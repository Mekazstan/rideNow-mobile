// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:ridenowappsss/core/services/user_service.dart';
import 'package:ridenowappsss/core/navigation/route_constant.dart';
import 'package:ridenowappsss/core/utils/extensions/app_color_extension.dart';
import 'package:ridenowappsss/modules/authentication/data/models/onboarding_data.dart';
import 'package:ridenowappsss/modules/authentication/presentation/views/widgets/onboarding_card.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  OnboardingScreenState createState() => OnboardingScreenState();
}

class OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int currentIndex = 0;
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;

  final List<OnboardingData> onboardingData = [
    OnboardingData(
      image: 'assets/onbb1.png',
      title: 'Safer rides with\ncommunity sharing.',
      description:
          'Let loved ones track your trips in real time for\nadded peace of mind.',
    ),
    OnboardingData(
      image: 'assets/onbb2.png',
      title: 'Negotiate your ride prices.',
      description:
          'Set your fare and agree on what works best for you\nand the driver.',
    ),
    OnboardingData(
      image: 'assets/onbb3.png',
      title: 'Earn 100% of your fees.\nNo cuts.',
      description:
          'Set your fare and agree on what works best for you\nand the driver.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.linear),
    );

    _progressController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _autoAdvance();
      }
    });

    _progressController.forward();
  }

  @override
  void dispose() {
    _progressController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      currentIndex = index;
    });

    _progressController.reset();
    _progressController.forward();
  }

  void _autoAdvance() {
    if (currentIndex < onboardingData.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.ease,
      );
    }
  }

  Future<void> _completeOnboarding() async {
    await FirstTimeUserService.markUserAsReturning();

    if (mounted) {
      context.goNamed(RouteConstants.userTypeSelection);
    }
  }

  void _handleNextButtonTap() async {
    _progressController.stop();
    if (currentIndex < onboardingData.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.ease,
      );
    } else {
      await _completeOnboarding();
    }
  }

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorExtension>()!;

    return Scaffold(
      backgroundColor: appColors.orange100,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (_progressController.isAnimating &&
                    currentIndex < onboardingData.length - 1) {
                  _progressController.stop();
                  _autoAdvance();
                }
              },
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: onboardingData.length,
                itemBuilder: (context, index) {
                  return OnboardingCard(data: onboardingData[index]);
                },
              ),
            ),
          ),
          _buildProgressIndicators(appColors),
          _buildNextButton(appColors),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }

  Widget _buildProgressIndicators(AppColorExtension appColors) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Row(
        children: List.generate(
          onboardingData.length,
          (index) => Container(
            margin: const EdgeInsets.only(right: 8),
            width: currentIndex == index ? 168 : 72,
            height: 8,
            decoration: BoxDecoration(
              color: appColors.blue200,
              borderRadius: BorderRadius.circular(4),
            ),
            child:
                currentIndex == index
                    ? AnimatedBuilder(
                      animation: _progressAnimation,
                      builder: (context, child) {
                        return Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: LinearProgressIndicator(
                            value: _progressAnimation.value,
                            backgroundColor: Colors.transparent,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              appColors.blue600,
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        );
                      },
                    )
                    : null,
          ),
        ),
      ),
    );
  }

  Widget _buildNextButton(AppColorExtension appColors) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          ElevatedButton(
            onPressed: _handleNextButtonTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: appColors.blue600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.arrow_forward, size: 18),
                const SizedBox(width: 4),
                Text(
                  currentIndex < onboardingData.length - 1 ? 'Next' : 'Finish',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
