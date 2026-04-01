import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:ridenowappsss/core/services/location_service.dart';
import 'package:ridenowappsss/core/services/service_locator.dart';
import 'package:ridenowappsss/core/utils/constants/api_constant.dart';
import 'package:ridenowappsss/modules/ride/presentation/providers/driver_provider.dart';
import 'package:ridenowappsss/modules/ride/presentation/views/widgets/driver_ride_request_bottom_sheet.dart';
import 'package:ridenowappsss/modules/ride/presentation/views/widgets/active_ride_bottom_sheet.dart';
import 'package:ridenowappsss/shared/widgets/ride_now_side_menu.dart';
import 'package:ridenowappsss/modules/authentication/presentation/providers/auth_provider.dart';
import 'package:ridenowappsss/shared/widgets/app_dialogs.dart';
import 'package:ridenowappsss/modules/wallet/presentation/providers/wallet_provider.dart';
import 'package:ridenowappsss/modules/community/presentation/providers/community_provider.dart';
import 'package:ridenowappsss/modules/accounts/presentation/providers/subscription_plan_provider.dart';

class RideScreenDriver extends StatefulWidget {
  const RideScreenDriver({super.key});

  @override
  State<RideScreenDriver> createState() => _RideScreenDriverState();
}

class _RideScreenDriverState extends State<RideScreenDriver> {
  GoogleMapController? _mapController;
  dynamic _selectedRide;

  @override
  void initState() {
    super.initState();
    _eagerLoadData();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeDriverLocation();
    });
  }

  /// Proactively fetches data for other screens to ensure smooth navigation
  void _eagerLoadData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      
      // Warm up data for other modules
      context.read<WalletProvider>().initializeWallet();
      context.read<SubscriptionProvider>().fetchSubscriptionPlans();
      context.read<CommunityProvider>().fetchSharedRides();
    });
  }

  Future<void> _initializeDriverLocation() async {
    final locationService = getIt<LocationService>();
    final driverProvider = context.read<DriverProvider>();
    final authProvider = context.read<AuthProvider>();

    // Bootstrap driver provider with initial status from user profile
    driverProvider.initializeFromUser(authProvider.user);

    try {
      final hasPermission = await driverProvider.checkLocationPermissions();
      if (!hasPermission && mounted) {
        LocationPermissionDialog.show(
          context,
          onEnable: () async {
            await _initializeDriverLocation();
          },
        );
        return;
      }

      final location = await locationService.getCurrentLocation();
      if (!mounted) return;
      
      driverProvider.setLocation(
        location: location.address ?? "Unknown Location",
        lat: location.latitude,
        lon: location.longitude,
      );

      driverProvider.fetchVerificationStatus();
      driverProvider.fetchRideRequests();

      if (_mapController != null) {
        _animateCamera(
          LatLng(location.latitude, location.longitude),
          MapConstants.defaultZoom,
        );
      }
    } catch (e) {
      debugPrint('Error initializing driver location: $e');
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    final provider = context.read<DriverProvider>();
    if (provider.hasLocation) {
      _animateCamera(
        LatLng(provider.currentLat!, provider.currentLon!),
        MapConstants.defaultZoom,
      );
    }
  }

  void _animateCamera(LatLng target, double zoom) {
    _mapController?.animateCamera(CameraUpdate.newLatLngZoom(target, zoom));
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const RideNowSideMenu(),
      body: Stack(
        children: [
          Consumer<DriverProvider>(
            builder: (context, provider, _) {
              // Auto-fit camera when markers change
              if (provider.hasActiveRide && provider.markers.isNotEmpty) {
                 WidgetsBinding.instance.addPostFrameCallback((_) {
                   _fitCameraToMarkers(provider.markers);
                 });
              }

              return GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: LatLng(
                    provider.currentLat ?? MapConstants.defaultLatitude,
                    provider.currentLon ?? MapConstants.defaultLongitude,
                  ),
                  zoom: MapConstants.defaultZoom,
                ),
                onMapCreated: _onMapCreated,
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
                markers: provider.hasActiveRide ? provider.markers : (_selectedRide != null ? _buildRideMarkers(_selectedRide) : {}),
                polylines: provider.hasActiveRide ? provider.polylines : {},
              );
            },
          ),
          Positioned(
            top: 50.h,
            left: 20.w,
            child: Builder(
              builder:
                  (context) => CircleAvatar(
                    backgroundColor: Colors.white,
                    child: IconButton(
                      icon: const Icon(Icons.menu, color: Colors.black),
                      onPressed: () => Scaffold.of(context).openDrawer(),
                    ),
                  ),
            ),
          ),

          // Bottom Sheet
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Consumer<DriverProvider>(
              builder: (context, provider, child) {
                if (provider.hasActiveRide) {
                  return const ActiveRideBottomSheet();
                }

                return RideRequestBottomSheet(
                  currentLocationName:
                      provider.currentLocation ?? "Calculating...",
                  selectedRide: _selectedRide,
                  onRefresh: _initializeDriverLocation,
                  onRideSelected: (ride) {
                    setState(() {
                      _selectedRide = ride;
                    });
                  },
                  onBackToList: () {
                    setState(() {
                      _selectedRide = null;
                    });
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Set<Marker> _buildRideMarkers(dynamic ride) {
    if (ride == null) return {};
    
    return {
      Marker(
        markerId: MarkerId('selected_pickup_${ride.id}'),
        position: LatLng(ride.pickupLat, ride.pickupLon),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      ),
      Marker(
        markerId: MarkerId('selected_destination_${ride.id}'),
        position: LatLng(ride.destinationLat, ride.destinationLon),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ),
    };
  }

  void _fitCameraToMarkers(Set<Marker> markers) {
    if (markers.isEmpty || _mapController == null) return;

    double? minLat, maxLat, minLng, maxLng;

    for (final marker in markers) {
      if (minLat == null || marker.position.latitude < minLat) minLat = marker.position.latitude;
      if (maxLat == null || marker.position.latitude > maxLat) maxLat = marker.position.latitude;
      if (minLng == null || marker.position.longitude < minLng) minLng = marker.position.longitude;
      if (maxLng == null || marker.position.longitude > maxLng) maxLng = marker.position.longitude;
    }
    
    // Also include current driver location in bounds
    final provider = context.read<DriverProvider>();
    if (provider.currentLat != null && provider.currentLon != null) {
      if (provider.currentLat! < minLat!) minLat = provider.currentLat!;
      if (provider.currentLat! > maxLat!) maxLat = provider.currentLat!;
      if (provider.currentLon! < minLng!) minLng = provider.currentLon!;
      if (provider.currentLon! > maxLng!) maxLng = provider.currentLon!;
    }

    final bounds = LatLngBounds(
      southwest: LatLng(minLat!, minLng!),
      northeast: LatLng(maxLat!, maxLng!),
    );

    _mapController?.animateCamera(CameraUpdate.newLatLngBounds(bounds, 100.h));
  }
}
