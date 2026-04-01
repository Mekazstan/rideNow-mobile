import 'package:intl/intl.dart';
import 'package:ridenowappsss/core/utils/extensions/amount_extension_validations_utils.dart';

class RideRequestsQuery {
  final String location;
  final double lat;
  final double lon;
  final double radiusKm;

  RideRequestsQuery({
    required this.location,
    required this.lat,
    required this.lon,
    this.radiusKm = 10.0,
  });

  Map<String, String> toQueryParameters() {
    return {
      'location': location.trim(),
      'lat': lat.toStringAsFixed(6),
      'lon': lon.toStringAsFixed(6),
      'radius_km': radiusKm.toStringAsFixed(1),
    };
  }

  // For debugging
  @override
  String toString() {
    return 'RideRequestsQuery(location: $location, lat: $lat, lon: $lon, radiusKm: $radiusKm)';
  }
}

// Pagination model
class Pagination {
  final int page;
  final int limit;
  final int totalPages;

  Pagination({
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      page: json['page'] as int? ?? 1,
      limit: json['limit'] as int? ?? 20,
      totalPages: json['total_pages'] as int? ?? 1,
    );
  }
}

// Location filter model
class LocationFilter {
  final double lat;
  final double lon;
  final double radiusKm;

  LocationFilter({
    required this.lat,
    required this.lon,
    required this.radiusKm,
  });

  factory LocationFilter.fromJson(Map<String, dynamic> json) {
    return LocationFilter(
      lat: (json['lat'] as num? ?? 0).toDouble(),
      lon: (json['lon'] as num? ?? 0).toDouble(),
      radiusKm: (json['radius_km'] as num? ?? 0).toDouble(),
    );
  }
}

// Response from fetching ride requests - MATCHES BACKEND STRUCTURE
class RideRequestsResponse {
  final List<RideRequest> rideRequests;
  final int totalRequests;
  final Pagination? pagination;
  final LocationFilter? locationFilter;

  RideRequestsResponse({
    required this.rideRequests,
    required this.totalRequests,
    this.pagination,
    this.locationFilter,
  });

  int get total => totalRequests;

  factory RideRequestsResponse.fromJson(Map<String, dynamic> json) {
    return RideRequestsResponse(
      rideRequests:
          (json['ride_requests'] as List<dynamic>?)
              ?.map(
                (item) => RideRequest.fromJson(item as Map<String, dynamic>),
              )
              .toList() ??
          [],
      totalRequests: json['total_requests'] as int? ?? 0,
      pagination:
          json['pagination'] != null
              ? Pagination.fromJson(json['pagination'] as Map<String, dynamic>)
              : null,
      locationFilter:
          json['location_filter'] != null
              ? LocationFilter.fromJson(
                json['location_filter'] as Map<String, dynamic>,
              )
              : null,
    );
  }
}

// Individual ride request - FIXED VERSION
class RideRequest {
  final String rideId;
  final String riderName;
  final String? riderPhoto;
  final LocationModelDriver _pickupLocation;
  final LocationModelDriver _destination;
  final double fare;
  final String distance;
  final double? riderRating;
  final DateTime requestedAt;
  final String vehicleType;
  final int etaMinutes;
  final String? riderPhoneNumber;
  final String? _additionalNotes;

  RideRequest({
    required this.rideId,
    required this.riderName,
    this.riderPhoto,
    this.riderPhoneNumber,
    required LocationModelDriver pickupLocation,
    required LocationModelDriver destination,
    required this.fare,
    required this.distance,
    this.riderRating,
    required this.requestedAt,
    required this.vehicleType,
    required this.etaMinutes,
    String? additionalNotes,
  }) : _pickupLocation = pickupLocation,
       _destination = destination,
       _additionalNotes = additionalNotes;

  // Getters for backward compatibility with old code - ALL RETURN STRINGS OR PRIMITIVES
  String get id => rideId;
  String get riderId => rideId;
  String get riderImage => riderPhoto ?? '';
  bool get isVerified => (riderRating ?? 0) >= 4.5;
  int? get badgeLevel =>
      riderRating != null ? (riderRating! * 2).toInt() : null;

  // Pickup location getters - ALL RETURN STRINGS OR DOUBLES
  String get pickupLocation => _pickupLocation.address;
  String get pickupLocationName => _pickupLocation.address;
  String get pickupAddress => _pickupLocation.address;
  double get pickupLat => _pickupLocation.coordinates.lat;
  double get pickupLon => _pickupLocation.coordinates.lng;

  // Destination location getters - ALL RETURN STRINGS OR DOUBLES
  String get destinationLocation => _destination.address;
  String get destinationAddress => _destination.address;
  double get destinationLat => _destination.coordinates.lat;
  double get destinationLon => _destination.coordinates.lng;

