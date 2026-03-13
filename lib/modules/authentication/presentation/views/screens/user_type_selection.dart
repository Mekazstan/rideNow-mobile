// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:ridenowappsss/core/navigation/route_constant.dart';
import 'package:ridenowappsss/core/utils/extensions/app_color_extension.dart';
import 'package:ridenowappsss/core/utils/extensions/app_font_extension.dart';
import 'package:ridenowappsss/modules/authentication/presentation/providers/user_provider.dart';
import 'package:ridenowappsss/modules/authentication/presentation/views/screens/user_type_option.dart';
import 'package:ridenowappsss/shared/widgets/ridenow_scaffold.dart';

class UserTypeSelectionView extends StatefulWidget {
  const UserTypeSelectionView({super.key});

  @override
  State<UserTypeSelectionView> createState() => _UserTypeSelectionViewState();
}

class _UserTypeSelectionViewState extends State<UserTypeSelectionView> {
  UserType? _selectedUserType;

  void _onSelectUserType(UserType type) {
    setState(() {
      _selectedUserType = type;
    });

    // Store temporarily in UserProvider for pre-auth selection
    Provider.of<UserProvider>(context, listen: false).setUserType(type);
  }

  void _handleContinue() {
    if (_selectedUserType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select a user type to continue'),
          backgroundColor:
              Theme.of(context).extension<AppColorExtension>()!.red300,
        ),
      );
      return;
    }

    context.goNamed(RouteConstants.login);
  }

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorExtension>()!;
    final appFonts = Theme.of(context).extension<AppFontThemeExtension>()!;

    return RidenowScaffold(
      showFirstImage: false,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 21.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 60.h),
            Text(
              'What type of\nuser are you?',
              style: appFonts.heading1Bold.copyWith(
                color: appColors.textSecondary,
                letterSpacing: -1,
                fontSize: 32,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 41.h),
            UserTypeOption(
              title: 'Rider',
              isSelected: _selectedUserType == UserType.rider,
              onTap: () => _onSelectUserType(UserType.rider),
              svgImage: 'assets/rider.png',
            ),
            UserTypeOption(
              title: 'Driver',
              isSelected: _selectedUserType == UserType.driver,
              onTap: () => _onSelectUserType(UserType.driver),
              svgImage: 'assets/driver.png',
            ),
            UserTypeOption(
              title: 'Vendor',
              isSelected: _selectedUserType == UserType.vendor,
              onTap: () => _onSelectUserType(UserType.vendor),
              svgImage: 'assets/vendor.png',
            ),
            SizedBox(height: 28.h),
            GestureDetector(
              onTap: _handleContinue,
              child: Container(
                height: 42.h,
                width: 349.w,
                decoration: BoxDecoration(
                  color:
                      _selectedUserType != null
                          ? appColors.blue600
                          : appColors.blue600.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset('assets/forwardArrow.svg'),
                      SizedBox(width: 8.w),
                      Text(
                        'Continue',
                        style: appFonts.textMdBold.copyWith(
                          color: appColors.textWhite,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
