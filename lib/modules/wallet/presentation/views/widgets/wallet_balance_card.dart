import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ridenowappsss/core/utils/extensions/amount_extension_validations_utils.dart';
import 'package:ridenowappsss/core/utils/extensions/app_color_extension.dart';
import 'package:ridenowappsss/core/utils/extensions/app_font_extension.dart';
import 'package:ridenowappsss/modules/wallet/presentation/providers/wallet_provider.dart';
import 'package:ridenowappsss/modules/wallet/presentation/views/widgets/wallet_widgets.dart';
import 'package:ridenowappsss/shared/widgets/shimmer_widget.dart';

class WalletBalanceCard extends StatelessWidget {
  final WalletProvider provider;
  final VoidCallback onDeposit;
  final VoidCallback onWithdraw;

  const WalletBalanceCard({
    super.key,
    required this.provider,
    required this.onDeposit,
    required this.onWithdraw,
  });

  @override
  Widget build(BuildContext context) {
    if (provider.isLoading && !provider.hasData) {
      return const WalletBalanceShimmer();
    }

    final appColors = Theme.of(context).extension<AppColorExtension>()!;
    final appFonts = Theme.of(context).extension<AppFontThemeExtension>()!;
    final balance = provider.formattedBalance;
    final currency = provider.walletBalance?.currency ?? 'NGN';

    return Container(
      height: 135.h,
      width: 348.w,
      decoration: BoxDecoration(
        color: appColors.blue50,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Your Wallet Balance',
              style: appFonts.textSmMedium.copyWith(
                color: appColors.textPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w300,
              ),
            ),
            SizedBox(height: 4.h),
            BalanceDisplay(
              balance: balance,
              currency: currency,
              isVisible: provider.balanceVisible,
              onToggleVisibility: provider.toggleBalanceVisibility,
            ),
            SizedBox(height: 16.h),
            WalletActionButtons(onDeposit: onDeposit, onWithdraw: onWithdraw),
          ],
        ),
      ),
    );
  }
}

class BalanceCard extends StatelessWidget {
  final double balance;
  final String currency;
  final bool hasError;

  const BalanceCard({
    super.key,
    required this.balance,
    required this.currency,
    required this.hasError,
  });

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorExtension>()!;
    final appFonts = Theme.of(context).extension<AppFontThemeExtension>()!;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 20.h),
      decoration: BoxDecoration(
        color: hasError ? appColors.red50 : appColors.blue50,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        children: [
          Text(
            'Your Wallet Balance',
            style: appFonts.textSmMedium.copyWith(
              color: hasError ? appColors.red600 : appColors.gray600,
              fontSize: 12.sp,
              fontWeight: FontWeight.w400,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            balance.formatAmountWithCurrency(currency: currency),
            style: appFonts.textSmMedium.copyWith(
              color: hasError ? appColors.red600 : appColors.textPrimary,
              fontSize: 24.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
