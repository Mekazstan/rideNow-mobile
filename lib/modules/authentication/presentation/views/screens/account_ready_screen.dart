import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:ridenowappsss/core/navigation/route_constant.dart';
import 'package:ridenowappsss/core/utils/extensions/app_color_extension.dart';
import 'package:ridenowappsss/core/utils/extensions/app_font_extension.dart';
import 'package:ridenowappsss/shared/widgets/ridenow_button.dart';
import 'package:ridenowappsss/shared/widgets/ridenow_scaffold.dart';

class AccountReadyScreen extends StatelessWidget {
  const AccountReadyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorExtension>()!;
    final appFonts = Theme.of(context).extension<AppFontThemeExtension>()!;

    return RidenowScaffold(
      showFirstImage: true,
      body: Stack(
        children: [
          // Content at the top
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 60.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your account is ready!',
                  style: appFonts.heading1Bold.copyWith(
                    fontSize: 28.sp,
                    color: appColors.textPrimary,
                    height: 1.1,
                  ),
                ),
                Text(
                  'Let’s ride now.',
                  style: appFonts.heading1Bold.copyWith(
                    fontSize: 28.sp,
                    color: appColors.textPrimary,
                    height: 1.1,
                  ),
                ),
                SizedBox(height: 32.h),
                RideNowButton(
                  title: 'Find your first ride',
                  onTap: () {
                    context.goNamed(RouteConstants.ride);
                  },
                  width: 200.w,
                  height: 54.h,
                ),
              ],
            ),
          ),

          // Driver Image at the vertical center-left
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.only(top: 100.h), // Offset slightly to avoid clashing with top text
              child: Image.asset(
                'assets/onbb3.png',
                fit: BoxFit.contain,
                width: 300.w,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
