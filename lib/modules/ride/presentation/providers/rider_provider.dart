import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ridenowappsss/core/services/location_service.dart';
import 'package:ridenowappsss/core/utils/constants/api_constant.dart';
import 'package:ridenowappsss/core/utils/enums/vehicle_type_enum.dart';
import 'package:ridenowappsss/core/utils/helpers/marker_manager.dart';
import 'package:ridenowappsss/modules/ride/data/models/place_prediction.dart';
import 'package:ridenowappsss/modules/ride/data/repositories/places_repository.dart';
import 'package:ridenowappsss/modules/ride/data/models/location_model.dart';
import 'package:ridenowappsss/modules/ride/data/models/available_drvers.dart';
import 'package:ridenowappsss/modules/ride/data/models/ride_request_model.dart';
import 'package:ridenowappsss/modules/ride/data/models/route_model.dart';
import 'dart:async';
import 'package:ridenowappsss/core/storage/ride_persistence.dart';
import 'package:ridenowappsss/modules/ride/data/models/ride_api_models.dart';
import 'package:ridenowappsss/core/services/socket_service.dart';
import 'package:ridenowappsss/core/services/service_locator.dart';

enum RideStage {
  initial,
  selectingPickup,
  selectingDestination,
  confirmingRide,
  searchingDrivers,
  driverOnWay,
  driverArrived,
  inProgress,
  completed,
  cancelled,
}

class RideProvider extends ChangeNotifier {
  final LocationService _locationService;
  final PlacesRepository _placesRepository;
  final MarkerManager _markerManager;

  final RidePersistenceService _persistenceService;

  RideProvider({
    required LocationService locationService,
    required PlacesRepository placesRepository,
    MarkerManager? markerManager,
    required RidePersistenceService persistenceService,
  }) : _locationService = locationService,
       _placesRepository = placesRepository,
       _markerManager = markerManager ?? MarkerManagerImpl(),
       _persistenceService = persistenceService;

  // State
  LocationModel? _currentLocation;
  LocationModel? _pickupLocation;
  LocationModel? _destinationLocation;
  RouteModel? _routeData;
  VehicleType? _selectedVehicleType;
  String? _currentRideId;
  GoogleMapController? _mapController;
  String? _userProfilePhoto;
  RideDetails? _rideDetails;
  String? _bookedDriverName;
  double? _bookedDriverRating;
  String? _bookedDriverPhoto;
  String? _bookedDriverEta;
  String? _bookedCarModel;
  String? _bookedPlateNumber;

  // Tracking
  RideStage _rideStage = RideStage.initial;
  DriverStatusResponse? _driverStatus;
  RideCodeResponse? _rideCode;
  String? _rideOtp;
  bool _isFirstLocationUpdate = true;
  StreamSubscription<LocationModel>? _locationSubscription;

  List<PlacePrediction> _pickupSuggestions = [];
  List<PlacePrediction> _destinationSuggestions = [];

  List<AvailableDriver> _availableDrivers = [];
  List<CounterOffer> _counterOffers = [];
  List<RideHistoryItem> _rideHistory = [];
  List<ChatMessage> _chatMessages = [];

  bool _isInitializing = true;
  bool _isLoadingLocation = true;
  bool _isLoadingRoute = false;
  bool _isLoadingPickupSuggestions = false;
  bool _isLoadingDestinationSuggestions = false;
  bool _showPickupSuggestions = false;
  bool _showDestinationSuggestions = false;
  bool _isCreatingRide = false;
  bool _isLoadingDrivers = false;
  bool _isLoadingOffers = false;
  bool _isRideDetailVisible = true;
  bool _isLoadingChat = false;

  Set<Polyline> _polylines = {};

  // Getters
  LocationModel? get currentLocation => _currentLocation;
  LocationModel? get pickupLocation => _pickupLocation;
  LocationModel? get destinationLocation => _destinationLocation;
  RouteModel? get routeData => _routeData;
  VehicleType? get selectedVehicleType => _selectedVehicleType;
  String? get currentRideId => _currentRideId;
  RideDetails? get rideDetails => _rideDetails;
  String? get userProfilePhoto => _userProfilePhoto;

  bool get isRideDetailVisible => _isRideDetailVisible;
  bool get isRideActive =>
      _rideStage != RideStage.initial &&
      _rideStage != RideStage.completed &&
      _rideStage != RideStage.cancelled;

  RideStage get rideStage => _rideStage;
  DriverStatusResponse? get driverStatus => _driverStatus;
  RideCodeResponse? get rideCode => _rideCode;
  String? get rideOtp => _rideOtp;
  String? get bookedDriverName => _bookedDriverName;
  double? get bookedDriverRating => _bookedDriverRating;
  String? get bookedDriverPhoto => _bookedDriverPhoto;
  String? get bookedDriverEta => _bookedDriverEta;
  String? get bookedCarModel => _bookedCarModel;
  String? get bookedPlateNumber => _bookedPlateNumber;
  String? get activePickupAddress =>
      _pickupLocation?.address ?? _rideDetails?.pickupLocation.address;
  String? get activeDestinationAddress =>
      _destinationLocation?.address ?? _rideDetails?.destination.address;

