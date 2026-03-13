import 'package:json_annotation/json_annotation.dart';

part 'community_models.g.dart';

@JsonSerializable()
class LocationCoordinates {
  final double lat;
  final double lng;

  LocationCoordinates({required this.lat, required this.lng});

  factory LocationCoordinates.fromJson(Map<String, dynamic> json) =>
      _$LocationCoordinatesFromJson(json);
  Map<String, dynamic> toJson() => _$LocationCoordinatesToJson(this);
}

@JsonSerializable()
class RideLocation {
  final String address;
  final LocationCoordinates coordinates;

  RideLocation({required this.address, required this.coordinates});

  factory RideLocation.fromJson(Map<String, dynamic> json) =>
      _$RideLocationFromJson(json);
  Map<String, dynamic> toJson() => _$RideLocationToJson(this);
}

@JsonSerializable()
class RideDriver {
  final String name;
  final String photo;
  final double rating;
  @JsonKey(name: 'vehicleType')
  final String? vehicleType;
  final String? vehicle;

  RideDriver({
    required this.name,
    required this.photo,
    required this.rating,
    this.vehicleType,
    this.vehicle,
  });

  factory RideDriver.fromJson(Map<String, dynamic> json) =>
      _$RideDriverFromJson(json);
  Map<String, dynamic> toJson() => _$RideDriverToJson(this);
}

@JsonSerializable()
class LiveRideDetails {
  final String id;
  final String riderName;
  final String status;
  final RideLocation pickupLocation;
  final RideLocation destination;
  final RideDriver driver;
  final LocationCoordinates currentLocation;
  final String estimatedArrival;
  final String startedAt;

  LiveRideDetails({
    required this.id,
    required this.riderName,
    required this.status,
    required this.pickupLocation,
    required this.destination,
    required this.driver,
    required this.currentLocation,
    required this.estimatedArrival,
    required this.startedAt,
  });

  factory LiveRideDetails.fromJson(Map<String, dynamic> json) =>
      _$LiveRideDetailsFromJson(json);
  Map<String, dynamic> toJson() => _$LiveRideDetailsToJson(this);
}

@JsonSerializable()
class LiveRideResponse {
  final LiveRideDetails ride;

  LiveRideResponse({required this.ride});

  factory LiveRideResponse.fromJson(Map<String, dynamic> json) =>
      _$LiveRideResponseFromJson(json);
  Map<String, dynamic> toJson() => _$LiveRideResponseToJson(this);
}

@JsonSerializable()
class SharedRide {
  final String rideId;
  final String riderName;
  final String status;
  final String pickupLocation;
  final String destination;
  final RideDriver driver;
  final String sharedAt;
  final LocationCoordinates liveLocation;

  SharedRide({
    required this.rideId,
    required this.riderName,
    required this.status,
    required this.pickupLocation,
    required this.destination,
    required this.driver,
    required this.sharedAt,
    required this.liveLocation,
  });

  factory SharedRide.fromJson(Map<String, dynamic> json) =>
      _$SharedRideFromJson(json);
  Map<String, dynamic> toJson() => _$SharedRideToJson(this);
}

@JsonSerializable()
class SharedRidesResponse {
  final List<SharedRide> sharedRides;

  SharedRidesResponse({required this.sharedRides});

  factory SharedRidesResponse.fromJson(Map<String, dynamic> json) =>
      _$SharedRidesResponseFromJson(json);
  Map<String, dynamic> toJson() => _$SharedRidesResponseToJson(this);
}

@JsonSerializable()
class ShareLocationRequest {
  @JsonKey(name: 'contact_ids')
  final List<String> contactIds;
  @JsonKey(name: 'duration_minutes')
  final int durationMinutes;
  @JsonKey(name: 'ride_id')
  final String rideId;

  ShareLocationRequest({
    required this.contactIds,
    required this.durationMinutes,
    required this.rideId,
  });

  factory ShareLocationRequest.fromJson(Map<String, dynamic> json) =>
      _$ShareLocationRequestFromJson(json);
  Map<String, dynamic> toJson() => _$ShareLocationRequestToJson(this);
}

@JsonSerializable()
class ShareLocationData {
  final String sharingId;
  final String status;
  final int durationMinutes;
  final String expiresAt;
  final String shareableLink;
  final int contactsNotified;
  final bool rideDetailsIncluded;
  final bool trackingEnabled;
  final bool renewalAvailable;

