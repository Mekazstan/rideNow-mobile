// ignore_for_file: unnecessary_overrides

import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:ridenowappsss/modules/authentication/data/models/auth_models.dart';
import 'package:ridenowappsss/modules/wallet/data/models/wallet_models.dart';
import 'package:ridenowappsss/modules/wallet/domain/services/wallet_service.dart';

enum WalletState { initial, loading, loaded, error, refreshing, loadingMore }

class WalletProvider extends ChangeNotifier {
  final WalletService _walletService;
  static const int _itemsPerPage = 20;

  WalletState _state = WalletState.initial;
  WalletBalance? _balance;
  List<WalletTransaction> _transactions = [];
  Pagination? _pagination;
  Exception? _error;
  bool _isBalanceVisible = true;

  DateTime? _filterStartDate;
  DateTime? _filterEndDate;
  List<WalletTransaction> _filteredTransactions = [];
  bool _isFilterActive = false;
  bool _hasWithdrawalPin = false;

  WalletProvider({WalletService? walletService})
    : _walletService = walletService ?? WalletService();

  WalletState get state => _state;
  WalletBalance? get walletBalance => _balance;
  List<WalletTransaction> get transactions =>
      _isFilterActive
          ? _filteredTransactions
          : List.unmodifiable(_transactions);
  Pagination? get pagination => _pagination;
  Exception? get lastError => _error;
  bool get balanceVisible => _isBalanceVisible;

  DateTime? get filterStartDate => _filterStartDate;
  DateTime? get filterEndDate => _filterEndDate;
  bool get isFilterActive => _isFilterActive;

  bool get isLoading => _state == WalletState.loading;
  bool get isRefreshing => _state == WalletState.refreshing;
  bool get isLoadingMore => _state == WalletState.loadingMore;
  bool get hasError => _state == WalletState.error;
  bool get hasMorePages => _pagination?.hasNext ?? false;
  bool get hasData => _balance != null && _transactions.isNotEmpty;
  bool get hasWithdrawalPin => _hasWithdrawalPin;

  String get formattedBalance {
    return _balance?.balance.toStringAsFixed(2) ?? '0.00';
  }

  String? get errorMessage {
    if (_error == null) return null;

    if (_error is ApiException) {
      return (_error as ApiException).message;
    } else if (_error is NetworkException) {
      return (_error as NetworkException).message;
    }

    return 'An unexpected error occurred';
  }

  /// Groups transactions by date (Today, Yesterday, or formatted date)
  Map<String, List<WalletTransaction>> get groupedTransactions {
    final transactionsToGroup =
        _isFilterActive ? _filteredTransactions : _transactions;

    if (transactionsToGroup.isEmpty) return {};

    final Map<String, List<WalletTransaction>> grouped = {};
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    for (var transaction in transactionsToGroup) {
      try {
        final parsedDate = DateTime.parse(transaction.createdAt);
        final transactionDate = DateTime(
          parsedDate.year,
          parsedDate.month,
          parsedDate.day,
        );

        String dateGroup;
        if (transactionDate == today) {
          dateGroup = 'Today';
        } else if (transactionDate == yesterday) {
          dateGroup = 'Yesterday';
        } else {
          dateGroup = DateFormat('MMMM dd, yyyy').format(transactionDate);
        }

        if (!grouped.containsKey(dateGroup)) {
          grouped[dateGroup] = [];
        }
        grouped[dateGroup]!.add(transaction);
      } catch (e) {
        _logError('Group transaction by date', e);
        continue;
      }
    }

    final sortedEntries =
        grouped.entries.toList()..sort((a, b) {
          final aDate = _getDateFromGroup(a.key, today, yesterday);
          final bDate = _getDateFromGroup(b.key, today, yesterday);
          return bDate.compareTo(aDate);
        });

    return Map.fromEntries(sortedEntries);
  }

  /// Applies date filter to transactions
  void applyDateFilter(DateTime? startDate, DateTime? endDate) {
    _filterStartDate = startDate;
    _filterEndDate = endDate;
    _isFilterActive = startDate != null || endDate != null;

    if (_isFilterActive) {
      _applyFilter();
    } else {
      _filteredTransactions = [];
    }

    notifyListeners();
  }

  /// Clears active date filter
  void clearDateFilter() {
    _filterStartDate = null;
    _filterEndDate = null;
    _isFilterActive = false;
    _filteredTransactions = [];
    notifyListeners();
  }

