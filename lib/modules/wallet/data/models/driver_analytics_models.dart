import 'package:json_annotation/json_annotation.dart';

part 'driver_analytics_models.g.dart';

@JsonSerializable()
class EarningsAnalytics {
  @JsonKey(name: 'total_revenue', defaultValue: 0.0)
  final double totalRevenue;
  @JsonKey(defaultValue: 'USD')
  final String currency;
  final List<PeakLocation>? peakLocations;

  EarningsAnalytics({
    required this.totalRevenue,
    required this.currency,
    this.peakLocations,
  });

  factory EarningsAnalytics.fromJson(Map<String, dynamic> json) =>
      _$EarningsAnalyticsFromJson(json);

  Map<String, dynamic> toJson() => _$EarningsAnalyticsToJson(this);
}

@JsonSerializable()
class PeakLocation {
  final String name;
  @JsonKey(defaultValue: 0.0)
  final double amount;
  @JsonKey(defaultValue: 0.0)
  final double percentage;

  PeakLocation({
    required this.name,
    required this.amount,
    required this.percentage,
  });

  factory PeakLocation.fromJson(Map<String, dynamic> json) =>
      _$PeakLocationFromJson(json);

  Map<String, dynamic> toJson() => _$PeakLocationToJson(this);
}

@JsonSerializable()
class PerformanceAnalytics {
  @JsonKey(name: 'rides_completed', defaultValue: 0)
  final int ridesCompleted;
  @JsonKey(name: 'distance_covered', defaultValue: 0.0)
  final double distanceCovered;
  @JsonKey(name: 'distance_unit', defaultValue: 'km')
  final String distanceUnit;

  PerformanceAnalytics({
    required this.ridesCompleted,
    required this.distanceCovered,
    this.distanceUnit = 'km',
  });

  factory PerformanceAnalytics.fromJson(Map<String, dynamic> json) =>
      _$PerformanceAnalyticsFromJson(json);

  Map<String, dynamic> toJson() => _$PerformanceAnalyticsToJson(this);
}

@JsonSerializable()
class RatingsAnalytics {
  @JsonKey(name: 'average_rating', defaultValue: 0.0)
  final double averageRating;
  @JsonKey(name: 'total_ratings', defaultValue: 0)
  final int totalRatings;

  RatingsAnalytics({required this.averageRating, required this.totalRatings});

  factory RatingsAnalytics.fromJson(Map<String, dynamic> json) =>
      _$RatingsAnalyticsFromJson(json);

  Map<String, dynamic> toJson() => _$RatingsAnalyticsToJson(this);
}

@JsonSerializable()
class DailyLimitStatus {
  @JsonKey(defaultValue: 0)
  final int limit;
  @JsonKey(defaultValue: 0)
  final int completed;
  @JsonKey(defaultValue: 0)
  final int remaining;

  DailyLimitStatus({
    required this.limit,
    required this.completed,
    required this.remaining,
  });

  factory DailyLimitStatus.fromJson(Map<String, dynamic> json) =>
      _$DailyLimitStatusFromJson(json);

  Map<String, dynamic> toJson() => _$DailyLimitStatusToJson(this);
}

@JsonSerializable()
class WeeklySummary {
  @JsonKey(name: 'total_revenue', defaultValue: 0.0)
  final double totalRevenue;
  @JsonKey(name: 'rides_completed', defaultValue: 0)
  final int ridesCompleted;
  @JsonKey(name: 'avg_rating', defaultValue: 0.0)
  final double avgRating;
  @JsonKey(name: 'distance_covered', defaultValue: 0.0)
  final double distanceCovered;

  WeeklySummary({
    required this.totalRevenue,
    required this.ridesCompleted,
    required this.avgRating,
    required this.distanceCovered,
  });

  factory WeeklySummary.fromJson(Map<String, dynamic> json) =>
      _$WeeklySummaryFromJson(json);

  Map<String, dynamic> toJson() => _$WeeklySummaryToJson(this);
}
