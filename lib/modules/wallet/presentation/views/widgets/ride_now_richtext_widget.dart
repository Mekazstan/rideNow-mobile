import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ridenowappsss/core/utils/extensions/app_color_extension.dart';
import 'package:ridenowappsss/core/utils/extensions/app_font_extension.dart';

class RideNowRichtextWidget extends StatelessWidget {
  const RideNowRichtextWidget({
    super.key,
    required this.firstText,
    required this.secondText,
    required this.appFonts,
    required this.appColors,
    this.firstTextColor,
    this.secondTextColor,
    this.firstTextWeight,
    this.secondTextWeight,
    this.fontSize,
    this.textAlign = TextAlign.left,
  });

  final String firstText;
  final String secondText;
  final AppFontThemeExtension appFonts;
  final AppColorExtension appColors;
  final Color? firstTextColor;
  final Color? secondTextColor;
  final FontWeight? firstTextWeight;
  final FontWeight? secondTextWeight;
  final double? fontSize;
  final TextAlign textAlign;

  @override
  Widget build(BuildContext context) {
    return RichText(
      textAlign: textAlign,
      text: TextSpan(
        children: [
          TextSpan(
            text: firstText,
            style: appFonts.textSmMedium.copyWith(
              color: firstTextColor ?? appColors.textPrimary,
              fontWeight: firstTextWeight ?? FontWeight.w400,
              fontSize: fontSize ?? 16.sp,
            ),
          ),
          TextSpan(
            text: secondText,
            style: appFonts.textSmMedium.copyWith(
              color: secondTextColor ?? appColors.textSecondary,
              fontWeight: secondTextWeight ?? FontWeight.w400,
              fontSize: fontSize ?? 16.sp,
            ),
          ),
        ],
      ),
    );
  }
}
