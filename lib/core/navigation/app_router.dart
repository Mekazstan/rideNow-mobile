import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ridenowappsss/core/navigation/bottom_navigation.dart';
import 'package:ridenowappsss/core/navigation/route_constant.dart';
import 'package:ridenowappsss/modules/accounts/presentation/views/screens/accounts_screen.dart';
import 'package:ridenowappsss/modules/accounts/presentation/views/screens/call_abulance.dart';
import 'package:ridenowappsss/modules/accounts/presentation/views/screens/call_police.dart';
import 'package:ridenowappsss/modules/accounts/presentation/views/screens/community_sharing.dart';
import 'package:ridenowappsss/modules/accounts/presentation/views/screens/help_center.dart';
import 'package:ridenowappsss/modules/accounts/presentation/views/screens/privacy_policy_screen.dart';
import 'package:ridenowappsss/modules/accounts/presentation/views/screens/safety_and_secuirity.dart';
import 'package:ridenowappsss/modules/accounts/presentation/views/screens/terms_and_conditions_screen.dart';
import 'package:ridenowappsss/modules/authentication/presentation/views/screens/emergency_contact.dart';

import 'package:ridenowappsss/modules/authentication/presentation/views/screens/forgot_password_screen.dart';
import 'package:ridenowappsss/modules/authentication/presentation/views/screens/lets_get_to_know_you_screen.dart';
import 'package:ridenowappsss/modules/authentication/presentation/views/screens/login_screen.dart';
import 'package:ridenowappsss/modules/authentication/presentation/views/screens/onboarding_screen.dart';
import 'package:ridenowappsss/modules/authentication/presentation/views/screens/select_payment_plan_screen.dart';
import 'package:ridenowappsss/modules/authentication/presentation/views/screens/sign_up_screen.dart';
import 'package:ridenowappsss/modules/authentication/presentation/views/screens/splash_screen.dart';
import 'package:ridenowappsss/modules/authentication/presentation/views/screens/user_type_selection.dart';
import 'package:ridenowappsss/modules/authentication/presentation/views/screens/verify_account_view.dart';
import 'package:ridenowappsss/modules/authentication/presentation/views/screens/account_ready_screen.dart';
import 'package:ridenowappsss/modules/authentication/presentation/views/screens/lets_know_you_more_screen.dart';
import 'package:ridenowappsss/modules/ride/presentation/views/screens/ride_screen.dart';
import 'package:ridenowappsss/modules/wallet/presentation/views/screens/wallet_screen.dart';
import 'package:ridenowappsss/modules/wallet/presentation/views/widgets/analytics_screen.dart';
import 'package:ridenowappsss/modules/wallet/presentation/views/widgets/plans_screen.dart';
import 'package:ridenowappsss/modules/ride/presentation/views/screens/driver_ride_screen.dart';
import 'package:ridenowappsss/modules/community/presentation/views/screens/community_screen.dart';
import 'package:ridenowappsss/modules/authentication/presentation/views/screens/driver_document_collection_screen.dart';
import 'package:ridenowappsss/modules/authentication/presentation/views/screens/document_resubmission_screen.dart';
import 'package:ridenowappsss/modules/authentication/presentation/views/screens/verification_status_screen.dart';
import 'package:ridenowappsss/modules/authentication/presentation/views/screens/smile_id_verification_screen.dart';

