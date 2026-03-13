// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:ridenowappsss/modules/ride/data/models/location_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class LocationService {
  Future<LocationModel> getCurrentLocation();
  Future<bool> isLocationServiceEnabled();
  Future<bool> requestLocationPermission();
  Stream<LocationModel> getLocationStream();
}

class LocationServiceImpl implements LocationService {
  static const String _cacheKeyLat = 'cached_latitude';
  static const String _cacheKeyLng = 'cached_longitude';
  static const String _cacheKeyTimestamp = 'cached_timestamp';
  static const int _cacheValidityMinutes = 10;

  LocationModel? _lastKnownLocation;

  @override
  Future<LocationModel> getCurrentLocation() async {
    try {
      final cachedLocation = await _getCachedLocation();
      if (cachedLocation != null) {
        _lastKnownLocation = cachedLocation;
        debugPrint(
          'ðŸ“ Using cached location: ${cachedLocation.latitude}, ${cachedLocation.longitude}',
        );

        _updateLocationInBackground();
        return cachedLocation;
      }
      if (!await isLocationServiceEnabled()) {
        debugPrint('âš ï¸ Location service disabled, using default');
        return LocationModel.defaultLocation();
      }

      // 3. Check permissions
      if (!await requestLocationPermission()) {
        debugPrint('âš ï¸ Location permission denied, using default');
        return LocationModel.defaultLocation();
      }

      // 4. Get fresh location with timeout
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 5),
      );

      final location = LocationModel(
        latitude: position.latitude,
        longitude: position.longitude,
      );

      // Cache the location
      await _cacheLocation(location);
      _lastKnownLocation = location;

      debugPrint(
        'ðŸ“ Fresh location obtained: ${location.latitude}, ${location.longitude}',
      );
      return location;
    } catch (e) {
      debugPrint('âŒ Error getting location: $e');

      // Return last known location if available
      if (_lastKnownLocation != null) {
        debugPrint('ðŸ“ Using last known location');
        return _lastKnownLocation!;
      }

      return LocationModel.defaultLocation();
    }
  }

  // Get cached location if still valid
  Future<LocationModel?> _getCachedLocation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedLat = prefs.getDouble(_cacheKeyLat);
      final cachedLng = prefs.getDouble(_cacheKeyLng);
      final cachedTimestamp = prefs.getInt(_cacheKeyTimestamp);

      if (cachedLat == null || cachedLng == null || cachedTimestamp == null) {
        return null;
      }

      // Check if cache is still valid
      final cacheAge = DateTime.now().millisecondsSinceEpoch - cachedTimestamp;
      final cacheValidityMs = _cacheValidityMinutes * 60 * 1000;

      if (cacheAge > cacheValidityMs) {
        debugPrint('âš ï¸ Cached location expired');
        return null;
      }

      return LocationModel(latitude: cachedLat, longitude: cachedLng);
    } catch (e) {
      debugPrint('âŒ Error reading cached location: $e');
      return null;
    }
  }

  // Cache location for faster subsequent loads
  Future<void> _cacheLocation(LocationModel location) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(_cacheKeyLat, location.latitude);
      await prefs.setDouble(_cacheKeyLng, location.longitude);
      await prefs.setInt(
        _cacheKeyTimestamp,
        DateTime.now().millisecondsSinceEpoch,
      );
      debugPrint('âœ… Location cached successfully');
    } catch (e) {
      debugPrint('âŒ Error caching location: $e');
    }
  }

  // Update location in background after returning cached location
  Future<void> _updateLocationInBackground() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      final location = LocationModel(
        latitude: position.latitude,
        longitude: position.longitude,
      );

      await _cacheLocation(location);
      _lastKnownLocation = location;
      debugPrint('âœ… Background location update completed');
    } catch (e) {
      debugPrint('âš ï¸ Background location update failed: $e');
    }
  }

  @override
  Stream<LocationModel> getLocationStream() {
    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 5,
    );

    return Geolocator.getPositionStream(locationSettings: locationSettings).map(
      (position) {
        final location = LocationModel(
          latitude: position.latitude,
          longitude: position.longitude,
        );

        // Cache each location update
        _cacheLocation(location);
        _lastKnownLocation = location;

        return location;
      },
    );
  }

  @override
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  @override
  Future<bool> requestLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      debugPrint('âš ï¸ Location permissions permanently denied');
      return false;
    }

    return permission != LocationPermission.denied;
  }

  // Clear cached location (useful for testing or reset)
  Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_cacheKeyLat);
      await prefs.remove(_cacheKeyLng);
      await prefs.remove(_cacheKeyTimestamp);
      _lastKnownLocation = null;
      debugPrint('âœ… Location cache cleared');
    } catch (e) {
      debugPrint('âŒ Error clearing location cache: $e');
    }
  }
}
