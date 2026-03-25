import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ridenowappsss/core/utils/extensions/app_color_extension.dart';
import 'package:ridenowappsss/core/utils/extensions/app_font_extension.dart';
import 'package:ridenowappsss/modules/wallet/presentation/views/widgets/ride_now_account_appbar.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorExtension>()!;
    final appFonts = Theme.of(context).extension<AppFontThemeExtension>()!;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 21.w),
          child: Column(
            children: [
              SizedBox(height: 20.h),
              RideNowAccountAppBar(
                appFonts: appFonts,
                appColors: appColors,
                title: 'Privacy Policy',
              ),
              SizedBox(height: 24.h),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSection(
                        appFonts,
                        appColors,
                        '1. Introduction',
                        'At RideNow, we value your privacy and are committed to protecting your personal data. This Privacy Policy explains how we collect, use, and share your information when you use our application and services.',
                      ),
                      _buildSection(
                        appFonts,
                        appColors,
                        '2. Data We Collect',
                        'We collect information that you provide directly to us, such as your name, email address, phone number, and profile picture. We also collect location data to facilitate rides and improve safety.',
                      ),
                      _buildSection(
                        appFonts,
                        appColors,
                        '3. How We Use Data',
                        'Your data is used to provide, maintain, and improve our services, including processing payments, facilitating communication between riders and drivers, and providing emergency support.',
                      ),
                      _buildSection(
                        appFonts,
                        appColors,
                        '4. Data Sharing',
                        'We share information with drivers (or riders) during a trip to facilitate the service. We may also share data with third-party service providers and for legal compliance when required.',
                      ),
                      _buildSection(
                        appFonts,
                        appColors,
                        '5. Data Security',
                        'We use industry-standard security measures to protect your personal information from unauthorized access, loss, or disclosure. However, no method of transmission over the internet is 100% secure.',
                      ),
                      _buildSection(
                        appFonts,
                        appColors,
                        '6. Your Rights',
                        'You have the right to access, update, or delete your personal information. You can manage your privacy settings directly within the app or contact our support team for assistance.',
                      ),
                      SizedBox(height: 32.h),
                      Text(
                        'Last Updated: March 21, 2026',
                        style: appFonts.textSmMedium.copyWith(
                          color: appColors.textSecondary,
                          fontSize: 12.sp,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      SizedBox(height: 40.h),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(
    AppFontThemeExtension appFonts,
    AppColorExtension appColors,
    String title,
    String content,
  ) {
    return Padding(
      padding: EdgeInsets.only(bottom: 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: appFonts.textSmMedium.copyWith(
              color: appColors.textPrimary,
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            content,
            style: appFonts.textSmMedium.copyWith(
              color: appColors.textSecondary,
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
