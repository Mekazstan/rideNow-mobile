// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ridenowappsss/shared/widgets/shimmer_widget.dart';

/// Shimmer for the map section while loading
class MapSectionShimmer extends StatelessWidget {
  const MapSectionShimmer({super.key});

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

        // Top bar shimmer
        Positioned(
          top: 15.h,
          left: 20.w,
          right: 20.w,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Navigation button shimmer
              ShimmerBox(width: 40.w, height: 40.h, borderRadius: 8.r),
              // Ride mode toggle shimmer
              ShimmerBox(width: 120.w, height: 40.h, borderRadius: 25.r),
            ],
          ),
        ),
      ],
    );
  }
}

/// Shimmer for location input section
class LocationInputSectionShimmer extends StatelessWidget {
  const LocationInputSectionShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25.r),
          topRight: Radius.circular(25.r),
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
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 24.h),
            // Title shimmer
            ShimmerBox(width: 220.w, height: 20.h, borderRadius: 4.r),
            SizedBox(height: 20.h),
            // Pickup field shimmer
            ShimmerBox(width: double.infinity, height: 50.h, borderRadius: 8.r),
            SizedBox(height: 12.h),
            // Destination field shimmer
            ShimmerBox(width: double.infinity, height: 50.h, borderRadius: 8.r),
            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }
}

/// Shimmer for location suggestions list
class LocationSuggestionsShimmer extends StatelessWidget {
  final int itemCount;

  const LocationSuggestionsShimmer({super.key, this.itemCount = 3});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxHeight: 200.h),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: itemCount,
        separatorBuilder: (context, index) => SizedBox(height: 8.h),
        itemBuilder:
            (context, index) => Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              child: Row(
                children: [
                  ShimmerBox(width: 24.w, height: 24.h, borderRadius: 12.r),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ShimmerBox(
                          width: double.infinity,
                          height: 14.h,
                          borderRadius: 4.r,
                        ),
                        SizedBox(height: 6.h),
                        ShimmerBox(
                          width: 200.w,
                          height: 12.h,
                          borderRadius: 4.r,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
      ),
    );
  }
}

/// Shimmer for driver card in vehicle selection sheet
class DriverCardShimmer extends StatelessWidget {
  const DriverCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          // Avatar shimmer
          AvatarShimmer(size: 56.w),
          SizedBox(width: 12.w),
          // Driver info shimmer
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerBox(width: 140.w, height: 16.h, borderRadius: 4.r),
                SizedBox(height: 6.h),
                Row(
                  children: [
                    ShimmerBox(width: 60.w, height: 12.h, borderRadius: 4.r),
                    SizedBox(width: 8.w),
                    ShimmerBox(width: 80.w, height: 12.h, borderRadius: 4.r),
                  ],
                ),
                SizedBox(height: 6.h),
                ShimmerBox(width: 100.w, height: 12.h, borderRadius: 4.r),
              ],
            ),
          ),
          SizedBox(width: 12.w),
          // Price shimmer
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              ShimmerBox(width: 70.w, height: 20.h, borderRadius: 4.r),
              SizedBox(height: 6.h),
              ShimmerBox(width: 50.w, height: 12.h, borderRadius: 4.r),
            ],
          ),
        ],
      ),
    );
  }
}

/// Shimmer for driver offers list
class DriverOffersListShimmer extends StatelessWidget {
  final int itemCount;

  const DriverOffersListShimmer({super.key, this.itemCount = 3});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      itemBuilder: (context, index) => const DriverCardShimmer(),
    );
  }
}

/// Shimmer for vehicle selection bottom sheet
class VehicleSelectionShimmer extends StatelessWidget {
  const VehicleSelectionShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header shimmer
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ShimmerBox(width: 150.w, height: 20.h, borderRadius: 4.r),
              ShimmerBox(width: 24.w, height: 24.h, borderRadius: 12.r),
            ],
          ),
          SizedBox(height: 16.h),
          // Destination shimmer
          ShimmerBox(width: 250.w, height: 14.h, borderRadius: 4.r),
          SizedBox(height: 20.h),
          // Wallet balance shimmer
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerBox(width: 80.w, height: 12.h, borderRadius: 4.r),
                    SizedBox(height: 6.h),
                    ShimmerBox(width: 120.w, height: 24.h, borderRadius: 4.r),
                  ],
                ),
                ShimmerBox(width: 80.w, height: 36.h, borderRadius: 8.r),
              ],
            ),
          ),
          SizedBox(height: 20.h),
          // Tab shimmer (Accepted/Pending)
          Row(
            children: [
              ShimmerBox(width: 100.w, height: 40.h, borderRadius: 8.r),
              SizedBox(width: 12.w),
              ShimmerBox(width: 100.w, height: 40.h, borderRadius: 8.r),
            ],
          ),
          SizedBox(height: 16.h),
          // Driver list shimmer
          const DriverOffersListShimmer(itemCount: 2),
        ],
      ),
    );
  }
}

/// Shimmer for route drawing on map
class RouteShimmer extends StatelessWidget {
  const RouteShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(20.w),
      padding: EdgeInsets.all(16.w),
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
      child: Row(
        children: [
          ShimmerBox(width: 40.w, height: 40.h, borderRadius: 20.r),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerBox(
                  width: double.infinity,
                  height: 14.h,
                  borderRadius: 4.r,
                ),
                SizedBox(height: 8.h),
                ShimmerBox(width: 150.w, height: 12.h, borderRadius: 4.r),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Shimmer for ride confirmation dialog
class RideConfirmationShimmer extends StatelessWidget {
  const RideConfirmationShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AvatarShimmer(size: 80.w),
            SizedBox(height: 16.h),
            ShimmerBox(width: 180.w, height: 20.h, borderRadius: 4.r),
            SizedBox(height: 12.h),
            ShimmerBox(width: 140.w, height: 14.h, borderRadius: 4.r),
            SizedBox(height: 24.h),
            // Trip details shimmer
            ...List.generate(
              3,
              (index) => Padding(
                padding: EdgeInsets.only(bottom: 12.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ShimmerBox(width: 100.w, height: 14.h, borderRadius: 4.r),
                    ShimmerBox(width: 120.w, height: 14.h, borderRadius: 4.r),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20.h),
            // Buttons shimmer
            Row(
              children: [
                Expanded(child: ButtonShimmer(height: 48.h, borderRadius: 8.r)),
                SizedBox(width: 12.w),
                Expanded(child: ButtonShimmer(height: 48.h, borderRadius: 8.r)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
