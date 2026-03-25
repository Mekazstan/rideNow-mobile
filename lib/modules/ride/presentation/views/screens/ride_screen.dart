// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ridenowappsss/core/utils/constants/api_constant.dart';
import 'package:ridenowappsss/core/utils/enums/vehicle_type_enum.dart';
import 'package:ridenowappsss/core/utils/extensions/app_color_extension.dart';
import 'package:ridenowappsss/core/utils/extensions/app_font_extension.dart';
import 'package:ridenowappsss/modules/ride/data/models/place_prediction.dart';
import 'package:ridenowappsss/modules/ride/presentation/views/widgets/location_input_section.dart';
import 'package:ridenowappsss/modules/ride/presentation/views/widgets/ride_map_view.dart';
import 'package:ridenowappsss/modules/ride/presentation/views/widgets/vehicle_selection_sheet.dart';
import 'package:ridenowappsss/modules/ride/presentation/providers/rider_provider.dart';
import 'package:ridenowappsss/shared/widgets/ride_now_side_menu.dart';
import 'package:ridenowappsss/modules/ride/presentation/views/widgets/driver_on_way_sheet.dart';
import 'package:ridenowappsss/modules/ride/presentation/views/widgets/driver_arrived_sheet.dart';
import 'package:ridenowappsss/shared/widgets/app_dialogs.dart';

class RideScreen extends StatefulWidget {
  const RideScreen({super.key});

  @override
  State<RideScreen> createState() => _RideScreenState();
}

class _RideScreenState extends State<RideScreen> {
  late final TextEditingController _pickupController;
  late final TextEditingController _destinationController;
  late final FocusNode _pickupFocusNode;
  late final FocusNode _destinationFocusNode;

  GoogleMapController? _mapController;

