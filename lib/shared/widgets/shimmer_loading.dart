// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// A reusable shimmer loading widget that replaces CircularProgressIndicator
/// Provides circular and rectangular shimmer effects
class ShimmerLoading extends StatelessWidget {
  final double? width;
  final double? height;
  final ShimmerShape shape;
  final Color? baseColor;
  final Color? highlightColor;
  final double? borderRadius;

  const ShimmerLoading({
    super.key,
    this.width,
    this.height,
    this.shape = ShimmerShape.circle,
    this.baseColor,
    this.highlightColor,
    this.borderRadius,
  });

  /// Circular shimmer - replaces CircularProgressIndicator
  const ShimmerLoading.circular({
    super.key,
    double? size,
    this.baseColor,
    this.highlightColor,
  }) : width = size,
       height = size,
       shape = ShimmerShape.circle,
       borderRadius = null;

  /// Rectangular shimmer for list items, cards, etc.
  const ShimmerLoading.rectangular({
    super.key,
    this.width,
    this.height,
    this.baseColor,
    this.highlightColor,
    this.borderRadius,
  }) : shape = ShimmerShape.rectangle;

  @override
  Widget build(BuildContext context) {
    final defaultBaseColor = baseColor ?? Colors.grey[300]!;
    final defaultHighlightColor = highlightColor ?? Colors.grey[100]!;

    return Shimmer.fromColors(
      baseColor: defaultBaseColor,
      highlightColor: defaultHighlightColor,
      child: Container(
        width: width ?? (shape == ShimmerShape.circle ? 40.w : null),
        height: height ?? (shape == ShimmerShape.circle ? 40.w : 20.h),
        decoration: BoxDecoration(
          color: defaultBaseColor,
          shape:
              shape == ShimmerShape.circle
                  ? BoxShape.circle
                  : BoxShape.rectangle,
          borderRadius:
              shape == ShimmerShape.rectangle
                  ? BorderRadius.circular(borderRadius?.r ?? 4.r)
                  : null,
        ),
      ),
    );
  }
}

enum ShimmerShape { circle, rectangle }

/// Shimmer for button loading states
class ShimmerButton extends StatelessWidget {
  final double? width;
  final double? height;
  final Color? baseColor;
  final Color? highlightColor;

  const ShimmerButton({
    super.key,
    this.width,
    this.height,
    this.baseColor,
    this.highlightColor,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: baseColor ?? Colors.grey[300]!,
      highlightColor: highlightColor ?? Colors.grey[100]!,
      child: Container(
        width: width ?? double.infinity,
        height: height ?? 48.h,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(12.r),
        ),
      ),
    );
  }
}

/// Shimmer for list items
class ShimmerListTile extends StatelessWidget {
  final double? height;
  final Color? baseColor;
  final Color? highlightColor;

  const ShimmerListTile({
    super.key,
    this.height,
    this.baseColor,
    this.highlightColor,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: baseColor ?? Colors.grey[300]!,
      highlightColor: highlightColor ?? Colors.grey[100]!,
      child: Container(
        height: height ?? 80.h,
        margin: EdgeInsets.symmetric(vertical: 8.h, horizontal: 16.w),
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            Container(
              width: 56.w,
              height: 56.w,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 16.h,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Container(
                    height: 14.h,
                    width: 150.w,
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
