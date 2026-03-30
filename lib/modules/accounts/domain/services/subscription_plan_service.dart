import 'package:flutter/foundation.dart';
import 'package:ridenowappsss/core/services/network_services.dart';
import 'package:ridenowappsss/modules/accounts/data/models/subscription_plan_model.dart';

class SubscriptionService {
  final DioClient _dioClient = DioClient();

  static const String _subscriptionPlansEndpoint =
      '/drivers/subscription-plans';
  static const String _subscribeEndpoint = '/onboardings/drivers/subscription';

  Future<SubscriptionPlanResponse> getSubscriptionPlans() async {
    try {
      if (kDebugMode) {
        print('=== Get Subscription Plans ===');
        print('Endpoint: $_subscriptionPlansEndpoint');
      }

      final response = await _dioClient.get(_subscriptionPlansEndpoint);

      if (kDebugMode) {
        print('Subscription Plans Response: ${response.data}');
      }

      return SubscriptionPlanResponse.fromJson(response.data);
    } catch (e) {
      if (kDebugMode) {
        print('Get Subscription Plans Error: $e');
      }
      rethrow;
    }
  }

  Future<Map<String, dynamic>> subscribeToPlan(
    String planType, {
    String paymentMethod = 'card',
    bool autoRenew = true,
    String? authorizationCode,
  }) async {
    try {
      if (kDebugMode) {
        print('=== Subscribe to Plan ===');
        print('Endpoint: $_subscribeEndpoint');
        print('Plan Type: $planType');
        print('Payment Method: $paymentMethod');
        if (authorizationCode != null) print('Authorization Code: $authorizationCode');
      }

      final response = await _dioClient.post(
        _subscribeEndpoint,
        data: {
          'plan_type': planType.toLowerCase(),
          'payment_method': paymentMethod,
          'auto_renew': autoRenew,
          if (authorizationCode != null) 'authorization_code': authorizationCode,
        },
      );

      if (kDebugMode) {
        print('Subscribe Response: ${response.data}');
      }

      return response.data as Map<String, dynamic>;
    } catch (e) {
      if (kDebugMode) {
        print('Subscribe to Plan Error: $e');
      }
      rethrow;
    }
  }


  Future<bool> verifyPayment(String reference) async {
    try {
      if (kDebugMode) {
        print('=== Verify Subscription Payment ===');
        print('Reference: $reference');
      }

      final response = await _dioClient.get(
        '/wallets/payment-callback',
        queryParameters: {'reference': reference},
      );

      if (kDebugMode) {
        print('Verify Response: ${response.data}');
      }

      final data = response.data as Map<String, dynamic>;
      
      // The backend redirect might cause Dio to return the final page or 
      // if it's an API call, it returns the JSON.
      // Based on WalletService, we expect a 'success' field.
      return data['success'] == true;
    } catch (e) {
      if (kDebugMode) {
        print('Verify Subscription Payment Error: $e');
      }
      return false;
    }
  }
}

