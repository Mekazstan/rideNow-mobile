// ignore_for_file: use_build_context_synchronously

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:ridenowappsss/core/navigation/route_constant.dart';
import 'package:ridenowappsss/core/utils/extensions/app_color_extension.dart';
import 'package:ridenowappsss/core/utils/extensions/app_font_extension.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ridenowappsss/modules/accounts/presentation/views/widgets/account_profile_details.dart';
import 'package:ridenowappsss/modules/accounts/presentation/views/widgets/personal_info_section.dart';
import 'package:ridenowappsss/modules/authentication/presentation/providers/auth_provider.dart';
import 'package:ridenowappsss/shared/widgets/shimmer_widget.dart';
import 'package:ridenowappsss/core/services/toast_service.dart';

class AccountsScreen extends StatefulWidget {
  const AccountsScreen({super.key});

  @override
  State<AccountsScreen> createState() => _AccountsScreenState();
}

class _AccountsScreenState extends State<AccountsScreen> {
  bool _isLoggingOut = false;
  bool _isDeletingAccount = false;
  bool _isLoadingProfile = false; // Default to false, will be set in initState if needed

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  /// Fetches and updates user profile data from the server
  Future<void> _loadUserProfile() async {
    final authProvider = context.read<AuthProvider>();

    // Only show shimmer if we don't have a user yet
    // This implements the "Silent Refresh" pattern for a better UX
    if (authProvider.user == null) {
      if (mounted) setState(() => _isLoadingProfile = true);
    } else {
      if (mounted) setState(() => _isLoadingProfile = false);
    }

    if (kDebugMode) {
      print('=== AccountsScreen: Loading User Profile ===');
      print(
        'Current user before fetch: ${authProvider.user?.firstName} ${authProvider.user?.lastName}',
      );
    }

    final success = await authProvider.fetchProfile();

    if (kDebugMode) {
      print('Profile fetch success: $success');
      print(
        'User after fetch: ${authProvider.user?.firstName} ${authProvider.user?.lastName}',
      );
    }

    if (mounted) {
      setState(() => _isLoadingProfile = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorExtension>()!;
    final appFonts = Theme.of(context).extension<AppFontThemeExtension>()!;

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadUserProfile,
          color: appColors.blue500,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 21),
            child:
                _isLoadingProfile
                    ? _buildShimmerView(appColors)
                    : _buildContentView(appColors, appFonts),
          ),
        ),
      ),
    );
  }

  /// Builds shimmer loading placeholder for the entire screen
  Widget _buildShimmerView(AppColorExtension appColors) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: 10.h),
        ShimmerBox(width: 40.w, height: 40.h, borderRadius: 8.r),
        SizedBox(height: 15.h),
        Center(
          child: Column(
            children: [
              AvatarShimmer(size: 80.w),
              SizedBox(height: 10.h),
              ShimmerBox(width: 150.w, height: 24.h, borderRadius: 4.r),
            ],
          ),
        ),
        SizedBox(height: 24.h),
        _buildMenuItemShimmer(),
        SizedBox(height: 20.h),
        Divider(color: appColors.blue200),
        SizedBox(height: 15.h),
        _buildMenuItemShimmer(),
        SizedBox(height: 15.h),
        Divider(color: appColors.blue200),
        SizedBox(height: 15.h),
        _buildMenuItemShimmer(),
        SizedBox(height: 15.h),
        Divider(color: appColors.blue200),
        SizedBox(height: 15.h),
        _buildMenuItemShimmer(),
        SizedBox(height: 15.h),
        Divider(color: appColors.blue200),
        SizedBox(height: 15.h),
        _buildMenuItemShimmer(),
        SizedBox(height: 15.h),
        Divider(color: appColors.blue200),
        SizedBox(height: 15.h),
        _buildMenuItemShimmer(),
        SizedBox(height: 15.h),
        Divider(color: appColors.blue200),
        SizedBox(height: 15.h),
        _buildMenuItemShimmer(),
        SizedBox(height: 15.h),
        Divider(color: appColors.blue200),
        SizedBox(height: 30.h),
      ],
    );
  }

  /// Builds a single shimmer placeholder for menu items
  Widget _buildMenuItemShimmer() {
    return Row(
      children: [
        ShimmerBox(width: 24.w, height: 24.h, borderRadius: 4.r),
        SizedBox(width: 12.w),
        ShimmerBox(width: 180.w, height: 16.h, borderRadius: 4.r),
        const Spacer(),
        ShimmerBox(width: 24.w, height: 24.h, borderRadius: 4.r),
      ],
    );
  }

  /// Builds the main content view with profile and menu options
  Widget _buildContentView(
    AppColorExtension appColors,
    AppFontThemeExtension appFonts,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 15.h),
        AccountProfileDetails(appColors: appColors, appFonts: appFonts),
        SizedBox(height: 24.h),
        Expanded(
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              PersonalInfoSection(appColors: appColors, appFonts: appFonts),
              SizedBox(height: 32.h),
              Text(
                'Ride History',
                style: appFonts.textSmMedium.copyWith(
                  color: appColors.textPrimary,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 16.h),
              _buildLargeMenuContainer(
                appColors,
                [
                  _buildMenuItem(
                    appFonts,
                    appColors,
                    'My Rides',
                    'assets/document.svg',
                    () => context.pushNamed(RouteConstants.myRides),
                  ),
                ],
              ),
              SizedBox(height: 32.h),
              Text(
                'Settings & Support',
                style: appFonts.textSmMedium.copyWith(
                  color: appColors.textPrimary,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 16.h),
              _buildLargeMenuContainer(
                appColors,
                [
                  _buildMenuItem(
                    appFonts,
                    appColors,
                    'Safety and Security',
                    'assets/safety.svg',
                    () => context.pushNamed(RouteConstants.safetyAndSecurity),
                  ),
                  _buildDivider(appColors),
                  _buildMenuItem(
                    appFonts,
                    appColors,
                    'Privacy Policy',
                    'assets/userPin.svg',
                    () => context.pushNamed(RouteConstants.privacyPolicy),
                  ),
                  _buildDivider(appColors),
                  _buildMenuItem(
                    appFonts,
                    appColors,
                    'Terms & Conditions',
                    'assets/document.svg',
                    () => context.pushNamed(RouteConstants.termsAndConditions),
                  ),
                  _buildDivider(appColors),
                  _buildMenuItem(
                    appFonts,
                    appColors,
                    'Help Center',
                    'assets/document.svg',
                    () => context.pushNamed(RouteConstants.helpCenter),
                  ),
                ],
              ),
              SizedBox(height: 32.h),
              Text(
                'Account Actions',
                style: appFonts.textSmMedium.copyWith(
                  color: appColors.textPrimary,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 16.h),
              _buildLargeMenuContainer(
                appColors,
                [
                  _isDeletingAccount
                      ? _buildLoadingItem(appColors, appFonts, 'Deleting account...', appColors.red600)
                      : _buildMenuItem(
                          appFonts,
                          appColors,
                          'Delete Account',
                          'assets/userPin.svg',
                          _handleDeleteAccount,
                          textColor: appColors.red600,
                          iconColor: appColors.red600,
                        ),
                  _buildDivider(appColors),
                  _isLoggingOut
                      ? _buildLoadingItem(appColors, appFonts, 'Logging out...', appColors.blue500)
                      : _buildMenuItem(
                          appFonts,
                          appColors,
                          'Log out',
                          'assets/logout.svg',
                          _handleLogout,
                          textColor: appColors.red600,
                          iconColor: appColors.red600,
                        ),
                ],
              ),
              SizedBox(height: 30.h),
            ],
          ),
        ),
      ],
    );
  }

  /// Shows confirmation dialog and handles user logout
  Future<void> _handleLogout() async {
    final appColors = Theme.of(context).extension<AppColorExtension>()!;

    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Logout'),
            content: const Text('Are you sure you want to logout?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(foregroundColor: appColors.red500),
                child: const Text('Logout'),
              ),
            ],
          ),
    );

    if (confirmed != true) return;

    setState(() => _isLoggingOut = true);

    try {
      final authProvider = context.read<AuthProvider>();
      await authProvider.logout();

      if (!mounted) return;

      context.goNamed(RouteConstants.login);

      ToastService.showSuccess('Logged out successfully');
    } catch (e) {
      if (!mounted) return;

      ToastService.showError('Logout failed: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoggingOut = false);
      }
    }
  }

  /// Shows confirmation dialog and permanently deletes user account
  Future<void> _handleDeleteAccount() async {
    final appColors = Theme.of(context).extension<AppColorExtension>()!;

    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Account'),
            content: const Text(
              'Are you sure you want to delete your account? This action cannot be undone and all your data will be permanently deleted.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(foregroundColor: appColors.red600),
                child: const Text('Delete'),
              ),
            ],
          ),
    );

    if (confirmed != true) return;

    setState(() => _isDeletingAccount = true);

    try {
      final authProvider = context.read<AuthProvider>();
      final success = await authProvider.deleteAccount();

      if (!mounted) return;

      if (success) {
        context.goNamed(RouteConstants.login);

        ToastService.showSuccess('Account deleted successfully');
      } else {
        ToastService.showError(authProvider.errorMessage ?? 'Failed to delete account');
      }
    } catch (e) {
      if (!mounted) return;

      ToastService.showError('Delete account failed: $e');
    } finally {
      if (mounted) {
        setState(() => _isDeletingAccount = false);
      }
    }
  }

  Widget _buildLargeMenuContainer(AppColorExtension appColors, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: appColors.blue50.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: appColors.blue100),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildMenuItem(
    AppFontThemeExtension appFonts,
    AppColorExtension appColors,
    String text,
    String iconAsset,
    VoidCallback onTap, {
    Color? textColor,
    Color? iconColor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        child: Row(
          children: [
            SvgPicture.asset(
              iconAsset,
              width: 20.w,
              height: 20.h,
              colorFilter: ColorFilter.mode(
                iconColor ?? appColors.blue500,
                BlendMode.srcIn,
              ),
            ),
            SizedBox(width: 16.w),
            Text(
              text,
              style: appFonts.textSmMedium.copyWith(
                color: textColor ?? appColors.textPrimary,
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.chevron_right_rounded,
              color: appColors.gray400,
              size: 20.sp,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider(AppColorExtension appColors) {
    return Divider(
      color: appColors.blue100.withOpacity(0.5),
      height: 1,
      indent: 52.w,
    );
  }

  Widget _buildLoadingItem(
    AppColorExtension appColors,
    AppFontThemeExtension appFonts,
    String text,
    Color color,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      child: Row(
        children: [
          SizedBox(
            width: 20.w,
            height: 20.h,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          SizedBox(width: 16.w),
          Text(
            text,
            style: appFonts.textSmMedium.copyWith(
              color: color,
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
