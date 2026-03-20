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
import 'package:ridenowappsss/shared/widgets/ridenow_button.dart';
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

  bool _isLoading = false;

  Future<void> _handleContinue() async {
    if (_selectedUserType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select a user type to continue'),
          backgroundColor:
              Theme.of(context).extension<AppColorExtension>()!.red300,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      final success = await authProvider.completeSignUp(
        firstName: '',
        lastName: '',
        phone: '',
        userType: _selectedUserType!.name,
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        if (success) {
          context.goNamed(
            RouteConstants.verifyAccount,
            extra: {'email': authProvider.tempEmail},
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(authProvider.errorMessage ?? 'Sign up failed'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('An unexpected error occurred'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
            // UserTypeOption(
            //   title: 'Vendor',
            //   isSelected: _selectedUserType == UserType.vendor,
            //   onTap: () => _onSelectUserType(UserType.vendor),
            //   svgImage: 'assets/vendor.png',
            // ),
            SizedBox(height: 28.h),
            RideNowButton(
              title: _isLoading ? 'Processing...' : 'Continue',
              onTap: _isLoading ? null : _handleContinue,
              isLoading: _isLoading,
              width: 349.w,
              leadingIcon: _isLoading ? null : SvgPicture.asset('assets/forwardArrow.svg'),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
