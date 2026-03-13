// ignore_for_file: deprecated_member_use

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:ridenowappsss/core/utils/constants/api_constant.dart';
import 'package:ridenowappsss/core/utils/extensions/app_color_extension.dart';
import 'package:ridenowappsss/core/utils/extensions/app_font_extension.dart';
import 'package:ridenowappsss/modules/authentication/presentation/providers/auth_provider.dart';
import 'package:ridenowappsss/modules/ride/data/models/location_model.dart';
import 'package:ridenowappsss/modules/ride/presentation/providers/rider_provider.dart';
import 'package:ridenowappsss/modules/ride/presentation/views/widgets/ride_screen_shimmer.dart';
import 'package:ridenowappsss/shared/widgets/navigation_button.dart';

class MapSection extends StatefulWidget {
  final Function(GoogleMapController) onMapCreated;

  const MapSection({super.key, required this.onMapCreated});

  @override
  State<MapSection> createState() => _MapSectionState();
}

class _MapSectionState extends State<MapSection> {
  GoogleMapController? _controller;

  // Clean map style - minimal customization
  static const String _mapStyle = '''
[
  {
    "featureType": "poi.business",
    "stylers": [
      {
        "visibility": "off"
      }
    ]
  }
]
''';

  @override
  Widget build(BuildContext context) {
    return Consumer<RideProvider>(
      builder: (context, viewModel, _) {
        // Show shimmer while loading location
        if (viewModel.isLoadingLocation) {
          return const MapSectionShimmer();
        }

        return Stack(
          children: [
            _GoogleMapView(
              viewModel: viewModel,
              onMapCreated: (controller) {
                _controller = controller;

                // Apply custom map style
                try {
                  controller.setMapStyle(_mapStyle);
                } catch (e) {
                  debugPrint('Error setting map style: $e');
                }

                // Set map controller in view model
                viewModel.setMapController(controller);

                widget.onMapCreated(controller);
              },
            ),
            if (viewModel.rideStage != RideStage.driverOnWay &&
                viewModel.rideStage != RideStage.driverArrived)
              const _MapTopBar(),

            // Show route shimmer when drawing route
            if (viewModel.isLoadingRoute)
              const Positioned(
                bottom: 100,
                left: 0,
                right: 0,
                child: RouteShimmer(),
              ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}

class _GoogleMapView extends StatefulWidget {
  final RideProvider viewModel;
  final Function(GoogleMapController) onMapCreated;

  const _GoogleMapView({required this.viewModel, required this.onMapCreated});

  @override
  State<_GoogleMapView> createState() => _GoogleMapViewState();
}

class _GoogleMapViewState extends State<_GoogleMapView> {
  @override
  void initState() {
    super.initState();
    // Set user profile photo when map initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final authProvider = context.read<AuthProvider>();
        final profilePhoto = authProvider.user?.profilePhoto;
        widget.viewModel.setUserProfilePhoto(profilePhoto);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final profilePhoto = authProvider.user?.profilePhoto;
    if (widget.viewModel.rideDetails == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.viewModel.setUserProfilePhoto(profilePhoto);
      });
    }

    return GoogleMap(
      onMapCreated: (controller) async {
        widget.onMapCreated(controller);
        widget.viewModel.setUserProfilePhoto(profilePhoto);
      },
      initialCameraPosition: CameraPosition(
        target:
            widget.viewModel.currentLocation?.toLatLng() ??
            LocationModel.defaultLocation().toLatLng(),
        zoom: MapConstants.defaultZoom,
      ),
      markers: widget.viewModel.markers,
      polylines: widget.viewModel.polylines,
      myLocationEnabled: false,
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
      mapToolbarEnabled: false,
      compassEnabled: false,
      buildingsEnabled: true,
      trafficEnabled: false,
      indoorViewEnabled: false,
      liteModeEnabled: false,
      tiltGesturesEnabled: true,
      rotateGesturesEnabled: true,
      scrollGesturesEnabled: true,
      zoomGesturesEnabled: true,
      onCameraMove: (position) {
        widget.viewModel.onCameraMove(position);
      },
      minMaxZoomPreference: const MinMaxZoomPreference(
        MapConstants.minZoom,
        MapConstants.maxZoom,
      ),
      gestureRecognizers: _buildGestureRecognizers(),
      mapType: MapType.normal,
      cameraTargetBounds: CameraTargetBounds.unbounded,
      padding: EdgeInsets.only(bottom: 50.h),
    );
  }

  Set<Factory<OneSequenceGestureRecognizer>> _buildGestureRecognizers() {
    return {
      Factory<PanGestureRecognizer>(() => PanGestureRecognizer()),
      Factory<ScaleGestureRecognizer>(() => ScaleGestureRecognizer()),
      Factory<TapGestureRecognizer>(() => TapGestureRecognizer()),
      Factory<VerticalDragGestureRecognizer>(
        () => VerticalDragGestureRecognizer(),
      ),
      Factory<HorizontalDragGestureRecognizer>(
        () => HorizontalDragGestureRecognizer(),
      ),
    };
  }
}

class _MapTopBar extends StatelessWidget {
  const _MapTopBar();

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 15.h,
      left: 20.w,
      right: 20.w,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          NavigationButton(
            appColors: Theme.of(context).extension<AppColorExtension>()!,
          ),
          const _RideModeToggle(),
        ],
      ),
    );
  }
}

class _RideModeToggle extends StatelessWidget {
  const _RideModeToggle();

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorExtension>();
    final appFonts = Theme.of(context).extension<AppFontThemeExtension>();

    return Container(
      height: 40.h,
      width: 120.w,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.r),
        color: appColors?.gray100 ?? Colors.grey[200],
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        children: [
          SvgPicture.asset(
            'assets/cars.svg',
            height: 16.h,
            colorFilter: ColorFilter.mode(
              appColors?.textPrimary ?? Colors.black,
              BlendMode.srcIn,
            ),
          ),
          SizedBox(width: 4.w),
          Text(
            'Ride',
            style: (appFonts?.textSmMedium ??
                    TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold))
                .copyWith(
                  color: appColors?.textPrimary ?? Colors.black,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                ),
          ),
          SizedBox(width: 4.w),
          Container(
            height: 13.h,
            width: 1.w,
            color: appColors?.pink500 ?? Colors.pink,
          ),
          SizedBox(width: 4.w),
          Image.asset('assets/food2.png', height: 16.h),
        ],
      ),
    );
  }
}
