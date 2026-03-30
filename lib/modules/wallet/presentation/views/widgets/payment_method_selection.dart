import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:ridenowappsss/core/utils/extensions/amount_extension_validations_utils.dart';
import 'package:ridenowappsss/core/utils/extensions/app_color_extension.dart';
import 'package:ridenowappsss/core/services/toast_service.dart';
import 'package:ridenowappsss/core/utils/extensions/app_font_extension.dart';
import 'package:ridenowappsss/modules/wallet/presentation/providers/wallet_provider.dart';
import 'package:ridenowappsss/shared/widgets/payment_web_view.dart';
import 'package:ridenowappsss/shared/widgets/ridenow_button.dart';

class SelectPaymentMethod extends StatefulWidget {
  final String amount;

  const SelectPaymentMethod({super.key, required this.amount});

  @override
  State<SelectPaymentMethod> createState() => _SelectPaymentMethodState();
}

class _SelectPaymentMethodState extends State<SelectPaymentMethod> {
  String? selectedMethod;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorExtension>()!;
    final appFonts = Theme.of(context).extension<AppFontThemeExtension>()!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Text(
            'Select Payment Method',
            style: appFonts.textSmMedium.copyWith(
              color: appColors.textPrimary,
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        SizedBox(height: 6.h),
        Center(
          child: Text(
            widget.amount.formatAmountWithCurrency(),
            style: appFonts.textSmMedium.copyWith(
              color: appColors.pink500,
              fontSize: 24.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        SizedBox(height: 17.h),
        PaymentMethodItem(
          imagePath: 'assets/bankTransfer.png',
          title: 'Bank Transfer',
          isSelected: selectedMethod == 'bank_transfer',
          onTap: () {
            setState(() {
              selectedMethod = 'bank_transfer';
            });
          },
        ),
        SizedBox(height: 17.h),
        PaymentMethodItem(
          imagePath: 'assets/cardPay.png',
          title: 'Pay with Card',
          isSelected: selectedMethod == 'card',
          onTap: () {
            setState(() {
              selectedMethod = 'card';
            });
          },
        ),
        SizedBox(height: 24.h),
        RideNowButton(
          height: 49.h,
          width: 349.w,
          title: isLoading ? 'Processing...' : 'Continue',
          onTap: selectedMethod != null && !isLoading ? _handleContinue : () {},
        ),
        const Spacer(),
      ],
    );
  }

  /// Handles payment initiation and navigation to web view
  Future<void> _handleContinue() async {
    if (selectedMethod == null) return;

    setState(() {
      isLoading = true;
    });

    try {
      final provider = Provider.of<WalletProvider>(context, listen: false);
      final amountValue = double.parse(
        widget.amount.replaceAll(RegExp(r'[^0-9.]'), ''),
      );

      final response = await provider.initiateDeposit(
        amount: amountValue,
        paymentMethod: selectedMethod!,
      );

      if (!mounted) return;

      if (response != null && response['success'] == true) {
        final paymentUrl = response['payment_url'];
        final transactionId = response['transaction_id'];

        if (paymentUrl != null && paymentUrl.isNotEmpty) {
          Navigator.pop(context);

          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => PaymentWebView(
                    paymentUrl: paymentUrl,
                    transactionId: transactionId ?? '',
                    amount: amountValue,
                    paymentMethod: selectedMethod!,
                  ),
            ),
          );

          if (result == true && mounted) {
            await provider.refreshWallet();
          }
        } else {
          _showError('Payment URL not received. Please try again.');
        }
      } else {
        _showError(response?['message'] ?? 'Failed to initiate payment');
      }
    } catch (e) {
      if (mounted) {
        _showError('Error: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ToastService.showError(message);
  }
}

/// Selectable payment method item
class PaymentMethodItem extends StatelessWidget {
  final String imagePath;
  final String title;
  final bool isSelected;
  final VoidCallback onTap;
  final double? height;
  final double? width;
  final Color? backgroundColor;
  final Color? borderColor;
  final double? borderRadius;
  final Color? selectedColor;

  const PaymentMethodItem({
    super.key,
    required this.imagePath,
    required this.title,
    required this.isSelected,
    required this.onTap,
    this.height,
    this.width,
    this.backgroundColor,
    this.borderColor,
    this.borderRadius,
    this.selectedColor,
  });

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorExtension>()!;
    final appFonts = Theme.of(context).extension<AppFontThemeExtension>()!;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height ?? 48.h,
        width: width ?? double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: backgroundColor ?? Colors.white,
          border: Border.all(
            color:
                isSelected
                    ? (selectedColor ?? appColors.blue500)
                    : (borderColor ?? appColors.blue200),
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(borderRadius ?? 12.r),
        ),
        child: Row(
          children: [
            SizedBox(
              height: 53.h,
              width: 53.w,
              child:
                  imagePath.endsWith('.svg')
                      ? SvgPicture.asset(
                        imagePath,
                        height: 24.h,
                        width: 24.w,
                        fit: BoxFit.contain,
                      )
                      : Image.asset(
                        imagePath,
                        height: 24.h,
                        width: 24.w,
                        fit: BoxFit.contain,
                      ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                title,
                style: appFonts.textSmMedium.copyWith(
                  color: appColors.textPrimary,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Container(
              height: 20.h,
              width: 20.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color:
                      isSelected
                          ? (selectedColor ?? appColors.blue50)
                          : appColors.gray300,
                  width: 2,
                ),
                color:
                    isSelected
                        ? (selectedColor ?? appColors.blue500)
                        : Colors.transparent,
              ),
              child:
                  isSelected
                      ? Center(
                        child: Container(
                          height: 8.h,
                          width: 8.w,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                        ),
                      )
                      : null,
            ),
          ],
        ),
      ),
    );
  }
}
