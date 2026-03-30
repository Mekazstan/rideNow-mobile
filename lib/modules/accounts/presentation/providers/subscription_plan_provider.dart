import 'package:flutter/foundation.dart';
import 'package:ridenowappsss/modules/accounts/data/models/subscription_plan_model.dart';
import 'package:ridenowappsss/modules/accounts/domain/services/subscription_plan_service.dart';

enum SubscriptionState { initial, loading, loaded, error }

class SubscriptionProvider extends ChangeNotifier {
  final SubscriptionService _subscriptionService = SubscriptionService();

  SubscriptionState _state = SubscriptionState.initial;
  List<SubscriptionPlan> _plans = [];
  CurrentSubscription? _currentSubscription;
  String? _errorMessage;
  bool _isSubscribing = false;

  SubscriptionState get state => _state;
  List<SubscriptionPlan> get plans => _plans;
  CurrentSubscription? get currentSubscription => _currentSubscription;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _state == SubscriptionState.loading;
  bool get isSubscribing => _isSubscribing;

  /// Fetches available subscription plans and current user subscription
  Future<void> fetchSubscriptionPlans() async {
    try {
      if (kDebugMode) {
        print('=== SubscriptionProvider: Fetching Plans ===');
      }

      _state = SubscriptionState.loading;
      _errorMessage = null;
      notifyListeners();

      final response = await _subscriptionService.getSubscriptionPlans();

      _plans = response.plans;
      _currentSubscription = response.currentSubscription;
      _state = SubscriptionState.loaded;

      if (kDebugMode) {
        print('Plans loaded: ${_plans.length}');
        print(
          'Current subscription: ${_currentSubscription?.planName ?? "None"}',
        );
      }

      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error in SubscriptionProvider: $e');
      }

      _state = SubscriptionState.error;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
    }
  }

  /// Subscribes user to a plan and refreshes subscription data
  Future<Map<String, dynamic>> subscribeToPlan(
    String planType, {
    String paymentMethod = 'card',
    bool autoRenew = true,
    String? authorizationCode,
  }) async {
    try {
      if (kDebugMode) {
        print('=== SubscriptionProvider: Subscribing to Plan $planType ===');
      }

      _isSubscribing = true;
      _errorMessage = null;
      notifyListeners();

      final response = await _subscriptionService.subscribeToPlan(
        planType,
        paymentMethod: paymentMethod,
        autoRenew: autoRenew,
        authorizationCode: authorizationCode,
      );

      if (kDebugMode) {
        print('Subscription response: ${response['message']}');
      }

      await fetchSubscriptionPlans();

      _isSubscribing = false;
      notifyListeners();

      return response;
    } catch (e) {

      if (kDebugMode) {
        print('Error subscribing to plan: $e');
      }

      _isSubscribing = false;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();

      return {'success': false, 'error': _errorMessage};
    }
  }

  /// Verifies a subscription payment after WebView checkout
  Future<bool> verifySubscriptionPayment(String reference) async {
    try {
      if (kDebugMode) {
        print('=== SubscriptionProvider: Verifying Payment $reference ===');
      }

      final isSuccessful = await _subscriptionService.verifyPayment(reference);

      if (isSuccessful) {
        await fetchSubscriptionPlans();
      }

      return isSuccessful;
    } catch (e) {
      if (kDebugMode) {
        print('Error verifying subscription payment: $e');
      }
      return false;
    }
  }


  /// Clears any error messages
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Returns a plan by its ID, or null if not found
  SubscriptionPlan? getPlanById(String planId) {
    try {
      return _plans.firstWhere((plan) => plan.id == planId);
    } catch (e) {
      return null;
    }
  }

  /// Checks if the given plan is the user's current subscription
  bool isPlanCurrent(String planId) {
    if (_currentSubscription == null) return false;
    return _currentSubscription!.planId == planId;
  }
}
