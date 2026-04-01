/// Refined Driver Status Model
class DriverStatusResponse {
  final bool success;
  final DriverStatusData data;

  DriverStatusResponse({required this.success, required this.data});

  factory DriverStatusResponse.fromJson(Map<String, dynamic> json) {
    return DriverStatusResponse(
      success: json['success'] as bool? ?? false,
      data: DriverStatusData.fromJson(json['data'] as Map<String, dynamic>),
    );
  }
}

class DriverStatusData {
  final DriverLocation location;
  final int etaMinutes;
  final double distanceKm;
  final int routeProgress;
  final String currentStatus;
  final VehicleInfo vehicle;
  final int nextUpdateIn;

  DriverStatusData({
    required this.location,
    required this.etaMinutes,
    required this.distanceKm,
    required this.routeProgress,
    required this.currentStatus,
    required this.vehicle,
    required this.nextUpdateIn,
  });

  factory DriverStatusData.fromJson(Map<String, dynamic> json) {
    return DriverStatusData(
      location: DriverLocation.fromJson(
        json['driver_location'] as Map<String, dynamic>,
      ),
      etaMinutes: json['eta_minutes'] as int? ?? 0,
      distanceKm: (json['distance_km'] as num?)?.toDouble() ?? 0.0,
      routeProgress: json['route_progress'] as int? ?? 0,
      currentStatus: json['current_status'] as String? ?? 'unknown',
      vehicle: VehicleInfo.fromJson(json['vehicle'] as Map<String, dynamic>),
      nextUpdateIn: json['next_update_in'] as int? ?? 0,
    );
  }
}

class DriverLocation {
  final double latitude;
  final double longitude;
  final int accuracy;
  final DateTime timestamp;

  DriverLocation({
    required this.latitude,
    required this.longitude,
    required this.accuracy,
    required this.timestamp,
  });

  factory DriverLocation.fromJson(Map<String, dynamic> json) {
    return DriverLocation(
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      accuracy: json['accuracy'] as int? ?? 0,
      timestamp:
          json['timestamp'] != null
              ? DateTime.parse(json['timestamp'] as String)
              : DateTime.now(),
    );
  }
}

class VehicleInfo {
  final String make;
  final String model;
  final String color;
  final String licensePlate;

  VehicleInfo({
    required this.make,
    required this.model,
    required this.color,
    required this.licensePlate,
  });

  factory VehicleInfo.fromJson(Map<String, dynamic> json) {
    return VehicleInfo(
      make: json['make'] as String? ?? '',
      model: json['model'] as String? ?? '',
      color: json['color'] as String? ?? '',
      licensePlate:
          json['license_plate'] as String? ??
          json['licensePlate'] as String? ??
          '',
    );
  }
}

/// Chat Models
class ChatHistoryResponse {
  final List<ChatMessage> messages;
  final int unreadCount;
  final String rideStatus;

  ChatHistoryResponse({
    required this.messages,
    required this.unreadCount,
    required this.rideStatus,
  });

  factory ChatHistoryResponse.fromJson(Map<String, dynamic> json) {
    return ChatHistoryResponse(
      messages:
          (json['messages'] as List<dynamic>?)
              ?.map((e) => ChatMessage.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      unreadCount: json['unreadCount'] as int? ?? 0,
      rideStatus: json['rideStatus'] as String? ?? 'unknown',
    );
  }
}

class ChatMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String senderType; // 'rider' or 'driver'
  final String message;
  final String messageType; // 'text' etc.
  final DateTime timestamp;
  final bool isRead;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.senderType,
    required this.message,
    required this.messageType,
    required this.timestamp,
    required this.isRead,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as String? ?? '',
      senderId: json['senderId'] as String? ?? '',
      senderName: json['senderName'] as String? ?? '',
      senderType: json['senderType'] as String? ?? 'unknown',
      message: json['message'] as String? ?? '',
      messageType: json['messageType'] as String? ?? 'text',
      timestamp:
          json['timestamp'] != null
              ? DateTime.parse(json['timestamp'] as String)
              : DateTime.now(),
      isRead: json['isRead'] as bool? ?? false,
    );
  }
}

