import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:ridenowappsss/modules/authentication/presentation/providers/auth_provider.dart';
import 'package:ridenowappsss/core/navigation/route_constant.dart';
import 'package:ridenowappsss/core/services/user_service.dart';
import 'package:ridenowappsss/core/storage/local_storage.dart';
import 'package:ridenowappsss/core/utils/extensions/app_color_extension.dart';
import 'package:ridenowappsss/core/utils/extensions/app_font_extension.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 0.6).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.0),
      end: const Offset(0.0, 0.8),
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeInOut),
    );

    _opacityAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeInOut),
    );

    _startAnimations();
    _navigateToNextScreen();
  }

  void _startAnimations() async {
    await _fadeController.forward();
    await Future.delayed(const Duration(milliseconds: 800));
    _slideController.forward();
  }

  Future<void> _navigateToNextScreen() async {
    await Future.delayed(const Duration(seconds: 4));
    if (!mounted) return;
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.initializeAuth();

    if (!mounted) return;

    if (authProvider.isAuthenticated) {
      context.goNamed(RouteConstants.ride);
    } else {
      final isFirstTimeUser = await FirstTimeUserService.isFirstTimeUser();
      if (!mounted) return;
      if (isFirstTimeUser) {
        context.goNamed(RouteConstants.onboarding);
      } else {
        context.goNamed(RouteConstants.userTypeSelection);
      }
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorExtension>()!;
    final appFonts = Theme.of(context).extension<AppFontThemeExtension>()!;
    return Scaffold(
      backgroundColor: appColors.pink600,
      body: Stack(
        children: [
          Center(child: Image.asset('assets/RideNow.png')),
          Center(
            child: AnimatedBuilder(
              animation: Listenable.merge([_fadeController, _slideController]),
              builder: (context, child) {
                double combinedOpacity = _fadeAnimation.value;
                if (_slideController.status == AnimationStatus.forward ||
                    _slideController.status == AnimationStatus.completed) {
                  combinedOpacity = _opacityAnimation.value;
                }
                return SlideTransition(
                  position: _slideAnimation,
                  child: Opacity(
                    opacity: combinedOpacity,
                    child: Text(
                      'Ride Now',
                      style: appFonts.textSmMedium.copyWith(
                        color: Colors.white,
                        fontSize: 48,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
