// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:ridenowappsss/core/services/toast_service.dart';
import 'package:ridenowappsss/core/utils/extensions/app_color_extension.dart';
import 'package:ridenowappsss/core/utils/extensions/app_font_extension.dart';
import 'package:ridenowappsss/modules/authentication/presentation/providers/auth_provider.dart';
import 'package:ridenowappsss/shared/widgets/ridenow_button.dart';
import 'package:ridenowappsss/shared/widgets/ridenow_scaffold.dart';
import 'package:ridenowappsss/shared/widgets/ridenow_textfield.dart';

// Screen 1: Recover Password - Email Input
class RecoverPasswordScreen extends StatefulWidget {
  const RecoverPasswordScreen({super.key});

  @override
  State<RecoverPasswordScreen> createState() => _RecoverPasswordScreenState();
}

class _RecoverPasswordScreenState extends State<RecoverPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorExtension>()!;
    final appFonts = Theme.of(context).extension<AppFontThemeExtension>()!;

    return RidenowScaffold(
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 19),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 58.h),
                  Text(
                    'Let\'s recover your password',
                    style: appFonts.heading1Bold.copyWith(
                      fontSize: 32.sp,
                      fontWeight: FontWeight.w600,
                      color: appColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Enter your email and we\'ll send you a recovery link',
                    style: appFonts.textBaseRegular.copyWith(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w400,
                      color: appColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: 40.h),
                  RidenowTextfield(
                    fieldName: 'Email',
                    hintText: 'onwukapraisejunior@gmail.com',
                    controller: _emailController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!value.contains('@')) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 32.h),
                  _buildSendLinkButton(authProvider, appColors, appFonts),
                  const Spacer(),
                  _buildBackToSignIn(appColors, appFonts),
                  SizedBox(height: 40.h),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSendLinkButton(
    AuthProvider authProvider,
    AppColorExtension appColors,
    AppFontThemeExtension appFonts,
  ) {
    return RideNowButton(
      title: authProvider.isLoading ? 'Sending...' : 'Send link',
      onTap: _handleSendLink,
      isLoading: authProvider.isLoading,
      width: 200.w,
    );
  }

  Widget _buildBackToSignIn(
    AppColorExtension appColors,
    AppFontThemeExtension appFonts,
  ) {
    return Center(
      child: TextButton(
        onPressed: () => context.pop(),
        child: Text(
          'Back to Sign in',
          style: appFonts.textMdRegular.copyWith(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: appColors.textPrimary,
          ),
        ),
      ),
    );
  }

  Future<void> _handleSendLink() async {
    if (!_formKey.currentState!.validate()) return;
    ToastService.showSuccess('Recovery link sent!');
  }
}

// Screen 2: Reset Password - New Password Input
class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
    });
  }

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorExtension>()!;
    final appFonts = Theme.of(context).extension<AppFontThemeExtension>()!;

    return RidenowScaffold(
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 19),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 58.h),
                  Text(
                    'Enter your new password',
                    style: appFonts.heading1Bold.copyWith(
                      fontSize: 32.sp,
                      fontWeight: FontWeight.w600,
                      color: appColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 40.h),
                  RidenowTextfield(
                    fieldName: 'New password',
                    hintText: '**********',
                    controller: _newPasswordController,
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20.h),
                  RidenowTextfield(
                    fieldName: 'Confirm password',
                    hintText: '**********',
                    controller: _confirmPasswordController,
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please confirm your password';
                      }
                      if (value != _newPasswordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 32.h),
                  _buildCompleteButton(authProvider, appColors, appFonts),
                  const Spacer(),
                  _buildBackToSignIn(appColors, appFonts),
                  SizedBox(height: 40.h),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCompleteButton(
    AuthProvider authProvider,
    AppColorExtension appColors,
    AppFontThemeExtension appFonts,
  ) {
    return RideNowButton(
      title: authProvider.isLoading ? 'Completing...' : 'Complete',
      onTap: _handleComplete,
      isLoading: authProvider.isLoading,
      width: 200.w,
    );
  }

  Widget _buildBackToSignIn(
    AppColorExtension appColors,
    AppFontThemeExtension appFonts,
  ) {
    return Center(
      child: TextButton(
        onPressed: () => context.pop(),
        child: Text(
          'Back to Sign in',
          style: appFonts.textMdRegular.copyWith(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: appColors.textPrimary,
          ),
        ),
      ),
    );
  }

  Future<void> _handleComplete() async {
    if (!_formKey.currentState!.validate()) return;
    ToastService.showSuccess('Password reset successful!');

    context.pop();
  }
}
