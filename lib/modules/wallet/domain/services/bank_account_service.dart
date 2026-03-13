import 'package:flutter/foundation.dart';
import 'package:ridenowappsss/core/services/network_services.dart';
import 'package:ridenowappsss/core/utils/constants/api_constant.dart';
import 'package:ridenowappsss/modules/wallet/data/models/wallet_models.dart';

class BankAccountService {
  final DioClient _dioClient;

  BankAccountService({DioClient? dioClient})
    : _dioClient = dioClient ?? DioClient();

  /// Fetch all saved bank accounts from API
  Future<BankAccountsResponse> getBankAccounts() async {
    try {
      _logRequest('Get Bank Accounts', ApiConstants.bankAccountsEndpoint);

      final response = await _dioClient.get(ApiConstants.bankAccountsEndpoint);

      _logResponse('Bank Accounts', response.data);
      dynamic responseData = response.data;
      if (responseData is List) {
        debugPrint('Response is a List, converting to expected format');
        return BankAccountsResponse.fromJson(responseData);
      }
      return BankAccountsResponse.fromJson(responseData);
    } catch (e) {
      _logError('Get Bank Accounts', e);
      rethrow;
    }
  }

  /// Add a new bank account via API
  Future<BankAccount> addBankAccount({
    required String bankName,
    required String bankCode,
    required String accountNumber,
    required String accountHolderName,
    bool isDefault = false,
  }) async {
    try {
      final body = {
        'account_number': accountNumber,
        'bank_code': bankCode,
        'account_name': accountHolderName,
        'bank_name': bankName,
      };

      _logRequest(
        'Add Bank Account',
        ApiConstants.addBankAccountEndpoint,
        params: body,
      );

      final response = await _dioClient.post(
        ApiConstants.addBankAccountEndpoint,
        data: body,
      );

      _logResponse('Bank Account Added', response.data);

      final data = response.data as Map<String, dynamic>;

      Map<String, dynamic> accountData;

      if (data.containsKey('account')) {
        accountData = data['account'] as Map<String, dynamic>;
      } else if (data.containsKey('data')) {
        accountData = data['data'] as Map<String, dynamic>;
      } else {
        accountData = data;
      }
      if (!accountData.containsKey('id')) {
        accountData['id'] =
            accountData['_id'] ??
            DateTime.now().millisecondsSinceEpoch.toString();
      }
      if (!accountData.containsKey('bank_name')) {
        accountData['bank_name'] = bankName;
      }
      if (!accountData.containsKey('bank_code')) {
        accountData['bank_code'] = bankCode;
      }
      if (!accountData.containsKey('account_number')) {
        accountData['account_number'] = accountNumber;
      }
      if (!accountData.containsKey('account_holder_name')) {
        accountData['account_holder_name'] = accountHolderName;
      }

      return BankAccount.fromJson(accountData);
    } catch (e) {
      _logError('Add Bank Account', e);
      rethrow;
    }
  }

  /// Delete a bank account via API
  Future<bool> deleteBankAccount(String accountId) async {
    try {
      final endpoint = '${ApiConstants.bankAccountsEndpoint}/$accountId';

      _logRequest('Delete Bank Account', endpoint);

      final response = await _dioClient.delete(endpoint);

      _logResponse('Bank Account Deleted', response.data);

      return true;
    } catch (e) {
      _logError('Delete Bank Account', e);
      rethrow;
    }
  }

  /// Validate bank account with bank API
  Future<BankValidationResult> validateBankAccount({
    required String accountNumber,
    required String bankCode,
  }) async {
    try {
      final body = {'account_number': accountNumber, 'bank_code': bankCode};

      _logRequest(
        'Validate Bank Account',
        ApiConstants.validateBankAccountEndpoint,
        params: body,
      );

      final response = await _dioClient.post(
        ApiConstants.validateBankAccountEndpoint,
        data: body,
      );

      _logResponse('Account Validated', response.data);

      final data = response.data as Map<String, dynamic>;
      if (data['success'] == true ||
          data['status'] == true ||
          data['status'] == 'success') {
        final accountName =
            data['account_holder_name'] ??
            data['account_name'] ??
            data['accountName'] ??
            data['data']?['account_name'] ??
            data['data']?['account_holder_name'];

        if (accountName != null && accountName.toString().isNotEmpty) {
          return BankValidationResult(
            isSuccess: true,
            accountHolderName: accountName.toString(),
          );
        }
      }
      return BankValidationResult(
        isSuccess: false,
        errorMessage:
            data['message'] ??
            data['error'] ??
            'Unable to verify account number',
      );
    } catch (e) {
      _logError('Validate Bank Account', e);

      String errorMessage = 'Unable to verify account. Please try again.';

      if (e.toString().contains('404')) {
        errorMessage = 'Account not found';
      } else if (e.toString().contains('400')) {
        errorMessage = 'Invalid account details';
      } else if (e.toString().contains('timeout')) {
        errorMessage = 'Request timeout. Please try again.';
      }

      return BankValidationResult(isSuccess: false, errorMessage: errorMessage);
    }
  }

  /// Fetch all banks from API
  Future<BanksResponse> getBanks() async {
    try {
      _logRequest('Get Banks', ApiConstants.banksListEndpoint);

      final response = await _dioClient.get(ApiConstants.banksListEndpoint);

      _logResponse('Banks List', response.data);
      dynamic responseData = response.data;
      if (responseData is List) {
        debugPrint('Response is a List, converting to expected format');
        return BanksResponse.fromJson(responseData);
      }
      return BanksResponse.fromJson(responseData);
    } catch (e) {
      _logError('Get Banks', e);
      rethrow;
    }
  }

  // Private helper methods
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
