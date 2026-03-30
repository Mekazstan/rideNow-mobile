import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:ridenowappsss/core/utils/extensions/amount_extension_validations_utils.dart';
import 'package:ridenowappsss/core/utils/extensions/app_color_extension.dart';
import 'package:ridenowappsss/core/utils/extensions/app_font_extension.dart';
import 'package:ridenowappsss/modules/accounts/data/models/subscription_plan_model.dart';
import 'package:ridenowappsss/modules/wallet/data/models/payment_method_models.dart';
import 'package:ridenowappsss/modules/wallet/presentation/providers/payment_method_provider.dart';
import 'package:ridenowappsss/shared/widgets/ridenow_button.dart';

class SubscriptionPaymentSheet extends StatefulWidget {
  final SubscriptionPlan plan;
  final Function(PaymentMethod? method, bool autoRenew) onConfirm;

  const SubscriptionPaymentSheet({
    super.key,
    required this.plan,
    required this.onConfirm,
  });

  @override
  State<SubscriptionPaymentSheet> createState() => _SubscriptionPaymentSheetState();
}

class _SubscriptionPaymentSheetState extends State<SubscriptionPaymentSheet> {
  bool _autoRenew = true;
  PaymentMethod? _selectedMethod;
  bool _isInitialLoad = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadMethods();
    });
  }

  Future<void> _loadMethods() async {
    final provider = Provider.of<PaymentMethodProvider>(context, listen: false);
    await provider.fetchPaymentMethods();
    if (mounted) {
      setState(() {
        _selectedMethod = provider.selectedMethod;
        _isInitialLoad = false;
      });
    }
  }

  bool get _isBankTransfer => _selectedMethod?.id == 'bank_transfer';
  bool get _isNewCard => _selectedMethod?.id == 'new_card' || (_selectedMethod == null && !_isBankTransfer);

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorExtension>()!;
    final appFonts = Theme.of(context).extension<AppFontThemeExtension>()!;
    final provider = Provider.of<PaymentMethodProvider>(context);

    // Filter out existing bank transfer from provider methods if any, 
    // as we'll show a static one with the specific behavior requested.
    final displayMethods = provider.paymentMethods.where((m) => m.type != PaymentMethodType.bankTransfer).toList();

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.r),
          topRight: Radius.circular(20.r),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Complete Payment',
                style: appFonts.textSmMedium.copyWith(
                  color: appColors.textPrimary,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          
          // Plan Info Card
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: appColors.blue50,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.plan.name,
                      style: appFonts.textSmMedium.copyWith(
                        color: appColors.textPrimary,
                        fontSize: 14.sp,
                      ),
                    ),
                    Text(
                      '${widget.plan.planType} Subscription',
                      style: appFonts.textSmMedium.copyWith(
                        color: appColors.textSecondary,
                        fontSize: 12.sp,
                      ),
                    ),
                  ],
                ),
                Text(
                  widget.plan.price.toString().formatAmountWithCurrency(),
                  style: appFonts.textSmMedium.copyWith(
                    color: appColors.pink500,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          
          SizedBox(height: 24.h),
          Text(
            'Select Payment Method',
            style: appFonts.textSmMedium.copyWith(
              color: appColors.textPrimary,
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 12.h),
          
          if (_isInitialLoad)
            const Center(child: CircularProgressIndicator())
          else
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: displayMethods.length + 2, // +1 for "New Card", +1 for "Bank Transfer"
                separatorBuilder: (_, __) => SizedBox(height: 12.h),
                itemBuilder: (context, index) {
                  if (index == displayMethods.length) {
                    return _buildNewCardOption(appColors, appFonts);
                  }
                  if (index == displayMethods.length + 1) {
                    return _buildBankTransferOption(appColors, appFonts);
                  }
                  final method = displayMethods[index];
                  return _buildMethodItem(method, appColors, appFonts);
                },
              ),
            ),
          
          if (!_isBankTransfer) ...[
            SizedBox(height: 24.h),
            // Auto-renew toggle
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Auto-Renewal',
                      style: appFonts.textSmMedium.copyWith(
                        color: appColors.textPrimary,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Automatically renew this plan',
                      style: appFonts.textSmMedium.copyWith(
                        color: appColors.textSecondary,
                        fontSize: 12.sp,
                      ),
                    ),
                  ],
                ),
                Switch.adaptive(
                  value: _autoRenew,
                  onChanged: (val) => setState(() => _autoRenew = val),
                  activeColor: appColors.blue500,
                ),
              ],
            ),
          ],
          
          SizedBox(height: 32.h),
          RideNowButton(
            title: 'Subscribe Now',
            onTap: _selectedMethod != null || _isNewCard ? () {
              widget.onConfirm(
                _isBankTransfer ? null : _selectedMethod, 
                _isBankTransfer ? false : _autoRenew
              );
            } : null,
          ),
          SizedBox(height: 8.h),
        ],
      ),
    );
  }

  Widget _buildMethodItem(PaymentMethod method, AppColorExtension appColors, AppFontThemeExtension appFonts) {
    bool isSelected = _selectedMethod?.id == method.id;
    bool isWallet = method.isWallet;
    bool insufficientBalance = isWallet && (method.balance ?? 0) < widget.plan.price;

    return GestureDetector(
      onTap: insufficientBalance ? null : () {
        setState(() => _selectedMethod = method);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: isSelected ? appColors.blue50.withOpacity(0.5) : Colors.white,
          border: Border.all(
            color: isSelected ? appColors.blue500 : appColors.gray200,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            Icon(
              isWallet ? Icons.account_balance_wallet_outlined : Icons.credit_card_outlined,
              color: insufficientBalance ? appColors.gray400 : appColors.blue500,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    method.name + (method.lastFour != null ? ' (**** ${method.lastFour})' : ''),
                    style: appFonts.textSmMedium.copyWith(
                      color: insufficientBalance ? appColors.gray400 : appColors.textPrimary,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (isWallet)
                    Text(
                      'Balance: ${method.balance.toString().formatAmountWithCurrency()}',
                      style: appFonts.textSmMedium.copyWith(
                        color: insufficientBalance ? appColors.pink500 : appColors.textSecondary,
                        fontSize: 12.sp,
                      ),
                    ),
                ],
              ),
            ),
            if (insufficientBalance)
              Text(
                'Insufficient',
                style: appFonts.textSmMedium.copyWith(
                  color: appColors.pink500,
                  fontSize: 10.sp,
                ),
              )
            else
              Container(
                height: 18.h,
                width: 18.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? appColors.blue500 : appColors.gray300,
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? Center(
                        child: Container(
                          height: 8.h,
                          width: 8.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: appColors.blue500,
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

  Widget _buildNewCardOption(AppColorExtension appColors, AppFontThemeExtension appFonts) {
    bool isSelected = _selectedMethod?.id == 'new_card';
    return GestureDetector(
      onTap: () {
        setState(() => _selectedMethod = PaymentMethod(
          id: 'new_card',
          type: PaymentMethodType.card,
          name: 'Add New Card',
        ));
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: isSelected ? appColors.blue50.withOpacity(0.5) : Colors.white,
          border: Border.all(
            color: isSelected ? appColors.blue500 : appColors.gray200,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            Icon(Icons.add_card_outlined, color: appColors.blue500),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                'Add New Card',
                style: appFonts.textSmMedium.copyWith(
                  color: appColors.textPrimary,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Container(
              height: 18.h,
              width: 18.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? appColors.blue500 : appColors.gray300,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        height: 8.h,
                        width: 8.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: appColors.blue500,
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

  Widget _buildBankTransferOption(AppColorExtension appColors, AppFontThemeExtension appFonts) {
    bool isSelected = _isBankTransfer;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedMethod = PaymentMethod(
          id: 'bank_transfer',
          type: PaymentMethodType.bankTransfer,
          name: 'Bank Transfer',
        ));
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: isSelected ? appColors.blue50.withOpacity(0.5) : Colors.white,
          border: Border.all(
            color: isSelected ? appColors.blue500 : appColors.gray200,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            Icon(Icons.account_balance_outlined, color: appColors.blue500),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                'Bank Transfer',
                style: appFonts.textSmMedium.copyWith(
                  color: appColors.textPrimary,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Container(
              height: 18.h,
              width: 18.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? appColors.blue500 : appColors.gray300,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        height: 8.h,
                        width: 8.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: appColors.blue500,
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
