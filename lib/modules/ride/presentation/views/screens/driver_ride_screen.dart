import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:ridenowappsss/core/services/location_service.dart';
import 'package:ridenowappsss/core/services/service_locator.dart';
import 'package:ridenowappsss/core/utils/constants/api_constant.dart';
import 'package:ridenowappsss/modules/ride/presentation/providers/driver_provider.dart';
import 'package:ridenowappsss/modules/ride/presentation/views/widgets/driver_ride_request_bottom_sheet.dart';
import 'package:ridenowappsss/shared/widgets/ride_now_side_menu.dart';
import 'package:ridenowappsss/shared/widgets/app_dialogs.dart';

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
    _initializeDriverLocation();
  }

  Future<void> _initializeDriverLocation() async {
    final locationService = getIt<LocationService>();
    final driverProvider = context.read<DriverProvider>();

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
            builder: (context, provider, child) {
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
                markers:
                    _selectedRide != null
                        ? _buildRideMarkers(_selectedRide)
                        : {},
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
    final markers = <Marker>{};
    return markers;
  }
}
