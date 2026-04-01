// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ridenowappsss/core/utils/extensions/amount_extension_validations_utils.dart';
import 'package:ridenowappsss/core/utils/extensions/app_color_extension.dart';
import 'package:ridenowappsss/core/utils/extensions/app_font_extension.dart';
import 'package:ridenowappsss/modules/wallet/data/models/wallet_models.dart';
import 'package:ridenowappsss/shared/widgets/ridenow_textfield.dart';

class AmountInput extends StatelessWidget {
  final TextEditingController controller;
  final String? errorMessage;
  final ValueChanged<String> onAmountChanged;

  const AmountInput({
    super.key,
    required this.controller,
    required this.errorMessage,
    required this.onAmountChanged,
  });

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorExtension>()!;
    final appFonts = Theme.of(context).extension<AppFontThemeExtension>()!;
    final hasError = errorMessage != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Amount (₦)',
          style: appFonts.textSmMedium.copyWith(
            color: hasError ? appColors.red400 : appColors.gray600,
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
          ),
        ),
        SizedBox(height: 8.h),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Withdraw',
              style: appFonts.textSmMedium.copyWith(
                color: appColors.textPrimary,
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RidenowTextfield(
                    fieldName: '',
                    showFieldName: false,
                    hintText: '₦1,000,000',
                    controller: controller,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9,.]')),
                      CommaInputFormatter(),
                    ],
                    onChanged: onAmountChanged,
                  ),
                  if (errorMessage != null) ...[
                    SizedBox(height: 4.h),
                    Text(
                      errorMessage!,
                      style: appFonts.textSmRegular.copyWith(
                        color: appColors.red400,
                        fontSize: 12.sp,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Bank Account Details Widget
class BankAccountDetails extends StatelessWidget {
  final BankAccount bankAccount;
  final VoidCallback onChangeBankAccount;

  const BankAccountDetails({
    super.key,
    required this.bankAccount,
    required this.onChangeBankAccount,
  });

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorExtension>()!;
    final appFonts = Theme.of(context).extension<AppFontThemeExtension>()!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'To',
          style: appFonts.textSmMedium.copyWith(
            color: appColors.gray600,
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
          ),
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: appColors.orange100,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Center(
                child: Text('🏦', style: TextStyle(fontSize: 20.sp)),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    bankAccount.bankName,
                    style: appFonts.textSmMedium.copyWith(
                      color: appColors.textPrimary,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    bankAccount.accountHolderName,
                    style: appFonts.textSmRegular.copyWith(
                      color: appColors.gray500,
                      fontSize: 12.sp,
                    ),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                Text(
                  bankAccount.accountNumber.formatAccountNumber(),
                  style: appFonts.textSmMedium.copyWith(
                    color: appColors.blue500,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                SizedBox(width: 8.w),
                GestureDetector(
                  onTap:
                      () => ClipboardHelper.copyToClipboard(
                        context,
                        bankAccount.accountNumber,
                        successMessage: 'Account number copied to clipboard',
                      ),
                  child: SvgPicture.asset(
                    'assets/copy.svg',
                    color: appColors.blue500,
                    width: 16.w,
                    height: 16.w,
                  ),
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: 12.h),
        GestureDetector(
          onTap: onChangeBankAccount,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.sync, size: 16.sp, color: appColors.blue500),
              SizedBox(width: 4.w),
              Text(
                'Change bank account',
                style: appFonts.textSmMedium.copyWith(
                  color: appColors.blue500,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
