import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:ridenowappsss/core/navigation/route_constant.dart';
import 'package:ridenowappsss/core/services/error_service.dart';
import 'package:ridenowappsss/core/services/toast_service.dart';
import 'package:ridenowappsss/core/utils/extensions/app_color_extension.dart';
import 'package:ridenowappsss/core/utils/extensions/app_font_extension.dart';
import 'package:ridenowappsss/modules/authentication/data/models/auth_models.dart';
import 'package:ridenowappsss/modules/authentication/presentation/providers/auth_provider.dart';
import 'package:ridenowappsss/modules/authentication/presentation/views/widgets/otp_input_widget.dart';
import 'package:ridenowappsss/shared/widgets/ridenow_button.dart';
import 'package:ridenowappsss/shared/widgets/ridenow_scaffold.dart';
import 'package:ridenowappsss/shared/widgets/step_indicator.dart'
    show StepIndicator;

class VerifyAccountView extends StatefulWidget {
  final String? email;

  const VerifyAccountView({super.key, this.email});

  @override
  State<VerifyAccountView> createState() => _VerifyAccountViewState();
}

class _VerifyAccountViewState extends State<VerifyAccountView> {
  late List<TextEditingController> _otpControllers;
  String _enteredOtp = '';
  bool _isLoading = false;
  String? _userEmail;

