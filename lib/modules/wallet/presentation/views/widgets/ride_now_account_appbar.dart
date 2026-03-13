import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ridenowappsss/core/utils/extensions/app_color_extension.dart';
import 'package:ridenowappsss/core/utils/extensions/app_font_extension.dart';

class RideNowAccountAppBar extends StatelessWidget {
  const RideNowAccountAppBar({
    super.key,
    required this.appFonts,
    required this.appColors,
    required this.title,
  });

  final AppFontThemeExtension appFonts;
  final AppColorExtension appColors;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: SvgPicture.asset(
            'assets/arrowLeft.svg',
            height: 24.h,
            width: 24.w,
          ),
        ),
        Spacer(),
        Text(
          title,
          style: appFonts.textSmMedium.copyWith(
            color: appColors.textPrimary,
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        Spacer(),
      ],
    );
  }
}
