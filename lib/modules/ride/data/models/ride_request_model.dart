import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Request model for creating a ride
class CreateRideRequest {
  final LocationData pickupLocation;
  final LocationData destination;
  final String vehicleType;
  final String paymentMethod;
  final double fareAmount;

  CreateRideRequest({
    required this.pickupLocation,
    required this.destination,
    required this.vehicleType,
    required this.paymentMethod,
    required this.fareAmount,
  });

  Map<String, dynamic> toJson() {
    return {
      'pickup_location': pickupLocation.toJson(),
      'destination': destination.toJson(),
      'vehicle_type': vehicleType,
      'payment_method': paymentMethod,
      'fare_amount': fareAmount,
    };
  }
}

/// Location data for pickup/destination
class LocationData {
  final double lat;
  final double lng;
  final String address;

  LocationData({required this.lat, required this.lng, required this.address});

  factory LocationData.fromLatLng(LatLng latLng, String address) {
    return LocationData(
      lat: latLng.latitude,
      lng: latLng.longitude,
      address: address,
    );
  }

  Map<String, dynamic> toJson() {
    return {'lat': lat, 'lng': lng, 'address': address};
  }
}

/// Response model for created ride
class CreateRideResponse {
  final String rideId;
  final String status;
  final String message;
  final RideDetails? rideDetails;

  CreateRideResponse({
    required this.rideId,
    required this.status,
    required this.message,
    this.rideDetails,
  });

  factory CreateRideResponse.fromJson(Map<String, dynamic> json) {
    return CreateRideResponse(
      rideId: json['ride_id'] as String? ?? json['id'] as String? ?? '',
      status: json['status'] as String? ?? 'pending',
      message: json['message'] as String? ?? 'Ride created successfully',
      rideDetails:
          json['ride'] != null
              ? RideDetails.fromJson(json['ride'] as Map<String, dynamic>)
              : null,
    );
  }
}

/// Detailed ride information
class RideDetails {
  final String id;
  final String status;
  final LocationData pickupLocation;
  final LocationData destination;
  final String vehicleType;
  final double fareAmount;
  final String? driverId;
  final DriverDetails? driver;
  final VehicleDetails? vehicle;
  final String? otp;
  final DateTime createdAt;

  RideDetails({
    required this.id,
    required this.status,
    required this.pickupLocation,
    required this.destination,
    required this.vehicleType,
    required this.fareAmount,
    this.driverId,
    this.driver,
    this.vehicle,
    this.otp,
    required this.createdAt,
  });

  factory RideDetails.fromJson(Map<String, dynamic> json) {
    return RideDetails(
      id: json['id'] as String? ?? json['ride_id'] as String? ?? '',
      status: json['status'] as String? ?? 'pending',
      pickupLocation: LocationData(
        lat: (json['pickup_location']?['lat'] as num?)?.toDouble() ?? 0.0,
        lng: (json['pickup_location']?['lng'] as num?)?.toDouble() ?? 0.0,
        address: json['pickup_location']?['address'] as String? ?? '',
      ),
      destination: LocationData(
        lat: (json['destination']?['lat'] as num?)?.toDouble() ?? 0.0,
        lng: (json['destination']?['lng'] as num?)?.toDouble() ?? 0.0,
        address: json['destination']?['address'] as String? ?? '',
      ),
      vehicleType: json['vehicle_type'] as String? ?? '',
      fareAmount: (json['fare_amount'] as num?)?.toDouble() ?? 0.0,
      driverId: json['driver_id'] as String?,

      // Handle both nested and flat driver structure
      driver:
          json['driver'] != null
              ? DriverDetails.fromJson(json['driver'])
              : (json['driver_name'] != null
                  ? DriverDetails(
                    name: json['driver_name'],
                    id: json['driver_id'] ?? '',
                    rating: 5.0,
                  )
                  : null),

      vehicle:
          json['vehicle'] != null
              ? VehicleDetails.fromJson(json['vehicle'])
              : null,

      otp: json['otp']?.toString(),

      createdAt:
          json['created_at'] != null
              ? DateTime.parse(json['created_at'] as String)
              : DateTime.now(),
    );
  }
}

class DriverDetails {
  final String id;
  final String name;
  final double rating;
  final String? profileImage;
  final String? phoneNumber;

  DriverDetails({
    required this.id,
    required this.name,
    required this.rating,
    this.profileImage,
    this.phoneNumber,
  });

  factory DriverDetails.fromJson(Map<String, dynamic> json) {
    return DriverDetails(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? 'Driver',
      rating: (json['rating'] as num?)?.toDouble() ?? 5.0,
      profileImage:
          json['profile_image'] as String? ?? json['photo_url'] as String?,
      phoneNumber: json['phone_number'] as String?,
    );
  }
}

class VehicleDetails {
  final String model;
  final String plateNumber;
  final String color;

  VehicleDetails({
    required this.model,
    required this.plateNumber,
    required this.color,
  });

  factory VehicleDetails.fromJson(Map<String, dynamic> json) {
    return VehicleDetails(
      model: json['model'] as String? ?? 'Vehicle',
      plateNumber: json['plate_number'] as String? ?? '',
      color: json['color'] as String? ?? 'Unknown',
    );
  }
}

class DriverStatusResponse {
  final String status;
  final String? eta;
  final double? driverLat;
  final double? driverLng;
  final String? message;

  DriverStatusResponse({
    required this.status,
    this.eta,
    this.driverLat,
    this.driverLng,
    this.message,
  });

  factory DriverStatusResponse.fromJson(Map<String, dynamic> json) {
    return DriverStatusResponse(
      status: json['status'] as String? ?? 'unknown',
      eta: json['eta'] as String? ?? json['duration'] as String?,
      driverLat:
          (json['lat'] as num?)?.toDouble() ??
          (json['driver_lat'] as num?)?.toDouble(),
      driverLng:
          (json['lng'] as num?)?.toDouble() ??
          (json['driver_lng'] as num?)?.toDouble(),
      message: json['message'] as String?,
    );
  }
}

class RideCodeResponse {
  final String code;

  RideCodeResponse({required this.code});

  factory RideCodeResponse.fromJson(Map<String, dynamic> json) {
    return RideCodeResponse(code: json['code']?.toString() ?? '');
  }
}
