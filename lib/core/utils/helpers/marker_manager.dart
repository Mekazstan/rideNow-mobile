// ignore_for_file: deprecated_member_use

import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ridenowappsss/modules/ride/data/models/location_model.dart';
import 'package:http/http.dart' as http;

abstract class MarkerManager {
  Set<Marker> get markers;
  Future<void> addCurrentLocationMarker(
    LocationModel location, {
    String? profilePhotoUrl,
    double? bearing,
  });
  Future<void> updatePickupMarker(
    LocationModel location, {
    String? profilePhotoUrl,
    double? bearing,
  });
  void addDestinationMarker(LocationModel location);
  void clearMarkers();
  Future<void> updateUserLocationWithPhoto(
    LocationModel location,
    String? profilePhotoUrl,
    double bearing,
  );
  Future<void> addDriverMarkers(List<DriverLocation> drivers);
  Future<void> updateDriverMarker(
    LatLng position, {
    String? photoUrl,
    double bearing = 0.0,
    String? eta,
  });
}

class DriverLocation {
  final String id;
  final double latitude;
  final double longitude;
  final String? photoUrl;
  final double bearing;

  DriverLocation({
    required this.id,
    required this.latitude,
    required this.longitude,
    this.photoUrl,
    this.bearing = 0.0,
  });
}

class MarkerManagerImpl implements MarkerManager {
  final Set<Marker> _markers = {};
  final Map<String, BitmapDescriptor> _markerCache = {};
  bool _isCreatingMarker = false;

  @override
  Set<Marker> get markers => _markers;

  @override
  Future<void> addCurrentLocationMarker(
    LocationModel location, {
    String? profilePhotoUrl,
    double? bearing,
  }) async {
    await updateUserLocationWithPhoto(
      location,
      profilePhotoUrl,
      bearing ?? 0.0,
    );
  }

  @override
  Future<void> updatePickupMarker(
    LocationModel location, {
    String? profilePhotoUrl,
    double? bearing,
  }) async {
    await updateUserLocationWithPhoto(
      location,
      profilePhotoUrl,
      bearing ?? 0.0,
    );
  }

  @override
  Future<void> updateUserLocationWithPhoto(
    LocationModel location,
    String? profilePhotoUrl,
    double bearing,
  ) async {
    if (_isCreatingMarker) return;
    _isCreatingMarker = true;

    try {
      _markers.removeWhere((m) => m.markerId.value == 'user_location');
      final markerIcon = await _createUserMarker(profilePhotoUrl, isUser: true);

      _markers.add(
        Marker(
          markerId: const MarkerId('user_location'),
          position: location.toLatLng(),
          icon: markerIcon,
          anchor: const Offset(0.5, 0.5),
          rotation: bearing,
          flat: true,
          zIndex: 999,
        ),
      );
    } catch (e) {
      debugPrint('Error adding user marker: $e');
    } finally {
      _isCreatingMarker = false;
    }
  }

  @override
  void addDestinationMarker(LocationModel location) {
    _markers.removeWhere((m) => m.markerId.value == 'destination');
    _markers.add(
      Marker(
        markerId: const MarkerId('destination'),
        position: location.toLatLng(),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        zIndex: 500,
      ),
    );
  }

  @override
  Future<void> addDriverMarkers(List<DriverLocation> drivers) async {
    _markers.removeWhere((m) => m.markerId.value.startsWith('driver_'));

    for (final driver in drivers) {
      try {
        final markerIcon = await _createUserMarker(
          driver.photoUrl,
          isUser: false,
        );
        _markers.add(
          Marker(
            markerId: MarkerId('driver_${driver.id}'),
            position: LatLng(driver.latitude, driver.longitude),
            icon: markerIcon,
            anchor: const Offset(0.5, 0.5),
            rotation: driver.bearing,
            flat: true,
            zIndex: 100,
          ),
        );
      } catch (e) {
        debugPrint('Error adding driver ${driver.id} marker: $e');
      }
    }
  }

  @override
  Future<void> updateDriverMarker(
    LatLng position, {
    String? photoUrl,
    double bearing = 0.0,
    String? eta,
  }) async {
    _markers.removeWhere((m) => m.markerId.value == 'active_driver');
    final markerIcon = await _createUserMarker(
      photoUrl,
      isUser: false,
      eta: eta,
    );

    _markers.add(
      Marker(
        markerId: const MarkerId('active_driver'),
        position: position,
        icon: markerIcon,
        anchor: const Offset(0.5, 0.5),
        rotation: bearing,
        flat: true,
        zIndex: 200,
      ),
    );
  }

