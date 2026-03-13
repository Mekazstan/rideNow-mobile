class DriverEarningsResponse {
  final bool success;
  final DriverEarningsData data;

  DriverEarningsResponse({required this.success, required this.data});

  factory DriverEarningsResponse.fromJson(Map<String, dynamic> json) {
    return DriverEarningsResponse(
      success: json['success'] as bool? ?? false,
      data: DriverEarningsData.fromJson(json['data'] as Map<String, dynamic>),
    );
  }
}

class DriverEarningsData {
  final double totalEarnings;
  final double todayEarnings;
  final double weeklyEarnings;
  final double monthlyEarnings;
  final String currency;
  final List<EarningsHistory> earningsHistory;
  final double pendingPayout;

  DriverEarningsData({
    required this.totalEarnings,
    required this.todayEarnings,
    required this.weeklyEarnings,
    required this.monthlyEarnings,
    required this.currency,
    required this.earningsHistory,
    required this.pendingPayout,
  });

  factory DriverEarningsData.fromJson(Map<String, dynamic> json) {
    return DriverEarningsData(
      totalEarnings: (json['total_earnings'] as num?)?.toDouble() ?? 0.0,
      todayEarnings: (json['today_earnings'] as num?)?.toDouble() ?? 0.0,
      weeklyEarnings: (json['weekly_earnings'] as num?)?.toDouble() ?? 0.0,
      monthlyEarnings: (json['monthly_earnings'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] as String? ?? 'USD',
      earningsHistory:
          (json['earnings_history'] as List<dynamic>?)
              ?.map((e) => EarningsHistory.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      pendingPayout: (json['pending_payout'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class EarningsHistory {
  final String date;
  final double amount;
  final int tripsCompleted;

  EarningsHistory({
    required this.date,
    required this.amount,
    required this.tripsCompleted,
  });

  factory EarningsHistory.fromJson(Map<String, dynamic> json) {
    return EarningsHistory(
      date: json['date'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      tripsCompleted: json['trips_completed'] as int? ?? 0,
    );
  }
}

class DriverPerformanceResponse {
  final bool success;
  final DriverPerformanceData data;

  DriverPerformanceResponse({required this.success, required this.data});

  factory DriverPerformanceResponse.fromJson(Map<String, dynamic> json) {
    return DriverPerformanceResponse(
      success: json['success'] as bool? ?? false,
      data: DriverPerformanceData.fromJson(
        json['data'] as Map<String, dynamic>,
      ),
    );
  }
}

class DriverPerformanceData {
  final double acceptanceRate;
  final double completionRate;
  final double cancellationRate;
  final double averageRating;
  final int totalOnlineMinutes;
  final int totalTrips;

  DriverPerformanceData({
    required this.acceptanceRate,
    required this.completionRate,
    required this.cancellationRate,
    required this.averageRating,
    required this.totalOnlineMinutes,
    required this.totalTrips,
  });

  factory DriverPerformanceData.fromJson(Map<String, dynamic> json) {
    return DriverPerformanceData(
      acceptanceRate: (json['acceptance_rate'] as num?)?.toDouble() ?? 0.0,
      completionRate: (json['completion_rate'] as num?)?.toDouble() ?? 0.0,
      cancellationRate: (json['cancellation_rate'] as num?)?.toDouble() ?? 0.0,
      averageRating: (json['average_rating'] as num?)?.toDouble() ?? 0.0,
      totalOnlineMinutes: json['total_online_minutes'] as int? ?? 0,
      totalTrips: json['total_trips'] as int? ?? 0,
    );
  }
}

class DriverRatingsResponse {
  final bool success;
  final DriverRatingsData data;

  DriverRatingsResponse({required this.success, required this.data});

  factory DriverRatingsResponse.fromJson(Map<String, dynamic> json) {
    return DriverRatingsResponse(
      success: json['success'] as bool? ?? false,
      data: DriverRatingsData.fromJson(json['data'] as Map<String, dynamic>),
    );
  }
}

class DriverRatingsData {
  final double averageRating;
  final int totalRatings;
  final Map<String, int> ratingBreakdown;
  final List<DriverReview> recentReviews;

  DriverRatingsData({
    required this.averageRating,
    required this.totalRatings,
    required this.ratingBreakdown,
    required this.recentReviews,
  });

  factory DriverRatingsData.fromJson(Map<String, dynamic> json) {
    final breakdownRaw =
        json['rating_breakdown'] as Map<String, dynamic>? ?? {};
    final breakdown = breakdownRaw.map((k, v) => MapEntry(k, v as int));

    return DriverRatingsData(
      averageRating: (json['average_rating'] as num?)?.toDouble() ?? 0.0,
      totalRatings: json['total_ratings'] as int? ?? 0,
      ratingBreakdown: breakdown,
      recentReviews:
          (json['recent_reviews'] as List<dynamic>?)
              ?.map((e) => DriverReview.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class DriverReview {
  final String riderName;
  final double rating;
  final String comment;
  final String date;

  DriverReview({
    required this.riderName,
    required this.rating,
    required this.comment,
    required this.date,
  });

  factory DriverReview.fromJson(Map<String, dynamic> json) {
    return DriverReview(
      riderName: json['rider_name'] as String? ?? 'Rider',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      comment: json['comment'] as String? ?? '',
      date: json['date'] as String? ?? '',
    );
  }
}

class DriverTripsResponse {
  final bool success;
  final DriverTripsData data;

  DriverTripsResponse({required this.success, required this.data});

  factory DriverTripsResponse.fromJson(Map<String, dynamic> json) {
    return DriverTripsResponse(
      success: json['success'] as bool? ?? false,
      data: DriverTripsData.fromJson(json['data'] as Map<String, dynamic>),
    );
  }
}

class DriverTripsData {
  final int totalTrips;
  final int completedTrips;
  final int cancelledTrips;
  final double totalDistance;
  final List<TripSummary> recentTrips;

  DriverTripsData({
    required this.totalTrips,
    required this.completedTrips,
    required this.cancelledTrips,
    required this.totalDistance,
    required this.recentTrips,
  });

  factory DriverTripsData.fromJson(Map<String, dynamic> json) {
    return DriverTripsData(
      totalTrips: json['total_trips'] as int? ?? 0,
      completedTrips: json['completed_trips'] as int? ?? 0,
      cancelledTrips: json['cancelled_trips'] as int? ?? 0,
      totalDistance: (json['total_distance_km'] as num?)?.toDouble() ?? 0.0,
      recentTrips:
          (json['recent_trips'] as List<dynamic>?)
              ?.map((e) => TripSummary.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class TripSummary {
  final String rideId;
  final String date;
  final double amount;
  final String pickup;
  final String destination;
  final String status;

  TripSummary({
    required this.rideId,
    required this.date,
    required this.amount,
    required this.pickup,
    required this.destination,
    required this.status,
  });

  factory TripSummary.fromJson(Map<String, dynamic> json) {
    return TripSummary(
      rideId: json['ride_id'] as String? ?? '',
      date: json['date'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      pickup: json['pickup'] as String? ?? '',
      destination: json['destination'] as String? ?? '',
      status: json['status'] as String? ?? '',
    );
  }
}

class DriverWeeklyAnalyticsResponse {
  final bool success;
  final DriverWeeklyAnalyticsData data;

  DriverWeeklyAnalyticsResponse({required this.success, required this.data});

  factory DriverWeeklyAnalyticsResponse.fromJson(Map<String, dynamic> json) {
    return DriverWeeklyAnalyticsResponse(
      success: json['success'] as bool? ?? false,
      data: DriverWeeklyAnalyticsData.fromJson(
        json['data'] as Map<String, dynamic>,
      ),
    );
  }
}

class DriverWeeklyAnalyticsData {
  final String weekPeriod;
  final double totalEarnings;
  final int totalTrips;
  final int totalOnlineHours;
  final List<DailyEarningSummary> dailyBreakdown;

  DriverWeeklyAnalyticsData({
    required this.weekPeriod,
    required this.totalEarnings,
    required this.totalTrips,
    required this.totalOnlineHours,
    required this.dailyBreakdown,
  });

  factory DriverWeeklyAnalyticsData.fromJson(Map<String, dynamic> json) {
    return DriverWeeklyAnalyticsData(
      weekPeriod: json['week_period'] as String? ?? '',
      totalEarnings: (json['total_earnings'] as num?)?.toDouble() ?? 0.0,
      totalTrips: json['total_trips'] as int? ?? 0,
      totalOnlineHours: json['total_online_hours'] as int? ?? 0,
      dailyBreakdown:
          (json['daily_breakdown'] as List<dynamic>?)
              ?.map(
                (e) => DailyEarningSummary.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
    );
  }
}

class DailyEarningSummary {
  final String day;
  final double earnings;
  final int trips;

  DailyEarningSummary({
    required this.day,
    required this.earnings,
    required this.trips,
  });

  factory DailyEarningSummary.fromJson(Map<String, dynamic> json) {
    return DailyEarningSummary(
      day: json['day'] as String? ?? '',
      earnings: (json['earnings'] as num?)?.toDouble() ?? 0.0,
      trips: json['trips'] as int? ?? 0,
    );
  }
}

class DriverDailyLimitResponse {
  final bool success;
  final DriverDailyLimitData data;

  DriverDailyLimitResponse({required this.success, required this.data});

  factory DriverDailyLimitResponse.fromJson(Map<String, dynamic> json) {
    return DriverDailyLimitResponse(
      success: json['success'] as bool? ?? false,
      data: DriverDailyLimitData.fromJson(json['data'] as Map<String, dynamic>),
    );
  }
}

class DriverDailyLimitData {
  final int onlineMinutesToday;
  final int maxOnlineMinutes;
  final int remainingMinutes;
  final bool isLimitReached;
  final String? resetTime;

  DriverDailyLimitData({
    required this.onlineMinutesToday,
    required this.maxOnlineMinutes,
    required this.remainingMinutes,
    required this.isLimitReached,
    this.resetTime,
  });

  factory DriverDailyLimitData.fromJson(Map<String, dynamic> json) {
    return DriverDailyLimitData(
      onlineMinutesToday: json['online_minutes_today'] as int? ?? 0,
      maxOnlineMinutes: json['max_online_minutes'] as int? ?? 0,
      remainingMinutes: json['remaining_minutes'] as int? ?? 0,
      isLimitReached: json['limit_reached'] as bool? ?? false,
      resetTime: json['reset_time'] as String?,
    );
  }
}
