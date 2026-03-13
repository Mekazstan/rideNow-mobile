import 'package:flutter/material.dart';
import 'package:ridenowappsss/modules/wallet/data/models/driver_analytics_models.dart';
import 'package:ridenowappsss/modules/wallet/domain/services/driver_analytics_service.dart';

enum AnalyticsState { initial, loading, loaded, error }

class DriverAnalyticsProvider extends ChangeNotifier {
  final DriverAnalyticsService _analyticsService;

  AnalyticsState _state = AnalyticsState.initial;
  EarningsAnalytics? _earnings;
  PerformanceAnalytics? _performance;
  RatingsAnalytics? _ratings;
  WeeklySummary? _weeklySummary;
  DailyLimitStatus? _dailyLimit;
  String? _errorMessage;

  DriverAnalyticsProvider({DriverAnalyticsService? analyticsService})
    : _analyticsService = analyticsService ?? DriverAnalyticsService();

  AnalyticsState get state => _state;
  EarningsAnalytics? get earnings => _earnings;
  PerformanceAnalytics? get performance => _performance;
  RatingsAnalytics? get ratings => _ratings;
  WeeklySummary? get weeklySummary => _weeklySummary;
  DailyLimitStatus? get dailyLimit => _dailyLimit;
  String? get errorMessage => _errorMessage;

  bool get isLoading => _state == AnalyticsState.loading;
  bool get hasError => _state == AnalyticsState.error;

  /// Fetches all analytics data for a specific period
  Future<void> fetchAllAnalytics({
    String period = 'monthly',
    String? startDate,
    String? endDate,
  }) async {
    _state = AnalyticsState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _analyticsService.getEarningsAnalytics(
          period: period,
          startDate: startDate,
          endDate: endDate,
        ),
        _analyticsService.getPerformanceAnalytics(
          period: period,
          startDate: startDate,
          endDate: endDate,
        ),
        _analyticsService.getRatingsAnalytics(),
        _analyticsService.getWeeklySummary(),
        _analyticsService.getDailyLimitStatus(),
      ]);

      _earnings = results[0] as EarningsAnalytics;
      _performance = results[1] as PerformanceAnalytics;
      _ratings = results[2] as RatingsAnalytics;
      _weeklySummary = results[3] as WeeklySummary;
      _dailyLimit = results[4] as DailyLimitStatus;

      _state = AnalyticsState.loaded;
    } catch (e) {
      _state = AnalyticsState.error;
      _errorMessage = e.toString();
      debugPrint('Error in fetchAllAnalytics: $e');
    } finally {
      notifyListeners();
    }
  }

  /// Refreshes only daily limit status
  Future<void> refreshDailyLimit() async {
    try {
      _dailyLimit = await _analyticsService.getDailyLimitStatus();
      notifyListeners();
    } catch (e) {
      debugPrint('Error refreshing daily limit: $e');
    }
  }

  /// Sets state to loading (for UI responsiveness)
  void setLoading() {
    _state = AnalyticsState.loading;
    notifyListeners();
  }
}
