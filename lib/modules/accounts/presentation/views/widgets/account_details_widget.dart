// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ridenowappsss/core/utils/extensions/app_color_extension.dart';
import 'package:ridenowappsss/core/utils/extensions/app_font_extension.dart';

class AccountDetailsWidget extends StatelessWidget {
  const AccountDetailsWidget({
    super.key,
    required this.appFonts,
    required this.appColors,
    required this.text,
    required this.iconAsset,
    this.showArrow = true,
    this.iconColor,
    this.textColor,
    this.iconWidget,
  });

  final AppFontThemeExtension appFonts;
  final AppColorExtension appColors;
  final String text;
  final String iconAsset;
  final bool showArrow;
  final Color? iconColor;
  final Color? textColor;
  final Widget? iconWidget;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SvgPicture.asset(
          iconAsset,
          colorFilter:
              iconColor != null
                  ? ColorFilter.mode(iconColor!, BlendMode.srcIn)
                  : null,
        ),
        SizedBox(width: 18.w),
        Text(
          text,
          style: appFonts.textSmMedium.copyWith(
            color: textColor ?? appColors.textPrimary,
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
          ),
        ),
        Spacer(),
        showArrow
            ? SvgPicture.asset('assets/rightArrow.svg', color: iconColor)
            : iconWidget ?? SizedBox(),
      ],
    );
  }
}
