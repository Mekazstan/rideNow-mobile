// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'community_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LocationCoordinates _$LocationCoordinatesFromJson(Map<String, dynamic> json) =>
    LocationCoordinates(
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
    );

Map<String, dynamic> _$LocationCoordinatesToJson(
        LocationCoordinates instance) =>
    <String, dynamic>{
      'lat': instance.lat,
      'lng': instance.lng,
    };

RideLocation _$RideLocationFromJson(Map<String, dynamic> json) => RideLocation(
      address: json['address'] as String,
      coordinates: LocationCoordinates.fromJson(
          json['coordinates'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$RideLocationToJson(RideLocation instance) =>
    <String, dynamic>{
      'address': instance.address,
      'coordinates': instance.coordinates,
    };

RideDriver _$RideDriverFromJson(Map<String, dynamic> json) => RideDriver(
      name: json['name'] as String,
      photo: json['photo'] as String,
      rating: (json['rating'] as num).toDouble(),
      vehicleType: json['vehicleType'] as String?,
      vehicle: json['vehicle'] as String?,
    );

Map<String, dynamic> _$RideDriverToJson(RideDriver instance) =>
    <String, dynamic>{
      'name': instance.name,
      'photo': instance.photo,
      'rating': instance.rating,
      'vehicleType': instance.vehicleType,
      'vehicle': instance.vehicle,
    };

LiveRideDetails _$LiveRideDetailsFromJson(Map<String, dynamic> json) =>
    LiveRideDetails(
      id: json['id'] as String,
      riderName: json['riderName'] as String,
      status: json['status'] as String,
      pickupLocation:
          RideLocation.fromJson(json['pickupLocation'] as Map<String, dynamic>),
      destination:
          RideLocation.fromJson(json['destination'] as Map<String, dynamic>),
      driver: RideDriver.fromJson(json['driver'] as Map<String, dynamic>),
      currentLocation: LocationCoordinates.fromJson(
          json['currentLocation'] as Map<String, dynamic>),
      estimatedArrival: json['estimatedArrival'] as String,
      startedAt: json['startedAt'] as String,
    );

Map<String, dynamic> _$LiveRideDetailsToJson(LiveRideDetails instance) =>
    <String, dynamic>{
      'id': instance.id,
      'riderName': instance.riderName,
      'status': instance.status,
      'pickupLocation': instance.pickupLocation,
      'destination': instance.destination,
      'driver': instance.driver,
      'currentLocation': instance.currentLocation,
      'estimatedArrival': instance.estimatedArrival,
      'startedAt': instance.startedAt,
    };

LiveRideResponse _$LiveRideResponseFromJson(Map<String, dynamic> json) =>
    LiveRideResponse(
      ride: LiveRideDetails.fromJson(json['ride'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$LiveRideResponseToJson(LiveRideResponse instance) =>
    <String, dynamic>{
      'ride': instance.ride,
    };

SharedRide _$SharedRideFromJson(Map<String, dynamic> json) => SharedRide(
      rideId: json['rideId'] as String,
      riderName: json['riderName'] as String,
      status: json['status'] as String,
      pickupLocation: json['pickupLocation'] as String,
      destination: json['destination'] as String,
      driver: RideDriver.fromJson(json['driver'] as Map<String, dynamic>),
      sharedAt: json['sharedAt'] as String,
      liveLocation: LocationCoordinates.fromJson(
          json['liveLocation'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$SharedRideToJson(SharedRide instance) =>
    <String, dynamic>{
      'rideId': instance.rideId,
      'riderName': instance.riderName,
      'status': instance.status,
      'pickupLocation': instance.pickupLocation,
      'destination': instance.destination,
      'driver': instance.driver,
      'sharedAt': instance.sharedAt,
      'liveLocation': instance.liveLocation,
    };

SharedRidesResponse _$SharedRidesResponseFromJson(Map<String, dynamic> json) =>
    SharedRidesResponse(
      sharedRides: (json['sharedRides'] as List<dynamic>)
          .map((e) => SharedRide.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$SharedRidesResponseToJson(
        SharedRidesResponse instance) =>
    <String, dynamic>{
      'sharedRides': instance.sharedRides,
    };

ShareLocationRequest _$ShareLocationRequestFromJson(
        Map<String, dynamic> json) =>
    ShareLocationRequest(
      contactIds: (json['contact_ids'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      durationMinutes: (json['duration_minutes'] as num).toInt(),
      rideId: json['ride_id'] as String,
    );

Map<String, dynamic> _$ShareLocationRequestToJson(
        ShareLocationRequest instance) =>
    <String, dynamic>{
      'contact_ids': instance.contactIds,
      'duration_minutes': instance.durationMinutes,
      'ride_id': instance.rideId,
    };

ShareLocationData _$ShareLocationDataFromJson(Map<String, dynamic> json) =>
    ShareLocationData(
      sharingId: json['sharingId'] as String,
      status: json['status'] as String,
      durationMinutes: (json['durationMinutes'] as num).toInt(),
      expiresAt: json['expiresAt'] as String,
      shareableLink: json['shareableLink'] as String,
      contactsNotified: (json['contactsNotified'] as num).toInt(),
      rideDetailsIncluded: json['rideDetailsIncluded'] as bool,
      trackingEnabled: json['trackingEnabled'] as bool,
      renewalAvailable: json['renewalAvailable'] as bool,
    );

Map<String, dynamic> _$ShareLocationDataToJson(ShareLocationData instance) =>
    <String, dynamic>{
      'sharingId': instance.sharingId,
      'status': instance.status,
      'durationMinutes': instance.durationMinutes,
      'expiresAt': instance.expiresAt,
      'shareableLink': instance.shareableLink,
      'contactsNotified': instance.contactsNotified,
      'rideDetailsIncluded': instance.rideDetailsIncluded,
      'trackingEnabled': instance.trackingEnabled,
      'renewalAvailable': instance.renewalAvailable,
    };

ShareLocationResponse _$ShareLocationResponseFromJson(
        Map<String, dynamic> json) =>
    ShareLocationResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      data: ShareLocationData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ShareLocationResponseToJson(
        ShareLocationResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'data': instance.data,
    };

UserLocation _$UserLocationFromJson(Map<String, dynamic> json) => UserLocation(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      accuracy: (json['accuracy'] as num).toInt(),
      timestamp: json['timestamp'] as String,
      address: json['address'] as String,
      speed: (json['speed'] as num).toInt(),
      heading: (json['heading'] as num).toInt(),
    );

Map<String, dynamic> _$UserLocationToJson(UserLocation instance) =>
    <String, dynamic>{
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'accuracy': instance.accuracy,
      'timestamp': instance.timestamp,
      'address': instance.address,
      'speed': instance.speed,
      'heading': instance.heading,
    };

RideDetails _$RideDetailsFromJson(Map<String, dynamic> json) => RideDetails(
      rideId: json['rideId'] as String,
      destination: json['destination'] as String,
      estimatedArrival: json['estimatedArrival'] as String,
    );

Map<String, dynamic> _$RideDetailsToJson(RideDetails instance) =>
    <String, dynamic>{
      'rideId': instance.rideId,
      'destination': instance.destination,
      'estimatedArrival': instance.estimatedArrival,
    };

SharingInfo _$SharingInfoFromJson(Map<String, dynamic> json) => SharingInfo(
      sharingId: json['sharingId'] as String,
      startedAt: json['startedAt'] as String,
      expiresAt: json['expiresAt'] as String,
      remainingMinutes: (json['remainingMinutes'] as num).toInt(),
      message: json['message'] as String,
      rideDetails:
          RideDetails.fromJson(json['rideDetails'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$SharingInfoToJson(SharingInfo instance) =>
    <String, dynamic>{
      'sharingId': instance.sharingId,
      'startedAt': instance.startedAt,
      'expiresAt': instance.expiresAt,
      'remainingMinutes': instance.remainingMinutes,
      'message': instance.message,
      'rideDetails': instance.rideDetails,
    };

LocationHistoryPoint _$LocationHistoryPointFromJson(
        Map<String, dynamic> json) =>
    LocationHistoryPoint(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      timestamp: json['timestamp'] as String,
    );

Map<String, dynamic> _$LocationHistoryPointToJson(
        LocationHistoryPoint instance) =>
    <String, dynamic>{
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'timestamp': instance.timestamp,
    };

SharedLocationData _$SharedLocationDataFromJson(Map<String, dynamic> json) =>
    SharedLocationData(
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      sharingActive: json['sharingActive'] as bool,
      location: UserLocation.fromJson(json['location'] as Map<String, dynamic>),
      sharingInfo:
          SharingInfo.fromJson(json['sharingInfo'] as Map<String, dynamic>),
      lastUpdated: json['lastUpdated'] as String,
      locationHistory: (json['locationHistory'] as List<dynamic>)
          .map((e) => LocationHistoryPoint.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$SharedLocationDataToJson(SharedLocationData instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'userName': instance.userName,
      'sharingActive': instance.sharingActive,
      'location': instance.location,
      'sharingInfo': instance.sharingInfo,
      'lastUpdated': instance.lastUpdated,
      'locationHistory': instance.locationHistory,
    };

SharedLocationResponse _$SharedLocationResponseFromJson(
        Map<String, dynamic> json) =>
    SharedLocationResponse(
      success: json['success'] as bool,
      data: SharedLocationData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$SharedLocationResponseToJson(
        SharedLocationResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'data': instance.data,
    };

StopSharingResponse _$StopSharingResponseFromJson(Map<String, dynamic> json) =>
    StopSharingResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
    );

Map<String, dynamic> _$StopSharingResponseToJson(
        StopSharingResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
    };