class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _shellNavigatorKey = GlobalKey<NavigatorState>();
  static final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  static final GoRouter _router = GoRouter(
    debugLogDiagnostics: true,
    initialLocation: '/',
    navigatorKey: _rootNavigatorKey,
    redirect: (context, state) async {
      if (state.matchedLocation == '/') {
        return null;
      }
      return null;
    },
    routes: [
      // ============================================================
      // SPLASH & ONBOARDING
      // ============================================================
      GoRoute(
        path: '/',
        name: RouteConstants.splash,
        pageBuilder: (context, state) {
          return CustomTransitionPage(
            key: state.pageKey,
            child: const SplashScreen(),
            transitionsBuilder: (
              context,
              animation,
              secondaryAnimation,
              child,
            ) {
              return FadeTransition(
                opacity: CurveTween(
                  curve: Curves.easeInOutCirc,
                ).animate(animation),
                child: child,
              );
            },
          );
        },
      ),

      GoRoute(
        path: '/onboarding',
        name: RouteConstants.onboarding,
        pageBuilder: (context, state) {
          return CustomTransitionPage(
            key: state.pageKey,
            child: const OnboardingScreen(),
            transitionsBuilder: (
              context,
              animation,
              secondaryAnimation,
              child,
            ) {
              return FadeTransition(
                opacity: CurveTween(
                  curve: Curves.easeInOutCirc,
                ).animate(animation),
                child: child,
              );
            },
          );
        },
      ),

      // ============================================================
      // AUTHENTICATION
      // ============================================================
      GoRoute(
        path: '/login',
        name: RouteConstants.login,
        pageBuilder: (context, state) {
          return CustomTransitionPage(
            key: state.pageKey,
            child: const LoginView(),
            transitionsBuilder: (
              context,
              animation,
              secondaryAnimation,
              child,
            ) {
              return FadeTransition(
                opacity: CurveTween(
                  curve: Curves.easeInOutCirc,
                ).animate(animation),
                child: child,
              );
            },
          );
        },
      ),

      GoRoute(
        path: '/signUp',
        name: RouteConstants.signUp,
        pageBuilder: (context, state) {
          return CustomTransitionPage(
            key: state.pageKey,
            child: const SignUpScreen(),
            transitionsBuilder: (
              context,
              animation,
              secondaryAnimation,
              child,
            ) {
              return FadeTransition(
                opacity: CurveTween(
                  curve: Curves.easeInOutCirc,
                ).animate(animation),
                child: child,
              );
            },
          );
        },
      ),

      GoRoute(
        path: '/recoverPassword',
        name: RouteConstants.recoverPassword,
        pageBuilder: (context, state) {
          return CustomTransitionPage(
            key: state.pageKey,
            child: const RecoverPasswordScreen(),
            transitionsBuilder: (
              context,
              animation,
              secondaryAnimation,
              child,
            ) {
              return FadeTransition(
                opacity: CurveTween(
                  curve: Curves.easeInOutCirc,
                ).animate(animation),
                child: child,
              );
            },
          );
        },
      ),

      GoRoute(
        path: '/verifyAccount',
        name: RouteConstants.verifyAccount,
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final email = extra?['email'] as String?;
          return CustomTransitionPage(
            key: state.pageKey,
            child: VerifyAccountView(email: email),
            transitionsBuilder: (
              context,
              animation,
              secondaryAnimation,
              child,
            ) {
              return FadeTransition(
                opacity: CurveTween(
                  curve: Curves.easeInOutCirc,
                ).animate(animation),
                child: child,
              );
            },
          );
        },
      ),

      // ============================================================
      // USER SETUP
      // ============================================================
      GoRoute(
        path: '/userTypeSelection',
        name: RouteConstants.userTypeSelection,
        pageBuilder: (context, state) {
          return CustomTransitionPage(
            key: state.pageKey,
            child: const UserTypeSelectionView(),
            transitionsBuilder: (
              context,
              animation,
              secondaryAnimation,
              child,
            ) {
              return FadeTransition(
                opacity: CurveTween(
                  curve: Curves.easeInOutCirc,
                ).animate(animation),
                child: child,
              );
            },
          );
        },
      ),

      GoRoute(
        path: '/letsGetToKnowYou',
        name: RouteConstants.letsGetToKnowYou,
        pageBuilder: (context, state) {
          return CustomTransitionPage(
            key: state.pageKey,
            child: LetsGetToKnowYouScreen(),
            transitionsBuilder: (
              context,
              animation,
              secondaryAnimation,
              child,
            ) {
              return FadeTransition(
                opacity: CurveTween(
                  curve: Curves.easeInOutCirc,
                ).animate(animation),
                child: child,
              );
            },
          );
        },
      ),

      GoRoute(
        path: '/emergencyContact',
        name: RouteConstants.emergencyContact,
        pageBuilder: (context, state) {
          return CustomTransitionPage(
            key: state.pageKey,
            child: EmergencyContact(),
            transitionsBuilder: (
              context,
              animation,
              secondaryAnimation,
              child,
            ) {
              return FadeTransition(
                opacity: CurveTween(
                  curve: Curves.easeInOutCirc,
                ).animate(animation),
                child: child,
              );
            },
          );
        },
      ),

      GoRoute(
        path: '/selectPaymentPlan',
        name: RouteConstants.selectPaymentPlan,
        pageBuilder: (context, state) {
          return CustomTransitionPage(
            key: state.pageKey,
            child: const SelectPaymentPlanScreen(),
            transitionsBuilder: (
              context,
              animation,
              secondaryAnimation,
              child,
            ) {
              return FadeTransition(
                opacity: CurveTween(
                  curve: Curves.easeInOutCirc,
                ).animate(animation),
                child: child,
              );
            },
          );
        },
      ),

      GoRoute(
        path: '/accountReady',
        name: RouteConstants.accountReady,
        pageBuilder: (context, state) {
          return CustomTransitionPage(
            key: state.pageKey,
            child: const AccountReadyScreen(),
            transitionsBuilder: (
              context,
              animation,
              secondaryAnimation,
              child,
            ) {
              return FadeTransition(
                opacity: CurveTween(
                  curve: Curves.easeInOutCirc,
                ).animate(animation),
                child: child,
              );
            },
          );
        },
      ),

      GoRoute(
        path: '/smileIdVerification',
        name: RouteConstants.smileIdVerification,
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return CustomTransitionPage(
            key: state.pageKey,
            child: SmileIDVerificationScreen(
              url: extra['url'] ?? '',
              jobId: extra['jobId'] ?? '',
              userId: extra['userId'] ?? '',
              onSuccess: (data) => debugPrint('Success: $data'),
              onError: (error) => debugPrint('Error: $error'),
            ),
            transitionsBuilder: (
              context,
              animation,
              secondaryAnimation,
              child,
            ) {
              return FadeTransition(
                opacity: CurveTween(
                  curve: Curves.easeInOutCirc,
                ).animate(animation),
                child: child,
              );
            },
          );
        },
      ),

      GoRoute(
        path: '/letsKnowYouMore',
        name: RouteConstants.letsKnowYouMore,
        pageBuilder: (context, state) {
          return CustomTransitionPage(
            key: state.pageKey,
            child: const LetsKnowYouMoreScreen(),
            transitionsBuilder: (
              context,
              animation,
              secondaryAnimation,
              child,
            ) {
              return FadeTransition(
                opacity: CurveTween(
                  curve: Curves.easeInOutCirc,
                ).animate(animation),
                child: child,
              );
            },
          );
        },
      ),

      GoRoute(
        path: '/driverDocumentCollection',
        name: RouteConstants.driverDocumentCollection,
        pageBuilder: (context, state) {
          return CustomTransitionPage(
            key: state.pageKey,
            child: const DriverDocumentCollectionScreen(),
            transitionsBuilder: (
              context,
              animation,
              secondaryAnimation,
              child,
            ) {
              return FadeTransition(
                opacity: CurveTween(
                  curve: Curves.easeInOutCirc,
                ).animate(animation),
                child: child,
              );
            },
          );
        },
      ),

      GoRoute(
        path: '/documentResubmission',
        name: RouteConstants.documentResubmission,
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return CustomTransitionPage(
            key: state.pageKey,
            child: DocumentResubmissionScreen(
              documentType: extra['documentType'] ?? 'drivers_license',
              documentName: extra['documentName'] ?? 'License',
            ),
            transitionsBuilder: (
              context,
              animation,
              secondaryAnimation,
              child,
            ) {
              return FadeTransition(
                opacity: CurveTween(
                  curve: Curves.easeInOutCirc,
                ).animate(animation),
                child: child,
              );
            },
          );
        },
      ),

      GoRoute(
        path: '/verificationStatus',
        name: RouteConstants.verificationStatus,
        pageBuilder: (context, state) {
          return CustomTransitionPage(
            key: state.pageKey,
            child: const VerificationStatusScreen(),
            transitionsBuilder: (
              context,
              animation,
              secondaryAnimation,
              child,
            ) {
              return FadeTransition(
                opacity: CurveTween(
                  curve: Curves.easeInOutCirc,
                ).animate(animation),
                child: child,
              );
            },
          );
        },
      ),

      // ============================================================
      // SAFETY & EMERGENCY
      // ============================================================
      GoRoute(
        path: '/safetyAndSecurity',
        name: RouteConstants.safetyAndSecurity,
        pageBuilder: (context, state) {
          return CustomTransitionPage(
            key: state.pageKey,
            child: const SafetyAndSecuirity(),
            transitionsBuilder: (
              context,
              animation,
              secondaryAnimation,
              child,
            ) {
              return FadeTransition(
                opacity: CurveTween(
                  curve: Curves.easeInOutCirc,
                ).animate(animation),
                child: child,
              );
            },
          );
        },
      ),

      GoRoute(
        path: '/callPolice',
        name: RouteConstants.callPolice,
        pageBuilder: (context, state) {
          return CustomTransitionPage(
            key: state.pageKey,
            child: const CallPolice(),
            transitionsBuilder: (
              context,
              animation,
              secondaryAnimation,
              child,
            ) {
              return FadeTransition(
                opacity: CurveTween(
                  curve: Curves.easeInOutCirc,
                ).animate(animation),
                child: child,
              );
            },
          );
        },
      ),

      GoRoute(
        path: '/callAnAbulance',
        name: RouteConstants.callAnAbulance,
        pageBuilder: (context, state) {
          return CustomTransitionPage(
            key: state.pageKey,
            child: const CallAmbulance(),
            transitionsBuilder: (
              context,
              animation,
              secondaryAnimation,
              child,
            ) {
              return FadeTransition(
                opacity: CurveTween(
                  curve: Curves.easeInOutCirc,
                ).animate(animation),
                child: child,
              );
            },
          );
        },
      ),

      // ============================================================
      // COMMUNITY & SUPPORT
      // ============================================================
      GoRoute(
        path: '/communitySharing',
        name: RouteConstants.communitySharing,
        pageBuilder: (context, state) {
          return CustomTransitionPage(
            key: state.pageKey,
            child: const CommunitySharing(),
            transitionsBuilder: (
              context,
              animation,
              secondaryAnimation,
              child,
            ) {
              return FadeTransition(
                opacity: CurveTween(
                  curve: Curves.easeInOutCirc,
                ).animate(animation),
                child: child,
              );
            },
          );
        },
      ),

      GoRoute(
        path: '/helpCenter',
        name: RouteConstants.helpCenter,
        pageBuilder: (context, state) {
          return CustomTransitionPage(
            key: state.pageKey,
            child: const HelpCenter(),
            transitionsBuilder: (
              context,
              animation,
              secondaryAnimation,
              child,
            ) {
              return FadeTransition(
                opacity: CurveTween(
                  curve: Curves.easeInOutCirc,
                ).animate(animation),
                child: child,
              );
            },
          );
        },
      ),

       GoRoute(
        path: '/privacyPolicy',
        name: RouteConstants.privacyPolicy,
        pageBuilder: (context, state) {
          return CustomTransitionPage(
            key: state.pageKey,
            child: const PrivacyPolicyScreen(),
            transitionsBuilder: (
              context,
              animation,
              secondaryAnimation,
              child,
            ) {
              return FadeTransition(
                opacity: CurveTween(
                  curve: Curves.easeInOutCirc,
                ).animate(animation),
                child: child,
              );
            },
          );
        },
      ),

      GoRoute(
        path: '/termsAndConditions',
        name: RouteConstants.termsAndConditions,
        pageBuilder: (context, state) {
          return CustomTransitionPage(
            key: state.pageKey,
            child: const TermsAndConditionsScreen(),
            transitionsBuilder: (
              context,
              animation,
              secondaryAnimation,
              child,
            ) {
              return FadeTransition(
                opacity: CurveTween(
                  curve: Curves.easeInOutCirc,
                ).animate(animation),
                child: child,
              );
            },
          );
        },
      ),

      // ============================================================
      // WALLET & ANALYTICS
      // ============================================================
      GoRoute(
        path: '/plans',
        name: RouteConstants.plans,
        pageBuilder: (context, state) {
          return CustomTransitionPage(
            key: state.pageKey,
            child: PlansScreen(),
            transitionsBuilder: (
              context,
              animation,
              secondaryAnimation,
              child,
            ) {
              return FadeTransition(
                opacity: CurveTween(
                  curve: Curves.easeInOutCirc,
                ).animate(animation),
                child: child,
              );
            },
          );
        },
      ),

      GoRoute(
        path: '/analytics',
        name: RouteConstants.analytics,
        pageBuilder: (context, state) {
          return CustomTransitionPage(
            key: state.pageKey,
            child: AnalyticsScreen(),
            transitionsBuilder: (
              context,
              animation,
              secondaryAnimation,
              child,
            ) {
              return FadeTransition(
                opacity: CurveTween(
                  curve: Curves.easeInOutCirc,
                ).animate(animation),
                child: child,
              );
            },
          );
        },
      ),

      // ============================================================
      // BOTTOM NAVIGATION SHELL
      // ============================================================
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return BottomNavShell(
            currentPath: state.uri.toString(),
            child: child,
          );
        },
        routes: [
          GoRoute(
            path: '/wallet',
            name: RouteConstants.wallet,
            pageBuilder: (context, state) {
              return CustomTransitionPage(
                key: state.pageKey,
                child: ConditionalWidget(
                  riderWidget: const WalletScreen(),
                  driverWidget: const WalletScreen(),
                  vendorWidget: const WalletScreen(),
                ),
                transitionsBuilder: (
                  context,
                  animation,
                  secondaryAnimation,
                  child,
                ) {
                  return FadeTransition(
                    opacity: CurveTween(
                      curve: Curves.easeInOutCirc,
                    ).animate(animation),
                    child: child,
                  );
                },
              );
            },
          ),
          GoRoute(
            path: '/ride',
            name: RouteConstants.ride,
            pageBuilder: (context, state) {
              return CustomTransitionPage(
                key: state.pageKey,
                child: ConditionalWidget(
                  riderWidget: RideScreen(),
                  driverWidget: const RideScreenDriver(),
                  vendorWidget: RideScreen(),
                ),
                transitionsBuilder: (
                  context,
                  animation,
                  secondaryAnimation,
                  child,
                ) {
                  return FadeTransition(
                    opacity: CurveTween(
                      curve: Curves.easeInOutCirc,
                    ).animate(animation),
                    child: child,
                  );
                },
              );
            },
          ),
          GoRoute(
            path: '/community',
            name: RouteConstants.community,
            pageBuilder: (context, state) {
              return CustomTransitionPage(
                key: state.pageKey,
                child: ConditionalWidget(
                  riderWidget: const CommunityScreen(),
                  driverWidget: const CommunityScreen(),
                  vendorWidget: const CommunitySharing(),
                ),
                transitionsBuilder: (
                  context,
                  animation,
                  secondaryAnimation,
                  child,
                ) {
                  return FadeTransition(
                    opacity: CurveTween(
                      curve: Curves.easeInOutCirc,
                    ).animate(animation),
                    child: child,
                  );
                },
              );
            },
          ),
          GoRoute(
            path: '/accounts',
            name: RouteConstants.accounts,
            pageBuilder: (context, state) {
              return CustomTransitionPage(
                key: state.pageKey,
                child: ConditionalWidget(
                  riderWidget: const AccountsScreen(),
                  driverWidget: const AccountsScreen(),
                  vendorWidget: const AccountsScreen(),
                ),
                transitionsBuilder: (
                  context,
                  animation,
                  secondaryAnimation,
                  child,
                ) {
                  return FadeTransition(
                    opacity: CurveTween(
                      curve: Curves.easeInOutCirc,
                    ).animate(animation),
                    child: child,
                  );
                },
              );
            },
          ),
        ],
      ),
    ],
  );

  static GoRouter get router => _router;
}
