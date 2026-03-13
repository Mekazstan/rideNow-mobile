import 'package:flutter/foundation.dart';
import 'package:ridenowappsss/core/services/network_services.dart';
import 'package:ridenowappsss/core/utils/constants/api_constant.dart';
import 'package:ridenowappsss/modules/wallet/data/models/wallet_models.dart';

class WalletService {
  final DioClient _dioClient;

  WalletService({DioClient? dioClient}) : _dioClient = dioClient ?? DioClient();

  /// Fetches current wallet balance
  Future<WalletBalance> getWalletBalance() async {
    try {
      _logRequest('Get Wallet Balance', ApiConstants.walletBalanceEndpoint);

      final response = await _dioClient.get(ApiConstants.walletBalanceEndpoint);

      _logResponse('Balance', response.data);

      return WalletBalance.fromJson(response.data);
    } catch (e) {
      _logError('Get Balance', e);
      rethrow;
    }
  }

  /// Fetches wallet transactions with pagination
  Future<TransactionsResponse> getTransactions({
    int page = 1,
    int perPage = ApiConstants.defaultPerPage,
  }) async {
    try {
      final validatedPage = _validatePage(page);
      final validatedPerPage = _validatePerPage(perPage);

      _logRequest(
        'Get Wallet Transactions',
        ApiConstants.walletTransactionsEndpoint,
        params: {'page': validatedPage, 'per_page': validatedPerPage},
      );

      final response = await _dioClient.get(
        ApiConstants.walletTransactionsEndpoint,
        queryParameters: {'page': validatedPage, 'per_page': validatedPerPage},
      );

      _logResponse('Transactions', response.data);

      return TransactionsResponse.fromJson(response.data);
    } catch (e) {
      _logError('Get Transactions', e);
      rethrow;
    }
  }

  /// Refreshes transactions (fetches first page)
  Future<TransactionsResponse> refreshTransactions({
    int perPage = ApiConstants.defaultPerPage,
  }) async {
    return getTransactions(page: 1, perPage: perPage);
  }

  /// Loads next page of transactions
  Future<TransactionsResponse> loadMoreTransactions({
    required int nextPage,
    int perPage = ApiConstants.defaultPerPage,
  }) async {
    return getTransactions(page: nextPage, perPage: perPage);
  }

  /// Initiates deposit transaction and returns payment URL
  Future<Map<String, dynamic>> initiateDeposit({
    required double amount,
    required String paymentMethod,
    String? authorizationCode,
    Map<String, dynamic>? cardDetails,
  }) async {
    try {
      const endpoint = '/wallets/deposit';

      final body = {
        'amount': amount,
        'payment_method': paymentMethod,
        if (authorizationCode != null) 'authorization_code': authorizationCode,
        if (cardDetails != null) 'card_details': cardDetails,
      };

      _logRequest('Initiate Deposit', endpoint, params: body);

      final response = await _dioClient.post(endpoint, data: body);

      _logResponse('Deposit Initiated', response.data);

      final data = response.data as Map<String, dynamic>;

      if (data['success'] == true) {
        return {
          'success': true,
          'transaction_id': data['transaction_id'],
          'new_balance': data['new_balance'],
          'status': data['status'],
          'message': data['message'] ?? 'Deposit initiated successfully',
          'payment_url': data['payment_url'],
        };
      } else {
        throw Exception(data['message'] ?? 'Deposit initiation failed');
      }
    } catch (e) {
      _logError('Initiate Deposit', e);
      rethrow;
    }
  }

  /// Verifies payment using callback reference from payment gateway
  Future<Map<String, dynamic>> verifyPaymentCallback({
    required String reference,
  }) async {
    try {
      const endpoint = ApiConstants.paymentCallbackEndpoint;

      _logRequest(
        'Verify Payment Callback',
        endpoint,
        params: {'reference': reference},
      );

      final response = await _dioClient.get(
        endpoint,
        queryParameters: {'reference': reference},
      );

      _logResponse('Payment Callback Verified', response.data);

      final data = response.data as Map<String, dynamic>;

      return {
        'success': data['success'] ?? false,
        'status': data['status']?.toString().toLowerCase() ?? 'pending',
        'message': data['message'] ?? 'Payment verification completed',
        'transaction_id': data['transaction_id'],
        'amount': data['amount'],
        'new_balance': data['new_balance'],
      };
    } catch (e) {
      _logError('Verify Payment Callback', e);
      return {
        'success': false,
        'status': 'failed',
        'message': 'Failed to verify payment: ${e.toString()}',
      };
    }
  }

