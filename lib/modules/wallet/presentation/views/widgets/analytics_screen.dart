// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:ridenowappsss/core/utils/extensions/app_color_extension.dart';
import 'package:ridenowappsss/modules/authentication/presentation/providers/auth_provider.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:ridenowappsss/shared/widgets/navigation_button.dart';
import 'package:ridenowappsss/shared/widgets/ride_now_side_menu.dart';
import 'package:ridenowappsss/shared/widgets/ride_now_side_menu_driver.dart';
import 'package:ridenowappsss/core/utils/extensions/amount_extension_validations_utils.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
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
              SizedBox(height: 24.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,

                children: [
                  NavigationButton(appColors: appColors),
                  Spacer(),
                  Text(
                    textAlign: TextAlign.center,
                    'Analytics',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  Spacer(),
                ],
              ),
              SizedBox(height: 25.h),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionHeader('This month'),
                      SizedBox(height: 12.h),
                      _buildMetricsGrid(),
                      SizedBox(height: 32.h),
                      _buildSectionHeader('Peak Earning Locations'),
                      SizedBox(height: 16.h),
                      _buildEarningsChart(),
                      SizedBox(height: 24.h),
                    ],
                  ),
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

  Widget _buildSectionHeader(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        Icon(
          Icons.filter_list_outlined,
          size: 22.sp,
          color: Colors.pink.shade300,
        ),
      ],
    );
  }

  Widget _buildMetricsGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16.w,
      mainAxisSpacing: 16.h,
      childAspectRatio: 0.95,
      children: [
        _buildMetricCard(
          imagePath: 'assets/revenue.svg',
          iconColor: Colors.orange.shade400,
          backgroundColor: Colors.orange.shade50,
          title: 'Total revenue\ngenerated',
          value: 567900.67.formatAmountWithCurrency(),
        ),
        _buildMetricCard(
          imagePath: 'assets/ridess.svg',
          iconColor: Colors.pink.shade400,
          backgroundColor: Colors.pink.shade50,
          title: 'Rides\ncompleted',
          value: '300 rides',
        ),
        _buildMetricCard(
          imagePath: 'assets/stars.svg',
          iconColor: Colors.green.shade400,
          backgroundColor: Colors.green.shade50,
          title: 'Avg rating',
          value: '4.5',
        ),
        _buildMetricCard(
          iconColor: Colors.blue.shade400,
          backgroundColor: Colors.blue.shade50,
          title: 'Total distance\ncovered',
          value: '3000km',
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    String? imagePath,
    required Color iconColor,
    required Color backgroundColor,
    required String title,
    required String value,
  }) {
    return Container(
      height: 155.h,
      width: 169.w,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(12.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SvgPicture.asset(imagePath ?? '', width: 28.w, height: 28.h),
            SizedBox(height: 8.h),
            Text(
              title,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: iconColor.withOpacity(0.9),
                height: 1.3,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              value,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEarningsChart() {
    final appColors = Theme.of(context).extension<AppColorExtension>()!;
    final locations = [
      _LocationEarning('Maitama', 0.7, 96300),
      _LocationEarning('Wuse', 0.45, 67260.33),
      _LocationEarning('Jabi', 0.35, 67260.33),
      _LocationEarning('Gwagwalada', 0.35, 67260.33),
      _LocationEarning('Wuye', 0.3, 56780),
    ];

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        children:
            locations.map((location) {
              return Padding(
                padding: EdgeInsets.only(bottom: 16.h),
                child: _buildLocationBar(location, appColors),
              );
            }).toList(),
      ),
    );
  }

  Widget _buildLocationBar(
    _LocationEarning location,
    AppColorExtension appColors,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          location.name,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 8.h),
        Row(
          children: [
            Expanded(
              child: LinearPercentIndicator(
                padding: EdgeInsets.zero,
                lineHeight: 8.h,
                percent: location.percentage,
                backgroundColor: Colors.grey.shade200,
                progressColor: appColors.blue600,
                barRadius: Radius.circular(4.r),
                animation: true,
                animationDuration: 2000,
                curve: Curves.easeOutCubic,
              ),
            ),
            SizedBox(width: 12.w),
            Text(
              location.amount.formatAmountWithCurrency(),
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ],
    );
  }
}



class _LocationEarning {
  final String name;
  final double percentage;
  final double amount;

  _LocationEarning(this.name, this.percentage, this.amount);
}
