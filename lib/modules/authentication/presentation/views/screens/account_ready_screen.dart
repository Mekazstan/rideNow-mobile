import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:ridenowappsss/core/navigation/route_constant.dart';
import 'package:ridenowappsss/core/utils/extensions/app_color_extension.dart';
import 'package:ridenowappsss/core/utils/extensions/app_font_extension.dart';
import 'package:ridenowappsss/modules/authentication/presentation/providers/auth_provider.dart';
import 'package:ridenowappsss/shared/widgets/ridenow_button.dart';
import 'package:ridenowappsss/shared/widgets/ridenow_scaffold.dart';

class AccountReadyScreen extends StatefulWidget {
  const AccountReadyScreen({super.key});

  @override
  State<AccountReadyScreen> createState() => _AccountReadyScreenState();
}

class _AccountReadyScreenState extends State<AccountReadyScreen> {
  bool _isNavigating = false;

  Future<void> _onGetStarted(BuildContext context) async {
    if (_isNavigating) return;
    setState(() => _isNavigating = true);

    try {
      // Refresh profile so we pick up the updated currentRole from the backend
      // (backend sets currentRole='driver' upon onboarding completion).
      final authProvider = context.read<AuthProvider>();
      await authProvider.fetchProfile();

      if (kDebugMode) {
        print('[AccountReadyScreen] Profile refreshed.');
        print('  userType    = ${authProvider.user?.userType}');
        print('  currentRole = ${authProvider.user?.currentRole}');
      }
    } catch (e) {
      if (kDebugMode) print('[AccountReadyScreen] Profile refresh error: $e');
    }

    if (mounted) {
      context.goNamed(RouteConstants.ride);
    }
  }

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
                  'Let\u2019s ride now.',
                  style: appFonts.heading1Bold.copyWith(
                    fontSize: 28.sp,
                    color: appColors.textPrimary,
                    height: 1.1,
                  ),
                ),
                SizedBox(height: 32.h),
                RideNowButton(
                  title: _isNavigating ? 'Loading...' : 'Find your first ride',
                  onTap: _isNavigating ? null : () => _onGetStarted(context),
                  width: 200.w,
                  height: 54.h,
                ),
              ],
            ),
          ),

          // Driver Image at the vertical center-left
          // Align(
          //   alignment: Alignment.centerLeft,
          //   child: Padding(
          //     padding: EdgeInsets.only(top: 100.h),
          //     child: Image.asset(
          //       'assets/onbb3.png',
          //       fit: BoxFit.contain,
          //       width: 300.w,
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}
