import 'package:ridenowappsss/modules/ride/data/models/driver_ride_request.dart';

class DriverStatusResponse {
  final String status;
  final bool isOnRide;
  final String? activeRideId;
  final Coordinates? currentLocation;
  final String? onlineSince;
  final int? onlineDuration;

  DriverStatusResponse({
    required this.status,
    required this.isOnRide,
    this.activeRideId,
    this.currentLocation,
    this.onlineSince,
    this.onlineDuration,
  });

  factory DriverStatusResponse.fromJson(Map<String, dynamic> json) {
    return DriverStatusResponse(
      status: json['status'] as String? ?? 'offline',
      isOnRide: json['isOnRide'] as bool? ?? false,
      activeRideId: json['activeRideId'] as String?,
      currentLocation:
          json['currentLocation'] != null
              ? Coordinates.fromJson(
                json['currentLocation'] as Map<String, dynamic>,
              )
              : null,
      onlineSince: json['onlineSince'] as String?,
      onlineDuration: json['onlineDuration'] as int?,
    );
  }
}

class DriverVehiclesResponse {
  final List<VehicleModel> vehicles;
  final String? activeVehicleId;

  DriverVehiclesResponse({required this.vehicles, this.activeVehicleId});

  factory DriverVehiclesResponse.fromJson(Map<String, dynamic> json) {
    return DriverVehiclesResponse(
      vehicles:
          (json['vehicles'] as List? ?? [])
              .map((e) => VehicleModel.fromJson(e as Map<String, dynamic>))
              .toList(),
      activeVehicleId: json['activeVehicleId'] as String?,
    );
  }
}

class VehicleModel {
  final String id;
  final String make;
  final String model;
  final int year;
  final String color;
  final String licensePlate;
  final String vehicleType;
  final bool isActive;
  final bool isVerified;
  final InsuranceModel? insurance;

  VehicleModel({
    required this.id,
    required this.make,
    required this.model,
    required this.year,
    required this.color,
    required this.licensePlate,
    required this.vehicleType,
    required this.isActive,
    required this.isVerified,
    this.insurance,
  });

  factory VehicleModel.fromJson(Map<String, dynamic> json) {
    return VehicleModel(
      id: json['id'] as String? ?? '',
      make: json['make'] as String? ?? '',
      model: json['model'] as String? ?? '',
      year: json['year'] as int? ?? 0,
      color: json['color'] as String? ?? '',
      licensePlate: json['licensePlate'] as String? ?? '',
      vehicleType: json['vehicleType'] as String? ?? '',
      isActive: json['isActive'] as bool? ?? false,
      isVerified: json['isVerified'] as bool? ?? false,
      insurance:
          json['insurance'] != null
              ? InsuranceModel.fromJson(
                json['insurance'] as Map<String, dynamic>,
              )
              : null,
    );
  }
}

class InsuranceModel {
  final String provider;
  final String policyNumber;
  final String expiryDate;

  InsuranceModel({
    required this.provider,
    required this.policyNumber,
    required this.expiryDate,
  });

  factory InsuranceModel.fromJson(Map<String, dynamic> json) {
    return InsuranceModel(
      provider: json['provider'] as String? ?? '',
      policyNumber: json['policyNumber'] as String? ?? '',
      expiryDate: json['expiryDate'] as String? ?? '',
    );
  }
}

class OptimalRouteResponse {
  final RouteData route;
  final DestinationData destination;
  final String estimatedArrival;

  OptimalRouteResponse({
    required this.route,
    required this.destination,
    required this.estimatedArrival,
  });

  factory OptimalRouteResponse.fromJson(Map<String, dynamic> json) {
    return OptimalRouteResponse(
      route: RouteData.fromJson(json['route'] as Map<String, dynamic>),
      destination: DestinationData.fromJson(
        json['destination'] as Map<String, dynamic>,
      ),
      estimatedArrival: json['estimatedArrival'] as String? ?? '',
    );
  }
}

class RouteData {
  final double distance;
  final int duration;
  final String polyline;
  final List<RouteStep> steps;

  RouteData({
    required this.distance,
    required this.duration,
    required this.polyline,
    required this.steps,
  });

  factory RouteData.fromJson(Map<String, dynamic> json) {
    return RouteData(
      distance: (json['distance'] as num? ?? 0).toDouble(),
      duration: json['duration'] as int? ?? 0,
      polyline: json['polyline'] as String? ?? '',
      steps:
          (json['steps'] as List? ?? [])
              .map((e) => RouteStep.fromJson(e as Map<String, dynamic>))
              .toList(),
    );
  }
}

class RouteStep {
  final String instruction;
  final double distance;
  final int duration;

  RouteStep({
    required this.instruction,
    required this.distance,
    required this.duration,
  });

  factory RouteStep.fromJson(Map<String, dynamic> json) {
    return RouteStep(
      instruction: json['instruction'] as String? ?? '',
      distance: (json['distance'] as num? ?? 0).toDouble(),
      duration: json['duration'] as int? ?? 0,
    );
  }
}

class DestinationData {
  final String address;
  final Coordinates coordinates;

  DestinationData({required this.address, required this.coordinates});

  factory DestinationData.fromJson(Map<String, dynamic> json) {
    return DestinationData(
      address: json['address'] as String? ?? '',
      coordinates: Coordinates.fromJson(
        json['coordinates'] as Map<String, dynamic>,
      ),
    );
  }
}
class DriverDocumentDetail {
  final String id;
  final String documentType;
  final String? documentName;
  final String status;
  final String? rejectionReason;
  final String? adminComment;
  final String createdAt;
  final String? verifiedAt;

  DriverDocumentDetail({
    required this.id,
    required this.documentType,
    this.documentName,
    required this.status,
    this.rejectionReason,
    this.adminComment,
    required this.createdAt,
    this.verifiedAt,
  });

  factory DriverDocumentDetail.fromJson(Map<String, dynamic> json) {
    return DriverDocumentDetail(
      id: json['id'] as String? ?? '',
      documentType: json['documentType'] as String? ?? '',
      documentName: json['documentName'] as String?,
      status: json['status'] as String? ?? 'pending',
      rejectionReason: json['rejectionReason'] as String?,
      adminComment: json['adminComment'] as String?,
      createdAt: json['createdAt'] as String? ?? '',
      verifiedAt: json['verifiedAt'] as String?,
    );
  }
}

class VerificationStatusResponse {
  final String approvalStatus;
  final String backgroundCheckStatus;
  final List<DriverDocumentDetail> documents;
  final bool isFullyVerified;
  final String? message;

  VerificationStatusResponse({
    required this.approvalStatus,
    required this.backgroundCheckStatus,
    required this.documents,
    required this.isFullyVerified,
    this.message,
  });

  factory VerificationStatusResponse.fromJson(Map<String, dynamic> json) {
    return VerificationStatusResponse(
      approvalStatus: json['approvalStatus'] as String? ?? 'pending',
      backgroundCheckStatus: json['backgroundCheckStatus'] as String? ?? 'pending',
      documents:
          (json['documents'] as List? ?? [])
              .map((e) => DriverDocumentDetail.fromJson(e as Map<String, dynamic>))
              .toList(),
      isFullyVerified: json['isFullyVerified'] as bool? ?? false,
      message: json['message'] as String?,
    );
  }
}
