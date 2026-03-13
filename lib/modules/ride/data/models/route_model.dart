import 'package:google_maps_flutter/google_maps_flutter.dart';

class RouteModel {
  final List<LatLng> points;
  final String distance;
  final String duration;

  const RouteModel({
    required this.points,
    required this.distance,
    required this.duration,
  });

  factory RouteModel.fromMap(Map<String, dynamic> map) {
    return RouteModel(
      points: map['points'] as List<LatLng>,
      distance: map['distance'] as String? ?? '',
      duration: map['duration'] as String? ?? '',
    );
  }

  bool get isEmpty => points.isEmpty;
}