  List<PlacePrediction> get pickupSuggestions => _pickupSuggestions;
  List<PlacePrediction> get destinationSuggestions => _destinationSuggestions;

  List<AvailableDriver> get availableDrivers => _availableDrivers;
  List<CounterOffer> get counterOffers => _counterOffers;
  List<RideHistoryItem> get rideHistory => _rideHistory;

  bool get isInitializing => _isInitializing;
  bool get isLoadingLocation => _isLoadingLocation;
  bool get isLoadingRoute => _isLoadingRoute;
  bool get isLoadingPickupSuggestions => _isLoadingPickupSuggestions;
  bool get isLoadingDestinationSuggestions => _isLoadingDestinationSuggestions;
  bool get showPickupSuggestions => _showPickupSuggestions;
  bool get showDestinationSuggestions => _showDestinationSuggestions;
  bool get isCreatingRide => _isCreatingRide;
  bool get isLoadingDrivers => _isLoadingDrivers;
  bool get isLoadingOffers => _isLoadingOffers;
  bool get isLoadingChat => _isLoadingChat;
  List<ChatMessage> get chatMessages => _chatMessages;

  Set<Marker> get markers => _markerManager.markers;
  Set<Polyline> get polylines => _polylines;

  // Added flags
  bool _isShowingAcceptedSuccess = false;
  bool get isShowingAcceptedSuccess => _isShowingAcceptedSuccess;

  void setRideDetailVisible(bool visible) {
    if (_isRideDetailVisible == visible) return;
    _isRideDetailVisible = visible;
    notifyListeners();
  }

  bool get canShowRoute =>
      _pickupLocation != null && _destinationLocation != null;

  bool get canCreateRide =>
      _pickupLocation != null &&
      _destinationLocation != null &&
      _selectedVehicleType != null;

  // Initialization
  Future<void> initialize() async {
    _isInitializing = true;
    _isLoadingLocation = true;
    notifyListeners();

    await _loadCurrentLocation(silent: true);
    _startLocationUpdates();

    // Check for persisted state
    final persisted = await _persistenceService.getPersistedState();
    if (persisted != null) {
      debugPrint(
        '[RIDE_RESTORE] Restoring persisted ride: ${persisted.rideId} at stage ${persisted.stage}',
      );

      _currentRideId = persisted.rideId;
      _rideStage = persisted.stage;
      _pickupLocation = persisted.pickup;
      _destinationLocation = persisted.destination;
      _selectedVehicleType = persisted.vehicleType;

      _bookedDriverName = persisted.driverName;
      _bookedDriverRating = persisted.driverRating;
      _bookedDriverPhoto = persisted.driverPhoto;
      _bookedDriverEta = persisted.driverEta;
      _bookedCarModel = persisted.carModel;
      _bookedPlateNumber = persisted.plateNumber;

      // Restore markers and route if possible
      if (_pickupLocation != null && _destinationLocation != null) {
        _markerManager.updatePickupMarker(
          _pickupLocation!,
          profilePhotoUrl: _userProfilePhoto,
        );
        _markerManager.addDestinationMarker(_destinationLocation!);
        await _tryDrawRoute();
      }

      // Resume tracking if needed
      if (_rideStage == RideStage.driverOnWay ||
          _rideStage == RideStage.driverArrived ||
          _rideStage == RideStage.inProgress) {
        _setupSocketListeners();
        fetchRideDetails();
      }
    } else {
      if (_rideStage == RideStage.driverOnWay ||
          _rideStage == RideStage.driverArrived ||
          _rideStage == RideStage.inProgress ||
          _rideStage == RideStage.searchingDrivers) {
        debugPrint('[RIDE_INIT] Warning: Stale booking state detected after login. Resetting.');
        _clearInMemoryState();
        await _loadCurrentLocation();
      }
    }

    _isInitializing = false;
    notifyListeners();

    // Secondary check: Fetch active ride from backend to ensure synchronization
    await restoreActiveRide();
  }

