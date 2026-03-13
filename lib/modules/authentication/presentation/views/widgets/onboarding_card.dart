import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ridenowappsss/core/utils/extensions/app_color_extension.dart';
import 'package:ridenowappsss/core/utils/extensions/app_font_extension.dart';
import 'package:ridenowappsss/modules/authentication/data/models/onboarding_data.dart';

class OnboardingCard extends StatelessWidget {
  final OnboardingData data;

  const OnboardingCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorExtension>()!;
    final appFonts = Theme.of(context).extension<AppFontThemeExtension>()!;

    return Column(
      children: [
        Image.asset(data.image),
        SizedBox(height: 11.h),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              data.title,
              style: appFonts.textMdMedium.copyWith(
                letterSpacing: -2,
                fontSize: 32,
                fontWeight: FontWeight.w500,
                color: appColors.textSecondary,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              data.description,
              style: appFonts.textMdMedium.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: appColors.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
