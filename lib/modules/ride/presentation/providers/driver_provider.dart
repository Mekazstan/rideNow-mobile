import 'dart:async';
import 'package:flutter/material.dart';
import 'package:ridenowappsss/modules/ride/data/models/driver_ride_request.dart';
import 'package:ridenowappsss/modules/ride/data/repositories/driver_repository.dart';
import 'package:ridenowappsss/core/services/location_service.dart';
import 'package:ridenowappsss/modules/wallet/data/models/driver_analytics_models.dart';
import 'package:ridenowappsss/modules/ride/data/models/driver_misc_models.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ridenowappsss/modules/ride/data/repositories/places_repository.dart';
import 'package:ridenowappsss/modules/ride/data/models/location_model.dart';
import 'package:ridenowappsss/modules/ride/data/models/ride_api_models.dart';
import 'package:ridenowappsss/core/services/socket_service.dart';
import 'package:ridenowappsss/core/services/service_locator.dart';
import 'package:ridenowappsss/core/services/toast_service.dart';
import 'package:ridenowappsss/modules/ride/data/models/driver_vehicle_model.dart';

class DriverProvider extends ChangeNotifier {
  final DriverRepository _repository;
  final LocationService _locationService;
  final PlacesRepository _placesRepository;

  DriverProvider({
    required DriverRepository repository,
    required LocationService locationService,
    required PlacesRepository placesRepository,
  }) : _repository = repository,
       _locationService = locationService,
       _placesRepository = placesRepository;

  // State
  List<RideRequest> _rideRequests = [];
  bool _isLoading = false;
  bool _isRefreshing = false;
  String? _errorMessage;
  VerificationStatusResponse? _verificationStatus;
  bool _isOnline = false;
  bool _isTogglingStatus = false;
  String? _initialApprovalStatus;

  // Current location for filtering
  String? _currentLocation;
  double? _currentLat;
  double? _currentLon;
  double _radiusKm = 50.0;

  // Ride limits
  int _ridesCompletedToday = 0;
  int _dailyLimit = 20;
  DateTime? _lastSyncTime;

  // Active Ride State
  AcceptRideResponse? _activeRide;
  bool _isArrivedAtPickup = false;
  bool _isRideStarted = false;
  bool _isRideCompleted = false;

  // Map state
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  bool _isLoadingRoute = false;
  List<ChatMessage> _chatMessages = [];
  bool _isShowingAcceptedSuccess = false;
  bool _isLoadingChat = false;

  // Vehicle State
  List<Vehicle> _vehicles = [];
  String? _selectedVehicleId;
  bool _isLoadingVehicles = false;

  // Counter Offer State
  String? _pendingCounterOfferRideId;
  double? _pendingCounterOfferAmount;
  bool _isBooking = false;

  // Getters
  String? get pendingCounterOfferRideId => _pendingCounterOfferRideId;
  double? get pendingCounterOfferAmount => _pendingCounterOfferAmount;
  bool get hasPendingCounterOffer => _pendingCounterOfferRideId != null;
  bool get isBooking => _isBooking;

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
  VerificationStatusResponse? get verificationStatus => _verificationStatus;
  bool get isOnline => _isOnline;
  bool get isTogglingStatus => _isTogglingStatus;

  // Active Ride Getters
  AcceptRideResponse? get activeRide => _activeRide;
  bool get isArrivedAtPickup => _isArrivedAtPickup;
  bool get isRideStarted => _isRideStarted;
  bool get isRideCompleted => _isRideCompleted;
  bool get hasActiveRide => _activeRide != null;

  // Map Getters
  Set<Marker> get markers => _markers;
  Set<Polyline> get polylines => _polylines;
  bool get isLoadingRoute => _isLoadingRoute;
  List<ChatMessage> get chatMessages => _chatMessages;
  bool get isLoadingChat => _isLoadingChat;
  bool get isShowingAcceptedSuccess => _isShowingAcceptedSuccess;
  
  List<Vehicle> get vehicles => _vehicles;
  String? get selectedVehicleId => _selectedVehicleId;
  bool get isLoadingVehicles => _isLoadingVehicles;
  bool get hasVehicles => _vehicles.isNotEmpty;

