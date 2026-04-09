import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ridenowappsss/core/utils/extensions/app_color_extension.dart';
import 'package:ridenowappsss/core/utils/extensions/app_font_extension.dart';

class RideAcceptedBottomSheet extends StatelessWidget {
  final String? profilePhotoOverride;
  final String title;
  final String subtitle;
  final String fare;

  const RideAcceptedBottomSheet({
    super.key,
    this.profilePhotoOverride,
    required this.title,
    required this.subtitle,
    required this.fare,
  });

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorExtension>()!;
    final appFonts = Theme.of(context).extension<AppFontThemeExtension>()!;

    return Container(
      padding: EdgeInsets.only(top: 24.h, left: 24.w, right: 24.w, bottom: 40.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32.r),
          topRight: Radius.circular(32.r),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 48.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: appColors.gray200,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          SizedBox(height: 32.h),

          // Profile Image with Checkmark
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Container(
                width: 72.w,
                height: 72.h,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: appColors.gray100,
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  image: profilePhotoOverride != null && profilePhotoOverride!.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(profilePhotoOverride!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: profilePhotoOverride == null || profilePhotoOverride!.isEmpty
                    ? Icon(Icons.person, size: 36.sp, color: appColors.gray400)
                    : null,
              ),
              Positioned(
                bottom: -4,
                right: -4,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Color(0xFF10B981), // Emerald green
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 16.sp,
                  ),
                ),
              ),
            ],
          ),
          
          SizedBox(height: 16.h),
          
          // Title
          Text(
            title,
            style: appFonts.textBaseMedium.copyWith(
              color: appColors.textPrimary,
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          
          SizedBox(height: 8.h),
          
          // Subtitle / Rating
          Text(
            subtitle,
            style: appFonts.textSmRegular.copyWith(
              color: appColors.textSecondary,
              fontSize: 14.sp,
            ),
            textAlign: TextAlign.center,
          ),
          
          SizedBox(height: 16.h),
          
          // Fare
          if (fare.isNotEmpty)
            Text(
              fare,
              style: appFonts.textBaseMedium.copyWith(
                color: const Color(0xFFE11D48), // Rose red for amount
                fontSize: 24.sp,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            
          SizedBox(height: 32.h),
          
          // Checked icons row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildActionIcon(Icons.check, appColors.blue50, appColors.blue600),
              SizedBox(width: 24.w),
              _buildActionIcon(Icons.chat_bubble_outline, appColors.gray100, appColors.gray400),
              SizedBox(width: 24.w),
              _buildActionIcon(Icons.close, appColors.gray100, appColors.gray400),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionIcon(IconData icon, Color bgColor, Color iconColor) {
    return Container(
      width: 48.w,
      height: 48.h,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Icon(
          icon,
          color: iconColor,
          size: 20.sp,
        ),
      ),
    );
  }
}
