import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ridenowappsss/core/utils/extensions/app_color_extension.dart';
import 'package:ridenowappsss/core/utils/extensions/app_font_extension.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

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
          'Privacy Policy',
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
                'Our Commitment to Privacy',
                style: appFonts.textSmMedium.copyWith(
                  color: appColors.textPrimary,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                'At RideNow, we value your privacy and are committed to protecting your personal data. This policy outlines how we collect, use, and safeguard your information.',
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
                '1. Information We Collect',
                'We collect information you provide directly to us, such as your name, email address, phone number, and profile photo. We also collect location data to provide transportation services.',
              ),
              _buildSection(
                appFonts,
                appColors,
                '2. How We Use Your Information',
                'We use your information to facilitate rides, process payments, provide customer support, and improve our services. We may also use it for safety and security purposes.',
              ),
              _buildSection(
                appFonts,
                appColors,
                '3. Information Sharing',
                'We share your information with drivers to facilitate rides and with third-party service providers for payment processing and other necessary functions. We do not sell your personal data.',
              ),
              _buildSection(
                appFonts,
                appColors,
                '4. Data Security',
                'We implement industry-standard security measures to protect your data from unauthorized access, loss, or misuse.',
              ),
              _buildSection(
                appFonts,
                appColors,
                '5. Your Choices',
                'You can update your profile information and manage your privacy settings (such as location sharing) directly within the app at any time.',
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