  void _applyFilter() {
    if (!_isFilterActive) {
      _filteredTransactions = [];
      return;
    }

    _filteredTransactions =
        _transactions.where((transaction) {
          try {
            final transactionDate = DateTime.parse(transaction.createdAt);

            if (_filterStartDate != null && _filterEndDate != null) {
              final startOfDay = DateTime(
                _filterStartDate!.year,
                _filterStartDate!.month,
                _filterStartDate!.day,
              );
              final endOfDay = DateTime(
                _filterEndDate!.year,
                _filterEndDate!.month,
                _filterEndDate!.day,
                23,
                59,
                59,
              );
              return transactionDate.isAfter(
                    startOfDay.subtract(const Duration(seconds: 1)),
                  ) &&
                  transactionDate.isBefore(
                    endOfDay.add(const Duration(seconds: 1)),
                  );
            }

            if (_filterStartDate != null) {
              final startOfDay = DateTime(
                _filterStartDate!.year,
                _filterStartDate!.month,
                _filterStartDate!.day,
              );
              return transactionDate.isAfter(
                startOfDay.subtract(const Duration(seconds: 1)),
              );
            }

            if (_filterEndDate != null) {
              final endOfDay = DateTime(
                _filterEndDate!.year,
                _filterEndDate!.month,
                _filterEndDate!.day,
                23,
                59,
                59,
              );
              return transactionDate.isBefore(
                endOfDay.add(const Duration(seconds: 1)),
              );
            }

            return true;
          } catch (e) {
            _logError('Filter transaction', e);
            return false;
          }
        }).toList();
  }

  DateTime _getDateFromGroup(
    String dateGroup,
    DateTime today,
    DateTime yesterday,
  ) {
    if (dateGroup == 'Today') return today;
    if (dateGroup == 'Yesterday') return yesterday;

    try {
      return DateFormat('MMMM dd, yyyy').parse(dateGroup);
    } catch (e) {
      return DateTime.now();
    }
  }

  /// Initializes wallet data (balance and transactions)
  Future<void> initializeWallet() async {
    if (isLoading) return;

    try {
      _updateState(WalletState.loading);
      _clearError();

      await Future.wait([
        _fetchWalletData(isInitialLoad: true),
        checkWithdrawalPinStatus(),
      ]);

      _updateState(WalletState.loaded);
    } catch (e) {
      _handleError(e, 'Initialize wallet');
    }
  }

  /// Refreshes wallet data with pull-to-refresh
  Future<void> refreshWallet() async {
    if (isRefreshing) return;

    try {
      _updateState(WalletState.refreshing);
      _clearError();

      await Future.wait([
        _fetchWalletData(isRefresh: true),
        checkWithdrawalPinStatus(),
      ]);

      _updateState(WalletState.loaded);
    } catch (e) {
      _handleError(e, 'Refresh wallet');
    }
  }

  /// Loads next page of transactions
  Future<void> loadMoreTransactions() async {
    if (!_canLoadMore()) return;

    try {
      _updateState(WalletState.loadingMore);
      _clearError();

      final nextPage = _getNextPage();
      await _fetchTransactions(page: nextPage, append: true);

      _updateState(WalletState.loaded);
    } catch (e) {
      _handleError(e, 'Load more transactions');
    }
  }

  /// Fetches current wallet balance
  Future<void> fetchBalance() async {
    try {
      _clearError();
      _balance = await _walletService.getWalletBalance();
      notifyListeners();
    } catch (e) {
      _handleError(e, 'Fetch balance');
    }
  }

  /// Checks if user has a withdrawal PIN set
  Future<void> checkWithdrawalPinStatus() async {
    try {
      _hasWithdrawalPin = await _walletService.checkWithdrawalPinStatus();
      notifyListeners();
    } catch (e) {
      _logError('Check withdrawal PIN status', e);
      // Fail silently to false
    }
  }

  /// Toggles balance visibility (show/hide)
  void toggleBalanceVisibility() {
    _isBalanceVisible = !_isBalanceVisible;
    notifyListeners();
  }

  /// Clears all wallet data and resets state
  void clearWalletData() {
    _balance = null;
    _transactions = [];
    _pagination = null;
    _state = WalletState.initial;
    clearDateFilter();
    _clearError();
    notifyListeners();
  }

  /// Initiates deposit transaction with payment details
  Future<Map<String, dynamic>?> initiateDeposit({
    required double amount,
    required String paymentMethod,
    String? authorizationCode,
    Map<String, dynamic>? cardDetails,
  }) async {
    try {
      _logDebug('Initiating deposit', {
        'amount': amount,
        'payment_method': paymentMethod,
      });

      final response = await _walletService.initiateDeposit(
        amount: amount,
        paymentMethod: paymentMethod,
        authorizationCode: authorizationCode,
        cardDetails: cardDetails,
      );

      _logDebug('Deposit initiated successfully', response);

      return response;
    } catch (e) {
      _logError('Initiate deposit', e);
      _error = e is Exception ? e : Exception(e.toString());
      rethrow;
    }
  }

