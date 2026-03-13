import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ridenowappsss/core/utils/extensions/amount_extension_validations_utils.dart';
import 'package:ridenowappsss/core/utils/extensions/app_color_extension.dart';
import 'package:ridenowappsss/core/utils/extensions/app_font_extension.dart';
import 'package:ridenowappsss/modules/wallet/presentation/views/widgets/how_much_to_deposit.dart';
import 'package:ridenowappsss/modules/wallet/presentation/views/widgets/payment_method_selection.dart';
import 'package:ridenowappsss/shared/widgets/ride_now_bottomsheet.dart';

class DepositBottomSheetContent extends StatefulWidget {
  const DepositBottomSheetContent({super.key});

  @override
  State<DepositBottomSheetContent> createState() =>
      _DepositBottomSheetContentState();
}

class _DepositBottomSheetContentState extends State<DepositBottomSheetContent> {
  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorExtension>()!;
    final appFonts = Theme.of(context).extension<AppFontThemeExtension>()!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'How much do you want to deposit?',
          style: appFonts.textSmMedium.copyWith(
            color: appColors.textPrimary,
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 17.h),
        Row(
          children: [
            _buildAmountButton('5000', appColors, appFonts),
            SizedBox(width: 16.w),
            _buildAmountButton('7000', appColors, appFonts),
            SizedBox(width: 16.w),
            _buildAmountButton('30000', appColors, appFonts),
            SizedBox(width: 16.w),
            _buildAmountButton('50000', appColors, appFonts),
          ],
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            _buildAmountButton('100000', appColors, appFonts),
            SizedBox(width: 16.w),
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
                _showCustomAmountBottomSheet(context, appColors);
              },
              child: Text(
                'Other Amount?',
                style: appFonts.textSmMedium.copyWith(
                  color: appColors.pink500,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 24.h),
        Text(
          'Did you know?',
          style: appFonts.textSmMedium.copyWith(
            color: appColors.gray400,
            fontSize: 14.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          'Depositing money in advance can help you save on overall transport costs?',
          style: appFonts.textSmMedium.copyWith(
            color: appColors.gray400,
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  void _showCustomAmountBottomSheet(
    BuildContext context,
    AppColorExtension appColors,
  ) {
    RideNowBottomSheet.show(
      context: context,
      height: 240.h,
      backgroundColor: Colors.white,
      borderRadius: 16.r,
      child: const HowMuchDeposit(),
      hideBottomNav: true,
    );
  }

  void _showPaymentMethodSheet(
    BuildContext context,
    AppColorExtension appColors,
    String amount,
  ) {
    RideNowBottomSheet.show(
      context: context,
      height: 320.h,
      backgroundColor: Colors.white,
      borderRadius: 16.r,
      hideBottomNav: true,
      child: SelectPaymentMethod(amount: amount),
    );
  }

  Widget _buildAmountButton(
    String amount,
    AppColorExtension appColors,
    AppFontThemeExtension appFonts,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        _showPaymentMethodSheet(context, appColors, amount);
      },
      child: Container(
        height: 31.h,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6.r),
          color: appColors.blue50,
        ),
        child: Center(
          child: Text(
            amount.formatAmountWithCurrency(),
            style: appFonts.textSmMedium.copyWith(
              color: appColors.gray600,
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
