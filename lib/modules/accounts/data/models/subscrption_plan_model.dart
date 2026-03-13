class SubscriptionPlanResponse {
  final List<SubscriptionPlan> plans;
  final CurrentSubscription? currentSubscription;

  SubscriptionPlanResponse({required this.plans, this.currentSubscription});

  factory SubscriptionPlanResponse.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlanResponse(
      plans:
          (json['plans'] as List<dynamic>)
              .map(
                (plan) =>
                    SubscriptionPlan.fromJson(plan as Map<String, dynamic>),
              )
              .toList(),
      currentSubscription:
          json['current_subscription'] != null
              ? CurrentSubscription.fromJson(
                json['current_subscription'] as Map<String, dynamic>,
              )
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'plans': plans.map((plan) => plan.toJson()).toList(),
      'current_subscription': currentSubscription?.toJson(),
    };
  }
}

class SubscriptionPlan {
  final String id;
  final String name;
  final String planType;
  final double price;
  final String currency;
  final int durationDays;
  final PlanBenefits benefits;
  final bool isActive;
  final bool isCurrent;
  final bool isRecommended;

  SubscriptionPlan({
    required this.id,
    required this.name,
    required this.planType,
    required this.price,
    required this.currency,
    required this.durationDays,
    required this.benefits,
    required this.isActive,
    required this.isCurrent,
    required this.isRecommended,
  });

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlan(
      id: json['id'] as String,
      name: json['name'] as String,
      planType: json['plan_type'] as String,
      price: (json['price'] as num).toDouble(),
      currency: json['currency'] as String,
      durationDays: json['duration_days'] as int,
      benefits: PlanBenefits.fromJson(json['benefits'] as Map<String, dynamic>),
      isActive: json['is_active'] as bool,
      isCurrent: json['is_current'] as bool,
      isRecommended: json['is_recommended'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'plan_type': planType,
      'price': price,
      'currency': currency,
      'duration_days': durationDays,
      'benefits': benefits.toJson(),
      'is_active': isActive,
      'is_current': isCurrent,
      'is_recommended': isRecommended,
    };
  }

  String get formattedPrice {
    if (price == 0) return 'Free';
    return 'N${price.toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}';
  }

  String get description {
    if (benefits.features.isEmpty) return '';
    return benefits.features.join('\n');
  }
}

class PlanBenefits {
  final List<String> features;
  final double? commissionRate;

  PlanBenefits({required this.features, this.commissionRate});

  factory PlanBenefits.fromJson(Map<String, dynamic> json) {
    return PlanBenefits(
      features:
          (json['features'] as List<dynamic>)
              .map((feature) => feature as String)
              .toList(),
      commissionRate:
          json['commission_rate'] != null
              ? (json['commission_rate'] as num).toDouble()
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'features': features,
      if (commissionRate != null) 'commission_rate': commissionRate,
    };
  }
}

class CurrentSubscription {
  final String id;
  final String planId;
  final String planName;
  final DateTime startDate;
  final DateTime endDate;
  final String status;

  CurrentSubscription({
    required this.id,
    required this.planId,
    required this.planName,
    required this.startDate,
    required this.endDate,
    required this.status,
  });

  factory CurrentSubscription.fromJson(Map<String, dynamic> json) {
    return CurrentSubscription(
      id: json['id'] as String,
      planId: json['plan_id'] as String,
      planName: json['plan_name'] as String,
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
      status: json['status'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'plan_id': planId,
      'plan_name': planName,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'status': status,
    };
  }
}
