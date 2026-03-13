// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ridenowappsss/core/utils/extensions/app_color_extension.dart';
import 'package:ridenowappsss/core/utils/extensions/app_font_extension.dart';
import 'package:ridenowappsss/modules/ride/data/models/ride_request_model.dart';

class DriverArrivedSheet extends StatelessWidget {
  final RideDetails? rideDetails;
  final String rideCode;
  final String? driverNameOverride;
  final double? driverRatingOverride;
  final String? driverPhotoOverride;
  final VoidCallback onCall;
  final VoidCallback onChat;

  const DriverArrivedSheet({
    super.key,
    required this.rideDetails,
    required this.rideCode,
    this.driverNameOverride,
    this.driverRatingOverride,
    this.driverPhotoOverride,
    required this.onCall,
    required this.onChat,
  });

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorExtension>()!;
    final appFonts = Theme.of(context).extension<AppFontThemeExtension>()!;

    final driver = rideDetails?.driver;
    final driverName = driverNameOverride ?? driver?.name ?? 'Driver';
    final rating = driverRatingOverride ?? driver?.rating ?? 4.9;
    final photoUrl = driverPhotoOverride ?? driver?.profileImage;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32.r),
          topRight: Radius.circular(32.r),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildDragHandle(appColors),
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 32.h),
            child: Column(
              children: [
                // Driver Avatar
                _buildDriverAvatar(photoUrl, appColors),
                SizedBox(height: 16.h),

                // Driver Arrived Header
                Text(
                  '$driverName has arrived!',
                  textAlign: TextAlign.center,
                  style: appFonts.textBaseMedium.copyWith(
                    color: appColors.blue600,
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 8.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      driverName,
                      style: appFonts.textSmRegular.copyWith(
                        color: appColors.textSecondary,
                        fontSize: 15.sp,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    _buildRatingBadge(rating),
                  ],
                ),

                SizedBox(height: 24.h),

                // Ride Code Section
                _buildRideCodeSection(appColors, appFonts),

                SizedBox(height: 24.h),

                // Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildCircleActionButton(
                      icon: Icons.call_outlined,
                      color: appColors.gray200,
                      iconColor: appColors.textPrimary,
                      onPressed: onCall,
                    ),
                    SizedBox(width: 16.w),
                    _buildCircleActionButton(
                      icon: Icons.chat_bubble_outline,
                      color: appColors.gray200,
                      iconColor: appColors.textPrimary,
                      onPressed: onChat,
                    ),
                  ],
                ),

                SizedBox(height: 24.h),

                // Extra info or instructions
                Text(
                  'Please share the code above with your driver to start the ride.',
                  style: appFonts.textSmRegular.copyWith(
                    color: appColors.textSecondary,
                    fontSize: 14.sp,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDragHandle(AppColorExtension appColors) {
    return Center(
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 12.h),
        width: 40.w,
        height: 4.h,
        decoration: BoxDecoration(
          color: appColors.gray300,
          borderRadius: BorderRadius.circular(2.r),
        ),
      ),
    );
  }

  Widget _buildDriverAvatar(String? imageUrl, AppColorExtension appColors) {
    return Container(
      width: 64.w,
      height: 64.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: appColors.blue600, width: 2),
      ),
      child: ClipOval(
        child:
            imageUrl != null
                ? Image.network(imageUrl, fit: BoxFit.cover)
                : Container(
                  color: appColors.gray200,
                  child: Icon(
                    Icons.person,
                    size: 32.sp,
                    color: appColors.gray400,
                  ),
                ),
      ),
    );
  }

  Widget _buildRatingBadge(double rating) {
    return Row(
      children: [
        Icon(Icons.star, size: 14.sp, color: Colors.amber),
        SizedBox(width: 4.w),
        Text(
          rating.toStringAsFixed(1),
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF111827),
          ),
        ),
      ],
    );
  }

  Widget _buildRideCodeSection(
    AppColorExtension appColors,
    AppFontThemeExtension appFonts,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 20.h),
      decoration: BoxDecoration(
        color: appColors.gray100,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: appColors.gray200),
      ),
      child: Column(
        children: [
          Text(
            'RIDE OTP',
            style: appFonts.textSmRegular.copyWith(
              color: appColors.textSecondary,
              letterSpacing: 2,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            rideCode,
            style: TextStyle(
              fontSize: 36.sp,
              fontWeight: FontWeight.w800,
              letterSpacing: 8,
              color: appColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircleActionButton({
    required IconData icon,
    required Color color,
    required Color iconColor,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 48.w,
        height: 48.w,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        child: Icon(icon, color: iconColor, size: 24.sp),
      ),
    );
  }
}
