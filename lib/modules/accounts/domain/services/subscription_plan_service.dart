import 'package:flutter/foundation.dart';
import 'package:ridenowappsss/core/services/network_services.dart';
import 'package:ridenowappsss/modules/accounts/data/models/subscrption_plan_model.dart';

class SubscriptionService {
  final DioClient _dioClient = DioClient();

  static const String _subscriptionPlansEndpoint =
      '/drivers/subscription-plans';
  static const String _subscribeEndpoint = '/drivers/subscribe';

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

  Future<Map<String, dynamic>> subscribeToPlan(String planId) async {
    try {
      if (kDebugMode) {
        print('=== Subscribe to Plan ===');
        print('Endpoint: $_subscribeEndpoint');
        print('Plan ID: $planId');
      }

      final response = await _dioClient.post(
        _subscribeEndpoint,
        data: {'plan_id': planId},
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
}