  // Verification status getters
  bool get isApproved {
    if (_verificationStatus != null) {
      return _verificationStatus!.isFullyVerified;
    }
    return _initialApprovalStatus == 'approved';
  }
  bool get isVerificationStatusLoaded =>
      _verificationStatus != null || _initialApprovalStatus != null;

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

    // Trigger real-time location update via socket if on a ride
    if (_activeRide != null && _isOnline) {
      getIt<SocketService>().emit('driver_location_update', {
        'rideId': _activeRide!.rideDetails!.rideId,
        'lat': lat,
        'lng': lon,
      });
    }

    // Trigger backend sync for auto-promotion and tracking
    syncLocationWithBackend();

    notifyListeners();
  }

  /// Sync current location with backend
  Future<void> syncLocationWithBackend() async {
    if (_currentLat == null || _currentLon == null) return;

    // Throttle: only sync once every 30 seconds to save battery/bandwidth
    final now = DateTime.now();
    if (_lastSyncTime != null &&
        now.difference(_lastSyncTime!) < const Duration(seconds: 30)) {
      return;
    }

    _lastSyncTime = now;
    debugPrint('📡 Syncing location with backend...');

    try {
      final response = await _repository.updateLocation(
        lat: _currentLat!,
        lng: _currentLon!,
        address: _currentLocation,
      );

      if (response['success'] == true) {
        final wasOffline = !_isOnline;
        final backendIsOnline = response['is_online'] as bool? ?? false;

        if (wasOffline && backendIsOnline) {
          debugPrint('🎊 Driver automatically promoted to ONLINE by backend');
          _isOnline = true;
          _setupSocketListeners();
          fetchRideRequests(isRefresh: true);
        } else if (!wasOffline && !backendIsOnline) {
          debugPrint('🔌 Driver set to OFFLINE by backend (likely due to inactivity)');
          _isOnline = false;
          stopAutoRefresh();
        }
      }
      notifyListeners();
    } catch (e) {
      // Periodic sync failures are logged but not shown to UI to avoid annoyance
      debugPrint('⚠️ Silent failure syncing location: $e');
    }
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

    // Only allow fetching ride requests if the driver is online
    if (!_isOnline) {
      _rideRequests = [];
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
        driverLat: currentLat,
        driverLng: currentLon,
        estimatedArrivalMinutes: 5,
      );

      final response = await _repository.acceptRide(request);

      // Remove the accepted ride from the list
      _rideRequests.removeWhere((r) => r.id == rideId);
      _filteredRequests.removeWhere((r) => r.id == rideId);

      // Increment local count
      _ridesCompletedToday++;
      
      _activeRide = response;
      _isArrivedAtPickup = false;
      _isRideStarted = false;
      _isRideCompleted = false;
      
      _setupSocketListeners();

      // Fetch route from driver to pickup
      if (response.rideDetails != null) {
        _updateMarkers(
          pickup: LatLng(response.rideDetails!.pickupLat, response.rideDetails!.pickupLon),
          destination: LatLng(response.rideDetails!.destinationLat, response.rideDetails!.destinationLon),
        );
        fetchRideRoute(
          LatLng(currentLat ?? 0.0, currentLon ?? 0.0),
          LatLng(response.rideDetails!.pickupLat, response.rideDetails!.pickupLon),
        );
      }

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

  /// Send a counter offer for a ride request
  Future<bool> sendCounterOffer(String rideId, double amount) async {
    try {
      debugPrint('🚀 Sending counter offer: $rideId → $amount');
      _isBooking = true;
      notifyListeners();

      await _repository.sendCounterOffer(rideId, amount);
      
      _pendingCounterOfferRideId = rideId;
      _pendingCounterOfferAmount = amount;
      
      // Setup listeners for acceptance
      _setupSocketListeners();

      _isBooking = false;
      notifyListeners();

      debugPrint('✅ Counter offer sent successfully');
      return true;
    } catch (e) {
      _isBooking = false;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      debugPrint('❌ Error sending counter offer: $_errorMessage');
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

  /// Notify that the driver has arrived at the pickup location
  Future<bool> notifyArrival() async {
    if (_activeRide == null) return false;
    
    try {
      debugPrint('🚗 Notifying arrival for ride: ${_activeRide!.rideDetails!.rideId}');
      
      await _repository.notifyArrival(
        _activeRide!.rideDetails!.rideId,
        'pickup',
        _currentLat ?? 0.0,
        _currentLon ?? 0.0,
        _currentLocation ?? '',
      );

      _isArrivedAtPickup = true;
      
      // Update markers: driver is now at pickup
      if (_activeRide?.rideDetails != null) {
        _updateMarkers(
          pickup: LatLng(_activeRide!.rideDetails!.pickupLat, _activeRide!.rideDetails!.pickupLon),
          destination: LatLng(_activeRide!.rideDetails!.destinationLat, _activeRide!.rideDetails!.destinationLon),
          isArrivedAtPickup: true,
        );
        _polylines.clear(); // Clear route to pickup
      }
      
      notifyListeners();
      
      debugPrint('✅ Arrival notified successfully');
      return true;
    } catch (e) {
      debugPrint('❌ Error notifying arrival: $e');
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  /// Start the ride after verifying OTP
  Future<bool> startRide(String otp) async {
    if (_activeRide == null) return false;
    
    try {
      debugPrint('🚗 Starting ride: ${_activeRide!.rideDetails!.rideId} with OTP: $otp');
      
      await _repository.startRide(
        _activeRide!.rideDetails!.rideId,
        otp,
        _currentLat ?? 0.0,
        _currentLon ?? 0.0,
        _currentLocation ?? '',
      );

      _isRideStarted = true;
      
      // Fetch route from pickup to destination
      if (_activeRide?.rideDetails != null) {
        fetchRideRoute(
          LatLng(_activeRide!.rideDetails!.pickupLat, _activeRide!.rideDetails!.pickupLon),
          LatLng(_activeRide!.rideDetails!.destinationLat, _activeRide!.rideDetails!.destinationLon),
        );
      }
      
      notifyListeners();
      
      debugPrint('✅ Ride started successfully');
      return true;
    } catch (e) {
      debugPrint('❌ Error starting ride: $e');
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  /// Complete the ride at destination
  Future<bool> completeRide() async {
    if (_activeRide == null) return false;
    
    try {
      debugPrint('🚗 Completing ride: ${_activeRide!.rideDetails!.rideId}');
      
      await _repository.completeRide(
        _activeRide!.rideDetails!.rideId,
        _currentLat ?? 0.0,
        _currentLon ?? 0.0,
        _currentLocation ?? '',
      );

      _isRideCompleted = true;
      _markers.clear();
      _polylines.clear();
      notifyListeners();
      
      debugPrint('✅ Ride completed successfully');
      return true;
    } catch (e) {
      debugPrint('❌ Error completing ride: $e');
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  /// Reset ride state (used when going back online after completion)
  void resetRideState() {
    _activeRide = null;
    _isArrivedAtPickup = false;
    _isRideStarted = false;
    _isRideCompleted = false;
    _markers.clear();
    _polylines.clear();
    notifyListeners();
    
    if (_isOnline) {
      _setupSocketListeners();
      fetchRideRequests(isRefresh: true);
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
    _setupSocketListeners();
  }

  void _setupSocketListeners() {
    final socketService = getIt<SocketService>();
    debugPrint('🔌 Setting up driver socket listeners');

    // Join driver pool if online
    if (_isOnline) {
      socketService.emit('join_driver_requests', {});
    }

    // Join active ride room if exists
    final activeRideId = _activeRide?.rideDetails?.rideId ?? _activeRide?.rideId;
    if (activeRideId != null) {
      socketService.emit('join_ride_as_driver', {'rideId': activeRideId});
    } else if (_pendingCounterOfferRideId != null) {
      socketService.emit('join_ride_as_driver', {'rideId': _pendingCounterOfferRideId});
    }

    // Ride Status Updates (Crucial for counter offer acceptance)
    socketService.on('ride_status_update', (data) {
      debugPrint('📡 Socket: Ride status updated: $data');
      if (data is Map<String, dynamic> && data['data'] != null) {
        final status = data['data']['status'];
        if (status == 'driver_assigned') {
          debugPrint('🎊 Rider accepted counter offer!');
          
          _isShowingAcceptedSuccess = true;
          notifyListeners();
          
          Future.delayed(const Duration(seconds: 5), () {
            _isShowingAcceptedSuccess = false;
            notifyListeners();
          });

          clearPendingCounterOffer();
          // Re-fetch ride requests and active ride
          fetchRideRequests(isRefresh: true);
          ToastService.showSuccess('A rider accepted your counter offer!');
        }
      }
    });

    // New Ride Requests
    socketService.on('new_ride_request', (data) {
      debugPrint('📡 Socket: New ride request available');
      fetchRideRequests();
    });

    // Counter Offer Declined
    socketService.on('counter_offer_declined', (data) {
      debugPrint('📡 Socket: Counter offer declined by rider: $data');
      ToastService.showInfo('The rider has declined your counter offer.');
      clearPendingCounterOffer();
      fetchRideRequests();
    });

    // Ride Cancellation
    socketService.on('ride_cancelled', (data) {
      debugPrint('📡 Socket: Ride cancelled by rider');
      if (data is Map<String, dynamic>) {
        final canceledRideId = data['ride_id'];
        
        if (canceledRideId == _activeRide?.rideDetails?.rideId) {
          ToastService.showInfo('The rider has cancelled the ride.');
          _activeRide = null;
          notifyListeners();
        } else if (canceledRideId == _pendingCounterOfferRideId) {
          ToastService.showInfo('The rider has cancelled their ride request.');
          clearPendingCounterOffer();
        }
      }
      fetchRideRequests();
    });

    // New Chat Messages
    socketService.on('new_message', (data) {
      debugPrint('📡 Socket: New message received');
      if (_activeRide != null) {
        fetchChatHistory();
      }
    });
  }

  void _cleanupSocketListeners() {
    final socketService = getIt<SocketService>();
    socketService.emit('leave_driver_requests', {});
    final activeRideId = _activeRide?.rideDetails?.rideId ?? _activeRide?.rideId;
    if (activeRideId != null) {
      socketService.emit('leave_ride_as_driver', {'rideId': activeRideId});
    }
    socketService.off('ride_status_update');
    socketService.off('new_ride_request');
    socketService.off('ride_cancelled');
    socketService.off('new_message');
  }

  /// Stop auto-refresh
  void stopAutoRefresh() {
    _cleanupSocketListeners();
  }

  /// Map helpers
  Future<void> fetchRideRoute(LatLng origin, LatLng destination) async {
    _isLoadingRoute = true;
    notifyListeners();

    try {
      final route = await _placesRepository.getRoute(
        origin: origin,
        destination: destination,
      );

      if (route != null) {
        _polylines = {
          Polyline(
            polylineId: const PolylineId('ride_route'),
            points: route.points,
            color: Colors.pink,
            width: 5,
            startCap: Cap.roundCap,
            endCap: Cap.roundCap,
          ),
        };
      }
    } catch (e) {
      debugPrint('❌ Error fetching ride route: $e');
    } finally {
      _isLoadingRoute = false;
      notifyListeners();
    }
  }

  void _updateMarkers({
    required LatLng pickup,
    required LatLng destination,
    bool isArrivedAtPickup = false,
  }) {
    _markers = {
      Marker(
        markerId: const MarkerId('pickup'),
        position: pickup,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        infoWindow: const InfoWindow(title: 'Pickup Location'),
      ),
      Marker(
        markerId: const MarkerId('destination'),
        position: destination,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: const InfoWindow(title: 'Destination'),
      ),
    };
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Clear pending counter offer state
  void clearPendingCounterOffer() {
    _pendingCounterOfferRideId = null;
    _pendingCounterOfferAmount = null;
    notifyListeners();
  }

  Future<void> fetchVerificationStatus() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _repository.getVerificationStatus();
      if (response['success'] == true) {
        _verificationStatus = VerificationStatusResponse.fromJson(response['data']);
        _errorMessage = null; // Clear error if we finally succeed
      }
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      debugPrint('❌ Error fetching verification status: $_errorMessage');
      
      // If we have a bootstrapped status, we don't treat a fetch failure as a fatal error
      // unless we have no data at all.
      if (_initialApprovalStatus != null) {
        debugPrint('ℹ️ Falling back to bootstrapped status: $_initialApprovalStatus');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Refresh ride requests manually
  Future<void> refresh() async {
    debugPrint('🔄 Manual refresh triggered');
    final futures = <Future>[
      fetchRideRequests(isRefresh: true),
      fetchVerificationStatus(),
    ];
    await Future.wait(futures);
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

  /// Toggle online/offline status
  Future<void> toggleOnlineStatus() async {
    if (_isTogglingStatus) return;

    if (!_isOnline) {
      if (!isApproved) {
        _errorMessage = 'You must be fully verified and approved to go online.';
        ToastService.showError(_errorMessage!);
        fetchVerificationStatus(); // Refresh status in case it changed
        return;
      }

      if (_currentLat == null || _currentLon == null || _currentLocation == null) {
        _errorMessage = 'Location not available. Please enable location services.';
        ToastService.showError(_errorMessage!);
        return;
      }

      // Ensure vehicles are loaded
      if (_vehicles.isEmpty) {
        await fetchVehicles();
      }

      if (_vehicles.isEmpty) {
        _errorMessage = 'You must have at least one registered vehicle to go online.';
        ToastService.showError(_errorMessage!);
        return;
      }

      // Default to selected or first verified
      final vehicleToUse = _vehicles.firstWhere(
        (v) => v.id == _selectedVehicleId,
        orElse: () => _vehicles.firstWhere(
          (v) => v.verificationStatus == 'verified' || v.verificationStatus == 'approved',
          orElse: () => _vehicles.first,
        ),
      );

      _isTogglingStatus = true;
      _errorMessage = null;
      notifyListeners();

      try {
        await _repository.goOnline(_currentLat!, _currentLon!, _currentLocation!, vehicleToUse.id);
        _isOnline = true;
        _setupSocketListeners();
        fetchRideRequests(isRefresh: true);
        ToastService.showSuccess('You are now online');
      } catch (e) {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        debugPrint('❌ Error going online: $_errorMessage');
        ToastService.showError(_errorMessage!);
      } finally {
        _isTogglingStatus = false;
        notifyListeners();
      }
    } else {
      _isTogglingStatus = true;
      _errorMessage = null;
      notifyListeners();

      try {
        await _repository.goOffline();
        _isOnline = false;
        _cleanupSocketListeners();
        _rideRequests = [];
        ToastService.showInfo('You are now offline');
      } catch (e) {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        debugPrint('❌ Error going offline: $_errorMessage');
        ToastService.showError(_errorMessage!);
      } finally {
        _isTogglingStatus = false;
        notifyListeners();
      }
    }
  }

  Future<void> fetchVehicles() async {
    _isLoadingVehicles = true;
    notifyListeners();

    try {
      final response = await _repository.getVehicles();
      _vehicles = response.vehicles;
      
      if (_vehicles.isNotEmpty) {
        final active = _vehicles.where((v) => v.isActive).toList();
        if (active.isNotEmpty) {
          _selectedVehicleId = active.first.id;
        } else {
          _selectedVehicleId = _vehicles.first.id;
        }
      }
      
      _isLoadingVehicles = false;
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error fetching vehicles: $e');
      _isLoadingVehicles = false;
      notifyListeners();
    }
  }

  void selectVehicle(String vehicleId) {
    _selectedVehicleId = vehicleId;
    notifyListeners();
  }

  /// Bootstrap provider with initial status from user model
  void initializeFromUser(dynamic user) {
    if (user != null && user.driverApprovalStatus != null) {
      _initialApprovalStatus = user.driverApprovalStatus;
      debugPrint('🚀 DriverProvider initialized from user: $_initialApprovalStatus');
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _cleanupSocketListeners();
    debugPrint('🗑️ DriverProvider disposed');
    super.dispose();
  }

  // CHAT METHODS
  Future<void> fetchChatHistory() async {
    final rideId = _activeRide?.rideDetails?.rideId;
    if (rideId == null) return;

    _isLoadingChat = true;
    notifyListeners();

    try {
      final response = await _placesRepository.getChatHistory(rideId);
      _chatMessages = response.messages;
      _isLoadingChat = false;
      notifyListeners();
    } catch (e) {
      debugPrint('❌ DriverProvider: Error fetching chat: $e');
      _isLoadingChat = false;
      notifyListeners();
    }
  }

  Future<bool> sendMessage(String text) async {
    final rideId = _activeRide?.rideDetails?.rideId;
    if (rideId == null) return false;

    try {
      final response = await _placesRepository.sendMessage(rideId, text);
      if (response.success) {
        await fetchChatHistory();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('❌ DriverProvider: Error sending message: $e');
      return false;
    }
  }
}
