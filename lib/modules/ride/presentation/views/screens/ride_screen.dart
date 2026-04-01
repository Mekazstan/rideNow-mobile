// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ridenowappsss/modules/ride/presentation/views/screens/chat_screen.dart';
import 'package:ridenowappsss/modules/ride/presentation/views/screens/rating_screen.dart';
import 'package:ridenowappsss/core/utils/constants/api_constant.dart';
import 'package:ridenowappsss/core/utils/enums/vehicle_type_enum.dart';
import 'package:ridenowappsss/core/utils/extensions/app_color_extension.dart';
import 'package:ridenowappsss/core/utils/extensions/app_font_extension.dart';
import 'package:go_router/go_router.dart';
import 'package:ridenowappsss/modules/ride/data/models/place_prediction.dart';
import 'package:ridenowappsss/modules/ride/presentation/views/widgets/location_input_section.dart';
import 'package:ridenowappsss/modules/ride/presentation/views/widgets/ride_map_view.dart';
import 'package:ridenowappsss/modules/ride/presentation/views/widgets/vehicle_selection_sheet.dart';
import 'package:ridenowappsss/modules/ride/presentation/providers/rider_provider.dart';
import 'package:ridenowappsss/shared/widgets/ride_now_side_menu.dart';
import 'package:ridenowappsss/modules/ride/presentation/views/widgets/driver_on_way_sheet.dart';
import 'package:ridenowappsss/modules/ride/presentation/views/widgets/driver_arrived_sheet.dart';
import 'package:ridenowappsss/modules/ride/presentation/views/widgets/trip_in_progress_sheet.dart';
import 'package:ridenowappsss/modules/ride/presentation/views/widgets/trip_arrived_sheet.dart';
import 'package:ridenowappsss/shared/widgets/app_dialogs.dart';
import 'package:ridenowappsss/core/services/toast_service.dart';
import 'package:ridenowappsss/modules/authentication/presentation/providers/auth_provider.dart';
import 'package:ridenowappsss/modules/ride/presentation/providers/driver_provider.dart';
import 'package:ridenowappsss/shared/widgets/glowing_online_toggle.dart';
import 'package:ridenowappsss/core/navigation/route_constant.dart';
import 'package:ridenowappsss/modules/wallet/presentation/providers/wallet_provider.dart';
import 'package:ridenowappsss/modules/community/presentation/providers/community_provider.dart';
import 'package:ridenowappsss/modules/accounts/presentation/providers/subscription_plan_provider.dart';
import 'package:ridenowappsss/modules/ride/presentation/views/widgets/drivers_offers_bottom_sheet.dart';
import 'package:ridenowappsss/modules/ride/data/models/available_drvers.dart';

class RideScreen extends StatefulWidget {
  const RideScreen({super.key});

  @override
  State<RideScreen> createState() => _RideScreenState();
}

class _RideScreenState extends State<RideScreen> with WidgetsBindingObserver {
  late final TextEditingController _pickupController;
  late final TextEditingController _destinationController;
  late final FocusNode _pickupFocusNode;
  late final FocusNode _destinationFocusNode;

