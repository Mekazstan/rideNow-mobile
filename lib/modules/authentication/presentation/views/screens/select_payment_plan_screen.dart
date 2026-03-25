import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:ridenowappsss/core/navigation/route_constant.dart';
import 'package:ridenowappsss/core/utils/extensions/app_color_extension.dart';
import 'package:ridenowappsss/core/utils/extensions/app_font_extension.dart';
import 'package:ridenowappsss/modules/accounts/presentation/providers/subscription_plan_provider.dart';
import 'package:ridenowappsss/modules/accounts/data/models/subscription_plan_model.dart';
import 'package:ridenowappsss/modules/authentication/presentation/views/widgets/paymet_plans.dart';
import 'package:ridenowappsss/shared/widgets/ridenow_button.dart';
import 'package:ridenowappsss/shared/widgets/ridenow_scaffold.dart';
import 'package:ridenowappsss/shared/widgets/shimmer_widget.dart';
import 'package:ridenowappsss/shared/widgets/step_indicator.dart';
import 'package:ridenowappsss/shared/widgets/app_dialogs.dart';
import 'package:ridenowappsss/core/services/toast_service.dart';
import 'dart:async';

class SelectPaymentPlanScreen extends StatefulWidget {
  const SelectPaymentPlanScreen({super.key});

  @override
  State<SelectPaymentPlanScreen> createState() =>
      _SelectPaymentPlanScreenState();
}

