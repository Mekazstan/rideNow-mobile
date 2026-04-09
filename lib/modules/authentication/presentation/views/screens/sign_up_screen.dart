import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:ridenowappsss/core/services/google_signin_service.dart';
import 'package:google_sign_in/google_sign_in.dart' as gsi;
import 'package:ridenowappsss/core/navigation/route_constant.dart';
import 'package:ridenowappsss/core/utils/extensions/app_color_extension.dart';
import 'package:ridenowappsss/core/utils/extensions/app_font_extension.dart';
import 'package:ridenowappsss/shared/widgets/ridenow_button.dart';
import 'package:ridenowappsss/shared/widgets/ridenow_scaffold.dart';
import 'package:ridenowappsss/shared/widgets/ridenow_textfield.dart';
import 'package:ridenowappsss/shared/widgets/app_dialogs.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:ridenowappsss/core/services/toast_service.dart';
import 'package:ridenowappsss/modules/authentication/presentation/providers/auth_provider.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Google Sign In instance
  final gsi.GoogleSignIn _googleSignIn = googleSignInService.instance;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorExtension>()!;
    final appFonts = Theme.of(context).extension<AppFontThemeExtension>()!;

    return RidenowScaffold(
      resizeToAvoidBottomInset: true,
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            if (authProvider.isAuthenticated) {
              final onboardingRoute = await authProvider.getOnboardingRoute(
                immediateStep: authProvider.nextStep,
              );
              if (!context.mounted) return;
              if (onboardingRoute != null) {
                context.goNamed(onboardingRoute);
              } else {
                context.goNamed(RouteConstants.ride);
              }
            }
          });

          return LayoutBuilder(
            builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 19),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 58.h),
                        Text(
                          'Hey there!',
                          style: appFonts.heading1Bold.copyWith(
                            fontSize: 32,
                            fontWeight: FontWeight.w500,
                            color: appColors.textSecondary,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'Sign up to Ridenow',
                          style: appFonts.textBaseRegular.copyWith(
                            color: appColors.textSecondary,
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        SizedBox(height: 32.h),
                        _buildSignUpForm(appColors, appFonts),
                        SizedBox(height: 12.h),
                        _buildDividerText(appColors, appFonts),
                        SizedBox(height: 27.h),
                        _buildSocialSignUpButtons(appColors, appFonts),
                        SizedBox(height: 20.h),
                        _buildSignInLink(appColors, appFonts),
                        const Spacer(),
                        SizedBox(height: 20.h),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            );
          },
        );
        },
      )
    );
  }

  Widget _buildSignUpForm(
    AppColorExtension appColors,
    AppFontThemeExtension appFonts,
  ) {
    return Card(
      elevation: 0,
      color: appColors.gray50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            RidenowTextfield(
              fieldName: 'Email',
              hintText: 'onwukapraisejunior@gmail.com',
              controller: _emailController,
            ),
            SizedBox(height: 16.h),
            RidenowTextfield(
              fieldName: 'Password',
              hintText: '**********',
              controller: _passwordController,
              obscureText: true,
            ),
            SizedBox(height: 16.h),
            RidenowTextfield(
              fieldName: 'Confirm Password',
              hintText: '**********',
              controller: _confirmPasswordController,
              obscureText: true,
            ),
            SizedBox(height: 24.h),
            _buildContinueButton(appColors, appFonts),
          ],
        ),
      ),
    );
  }

  Widget _buildContinueButton(
    AppColorExtension appColors,
    AppFontThemeExtension appFonts,
  ) {
    return RideNowButton(
      title: _isLoading ? 'Processing...' : 'Continue',
      onTap: _handleSignUp,
      isLoading: _isLoading,
      leadingIcon: _isLoading ? null : SvgPicture.asset('assets/forwardArrow.svg'),
    );
  }

  Widget _buildDividerText(
    AppColorExtension appColors,
    AppFontThemeExtension appFonts,
  ) {
    return Column(
      children: [
        Align(
          alignment: Alignment.center,
          child: Text(
            'Or',
            style: appFonts.textMdBold.copyWith(
              color: appColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        SizedBox(height: 7.h),
        Align(
          alignment: Alignment.center,
          child: Text(
            'Sign up with:',
            style: appFonts.textMdRegular.copyWith(
              color: appColors.textPrimary,
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSocialSignUpButtons(
    AppColorExtension appColors,
    AppFontThemeExtension appFonts,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        RideNowButton(
          colorSet: RideNowButtonColorSet.accent,
          width: 127.w,
          height: 42.h,
          title: 'Google',
          variant: RideNowButtonVariant.outlined,
          leadingIcon: SvgPicture.asset(
            'assets/google.svg',
            height: 24,
            width: 24,
          ),
          onTap: _isLoading ? () {} : _handleGoogleSignUp,
        ),
        const SizedBox(width: 16),
        RideNowButton(
          colorSet: RideNowButtonColorSet.accent,
          width: 127.w,
          height: 42.h,
          title: 'Apple',
          variant: RideNowButtonVariant.outlined,
          leadingIcon: SvgPicture.asset(
            'assets/apple.svg',
            height: 16,
            width: 16,
            colorFilter: ColorFilter.mode(appColors.textWhite, BlendMode.srcIn),
          ),
          onTap: _isLoading ? () {} : _handleAppleSignUp,
        ),
      ],
    );
  }

  Widget _buildSignInLink(
    AppColorExtension appColors,
    AppFontThemeExtension appFonts,
  ) {
    return Align(
      alignment: Alignment.center,
      child: RichText(
        text: TextSpan(
          text: "Already have an account? ",
          style: appFonts.textMdRegular.copyWith(
            color: appColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
          children: [
            TextSpan(
              text: 'Sign in',
              style: appFonts.textMdRegular.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                decoration: TextDecoration.underline,
                color: appColors.textPrimary,
              ),
              recognizer:
                  TapGestureRecognizer()
                    ..onTap = () => context.goNamed(RouteConstants.login),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSignUp() async {
    if (_isLoading) return;

    Provider.of<AuthProvider>(context, listen: false).clearErrors();

    final email = _emailController.text;
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (email.trim().isEmpty) {
      ToastService.showError(
        'Email is required',
      );
      return;
    }

    if (!_isValidEmail(email.trim())) {
      ToastService.showError(
        'Invalid Email',
      );
      return;
    }

    if (password.isEmpty) {
      ToastService.showError(
        'Password is required',
      );
      return;
    }

    if (password.length < 6) {
      ToastService.showError(
        'Password Too Short',
      );
      return;
    }

    if (confirmPassword.isEmpty) {
      ToastService.showError(
        'Please confirm your password',
      );
      return;
    }

    if (password != confirmPassword) {
      ToastService.showError(
        'Passwords Do Not Match',
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      authProvider.storeTempSignUpData(
        email: email.trim(),
        password: password,
        confirmPassword: confirmPassword,
      );

      await Future.delayed(const Duration(milliseconds: 100));

      if (mounted) {
        context.goNamed(RouteConstants.userTypeSelection);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleGoogleSignUp() async {
    if (_isLoading) return;

    try {
      setState(() => _isLoading = true);
      ToastService.showInfo('Signing up with Google...');

      // Sign out first to ensure account picker shows
      await _googleSignIn.signOut();

      // Use .authenticate() instead of .signIn()
      final gsi.GoogleSignInAccount? googleUser = await _googleSignIn.authenticate();

      if (googleUser == null) {
        ToastService.showInfo('Sign up cancelled');
        return;
      }

      // Request authorization
      final List<String> scopes = [
        'email',
        'https://www.googleapis.com/auth/userinfo.profile',
      ];
      
      final authorizedUser = await googleUser.authorizationClient.authorizeScopes(scopes);
      final String? accessToken = authorizedUser.accessToken;

      if (accessToken == null) {
        ToastService.showError('Failed to get access token from Google');
        return;
      }

      if (!mounted) return;
      final userType = await _showUserTypeDialog();

      if (userType == null) {
        ToastService.showInfo('Sign up cancelled');
        await _googleSignIn.signOut();
        return;
      }

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (mounted) AppLoadingDialog.show(context, message: 'Creating your account...');
      
      final success = await authProvider.socialSignUp(
        provider: 'google',
        userType: userType,
        accessToken: accessToken,
      );

      if (mounted) Navigator.pop(context); // Hide loading dialog

      if (!success && mounted) {
        await _googleSignIn.signOut();
      }
    } catch (e) {
      print('Google Sign-Up Error: $e');
      ToastService.showError('Failed to sign up with Google.');
      await _googleSignIn.signOut();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }


  Future<void> _handleAppleSignUp() async {
    if (_isLoading) return;

    try {
      setState(() => _isLoading = true);

      // Check if Apple Sign In is available
      if (!await SignInWithApple.isAvailable()) {
        ToastService.showError(
          'Apple Sign In is not available on this device',
        );
        return;
      }

      ToastService.showInfo('Signing up with Apple...');

      // Request Apple Sign-In
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      if (credential.identityToken == null) {
        ToastService.showError(
          'Failed to get identity token from Apple',
        );
        return;
      }

      // Show user type selection dialog
      if (!mounted) return;

      final userType = await _showUserTypeDialog();

      if (userType == null) {
        ToastService.showInfo('Sign up cancelled');
        return;
      }

      // Call your API with the identity token
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      if (mounted) AppLoadingDialog.show(context, message: 'Creating your account...');
      await authProvider.socialSignUp(
        provider: 'apple',
        userType: userType,
        accessToken: credential.identityToken!,
      );
      if (mounted) Navigator.pop(context); // Hide loading dialog
    } catch (e) {
      print('Apple Sign-Up Error: $e');

      if (e.toString().contains('canceled')) {
        ToastService.showInfo('Sign up cancelled');
      } else {
        ToastService.showError(
          'Failed to sign up with Apple. Please try again.',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<String?> _showUserTypeDialog() async {
    final appColors = Theme.of(context).extension<AppColorExtension>()!;
    final appFonts = Theme.of(context).extension<AppFontThemeExtension>()!;

    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Account Type', style: appFonts.textLgBold),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Are you signing up as a rider or driver?',
                style: appFonts.textBaseRegular,
              ),
              SizedBox(height: 20.h),
              ListTile(
                leading: Icon(Icons.directions_car, color: appColors.blue600),
                title: Text('Rider', style: appFonts.textMdRegular),
                subtitle: Text(
                  'Request rides from drivers',
                  style: appFonts.textSmRegular,
                ),
                onTap: () => Navigator.of(context).pop('rider'),
              ),
              ListTile(
                leading: Icon(Icons.local_taxi, color: appColors.blue600),
                title: Text('Driver', style: appFonts.textMdRegular),
                subtitle: Text(
                  'Provide rides to passengers',
                  style: appFonts.textSmRegular,
                ),
                onTap: () => Navigator.of(context).pop('driver'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel', style: appFonts.textMdRegular),
            ),
          ],
        );
      },
    );
  }

  bool _isValidEmail(String email) {
    return RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    ).hasMatch(email);
  }
}