  @override
  void clearMarkers() {
    _markers.clear();
    _markerCache.clear();
  }

  Future<BitmapDescriptor> _createUserMarker(
    String? profilePhotoUrl, {
    required bool isUser,
    String? eta,
  }) async {
    try {
      final cacheKey =
          '${profilePhotoUrl ?? 'default'}_${isUser ? 'user' : 'driver'}_${eta ?? 'none'}';
      if (_markerCache.containsKey(cacheKey)) {
        return _markerCache[cacheKey]!;
      }

      const double size = 250.0;
      const double avatarSize = 100.0;
      const double borderWidth = 5.0;
      final centerOffset = Offset(size / 2, size / 2 - (eta != null ? 20 : 0));

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      final paint = Paint()..isAntiAlias = true;

      // Shadow
      paint.color = Colors.black.withOpacity(0.15);
      canvas.drawCircle(
        centerOffset,
        (avatarSize / 2) + borderWidth + 2,
        paint..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
      );

      // Border (Red for user/pickup, Blue for driver)
      final borderColor =
          isUser ? const Color(0xFFEF4444) : const Color(0xFF3B82F6);
      canvas.drawCircle(
        centerOffset,
        (avatarSize / 2) + borderWidth,
        paint
          ..color = borderColor
          ..maskFilter = null,
      );

      bool imageLoaded = false;
      if (profilePhotoUrl != null && profilePhotoUrl.isNotEmpty) {
        try {
          final response = await http
              .get(Uri.parse(profilePhotoUrl))
              .timeout(const Duration(seconds: 5));
          if (response.statusCode == 200) {
            final codec = await ui.instantiateImageCodec(
              response.bodyBytes,
              targetWidth: avatarSize.toInt() * 2,
              targetHeight: avatarSize.toInt() * 2,
            );
            final frame = await codec.getNextFrame();
            final image = frame.image;

            canvas.save();
            canvas.clipPath(
              Path()..addOval(
                Rect.fromCircle(center: centerOffset, radius: avatarSize / 2),
              ),
            );
            canvas.drawImageRect(
              image,
              Rect.fromLTWH(
                0,
                0,
                image.width.toDouble(),
                image.height.toDouble(),
              ),
              Rect.fromCircle(center: centerOffset, radius: avatarSize / 2),
              Paint()..filterQuality = FilterQuality.high,
            );
            canvas.restore();
            imageLoaded = true;
          }
        } catch (e) {
          debugPrint('Image load error: $e');
        }
      }

      if (!imageLoaded) {
        paint.color = Colors.grey[200]!;
        canvas.drawCircle(centerOffset, avatarSize / 2, paint);
        final textPainter = TextPainter(
          text: TextSpan(
            text: '👤',
            style: TextStyle(fontSize: avatarSize * 0.6),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        textPainter.paint(
          canvas,
          Offset(
            centerOffset.dx - textPainter.width / 2,
            centerOffset.dy - textPainter.height / 2,
          ),
        );
      }

      if (!isUser && eta != null) {
        final badgeWidth = 100.0;
        final badgeHeight = 34.0;
        final badgeOffset = Offset(
          centerOffset.dx,
          centerOffset.dy + (avatarSize / 2) + 25,
        );

        final badgeRect = RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: badgeOffset,
            width: badgeWidth,
            height: badgeHeight,
          ),
          const Radius.circular(17),
        );
        canvas.drawRRect(badgeRect, paint..color = const Color(0xFFE91E63));

        final textPainter = TextPainter(
          text: TextSpan(
            text: eta,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        textPainter.paint(
          canvas,
          Offset(
            badgeOffset.dx - textPainter.width / 2,
            badgeOffset.dy - textPainter.height / 2,
          ),
        );
      }

      final picture = recorder.endRecording();
      final img = await picture.toImage(size.toInt(), size.toInt());
      final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
      final bitmapDescriptor = BitmapDescriptor.fromBytes(
        byteData!.buffer.asUint8List(),
      );
      _markerCache[cacheKey] = bitmapDescriptor;
      return bitmapDescriptor;
    } catch (e) {
      return BitmapDescriptor.defaultMarker;
    }
  }
}