  VehicleType? _selectedVehicleType;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _initializeFocusNodes();
    _initializeViewModel();
  }

  void _initializeControllers() {
    _pickupController =
        TextEditingController()..addListener(_onPickupTextChanged);
    _destinationController =
        TextEditingController()..addListener(_onDestinationTextChanged);
  }

  void _initializeFocusNodes() {
    _pickupFocusNode = FocusNode()..addListener(_onPickupFocusChanged);
    _destinationFocusNode =
        FocusNode()..addListener(_onDestinationFocusChanged);
  }

  void _initializeViewModel() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final provider = context.read<RideProvider>();

      // Check permissions and show prompt if needed
      final hasPermission = await provider.checkLocationPermissions();
      if (!hasPermission && mounted) {
        LocationPermissionDialog.show(
          context,
          onEnable: () async {
            await provider.initialize();
          },
        );
      } else {
        await provider.initialize();
      }

      if (mounted) {
        provider.addListener(_onRideStageChanged);
        // Initial check in case it loaded extremely fast
        _onRideStageChanged();
      }
    });
  }

  void _onRideStageChanged() {
    if (!mounted) return;

    final provider = context.read<RideProvider>();

    if (!_pickupFocusNode.hasFocus &&
        provider.pickupLocation != null &&
        provider.pickupLocation!.address != null) {
      if (_pickupController.text != provider.pickupLocation!.address) {
        _pickupController.text = provider.pickupLocation!.address!;
      }
    }

    debugPrint('🔄 Ride stage changed to: ${provider.rideStage}');
  }

  void _handleCall() {
    debugPrint('Calling driver...');
  }

  void _handleChat() {
    debugPrint('Opening chat...');
  }

  Future<void> _handleCancelRide() async {
    try {
      await context.read<RideProvider>().cancelRide();
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to cancel ride: $e')));
      }
    }
  }

  @override
  void dispose() {
    context.read<RideProvider>().removeListener(_onRideStageChanged);
    _disposeControllers();
    _disposeFocusNodes();
    _mapController?.dispose();
    super.dispose();
  }

  void _disposeControllers() {
    _pickupController.dispose();
    _destinationController.dispose();
  }

  void _disposeFocusNodes() {
    _pickupFocusNode.dispose();
    _destinationFocusNode.dispose();
  }

  void _onPickupTextChanged() {
    if (_pickupFocusNode.hasFocus) {
      _viewModel.fetchPickupSuggestions(_pickupController.text);
    }
  }

  void _onDestinationTextChanged() {
    if (_destinationFocusNode.hasFocus) {
      _viewModel.fetchDestinationSuggestions(_destinationController.text);
    }
  }

  void _onPickupFocusChanged() {
    if (_pickupFocusNode.hasFocus) {
      _viewModel.showPickupSuggestionsIfAvailable();
    } else {
      _hideWithDelay(() => _viewModel.hidePickupSuggestions());
    }
  }

  void _onDestinationFocusChanged() {
    if (_destinationFocusNode.hasFocus) {
      _viewModel.showDestinationSuggestionsIfAvailable();
    } else {
      _hideWithDelay(() => _viewModel.hideDestinationSuggestions());
    }
  }

  void _hideWithDelay(VoidCallback callback) {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) callback();
    });
  }

  RideProvider get _viewModel => context.read<RideProvider>();

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    final location = _viewModel.currentLocation;
    if (location != null) {
      _animateCamera(location.toLatLng(), MapConstants.defaultZoom);
    }
  }

  void _animateCamera(LatLng target, double zoom) {
    _mapController?.animateCamera(CameraUpdate.newLatLngZoom(target, zoom));
  }

  Future<void> _handlePickupSelection(PlacePrediction prediction) async {
    _pickupController.text = prediction.description;
    _pickupFocusNode.unfocus();
    await _viewModel.selectPickupLocation(prediction);
    _checkAndShowVehicleSelection();
  }

  Future<void> _handleDestinationSelection(PlacePrediction prediction) async {
    _destinationController.text = prediction.description;
    _destinationFocusNode.unfocus();
    await _viewModel.selectDestination(prediction);
    _checkAndShowVehicleSelection();
  }

  void _checkAndShowVehicleSelection() {
    if (_viewModel.canShowRoute) {
      _fitRouteBounds();
      VehicleSelectionSheet.show(
        context,
        destination: _destinationController.text,
        pickup: _pickupController.text,
        onVehicleSelected: (VehicleType vehicleType) {
          _selectedVehicleType = vehicleType;
          _viewModel.setSelectedVehicleType(vehicleType);
        },
        onTopUp: _handleTopUp,
      );
    }
  }

  void _handleTopUp() {
    debugPrint('Navigating to top-up screen');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Opening wallet top-up...'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _fitRouteBounds() {
    final bounds = _viewModel.getRouteBounds();
    if (bounds != null) {
      _mapController?.animateCamera(
        CameraUpdate.newLatLngBounds(bounds, MapConstants.routeBoundsPadding),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RideProvider>(
      builder: (context, viewModel, _) {
        final isBooked =
            viewModel.rideStage == RideStage.driverOnWay ||
            viewModel.rideStage == RideStage.driverArrived;

        return Scaffold(
          drawer: const RideNowSideMenu(),
          body: SafeArea(
            bottom: false,
            child: Stack(
              children: [
                Positioned.fill(child: MapSection(onMapCreated: _onMapCreated)),

                if (isBooked)
                  Positioned(
                    top: 15.h,
                    left: 20.w,
                    right: 20.w,
                    child: _TripOverviewHeader(
                      pickup: viewModel.pickupLocation?.address ?? 'Pickup',
                      destination:
                          viewModel.destinationLocation?.address ??
                          'Destination',
                    ),
                  ),

                if (!isBooked)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: LocationInputSection(
                      pickupController: _pickupController,
                      destinationController: _destinationController,
                      pickupFocusNode: _pickupFocusNode,
                      destinationFocusNode: _destinationFocusNode,
                      onPickupSelected: _handlePickupSelection,
                      onDestinationSelected: _handleDestinationSelection,
                    ),
                  ),

                // Driver on Way Sheet
                if (viewModel.rideStage == RideStage.driverOnWay)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: DriverOnWaySheet(
                      rideDetails: viewModel.rideDetails,
                      pickupAddress: viewModel.activePickupAddress,
                      destinationAddress: viewModel.activeDestinationAddress,
                      vehicleInfo: viewModel.selectedVehicleType?.displayName,
                      driverNameOverride: viewModel.bookedDriverName,
                      driverRatingOverride: viewModel.bookedDriverRating,
                      driverPhotoOverride: viewModel.bookedDriverPhoto,
                      carModel: viewModel.bookedCarModel,
                      plateNumber: viewModel.bookedPlateNumber,
                      eta:
                          viewModel.driverStatus?.eta ??
                          viewModel.bookedDriverEta,
                      onCall: _handleCall,
                      onChat: _handleChat,
                      onCancel: _handleCancelRide,
                    ),
                  ),

                // Driver Arrived Sheet
                if (viewModel.rideStage == RideStage.driverArrived)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: DriverArrivedSheet(
                      rideDetails: viewModel.rideDetails,
                      rideCode: viewModel.rideOtp ?? '0000',
                      driverNameOverride: viewModel.bookedDriverName,
                      driverRatingOverride: viewModel.bookedDriverRating,
                      driverPhotoOverride: viewModel.bookedDriverPhoto,
                      onCall: _handleCall,
                      onChat: _handleChat,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _TripOverviewHeader extends StatelessWidget {
  final String pickup;
  final String destination;

  const _TripOverviewHeader({required this.pickup, required this.destination});

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorExtension>()!;
    final appFonts = Theme.of(context).extension<AppFontThemeExtension>()!;

    return Column(
      children: [
        _buildIndicator(
          context,
          pickup,
          isPickup: true,
          appColors: appColors,
          appFonts: appFonts,
        ),
        SizedBox(height: 10.h),
        _buildIndicator(
          context,
          destination,
          isPickup: false,
          appColors: appColors,
          appFonts: appFonts,
        ),
      ],
    );
  }

  Widget _buildIndicator(
    BuildContext context,
    String address, {
    required bool isPickup,
    required AppColorExtension appColors,
    required AppFontThemeExtension appFonts,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            isPickup ? Icons.search : Icons.location_on_outlined,
            size: 18,
            color: appColors.gray400,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              address,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: appFonts.textSmMedium.copyWith(
                color: appColors.textPrimary,
                fontSize: 14.sp,
              ),
            ),
          ),
          Icon(Icons.close, size: 18, color: appColors.gray300),
        ],
      ),
    );
  }
}
