import 'package:flutter/foundation.dart';
import 'package:ridenowappsss/core/services/network_services.dart';
import 'package:ridenowappsss/modules/wallet/data/models/wallet_models.dart';

class BankValidationService {
  final DioClient _dioClient;

  static const String _verifyAccountEndpoint = '/wallets/verify-account';

  // Error messages
  static const String _networkError = 'Network error. Please try again.';
  static const String _invalidAccount = 'Invalid account number';
  static const String _accountNotFound = 'Account number not found';

  BankValidationService({DioClient? dioClient})
    : _dioClient = dioClient ?? DioClient();

  /// Validate bank account number using the API
  Future<BankValidationResult> validateAccount({
    required String accountNumber,
    required String bankCode,
  }) async {
    try {
      _logRequest('Validate Account', accountNumber, bankCode);

      final body = {'account_number': accountNumber, 'bank_code': bankCode};

      final response = await _dioClient.post(
        _verifyAccountEndpoint,
        data: body,
      );

      _logResponse('Validation Response', response.data);

      final data = response.data as Map<String, dynamic>;

      // Handle success - check multiple possible response formats
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

      // If no account name found or success is false
      return BankValidationResult(
        isSuccess: false,
        errorMessage:
            data['message'] ??
            data['error'] ??
            'Unable to verify account number',
      );
    } catch (e) {
      _logError('Validate Account', e);

      // Parse error message from exception
      String errorMessage = _networkError;

      final errorStr = e.toString().toLowerCase();
      if (errorStr.contains('404')) {
        errorMessage = _accountNotFound;
      } else if (errorStr.contains('400')) {
        errorMessage = _invalidAccount;
      } else if (errorStr.contains('timeout')) {
        errorMessage = 'Request timeout. Please try again.';
      }

      return BankValidationResult(isSuccess: false, errorMessage: errorMessage);
    }
  }

  // Private helper methods
  void _logRequest(String operation, String accountNumber, String bankCode) {
    if (!kDebugMode) return;

    debugPrint('=== $operation ===');
    debugPrint('Account Number: $accountNumber');
    debugPrint('Bank Code: $bankCode');
  }

  void _logResponse(String operation, dynamic data) {
    if (!kDebugMode) return;

    debugPrint('$operation: $data');
  }

  void _logError(String operation, dynamic error) {
    if (!kDebugMode) return;

    debugPrint('=== $operation Error ===');
    debugPrint('Error: $error');
  }
}
