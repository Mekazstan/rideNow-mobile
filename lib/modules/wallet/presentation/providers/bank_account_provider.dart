import 'package:flutter/material.dart';
import 'package:ridenowappsss/modules/wallet/data/models/wallet_models.dart';
import 'package:ridenowappsss/modules/wallet/domain/services/bank_account_service.dart';
import 'package:ridenowappsss/modules/wallet/domain/services/bank_validation_service.dart';

enum BankAccountState { initial, loading, loaded, error }

class BankAccountProvider extends ChangeNotifier {
  final BankAccountService _bankAccountService;
  final BankValidationService _validationService;

  static const int _accountNumberLength = 10;
  static const String _selectBankError = 'Please select a bank first';
  static const String _invalidFormatError = 'Account number must be 10 digits';
  static const String _verificationError =
      'Unable to verify account. Please try again.';

  BankAccountProvider({
    BankAccountService? bankAccountService,
    BankValidationService? validationService,
  }) : _bankAccountService = bankAccountService ?? BankAccountService(),
       _validationService = validationService ?? BankValidationService();

  // State management
  BankAccountState _state = BankAccountState.initial;
  ValidationState _validationState = ValidationState.idle;
  String? _accountHolderName;
  String? _errorMessage;

  // Input state
  String _accountNumber = '';
  String? _selectedBankName;
  String? _selectedBankCode;

  // Saved accounts
  List<BankAccount> _savedAccounts = [];

  // Getters - State
  BankAccountState get state => _state;
  ValidationState get validationState => _validationState;
  String? get accountHolderName => _accountHolderName;
  String? get errorMessage => _errorMessage;

  // Getters - Input state
  String get accountNumber => _accountNumber;
  String? get selectedBankName => _selectedBankName;
  String? get selectedBankCode => _selectedBankCode;

  // Getters - Computed state
  bool get isLoading => _state == BankAccountState.loading;
  bool get isValidating => _validationState == ValidationState.loading;
  bool get isAccountValid =>
      _validationState == ValidationState.success && _accountHolderName != null;
  bool get hasError =>
      _state == BankAccountState.error ||
      (_validationState == ValidationState.error && _errorMessage != null);
  bool get canAddAccount => isAccountValid && _isAccountNumberComplete();
  bool get hasBankSelected => _selectedBankCode != null;

  // Getters - Saved accounts
  List<BankAccount> get savedBankAccounts => List.unmodifiable(_savedAccounts);
  int get savedAccountsCount => _savedAccounts.length;
  bool get hasSavedAccounts => _savedAccounts.isNotEmpty;

  /// Initialize - fetch saved bank accounts from API
  Future<void> initialize() async {
    if (isLoading) return;

    try {
      _updateState(BankAccountState.loading);
      await fetchBankAccounts();
      _updateState(BankAccountState.loaded);
    } catch (e) {
      _handleError(e, 'Failed to load bank accounts');
    }
  }

  /// Fetch bank accounts from API
  Future<void> fetchBankAccounts() async {
    try {
      final response = await _bankAccountService.getBankAccounts();
      _savedAccounts = response.accounts;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _handleError(e, 'Failed to fetch bank accounts');
      rethrow;
    }
  }

  /// Refresh bank accounts
  Future<void> refreshBankAccounts() async {
    await fetchBankAccounts();
  }

  /// Set selected bank details
  void setBankDetails({required String bankName, required String bankCode}) {
    _selectedBankName = bankName;
    _selectedBankCode = bankCode;
    notifyListeners();

    // Re-validate if account number is complete
    if (_isAccountNumberComplete()) {
      _validateAccount();
    }
  }

  /// Handle account number input changes
  void onAccountNumberChanged(String value) {
    _accountNumber = value.trim();
    _resetValidationState();

    // Validate format and trigger validation if complete
    if (!_validateInputFormat()) return;

    if (_shouldValidate()) {
      _validateAccount();
    }
  }

