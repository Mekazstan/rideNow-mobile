class GlobalLocationUpdateRequest {
  final LocationDetail location;
  final double heading;
  final double speed;
  final String timestamp;

  GlobalLocationUpdateRequest({
    required this.location,
    required this.heading,
    required this.speed,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'location': location.toJson(),
      'heading': heading,
      'speed': speed,
      'timestamp': timestamp,
    };
  }
}

class LocationDetail {
  final double lat;
  final double lng;
  final String address;
  final double heading;
  final double speed;
  final String timestamp;

  LocationDetail({
    required this.lat,
    required this.lng,
    required this.address,
    required this.heading,
    required this.speed,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'lat': lat,
      'lng': lng,
      'address': address,
      'heading': heading,
      'speed': speed,
      'timestamp': timestamp,
    };
  }
}

class GlobalLocationUpdateResponse {
  final bool success;
  final double lat;
  final double lng;
  final String timestamp;

  GlobalLocationUpdateResponse({
    required this.success,
    required this.lat,
    required this.lng,
    required this.timestamp,
  });

  factory GlobalLocationUpdateResponse.fromJson(Map<String, dynamic> json) {
    final location = json['location'] as Map<String, dynamic>?;
    return GlobalLocationUpdateResponse(
      success: json['success'] as bool? ?? false,
      lat: (location?['lat'] as num? ?? 0).toDouble(),
      lng: (location?['lng'] as num? ?? 0).toDouble(),
      timestamp: json['timestamp'] as String? ?? '',
    );
  }
}