  GoogleMapController? _mapController;
  VehicleType? _selectedVehicleType;
  bool _isVehicleSelectionVisible = false;
  bool _isBottomSheetVisible = false;
  // Saved reference so we can safely use it in dispose() without a BuildContext.
  late final RideProvider _rideProvider;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _initializeFocusNodes();
    _initializeViewModel();
    _eagerLoadData();
    WidgetsBinding.instance.addObserver(this);
  }

  /// Proactively fetches data for other screens to ensure smooth navigation
  void _eagerLoadData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      
      // Warm up data for other modules
      context.read<WalletProvider>().initializeWallet();
      context.read<CommunityProvider>().fetchSharedRides();
      context.read<SubscriptionProvider>().fetchSubscriptionPlans();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      final driverProvider = context.read<DriverProvider>();
      if (driverProvider.isOnline) {
        debugPrint('📱 App backgrounded: going offline automatically');
        driverProvider.toggleOnlineStatus();
      }
    }
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
      _rideProvider = context.read<RideProvider>();
      final provider = _rideProvider;

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

    // Sync Pickup Controller
    if (!_pickupFocusNode.hasFocus &&
        provider.pickupLocation != null &&
        provider.pickupLocation!.address != null) {
      if (_pickupController.text != provider.pickupLocation!.address) {
        _pickupController.text = provider.pickupLocation!.address!;
      }
    }

    // Sync Destination Controller
    if (!_destinationFocusNode.hasFocus &&
        provider.destinationLocation != null &&
        provider.destinationLocation!.address != null) {
      if (_destinationController.text != provider.destinationLocation!.address) {
        _destinationController.text = provider.destinationLocation!.address!;
      }
    }

    // Restore Vehicle Selection if route exists and we are not in booked/searching state
    if (provider.canShowRoute &&
        provider.rideStage == RideStage.initial &&
        !_isVehicleSelectionVisible) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _checkAndShowVehicleSelection();
        }
      });
    }

    debugPrint('🔄 Ride stage changed to: ${provider.rideStage}');

    // Auto-show searching UI if we just entered searching state
    if (provider.rideStage == RideStage.searchingDrivers &&
        provider.isRideDetailVisible &&
        !_isBottomSheetVisible) {
      _showActiveRideDetails();
    }
  }

  void _showActiveRideDetails() async {
    if (_isBottomSheetVisible) return;

    final provider = context.read<RideProvider>();
    provider.setRideDetailVisible(true);

    if (provider.rideStage == RideStage.searchingDrivers) {
      setState(() => _isBottomSheetVisible = true);
      await DriverOffersBottomSheet.show(
        context,
        rideViewModel: provider,
        onBookDriver: (driver) async {
          final fare = provider.rideDetails?.fareAmount ?? 0.0;
          await provider.bookDriver(driver.driverId, fare);
        },
        onAcceptOffer: (offer) {
          provider.acceptOffer(offer);
        },
        onDeclineOffer: (offer) {
          provider.declineOffer(offer);
        },
      );

      if (mounted) {
        setState(() => _isBottomSheetVisible = false);
      }
    }
  }

  void _handleCall() async {
    final driverPhone = _viewModel.rideDetails?.driver?.phoneNumber;
    if (driverPhone != null && driverPhone.isNotEmpty) {
      final url = Uri.parse('tel:$driverPhone');
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      } else {
        ToastService.showError('Could not launch dialer');
      }
    } else {
      ToastService.showError('Driver phone number not available');
    }
  }

  void _handleChat() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ChatScreen()),
    );
  }

  Future<void> _handleCancelRide() async {
    try {
      await context.read<RideProvider>().cancelRide();
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ToastService.showError('Failed to cancel ride: $e');
      }
    }
  }

  @override
  void dispose() {
    // Use the saved reference – never call context.read() inside dispose().
    _rideProvider.removeListener(_onRideStageChanged);
    _disposeControllers();
    _disposeFocusNodes();
    _mapController?.dispose();
    WidgetsBinding.instance.removeObserver(this);
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

  RideProvider get _viewModel => _rideProvider;

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    // Redundant: ViewModel.setMapController already handles initial centering.
    /*
    final location = _viewModel.currentLocation;
    if (location != null) {
      _animateCamera(location.toLatLng(), MapConstants.defaultZoom);
    }
    */
  }

  void _animateCamera(LatLng target, double zoom) {
    try {
      _mapController?.animateCamera(CameraUpdate.newLatLngZoom(target, zoom));
    } catch (e) {
      debugPrint('[MAP] Widget animation error: $e');
    }
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
      setState(() {
        _isVehicleSelectionVisible = true;
      });
    }
  }

  void _handleTopUp() {
    context.pushNamed(RouteConstants.wallet);
  }

  void _fitRouteBounds() {
    final bounds = _viewModel.getRouteBounds();
    if (bounds != null && _mapController != null) {
      try {
        _mapController!.animateCamera(
          CameraUpdate.newLatLngBounds(bounds, MapConstants.routeBoundsPadding),
        );
      } catch (e) {
        debugPrint('[MAP] Bounds animation error: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final isDriver = authProvider.user?.userType.toLowerCase() == 'driver';
    final isVerified = authProvider.user?.verificationStatus.toLowerCase() == 'verified';

    return Consumer<RideProvider>(
      builder: (context, viewModel, _) {
        final isBooked =
            viewModel.rideStage == RideStage.driverOnWay ||
            viewModel.rideStage == RideStage.driverArrived ||
            viewModel.rideStage == RideStage.inProgress ||
            viewModel.rideStage == RideStage.completed;

        return Scaffold(
          drawer: const RideNowSideMenu(),
          body: SafeArea(
            bottom: false,
            child: Stack(
              children: [
                Positioned.fill(child: MapSection(onMapCreated: _onMapCreated)),

                // Driver Online Toggle
                if (isDriver && isVerified)
                  Positioned(
                    top: 10.h,
                    right: 20.w,
                    child: Consumer<DriverProvider>(
                      builder: (context, driverProvider, child) {
                        return GlowingOnlineToggle(
                          isOnline: driverProvider.isOnline,
                          isLoading: driverProvider.isTogglingStatus,
                          onToggle: () => driverProvider.toggleOnlineStatus(),
                        );
                      },
                    ),
                  ),

                if (isBooked || _isVehicleSelectionVisible)
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

                if (!isBooked && !_isVehicleSelectionVisible)
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

                if (_isVehicleSelectionVisible && !isBooked)
                  VehicleSelectionSheet(
                    destination: _destinationController.text,
                    pickup: _pickupController.text,
                    onVehicleSelected: (VehicleType vehicleType) {
                      _selectedVehicleType = vehicleType;
                      _viewModel.setSelectedVehicleType(vehicleType);
                    },
                    onTopUp: _handleTopUp,
                    onDismiss: () {
                      setState(() {
                        _isVehicleSelectionVisible = false;
                      });
                    },
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
                      eta: viewModel.driverStatus?.data.etaMinutes != null
                          ? '${viewModel.driverStatus!.data.etaMinutes} mins'
                          : viewModel.bookedDriverEta,
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

                // Trip In Progress Sheet
                if (viewModel.rideStage == RideStage.inProgress)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: TripInProgressSheet(
                      rideDetails: viewModel.rideDetails,
                      pickupAddress: viewModel.activePickupAddress,
                      destinationAddress: viewModel.activeDestinationAddress,
                      vehicleInfo: viewModel.selectedVehicleType?.displayName,
                      driverNameOverride: viewModel.bookedDriverName,
                      driverRatingOverride: viewModel.bookedDriverRating,
                      driverPhotoOverride: viewModel.bookedDriverPhoto,
                      carModel: viewModel.bookedCarModel,
                      plateNumber: viewModel.bookedPlateNumber,
                      onCancel: _handleCancelRide,
                    ),
                  ),

                // Trip Completed Sheet (Arrived)
                if (viewModel.rideStage == RideStage.completed)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: TripArrivedSheet(
                      onRateDriver: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const RatingScreen()),
                        );
                      },
                      onBookAnother: () {
                        viewModel.reset();
                      },
                    ),
                  ),

                // Floating Active Ride Card (when detail is hidden)
                if (viewModel.isRideActive && !viewModel.isRideDetailVisible)
                  Positioned(
                    bottom: 20.h,
                    left: 20.w,
                    right: 20.w,
                    child: _ActiveRideFloatingCard(
                      stage: viewModel.rideStage,
                      onTap: () {
                        viewModel.setRideDetailVisible(true);
                        _showActiveRideDetails();
                      },
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

class _ActiveRideFloatingCard extends StatelessWidget {
  final RideStage stage;
  final VoidCallback onTap;

  const _ActiveRideFloatingCard({required this.stage, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorExtension>()!;
    final appFonts = Theme.of(context).extension<AppFontThemeExtension>()!;

    String title = 'Active Ride';
    String status = 'In Progress';
    IconData icon = Icons.local_taxi;

    switch (stage) {
      case RideStage.searchingDrivers:
        title = 'Finding Drivers';
        status = 'Tap to view offers';
        icon = Icons.search;
        break;
      case RideStage.driverOnWay:
        title = 'Driver is coming';
        status = 'Tap to see details';
        icon = Icons.directions_car;
        break;
      case RideStage.driverArrived:
        title = 'Driver has arrived!';
        status = 'Tap to meet driver';
        icon = Icons.location_on;
        break;
      case RideStage.inProgress:
        title = 'Trip In Progress';
        status = 'On your way...';
        icon = Icons.map;
        break;
      default:
        break;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
          border: Border.all(color: appColors.blue500.withOpacity(0.3), width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: appColors.blue50,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: appColors.blue600, size: 24.sp),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: appFonts.textBaseMedium.copyWith(
                      fontWeight: FontWeight.w700,
                      color: appColors.textPrimary,
                    ),
                  ),
                  Text(
                    status,
                    style: appFonts.textSmRegular.copyWith(
                      color: appColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: appColors.gray400),
          ],
        ),
      ),
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
