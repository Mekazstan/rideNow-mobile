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
  Timer? _trackingTimer;
  Timer? _offersTimer;
  String? _rideOtp;

  List<PlacePrediction> _pickupSuggestions = [];
  List<PlacePrediction> _destinationSuggestions = [];

  List<AvailableDriver> _availableDrivers = [];
  List<CounterOffer> _counterOffers = [];

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

  Set<Marker> get markers => _markerManager.markers;
  Set<Polyline> get polylines => _polylines;

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
        startTrackingDriver();
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
    if (_driverStatus?.driverLat != null && _driverStatus?.driverLng != null) {
      driverPos = LatLng(_driverStatus!.driverLat!, _driverStatus!.driverLng!);
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

      debugPrint('✅ Ride created successfully: ${response.rideId}');

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
      startTrackingDriver();
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
    _offersTimer?.cancel();
    debugPrint('🔄 Starting offers polling (every 30s)...');
    _offersTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      fetchAvailableDrivers();
      fetchCounterOffers();
    });
  }

  void stopPollingOffers() {
    debugPrint('🛑 Stopping offers polling');
    _offersTimer?.cancel();
    _offersTimer = null;
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
      notifyListeners();
      await fetchRideDetails();

      fitCameraToBounds();

      startTrackingDriver();
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
    debugPrint('🚀 Starting driver tracking...');
    _trackingTimer?.cancel();

    // Immediate check
    _checkDriverStatus();

    // Poll every 10 seconds (or 5)
    _trackingTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _checkDriverStatus();
    });
  }

  Future<void> _checkDriverStatus() async {
    if (_currentRideId == null) return;

    try {
      final statusResponse = await _placesRepository.getDriverStatus(
        _currentRideId!,
      );
      _driverStatus = statusResponse;

      debugPrint(
        '🚕 Driver Status: ${statusResponse.status}, ETA: ${statusResponse.eta}',
      );

      if (statusResponse.status.toLowerCase().contains('way') ||
          statusResponse.status == 'accepted') {
        _rideStage = RideStage.driverOnWay;
      } else if (statusResponse.status.toLowerCase().contains('arrived')) {
        _rideStage = RideStage.driverArrived;
        if (_rideCode == null) {
          _fetchRideCode();
        }
      }

      // Update driver position on map if available
      if (statusResponse.driverLat != null &&
          statusResponse.driverLng != null) {
        await _markerManager.updateDriverMarker(
          LatLng(statusResponse.driverLat!, statusResponse.driverLng!),
          photoUrl: _rideDetails?.driver?.profileImage,
          eta: statusResponse.eta,
        );

        // Fit camera to show rider, driver, and route
        fitCameraToBounds();
      }

      // Schedule notifyListeners after the current frame to avoid setState during build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    } catch (e) {
      debugPrint('⚠️ Error tracking driver: $e');
    }
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
    _trackingTimer?.cancel();
    _trackingTimer = null;
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
    _polylines.clear();
    _markerManager.clearMarkers();
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

  @override
  void dispose() {
    stopTracking();
    stopPollingOffers();
    _placesRepository.cancelPendingRequests();
    super.dispose();
  }
}
