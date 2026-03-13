// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ridenowappsss/core/utils/extensions/app_color_extension.dart';
import 'package:ridenowappsss/core/utils/extensions/app_font_extension.dart';
import 'package:ridenowappsss/modules/wallet/presentation/views/widgets/ride_now_richtext_widget.dart';

class WatchRideContent extends StatelessWidget {
  const WatchRideContent({
    super.key,
    required this.appColors,
    required this.appFonts,
  });

  final AppColorExtension appColors;
  final AppFontThemeExtension appFonts;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 61.h,
      width: 351.w,
      decoration: BoxDecoration(
        color: appColors.blue100.withOpacity(0.25),
        border: Border.all(color: appColors.gray200),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Row(
          children: [
            Container(
              height: 32.h,
              width: 32.w,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Image.asset('assets/user.png'),
            ),
            SizedBox(width: 12.w),
            RideNowRichtextWidget(
              firstText: 'Ameh Cindy ',
              secondText: 'is live now',
              fontSize: 14.sp,
              textAlign: TextAlign.center,
              firstTextColor: appColors.textPrimary,
              secondTextColor: appColors.textPrimary,
              firstTextWeight: FontWeight.w700,
              secondTextWeight: FontWeight.w500,
              appFonts: appFonts,
              appColors: appColors,
            ),
            Spacer(),
            SvgPicture.asset('assets/eye.svg'),
            SizedBox(width: 4.w),
            Text(
              'Watch live',
              style: appFonts.textMdBold.copyWith(
                color: appColors.blue600,
                fontSize: 12.sp,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