  Future<void> restoreActiveRide() async {
    try {
      final activeRide = await _placesRepository.getActiveRide();
      if (activeRide != null) {
        debugPrint('[RIDE_RESTORE] Active ride found on backend: ${activeRide.id}');
        
        // If we don't have a current ride or it's different, sync with backend
        if (_currentRideId != activeRide.id) {
          _currentRideId = activeRide.id;
          _rideDetails = activeRide;
          
          // Map backend status to UI stage
          _rideStage = _mapApiStatusToStage(activeRide.status);
          
          _pickupLocation = LocationModel(
            latitude: activeRide.pickupLocation.lat,
            longitude: activeRide.pickupLocation.lng,
            address: activeRide.pickupLocation.address,
          );
          
          _destinationLocation = LocationModel(
            latitude: activeRide.destination.lat,
            longitude: activeRide.destination.lng,
            address: activeRide.destination.address,
          );

          if (activeRide.driver != null) {
            _bookedDriverName = activeRide.driver!.name;
            _bookedDriverRating = activeRide.driver!.rating;
            _bookedDriverPhoto = activeRide.driver!.profileImage;
            _bookedDriverEta = '--';
          }

          if (activeRide.vehicle != null) {
            _bookedCarModel = '${activeRide.vehicle!.model} ${activeRide.vehicle!.color}';
            _bookedPlateNumber = activeRide.vehicle!.plateNumber;
          }

          // Restore markers and route
          _markerManager.updatePickupMarker(
            _pickupLocation!,
            profilePhotoUrl: _userProfilePhoto,
          );
          _markerManager.addDestinationMarker(_destinationLocation!);
          await _tryDrawRoute();

          // Resume tracking if needed
          if (isRideActive) {
            _setupSocketListeners();
          }
          
          _persistState();
          notifyListeners();
        }
      } else {
        if (_currentRideId != null) {
          debugPrint('[RIDE_RESTORE] Backend reports no active ride. Resetting local state.');
          reset();
          await _loadCurrentLocation();
        }
      }
    } catch (e) {
      debugPrint('[RIDE_RESTORE] Error restoring active ride: $e');
    }
  }

  RideStage _mapApiStatusToStage(String status) {
    switch (status) {
      case 'searching_driver':
        return RideStage.searchingDrivers;
      case 'driver_assigned':
      case 'driver_en_route':
        return RideStage.driverOnWay;
      case 'arrived':
        return RideStage.driverArrived;
      case 'in_progress':
        return RideStage.inProgress;
      case 'completed':
        return RideStage.completed;
      case 'cancelled':
        return RideStage.cancelled;
      default:
        return RideStage.initial;
    }
  }

  Future<void> fetchRideHistory() async {
    try {
      final response = await _placesRepository.getRiderHistory();
      _rideHistory = response.rides;
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error fetching ride history: $e');
    }
  }

  Future<void> _persistState() async {
    try {
      await _persistenceService.saveRideState(
        rideId: _currentRideId,
        stage: _rideStage,
        pickup: _pickupLocation,
        destination: _destinationLocation,
        vehicleType: _selectedVehicleType,
        driverName: _bookedDriverName,
        driverRating: _bookedDriverRating,
        driverPhoto: _bookedDriverPhoto,
        driverEta: _bookedDriverEta,
        carModel: _bookedCarModel,
        plateNumber: _bookedPlateNumber,
      );
    } catch (e) {
      debugPrint('[RIDE_PERSIST] Warning: Error persisting ride state: $e');
    }
  }

  Future<void> _loadCurrentLocation({bool silent = false}) async {
    if (!silent) {
      _isLoadingLocation = true;
      notifyListeners();
    }

    _currentLocation = await _locationService.getCurrentLocation();
    if (_currentLocation != null) {
      _markerManager.addCurrentLocationMarker(_currentLocation!);

      debugPrint(
        '[LOCATION] Current location loaded: ${_currentLocation?.latitude}, ${_currentLocation?.longitude}',
      );

      // Auto-move camera to current location if map is ready
      _animateCameraToCurrentLocation();

      // PRE-FILL PICKUP LOCATION WITH CURRENT LOCATION
      try {
        final details = await _placesRepository.reverseGeocodeAddress(
          _currentLocation!.latitude,
          _currentLocation!.longitude,
        );

        if (details != null && details.formattedAddress != null) {
          _pickupLocation = LocationModel(
            latitude: _currentLocation!.latitude,
            longitude: _currentLocation!.longitude,
            address: details.formattedAddress!,
          );

          // Update pickup marker with current location as well
          _markerManager.updatePickupMarker(
            _pickupLocation!,
            profilePhotoUrl: _userProfilePhoto,
          );

          debugPrint('[GEOCODING] Default pickup set to: ${_pickupLocation?.address}');
        }
      } catch (e) {
        debugPrint('[GEOCODING] Warning: Error reverse geocoding current location: $e');
      }
    }

    _isLoadingLocation = false;
    if (!silent) {
      notifyListeners();
    }
  }

  Future<bool> checkLocationPermissions() async {
    final enabled = await _locationService.isLocationServiceEnabled();
    if (!enabled) return false;

    final hasPermission = await _locationService.requestLocationPermission();
    return hasPermission;
  }

  // Map Controller & Profile
  CameraPosition? _cameraPosition;
  CameraPosition? get cameraPosition => _cameraPosition;

  void setMapController(GoogleMapController controller) {
    _mapController = controller;
    // Move camera to current location once controller is available
    if (_currentLocation != null) {
      _animateCameraToCurrentLocation();
    }
  }

