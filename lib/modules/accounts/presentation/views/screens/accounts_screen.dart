// ignore_for_file: use_build_context_synchronously

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:ridenowappsss/core/navigation/route_constant.dart';
import 'package:ridenowappsss/core/utils/extensions/app_color_extension.dart';
import 'package:ridenowappsss/core/utils/extensions/app_font_extension.dart';
import 'package:ridenowappsss/modules/accounts/presentation/views/widgets/account_details_widget.dart';
import 'package:ridenowappsss/modules/accounts/presentation/views/widgets/account_profile_details.dart';
import 'package:ridenowappsss/modules/authentication/presentation/providers/auth_provider.dart';
import 'package:ridenowappsss/shared/widgets/shimmer_widget.dart';

class AccountsScreen extends StatefulWidget {
  const AccountsScreen({super.key});

  @override
  State<AccountsScreen> createState() => _AccountsScreenState();
}

class _AccountsScreenState extends State<AccountsScreen> {
  bool _isLoggingOut = false;
  bool _isDeletingAccount = false;
  bool _isLoadingProfile = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  /// Fetches and updates user profile data from the server
  Future<void> _loadUserProfile() async {
    if (kDebugMode) {
      print('=== AccountsScreen: Loading User Profile ===');
    }

    setState(() => _isLoadingProfile = true);

    final authProvider = context.read<AuthProvider>();

    if (kDebugMode) {
      print(
        'Current user before fetch: ${authProvider.user?.firstName} ${authProvider.user?.lastName}',
      );
      print('Current user email: ${authProvider.user?.email}');
    }

    final success = await authProvider.fetchProfile();

    if (kDebugMode) {
      print('Profile fetch success: $success');
      print(
        'User after fetch: ${authProvider.user?.firstName} ${authProvider.user?.lastName}',
      );
      print('User email after fetch: ${authProvider.user?.email}');
      print('Profile photo: ${authProvider.user?.profilePhoto}');
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
              GestureDetector(
                onTap:
                    () => context.pushNamed(RouteConstants.safetyAndSecurity),
                child: AccountDetailsWidget(
                  appFonts: appFonts,
                  appColors: appColors,
                  text: 'Safety and Security',
                  iconAsset: 'assets/safety.svg',
                ),
              ),
              SizedBox(height: 20.h),
              Divider(color: appColors.blue200),
              SizedBox(height: 15.h),
              AccountDetailsWidget(
                appFonts: appFonts,
                appColors: appColors,
                text: 'Privacy Policy',
                iconAsset: 'assets/userPin.svg',
              ),
              SizedBox(height: 15.h),
              Divider(color: appColors.blue200),
              SizedBox(height: 15.h),
              AccountDetailsWidget(
                appFonts: appFonts,
                appColors: appColors,
                text: 'Terms & Conditions',
                iconAsset: 'assets/document.svg',
              ),
              SizedBox(height: 15.h),
              Divider(color: appColors.blue200),
              SizedBox(height: 15.h),
              GestureDetector(
                onTap: () => context.pushNamed(RouteConstants.helpCenter),
                child: AccountDetailsWidget(
                  appFonts: appFonts,
                  appColors: appColors,
                  text: 'Help Center',
                  iconAsset: 'assets/document.svg',
                ),
              ),
              SizedBox(height: 15.h),
              Divider(color: appColors.blue200),
              SizedBox(height: 15.h),
              // Show loading indicator or delete button
              _isDeletingAccount
                  ? Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 12.h,
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 24.w,
                          height: 24.h,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              appColors.red600,
                            ),
                          ),
                        ),
                        SizedBox(width: 16.w),
                        Text(
                          'Deleting account...',
                          style: appFonts.textSmMedium.copyWith(
                            color: appColors.red600,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  )
                  : GestureDetector(
                    onTap: _handleDeleteAccount,
                    child: AccountDetailsWidget(
                      appFonts: appFonts,
                      appColors: appColors,
                      textColor: appColors.red600,
                      iconColor: appColors.red600,
                      text: 'Delete Account',
                      iconAsset: 'assets/userPin.svg',
                    ),
                  ),
              SizedBox(height: 15.h),
              Divider(color: appColors.blue200),
              SizedBox(height: 15.h),
              // Show loading indicator or logout button
              _isLoggingOut
                  ? Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 12.h,
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 24.w,
                          height: 24.h,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              appColors.blue500,
                            ),
                          ),
                        ),
                        SizedBox(width: 16.w),
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
                  : GestureDetector(
                    onTap: _handleLogout,
                    child: AccountDetailsWidget(
                      appFonts: appFonts,
                      appColors: appColors,
                      textColor: appColors.red600,
                      iconColor: appColors.red600,
                      text: 'Log out',
                      iconAsset: 'assets/logout.svg',
                    ),
                  ),
              SizedBox(height: 15.h),
              Divider(color: appColors.blue200),
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

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Logged out successfully'),
          backgroundColor: appColors.green400,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Logout failed: $e'),
          backgroundColor: appColors.red400,
        ),
      );
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

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Account deleted successfully'),
            backgroundColor: appColors.green400,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              authProvider.errorMessage ?? 'Failed to delete account',
            ),
            backgroundColor: appColors.red400,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Delete account failed: $e'),
          backgroundColor: appColors.red400,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isDeletingAccount = false);
      }
    }
  }
}