  /// Verifies payment using callback reference with fallback methods
  Future<bool> verifyPaymentCallback(String reference) async {
    if (reference.isEmpty) {
      _logDebug('Cannot verify: Reference is empty', null);
      return false;
    }

    try {
      _logDebug('Verifying payment callback', {'reference': reference});

      final response = await _walletService.verifyPaymentCallback(
        reference: reference,
      );

      _logDebug('Payment callback verification response', response);

      bool isSuccessful = _isPaymentSuccessful(response);

      if (isSuccessful) {
        _logDebug('Verification result: SUCCESS', {'reference': reference});
        return true;
      }

      _logDebug(
        'Callback verification inconclusive, trying alternatives',
        null,
      );
      return await _verifyByAlternativeMethods(reference);
    } catch (e) {
      _logError('Verify payment callback', e);
      _logDebug(
        'Error during callback verification, trying alternatives',
        null,
      );
      return await _verifyByAlternativeMethods(reference);
    }
  }

  bool _isPaymentSuccessful(Map<String, dynamic> response) {
    if (response['success'] == true) {
      return true;
    }

    if (response.containsKey('status')) {
      final status = response['status'].toString().toLowerCase();
      if (_isSuccessStatus(status)) {
        return true;
      }
    }

    if (response.containsKey('data') && response['data'] is Map) {
      final data = response['data'] as Map<String, dynamic>;
      if (data.containsKey('status')) {
        final status = data['status'].toString().toLowerCase();
        if (_isSuccessStatus(status)) {
          return true;
        }
      }
    }

    return false;
  }

  bool _isSuccessStatus(String status) {
    return status == 'successful' ||
        status == 'success' ||
        status == 'completed';
  }

  Future<bool> _verifyByAlternativeMethods(String reference) async {
    try {
      _logDebug('Waiting before checking recent transactions', null);
      await Future.delayed(const Duration(seconds: 3));

      bool verifiedByTransaction = await _verifyByRecentTransaction(reference);
      if (verifiedByTransaction) {
        _logDebug('Verified by recent transaction check', null);
        return true;
      }

      _logDebug('First attempt failed, waiting longer...', null);
      await Future.delayed(const Duration(seconds: 2));

      verifiedByTransaction = await _verifyByRecentTransaction(reference);
      if (verifiedByTransaction) {
        _logDebug('Verified by second transaction check', null);
        return true;
      }

      _logDebug('All verification methods failed', null);
      return false;
    } catch (e) {
      _logError('Alternative verification methods', e);
      return false;
    }
  }

  Future<bool> _verifyByRecentTransaction(String reference) async {
    try {
      _logDebug('Verifying by recent transactions', {'reference': reference});

      await _fetchTransactions(page: 1, replace: false);

      final matchingTransaction = _transactions.firstWhere((t) {
        if (t.referenceId == reference || t.externalReference == reference) {
          return true;
        }

        try {
          final createdAt = DateTime.parse(t.createdAt);
          final isRecent = DateTime.now().difference(createdAt).inMinutes < 5;
          final isDeposit =
              t.type.toLowerCase() == 'deposit' ||
              t.type.toLowerCase() == 'credit';
          final isSuccessful = _isSuccessStatus(t.status.toLowerCase());

          return isRecent && isDeposit && isSuccessful;
        } catch (e) {
          return false;
        }
      }, orElse: () => throw Exception('No matching transaction found'));

      _logDebug('Found matching transaction', {
        'transaction_id': matchingTransaction.id,
        'status': matchingTransaction.status,
        'reference': matchingTransaction.referenceId,
      });

      return _isSuccessStatus(matchingTransaction.status.toLowerCase());
    } catch (e) {
      _logError('Verify by recent transaction', e);
      return false;
    }
  }

  /// Verifies deposit transaction by ID
  Future<bool> verifyDeposit(String transactionId) async {
    if (transactionId.isEmpty) {
      _logDebug('Cannot verify: Transaction ID is empty', null);
      return false;
    }

    try {
      _logDebug('Verifying transaction', {'transaction_id': transactionId});

      final isSuccessful = await _walletService.verifyTransaction(
        transactionId,
      );

      _logDebug('Transaction verification result', {
        'is_successful': isSuccessful,
      });

      return isSuccessful;
    } catch (e) {
      _logError('Verify deposit', e);
      return false;
    }
  }

