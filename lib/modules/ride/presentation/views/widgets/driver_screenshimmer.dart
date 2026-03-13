// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ridenowappsss/shared/widgets/shimmer_widget.dart';

class DriverMapSectionShimmer extends StatelessWidget {
  const DriverMapSectionShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Main map shimmer
        Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.grey[200],
          child: const ShimmerEffect(child: ColoredBox(color: Colors.white)),
        ),

        // Top left navigation button shimmer
        Positioned(
          top: 15.h,
          left: 20.w,
          child: ShimmerBox(width: 40.w, height: 40.h, borderRadius: 8.r),
        ),

        // Top right mode toggle shimmer
        Positioned(
          top: 15.h,
          right: 20.w,
          child: ShimmerBox(width: 120.w, height: 40.h, borderRadius: 25.r),
        ),

        // Bottom right FABs shimmer
        Positioned(
          right: 20.w,
          bottom: 20.h,
          child: Column(
            children: [
              ShimmerBox(width: 40.w, height: 40.h, borderRadius: 20.r),
              SizedBox(height: 8.h),
              ShimmerBox(width: 40.w, height: 40.h, borderRadius: 20.r),
            ],
          ),
        ),

        // Center loading text
        Center(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ShimmerBox(width: 200.w, height: 16.h, borderRadius: 4.r),
                SizedBox(height: 8.h),
                ShimmerBox(width: 150.w, height: 12.h, borderRadius: 4.r),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Shimmer for driver's bottom sheet - UPDATED to match Figma design
class DriverBottomSheetShimmer extends StatelessWidget {
  const DriverBottomSheetShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 320.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.r),
          topRight: Radius.circular(20.r),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                margin: EdgeInsets.only(top: 12.h),
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            SizedBox(height: 24.h),

            // Title and refresh button shimmer
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ShimmerBox(width: 180.w, height: 20.h, borderRadius: 4.r),
                ShimmerBox(width: 40.w, height: 40.h, borderRadius: 20.r),
              ],
            ),

            SizedBox(height: 10.h),

            // Circular search bar shimmer matching Figma
            ShimmerBox(
              width: double.infinity,
              height: 48.h,
              borderRadius: 24.r, // Fully rounded like in Figma
            ),

            SizedBox(height: 20.h),

            // Ride requests list shimmer
            Expanded(
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 3,
                separatorBuilder: (context, index) => SizedBox(height: 16.h),
                itemBuilder:
                    (context, index) => const DriverRideRequestShimmer(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shimmer for a single ride request card - UPDATED to match Figma (destination only)
class DriverRideRequestShimmer extends StatelessWidget {
  const DriverRideRequestShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Destination location only (no pickup)
          Row(
            children: [
              ShimmerBox(width: 16.w, height: 16.h, borderRadius: 8.r),
              SizedBox(width: 8.w),
              Expanded(
                child: ShimmerBox(
                  width: double.infinity,
                  height: 14.h,
                  borderRadius: 4.r,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),

          // Rider info row
          Row(
            children: [
              // Avatar
              AvatarShimmer(size: 40.r),
              SizedBox(width: 8.w),

              // Rider details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerBox(width: 120.w, height: 14.h, borderRadius: 4.r),
                    SizedBox(height: 4.h),
                    ShimmerBox(width: 80.w, height: 12.h, borderRadius: 4.r),
                  ],
                ),
              ),

              // Badge and price
              Row(
                children: [
                  ShimmerBox(width: 16.w, height: 16.h, borderRadius: 8.r),
                  SizedBox(width: 6.w),
                  ShimmerBox(width: 12.w, height: 14.h, borderRadius: 4.r),
                ],
              ),
              SizedBox(width: 12.w),
              ShimmerBox(width: 60.w, height: 14.h, borderRadius: 4.r),
            ],
          ),
          SizedBox(height: 8.h),

          // Time since created
          ShimmerBox(width: 80.w, height: 12.h, borderRadius: 4.r),
        ],
      ),
    );
  }
}

/// Shimmer for ride requests list
class DriverRideRequestsListShimmer extends StatelessWidget {
  final int itemCount;

  const DriverRideRequestsListShimmer({super.key, this.itemCount = 3});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      separatorBuilder: (context, index) => SizedBox(height: 16.h),
      itemBuilder: (context, index) => const DriverRideRequestShimmer(),
    );
  }
}

/// Shimmer for error state with retry button
class DriverErrorStateShimmer extends StatelessWidget {
  const DriverErrorStateShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ShimmerBox(width: 48.w, height: 48.h, borderRadius: 24.r),
            SizedBox(height: 12.h),
            ShimmerBox(width: 150.w, height: 16.h, borderRadius: 4.r),
            SizedBox(height: 8.h),
            ShimmerBox(width: 200.w, height: 13.h, borderRadius: 4.r),
            SizedBox(height: 16.h),
            ButtonShimmer(width: 120.w, height: 40.h, borderRadius: 8.r),
          ],
        ),
      ),
    );
  }
}

/// Shimmer for empty state
class DriverEmptyStateShimmer extends StatelessWidget {
  const DriverEmptyStateShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ShimmerBox(width: 48.w, height: 48.h, borderRadius: 24.r),
          SizedBox(height: 12.h),
          ShimmerBox(width: 180.w, height: 14.h, borderRadius: 4.r),
          SizedBox(height: 6.h),
          ShimmerBox(width: 150.w, height: 12.h, borderRadius: 4.r),
        ],
      ),
    );
  }
}

/// Shimmer for loading dialog
class DriverLoadingDialogShimmer extends StatelessWidget {
  const DriverLoadingDialogShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ShimmerBox(width: 40.w, height: 40.h, borderRadius: 20.r),
            SizedBox(height: 16.h),
            ShimmerBox(width: 150.w, height: 14.h, borderRadius: 4.r),
          ],
        ),
      ),
    );
  }
}
