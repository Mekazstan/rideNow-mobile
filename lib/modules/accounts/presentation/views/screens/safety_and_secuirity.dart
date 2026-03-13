// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:ridenowappsss/core/navigation/route_constant.dart';
import 'package:ridenowappsss/core/utils/extensions/app_color_extension.dart';
import 'package:ridenowappsss/core/utils/extensions/app_font_extension.dart';
import 'package:ridenowappsss/modules/accounts/presentation/providers/support_provider.dart';
import 'package:ridenowappsss/modules/accounts/presentation/views/widgets/account_details_widget.dart';
import 'package:ridenowappsss/shared/widgets/ride_now_radio_button.dart';

class SafetyAndSecuirity extends StatefulWidget {
  const SafetyAndSecuirity({super.key});

  @override
  State<SafetyAndSecuirity> createState() => _SafetyAndSecuirityState();
}

class _SafetyAndSecuirityState extends State<SafetyAndSecuirity> {
  bool _isLocationSharingEnabled = false;
  bool _isDetectiveModeEnabled = false;
  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Initialize privacy settings from provider on first build
    if (!_isInitialized) {
      final supportProvider = context.read<SupportProvider>();
      setState(() {
        _isLocationSharingEnabled = supportProvider.locationSharingEnabled;
        _isDetectiveModeEnabled = supportProvider.detectiveModeEnabled;
        _isInitialized = true;
      });
    }
  }

  /// Toggles location sharing on/off and updates the server
  Future<void> _toggleLocationSharing() async {
    final appColors = Theme.of(context).extension<AppColorExtension>()!;
    final supportProvider = context.read<SupportProvider>();

    final newValue = !_isLocationSharingEnabled;

    if (kDebugMode) {
      print('Toggling location sharing to: $newValue');
    }

    final success = await supportProvider.updateLocationSharing(newValue);

    if (!mounted) return;

    if (success) {
      setState(() {
        _isLocationSharingEnabled = newValue;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            newValue
                ? 'Location sharing activated'
                : 'Location sharing deactivated',
          ),
          backgroundColor: appColors.green400,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            supportProvider.errorMessage ?? 'Failed to update location sharing',
          ),
          backgroundColor: appColors.red400,
        ),
      );
    }
  }

  /// Toggles detective mode on/off and updates the server
  Future<void> _toggleDetectiveMode() async {
    final appColors = Theme.of(context).extension<AppColorExtension>()!;
    final supportProvider = context.read<SupportProvider>();

    final newValue = !_isDetectiveModeEnabled;

    if (kDebugMode) {
      print('Toggling detective mode to: $newValue');
    }

    final success = await supportProvider.updateDetectiveMode(newValue);

    if (!mounted) return;

    if (success) {
      setState(() {
        _isDetectiveModeEnabled = newValue;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            newValue
                ? 'Detective mode activated'
                : 'Detective mode deactivated',
          ),
          backgroundColor: appColors.green400,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            supportProvider.errorMessage ?? 'Failed to update detective mode',
          ),
          backgroundColor: appColors.red400,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorExtension>()!;
    final appFonts = Theme.of(context).extension<AppFontThemeExtension>()!;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 21),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20.h),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Row(
                  children: [
                    SvgPicture.asset('assets/arrowLeft.svg'),
                    SizedBox(width: 12.w),
                    Text(
                      'Back to Settings',
                      style: appFonts.textSmMedium.copyWith(
                        color: appColors.textPrimary,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 13.h),
              Text(
                'Safety and Security',
                style: appFonts.textSmMedium.copyWith(
                  color: appColors.textPrimary,
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 33.h),
              Text(
                'Safety and Community Settings',
                style: appFonts.textSmMedium.copyWith(
                  color: appColors.textPrimary,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 13.h),
              Container(
                height: 240.h,
                width: 350.w,
                decoration: BoxDecoration(
                  color: appColors.blue50.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      SizedBox(height: 8.h),
                      GestureDetector(
                        onTap: () {
                          context.pushNamed(RouteConstants.communitySharing);
                        },
                        child: AccountDetailsWidget(
                          appFonts: appFonts,
                          appColors: appColors,
                          text: 'Community sharing',
                          iconAsset: 'assets/safety.svg',
                        ),
                      ),
                      SizedBox(height: 13.h),
                      Divider(color: appColors.blue200),
                      SizedBox(height: 13.h),
                      AccountDetailsWidget(
                        appFonts: appFonts,
                        appColors: appColors,
                        text: 'Security FAQs',
                        iconAsset: 'assets/language.svg',
                      ),
                      SizedBox(height: 13.h),
                      Divider(color: appColors.blue200),
                      SizedBox(height: 13.h),
                      GestureDetector(
                        onTap: () {
                          context.pushNamed(RouteConstants.callPolice);
                        },
                        child: AccountDetailsWidget(
                          appFonts: appFonts,
                          appColors: appColors,
                          text: 'Call Police',
                          iconAsset: 'assets/userPin.svg',
                        ),
                      ),
                      SizedBox(height: 13.h),
                      Divider(color: appColors.blue200),
                      SizedBox(height: 13.h),
                      GestureDetector(
                        onTap: () {
                          context.pushNamed(RouteConstants.callAnAbulance);
                        },
                        child: AccountDetailsWidget(
                          appFonts: appFonts,
                          appColors: appColors,
                          text: 'Call Ambulance',
                          iconAsset: 'assets/download.svg',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 33.h),
              Text(
                'Privacy Settings',
                style: appFonts.textSmMedium.copyWith(
                  color: appColors.textPrimary,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 13.h),
              Consumer<SupportProvider>(
                builder: (context, provider, child) {
                  return Container(
                    height: 141.h,
                    width: 350.w,
                    decoration: BoxDecoration(
                      color: appColors.blue50.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          SizedBox(height: 8.h),
                          Row(
                            children: [
                              Text(
                                'Activate Location Sharing',
                                style: appFonts.textSmMedium.copyWith(
                                  color: appColors.textPrimary,
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              SizedBox(width: 6.w),
                              SvgPicture.asset('assets/info.svg'),
                              const Spacer(),
                              // Show loading indicator or toggle button
                              if (provider.isLoadingPrivacyLocation)
                                SizedBox(
                                  width: 20.w,
                                  height: 20.h,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      appColors.blue500,
                                    ),
                                  ),
                                )
                              else
                                RideNowRadioButton(
                                  width: 52.h,
                                  height: 32.w,
                                  isSelected: _isLocationSharingEnabled,
                                  onTap: _toggleLocationSharing,
                                ),
                            ],
                          ),
                          SizedBox(height: 15.h),
                          Divider(color: appColors.blue200),
                          SizedBox(height: 15.h),
                          Row(
                            children: [
                              Text(
                                'Activate Detective Mode',
                                style: appFonts.textSmMedium.copyWith(
                                  color: appColors.textPrimary,
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              SizedBox(width: 6.w),
                              SvgPicture.asset('assets/info.svg'),
                              const Spacer(),
                              // Show loading indicator or toggle button
                              if (provider.isLoadingPrivacy)
                                SizedBox(
                                  width: 20.w,
                                  height: 20.h,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      appColors.blue500,
                                    ),
                                  ),
                                )
                              else
                                RideNowRadioButton(
                                  width: 52.h,
                                  height: 32.w,
                                  isSelected: _isDetectiveModeEnabled,
                                  onTap: _toggleDetectiveMode,
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