class SendMessageResponse {
  final bool success;
  final String messageId;
  final DateTime timestamp;
  final bool delivered;
  final String message;

  SendMessageResponse({
    required this.success,
    required this.messageId,
    required this.timestamp,
    required this.delivered,
    required this.message,
  });

  factory SendMessageResponse.fromJson(Map<String, dynamic> json) {
    return SendMessageResponse(
      success: json['success'] as bool? ?? false,
      messageId: json['messageId'] as String? ?? '',
      timestamp:
          json['timestamp'] != null
              ? DateTime.parse(json['timestamp'] as String)
              : DateTime.now(),
      delivered: json['delivered'] as bool? ?? false,
      message: json['message'] as String? ?? '',
    );
  }
}

/// Nearby Drivers Models
class NearbyDriversResponse {
  final List<NearbyDriver> drivers;
  final int totalDrivers;
  final int searchRadius;
  final NearbyLocation pickupLocation;

  NearbyDriversResponse({
    required this.drivers,
    required this.totalDrivers,
    required this.searchRadius,
    required this.pickupLocation,
  });

  factory NearbyDriversResponse.fromJson(Map<String, dynamic> json) {
    return NearbyDriversResponse(
      drivers:
          (json['drivers'] as List<dynamic>?)
              ?.map((e) => NearbyDriver.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      totalDrivers: json['totalDrivers'] as int? ?? 0,
      searchRadius: json['searchRadius'] as int? ?? 10,
      pickupLocation: NearbyLocation.fromJson(
        json['pickupLocation'] as Map<String, dynamic>,
      ),
    );
  }
}

class NearbyDriver {
  final String driverId;
  final String name;
  final double rating;
  final int totalTrips;
  final String profilePhoto;
  final VehicleInfo vehicle;
  final NearbyLocation location;
  final double distance;
  final int estimatedArrival;
  final bool isAvailable;

  NearbyDriver({
    required this.driverId,
    required this.name,
    required this.rating,
    required this.totalTrips,
    required this.profilePhoto,
    required this.vehicle,
    required this.location,
    required this.distance,
    required this.estimatedArrival,
    required this.isAvailable,
  });

  factory NearbyDriver.fromJson(Map<String, dynamic> json) {
    return NearbyDriver(
      driverId: json['driverId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      totalTrips: json['totalTrips'] as int? ?? 0,
      profilePhoto: json['profilePhoto'] as String? ?? '',
      vehicle: VehicleInfo.fromJson(json['vehicle'] as Map<String, dynamic>),
      location: NearbyLocation.fromJson(
        json['location'] as Map<String, dynamic>,
      ),
      distance: (json['distance'] as num?)?.toDouble() ?? 0.0,
      estimatedArrival: json['estimatedArrival'] as int? ?? 0,
      isAvailable: json['isAvailable'] as bool? ?? false,
    );
  }
}

class NearbyLocation {
  final double lat;
  final double lng;

  NearbyLocation({required this.lat, required this.lng});

