import 'dart:async';
import 'package:flutter/material.dart';
import 'package:ridenowappsss/modules/ride/data/models/driver_ride_request.dart';
import 'package:ridenowappsss/modules/ride/data/repositories/driver_repository.dart';
import 'package:ridenowappsss/core/services/location_service.dart';
import 'package:ridenowappsss/modules/wallet/data/models/driver_analytics_models.dart';

class DriverProvider extends ChangeNotifier {
  final DriverRepository _repository;
  final LocationService _locationService;

  DriverProvider({
    required DriverRepository repository,
    required LocationService locationService,
  }) : _repository = repository,
       _locationService = locationService;

  // State
  List<RideRequest> _rideRequests = [];
  bool _isLoading = false;
  bool _isRefreshing = false;
  String? _errorMessage;
  Timer? _autoRefreshTimer;

  // Current location for filtering
  String? _currentLocation;
  double? _currentLat;
  double? _currentLon;
  double _radiusKm = 50.0;

  // Ride limits
  int _ridesCompletedToday = 0;
  int _dailyLimit = 20;

  // Getters
  List<RideRequest> get rideRequests => _rideRequests;
  bool get isLoading => _isLoading;
  bool get isRefreshing => _isRefreshing;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;
  int get requestCount => _rideRequests.length;
  double get radiusKm => _radiusKm;
  String? get currentLocation => _currentLocation;
  double? get currentLat => _currentLat;
  double? get currentLon => _currentLon;
  int get ridesCompletedToday => _ridesCompletedToday;
  int get dailyLimit => _dailyLimit;
  int get ridesRemaining => (_dailyLimit - _ridesCompletedToday).clamp(0, _dailyLimit);

  // Filtered ride requests based on search
  List<RideRequest> _filteredRequests = [];
  List<RideRequest> get filteredRequests =>
      _filteredRequests.isEmpty ? _rideRequests : _filteredRequests;

  /// Initialize with location
  void setLocation({
    required String location,
    required double lat,
    required double lon,
    double? radiusKm,
  }) {
    _currentLocation = location;
    _currentLat = lat;
    _currentLon = lon;
    if (radiusKm != null) {
      _radiusKm = radiusKm;
    }

    debugPrint('🗺️ Location set in ViewModel:');
    debugPrint('   📍 Location: $_currentLocation');
    debugPrint('   📍 Latitude: $_currentLat');
    debugPrint('   📍 Longitude: $_currentLon');
    debugPrint('   📍 Radius: $_radiusKm km');

    notifyListeners();
  }

  /// Fetch ride requests
  Future<void> fetchRideRequests({bool isRefresh = false}) async {
    if (_currentLocation == null ||
        _currentLat == null ||
        _currentLon == null) {
      _errorMessage = 'Location not set. Please enable location services.';
      notifyListeners();
      return;
    }

    // Validate coordinates
    if (!_currentLat!.isFinite || !_currentLon!.isFinite) {
      _errorMessage = 'Invalid location coordinates';
      notifyListeners();
      return;
    }

    if (_currentLat!.abs() < 0.0001 || _currentLon!.abs() < 0.0001) {
      _errorMessage = 'Invalid location coordinates (too close to zero)';
      notifyListeners();
      return;
    }

    if (isRefresh) {
      _isRefreshing = true;
    } else {
      _isLoading = true;
    }
    _errorMessage = null;
    notifyListeners();

    try {
      final query = RideRequestsQuery(
        location: _currentLocation!,
        lat: _currentLat!,
        lon: _currentLon!,
        radiusKm: _radiusKm,
      );

      // Debug output
      debugPrint('');
      debugPrint('🚗 ==========================================');
      debugPrint('🚗 Fetching ride requests with:');
      debugPrint('   📍 Location: $_currentLocation');
      debugPrint('   📍 Latitude: $_currentLat');
      debugPrint('   📍 Longitude: $_currentLon');
      debugPrint('   📍 Radius: ${_radiusKm}km');
      debugPrint('🚗 ==========================================');
      debugPrint('');

      // Fetch requests and status in parallel
      final results = await Future.wait([
        _repository.getRideRequests(query),
        _repository.getDriverStatus(),
      ]);

      final response = results[0] as RideRequestsResponse;
      final status = results[1] as DailyLimitStatus;

      _rideRequests = response.rideRequests;
      _ridesCompletedToday = status.completed;
      _dailyLimit = status.limit;
      _filteredRequests = [];

      debugPrint('✅ Successfully loaded ${_rideRequests.length} ride requests');
      if (_rideRequests.isNotEmpty) {
        final firstRide = _rideRequests.first;
        debugPrint('📋 Sample ride request:');
        debugPrint('   🆔 ID: ${firstRide.rideId}');
        debugPrint('   👤 Rider: ${firstRide.riderName}');
        debugPrint('   📍 From: ${firstRide.pickupLocationName}');
        debugPrint('   🏁 To: ${firstRide.destinationLocation}');
        debugPrint('   💰 Fare: ${firstRide.getFormattedFare()}');
        debugPrint('   📏 Distance: ${firstRide.distance}');
      }
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      debugPrint('❌ Error fetching ride requests: $_errorMessage');
      debugPrint('Full error: $e');
    } finally {
      _isLoading = false;
      _isRefreshing = false;
      notifyListeners();
    }
  }

