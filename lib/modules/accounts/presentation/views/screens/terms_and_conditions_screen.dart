import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ridenowappsss/core/utils/extensions/app_color_extension.dart';
import 'package:ridenowappsss/core/utils/extensions/app_font_extension.dart';
import 'package:ridenowappsss/modules/wallet/presentation/views/widgets/ride_now_account_appbar.dart';

class TermsAndConditionsScreen extends StatelessWidget {
  const TermsAndConditionsScreen({super.key});

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
                title: 'Terms & Conditions',
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
                        '1. Acceptance of Terms',
                        'By using the RideNow application, you agree to comply with and be bound by these Terms and Conditions. If you do not agree, please do not use our services.',
                      ),
                      _buildSection(
                        appFonts,
                        appColors,
                        '2. User Responsibilities',
                        'Users are responsible for maintaining the confidentiality of their account and password. You agree to provide accurate information and follow all safety protocols during a ride.',
                      ),
                      _buildSection(
                        appFonts,
                        appColors,
                        '3. Service Terms',
                        'RideNow acts as a platform to connect riders and independent drivers. We do not provide transportation services directly and are not responsible for the actions of users on the platform.',
                      ),
                      _buildSection(
                        appFonts,
                        appColors,
                        '4. Payments & Fares',
                        'Fares are calculated based on distance, time, and demand. You agree to pay the fare quoted at the time of booking. Cancellation fees may apply as per our policy.',
                      ),
                      _buildSection(
                        appFonts,
                        appColors,
                        '5. Limitation of Liability',
                        'RideNow is not liable for any indirect, incidental, or consequential damages arising from the use of our services. Our maximum liability is limited to the amount paid for the service.',
                      ),
                      _buildSection(
                        appFonts,
                        appColors,
                        '6. Account Termination',
                        'We reserve the right to suspend or terminate accounts that violate our community guidelines, engage in fraudulent activity, or fail to comply with these terms.',
                      ),
                      _buildSection(
                        appFonts,
                        appColors,
                        '7. Governing Law',
                        'These Terms and Conditions shall be governed by and construed in accordance with the laws of the jurisdiction in which RideNow operates.',
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