  void _animateCameraToCurrentLocation() {
    if (_mapController == null || _currentLocation == null) return;
    
    try {
      debugPrint('[MAP] Animate camera to: ${_currentLocation!.latitude}, ${_currentLocation!.longitude}');
      _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(
          _currentLocation!.toLatLng(),
          MapConstants.defaultZoom,
        ),
      );
    } catch (e) {
      debugPrint('[MAP] Error animating camera: $e');
    }
  }

  void onCameraMove(CameraPosition position) {
    _cameraPosition = position;
    // If the user manually moves the map, stop auto-centering on current location
    if (_isFirstLocationUpdate) {
      _isFirstLocationUpdate = false;
      debugPrint('[MAP] User moved camera, auto-center disabled');
    }
  }

  void _startLocationUpdates() {
    _locationSubscription?.cancel();
    _isFirstLocationUpdate = true;
    
    _locationSubscription = _locationService.getLocationStream().listen((location) {
      _currentLocation = location;
      
      // Update the user location marker on the map
      _markerManager.updatePickupMarker(
        location,
        profilePhotoUrl: _userProfilePhoto,
      );

      // Auto-center camera ONLY if it's the first update or we want to follow (during initial load)
      if (_isFirstLocationUpdate) {
        _animateCameraToCurrentLocation();
      }

      notifyListeners();
    }, onError: (error) {
      debugPrint('[LOCATION] Stream error: $error');
    });
  }

  void setUserProfilePhoto(String? photoUrl) {
    if (_userProfilePhoto == photoUrl) return;
    _userProfilePhoto = photoUrl;
    notifyListeners();
  }

  void setRideDetails(RideDetails? details) {
    if (_rideDetails == details) return;
    _rideDetails = details;
    notifyListeners();
  }

  // Vehicle selection
  void setSelectedVehicleType(VehicleType vehicleType) {
    if (_selectedVehicleType == vehicleType) return;
    _selectedVehicleType = vehicleType;
    debugPrint('🚗 Vehicle type selected: ${vehicleType.toApiValue()}');
    notifyListeners();
  }

  // Pickup operations
  Future<void> fetchPickupSuggestions(String input) async {
    if (_shouldSkipSearch(input)) {
      _clearPickupSuggestions();
      return;
    }

    _isLoadingPickupSuggestions = true;
    _showPickupSuggestions = true;
    notifyListeners();

    final suggestions = await _placesRepository.searchPlaces(
      input,
      latitude: _currentLocation?.latitude,
      longitude: _currentLocation?.longitude,
    );

    _updatePickupSuggestions(suggestions);
    _isLoadingPickupSuggestions = false;
    notifyListeners();
  }

  Future<void> selectPickupLocation(PlacePrediction prediction) async {
    debugPrint('🔵 Selecting pickup: ${prediction.description}');

    _clearPickupSuggestions();

    final details = await _placesRepository.getPlaceDetails(prediction.placeId);
    if (details == null) {
      debugPrint('❌ Failed to get place details for pickup');
      return;
    }

    _pickupLocation = LocationModel.fromPlaceDetails(details);

    // Verify the location was properly created
    if (_pickupLocation == null) {
      debugPrint('❌ Failed to create LocationModel from place details');
      return;
    }

    debugPrint('✅ Pickup location set:');
    debugPrint('   Address: ${_pickupLocation?.address}');
    debugPrint('   Lat: ${_pickupLocation?.latitude}');
    debugPrint('   Lng: ${_pickupLocation?.longitude}');

    _markerManager.updatePickupMarker(
      _pickupLocation!,
      profilePhotoUrl: _userProfilePhoto,
    );

    await _tryDrawRoute();
    notifyListeners();
  }

  void showPickupSuggestionsIfAvailable() {
    if (_pickupSuggestions.isNotEmpty) {
      _showPickupSuggestions = true;
      notifyListeners();
    }
  }

  void hidePickupSuggestions() {
    _showPickupSuggestions = false;
    notifyListeners();
  }

  // Destination operations
  Future<void> fetchDestinationSuggestions(String input) async {
    if (_shouldSkipSearch(input)) {
      _clearDestinationSuggestions();
      return;
    }

    _isLoadingDestinationSuggestions = true;
    _showDestinationSuggestions = true;
    notifyListeners();

    final suggestions = await _placesRepository.searchPlaces(
      input,
      latitude: _currentLocation?.latitude,
      longitude: _currentLocation?.longitude,
    );

    _updateDestinationSuggestions(suggestions);
    _isLoadingDestinationSuggestions = false;
    notifyListeners();
  }

  Future<void> selectDestination(PlacePrediction prediction) async {
    debugPrint('🔵 Selecting destination: ${prediction.description}');

    _clearDestinationSuggestions();

    final details = await _placesRepository.getPlaceDetails(prediction.placeId);
    if (details == null) {
      debugPrint('❌ Failed to get place details for destination');
      return;
    }

    _destinationLocation = LocationModel.fromPlaceDetails(details);

    // Verify the location was properly created
    if (_destinationLocation == null) {
      debugPrint('❌ Failed to create LocationModel from place details');
      return;
    }

    debugPrint('✅ Destination location set:');
    debugPrint('   Address: ${_destinationLocation?.address}');
    debugPrint('   Lat: ${_destinationLocation?.latitude}');
    debugPrint('   Lng: ${_destinationLocation?.longitude}');

    _markerManager.addDestinationMarker(_destinationLocation!);

    await _tryDrawRoute();
    notifyListeners();
  }

  Future<void> geocodeAndSelectPickup(String address) async {
    if (address.trim().isEmpty) return;

    debugPrint('🔍 Geocoding pickup address: $address');

    try {
      final details = await _placesRepository.geocodeAddress(address);
      if (details != null) {
        _pickupLocation = LocationModel.fromPlaceDetails(details);

        if (_pickupLocation != null) {
          debugPrint('✅ Pickup geocoded successfully:');
          debugPrint('   Address: ${_pickupLocation?.address}');
          debugPrint('   Lat: ${_pickupLocation?.latitude}');
          debugPrint('   Lng: ${_pickupLocation?.longitude}');

          _markerManager.updatePickupMarker(
            _pickupLocation!,
            profilePhotoUrl: _userProfilePhoto,
          );
          await _tryDrawRoute();
          notifyListeners();
        } else {
          debugPrint('❌ Failed to create pickup location from geocoding');
        }
      } else {
        debugPrint('❌ Geocoding returned null for pickup');
      }
    } catch (e) {
      debugPrint('❌ Error geocoding pickup address: $e');
    }
  }

  Future<void> geocodeAndSelectDestination(String address) async {
    if (address.trim().isEmpty) return;

    debugPrint('🔍 Geocoding destination address: $address');

    try {
      final details = await _placesRepository.geocodeAddress(address);
      if (details != null) {
        _destinationLocation = LocationModel.fromPlaceDetails(details);

        if (_destinationLocation != null) {
          debugPrint('✅ Destination geocoded successfully:');
          debugPrint('   Address: ${_destinationLocation?.address}');
          debugPrint('   Lat: ${_destinationLocation?.latitude}');
          debugPrint('   Lng: ${_destinationLocation?.longitude}');

          _markerManager.addDestinationMarker(_destinationLocation!);
          await _tryDrawRoute();
          notifyListeners();
        } else {
          debugPrint('❌ Failed to create destination location from geocoding');
        }
      } else {
        debugPrint('❌ Geocoding returned null for destination');
      }
    } catch (e) {
      debugPrint('❌ Error geocoding destination address: $e');
    }
  }

  void showDestinationSuggestionsIfAvailable() {
    if (_destinationSuggestions.isNotEmpty) {
      _showDestinationSuggestions = true;
      notifyListeners();
    }
  }

  void hideDestinationSuggestions() {
    _showDestinationSuggestions = false;
    notifyListeners();
  }

  // Route operations
  Future<void> _tryDrawRoute() async {
    if (!canShowRoute) return;

    _isLoadingRoute = true;
    notifyListeners();

    final route = await _placesRepository.getRoute(
      origin: _pickupLocation!.toLatLng(),
      destination: _destinationLocation!.toLatLng(),
    );

    if (route != null) {
      _routeData = route;
      _createPolyline(route.points);
      debugPrint('✅ Route drawn successfully');

      // Auto-fit camera to show the entire route
      fitCameraToBounds();
    } else {
      debugPrint('❌ Failed to get route');
    }

    _isLoadingRoute = false;
    notifyListeners();
  }

  void _createPolyline(List<LatLng> points) {
    _polylines = {
      Polyline(
        polylineId: const PolylineId('route'),
        points: points,
        color: Colors.pink,
        width: MapConstants.polylineWidth,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
      ),
    };
  }

  LatLngBounds? getRouteBounds() {
    if (!canShowRoute) return null;

    final pickup = _pickupLocation!.toLatLng();
    final dest = _destinationLocation!.toLatLng();

    // If tracking driver, include driver position in bounds
    LatLng? driverPos;
    if (_driverStatus != null) {
      driverPos = LatLng(
        _driverStatus!.data.location.latitude,
        _driverStatus!.data.location.longitude,
      );
    }

    // Calculate bounds including all relevant points
    final points = [pickup, dest];
    if (driverPos != null) points.add(driverPos);

    double minLat = points.first.latitude;
    double maxLat = points.first.latitude;
    double minLng = points.first.longitude;
    double maxLng = points.first.longitude;

    for (final point in points) {
      if (point.latitude < minLat) minLat = point.latitude;
      if (point.latitude > maxLat) maxLat = point.latitude;
      if (point.longitude < minLng) minLng = point.longitude;
      if (point.longitude > maxLng) maxLng = point.longitude;
    }

    final latDelta = maxLat - minLat;
    final lngDelta = maxLng - minLng;

    // Ensure we don't have zero deltas
    final paddingRatio = 1.5;
    final latPadding = latDelta > 0 ? latDelta * paddingRatio : 0.02;
    final lngPadding = lngDelta > 0 ? lngDelta * paddingRatio : 0.02;

    return LatLngBounds(
      southwest: LatLng(minLat - latPadding, minLng - lngPadding),
      northeast: LatLng(maxLat + latPadding, maxLng + lngPadding),
    );
  }

  /// Fit camera to show route and all markers
  void fitCameraToBounds() {
    final bounds = getRouteBounds();
    if (bounds != null && _mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLngBounds(bounds, MapConstants.routeBoundsPadding),
      );
    }
  }

  // CREATE RIDE - WITH VALIDATION
  Future<CreateRideResponse> createRide({
    required double fareAmount,
    String paymentMethod = RideConstants.paymentWallet,
  }) async {
    // CRITICAL VALIDATION
    debugPrint('🚗 Attempting to create ride...');
    debugPrint('   Pickup: ${_pickupLocation?.address ?? "NULL"}');
    debugPrint('   Destination: ${_destinationLocation?.address ?? "NULL"}');
    debugPrint('   Vehicle: ${_selectedVehicleType?.toApiValue() ?? "NULL"}');

    if (_pickupLocation == null) {
      debugPrint('❌ VALIDATION FAILED: Pickup location is null');
      throw Exception('Please select a pickup location');
    }

    if (_destinationLocation == null) {
      debugPrint('❌ VALIDATION FAILED: Destination location is null');
      throw Exception('Please select a destination location');
    }

    if (_selectedVehicleType == null) {
      debugPrint('❌ VALIDATION FAILED: Vehicle type is null');
      throw Exception('Please select a vehicle type');
    }

    // Validate coordinates
    if (_pickupLocation!.latitude == 0.0 && _pickupLocation!.longitude == 0.0) {
      debugPrint('❌ VALIDATION FAILED: Pickup coordinates are 0.0');
      throw Exception('Invalid pickup location. Please select again.');
    }

    if (_destinationLocation!.latitude == 0.0 &&
        _destinationLocation!.longitude == 0.0) {
      debugPrint('❌ VALIDATION FAILED: Destination coordinates are 0.0');
      throw Exception('Invalid destination location. Please select again.');
    }

    _isCreatingRide = true;
    notifyListeners();

    try {
      final request = CreateRideRequest(
        pickupLocation: LocationData(
          lat: _pickupLocation!.latitude,
          lng: _pickupLocation!.longitude,
          address: _pickupLocation!.address ?? 'Pickup Location',
        ),
        destination: LocationData(
          lat: _destinationLocation!.latitude,
          lng: _destinationLocation!.longitude,
          address: _destinationLocation!.address ?? 'Destination',
        ),
        vehicleType: _selectedVehicleType!.toApiValue(),
        paymentMethod: paymentMethod,
        fareAmount: fareAmount,
      );

      debugPrint('🚗 Creating ride with validated request:');
      debugPrint(
        '   Pickup: ${request.pickupLocation.address} (${request.pickupLocation.lat}, ${request.pickupLocation.lng})',
      );
      debugPrint(
        '   Destination: ${request.destination.address} (${request.destination.lat}, ${request.destination.lng})',
      );
      debugPrint('   Vehicle: ${request.vehicleType}');
      debugPrint('   Fare: ${request.fareAmount}');

      final response = await _placesRepository.createRide(request);

      // Store the ride ID for fetching drivers/offers
      _currentRideId = response.rideId;
      _rideOtp = response.rideCode; // Cache OTP from ride creation response!

      debugPrint('✅ Ride created successfully: ${response.rideId} with code: ${_rideOtp}');

      _isCreatingRide = false;
      _rideStage = RideStage.searchingDrivers;
      notifyListeners();
      _persistState();

      return response;
    } catch (e) {
      _isCreatingRide = false;
      notifyListeners();

      debugPrint('❌ ViewModel: Error creating ride: $e');
      rethrow;
    }
  }

  // FETCH AVAILABLE DRIVERS
  Future<void> fetchAvailableDrivers() async {
    if (_currentRideId == null) {
      debugPrint('❌ Cannot fetch drivers: No ride ID available');
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _isLoadingDrivers = true;
      notifyListeners();
    });

    try {
      final response = await _placesRepository.getAvailableDrivers(
        _currentRideId!,
      );
      _availableDrivers = response.drivers;

      debugPrint('✅ Loaded ${_availableDrivers.length} available drivers');

      _isLoadingDrivers = false;
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error fetching available drivers: $e');
      _isLoadingDrivers = false;
      notifyListeners();
    }
  }

  // FETCH RIDE DETAILS
  Future<void> fetchRideDetails() async {
    if (_currentRideId == null) return;
    try {
      final details = await _placesRepository.getRideDetails(_currentRideId!);
      
      if (details?.status == 'cancelled') {
        debugPrint('[RIDE_DETAILS] Ride was cancelled by the system. Resetting.');
        reset();
        await _loadCurrentLocation();
        return;
      }
      
      _rideDetails = details;
      notifyListeners();
      debugPrint('✅ Ride details loaded for: $_currentRideId');
    } catch (e) {
      debugPrint('❌ Error fetching ride details: $e');
    }
  }

  // BOOK DRIVER
  Future<void> bookDriver(String driverId, double fare) async {
    if (_currentRideId == null) {
      debugPrint('❌ Cannot book driver: No ride ID available');
      return;
    }

    try {
      await _placesRepository.selectDriver(_currentRideId!, driverId, fare);
      debugPrint('✅ Driver selected: $driverId with fare: $fare');
      AvailableDriver? driver;
      try {
        driver = _availableDrivers.firstWhere((d) => d.driverId == driverId);
      } catch (_) {
        try {
          final offer = _counterOffers.firstWhere(
            (o) => o.driverId == driverId,
          );
          driver = AvailableDriver(
            driverId: offer.driverId,
            driverName: offer.driverName,
            rating: offer.rating,
            ridesCompleted: offer.ridesCompleted,
            estimatedTime: offer.estimatedTime,
            distance: '',
            vehicle: Vehicle(
              type: offer.vehicleType ?? 'Standard',
              make: 'Vehicle',
              color: 'Unknown',
              licensePlate: offer.plateNumber ?? '',
            ),
          );
        } catch (_) {}
      }

      if (driver != null) {
        _bookedDriverName = driver.driverName;
        _bookedDriverRating = driver.rating;
        _bookedDriverPhoto = driver.imageUrl;
        _bookedDriverEta = driver.estimatedTime;
        _bookedCarModel = driver.vehicleMake;
        _bookedPlateNumber = driver.plateNumber;
      }

      // Update stage to driverOnWay immediately
      _rideStage = RideStage.driverOnWay;
      notifyListeners();
      await fetchRideDetails();
      fitCameraToBounds();
      _setupSocketListeners();
      _persistState();
    } catch (e) {
      debugPrint('❌ Error booking driver: $e');
      rethrow;
    }
  }

  // FETCH COUNTER OFFERS
  Future<void> fetchCounterOffers() async {
    if (_currentRideId == null) {
      debugPrint('❌ Cannot fetch offers: No ride ID available');
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _isLoadingOffers = true;
      notifyListeners();
    });

    try {
      final response = await _placesRepository.getCounterOffers(
        _currentRideId!,
      );
      _counterOffers = response.offers;

      debugPrint('✅ Loaded ${_counterOffers.length} counter offers');

      _isLoadingOffers = false;
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error fetching counter offers: $e');
      _isLoadingOffers = false;
      notifyListeners();
    }
  }

  // OFFERS POLLING & ACTIONS
  void startPollingOffers() {
    _setupSocketListeners();
  }

  void stopPollingOffers() {
    debugPrint('🛑 Stopping offers polling');
    _cleanupSocketListeners();
  }

  Future<void> acceptCounterOffer(String offerId) async {
    if (_currentRideId == null) return;
    try {
      await _placesRepository.acceptCounterOffer(_currentRideId!, offerId);

      // Store driver info for immediate display
      final offer = _counterOffers.firstWhere(
        (o) => o.offerId == offerId,
        orElse:
            () => CounterOffer(
              offerId: offerId,
              driverId: '',
              driverName: 'Driver',
              rating: 4.9,
              ridesCompleted: 0,
              proposedFare: 0,
              estimatedTime: '...',
            ),
      );
      _bookedDriverName = offer.driverName;
      _bookedDriverRating = offer.rating;
      _bookedDriverPhoto = offer.imageUrl;
      _bookedDriverEta = offer.estimatedTime;
      _bookedCarModel = offer.vehicleType;
      _bookedPlateNumber = offer.plateNumber;

      _rideStage = RideStage.driverOnWay;
      _isShowingAcceptedSuccess = true;
      notifyListeners();
      
      Future.delayed(const Duration(seconds: 5), () {
        _isShowingAcceptedSuccess = false;
        notifyListeners();
      });

      await fetchRideDetails();

      fitCameraToBounds();

      _setupSocketListeners();
      _persistState();
    } catch (e) {
      debugPrint('❌ Error accepting offer: $e');
      rethrow;
    }
  }

  Future<void> declineCounterOffer(String offerId) async {
    if (_currentRideId == null) return;
    try {
      await _placesRepository.declineCounterOffer(_currentRideId!, offerId);
      debugPrint('✅ Declined offer: $offerId');
      fetchCounterOffers();
    } catch (e) {
      debugPrint('❌ Error declining offer: $e');
      rethrow;
    }
  }

  // Private helpers
  bool _shouldSkipSearch(String input) => input.trim().length < 2;

  void _updatePickupSuggestions(List<PlacePrediction> suggestions) {
    _pickupSuggestions = suggestions;
    _showPickupSuggestions = suggestions.isNotEmpty;
    notifyListeners();
  }

  void _clearPickupSuggestions() {
    _pickupSuggestions = [];
    _showPickupSuggestions = false;
    notifyListeners();
  }

  void _updateDestinationSuggestions(List<PlacePrediction> suggestions) {
    _destinationSuggestions = suggestions;
    _showDestinationSuggestions = suggestions.isNotEmpty;
    notifyListeners();
  }

  void _clearDestinationSuggestions() {
    _destinationSuggestions = [];
    _showDestinationSuggestions = false;
    notifyListeners();
  }

  // TRACKING METHODS
  void startTrackingDriver() {
    _setupSocketListeners();
  }

  void _setupSocketListeners() {
    final socketService = getIt<SocketService>();
    if (_currentRideId == null) return;

    debugPrint('🔌 Setting up socket listeners for ride: $_currentRideId');
    
    // Join ride-specific room
    socketService.emit('join_ride_as_rider', {'rideId': _currentRideId});

    // Ride Status Updates
    socketService.on('ride_status_update', (data) {
      debugPrint('📡 Socket: Ride status updated: $data');
      if (data is Map<String, dynamic> && data['status'] != null) {
        final newStage = _mapApiStatusToStage(data['status']);
        
        if (newStage != _rideStage) {
          _rideStage = newStage;
          notifyListeners();
          fetchRideDetails(); // Refresh details to get latest markers/driver info
          
          if (newStage == RideStage.driverArrived && _rideOtp == null) {
            _fetchRideCode();
          }
        }
      }
    });

    // Driver Location Updates
    socketService.on('driver_location_update', (data) {
      if (data is Map<String, dynamic>) {
        final lat = (data['lat'] as num).toDouble();
        final lng = (data['lng'] as num).toDouble();
        debugPrint('📡 Socket: Driver location: $lat, $lng');
        _markerManager.updateDriverMarker(
          LatLng(lat, lng),
          photoUrl: _rideDetails?.driver?.profileImage,
        );
        notifyListeners();
      }
    });

    // New Counter Offers
    socketService.on('counter_offer_received', (data) {
      debugPrint('📡 Socket: New counter offer received');
      fetchCounterOffers();
    });

    // New Chat Messages
    socketService.on('new_message', (data) {
      debugPrint('📡 Socket: New message received');
      fetchChatHistory();
    });
  }

  void _cleanupSocketListeners() {
    final socketService = getIt<SocketService>();
    if (_currentRideId != null) {
      socketService.emit('leave_ride', {'rideId': _currentRideId});
    }
    socketService.off('ride_status_update');
    socketService.off('driver_location_update');
    socketService.off('new_counter_offer');
    socketService.off('new_message');
  }

  Future<void> _fetchRideCode() async {
    if (_currentRideId == null) return;

    try {
      final codeResponse = await _placesRepository.getRideCode(_currentRideId!);
      _rideCode = codeResponse;
      _rideOtp = codeResponse.code;
      notifyListeners();
    } catch (e) {
      debugPrint('⚠️ Error fetching ride code: $e');
    }
  }

  void stopTracking() {
    _cleanupSocketListeners();
  }

  void _clearInMemoryState() {
    _currentRideId = null;
    _rideStage = RideStage.initial;
    _pickupLocation = null;
    _destinationLocation = null;
    _selectedVehicleType = null;
    _rideDetails = null;
    _driverStatus = null;
    _rideCode = null;
    _rideOtp = null;
    _isShowingAcceptedSuccess = false;
    _polylines.clear();
    _markerManager.clearMarkers();
    _chatMessages.clear();
    stopTracking();
    stopPollingOffers();
  }

  void reset() {
    _clearInMemoryState();
    _persistenceService.clearRideState();
    notifyListeners();
  }

  Future<void> cancelRide() async {
    if (_currentRideId == null) return;
    try {
      await _placesRepository.cancelRide(_currentRideId!);
      reset();
    } catch (e) {
      debugPrint('❌ Error cancelling ride: $e');
      rethrow;
    }
  }

  Future<void> acceptOffer(CounterOffer offer) async {
    if (_currentRideId == null) return;
    try {
      await acceptCounterOffer(offer.offerId);
    } catch (e) {
      debugPrint('❌ Error accepting offer: $e');
      rethrow;
    }
  }

  Future<void> declineOffer(CounterOffer offer) async {
    if (_currentRideId == null) return;
    try {
      await _placesRepository.declineCounterOffer(_currentRideId!, offer.offerId);
      _counterOffers.removeWhere((o) => o.offerId == offer.offerId);
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error declining offer: $e');
      rethrow;
    }
  }

  // CHAT METHODS
  Future<void> fetchChatHistory() async {
    if (_currentRideId == null) return;

    _isLoadingChat = true;
    notifyListeners();

    try {
      final response = await _placesRepository.getChatHistory(_currentRideId!);
      _chatMessages = response.messages;
      _isLoadingChat = false;
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error fetching chat: $e');
      _isLoadingChat = false;
      notifyListeners();
    }
  }

  Future<bool> sendMessage(String text) async {
    if (_currentRideId == null) return false;

    try {
      final response = await _placesRepository.sendMessage(_currentRideId!, text);
      if (response.success) {
        // Optimistically add to list or just refetch
        await fetchChatHistory();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('❌ Error sending message: $e');
      return false;
    }
  }
  @override
  void dispose() {
    stopTracking();
    stopPollingOffers();
    _locationSubscription?.cancel();
    _placesRepository.cancelPendingRequests();
    super.dispose();
  }
}
