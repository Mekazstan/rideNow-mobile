// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:ridenowappsss/core/utils/extensions/app_color_extension.dart';
import 'package:ridenowappsss/modules/authentication/presentation/providers/auth_provider.dart';
import 'package:ridenowappsss/shared/widgets/navigation_button.dart';
import 'package:ridenowappsss/shared/widgets/ride_now_side_menu.dart';
import 'package:ridenowappsss/shared/widgets/ride_now_side_menu_driver.dart';
import 'package:ridenowappsss/core/services/toast_service.dart';

class PlansScreen extends StatefulWidget {
  const PlansScreen({super.key});

  @override
  State<PlansScreen> createState() => _PlansScreenState();
}

class _PlansScreenState extends State<PlansScreen> {
  String? selectedPlanId;
  String? expandedPlanId;

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorExtension>()!;

    return Scaffold(
      drawer: _getDrawer(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 21),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              NavigationButton(appColors: appColors),
              SizedBox(height: 17.h),
              Text(
                'Plans',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 24.h),
              Expanded(
                child: ListView(
                  children: [
                    _buildCommissionPlanCard(appColors),
                    SizedBox(height: 16.h),
                    _buildSubscriptionPlanCard(
                      appColors,
                      'monthly',
                      'Monthly Subscription',
                      'N8,000.00',
                      'Pay a weekly fee and drive without charges.',
                      true,
                      [
                        'Drivers pay â‚¦8,000 Weekly',
                        'Capped at 25 rides/day',
                        'Additional rides: â‚¦50 each after daily cap',
                      ],
                    ),
                    SizedBox(height: 16.h),
                    _buildSubscriptionPlanCard(
                      appColors,
                      'weekly',
                      'Weekly Subscription',
                      'N2,000.00',
                      'Pay a weekly fee and drive without charges.',
                      false,
                      [
                        'Drivers pay â‚¦2,000 Weekly',
                        'Capped at 20 rides/day',
                        'Additional rides: â‚¦100 each after daily cap',
                      ],
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

  Widget _getDrawer() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        final userType = authProvider.user?.userType.toLowerCase() ?? 'rider';

        return userType == 'driver'
            ? const RideNowSideMenuDriver()
            : const RideNowSideMenu();
      },
    );
  }

  Widget _buildCommissionPlanCard(AppColorExtension appColors) {
    final isSelected = selectedPlanId == 'commission';
    final isExpanded = expandedPlanId == 'commission';

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedPlanId = isSelected ? null : 'commission';
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          gradient:
              isSelected
                  ? LinearGradient(
                    colors: [appColors.blue600, appColors.blue700],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                  : null,
          color: isSelected ? null : Colors.grey[100],
          border: Border.all(
            color: isSelected ? appColors.blue700 : Colors.grey[300]!,
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Commission Plan',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color:
                    isSelected
                        ? Colors.white.withOpacity(0.9)
                        : Colors.grey[600],
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Free',
              style: TextStyle(
                fontSize: 28.sp,
                fontWeight: FontWeight.w700,
                color: isSelected ? Colors.white : appColors.blue600,
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              '15% commission charged per ride completed',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
                color:
                    isSelected
                        ? Colors.white.withOpacity(0.95)
                        : Colors.grey[600],
                height: 1.4,
              ),
            ),
            SizedBox(height: 16.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6.r),
                    color:
                        isSelected
                            ? Colors.white.withOpacity(0.2)
                            : Colors.grey[300],
                  ),
                  child: Text(
                    'Currently Active',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      color:
                          isSelected
                              ? Colors.white.withOpacity(0.9)
                              : Colors.grey[600],
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      expandedPlanId = isExpanded ? null : 'commission';
                    });
                  },
                  child: Row(
                    children: [
                      Text(
                        'See details',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: isSelected ? Colors.white : Colors.grey[600],
                        ),
                      ),
                      SizedBox(width: 4.w),
                      AnimatedRotation(
                        duration: const Duration(milliseconds: 300),
                        turns: isExpanded ? 0.5 : 0,
                        child: Icon(
                          Icons.keyboard_arrow_down,
                          color: isSelected ? Colors.white : Colors.grey[600],
                          size: 20.sp,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 300),
              crossFadeState:
                  isExpanded
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
              firstChild: const SizedBox.shrink(),
              secondChild: Container(
                margin: EdgeInsets.only(top: 16.h),
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.r),
                  color:
                      isSelected
                          ? Colors.white.withOpacity(0.15)
                          : Colors.white,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '15% commission on each ride',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                        color:
                            isSelected
                                ? Colors.white.withOpacity(0.95)
                                : Colors.grey[700],
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'No upfront payment required',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                        color:
                            isSelected
                                ? Colors.white.withOpacity(0.95)
                                : Colors.grey[700],
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Flexible and pay as you go',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                        color:
                            isSelected
                                ? Colors.white.withOpacity(0.95)
                                : Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubscriptionPlanCard(
    AppColorExtension appColors,
    String planId,
    String planName,
    String price,
    String description,
    bool showRecommended,
    List<String> details,
  ) {
    final isSelected = selectedPlanId == planId;
    final isExpanded = expandedPlanId == planId;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedPlanId = isSelected ? null : planId;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          gradient:
              isSelected
                  ? LinearGradient(
                    colors: [appColors.blue600, appColors.blue700],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                  : null,
          color: isSelected ? null : Colors.grey[100],
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
                  planName,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                    color:
                        isSelected
                            ? Colors.white.withOpacity(0.9)
                            : Colors.grey[600],
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
                      style: TextStyle(
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
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.w700,
                color: isSelected ? Colors.white : appColors.blue600,
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              description,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
                color:
                    isSelected
                        ? Colors.white.withOpacity(0.95)
                        : Colors.grey[600],
                height: 1.4,
              ),
            ),
            SizedBox(height: 24.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {
                    ToastService.showSuccess('$planName selected!');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isSelected ? Colors.white : appColors.blue600,
                    padding: EdgeInsets.symmetric(
                      horizontal: 24.w,
                      vertical: 12.h,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  child: Text(
                    'Choose plan',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? appColors.blue600 : Colors.white,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      expandedPlanId = isExpanded ? null : planId;
                    });
                  },
                  child: Row(
                    children: [
                      Text(
                        'See details',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w400,
                          color: isSelected ? Colors.white : Colors.grey[600],
                        ),
                      ),
                      SizedBox(width: 4.w),
                      AnimatedRotation(
                        duration: const Duration(milliseconds: 300),
                        turns: isExpanded ? 0.5 : 0,
                        child: Icon(
                          Icons.keyboard_arrow_down,
                          color: isSelected ? Colors.white : Colors.grey[600],
                          size: 20.sp,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 300),
              crossFadeState:
                  isExpanded
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
              firstChild: const SizedBox.shrink(),
              secondChild: Container(
                margin: EdgeInsets.only(top: 16.h),
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.r),
                  color:
                      isSelected
                          ? Colors.white.withOpacity(0.15)
                          : Colors.white,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children:
                      details.map((detail) {
                        return Padding(
                          padding: EdgeInsets.only(bottom: 8.h),
                          child: Text(
                            detail,
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w400,
                              color:
                                  isSelected
                                      ? Colors.white.withOpacity(0.95)
                                      : Colors.grey[700],
                            ),
                          ),
                        );
                      }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
