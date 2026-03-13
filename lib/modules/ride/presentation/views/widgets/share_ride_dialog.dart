// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ridenowappsss/core/utils/extensions/app_color_extension.dart';
import 'package:ridenowappsss/core/utils/extensions/app_font_extension.dart';

class ShareRideDialog extends StatelessWidget {
  final VoidCallback onFacebook;
  final VoidCallback onSnapchat;
  final VoidCallback onWhatsapp;

  const ShareRideDialog({
    super.key,
    required this.onFacebook,
    required this.onSnapchat,
    required this.onWhatsapp,
  });

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorExtension>()!;
    final appFonts = Theme.of(context).extension<AppFontThemeExtension>()!;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Icon(
                    Icons.close,
                    color: appColors.gray400,
                    size: 20.sp,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Text(
              'Share your ride to:',
              style: appFonts.textBaseMedium.copyWith(
                color: appColors.textPrimary.withOpacity(0.7),
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 32.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildSocialIcon(
                  icon: Icons.facebook,
                  color: Colors.black,
                  onTap: onFacebook,
                ),
                SizedBox(width: 24.w),
                _buildSocialIcon(
                  icon: Icons.snapchat,
                  color: Colors.black,
                  onTap: onSnapchat,
                ),
                SizedBox(width: 24.w),
                _buildSocialIcon(
                  icon: Icons.chat,
                  color: Colors.black,
                  onTap: onWhatsapp,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialIcon({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Icon(icon, color: color, size: 36.sp),
    );
  }
}
