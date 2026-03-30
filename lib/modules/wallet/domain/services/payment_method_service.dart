import 'package:flutter/foundation.dart';
import 'package:ridenowappsss/core/services/network_services.dart';
import 'package:ridenowappsss/core/utils/constants/api_constant.dart';
import 'package:ridenowappsss/modules/wallet/data/models/payment_method_models.dart';

class PaymentMethodService {
  final DioClient _dioClient;

  PaymentMethodService({DioClient? dioClient}) : _dioClient = dioClient ?? DioClient();

  /// Fetches user's payment methods (saved cards and wallet)
  Future<List<PaymentMethod>> getPaymentMethods() async {
    try {
      _logRequest('Get Payment Methods', ApiConstants.paymentMethodsEndpoint);

      final response = await _dioClient.get(ApiConstants.paymentMethodsEndpoint);

      _logResponse('Payment Methods', response.data);

      final paymentMethodsResponse = PaymentMethodsResponse.fromJson(response.data);
      return paymentMethodsResponse.paymentMethods;
    } catch (e) {
      _logError('Get Payment Methods', e);
      rethrow;
    }
  }

  void _logRequest(String operation, String endpoint) {
    if (!kDebugMode) return;
    debugPrint('=== $operation ===');
    debugPrint('Endpoint: $endpoint');
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