  /// Add validated account to saved accounts via API
  Future<BankAccount?> addBankAccount() async {
    if (!canAddAccount) {
      _errorMessage = 'Cannot add account. Please verify account first.';
      return null;
    }

    // Validate all required fields
    if (_selectedBankName == null ||
        _selectedBankCode == null ||
        _accountHolderName == null ||
        _accountNumber.isEmpty) {
      _errorMessage = 'Missing required information';
      return null;
    }

    try {
      _updateState(BankAccountState.loading);

      debugPrint('=== Adding Bank Account ===');
      debugPrint('Bank Name: $_selectedBankName');
      debugPrint('Bank Code: $_selectedBankCode');
      debugPrint('Account Number: $_accountNumber');
      debugPrint('Account Holder: $_accountHolderName');

      final account = await _bankAccountService.addBankAccount(
        bankName: _selectedBankName!,
        bankCode: _selectedBankCode!,
        accountNumber: _accountNumber,
        accountHolderName: _accountHolderName!,
      );

      debugPrint('=== Bank Account Added Successfully ===');
      debugPrint('Account ID: ${account.id}');

      // Refresh the list to get updated data
      await fetchBankAccounts();

      _updateState(BankAccountState.loaded);

      // Reset form after successful addition
      reset();

      return account;
    } catch (e) {
      debugPrint('=== Add Bank Account Error ===');
      debugPrint('Error: $e');

      _handleError(e, 'Failed to add bank account');

      // Parse specific error messages
      final errorStr = e.toString().toLowerCase();
      if (errorStr.contains('duplicate')) {
        _errorMessage = 'This account already exists';
      } else if (errorStr.contains('400')) {
        _errorMessage = 'Invalid account details';
      } else if (errorStr.contains('401') || errorStr.contains('403')) {
        _errorMessage = 'Authentication failed';
      } else if (errorStr.contains('network')) {
        _errorMessage = 'Network error. Please try again.';
      } else {
        _errorMessage = 'Failed to add bank account';
      }

      return null;
    }
  }

  /// Remove account from saved accounts via API
  Future<void> removeBankAccount(BankAccount account) async {
    try {
      await _bankAccountService.deleteBankAccount(account.id);

      // Refresh the list
      await fetchBankAccounts();
    } catch (e) {
      _handleError(e, 'Failed to remove bank account');
    }
  }

  /// Get account by account number
  BankAccount? getAccountByNumber(String accountNumber) {
    try {
      return _savedAccounts.firstWhere(
        (account) => account.accountNumber == accountNumber,
      );
    } catch (e) {
      return null;
    }
  }

  /// Check if account exists
  bool hasAccount(String accountNumber) {
    return _savedAccounts.any(
      (account) => account.accountNumber == accountNumber,
    );
  }

  /// Reset validation state only
  void reset() {
    _accountNumber = '';
    _resetValidationState();
  }

  /// Reset everything including bank selection
  void resetAll() {
    _accountNumber = '';
    _selectedBankName = null;
    _selectedBankCode = null;
    _resetValidationState();
  }

  // Private validation methods
  bool _validateInputFormat() {
    if (_accountNumber.isEmpty) return true;

    if (!_isValidFormat()) {
      _setErrorState(_invalidFormatError);
      return false;
    }

    return true;
  }

  bool _isValidFormat() {
    return _accountNumber.length == _accountNumberLength &&
        _isNumeric(_accountNumber);
  }

  bool _isNumeric(String value) {
    return RegExp(r'^\d+$').hasMatch(value);
  }

  bool _shouldValidate() {
    return _isAccountNumberComplete() && hasBankSelected;
  }

  bool _isAccountNumberComplete() {
    return _accountNumber.length == _accountNumberLength;
  }

  Future<void> _validateAccount() async {
    if (!hasBankSelected) {
      _setErrorState(_selectBankError);
      return;
    }

    _setLoadingState();

    try {
      // Try API validation first
      final apiResult = await _bankAccountService.validateBankAccount(
        accountNumber: _accountNumber,
        bankCode: _selectedBankCode!,
      );

      if (apiResult.isSuccess && apiResult.accountHolderName != null) {
        _setSuccessState(apiResult.accountHolderName!);
        return;
      }

      // Fallback to local validation if API fails
      final result = await _validationService.validateAccount(
        accountNumber: _accountNumber,
        bankCode: _selectedBankCode!,
      );

      if (result.isSuccess && result.accountHolderName != null) {
        _setSuccessState(result.accountHolderName!);
      } else {
        _setErrorState(result.errorMessage ?? _verificationError);
      }
    } catch (e) {
      _setErrorState(_verificationError);
    }
  }

  // State management methods
  void _updateState(BankAccountState newState) {
    _state = newState;
    notifyListeners();
  }

  void _resetValidationState() {
    _validationState = ValidationState.idle;
    _accountHolderName = null;
    _errorMessage = null;
    notifyListeners();
  }

  void _setLoadingState() {
    _validationState = ValidationState.loading;
    _accountHolderName = null;
    _errorMessage = null;
    notifyListeners();
  }

  void _setSuccessState(String name) {
    _validationState = ValidationState.success;
    _accountHolderName = name;
    _errorMessage = null;
    notifyListeners();
  }

  void _setErrorState(String message) {
    _validationState = ValidationState.error;
    _accountHolderName = null;
    _errorMessage = message;
    notifyListeners();
  }

  void _handleError(dynamic error, String defaultMessage) {
    _state = BankAccountState.error;
    _errorMessage = error.toString();
    notifyListeners();
  }
}
