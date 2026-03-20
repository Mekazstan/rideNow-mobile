import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:ridenowappsss/core/utils/extensions/app_color_extension.dart';
import 'package:ridenowappsss/core/utils/extensions/app_font_extension.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:ridenowappsss/core/services/error_service.dart';
import 'package:ridenowappsss/core/services/toast_service.dart';
import 'package:ridenowappsss/modules/authentication/presentation/providers/auth_provider.dart';
import 'package:ridenowappsss/shared/widgets/ridenow_button.dart';
import 'package:ridenowappsss/shared/widgets/ridenow_scaffold.dart';
import 'package:ridenowappsss/shared/widgets/ridenow_textfield.dart';
import 'package:ridenowappsss/core/navigation/route_constant.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Google Sign In instance
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: <String>['email', 'profile'],
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ToastService.init(context);
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorExtension>()!;
    final appFonts = Theme.of(context).extension<AppFontThemeExtension>()!;

    return RidenowScaffold(
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (authProvider.isAuthenticated) {
              ErrorService.showSuccess('Welcome back!');
              context.goNamed(RouteConstants.ride);
            } else if (authProvider.hasError &&
                authProvider.lastError != null) {
              ErrorService.handleAuthError(
                authProvider.lastError!,
                onRetry: () => _handleLogin(),
              );
              authProvider.clearErrors();
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
                              'Sign in to your account',
                              style: appFonts.textBaseRegular.copyWith(
                                color: appColors.textSecondary,
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            SizedBox(height: 32.h),
                            _buildLoginForm(authProvider, appColors, appFonts),
                            SizedBox(height: 39.h),
                            _buildSignUpLink(appColors, appFonts),
                            SizedBox(height: 7.h),
                            _buildSocialLoginSection(
                              authProvider,
                              appColors,
                              appFonts,
                            ),
                            SizedBox(height: 18.h),
                            Center(
                              child: GestureDetector(
                                onTap:
                                    () => context.goNamed(
                                      RouteConstants.recoverPassword,
                                    ),
                                child: Text(
                                  'Forgot your password?',
                                  style: appFonts.textBaseRegular.copyWith(
                                    color: appColors.textSecondary,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                  ),
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
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildLoginForm(
    AuthProvider authProvider,
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
              validator: (value) {
                if (authProvider.validationErrors != null &&
                    authProvider.validationErrors!.containsKey('email')) {
                  return authProvider.validationErrors!['email'];
                }
                return null;
              },
            ),
            SizedBox(height: 16.h),
            RidenowTextfield(
              fieldName: 'Password',
              hintText: '**********',
              controller: _passwordController,
              obscureText: true,
              validator: (value) {
                if (authProvider.validationErrors != null &&
                    authProvider.validationErrors!.containsKey('password')) {
                  return authProvider.validationErrors!['password'];
                }
                return null;
              },
            ),
            SizedBox(height: 24.h),
            _buildSignInButton(authProvider, appColors, appFonts),
          ],
        ),
      ),
    );
  }

  Widget _buildSignInButton(
    AuthProvider authProvider,
    AppColorExtension appColors,
    AppFontThemeExtension appFonts,
  ) {
    return RideNowButton(
      title: authProvider.isLoading ? 'Signing in...' : 'Sign in',
      onTap: _handleLogin,
      isLoading: authProvider.isLoading,
      leadingIcon:
          authProvider.isLoading
              ? null
              : SvgPicture.asset('assets/forwardArrow.svg'),
    );
  }

  Widget _buildSignUpLink(
    AppColorExtension appColors,
    AppFontThemeExtension appFonts,
  ) {
    return Align(
      alignment: Alignment.center,
      child: RichText(
        text: TextSpan(
          text: "Don't have an account? ",
          style: appFonts.textMdRegular.copyWith(
            color: appColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
          children: [
            TextSpan(
              text: 'Sign up',
              style: appFonts.textMdRegular.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                decoration: TextDecoration.underline,
                color: appColors.textPrimary,
              ),
              recognizer:
                  TapGestureRecognizer()
                    ..onTap = () => context.goNamed(RouteConstants.signUp),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialLoginSection(
    AuthProvider authProvider,
    AppColorExtension appColors,
    AppFontThemeExtension appFonts,
  ) {
    return Column(
      children: [
        Align(
          alignment: Alignment.center,
          child: Text(
            'or sign in with:',
            style: appFonts.textMdRegular.copyWith(
              color: appColors.textPrimary,
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        SizedBox(height: 27.h),
        Row(
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
              onTap: authProvider.isLoading ? () {} : _handleGoogleSignIn,
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
                colorFilter: ColorFilter.mode(
                  appColors.textWhite,
                  BlendMode.srcIn,
                ),
              ),
              onTap: authProvider.isLoading ? () {} : _handleAppleSignIn,
            ),
          ],
        ),
      ],
    );
  }

  /// UPDATED LOGIN HANDLER WITH PROPER FLOW
  Future<void> _handleLogin() async {
    // Clear previous errors
    Provider.of<AuthProvider>(context, listen: false).clearErrors();

    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    debugPrint('=== LOGIN STARTED ===');
    debugPrint('Email: $email');

    try {
      // Step 1: Perform login
      final loginSuccess = await authProvider.login(
        email: email,
        password: password,
      );

      if (!loginSuccess) {
        debugPrint('âŒ Login failed');
        return; // Error handling is done by Consumer widget above
      }

      debugPrint('âœ… Login API call successful');

      // Step 2: Ensure user profile is loaded
      if (authProvider.user == null) {
        debugPrint('âš ï¸ User is null after login, fetching profile...');

        final profileFetched = await authProvider.fetchProfile();

        if (!profileFetched || authProvider.user == null) {
          debugPrint('âŒ Failed to load user profile');
          ToastService.showError('Failed to load user data. Please try again.');
          return;
        }
      }

      // Step 3: Verify user data is loaded
      final user = authProvider.user!;
      final userType = user.userType.toLowerCase();

      debugPrint('âœ… User data loaded successfully');
      debugPrint('   Name: ${user.firstName} ${user.lastName}');
      debugPrint('   Email: ${user.email}');
      debugPrint('   User Type: $userType');
      debugPrint('   Verification Status: ${user.verificationStatus}');
      debugPrint('   Email Verified: ${user.emailVerified}');

      if (!mounted) return;

      // Step 4: Navigate based on email verification status
      if (user.emailVerified == false) {
        debugPrint(
          'ðŸ“§ Email not verified, navigating to verification screen',
        );

        context.goNamed(
          RouteConstants.verifyAccount,
          extra: {'email': user.email},
        );
        return;
      }

      // Step 5: Navigate to ride screen (handled by Consumer widget)
      debugPrint(
        'ðŸš€ Login completed, navigation will be handled by Consumer',
      );
      debugPrint('=== LOGIN COMPLETED ===');
    } catch (e, stackTrace) {
      debugPrint('âŒ Login error: $e');
      debugPrint('Stack trace: $stackTrace');

      if (!mounted) return;

      ToastService.showError('An unexpected error occurred. Please try again.');
    }
  }

  Future<void> _handleGoogleSignIn() async {
    try {
      ToastService.showInfo('Signing in with Google...');

      // Sign out first to ensure account picker shows
      await _googleSignIn.signOut();

      // Trigger Google Sign-In
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // User cancelled the sign-in
        ToastService.showInfo('Sign in cancelled');
        return;
      }

      // Get authentication details
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      if (googleAuth.accessToken == null) {
        ToastService.showError('Authentication Error');
        return;
      }

      // Call your API with the access token
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.socialSignIn(
        provider: 'google',
        accessToken: googleAuth.accessToken!,
      );

      if (!success && mounted) {
        // Error is already handled by the provider
        await _googleSignIn.signOut();
      }
    } catch (e) {
      debugPrint('Google Sign-In Error: $e');
      ToastService.showError('Sign In Failed');
      await _googleSignIn.signOut();
    }
  }

  Future<void> _handleAppleSignIn() async {
    try {
      // Check if Apple Sign In is available
      if (!await SignInWithApple.isAvailable()) {
        ToastService.showError('Not Available');
        return;
      }

      ToastService.showInfo('Signing in with Apple...');

      // Request Apple Sign-In
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      if (credential.identityToken == null) {
        ToastService.showError('Authentication Error');
        return;
      }

      // Call your API with the identity token
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.socialSignIn(
        provider: 'apple',
        accessToken: credential.identityToken!,
      );
    } catch (e) {
      debugPrint('Apple Sign-In Error: $e');

      if (e.toString().contains('canceled')) {
        ToastService.showInfo('Sign in cancelled');
      } else {
        ToastService.showError('Sign In Failed');
      }
    }
  }
}