  // Other getters
  double get estimatedFare => fare;
  double get distanceKm => _parseDistance(distance);
  String get status => 'pending';
  DateTime get createdAt => requestedAt;
  String? get additionalNotes => _additionalNotes;

  factory RideRequest.fromJson(Map<String, dynamic> json) {
    return RideRequest(
      rideId: json['ride_id'] as String? ?? '',
      riderName: json['rider_name'] as String? ?? 'Unknown',
      riderPhoto: json['rider_photo'] as String?,
      pickupLocation: LocationModelDriver.fromJson(
        json['pickup_location'] as Map<String, dynamic>? ?? {},
      ),
      destination: LocationModelDriver.fromJson(
        json['destination'] as Map<String, dynamic>? ?? {},
      ),
      fare: (json['fare'] as num? ?? 0).toDouble(),
      distance: json['distance'] as String? ?? '0km',
      riderRating: (json['rider_rating'] as num?)?.toDouble(),
      requestedAt:
          json['requested_at'] != null
              ? DateTime.parse(json['requested_at'] as String)
              : DateTime.now(),
      vehicleType: json['vehicle_type'] as String? ?? 'standard',
      etaMinutes: json['eta_minutes'] as int? ?? 0,
      additionalNotes: json['additional_notes'] as String?,
      riderPhoneNumber: json['rider_phone'] as String? ?? json['rider_phone_number'] as String?,
    );
  }

  // Helper method to parse distance string to double
  static double _parseDistance(String distance) {
    try {
      final numStr = distance.replaceAll(RegExp(r'[^0-9.]'), '');
      return double.parse(numStr);
    } catch (e) {
      return 0.0;
    }
  }

  String getFormattedFare() {
    return fare.formatAmountWithCurrency();
  }

  String getTimeSinceCreated() {
    final now = DateTime.now();
    final difference = now.difference(requestedAt);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  String getFormattedDistance() {
    return distance;
  }

  String getFormattedETA() {
    if (etaMinutes < 60) {
      return '$etaMinutes min';
    }
    final hours = etaMinutes ~/ 60;
    final mins = etaMinutes % 60;
    return mins > 0 ? '${hours}h ${mins}m' : '${hours}h';
  }

  String getVehicleTypeDisplay() {
    return vehicleType[0].toUpperCase() + vehicleType.substring(1);
  }

  String getRiderRatingDisplay() {
    if (riderRating == null) return 'N/A';
    return riderRating!.toStringAsFixed(1);
  }
}

// Location model for pickup and destination
class LocationModelDriver {
  final String address;
  final Coordinates coordinates;

  LocationModelDriver({required this.address, required this.coordinates});

  factory LocationModelDriver.fromJson(Map<String, dynamic> json) {
    return LocationModelDriver(
      address: json['address'] as String? ?? '',
      coordinates: Coordinates.fromJson(
        json['coordinates'] as Map<String, dynamic>? ?? {},
      ),
    );
  }
}

// Coordinates model
class Coordinates {
  final double lat;
  final double lng;

  Coordinates({required this.lat, required this.lng});

  factory Coordinates.fromJson(Map<String, dynamic> json) {
    return Coordinates(
      lat: (json['lat'] as num? ?? 0).toDouble(),
      lng: (json['lng'] as num? ?? 0).toDouble(),
    );
  }
}

// Request to accept a ride
class AcceptRideRequest {
  final String rideId;
  final double? proposedFare;
  final double? driverLat;
  final double? driverLng;
  final int? estimatedArrivalMinutes;

  AcceptRideRequest({
    required this.rideId,
    this.proposedFare,
    this.driverLat,
    this.driverLng,
    this.estimatedArrivalMinutes,
  });

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{'ride_id': rideId};
    if (proposedFare != null) {
      json['proposed_fare'] = proposedFare;
    }
    return json;
  }
}

// Response from accepting a ride
class AcceptRideResponse {
  final String message;
  final String rideId;
  final String? status;
  final RideRequest? rideDetails;
  final bool success;

  AcceptRideResponse({
    required this.message,
    required this.rideId,
    this.status,
    this.rideDetails,
    this.success = true,
  });

  factory AcceptRideResponse.fromJson(Map<String, dynamic> json) {
    // NestJS can return message as either a String or a List<String>
    final rawMessage = json['message'];
    final message = rawMessage is List
        ? (rawMessage as List<dynamic>).join(', ')
        : rawMessage as String? ?? 'Ride accepted';

    return AcceptRideResponse(
      message: message,
      rideId: json['ride_id'] as String? ?? json['rideId'] as String? ?? '',
      status: json['status'] as String?,
      success: json['success'] as bool? ?? true,
      rideDetails: json['ride'] != null ? RideRequest.fromJson(json['ride']) : null,
    );
  }
}