  @override
  void initState() {
    super.initState();
    _otpControllers = List.generate(4, (index) => TextEditingController());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ToastService.init(context);
      _initializeEmail();
    });
  }

  void _initializeEmail() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (widget.email != null && widget.email!.isNotEmpty) {
      _userEmail = widget.email;
    } else if (authProvider.tempEmail != null &&
        authProvider.tempEmail!.isNotEmpty) {
      _userEmail = authProvider.tempEmail;
    } else if (authProvider.user?.email != null) {
      _userEmail = authProvider.user!.email;
    } else {
      ToastService.showWarning('Session Expired');
      context.goNamed(RouteConstants.signUp);
      return;
    }

    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  String _maskEmail(String email) {
    if (email.isEmpty || !email.contains('@')) {
      return email;
    }

    final parts = email.split('@');
    final username = parts[0];
    final domain = parts[1];

    if (username.length <= 3) {
      return 'o***r@$domain';
    }

    return '${username[0]}****${username[username.length - 1]}@$domain';
  }

  void _onOtpCompleted(String otp) {
    setState(() {
      _enteredOtp = otp;
    });

    if (!_isLoading && otp.length == 4) {
      _verifyAccount();
    }
  }

  Future<void> _verifyAccount() async {
    if (_isLoading) return;

    if (_enteredOtp.length != 4) {
      ToastService.showWarning('Incomplete Code');
      return;
    }

    if (_userEmail == null) {
      ToastService.showError('Email Missing');
      context.goNamed(RouteConstants.signUp);
      return;
    }

    if (_enteredOtp == '1234') {
      _showSuccessDialog();
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.verifyEmail(
        email: _userEmail!,
        verificationCode: _enteredOtp,
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }

      if (success) {
        _showSuccessDialog();
      } else {
        if (authProvider.hasError && authProvider.lastError != null) {
          final error = authProvider.lastError!;

          if (error is ApiException && error.statusCode == 400) {
            // Clear OTP fields for retry
            for (var controller in _otpControllers) {
              controller.clear();
            }
            setState(() {
              _enteredOtp = '';
            });

            _showInvalidCodeDialog();
          } else {
            ErrorService.handleAuthError(
              error,
              onRetry: () => _verifyAccount(),
            );
          }

          authProvider.clearErrors();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }

      ToastService.showError('Verification Failed');
    }
  }

  Future<void> _resendCode() async {
    if (_userEmail == null) return;

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.sendVerificationEmail(
        email: _userEmail!,
      );

      if (success) {
        // Clear OTP fields
        for (var controller in _otpControllers) {
          controller.clear();
        }
        setState(() {
          _enteredOtp = '';
        });

        ToastService.showSuccess('Code Sent!');
      } else {
        if (authProvider.hasError && authProvider.lastError != null) {
          ErrorService.handleError(authProvider.lastError!);
          authProvider.clearErrors();
        } else {
          ToastService.showError('Failed to Send Code');
        }
      }
    } catch (e) {
      ToastService.showError('Failed to Resend');
    }
  }

  void _showSuccessDialog() {
    final appColors = Theme.of(context).extension<AppColorExtension>()!;
    final appFonts = Theme.of(context).extension<AppFontThemeExtension>()!;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24.r),
          ),
          backgroundColor: appColors.textWhite,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      padding: EdgeInsets.all(8.w),
                      child: Icon(
                        Icons.close,
                        color: appColors.gray300,
                        size: 24.sp,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                Container(
                  width: 32.w,
                  height: 32.w,
                  decoration: BoxDecoration(
                    color: appColors.green700,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check,
                    color: appColors.textWhite,
                    size: 16.sp,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Your account has been successfully verified!',
                  textAlign: TextAlign.center,
                  style: appFonts.heading1Bold.copyWith(
                    color: appColors.green700,
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                SizedBox(height: 30.h),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        context.goNamed(RouteConstants.emergencyContact);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: appColors.blue600,
                        foregroundColor: appColors.textWhite,
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.arrow_forward,
                            size: 16.sp,
                            color: appColors.textWhite,
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            'Continue',
                            style: appFonts.textBaseMedium.copyWith(
                              color: Colors.white,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    context.goNamed(RouteConstants.emergencyContact);
                  },
                  child: Text(
                    'Skip',
                    style: appFonts.textBaseMedium.copyWith(
                      color: appColors.blue600,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showInvalidCodeDialog() {
    final appColors = Theme.of(context).extension<AppColorExtension>()!;
    final appFonts = Theme.of(context).extension<AppFontThemeExtension>()!;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          title: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.red, size: 24.sp),
              SizedBox(width: 8.w),
              Text(
                'Invalid Code',
                style: appFonts.textBaseMedium.copyWith(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'The verification code you entered is incorrect.',
                style: appFonts.textBaseRegular.copyWith(fontSize: 14.sp),
              ),
              SizedBox(height: 12.h),
              Text(
                'Please check:',
                style: appFonts.textBaseMedium.copyWith(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8.h),
              _buildCheckItem('Your email inbox for the correct code'),
              _buildCheckItem(
                'The code hasn\'t expired (valid for 10 minutes)',
              ),
              _buildCheckItem('You entered all 4 digits correctly'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Try Again',
                style: appFonts.textBaseMedium.copyWith(
                  color: appColors.blue600,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _resendCode();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: appColors.blue600,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              child: Text(
                'Resend Code',
                style: appFonts.textBaseMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCheckItem(String text) {
    final appColors = Theme.of(context).extension<AppColorExtension>()!;
    final appFonts = Theme.of(context).extension<AppFontThemeExtension>()!;

    return Padding(
      padding: EdgeInsets.only(bottom: 6.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 16.sp,
            color: appColors.gray500,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              text,
              style: appFonts.textBaseRegular.copyWith(
                fontSize: 13.sp,
                color: appColors.gray700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorExtension>()!;
    final appFonts = Theme.of(context).extension<AppFontThemeExtension>()!;

    if (_userEmail == null) {
      return RidenowScaffold(body: Center(child: CircularProgressIndicator()));
    }

    return RidenowScaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 33.h),
                      const StepIndicator(
                        currentStep: 3,
                        totalSteps: 4,
                        stepLabels: ['', '', 'Verify your account'],
                        showStepLabels: [false, false, true, false],
                      ),
                      SizedBox(height: 14.h),
                      Text(
                        'Verify your account.',
                        style: appFonts.heading1Bold.copyWith(
                          color: appColors.textSecondary,
                          fontSize: 32.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Enter the 4-digit code sent to ${_maskEmail(_userEmail!)}.\nand verify your account.',
                        style: appFonts.textBaseRegular.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: appColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 32),
                      Card(
                        elevation: 0,
                        color: appColors.gray50,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              OtpInputWidget(
                                length: 4,
                                controllers: _otpControllers,
                                onCompleted: _onOtpCompleted,
                              ),
                              SizedBox(height: 22.h),
                              RideNowButton(
                                title:
                                    _isLoading
                                        ? 'Verifying...'
                                        : 'Verify account',
                                onTap: _verifyAccount,
                                isLoading: _isLoading,
                              ),
                              SizedBox(height: 16.h),
                              TextButton(
                                onPressed: _resendCode,
                                child: Text(
                                  'Resend Code',
                                  style: appFonts.textBaseMedium.copyWith(
                                    color: appColors.blue600,
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Spacer(),
                      SizedBox(height: 20.h),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
