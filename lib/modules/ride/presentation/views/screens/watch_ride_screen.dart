// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ridenowappsss/core/utils/extensions/app_color_extension.dart';
import 'package:ridenowappsss/core/utils/extensions/app_font_extension.dart';
import 'package:ridenowappsss/modules/ride/presentation/views/widgets/ride_map_view.dart';

class WatchRideScreen extends StatefulWidget {
  final String rideId;

  const WatchRideScreen({super.key, required this.rideId});

  @override
  State<WatchRideScreen> createState() => _WatchRideScreenState();
}

class _WatchRideScreenState extends State<WatchRideScreen> {
  bool isArrived = false; // Simulation/State flag for Image 3 vs Image 4
  bool isLoading = true; // For Shimmer effect simulation

  @override
  void initState() {
    super.initState();
    _simulateLoading();
  }

  void _simulateLoading() async {
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    // Controller can be used for camera updates if needed
  }

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorExtension>()!;
    final appFonts = Theme.of(context).extension<AppFontThemeExtension>()!;

    return Scaffold(
      body: Stack(
        children: [
          // Map Background
          Positioned.fill(child: MapSection(onMapCreated: _onMapCreated)),

          // Watching Header Banner (Screenshot 1)
          if (!isArrived)
            Positioned(
              top: 60.h,
              left: 20.w,
              right: 20.w,
              child: _buildWatchingBanner(appColors, appFonts),
            ),

          // Arrived Notification (Screenshot 0)
          if (isArrived)
            Positioned(
              top: 60.h,
              left: 20.w,
              right: 20.w,
              child: _buildArrivedBanner(appColors, appFonts),
            ),

          // Bottom Details Sheet
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child:
                isLoading
                    ? _buildShimmerSheet(appColors, appFonts)
                    : _buildObserverBottomSheet(appColors, appFonts),
          ),
        ],
      ),
    );
  }

  Widget _buildWatchingBanner(
    AppColorExtension appColors,
    AppFontThemeExtension appFonts,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 36.w,
            height: 36.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: const DecorationImage(
                image: AssetImage('assets/user.png'), // Placeholder
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              "You're watching Ameh Cindy's ride",
              style: appFonts.textSmMedium.copyWith(
                color: const Color(0xFFE91E63), // Pink
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Icon(Icons.close, color: appColors.gray400, size: 20.sp),
          ),
        ],
      ),
    );
  }

  Widget _buildArrivedBanner(
    AppColorExtension appColors,
    AppFontThemeExtension appFonts,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 36.w,
            height: 36.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: const DecorationImage(
                image: AssetImage('assets/user.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              'Ameh has arrived!',
              style: appFonts.textSmMedium.copyWith(
                color: const Color(0xFF16A34A), // Green
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          GestureDetector(
            onTap: () => setState(() => isArrived = false),
            child: Icon(Icons.close, color: appColors.gray400, size: 20.sp),
          ),
        ],
      ),
    );
  }

  Widget _buildObserverBottomSheet(
    AppColorExtension appColors,
    AppFontThemeExtension appFonts,
  ) {
    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 40.h),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40.w,
              height: 4.h,
              margin: EdgeInsets.only(bottom: 24.h),
              decoration: BoxDecoration(
                color: appColors.gray300,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ),
          if (isArrived)
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: const Color(0xFF16A34A).withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Ameh has arrived at Murtala Mohammed expressway.',
                      style: appFonts.textBaseMedium.copyWith(
                        color: const Color(0xFF16A34A),
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: const BoxDecoration(
                      color: Color(0xFF16A34A),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.check, size: 20.sp, color: Colors.white),
                  ),
                ],
              ),
            )
          else
            Text(
              "Going to Murtala Mohammed expressway.",
              style: appFonts.textBaseMedium.copyWith(
                color: appColors.textPrimary,
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          SizedBox(height: 24.h),

          // Driver Info
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10.r),
                child: Image.asset(
                  'assets/user.png',
                  width: 56.w,
                  height: 56.h,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Driver',
                      style: appFonts.textSmRegular.copyWith(
                        color: appColors.textSecondary,
                        fontSize: 13.sp,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          'Kelechi Eze',
                          style: appFonts.textSmMedium.copyWith(
                            color: appColors.textPrimary,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        _buildRatingBadge(4.0, appColors),
                      ],
                    ),
                    Text(
                      'Nissan 16v 322 Machine',
                      style: appFonts.textSmRegular.copyWith(
                        color: appColors.textSecondary,
                        fontSize: 12.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 32.h),

          // Ride Details
          Row(
            children: [
              Icon(Icons.location_on, color: appColors.blue600, size: 24.sp),
              SizedBox(width: 12.w),
              Text(
                'Ride details',
                style: appFonts.textSmMedium.copyWith(
                  color: appColors.textPrimary,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          _buildRideTimeline(appColors, appFonts),
        ],
      ),
    );
  }

  Widget _buildRideTimeline(
    AppColorExtension appColors,
    AppFontThemeExtension appFonts,
  ) {
    return Stack(
      children: [
        Positioned(
          left: 11.w,
          top: 8.h,
          bottom: 24.h,
          child: Container(
            width: 1.w,
            color: appColors.blue600.withOpacity(0.3),
          ),
        ),
        Column(
          children: [
            _buildTimelineItem(
              'Going to',
              'Murtala Mohammed Expressway',
              appColors,
              appFonts,
              showDot: true,
            ),
            SizedBox(height: 16.h),
            _buildTimelineItem(
              'From',
              'Ibro Fish 1st Avenu',
              appColors,
              appFonts,
              showDot: false,
            ),
            SizedBox(height: 16.h),
            _buildTimelineItem(
              'Vehicle',
              'Tricycle',
              appColors,
              appFonts,
              showDot: false,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTimelineItem(
    String label,
    String value,
    AppColorExtension appColors,
    AppFontThemeExtension appFonts, {
    bool showDot = true,
  }) {
    return Padding(
      padding: EdgeInsets.only(left: 24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: appFonts.textSmRegular.copyWith(
              color: appColors.textSecondary,
              fontSize: 12.sp,
            ),
          ),
          Text(
            value,
            style: appFonts.textBaseMedium.copyWith(
              color: appColors.textPrimary,
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
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
          rating.toInt().toString(),
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w700,
            color: appColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildShimmerSheet(
    AppColorExtension appColors,
    AppFontThemeExtension appFonts,
  ) {
    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 40.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32.r),
          topRight: Radius.circular(32.r),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 40.w, height: 4.h, color: appColors.gray200),
          SizedBox(height: 24.h),
          _buildShimmerItem(double.infinity, 24.h, appColors),
          SizedBox(height: 24.h),
          Row(
            children: [
              _buildShimmerItem(56.w, 56.h, appColors, radius: 10.r),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  children: [
                    _buildShimmerItem(100.w, 14.h, appColors),
                    SizedBox(height: 8.h),
                    _buildShimmerItem(150.w, 18.h, appColors),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 32.h),
          _buildShimmerItem(double.infinity, 100.h, appColors),
        ],
      ),
    );
  }

  Widget _buildShimmerItem(
    double width,
    double height,
    AppColorExtension appColors, {
    double? radius,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: appColors.gray100,
        borderRadius: BorderRadius.circular(radius ?? 4.r),
      ),
    );
  }
}