  ShareLocationData({
    required this.sharingId,
    required this.status,
    required this.durationMinutes,
    required this.expiresAt,
    required this.shareableLink,
    required this.contactsNotified,
    required this.rideDetailsIncluded,
    required this.trackingEnabled,
    required this.renewalAvailable,
  });

  factory ShareLocationData.fromJson(Map<String, dynamic> json) =>
      _$ShareLocationDataFromJson(json);
  Map<String, dynamic> toJson() => _$ShareLocationDataToJson(this);
}

@JsonSerializable()
class ShareLocationResponse {
  final bool success;
  final String message;
  final ShareLocationData data;

  ShareLocationResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory ShareLocationResponse.fromJson(Map<String, dynamic> json) =>
      _$ShareLocationResponseFromJson(json);
  Map<String, dynamic> toJson() => _$ShareLocationResponseToJson(this);
}

@JsonSerializable()
class UserLocation {
  final double latitude;
  final double longitude;
  final int accuracy;
  final String timestamp;
  final String address;
  final int speed;
  final int heading;

  UserLocation({
    required this.latitude,
    required this.longitude,
    required this.accuracy,
    required this.timestamp,
    required this.address,
    required this.speed,
    required this.heading,
  });

  factory UserLocation.fromJson(Map<String, dynamic> json) =>
      _$UserLocationFromJson(json);
  Map<String, dynamic> toJson() => _$UserLocationToJson(this);
}

@JsonSerializable()
class RideDetails {
  final String rideId;
  final String destination;
  final String estimatedArrival;

  RideDetails({
    required this.rideId,
    required this.destination,
    required this.estimatedArrival,
  });

  factory RideDetails.fromJson(Map<String, dynamic> json) =>
      _$RideDetailsFromJson(json);
  Map<String, dynamic> toJson() => _$RideDetailsToJson(this);
}

@JsonSerializable()
class SharingInfo {
  final String sharingId;
  final String startedAt;
  final String expiresAt;
  final int remainingMinutes;
  final String message;
  final RideDetails rideDetails;

  SharingInfo({
    required this.sharingId,
    required this.startedAt,
    required this.expiresAt,
    required this.remainingMinutes,
    required this.message,
    required this.rideDetails,
  });

  factory SharingInfo.fromJson(Map<String, dynamic> json) =>
      _$SharingInfoFromJson(json);
  Map<String, dynamic> toJson() => _$SharingInfoToJson(this);
}

@JsonSerializable()
class LocationHistoryPoint {
  final double latitude;
  final double longitude;
  final String timestamp;

  LocationHistoryPoint({
    required this.latitude,
    required this.longitude,
    required this.timestamp,
  });

  factory LocationHistoryPoint.fromJson(Map<String, dynamic> json) =>
      _$LocationHistoryPointFromJson(json);
  Map<String, dynamic> toJson() => _$LocationHistoryPointToJson(this);
}

@JsonSerializable()
class SharedLocationData {
  final String userId;
  final String userName;
  final bool sharingActive;
  final UserLocation location;
  final SharingInfo sharingInfo;
  final String lastUpdated;
  final List<LocationHistoryPoint> locationHistory;

  SharedLocationData({
    required this.userId,
    required this.userName,
    required this.sharingActive,
    required this.location,
    required this.sharingInfo,
    required this.lastUpdated,
    required this.locationHistory,
  });

  factory SharedLocationData.fromJson(Map<String, dynamic> json) =>
      _$SharedLocationDataFromJson(json);
  Map<String, dynamic> toJson() => _$SharedLocationDataToJson(this);
}

@JsonSerializable()
class SharedLocationResponse {
  final bool success;
  final SharedLocationData data;

  SharedLocationResponse({required this.success, required this.data});

  factory SharedLocationResponse.fromJson(Map<String, dynamic> json) =>
      _$SharedLocationResponseFromJson(json);
  Map<String, dynamic> toJson() => _$SharedLocationResponseToJson(this);
}

@JsonSerializable()
class StopSharingResponse {
  final bool success;
  final String message;

  StopSharingResponse({required this.success, required this.message});

  factory StopSharingResponse.fromJson(Map<String, dynamic> json) =>
      _$StopSharingResponseFromJson(json);
  Map<String, dynamic> toJson() => _$StopSharingResponseToJson(this);
}
