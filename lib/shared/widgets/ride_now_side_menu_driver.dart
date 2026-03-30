// ignore_for_file: deprecated_member_use, use_build_context_synchronously, unrelated_type_equality_checks

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:ridenowappsss/core/navigation/route_constant.dart';
import 'package:ridenowappsss/core/utils/extensions/app_color_extension.dart';
import 'package:ridenowappsss/core/utils/extensions/app_font_extension.dart';
import 'package:ridenowappsss/modules/authentication/data/models/auth_models.dart';
import 'package:ridenowappsss/modules/authentication/presentation/providers/auth_provider.dart';
import 'package:ridenowappsss/shared/widgets/shimmer_widget.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ridenowappsss/shared/widgets/switch_role_modal.dart';
import 'package:geolocator/geolocator.dart';
import 'package:ridenowappsss/modules/ride/data/repositories/places_repository.dart';
import 'package:ridenowappsss/core/services/service_locator.dart';
import 'package:ridenowappsss/core/utils/constants/api_constant.dart';
import 'package:ridenowappsss/core/services/toast_service.dart';

class RideNowSideMenuDriver extends StatefulWidget {
  const RideNowSideMenuDriver({super.key});

  @override
  State<RideNowSideMenuDriver> createState() => _RideNowSideMenuDriverState();
}

class _RideNowSideMenuDriverState extends State<RideNowSideMenuDriver> {
  bool _isLoadingProfile = true;
  bool _isLoggingOut = false;
  GoogleMapController? _mapController;
  LatLng? _currentPosition;
  bool _isLoadingLocation = true;
  final Set<Marker> _markers = {};
  String _currentLocationName = 'Locating...';

