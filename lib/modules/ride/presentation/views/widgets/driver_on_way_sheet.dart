// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ridenowappsss/core/utils/extensions/app_color_extension.dart';
import 'package:ridenowappsss/core/utils/extensions/app_font_extension.dart';
import 'package:ridenowappsss/modules/ride/data/models/ride_request_model.dart';

class DriverOnWaySheet extends StatelessWidget {
  final RideDetails? rideDetails;
  final String? eta;
  final String? pickupAddress;
  final String? destinationAddress;
  final String? vehicleInfo;
  final String? driverNameOverride;
  final double? driverRatingOverride;
  final String? driverPhotoOverride;
  final String? carModel;
  final String? plateNumber;
  final VoidCallback onCall;
  final VoidCallback onChat;
  final VoidCallback onCancel;

  const DriverOnWaySheet({
    super.key,
    required this.rideDetails,
    this.eta,
    this.pickupAddress,
    this.destinationAddress,
    this.vehicleInfo,
    this.driverNameOverride,
    this.driverRatingOverride,
    this.driverPhotoOverride,
    this.carModel,
    this.plateNumber,
    required this.onCall,
    required this.onChat,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorExtension>()!;
    final appFonts = Theme.of(context).extension<AppFontThemeExtension>()!;

    final driver = rideDetails?.driver;
    final driverName = driverNameOverride ?? driver?.name ?? 'Driver';
    final rating = driverRatingOverride ?? driver?.rating ?? 4.9;
    final photoUrl = driverPhotoOverride ?? driver?.profileImage;
    final arrivalTime = eta ?? '15 mins';

    final firstName = driverName.split(' ')[0];
    String displayArrivalTime = arrivalTime;
    if (displayArrivalTime.toLowerCase().contains('min') &&
        !displayArrivalTime.toLowerCase().contains('minute')) {
      displayArrivalTime = displayArrivalTime
          .replaceAll('mins', 'minutes')
          .replaceAll('min', 'minute');
    }

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
            padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 40.h),
            child: Column(
              children: [
                // Driver Avatar
                _buildDriverAvatar(photoUrl, appColors),
                SizedBox(height: 16.h),

                // Driver Info Text
                Text(
                  '$firstName is on his way!',
                  textAlign: TextAlign.center,
                  style: appFonts.textBaseMedium.copyWith(
                    color: appColors.textPrimary,
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 12.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      driverName,
                      style: appFonts.textSmRegular.copyWith(
                        color: appColors.textSecondary,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    _buildRatingBadge(rating, appColors),
                  ],
                ),
                SizedBox(height: 4.h),
                Text(
                  'Arriving in $displayArrivalTime',
                  style: appFonts.textSmRegular.copyWith(
                    color: appColors.textSecondary.withOpacity(0.7),
                    fontSize: 14.sp,
                  ),
                ),

                SizedBox(height: 24.h),

                // Call and Chat Buttons
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

                SizedBox(height: 32.h),

                // Ride Details Card
                _buildRideDetailsCard(appColors, appFonts),

                SizedBox(height: 24.h),

                // Cancel Button at bottom
                GestureDetector(
                  onTap: onCancel,
                  child: Text(
                    'Cancel Ride',
                    style: appFonts.textBaseMedium.copyWith(
                      color: appColors.red500,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
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

  Widget _buildRatingBadge(double rating, AppColorExtension appColors) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.all(2.w),
          decoration: const BoxDecoration(
            color: Color(0xFF10B981), // Green
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.star, size: 14.sp, color: Colors.white),
        ),
        SizedBox(width: 6.w),
        Text(
          rating.toInt().toString(),
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w700,
            color: appColors.textPrimary,
          ),
        ),
      ],
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

  Widget _buildRideDetailsCard(
    AppColorExtension appColors,
    AppFontThemeExtension appFonts,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: appColors.blue50.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Stack(
        children: [
          // Vertical Line
          Positioned(
            left: 11.w,
            top: 50.h,
            bottom: 30.h,
            child: Container(
              width: 1,
              color: appColors.blue600.withOpacity(0.5),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    color: appColors.blue600,
                    size: 24.sp,
                  ),
                  SizedBox(width: 12.w),
                  Text(
                    'Your ride details',
                    style: appFonts.textBaseMedium.copyWith(
                      color: appColors.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 16.sp,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24.h),
              Padding(
                padding: EdgeInsets.only(left: 36.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailItem(
                      label: 'Going to',
                      value:
                          destinationAddress ??
                          rideDetails?.destination.address ??
                          '...',
                      appColors: appColors,
                      appFonts: appFonts,
                    ),
                    SizedBox(height: 24.h),
                    _buildDetailItem(
                      label: 'From',
                      value:
                          pickupAddress ??
                          rideDetails?.pickupLocation.address ??
                          '...',
                      appColors: appColors,
                      appFonts: appFonts,
                    ),
                    SizedBox(height: 24.h),
                    _buildDetailItem(
                      label: 'Vehicle',
                      value: vehicleInfo ?? rideDetails?.vehicleType ?? '...',
                      appColors: appColors,
                      appFonts: appFonts,
                    ),
                    if (carModel != null || rideDetails?.vehicle != null) ...[
                      SizedBox(height: 24.h),
                      _buildDetailItem(
                        label: 'Car',
                        value:
                            '${carModel ?? rideDetails?.vehicle?.model ?? ''} ${plateNumber ?? rideDetails?.vehicle?.plateNumber ?? ''}'
                                .trim(),
                        appColors: appColors,
                        appFonts: appFonts,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem({
    required String label,
    required String value,
    required AppColorExtension appColors,
    required AppFontThemeExtension appFonts,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: appFonts.textSmRegular.copyWith(
            color: appColors.textSecondary,
            fontSize: 13.sp,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          value,
          style: appFonts.textBaseMedium.copyWith(
            color: appColors.textPrimary,
            fontSize: 15.sp,
            fontWeight: FontWeight.w700,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
