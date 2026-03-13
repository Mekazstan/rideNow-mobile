class CancelSubscriptionRequest {
  final String reason;
  final String feedback;
  final bool cancelImmediately;

  CancelSubscriptionRequest({
    required this.reason,
    required this.feedback,
    required this.cancelImmediately,
  });

  Map<String, dynamic> toJson() {
    return {
      'reason': reason,
      'feedback': feedback,
      'cancel_immediately': cancelImmediately,
    };
  }
}

class CancelSubscriptionResponse {
  final bool success;
  final String cancelledPlan;
  final String activeUntil;
  final String message;

  CancelSubscriptionResponse({
    required this.success,
    required this.cancelledPlan,
    required this.activeUntil,
    required this.message,
  });

  factory CancelSubscriptionResponse.fromJson(Map<String, dynamic> json) {
    return CancelSubscriptionResponse(
      success: json['success'] as bool? ?? false,
      cancelledPlan: json['cancelledPlan'] as String? ?? '',
      activeUntil: json['activeUntil'] as String? ?? '',
      message: json['message'] as String? ?? '',
    );
  }
}

class ChangePlanRequest {
  final String newPlanId;
  final String paymentMethod;
  final String effectiveDate;

  ChangePlanRequest({
    required this.newPlanId,
    required this.paymentMethod,
    required this.effectiveDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'new_plan_id': newPlanId,
      'payment_method': paymentMethod,
      'effective_date': effectiveDate,
    };
  }
}

class ChangePlanResponse {
  final bool success;
  final String newPlan;
  final int dailyRideLimit;
  final int commission;
  final double amountCharged;
  final String effectiveDate;
  final String message;

  ChangePlanResponse({
    required this.success,
    required this.newPlan,
    required this.dailyRideLimit,
    required this.commission,
    required this.amountCharged,
    required this.effectiveDate,
    required this.message,
  });

  factory ChangePlanResponse.fromJson(Map<String, dynamic> json) {
    return ChangePlanResponse(
      success: json['success'] as bool? ?? false,
      newPlan: json['newPlan'] as String? ?? '',
      dailyRideLimit: json['dailyRideLimit'] as int? ?? 0,
      commission: json['commission'] as int? ?? 0,
      amountCharged: (json['amountCharged'] as num? ?? 0).toDouble(),
      effectiveDate: json['effectiveDate'] as String? ?? '',
      message: json['message'] as String? ?? '',
    );
  }
}
