// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'driver_analytics_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EarningsAnalytics _$EarningsAnalyticsFromJson(Map<String, dynamic> json) =>
    EarningsAnalytics(
      totalRevenue: (json['total_revenue'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] as String? ?? 'USD',
      peakLocations: (json['peakLocations'] as List<dynamic>?)
          ?.map((e) => PeakLocation.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$EarningsAnalyticsToJson(EarningsAnalytics instance) =>
    <String, dynamic>{
      'total_revenue': instance.totalRevenue,
      'currency': instance.currency,
      'peakLocations': instance.peakLocations,
    };

PeakLocation _$PeakLocationFromJson(Map<String, dynamic> json) => PeakLocation(
      name: json['name'] as String,
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      percentage: (json['percentage'] as num?)?.toDouble() ?? 0.0,
    );

Map<String, dynamic> _$PeakLocationToJson(PeakLocation instance) =>
    <String, dynamic>{
      'name': instance.name,
      'amount': instance.amount,
      'percentage': instance.percentage,
    };

PerformanceAnalytics _$PerformanceAnalyticsFromJson(
        Map<String, dynamic> json) =>
    PerformanceAnalytics(
      ridesCompleted: (json['rides_completed'] as num?)?.toInt() ?? 0,
      distanceCovered: (json['distance_covered'] as num?)?.toDouble() ?? 0.0,
      distanceUnit: json['distance_unit'] as String? ?? 'km',
    );

Map<String, dynamic> _$PerformanceAnalyticsToJson(
        PerformanceAnalytics instance) =>
    <String, dynamic>{
      'rides_completed': instance.ridesCompleted,
      'distance_covered': instance.distanceCovered,
      'distance_unit': instance.distanceUnit,
    };

RatingsAnalytics _$RatingsAnalyticsFromJson(Map<String, dynamic> json) =>
    RatingsAnalytics(
      averageRating: (json['average_rating'] as num?)?.toDouble() ?? 0.0,
      totalRatings: (json['total_ratings'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$RatingsAnalyticsToJson(RatingsAnalytics instance) =>
    <String, dynamic>{
      'average_rating': instance.averageRating,
      'total_ratings': instance.totalRatings,
    };

DailyLimitStatus _$DailyLimitStatusFromJson(Map<String, dynamic> json) =>
    DailyLimitStatus(
      limit: (json['limit'] as num?)?.toInt() ?? 0,
      completed: (json['completed'] as num?)?.toInt() ?? 0,
      remaining: (json['remaining'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$DailyLimitStatusToJson(DailyLimitStatus instance) =>
    <String, dynamic>{
      'limit': instance.limit,
      'completed': instance.completed,
      'remaining': instance.remaining,
    };

WeeklySummary _$WeeklySummaryFromJson(Map<String, dynamic> json) =>
    WeeklySummary(
      totalRevenue: (json['total_revenue'] as num?)?.toDouble() ?? 0.0,
      ridesCompleted: (json['rides_completed'] as num?)?.toInt() ?? 0,
      avgRating: (json['avg_rating'] as num?)?.toDouble() ?? 0.0,
      distanceCovered: (json['distance_covered'] as num?)?.toDouble() ?? 0.0,
    );

Map<String, dynamic> _$WeeklySummaryToJson(WeeklySummary instance) =>
    <String, dynamic>{
      'total_revenue': instance.totalRevenue,
      'rides_completed': instance.ridesCompleted,
      'avg_rating': instance.avgRating,
      'distance_covered': instance.distanceCovered,
    };
