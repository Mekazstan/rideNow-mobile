import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ridenowappsss/core/utils/extensions/app_color_extension.dart';
import 'package:ridenowappsss/core/utils/extensions/app_font_extension.dart';

class TermsAndConditionsScreen extends StatelessWidget {
  const TermsAndConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorExtension>()!;
    final appFonts = Theme.of(context).extension<AppFontThemeExtension>()!;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: SvgPicture.asset('assets/arrowLeft.svg'),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Terms & Conditions',
          style: appFonts.textSmMedium.copyWith(
            color: appColors.textPrimary,
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Terms of Service',
                style: appFonts.textSmMedium.copyWith(
                  color: appColors.textPrimary,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                'Welcome to RideNow. By using our services, you agree to the following terms and conditions. Please read them carefully.',
                style: appFonts.textSmMedium.copyWith(
                  color: appColors.textSecondary,
                  fontSize: 14.sp,
                  height: 1.5,
                ),
              ),
              SizedBox(height: 20.h),
              _buildSection(
                appFonts,
                appColors,
                '1. Acceptance of Terms',
                'By accessing or using the RideNow platform, you agree to be bound by these Terms and Conditions and all applicable laws and regulations.',
              ),
              _buildSection(
                appFonts,
                appColors,
                '2. User Eligibility',
                'You must be at least 18 years old to use this service. By creating an account, you represent and warrant that you meet this requirement.',
              ),
              _buildSection(
                appFonts,
                appColors,
                '3. User Account',
                'You are responsible for maintaining the confidentiality of your account credentials and for all activities that occur under your account.',
              ),
              _buildSection(
                appFonts,
                appColors,
                '4. Service Description',
                'RideNow provides a platform connecting riders with drivers for transportation services. We do not provide transportation services ourselves.',
              ),
              _buildSection(
                appFonts,
                appColors,
                '5. Limitation of Liability',
                'RideNow shall not be liable for any indirect, incidental, special, or consequential damages arising out of or in connection with your use of the service.',
              ),
              SizedBox(height: 40.h),
              Center(
                child: Text(
                  'Last updated: March 2026',
                  style: appFonts.textSmMedium.copyWith(
                    color: appColors.textSecondary,
                    fontSize: 12.sp,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
              SizedBox(height: 20.h),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: appFonts.textSmMedium.copyWith(
            color: appColors.textPrimary,
            fontSize: 15.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          content,
          style: appFonts.textSmMedium.copyWith(
            color: appColors.textSecondary,
            fontSize: 14.sp,
            height: 1.5,
          ),
        ),
        SizedBox(height: 16.h),
      ],
    );
  }
}
