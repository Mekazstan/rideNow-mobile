// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ridenowappsss/core/utils/extensions/app_font_extension.dart';

class SafetyMenuOverlay extends StatelessWidget {
  final VoidCallback onShareLiveLocation;
  final VoidCallback onCallPolice;

  const SafetyMenuOverlay({
    super.key,
    required this.onShareLiveLocation,
    required this.onCallPolice,
  });

  @override
  Widget build(BuildContext context) {
    final appFonts = Theme.of(context).extension<AppFontThemeExtension>()!;

    return Material(
      color: Colors.transparent,
      child: Container(
        width: 210.w,
        decoration: BoxDecoration(
          color: const Color(0xFF2D50E6), // Vivid blue from image
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildMenuItem(
              icon: Icons.location_on,
              title: 'Share live location',
              onTap: onShareLiveLocation,
              appFonts: appFonts,
            ),
            Divider(color: Colors.white.withOpacity(0.2), height: 1),
            _buildMenuItem(
              icon: Icons.local_police,
              title: 'Call Police',
              onTap: onCallPolice,
              appFonts: appFonts,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required AppFontThemeExtension appFonts,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20.sp),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                title,
                style: appFonts.textSmMedium.copyWith(
                  color: Colors.white,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
