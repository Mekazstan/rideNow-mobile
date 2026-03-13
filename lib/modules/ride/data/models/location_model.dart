import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ridenowappsss/core/utils/constants/api_constant.dart';
import 'package:ridenowappsss/modules/ride/data/models/place_details.dart';

class LocationModel {
  final double latitude;
  final double longitude;
  final String? address;
  final String? name;

  LocationModel({
    required this.latitude,
    required this.longitude,
    this.address,
    this.name,
  });

  // Factory constructor from PlaceDetails
  factory LocationModel.fromPlaceDetails(PlaceDetails details) {
    final double lat = details.geometry?.location?.lat ?? 0.0;
    final double lng = details.geometry?.location?.lng ?? 0.0;
    if (lat == 0.0 && lng == 0.0) {}

    return LocationModel(
      latitude: lat,
      longitude: lng,
      address: details.formattedAddress ?? details.name ?? "Unknown Location",
      name: details.name,
    );
  }

  // Factory for default location (fallback)
  factory LocationModel.defaultLocation() {
    return LocationModel(
      latitude: MapConstants.defaultLatitude,
      longitude: MapConstants.defaultLongitude,
      address: 'Benin City, Nigeria',
      name: 'Current Location',
    );
  }

  // Convert to LatLng for Google Maps
  LatLng toLatLng() {
    return LatLng(latitude, longitude);
  }

  // Copy with method
  LocationModel copyWith({
    double? latitude,
    double? longitude,
    String? address,
    String? name,
  }) {
    return LocationModel(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      name: name ?? this.name,
    );
  }

  // For debugging
  @override
  String toString() {
    return 'LocationModel(lat: $latitude, lng: $longitude, address: $address)';
  }

  // Validation helper
  bool get isValid {
    return latitude != 0.0 &&
        longitude != 0.0 &&
        latitude.abs() <= 90 &&
        longitude.abs() <= 180;
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'name': name,
    };
  }

  // From JSON
  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      address: json['address'] as String?,
      name: json['name'] as String?,
    );
  }
}
