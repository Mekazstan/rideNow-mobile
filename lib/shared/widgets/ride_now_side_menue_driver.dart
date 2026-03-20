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

class RideNowSideMenueDriver extends StatefulWidget {
  const RideNowSideMenueDriver({super.key});

  @override
  State<RideNowSideMenueDriver> createState() => _RideNowSideMenueDriverState();
}

class _RideNowSideMenueDriverState extends State<RideNowSideMenueDriver> {
  bool _isLoggingOut = false;
  bool _isLoadingProfile = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
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
              'Murtala Mohammed Expressway',
              style: appFonts.textSmMedium.copyWith(
                color: appColors.textPrimary,
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 6.h),
            Container(
              height: 187.h,
              width: 279.w,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Image.asset('assets/map2.png'),
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
                        onTap: () => _handleSwitchAccount('rider'),
                        hasCheckmark: user?.userType.toLowerCase() == 'rider',
                      ),
                      SubMenuItem(
                        title: 'Driver',
                        onTap: () => _handleSwitchAccount('driver'),
                        hasCheckmark: user?.userType.toLowerCase() == 'driver',
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
                SvgPicture.asset('assets/verify.svg'),
                SizedBox(width: 6.w),
                Text(
                  user?.verificationStatus == true ? 'Verified' : 'Unverified',
                  style: appFonts.textSmMedium.copyWith(
                    color:
                        user?.verificationStatus == true
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Logged out successfully'),
          backgroundColor: appColors.green400,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );

      debugPrint('=== LOGOUT FLOW COMPLETED ===');
    } catch (e) {
      debugPrint('âŒ Logout error: $e');

      if (!mounted) return;

      setState(() => _isLoggingOut = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Logout failed: ${e.toString()}'),
          backgroundColor: appColors.red400,
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _handleSwitchAccount(String targetUserType) async {
    final appColors = Theme.of(context).extension<AppColorExtension>()!;
    final authProvider = context.read<AuthProvider>();
    final currentUserType = authProvider.user?.userType.toLowerCase();
    final navigator = Navigator.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    debugPrint('=== SWITCH ACCOUNT: START ===');
    debugPrint('From: $currentUserType â†’ To: $targetUserType');

    // Already on target account
    if (currentUserType == targetUserType.toLowerCase()) {
      navigator.pop(); // Close drawer
      return;
    }

    // Get confirmation
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Switch Account'),
            content: Text('Switch to $targetUserType account?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Continue'),
              ),
            ],
          ),
    );

    if (confirmed != true) return;

    // Perform logout
    try {
      await authProvider.logout();
      debugPrint('âœ… Logged out');
    } catch (e) {
      debugPrint('âš ï¸ Logout error (continuing anyway): $e');
    }

    // Close drawer (handle any errors)
    await Future.delayed(const Duration(milliseconds: 100));

    try {
      if (navigator.canPop()) {
        navigator.pop();
        debugPrint('âœ… Drawer closed');
      }
    } catch (e) {
      debugPrint('âš ï¸ Could not close drawer: $e');
    }

    // Wait before navigation
    await Future.delayed(const Duration(milliseconds: 200));

    // Navigate to login - THIS WILL WORK
    if (mounted) {
      GoRouter.of(context);

      try {
        // Clear the entire stack and go to login
        context.goNamed(RouteConstants.login);
        debugPrint('âœ… Navigated to login');
      } catch (e) {
        debugPrint('âŒ GoRouter.go failed: $e');

        // Fallback: Use Navigator to clear stack
        try {
          Navigator.of(
            context,
          ).pushNamedAndRemoveUntil('/login', (route) => false);
          debugPrint('âœ… Navigated with Navigator fallback');
        } catch (e2) {
          debugPrint('âŒ Navigator fallback failed: $e2');
        }
      }

      // Show message
      await Future.delayed(const Duration(milliseconds: 300));

      if (mounted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text('Login with your $targetUserType credentials'),
            backgroundColor: appColors.blue500,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }

    debugPrint('=== SWITCH ACCOUNT: END ===');
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