  /// Verifies transaction status by transaction ID
  Future<bool> verifyTransaction(String transactionId) async {
    try {
      final endpoint = '/wallets/transactions/$transactionId';

      _logRequest('Verify Transaction', endpoint);

      final response = await _dioClient.get(endpoint);

      _logResponse('Transaction Verified', response.data);

      final data = response.data as Map<String, dynamic>;
      final status = data['status']?.toString().toLowerCase();

      final isSuccessful =
          status == 'successful' ||
          status == 'success' ||
          status == 'completed';

      debugPrint('Transaction status: $status, isSuccessful: $isSuccessful');

      return isSuccessful;
    } catch (e) {
      _logError('Verify Transaction', e);
      return false;
    }
  }

  /// Creates a new withdrawal PIN
  Future<void> createWithdrawalPin(String pin) async {
    try {
      final endpoint = ApiConstants.withdrawalPinEndpoint;

      final body = {'pin': pin};

      _logRequest('Create Withdrawal PIN', endpoint, params: {'pin': '****'});

      final response = await _dioClient.post(endpoint, data: body);

      _logResponse('Withdrawal PIN Created', response.data);
    } catch (e) {
      _logError('Create Withdrawal PIN', e);
      rethrow;
    }
  }

  /// Verifies if withdrawal PIN is correct
  Future<bool> verifyWithdrawalPin(String pin) async {
    try {
      final endpoint = '${ApiConstants.withdrawalPinEndpoint}/verify';

      final body = {'pin': pin};

      _logRequest('Verify Withdrawal PIN', endpoint, params: {'pin': '****'});

      final response = await _dioClient.post(endpoint, data: body);

      _logResponse('PIN Verified', response.data);

      final data = response.data as Map<String, dynamic>;
      return data['valid'] == true || data['success'] == true;
    } catch (e) {
      _logError('Verify Withdrawal PIN', e);
      return false;
    }
  }

  /// Initiates withdrawal transaction with PIN verification
  Future<Map<String, dynamic>> initiateWithdrawal({
    required double amount,
    required String bankAccountId,
    required String withdrawalPin,
    String? description,
  }) async {
    try {
      final endpoint = ApiConstants.withdrawEndpoint;

      final body = {
        'amount': amount,
        'bank_account_id': bankAccountId,
        'withdrawal_pin': withdrawalPin,
        if (description != null) 'description': description,
      };

      _logRequest(
        'Initiate Withdrawal',
        endpoint,
        params: {
          'amount': amount,
          'bank_account_id': bankAccountId,
          'withdrawal_pin': '****',
          if (description != null) 'description': description,
        },
      );

      final response = await _dioClient.post(endpoint, data: body);

      _logResponse('Withdrawal Initiated', response.data);

      return response.data as Map<String, dynamic>;
    } catch (e) {
      _logError('Initiate Withdrawal', e);
      rethrow;
    }
  }

  int _validatePage(int page) => page < 1 ? 1 : page;

  int _validatePerPage(int perPage) =>
      perPage < 1 || perPage > 100 ? ApiConstants.defaultPerPage : perPage;

  void _logRequest(
    String operation,
    String endpoint, {
    Map<String, dynamic>? params,
  }) {
    if (!kDebugMode) return;

    debugPrint('=== $operation ===');
    debugPrint('Endpoint: $endpoint');
    if (params != null) debugPrint('Parameters: $params');
  }

  void _logResponse(String operation, dynamic data) {
    if (!kDebugMode) return;

    debugPrint('$operation Response: $data');
  }

  void _logError(String operation, dynamic error) {
    if (!kDebugMode) return;

    debugPrint('=== $operation Error ===');
    debugPrint('Error: $error');
  }
}