  Future<bool> checkLocationPermissions() async {
    final enabled = await _locationService.isLocationServiceEnabled();
    if (!enabled) return false;

    final hasPermission = await _locationService.requestLocationPermission();
    return hasPermission;
  }

  /// Search/filter ride requests by location or rider name
  void searchRideRequests(String query) {
    if (query.trim().isEmpty) {
      _filteredRequests = [];
      notifyListeners();
      return;
    }

    final lowerQuery = query.toLowerCase();
    _filteredRequests =
        _rideRequests.where((request) {
          // Search in pickup location
          final pickupMatch =
              request.pickupLocationName.toLowerCase().contains(lowerQuery) ||
              request.pickupAddress.toLowerCase().contains(lowerQuery);

          // Search in destination
          final destinationMatch =
              request.destinationLocation.toLowerCase().contains(lowerQuery) ||
              request.destinationAddress.toLowerCase().contains(lowerQuery);

          // Search in rider name
          final riderMatch = request.riderName.toLowerCase().contains(
            lowerQuery,
          );

          return pickupMatch || destinationMatch || riderMatch;
        }).toList();

    debugPrint(
      '🔍 Search results: ${_filteredRequests.length} rides found for "$query"',
    );
    notifyListeners();
  }

  /// Accept a ride request
  Future<bool> acceptRide(String rideId, {double? proposedFare}) async {
    try {
      debugPrint('🚗 Attempting to accept ride: $rideId');

      final request = AcceptRideRequest(
        rideId: rideId,
        proposedFare: proposedFare,
      );

      final response = await _repository.acceptRide(request);

      // Remove the accepted ride from the list
      _rideRequests.removeWhere((r) => r.id == rideId);
      _filteredRequests.removeWhere((r) => r.id == rideId);

      // Increment local count
      _ridesCompletedToday++;

      notifyListeners();

      debugPrint('✅ Ride accepted successfully: ${response.message}');
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      debugPrint('❌ Error accepting ride: $_errorMessage');
      debugPrint('Full error: $e');
      notifyListeners();
      return false;
    }
  }

  /// Reject a ride request
  Future<bool> rejectRide(String rideId) async {
    try {
      debugPrint('🚗 Attempting to reject ride: $rideId');

      await _repository.rejectRide(rideId);

      // Remove the rejected ride from the list
      _rideRequests.removeWhere((r) => r.id == rideId);
      _filteredRequests.removeWhere((r) => r.id == rideId);

      notifyListeners();

      debugPrint('✅ Ride rejected successfully');
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      debugPrint('❌ Error rejecting ride: $_errorMessage');
      debugPrint('Full error: $e');
      notifyListeners();
      return false;
    }
  }

  /// Update search radius and optionally refetch
  void updateRadius(double radiusKm, {bool refetch = false}) {
    if (radiusKm < 1.0 || radiusKm > 100.0) {
      debugPrint('⚠️ Invalid radius: $radiusKm. Must be between 1 and 100 km');
      return;
    }

    _radiusKm = radiusKm;
    debugPrint('📍 Search radius updated to: $_radiusKm km');
    notifyListeners();

    if (refetch) {
      fetchRideRequests(isRefresh: true);
    }
  }

  /// Start auto-refresh (refresh every 30 seconds by default)
  void startAutoRefresh({Duration interval = const Duration(seconds: 30)}) {
    stopAutoRefresh();

    debugPrint('🔄 Auto-refresh started (interval: ${interval.inSeconds}s)');

    _autoRefreshTimer = Timer.periodic(interval, (_) {
      debugPrint('🔄 Auto-refreshing ride requests...');
      fetchRideRequests(isRefresh: true);
    });
  }

  /// Stop auto-refresh
  void stopAutoRefresh() {
    if (_autoRefreshTimer != null) {
      _autoRefreshTimer?.cancel();
      _autoRefreshTimer = null;
      debugPrint('🔄 Auto-refresh stopped');
    }
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Refresh ride requests manually
  Future<void> refresh() async {
    debugPrint('🔄 Manual refresh triggered');
    await fetchRideRequests(isRefresh: true);
  }

  /// Reset all filters
  void resetFilters() {
    _filteredRequests = [];
    notifyListeners();
  }

  /// Check if location is set
  bool get hasLocation =>
      _currentLocation != null && _currentLat != null && _currentLon != null;

  /// Get location summary
  String getLocationSummary() {
    if (!hasLocation) return 'Location not set';
    return '$_currentLocation (${_currentLat!.toStringAsFixed(4)}, ${_currentLon!.toStringAsFixed(4)})';
  }

  @override
  void dispose() {
    stopAutoRefresh();
    debugPrint('🗑️ DriverProvider disposed');
    super.dispose();
  }
}