class _SelectPaymentPlanScreenState extends State<SelectPaymentPlanScreen> {
  String? selectedPlanId;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _loadPlans());
  }


  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadPlans() async {
    final subscriptionProvider = context.read<SubscriptionProvider>();
    await subscriptionProvider.fetchSubscriptionPlans();
  }

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorExtension>()!;
    final appFonts = Theme.of(context).extension<AppFontThemeExtension>()!;

    return RidenowScaffold(
      showFirstImage: false,
      body: Consumer<SubscriptionProvider>(
        builder: (context, subscriptionProvider, child) {
          return Stack(
            children: [
              RefreshIndicator(
                onRefresh: _loadPlans,
                color: appColors.blue500,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 19),
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      SizedBox(height: 58.h),
                      const StepIndicator(
                        currentStep: 4,
                        totalSteps: 4,
                        stepLabels: ['', '', '', 'Payment Plan'],
                        showStepLabels: [false, false, false, true],
                      ),
                      SizedBox(height: 32.h),
                      Text(
                        'Select your payment plan',
                        style: appFonts.heading1Bold.copyWith(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.w500,
                          color: appColors.textSecondary,
                        ),
                      ),
                      SizedBox(height: 32.h),
                      if (subscriptionProvider.isLoading)
                        _buildShimmerView()
                      else if (subscriptionProvider.state ==
                          SubscriptionState.error)
                        _buildErrorView(appColors, appFonts, subscriptionProvider)
                      else if (subscriptionProvider.plans.isEmpty)
                        _buildEmptyView(appColors, appFonts)
                      else
                        _buildPlansList(appColors, appFonts, subscriptionProvider),
                    ],
                  ),
                ),
              ),
              if (subscriptionProvider.isSubscribing)
                Container(
                  color: Colors.black.withOpacity(0.3),
                  child: Center(
                    child: Container(
                      padding: EdgeInsets.all(24.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(appColors.blue500),
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            'Processing Payment...',
                            style: appFonts.textSmMedium.copyWith(
                              fontWeight: FontWeight.w600,
                              color: appColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            'Please do not close the app',
                            style: appFonts.textSmMedium.copyWith(
                              fontSize: 12.sp,
                              color: appColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildShimmerView() {
    return Column(
      children: [
        _buildPlanShimmer(),
        SizedBox(height: 20.h),
        _buildPlanShimmer(),
      ],
    );
  }

  Widget _buildPlanShimmer() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        color: Colors.grey[50],
        border: Border.all(color: Colors.grey[300]!, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ShimmerBox(width: 120.w, height: 16.h, borderRadius: 4.r),
              ShimmerBox(width: 80.w, height: 24.h, borderRadius: 20.r),
            ],
          ),
          SizedBox(height: 8.h),
          ShimmerBox(width: 100.w, height: 28.h, borderRadius: 4.r),
          SizedBox(height: 20.h),
          ShimmerBox(width: double.infinity, height: 14.h, borderRadius: 4.r),
          SizedBox(height: 8.h),
          ShimmerBox(width: 200.w, height: 14.h, borderRadius: 4.r),
          SizedBox(height: 24.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ShimmerBox(width: 120.w, height: 45.h, borderRadius: 8.r),
              ShimmerBox(width: 100.w, height: 20.h, borderRadius: 4.r),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(
    AppColorExtension appColors,
    AppFontThemeExtension appFonts,
    SubscriptionProvider provider,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 100.h),
          Icon(Icons.error_outline, size: 64.sp, color: appColors.red600),
          SizedBox(height: 16.h),
          Text(
            provider.errorMessage ?? 'Failed to load subscription plans',
            style: appFonts.textSmMedium.copyWith(
              color: appColors.red600,
              fontSize: 16.sp,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24.h),
          RideNowButton(
            title: 'Retry',
            onTap: _loadPlans,
            width: 150.w,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyView(
    AppColorExtension appColors,
    AppFontThemeExtension appFonts,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 100.h),
          Icon(Icons.inbox_outlined, size: 64.sp, color: appColors.gray400),
          SizedBox(height: 16.h),
          Text(
            'No subscription plans available',
            style: appFonts.textSmMedium.copyWith(
              color: appColors.textSecondary,
              fontSize: 16.sp,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPlansList(
    AppColorExtension appColors,
    AppFontThemeExtension appFonts,
    SubscriptionProvider provider,
  ) {
    return Column(
      children:
          provider.plans.asMap().entries.map((entry) {
            final index = entry.key;
            final plan = entry.value;
            final isLast = index == provider.plans.length - 1;

            return Column(
              children: [
                PaymentPlans(
                  appColors: appColors,
                  appFonts: appFonts,
                  planTitle: plan.name,
                  price: plan.formattedPrice,
                  description: plan.benefits.features.join('\n'),
                  isSelected: selectedPlanId == plan.id,
                  showRecommended: plan.isRecommended,
                  index: index,
                  onTap: () {
                    setState(() {
                      selectedPlanId =
                          selectedPlanId == plan.id ? null : plan.id;
                    });
                  },
                  onChoosePlan: () => _handleChoosePlan(plan, provider),
                  onSeeDetails:
                      () => _showPlanDetails(plan, appColors, appFonts),
                ),
                if (!isLast) SizedBox(height: 20.h),
              ],
            );
          }).toList(),
    );
  }

  Future<void> _handleChoosePlan(
    SubscriptionPlan plan,
    SubscriptionProvider provider,
  ) async {
    final appColors = Theme.of(context).extension<AppColorExtension>()!;
    final appFonts = Theme.of(context).extension<AppFontThemeExtension>()!;

    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Confirm ${plan.name}'),
            content: Text(
              'Are you sure you want to subscribe to the ${plan.name}?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(foregroundColor: appColors.blue500),
                child: const Text('Confirm'),
              ),
            ],
          ),
    );

    if (confirmed != true) return;

    final success = await provider.subscribeToPlan(plan.id);

    if (!mounted) return;

    if (success) {
      ToastService.showSuccess('Successfully subscribed to plan!');
      context.goNamed(RouteConstants.accountReady);
    } else {
      String errorMessage = provider.errorMessage ?? 'Failed to subscribe to plan';
      AppErrorDialog.show(
        context,
        title: 'Subscription Failed',
        message: errorMessage,
      );
    }
  }

  void _showPlanDetails(
    dynamic plan,
    AppColorExtension appColors,
    AppFontThemeExtension appFonts,
  ) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    plan.name,
                    style: appFonts.heading1Bold.copyWith(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w700,
                      color: appColors.textPrimary,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              Text(
                plan.formattedPrice,
                style: appFonts.heading1Bold.copyWith(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w700,
                  color: appColors.blue600,
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                'Duration: ${plan.durationDays} days',
                style: appFonts.textSmMedium.copyWith(
                  fontSize: 14.sp,
                  color: appColors.textSecondary,
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                'Benefits:',
                style: appFonts.heading1Bold.copyWith(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: appColors.textPrimary,
                ),
              ),
              SizedBox(height: 8.h),
              ...plan.benefits.features.map((feature) {
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 4.h),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.check_circle,
                        size: 20.sp,
                        color: appColors.green500,
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          feature,
                          style: appFonts.textSmMedium.copyWith(
                            fontSize: 14.sp,
                            color: appColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              SizedBox(height: 24.h),
            ],
          ),
        );
      },
    );
  }
}
