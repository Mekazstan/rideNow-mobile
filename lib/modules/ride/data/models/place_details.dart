import 'package:flutter/foundation.dart';

class PlaceDetails {
  final Geometry? geometry;
  final String? formattedAddress;
  final String? name;

  PlaceDetails({this.geometry, this.formattedAddress, this.name});

  factory PlaceDetails.fromJson(Map<String, dynamic> json) {
    try {
      debugPrint('📍 Parsing PlaceDetails from JSON: $json');

      final placeDetails = PlaceDetails(
        geometry:
            json['geometry'] != null
                ? Geometry.fromJson(json['geometry'] as Map<String, dynamic>)
                : null,
        formattedAddress: json['formatted_address'] as String?,
        name: json['name'] as String?,
      );

      // Validate the parsed data
      if (placeDetails.geometry?.location?.lat == null ||
          placeDetails.geometry?.location?.lng == null) {
        debugPrint('⚠️ PlaceDetails missing coordinates!');
      } else {
        debugPrint(
          '✅ PlaceDetails parsed: ${placeDetails.geometry?.location?.lat}, ${placeDetails.geometry?.location?.lng}',
        );
      }

      return placeDetails;
    } catch (e) {
      debugPrint('❌ Error parsing PlaceDetails: $e');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'geometry': geometry?.toJson(),
      'formatted_address': formattedAddress,
      'name': name,
    };
  }
}

class Geometry {
  final Location? location;

  Geometry({this.location});

  factory Geometry.fromJson(Map<String, dynamic> json) {
    try {
      return Geometry(
        location:
            json['location'] != null
                ? Location.fromJson(json['location'] as Map<String, dynamic>)
                : null,
      );
    } catch (e) {
      debugPrint('❌ Error parsing Geometry: $e');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {'location': location?.toJson()};
  }
}

class Location {
  final double? lat;
  final double? lng;

  Location({this.lat, this.lng});

  factory Location.fromJson(Map<String, dynamic> json) {
    try {
      // Handle both 'lat'/'lng' and 'latitude'/'longitude' formats
      final latitude = json['lat'] as num? ?? json['latitude'] as num?;
      final longitude = json['lng'] as num? ?? json['longitude'] as num?;

      if (latitude == null || longitude == null) {
        debugPrint('⚠️ Location missing lat/lng in JSON: $json');
      }

      return Location(lat: latitude?.toDouble(), lng: longitude?.toDouble());
    } catch (e) {
      debugPrint('❌ Error parsing Location: $e');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {'lat': lat, 'lng': lng};
  }
}
