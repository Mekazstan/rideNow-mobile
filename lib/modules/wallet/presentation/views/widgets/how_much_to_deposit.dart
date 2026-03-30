import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ridenowappsss/core/utils/extensions/app_color_extension.dart';
import 'package:ridenowappsss/core/utils/extensions/app_font_extension.dart';
import 'package:ridenowappsss/core/services/toast_service.dart';
import 'package:ridenowappsss/modules/wallet/presentation/views/widgets/payment_method_selection.dart';
import 'package:ridenowappsss/shared/widgets/ride_now_bottomsheet.dart';
import 'package:ridenowappsss/shared/widgets/ridenow_button.dart';
import 'package:ridenowappsss/shared/widgets/ridenow_textfield.dart';

class HowMuchDeposit extends StatefulWidget {
  const HowMuchDeposit({super.key});

  @override
  State<HowMuchDeposit> createState() => _HowMuchDepositState();
}

class _HowMuchDepositState extends State<HowMuchDeposit> {
  final TextEditingController _textEditingController = TextEditingController();

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorExtension>()!;
    final appFonts = Theme.of(context).extension<AppFontThemeExtension>()!;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How much?',
            style: appFonts.textSmMedium.copyWith(
              color: appColors.textPrimary,
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 17.h),
          RidenowTextfield(
            fieldName: 'Amount (N)',
            hintText: '1,000,000',
            controller: _textEditingController,
            keyboardType: TextInputType.number,
          ),
          SizedBox(height: 24.h),
          RideNowButton(
            height: 49.h,
            width: 349.w,
            title: 'Continue',
            onTap: () {
              final amount = _textEditingController.text.trim().replaceAll(
                ',',
                '',
              );
              if (amount.isEmpty || double.tryParse(amount) == null) {
                ToastService.showWarning('Please enter a valid amount');
                return;
              }
              Navigator.pop(context);
              _showPaymentMethodSheet(context, appColors, amount);
            },
          ),
        ],
      ),
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
      child: SelectPaymentMethod(amount: amount),
    );
  }
}
