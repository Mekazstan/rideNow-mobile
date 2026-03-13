import 'package:flutter/foundation.dart';
import 'package:ridenowappsss/core/services/network_services.dart';
import 'package:ridenowappsss/core/utils/constants/api_constant.dart';
import 'package:ridenowappsss/modules/wallet/data/models/driver_analytics_models.dart';

class DriverAnalyticsService {
  final DioClient _dioClient;

  DriverAnalyticsService({DioClient? dioClient})
    : _dioClient = dioClient ?? DioClient();

  /// Fetches driver earnings analytics
  Future<EarningsAnalytics> getEarningsAnalytics({
    String? period,
    String? startDate,
    String? endDate,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {};
      if (period != null) queryParams['period'] = period;
      if (startDate != null) queryParams['startDate'] = startDate;
      if (endDate != null) queryParams['endDate'] = endDate;

      final response = await _dioClient.get(
        ApiConstants.driverEarningsAnalyticsEndpoint,
        queryParameters: queryParams,
      );

      return EarningsAnalytics.fromJson(response.data);
    } catch (e) {
      debugPrint('Error fetching earnings analytics: $e');
      rethrow;
    }
  }

  /// Fetches driver performance analytics
  Future<PerformanceAnalytics> getPerformanceAnalytics({
    String? period,
    String? startDate,
    String? endDate,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {};
      if (period != null) queryParams['period'] = period;
      if (startDate != null) queryParams['start_date'] = startDate;
      if (endDate != null) queryParams['end_date'] = endDate;

      final response = await _dioClient.get(
        ApiConstants.driverPerformanceAnalyticsEndpoint,
        queryParameters: queryParams,
      );

      return PerformanceAnalytics.fromJson(response.data);
    } catch (e) {
      debugPrint('Error fetching performance analytics: $e');
      rethrow;
    }
  }

  /// Fetches driver ratings analytics
  Future<RatingsAnalytics> getRatingsAnalytics() async {
    try {
      final response = await _dioClient.get(
        ApiConstants.driverRatingsAnalyticsEndpoint,
      );
      return RatingsAnalytics.fromJson(response.data);
    } catch (e) {
      debugPrint('Error fetching ratings analytics: $e');
      rethrow;
    }
  }

  /// Fetches weekly summary
  Future<WeeklySummary> getWeeklySummary() async {
    try {
      final response = await _dioClient.get(
        ApiConstants.driverWeeklySummaryEndpoint,
      );
      return WeeklySummary.fromJson(response.data);
    } catch (e) {
      debugPrint('Error fetching weekly summary: $e');
      rethrow;
    }
  }

  /// Fetches daily limit status
  Future<DailyLimitStatus> getDailyLimitStatus() async {
    try {
      final response = await _dioClient.get(
        ApiConstants.driverDailyLimitStatusEndpoint,
      );
      return DailyLimitStatus.fromJson(response.data);
    } catch (e) {
      debugPrint('Error fetching daily limit status: $e');
      rethrow;
    }
  }
}