  /// Verifies deposit by checking transaction list
  Future<bool> verifyDepositByTransactionList(String transactionId) async {
    try {
      _logDebug('Verifying by transaction list', {
        'transaction_id': transactionId,
      });

      await _fetchTransactions(page: 1, replace: true);

      final transaction = _transactions.firstWhere(
        (t) => t.id == transactionId,
        orElse: () => throw Exception('Transaction not found'),
      );

      final status = transaction.status.toLowerCase();
      final isSuccessful =
          status == 'successful' ||
          status == 'success' ||
          status == 'completed';

      _logDebug('Transaction found in list', {
        'status': status,
        'is_successful': isSuccessful,
      });

      return isSuccessful;
    } catch (e) {
      _logError('Verify by transaction list', e);
      return false;
    }
  }

  /// Creates a new withdrawal PIN
  Future<void> createWithdrawalPin(String pin) async {
    try {
      _logDebug('Creating withdrawal PIN', {'pin_length': pin.length});

      await _walletService.createWithdrawalPin(pin);

      _hasWithdrawalPin = true;
      notifyListeners();

      _logDebug('Withdrawal PIN created successfully', null);
    } catch (e) {
      _logError('Create withdrawal PIN', e);
      _error = e is Exception ? e : Exception(e.toString());
      rethrow;
    }
  }

  /// Verifies withdrawal PIN
  Future<bool> verifyWithdrawalPin(String pin) async {
    try {
      _logDebug('Verifying withdrawal PIN', {'pin_length': pin.length});

      final isValid = await _walletService.verifyWithdrawalPin(pin);

      _logDebug('PIN verification result', {'is_valid': isValid});

      return isValid;
    } catch (e) {
      _logError('Verify withdrawal PIN', e);
      return false;
    }
  }

  /// Initiates withdrawal transaction
  Future<Map<String, dynamic>?> initiateWithdrawal({
    required double amount,
    required String bankAccountId,
    required String withdrawalPin,
    String? description,
  }) async {
    try {
      _logDebug('Initiating withdrawal', {
        'amount': amount,
        'bank_account_id': bankAccountId,
      });

      final response = await _walletService.initiateWithdrawal(
        amount: amount,
        bankAccountId: bankAccountId,
        withdrawalPin: withdrawalPin,
        description: description,
      );

      _logDebug('Withdrawal initiated successfully', response);

      await fetchBalance();

      return response;
    } catch (e) {
      _logError('Initiate withdrawal', e);
      _error = e is Exception ? e : Exception(e.toString());
      rethrow;
    }
  }

  /// Finalizes withdrawal transaction with OTP
  Future<Map<String, dynamic>?> finalizeWithdrawal({
    required String transferCode,
    required String otp,
    required String transactionId,
  }) async {
    try {
      _logDebug('Finalizing withdrawal', {
        'transferCode': transferCode,
        'transactionId': transactionId,
      });

      final response = await _walletService.finalizeWithdrawal(
        transferCode: transferCode,
        otp: otp,
        transactionId: transactionId,
      );

      _logDebug('Withdrawal finalized successfully', response);

      await _fetchWalletData(isRefresh: true);

      return response;
    } catch (e) {
      _logError('Finalize withdrawal', e);
      _error = e is Exception ? e : Exception(e.toString());
      rethrow;
    }
  }

  Future<void> _fetchWalletData({

    bool isInitialLoad = false,
    bool isRefresh = false,
  }) async {
    await Future.wait([
      _fetchBalance(),
      _fetchTransactions(page: 1, replace: isInitialLoad || isRefresh),
    ]);
  }

  Future<void> _fetchBalance() async {
    _balance = await _walletService.getWalletBalance();
  }

  Future<void> _fetchTransactions({
    required int page,
    bool replace = false,
    bool append = false,
  }) async {
    final response = await _walletService.getTransactions(
      page: page,
      perPage: _itemsPerPage,
    );

    _updateTransactions(response, replace: replace, append: append);
    _pagination = response.pagination;
  }

  void _updateTransactions(
    TransactionsResponse response, {
    bool replace = false,
    bool append = false,
  }) {
    if (replace) {
      _transactions = response.transactions;
    } else if (append) {
      _transactions.addAll(response.transactions);
    } else {
      _transactions = response.transactions;
    }

    if (_isFilterActive) {
      _applyFilter();
    }
  }

  bool _canLoadMore() {
    return hasMorePages && !isLoadingMore && !isLoading;
  }

  int _getNextPage() {
    return (_pagination?.currentPage ?? 0) + 1;
  }

  void _updateState(WalletState newState) {
    _state = newState;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  void _handleError(dynamic error, String context) {
    _logError(context, error);
    _state = WalletState.error;
    _error = error is Exception ? error : Exception(error.toString());
    notifyListeners();
  }

  void _logError(String context, dynamic error) {
    if (kDebugMode) {
      print('=== $context Error ===');
      print('Error: $error');
    }
  }

  void _logDebug(String context, dynamic data) {
    if (kDebugMode) {
      print('=== $context ===');
      if (data != null) print('Data: $data');
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}
