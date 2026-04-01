// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ridenowappsss/core/utils/extensions/app_color_extension.dart';
import 'package:ridenowappsss/core/utils/extensions/app_font_extension.dart';
import 'package:ridenowappsss/modules/ride/data/models/driver_ride_request.dart';
import 'package:ridenowappsss/shared/widgets/ridenow_button.dart';

class DriverSideOnWaySheet extends StatelessWidget {
  final AcceptRideResponse ride;
  final VoidCallback onArrived;
  final VoidCallback onCall;
  final VoidCallback onChat;
  final bool isLoading;

  const DriverSideOnWaySheet({
    super.key,
    required this.ride,
    required this.onArrived,
    required this.onCall,
    required this.onChat,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorExtension>()!;
    final appFonts = Theme.of(context).extension<AppFontThemeExtension>()!;

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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _buildAvatar(ride.rideDetails?.riderImage, appColors),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Rider',
                            style: appFonts.textSmRegular.copyWith(
                              color: appColors.textSecondary,
                              fontSize: 13.sp,
                            ),
                          ),
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  ride.rideDetails?.riderName ?? 'Rider',
                                  style: appFonts.textSmMedium.copyWith(
                                    color: appColors.textPrimary,
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              SizedBox(width: 8.w),
                              _buildRatingBadge(ride.rideDetails?.riderRating ?? 4.9, appColors),
                            ],
                          ),
                        ],
                      ),
                    ),
                    _buildActionIcons(appColors),
                  ],
                ),
                SizedBox(height: 24.h),
                _buildRideDetails(appColors, appFonts),
                SizedBox(height: 24.h),
                RideNowButton(
                  title: 'I have Arrived at Pickup',
                  onTap: onArrived,
                  isLoading: isLoading,
                  width: double.infinity,
                  height: 56.h,
                  colorSet: RideNowButtonColorSet.primary,
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

  Widget _buildAvatar(String? imageUrl, AppColorExtension appColors) {
    return Container(
      width: 48.w,
      height: 48.w,
      decoration: BoxDecoration(
        color: const Color(0xFFFFD700),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.r),
        child:
            imageUrl != null && imageUrl.isNotEmpty
                ? Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(Icons.person, color: Colors.white, size: 28.sp);
                    },
                  )
                : Icon(Icons.person, color: Colors.white, size: 28.sp),
      ),
    );
  }

  Widget _buildRatingBadge(double rating, AppColorExtension appColors) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.all(2.w),
          decoration: const BoxDecoration(
            color: Color(0xFF10B981),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.star, size: 8.sp, color: Colors.white),
        ),
        SizedBox(width: 4.w),
        Text(
          rating.toStringAsFixed(1),
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w700,
            color: appColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildActionIcons(AppColorExtension appColors) {
    return Row(
      children: [
        _buildIconCircle(
          Icons.call_outlined,
          const Color(0xFFEFF4FF),
          appColors.blue600,
          onTap: onCall,
        ),
        SizedBox(width: 8.w),
        _buildIconCircle(
          Icons.chat_bubble_outline,
          const Color(0xFFEFF4FF),
          appColors.blue600,
          onTap: onChat,
        ),
      ],
    );
  }

  Widget _buildIconCircle(
    IconData icon,
    Color bgColor,
    Color iconColor, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40.w,
        height: 40.w,
        decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
        child: Icon(icon, color: iconColor, size: 20.sp),
      ),
    );
  }

  Widget _buildRideDetails(
    AppColorExtension appColors,
    AppFontThemeExtension appFonts,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDetailItem(
          'Pickup Address',
          ride.rideDetails?.pickupAddress ?? '',
          appColors,
          appFonts,
        ),
        SizedBox(height: 16.h),
        _buildDetailItem(
          'Destination Address',
          ride.rideDetails?.destinationLocation ?? '',
          appColors,
          appFonts,
        ),
      ],
    );
  }

  Widget _buildDetailItem(
    String label,
    String value,
    AppColorExtension appColors,
    AppFontThemeExtension appFonts,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: appFonts.textSmRegular.copyWith(
            color: appColors.textSecondary,
            fontSize: 12.sp,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          value,
          style: appFonts.textSmMedium.copyWith(
            color: appColors.textPrimary,
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