  factory NearbyLocation.fromJson(Map<String, dynamic> json) {
    return NearbyLocation(
      lat: (json['lat'] as num?)?.toDouble() ?? 0.0,
      lng: (json['lng'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

/// Payment Models
class PaymentResponse {
  final bool success;
  final String transactionId;
  final double amountCharged;
  final String paymentStatus;

  PaymentResponse({
    required this.success,
    required this.transactionId,
    required this.amountCharged,
    required this.paymentStatus,
  });

  factory PaymentResponse.fromJson(Map<String, dynamic> json) {
    return PaymentResponse(
      success: json['success'] as bool? ?? false,
      transactionId: json['transaction_id'] as String? ?? '',
      amountCharged: (json['amount_charged'] as num?)?.toDouble() ?? 0.0,
      paymentStatus: json['payment_status'] as String? ?? '',
    );
  }
}

/// Receipt Models
class RideReceiptResponse {
  final ReceiptDetails receipt;

  RideReceiptResponse({required this.receipt});

  factory RideReceiptResponse.fromJson(Map<String, dynamic> json) {
    return RideReceiptResponse(
      receipt: ReceiptDetails.fromJson(json['receipt'] as Map<String, dynamic>),
    );
  }
}

class ReceiptDetails {
  final String rideId;
  final String transactionId;
  final double amount;
  final String currency;
  final String date;
  final String pickup;
  final String destination;
  final String driverName;
  final String distance;
  final String duration;
  final String paymentMethod;

  ReceiptDetails({
    required this.rideId,
    required this.transactionId,
    required this.amount,
    required this.currency,
    required this.date,
    required this.pickup,
    required this.destination,
    required this.driverName,
    required this.distance,
    required this.duration,
    required this.paymentMethod,
  });

  factory ReceiptDetails.fromJson(Map<String, dynamic> json) {
    return ReceiptDetails(
      rideId: json['ride_id'] as String? ?? '',
      transactionId: json['transaction_id'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] as String? ?? 'NGN',
      date: json['date'] as String? ?? '',
      pickup: json['pickup'] as String? ?? '',
      destination: json['destination'] as String? ?? '',
      driverName: json['driver_name'] as String? ?? '',
      distance: json['distance'] as String? ?? '',
      duration: json['duration'] as String? ?? '',
      paymentMethod: json['payment_method'] as String? ?? '',
    );
  }
}

/// Select Driver Response
class SelectDriverResponse {
  final bool success;
  final String message;
  final SelectDriverData data;

  SelectDriverResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory SelectDriverResponse.fromJson(Map<String, dynamic> json) {
    return SelectDriverResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      data: SelectDriverData.fromJson(json['data'] as Map<String, dynamic>),
    );
  }
}

class SelectDriverData {
  final String rideId;
  final String driverId;
  final String status;
  final int acceptanceTimeout;
  final DateTime expiresAt;
  final DriverContactInfo driverContact;

  SelectDriverData({
    required this.rideId,
    required this.driverId,
    required this.status,
    required this.acceptanceTimeout,
    required this.expiresAt,
    required this.driverContact,
  });

  factory SelectDriverData.fromJson(Map<String, dynamic> json) {
    return SelectDriverData(
      rideId: json['ride_id'] as String? ?? '',
      driverId: json['driver_id'] as String? ?? '',
      status: json['status'] as String? ?? '',
      acceptanceTimeout: json['acceptance_timeout'] as int? ?? 30,
      expiresAt:
          json['expires_at'] != null
              ? DateTime.parse(json['expires_at'] as String)
              : DateTime.now(),
      driverContact: DriverContactInfo.fromJson(
        json['driver_contact_info'] as Map<String, dynamic>,
      ),
    );
  }
}

class DriverContactInfo {
  final String name;
  final double rating;

  DriverContactInfo({required this.name, required this.rating});

  factory DriverContactInfo.fromJson(Map<String, dynamic> json) {
    return DriverContactInfo(
      name: json['name'] as String? ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

/// Tracking Models
class RideTrackingResponse {
  final bool success;
  final TrackingData data;

  RideTrackingResponse({required this.success, required this.data});

  factory RideTrackingResponse.fromJson(Map<String, dynamic> json) {
    return RideTrackingResponse(
      success: json['success'] as bool? ?? false,
      data: TrackingData.fromJson(json['data'] as Map<String, dynamic>),
    );
  }
}

class TrackingData {
  final String rideId;
  final String status;
  final DriverLocation currentLocation;
  final RouteData route;
  final RideProgress progress;
  final DriverActivity driver;
  final int nextUpdateIn;

  TrackingData({
    required this.rideId,
    required this.status,
    required this.currentLocation,
    required this.route,
    required this.progress,
    required this.driver,
    required this.nextUpdateIn,
  });

  factory TrackingData.fromJson(Map<String, dynamic> json) {
    return TrackingData(
      rideId: json['ride_id'] as String? ?? '',
      status: json['status'] as String? ?? '',
      currentLocation: DriverLocation.fromJson(
        json['current_location'] as Map<String, dynamic>,
      ),
      route: RouteData.fromJson(json['route'] as Map<String, dynamic>),
      progress: RideProgress.fromJson(json['progress'] as Map<String, dynamic>),
      driver: DriverActivity.fromJson(json['driver'] as Map<String, dynamic>),
      nextUpdateIn: json['next_update_in'] as int? ?? 5,
    );
  }
}

class RouteData {
  final String polyline;
  final List<NearbyLocation> waypoints;

  RouteData({required this.polyline, required this.waypoints});

  factory RouteData.fromJson(Map<String, dynamic> json) {
    return RouteData(
      polyline: json['polyline'] as String? ?? '',
      waypoints:
          (json['waypoints'] as List<dynamic>?)
              ?.map((e) => NearbyLocation.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class RideProgress {
  final double distanceTraveled;
  final double distanceRemaining;
  final int timeElapsed;
  final int timeRemaining;
  final int progressPercentage;

  RideProgress({
    required this.distanceTraveled,
    required this.distanceRemaining,
    required this.timeElapsed,
    required this.timeRemaining,
    required this.progressPercentage,
  });

  factory RideProgress.fromJson(Map<String, dynamic> json) {
    return RideProgress(
      distanceTraveled:
          (json['distance_traveled_km'] as num?)?.toDouble() ?? 0.0,
      distanceRemaining:
          (json['distance_remaining_km'] as num?)?.toDouble() ?? 0.0,
      timeElapsed: json['time_elapsed_minutes'] as int? ?? 0,
      timeRemaining: json['time_remaining_minutes'] as int? ?? 0,
      progressPercentage: json['progress_percentage'] as int? ?? 0,
    );
  }
}

class DriverActivity {
  final int speed;
  final int heading;
  final String nextTurn;

  DriverActivity({
    required this.speed,
    required this.heading,
    required this.nextTurn,
  });

  factory DriverActivity.fromJson(Map<String, dynamic> json) {
    return DriverActivity(
      speed: json['speed_kph'] as int? ?? 0,
      heading: json['heading'] as int? ?? 0,
      nextTurn: json['next_turn'] as String? ?? '',
    );
  }
}

/// Verify Code Models
class VerifyRideCodeResponse {
  final bool success;
  final bool verified;
  final String rideId;
  final SimpleRiderInfo rider;
  final String status;
  final bool canStartRide;
  final String message;

  VerifyRideCodeResponse({
    required this.success,
    required this.verified,
    required this.rideId,
    required this.rider,
    required this.status,
    required this.canStartRide,
    required this.message,
  });

  factory VerifyRideCodeResponse.fromJson(Map<String, dynamic> json) {
    return VerifyRideCodeResponse(
      success: json['success'] as bool? ?? false,
      verified: json['verified'] as bool? ?? false,
      rideId: json['rideId'] as String? ?? '',
      rider: SimpleRiderInfo.fromJson(json['rider'] as Map<String, dynamic>),
      status: json['status'] as String? ?? '',
      canStartRide: json['canStartRide'] as bool? ?? false,
      message: json['message'] as String? ?? '',
    );
  }
}

class SimpleRiderInfo {
  final String name;
  final String photo;

  SimpleRiderInfo({required this.name, required this.photo});

  factory SimpleRiderInfo.fromJson(Map<String, dynamic> json) {
    return SimpleRiderInfo(
      name: json['name'] as String? ?? 'Rider',
      photo: json['photo'] as String? ?? '',
    );
  }
}

/// Sharing Models
class ShareTripResponse {
  final bool success;
  final String shareToken;
  final List<SharedWithContact> sharedWith;
  final String trackingUrl;
  final String expiresAt;

  ShareTripResponse({
    required this.success,
    required this.shareToken,
    required this.sharedWith,
    required this.trackingUrl,
    required this.expiresAt,
  });

  factory ShareTripResponse.fromJson(Map<String, dynamic> json) {
    return ShareTripResponse(
      success: json['success'] as bool? ?? false,
      shareToken: json['share_token'] as String? ?? '',
      sharedWith:
          (json['shared_with'] as List<dynamic>?)
              ?.map(
                (e) => SharedWithContact.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
      trackingUrl: json['tracking_url'] as String? ?? '',
      expiresAt: json['expires_at'] as String? ?? '',
    );
  }
}

class SharedWithContact {
  final String contactId;
  final String contactName;
  final bool notificationSent;

  SharedWithContact({
    required this.contactId,
    required this.contactName,
    required this.notificationSent,
  });

  factory SharedWithContact.fromJson(Map<String, dynamic> json) {
    return SharedWithContact(
      contactId: json['contact_id'] as String? ?? '',
      contactName: json['contact_name'] as String? ?? '',
      notificationSent: json['notification_sent'] as bool? ?? false,
    );
  }
}

class ShareRideLinkResponse {
  final bool success;
  final String shareLink;
  final String message;

  ShareRideLinkResponse({
    required this.success,
    required this.shareLink,
    required this.message,
  });

  factory ShareRideLinkResponse.fromJson(Map<String, dynamic> json) {
    return ShareRideLinkResponse(
      success: json['success'] as bool? ?? false,
      shareLink: json['share_link'] as String? ?? '',
      message: json['message'] as String? ?? '',
    );
  }
}

/// Status Update Response
class RideStatusUpdateResponse {
  final String message;
  final String newStatus;
  final DateTime timestamp;

  RideStatusUpdateResponse({
    required this.message,
    required this.newStatus,
    required this.timestamp,
  });

  factory RideStatusUpdateResponse.fromJson(Map<String, dynamic> json) {
    return RideStatusUpdateResponse(
      message: json['message'] as String? ?? '',
      newStatus: json['new_status'] as String? ?? '',
      timestamp:
          json['timestamp'] != null
              ? DateTime.parse(json['timestamp'] as String)
              : DateTime.now(),
    );
  }
}

class RideHistoryResponse {
  final List<RideHistoryItem> rides;
  final int totalCount;

  RideHistoryResponse({required this.rides, required this.totalCount});

  factory RideHistoryResponse.fromJson(Map<String, dynamic> json) {
    return RideHistoryResponse(
      rides:
          (json['rides'] as List<dynamic>?)
              ?.map((e) => RideHistoryItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      totalCount: json['total_count'] as int? ?? 0,
    );
  }
}

class RideHistoryItem {
  final String rideId;
  final String status;
  final LocationResponseDto pickupLocation;
  final LocationResponseDto destination;
  final double fare;
  final String currency;
  final String createdAt;
  final String? driverName;
  final String? vehicleInfo;

  RideHistoryItem({
    required this.rideId,
    required this.status,
    required this.pickupLocation,
    required this.destination,
    required this.fare,
    required this.currency,
    required this.createdAt,
    this.driverName,
    this.vehicleInfo,
  });

  factory RideHistoryItem.fromJson(Map<String, dynamic> json) {
    return RideHistoryItem(
      rideId: json['ride_id'] as String? ?? '',
      status: json['status'] as String? ?? '',
      pickupLocation: LocationResponseDto.fromJson(
        json['pickup_location'] as Map<String, dynamic>,
      ),
      destination: LocationResponseDto.fromJson(
        json['destination'] as Map<String, dynamic>,
      ),
      fare: (json['fare'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] as String? ?? 'NGN',
      createdAt: json['created_at'] as String? ?? '',
      driverName: json['driver_name'] as String?,
      vehicleInfo: json['vehicle_info'] as String?,
    );
  }
}

class LocationResponseDto {
  final String address;
  final CoordinatesResponseDto coordinates;

  LocationResponseDto({required this.address, required this.coordinates});

  factory LocationResponseDto.fromJson(Map<String, dynamic> json) {
    return LocationResponseDto(
      address: json['address'] as String? ?? '',
      coordinates: CoordinatesResponseDto.fromJson(
        json['coordinates'] as Map<String, dynamic>,
      ),
    );
  }
}

class CoordinatesResponseDto {
  final double lat;
  final double lng;

  CoordinatesResponseDto({required this.lat, required this.lng});

  factory CoordinatesResponseDto.fromJson(Map<String, dynamic> json) {
    return CoordinatesResponseDto(
      lat: (json['lat'] as num?)?.toDouble() ?? 0.0,
      lng: (json['lng'] as num?)?.toDouble() ?? 0.0,
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

class AutoAcceptNearestResponse {
  final bool success;
  final String message;
  final String? rideId;

  AutoAcceptNearestResponse({
    required this.success,
    required this.message,
    this.rideId,
  });

  factory AutoAcceptNearestResponse.fromJson(Map<String, dynamic> json) {
    return AutoAcceptNearestResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      rideId: json['rideId'] as String?,
    );
  }
}
