class Vehicle {
  final String type;
  final String make;
  final String color;
  final String licensePlate;

  Vehicle({
    required this.type,
    required this.make,
    required this.color,
    required this.licensePlate,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      type: json['type'] as String? ?? '',
      make: json['make'] as String? ?? '',
      color: json['color'] as String? ?? '',
      licensePlate: json['license_plate'] as String? ?? '',
    );
  }
}

/// Available Driver Model
class AvailableDriver {
  final String driverId;
  final String driverName;
  final String? imageUrl;
  final double rating;
  final int ridesCompleted;
  final String estimatedTime;
  final String distance;
  final Vehicle? vehicle;

  AvailableDriver({
    required this.driverId,
    required this.driverName,
    this.imageUrl,
    required this.rating,
    required this.ridesCompleted,
    required this.estimatedTime,
    required this.distance,
    this.vehicle,
  });

  // Convenience getters for vehicle info
  String? get vehicleType => vehicle?.type;
  String? get plateNumber => vehicle?.licensePlate;
  String? get vehicleMake => vehicle?.make;
  String? get vehicleColor => vehicle?.color;

  factory AvailableDriver.fromJson(Map<String, dynamic> json) {
    return AvailableDriver(
      driverId: json['driver_id'] as String? ?? json['id'] as String? ?? '',
      driverName:
          json['name'] as String? ?? json['driver_name'] as String? ?? '',
      imageUrl:
          json['profile_image'] as String? ?? json['image_url'] as String?,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      ridesCompleted:
          json['rides_completed'] as int? ?? json['total_rides'] as int? ?? 0,
      estimatedTime: _formatEtaMinutes(json['eta_minutes']),
      distance: json['distance'] as String? ?? '0.0km',
      vehicle:
          json['vehicle'] != null
              ? Vehicle.fromJson(json['vehicle'] as Map<String, dynamic>)
              : null,
    );
  }

  /// Helper to format eta_minutes into readable string
  static String _formatEtaMinutes(dynamic etaMinutes) {
    if (etaMinutes == null) return '0 mins';

    final minutes = etaMinutes is int ? etaMinutes : 0;
    if (minutes == 0) return 'Nearby';
    if (minutes == 1) return '1 min';
    return '$minutes mins';
  }
}

/// Surge Pricing Model
class SurgePricing {
  final double multiplier;
  final bool applied;
  final String message;

  SurgePricing({
    required this.multiplier,
    required this.applied,
    required this.message,
  });

  factory SurgePricing.fromJson(Map<String, dynamic> json) {
    return SurgePricing(
      multiplier: (json['multiplier'] as num?)?.toDouble() ?? 1.0,
      applied: json['applied'] as bool? ?? false,
      message: json['message'] as String? ?? '',
    );
  }
}

/// Counter Offer Model
class CounterOffer {
  final String offerId;
  final String driverId;
  final String driverName;
  final String? imageUrl;
  final double rating;
  final int ridesCompleted;
  final double proposedFare;
  final String estimatedTime;
  final String? vehicleType;
  final String? plateNumber;

  CounterOffer({
    required this.offerId,
    required this.driverId,
    required this.driverName,
    this.imageUrl,
    required this.rating,
    required this.ridesCompleted,
    required this.proposedFare,
    required this.estimatedTime,
    this.vehicleType,
    this.plateNumber,
  });

  factory CounterOffer.fromJson(Map<String, dynamic> json) {
    return CounterOffer(
      offerId: json['offer_id'] as String? ?? json['id'] as String? ?? '',
      driverId: json['driver_id'] as String? ?? '',
      driverName:
          json['driver_name'] as String? ?? json['name'] as String? ?? '',
      imageUrl:
          json['profile_image'] as String? ?? json['image_url'] as String?,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      ridesCompleted:
          json['rides_completed'] as int? ?? json['total_rides'] as int? ?? 0,
      proposedFare: (json['amount'] as num?)?.toDouble() ?? (json['proposed_fare'] as num?)?.toDouble() ?? 0.0,
      estimatedTime:
          json['estimated_time'] as String? ??
          json['eta'] as String? ??
          '0 mins',
      vehicleType: json['vehicle_type'] as String?,
      plateNumber: json['plate_number'] as String?,
    );
  }
}

/// Response for Available Drivers
class AvailableDriversResponse {
  final List<AvailableDriver> drivers;
  final SurgePricing surgePricing;
  final List<CounterOffer> offers;
  final int count;

  AvailableDriversResponse({
    required this.drivers,
    required this.surgePricing,
    required this.offers,
    required this.count,
  });

  factory AvailableDriversResponse.fromJson(Map<String, dynamic> json) {
    final driversList =
        json['available_drivers'] as List? ??
        json['drivers'] as List? ??
        json['data'] as List? ??
        [];

    // Parse drivers
    final drivers =
        driversList
            .map((d) => AvailableDriver.fromJson(d as Map<String, dynamic>))
            .toList();

    // Parse surge pricing
    final surgePricing =
        json['surge_pricing'] != null
            ? SurgePricing.fromJson(
              json['surge_pricing'] as Map<String, dynamic>,
            )
            : SurgePricing(multiplier: 1.0, applied: false, message: '');

    // Parse offers
    final offersList = json['offers'] as List? ?? [];
    final offers =
        offersList
            .map((o) => CounterOffer.fromJson(o as Map<String, dynamic>))
            .toList();

    return AvailableDriversResponse(
      drivers: drivers,
      surgePricing: surgePricing,
      offers: offers,
      count: json['count'] as int? ?? drivers.length,
    );
  }
}

/// Response for Counter Offers
class CounterOffersResponse {
  final List<CounterOffer> offers;
  final int count;

  CounterOffersResponse({required this.offers, required this.count});

  factory CounterOffersResponse.fromJson(dynamic json) {
    // Handle case where API returns a List directly
    if (json is List) {
      final offersList = json;
      return CounterOffersResponse(
        offers:
            offersList
                .map((o) => CounterOffer.fromJson(o as Map<String, dynamic>))
                .toList(),
        count: offersList.length,
      );
    }

    // Handle case where API returns a Map with 'offers' or 'data' key
    if (json is Map<String, dynamic>) {
      final offersList = json['offers'] as List? ?? json['data'] as List? ?? [];
      return CounterOffersResponse(
        offers:
            offersList
                .map((o) => CounterOffer.fromJson(o as Map<String, dynamic>))
                .toList(),
        count: json['count'] as int? ?? offersList.length,
      );
    }

    // Fallback to empty response
    return CounterOffersResponse(offers: [], count: 0);
  }
}
