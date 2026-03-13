// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ridenowappsss/core/utils/extensions/app_color_extension.dart';

class NavigationButton extends StatelessWidget {
  const NavigationButton({super.key, required this.appColors});

  final AppColorExtension appColors;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Scaffold.of(context).openDrawer();
      },
      child: Container(
        height: 34.h,
        width: 34.w,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: appColors.gray100,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              spreadRadius: 0,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Transform.scale(
          scale: 0.5,
          child: SvgPicture.asset(
            'assets/menue.svg',
            height: 12.h,
            width: 12.w,
          ),
        ),
      ),
    );
  }
}
