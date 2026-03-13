// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ridenowappsss/core/utils/extensions/app_color_extension.dart';
import 'package:ridenowappsss/core/utils/extensions/app_font_extension.dart';
import 'package:ridenowappsss/shared/widgets/ridenow_button.dart';

class PaymentPlans extends StatelessWidget {
  const PaymentPlans({
    super.key,
    required this.appColors,
    required this.appFonts,
    required this.planTitle,
    required this.price,
    required this.description,
    required this.isSelected,
    required this.onTap,
    required this.index,
    this.showRecommended = false,
    this.onSeeDetails,
    this.onChoosePlan,
  });

  final AppColorExtension appColors;
  final AppFontThemeExtension appFonts;
  final String planTitle;
  final String price;
  final String description;
  final bool isSelected;
  final VoidCallback onTap;
  final int index;
  final bool showRecommended;
  final VoidCallback? onSeeDetails;
  final VoidCallback? onChoosePlan;

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorExtension>()!;
    final appFonts = Theme.of(context).extension<AppFontThemeExtension>()!;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 351.w,
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          color: isSelected ? appColors.blue50 : Colors.grey[50],
          border: Border.all(
            color: isSelected ? appColors.blue700 : Colors.grey[300]!,
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  planTitle,
                  style: appFonts.heading1Bold.copyWith(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                  ),
                ),
                if (showRecommended)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20.r),
                      color: Colors.pink,
                    ),
                    child: Text(
                      'Recommended',
                      style: appFonts.heading1Bold.copyWith(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 8.h),
            Text(
              price,
              style: appFonts.heading1Bold.copyWith(
                fontSize: 24.sp,
                fontWeight: FontWeight.w700,
                color: appColors.blue600,
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              description,
              style: appFonts.heading1Bold.copyWith(
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
                color: Colors.grey[600],
                height: 1.4,
              ),
            ),
            SizedBox(height: 24.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                RideNowButton(
                  title: 'Choose plan',
                  onTap: onChoosePlan ?? () {},
                  width: 120.w,
                  height: 45.h,
                ),
                GestureDetector(
                  onTap: onSeeDetails,
                  child: Row(
                    children: [
                      Text(
                        'See details',
                        style: appFonts.heading1Bold.copyWith(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w400,
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Icon(
                        Icons.keyboard_arrow_down,
                        color: Colors.grey[600],
                        size: 20.sp,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