  static const LatLng _defaultLocation = LatLng(6.3350, 5.6037);

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  /// Gets current location or falls back to default
  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _setDefaultLocation();
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _setDefaultLocation();
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _setDefaultLocation();
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      if (mounted) {
        setState(() {
          _currentPosition = LatLng(position.latitude, position.longitude);
          _isLoadingLocation = false;
          _addMarker(_currentPosition!);
        });
        _getLocationName(position.latitude, position.longitude);
      }
    } catch (e) {
      _setDefaultLocation();
    }
  }

  void _setDefaultLocation() {
    if (mounted) {
      setState(() {
        _currentPosition = _defaultLocation;
        _isLoadingLocation = false;
        _addMarker(_defaultLocation);
      });
    }
  }

  Future<void> _getLocationName(double latitude, double longitude) async {
    try {
      final placesRepo = getIt<PlacesRepository>();
      final details = await placesRepo.reverseGeocodeAddress(latitude, longitude);
      if (mounted && details != null && details.formattedAddress != null) {
        setState(() {
          _currentLocationName = details.formattedAddress!;
        });
      }
    } catch (e) {
      debugPrint('Error getting location name: $e');
    }
  }

  void _addMarker(LatLng position) {
    setState(() {
      _markers.add(
        Marker(
          markerId: const MarkerId('driver_location'),
          position: position,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          infoWindow: const InfoWindow(title: 'Your Location'),
        ),
      );
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    if (_currentPosition != null) {
      controller.animateCamera(
        CameraUpdate.newLatLngZoom(_currentPosition!, 15),
      );
    }
  }

  /// Fetches user profile from auth provider
  Future<void> _loadUserProfile() async {
    final authProvider = context.read<AuthProvider>();
    await authProvider.fetchProfile();
    if (mounted) {
      setState(() => _isLoadingProfile = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorExtension>()!;
    final appFonts = Theme.of(context).extension<AppFontThemeExtension>()!;
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;

    return Drawer(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 54.h),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_isLoadingProfile)
                  _buildProfileShimmer(appColors)
                else
                  _buildProfileContent(appColors, appFonts, user),
                const Spacer(),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: SvgPicture.asset('assets/close.svg'),
                ),
              ],
            ),
            SizedBox(height: 41.h),
            Text(
              'Your current location',
              style: appFonts.textSmMedium.copyWith(
                color: appColors.textPrimary,
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              _currentLocationName,
              style: appFonts.textSmMedium.copyWith(
                color: appColors.textPrimary,
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 6.h),
            Container(
              height: 187.h,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: appColors.gray200, width: 1),
              ),
              clipBehavior: Clip.antiAlias,
              child:
                  _isLoadingLocation
                      ? const ShimmerBox(borderRadius: 12)
                      : GoogleMap(
                        onMapCreated: _onMapCreated,
                        initialCameraPosition: CameraPosition(
                          target: _currentPosition ?? _defaultLocation,
                          zoom: 15,
                        ),
                        markers: _markers,
                        myLocationEnabled: false,
                        myLocationButtonEnabled: false,
                        zoomControlsEnabled: false,
                        mapToolbarEnabled: false,
                        compassEnabled: false,
                        scrollGesturesEnabled: false,
                        zoomGesturesEnabled: false,
                        tiltGesturesEnabled: false,
                        rotateGesturesEnabled: false,
                        mapType: MapType.normal,
                      ),
            ),
            SizedBox(height: 10.h),
            Expanded(
              child: ListView(
                children: [
                  MenuTile(
                    icon: 'assets/car.svg',
                    title: 'Find a rider',
                    onTap: () {
                      Navigator.pop(context);
                      context.goNamed(RouteConstants.ride);
                    },
                  ),
                  Divider(color: appColors.gray200),
                  ExpandableMenuTile(
                    icon: 'assets/wallet.svg',
                    title: 'Payouts and plans',
                    subItems: [
                      SubMenuItem(
                        title: 'Wallet',
                        onTap: () {
                          Navigator.pop(context);
                          context.goNamed(RouteConstants.wallet);
                        },
                      ),
                      SubMenuItem(
                        title: 'Analytics',
                        onTap: () {
                          Navigator.pop(context);
                          context.goNamed(RouteConstants.analytics);
                        },
                      ),
                      SubMenuItem(
                        title: 'Plans',
                        onTap: () {
                          Navigator.pop(context);
                          context.goNamed(RouteConstants.plans);
                        },
                      ),
                    ],
                  ),
                  Divider(color: appColors.gray200),
                  ExpandableMenuTile(
                    icon: 'assets/userPin.svg',
                    title: 'Switch accounts',
                    subItems: [
                      SubMenuItem(
                        title: 'Rider',
                        onTap: () => _showSwitchRoleModal('rider'),
                        hasCheckmark: (user?.currentRole ?? user?.userType)?.toLowerCase() == 'rider',
                      ),
                      SubMenuItem(
                        title: 'Driver',
                        onTap: () => _showSwitchRoleModal('driver'),
                        hasCheckmark: (user?.currentRole ?? user?.userType)?.toLowerCase() == 'driver',
                      ),
                      // SubMenuItem(
                      //   title: 'Vendor',
                      //   onTap: () => _handleSwitchAccount('vendor'),
                      //   hasCheckmark: user?.userType.toLowerCase() == 'vendor',
                      //   subtitle:
                      //       user?.userType.toLowerCase() == 'vendor' &&
                      //               user?.verificationStatus != true
                      //           ? 'Pending verification'
                      //           : null,
                      // ),
                    ],
                  ),
                  Divider(color: appColors.gray200),
                  MenuTile(
                    icon: 'assets/settings.svg',
                    title: 'Settings',
                    onTap: () {
                      Navigator.pop(context);
                      context.goNamed(RouteConstants.accounts);
                    },
                  ),
                  Divider(color: appColors.gray200),
                  _isLoggingOut
                      ? Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 20.h,
                        ),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 20.w,
                              height: 20.h,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  appColors.blue500,
                                ),
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Text(
                              'Logging out...',
                              style: appFonts.textSmMedium.copyWith(
                                color: appColors.textPrimary,
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      )
                      : MenuTile(
                        icon: 'assets/logout.svg',
                        title: 'Log out',
                        onTap: _handleLogout,
                      ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds shimmer placeholder for profile section
  Widget _buildProfileShimmer(AppColorExtension appColors) {
    return Row(
      children: [
        AvatarShimmer(size: 48.w),
        SizedBox(width: 8.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ShimmerBox(width: 120.w, height: 16.h, borderRadius: 4.r),
            SizedBox(height: 6.h),
            ShimmerBox(width: 80.w, height: 12.h, borderRadius: 4.r),
          ],
        ),
      ],
    );
  }

  /// Builds actual profile content with user data
  Widget _buildProfileContent(
    AppColorExtension appColors,
    AppFontThemeExtension appFonts,
    User? user,
  ) {
    return Row(
      children: [
        Container(
          height: 48.h,
          width: 48.w,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: appColors.gray200,
          ),
          child:
              user?.profilePhoto != null
                  ? ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Image.network(
                      user!.profilePhoto!,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (_, __, ___) => Image.asset('assets/user.png'),
                    ),
                  )
                  : Image.asset('assets/user.png'),
        ),
        SizedBox(width: 8.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${user?.firstName ?? 'User'} ${user?.lastName ?? ''}',
              style: appFonts.textSmMedium.copyWith(
                color: appColors.textPrimary,
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 6.h),
            Row(
              children: [
                SvgPicture.asset(
                  'assets/verify.svg',
                  colorFilter: ColorFilter.mode(
                    user?.verificationStatus?.toLowerCase() == 'verified'
                        ? appColors.pink300
                        : appColors.gray400.withOpacity(0.5),
                    BlendMode.srcIn,
                  ),
                ),
                SizedBox(width: 6.w),
                Text(
                  user?.verificationStatus?.toLowerCase() == 'verified'
                      ? 'Verified'
                      : 'Unverified',
                  style: appFonts.textSmMedium.copyWith(
                    color:
                        user?.verificationStatus?.toLowerCase() == 'verified'
                            ? appColors.pink300
                            : appColors.gray400,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _handleLogout() async {
    final appColors = Theme.of(context).extension<AppColorExtension>()!;

    // Step 1: Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false, // Prevent dismissing by tapping outside
      builder:
          (dialogContext) => AlertDialog(
            title: const Text('Logout'),
            content: const Text('Are you sure you want to logout?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                style: TextButton.styleFrom(foregroundColor: appColors.red500),
                child: const Text('Logout'),
              ),
            ],
          ),
    );

    // User cancelled
    if (confirmed != true) {
      debugPrint('Logout cancelled by user');
      return;
    }

    // Step 2: Show loading state
    if (!mounted) return;
    setState(() => _isLoggingOut = true);

    debugPrint('=== LOGOUT INITIATED FROM UI ===');

    try {
      final authProvider = context.read<AuthProvider>();

      // Step 3: Perform logout
      await authProvider.logout();

      debugPrint('âœ… Logout completed from AuthProvider');

      // Step 4: Close drawer
      if (!mounted) return;
      Navigator.of(context).pop(); // Close the drawer

      // Small delay to ensure drawer closes
      await Future.delayed(const Duration(milliseconds: 200));

      // Step 5: Navigate to login screen
      if (!mounted) return;

      debugPrint('ðŸš€ Navigating to login screen');
      context.go('/login'); // Use go instead of goNamed to clear stack

      // Step 6: Show success message
      await Future.delayed(const Duration(milliseconds: 300));

      if (!mounted) return;
      ToastService.showSuccess('Logged out successfully');

      debugPrint('=== LOGOUT FLOW COMPLETED ===');
    } catch (e) {
      debugPrint('âŒ Logout error: $e');

      if (!mounted) return;

      setState(() => _isLoggingOut = false);

      ToastService.showError('Logout failed: ${e.toString()}');
    }
  }

  void _showSwitchRoleModal(String targetRole) {
    final authProvider = context.read<AuthProvider>();
    final userRole = (authProvider.user?.currentRole ?? authProvider.user?.userType ?? 'driver').toLowerCase();

    if (userRole == targetRole.toLowerCase()) {
      _showAlreadyInRoleModal(targetRole);
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SwitchRoleModal(targetRole: targetRole),
    );
  }

  void _showAlreadyInRoleModal(String role) {
    final appColors = Theme.of(context).extension<AppColorExtension>()!;
    final appFonts = Theme.of(context).extension<AppFontThemeExtension>()!;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: Text(
          'Account Switch',
          style: appFonts.textSmMedium.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 18.sp,
          ),
        ),
        content: Text(
          'You are already a ${role.toLowerCase()}.',
          style: appFonts.textSmMedium.copyWith(
            color: appColors.textSecondary,
            fontSize: 16.sp,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'OK',
              style: TextStyle(
                color: appColors.pink600,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Single menu item tile
class MenuTile extends StatelessWidget {
  final String icon;
  final String title;
  final VoidCallback onTap;

  const MenuTile({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorExtension>()!;
    final appFonts = Theme.of(context).extension<AppFontThemeExtension>()!;

    return Container(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
          child: Row(
            children: [
              SvgPicture.asset(
                icon,
                height: 20.h,
                width: 20.w,
                color: appColors.blue500,
              ),
              SizedBox(width: 12.w),
              Text(
                title,
                style: appFonts.textSmMedium.copyWith(
                  color: appColors.textPrimary,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Expandable menu tile with sub-items
class ExpandableMenuTile extends StatefulWidget {
  final String icon;
  final String title;
  final List<SubMenuItem> subItems;
  final bool initiallyExpanded;

  const ExpandableMenuTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subItems,
    this.initiallyExpanded = false,
  });

  @override
  State<ExpandableMenuTile> createState() => _ExpandableMenuTileState();
}

class _ExpandableMenuTileState extends State<ExpandableMenuTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    if (_isExpanded) {
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// Toggles expansion state
  void _toggle() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorExtension>()!;
    final appFonts = Theme.of(context).extension<AppFontThemeExtension>()!;

    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(vertical: 8.h),
          child: InkWell(
            onTap: _toggle,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
              child: Row(
                children: [
                  SvgPicture.asset(
                    widget.icon,
                    height: 20.h,
                    width: 20.w,
                    color: appColors.blue500,
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      widget.title,
                      style: appFonts.textSmMedium.copyWith(
                        color: appColors.textPrimary,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: _isExpanded ? 0.0 : -0.5,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      color: appColors.blue500,
                      size: 20.sp,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SizeTransition(
          sizeFactor: _animation,
          child:
              widget.subItems.isNotEmpty
                  ? Container(
                    padding: EdgeInsets.only(left: 44.w),
                    child: Column(
                      children:
                          widget.subItems.map((subItem) {
                            return Container(
                              padding: EdgeInsets.symmetric(vertical: 4.h),
                              child: InkWell(
                                onTap: subItem.onTap,
                                borderRadius: BorderRadius.circular(8),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12.w,
                                    vertical: 12.h,
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              subItem.title,
                                              style: appFonts.textSmMedium
                                                  .copyWith(
                                                    color:
                                                        appColors.textSecondary,
                                                    fontSize: 14.sp,
                                                    fontWeight: FontWeight.w400,
                                                  ),
                                            ),
                                            if (subItem.subtitle != null) ...[
                                              SizedBox(height: 2.h),
                                              Text(
                                                subItem.subtitle!,
                                                style: appFonts.textSmMedium
                                                    .copyWith(
                                                      color: appColors.gray400,
                                                      fontSize: 12.sp,
                                                      fontWeight:
                                                          FontWeight.w300,
                                                    ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                      if (subItem.hasCheckmark)
                                        Container(
                                          width: 16.w,
                                          height: 16.h,
                                          decoration: BoxDecoration(
                                            color: appColors.pink600,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            Icons.check,
                                            color: Colors.white,
                                            size: 12.sp,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                    ),
                  )
                  : const SizedBox.shrink(),
        ),
      ],
    );
  }
}

/// Model for sub-menu items
class SubMenuItem {
  final String title;
  final VoidCallback onTap;
  final bool hasCheckmark;
  final String? subtitle;

  const SubMenuItem({
    required this.title,
    required this.onTap,
    this.hasCheckmark = false,
    this.subtitle,
  });
}
