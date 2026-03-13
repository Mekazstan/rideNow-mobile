import 'package:flutter/material.dart';
import 'package:ridenowappsss/modules/wallet/data/models/wallet_models.dart';
import 'package:ridenowappsss/modules/wallet/domain/services/bank_account_service.dart';

enum BanksState { initial, loading, loaded, error }

/// ViewModel for managing bank list
class BanksProvider extends ChangeNotifier {
  final BankAccountService _bankAccountService;

  BanksProvider({BankAccountService? bankAccountService})
    : _bankAccountService = bankAccountService ?? BankAccountService();

  // State
  BanksState _state = BanksState.initial;
  List<Bank> _banks = [];
  List<Bank> _filteredBanks = [];
  String? _errorMessage;
  String _searchQuery = '';

  // Getters
  BanksState get state => _state;
  List<Bank> get banks => List.unmodifiable(_banks);
  List<Bank> get filteredBanks => List.unmodifiable(_filteredBanks);
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;

  bool get isLoading => _state == BanksState.loading;
  bool get hasError => _state == BanksState.error;
  bool get hasBanks => _banks.isNotEmpty;
  bool get hasFilteredBanks => _filteredBanks.isNotEmpty;

  /// Initialize - fetch banks
  Future<void> initialize() async {
    if (isLoading) return;

    try {
      _updateState(BanksState.loading);
      await fetchBanks();
      _updateState(BanksState.loaded);
    } catch (e) {
      _handleError(e, 'Failed to load banks');
    }
  }

  /// Fetch banks from API
  Future<void> fetchBanks() async {
    try {
      final response = await _bankAccountService.getBanks();
      _banks = response.banks;
      _filteredBanks = _banks;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _handleError(e, 'Failed to fetch banks');
      rethrow;
    }
  }

  /// Search banks
  void searchBanks(String query) {
    _searchQuery = query.trim();

    if (_searchQuery.isEmpty) {
      _filteredBanks = _banks;
    } else {
      _filteredBanks =
          _banks
              .where(
                (bank) => bank.name.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ),
              )
              .toList();
    }

    notifyListeners();
  }

  /// Clear search
  void clearSearch() {
    _searchQuery = '';
    _filteredBanks = _banks;
    notifyListeners();
  }

  /// Get bank by code
  Bank? getBankByCode(String code) {
    try {
      return _banks.firstWhere((bank) => bank.code == code);
    } catch (e) {
      return null;
    }
  }

  /// Get bank by name
  Bank? getBankByName(String name) {
    try {
      return _banks.firstWhere(
        (bank) => bank.name.toLowerCase() == name.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }

  // Private methods
  void _updateState(BanksState newState) {
    _state = newState;
    notifyListeners();
  }

  void _handleError(dynamic error, String defaultMessage) {
    _state = BanksState.error;
    _errorMessage = error.toString();
    notifyListeners();
  }
}
