// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:ridenowappsss/core/navigation/bottom_navigation.dart';

class RideNowBottomSheet extends StatelessWidget {
  final double? height;
  final double? width;
  final Color? backgroundColor;
  final double? borderRadius;
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final bool isDismissible;
  final bool enableDrag;

  const RideNowBottomSheet({
    super.key,
    this.height,
    this.width,
    this.backgroundColor,
    this.borderRadius,
    required this.child,
    this.padding,
    this.isDismissible = true,
    this.enableDrag = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height ?? 432.h,
      width: width ?? double.infinity,
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(borderRadius ?? 16.r),
          topRight: Radius.circular(borderRadius ?? 16.r),
        ),
      ),
      child: Column(
        children: [
          if (enableDrag) ...[
            SizedBox(height: 8.h),
            Container(
              height: 4.h,
              width: 32.w,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(height: 16.h),
          ],
          Expanded(
            child: Padding(
              padding: padding ?? EdgeInsets.symmetric(horizontal: 16.w),
              child: child,
            ),
          ),
        ],
      ),
    );
  }

  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    double? height,
    double? width,
    Color? backgroundColor,
    double? borderRadius,
    EdgeInsetsGeometry? padding,
    bool isDismissible = true,
    bool enableDrag = true,
    bool isScrollControlled = true,
    Color? barrierColor,
    bool hideBottomNav = true,
  }) {
    if (hideBottomNav) {
      final navProvider = Provider.of<BottomNavVisibilityProvider>(
        context,
        listen: false,
      );
      navProvider.hide();
    }

    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: isScrollControlled,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      backgroundColor: Colors.transparent,
      barrierColor:
          barrierColor ??
          (hideBottomNav
              ? Colors.black.withOpacity(0.75)
              : Colors.black.withOpacity(0.5)),
      builder:
          (context) => RideNowBottomSheet(
            height: height,
            width: width,
            backgroundColor: backgroundColor,
            borderRadius: borderRadius,
            padding: padding,
            isDismissible: isDismissible,
            enableDrag: enableDrag,
            child: child,
          ),
    ).whenComplete(() {
      if (hideBottomNav) {
        final navProvider = Provider.of<BottomNavVisibilityProvider>(
          context,
          listen: false,
        );
        navProvider.show();
      }
    });
  }
}
