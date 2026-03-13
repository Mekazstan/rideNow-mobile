// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ridenowappsss/core/utils/extensions/app_color_extension.dart';
import 'package:ridenowappsss/core/utils/extensions/app_font_extension.dart';

class RideDetailsView extends StatelessWidget {
  final dynamic ride;
  final AppColorExtension appColors;
  final AppFontThemeExtension appFonts;
  final String currentLocationName;
  final VoidCallback onBack;
  final VoidCallback onAccept;

  const RideDetailsView({
    super.key,
    required this.ride,
    required this.appColors,
    required this.appFonts,
    required this.currentLocationName,
    required this.onBack,
    required this.onAccept,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 8.h),
          _buildBackButton(),
          SizedBox(height: 24.h),
          _buildRiderProfileCard(),
          SizedBox(height: 20.h),
          _buildRideDetailsSection(),
          SizedBox(height: 24.h),
          _buildAcceptButton(),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }

  Widget _buildBackButton() {
    return InkWell(
      onTap: onBack,
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(2.w),
            child: Icon(
              Icons.arrow_back_ios_new,
              size: 14.sp,
              color: appColors.textPrimary,
            ),
          ),
          SizedBox(width: 8.w),
          Text(
            'Back to find rides',
            style: appFonts.textSmMedium.copyWith(
              color: appColors.textPrimary,
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRiderProfileCard() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: appColors.gray200, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Profile Image
              Container(
                width: 56.w,
                height: 56.h,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: appColors.pink500, width: 2),
                  image:
                      ride.riderImage.isNotEmpty
                          ? DecorationImage(
                            image: NetworkImage(ride.riderImage),
                            fit: BoxFit.cover,
                          )
                          : null,
                ),
                child:
                    ride.riderImage.isEmpty
                        ? Icon(
                          Icons.person,
                          size: 28.sp,
                          color: appColors.gray400,
                        )
                        : null,
              ),
              SizedBox(width: 12.w),
              // Rider Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            ride.riderName,
                            style: appFonts.textSmMedium.copyWith(
                              color: appColors.textPrimary,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w700,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (ride.isVerified) ...[
                          SizedBox(width: 6.w),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 2.w,
                              vertical: 2.h,
                            ),
                            child: Icon(
                              Icons.verified,
                              size: 16.sp,
                              color: appColors.green600,
                            ),
                          ),
                        ],
                      ],
                    ),
                    SizedBox(height: 4.h),
                    if (ride.getRiderRatingDisplay() != 'N/A')
                      Row(
                        children: [
                          Icon(
                            Icons.star,
                            size: 14.sp,
                            color: appColors.pink300,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            ride.getRiderRatingDisplay(),
                            style: appFonts.textSmMedium.copyWith(
                              color: appColors.textSecondary,
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              // Fare
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: appColors.green50,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  ride.getFormattedFare(),
                  style: appFonts.textSmMedium.copyWith(
                    color: appColors.green700,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRideDetailsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 4.w, bottom: 12.h),
          child: Text(
            'Ride details',
            style: appFonts.textSmMedium.copyWith(
              color: appColors.textPrimary,
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: appColors.gray50,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: appColors.gray200, width: 1),
          ),
          child: Column(
            children: [
              _buildLocationRow(
                icon: Icons.radio_button_checked,
                iconColor: appColors.blue600,
                iconBgColor: appColors.blue50,
                label: 'From',
                location:
                    ride.pickupLocation.isNotEmpty
                        ? ride.pickupLocation
                        : currentLocationName,
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 12.h),
                child: Row(
                  children: [
                    SizedBox(width: 18.w),
                    Container(
                      width: 2.w,
                      height: 24.h,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            appColors.blue600.withOpacity(0.3),
                            appColors.pink500.withOpacity(0.3),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              _buildLocationRow(
                icon: Icons.location_on,
                iconColor: appColors.pink500,
                iconBgColor: appColors.pink50,
                label: 'To',
                location: ride.destinationLocation,
              ),
              if (ride.additionalNotes != null &&
                  ride.additionalNotes!.isNotEmpty) ...[
                SizedBox(height: 16.h),
                Divider(color: appColors.gray200, height: 1),
                SizedBox(height: 16.h),
                _buildNotesSection(),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLocationRow({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String label,
    required String location,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36.w,
          height: 36.h,
          decoration: BoxDecoration(color: iconBgColor, shape: BoxShape.circle),
          child: Icon(icon, size: 18.sp, color: iconColor),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: appFonts.textSmMedium.copyWith(
                  color: appColors.textSecondary,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                location,
                style: appFonts.textSmMedium.copyWith(
                  color: appColors.textPrimary,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNotesSection() {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: appColors.gray200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.note_outlined,
                size: 16.sp,
                color: appColors.textSecondary,
              ),
              SizedBox(width: 6.w),
              Text(
                'Additional Notes',
                style: appFonts.textSmMedium.copyWith(
                  color: appColors.textSecondary,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            ride.additionalNotes ?? '',
            style: appFonts.textSmMedium.copyWith(
              color: appColors.textPrimary,
              fontSize: 13.sp,
              fontWeight: FontWeight.w400,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAcceptButton() {
    return Container(
      width: double.infinity,
      height: 52.h,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [appColors.pink500, appColors.pink600],
        ),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: appColors.pink500.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onAccept,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          padding: EdgeInsets.zero,
        ),
        child: Text(
          'Accept ride',
          style: appFonts.textSmMedium.copyWith(
            color: Colors.white,
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }
}
