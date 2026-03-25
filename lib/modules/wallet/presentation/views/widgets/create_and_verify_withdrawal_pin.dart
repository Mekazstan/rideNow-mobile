import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:ridenowappsss/core/utils/extensions/amount_extension_validations_utils.dart';
import 'package:ridenowappsss/modules/authentication/presentation/views/widgets/otp_input_widget.dart';
import 'package:ridenowappsss/modules/wallet/presentation/providers/wallet_provider.dart';
import 'package:ridenowappsss/core/utils/extensions/app_color_extension.dart';
import 'package:ridenowappsss/core/utils/extensions/app_font_extension.dart';
import 'package:ridenowappsss/modules/wallet/data/models/wallet_models.dart';
import 'package:ridenowappsss/modules/wallet/presentation/views/widgets/finalize_withdrawal_bottom_sheet.dart';
import 'package:ridenowappsss/shared/widgets/ride_now_bottomsheet.dart';
import 'package:ridenowappsss/shared/widgets/ridenow_button.dart';

class CreateWithdrawalPINBottomSheet extends StatefulWidget {
  final BankAccount bankAccount;
  final double amount;

  const CreateWithdrawalPINBottomSheet({
    super.key,
    required this.bankAccount,
    required this.amount,
  });

  @override
  State<CreateWithdrawalPINBottomSheet> createState() =>
      _CreateWithdrawalPINBottomSheetState();
}

class _CreateWithdrawalPINBottomSheetState
    extends State<CreateWithdrawalPINBottomSheet> {
  final List<TextEditingController> _pinControllers = List.generate(
    4,
    (_) => TextEditingController(),
  );
  bool _isLoading = false;

  @override
  void dispose() {
    for (var controller in _pinControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  bool get _isPINComplete {
    return _pinControllers.every((controller) => controller.text.isNotEmpty);
  }

  String get _pin {
    return _pinControllers.map((c) => c.text).join();
  }

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorExtension>()!;
    final appFonts = Theme.of(context).extension<AppFontThemeExtension>()!;

    return Padding(
      padding: EdgeInsets.all(24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Create your 4-digit code',
            style: appFonts.textBaseMedium.copyWith(
              color: appColors.textPrimary,
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 32.h),
          OtpInputWidget(
            length: 4,
            controllers: _pinControllers,
            onCompleted: (pin) => setState(() {}),
          ),
          const Spacer(),
          RideNowButton(
            title: 'Continue',
            onTap: _handleContinue,
            isLoading: _isLoading,
            width: double.infinity,
            height: 48.h,
          ),
        ],
      ),
    );
  }

  /// Creates withdrawal PIN and opens verification sheet
  Future<void> _handleContinue() async {
    if (!_isPINComplete) return;

    setState(() => _isLoading = true);

    try {
      final walletProvider = context.read<WalletProvider>();

      await walletProvider.createWithdrawalPin(_pin);

      if (!mounted) return;

      Navigator.pop(context);

      RideNowBottomSheet.show(
        context: context,
        height: 300.h,
        backgroundColor: Colors.white,
        borderRadius: 16.r,
        hideBottomNav: false,
        child: VerifyWithdrawalPINBottomSheet(
          bankAccount: widget.bankAccount,
          amount: widget.amount,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      SnackBarHelper.showError(
        context,
        ErrorMessageParser.parsePINCreationError(e),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}

class VerifyWithdrawalPINBottomSheet extends StatefulWidget {
  final BankAccount bankAccount;
  final double amount;

  const VerifyWithdrawalPINBottomSheet({
    super.key,
    required this.bankAccount,
    required this.amount,
  });

  @override
  State<VerifyWithdrawalPINBottomSheet> createState() =>
      _VerifyWithdrawalPINBottomSheetState();
}

class _VerifyWithdrawalPINBottomSheetState
    extends State<VerifyWithdrawalPINBottomSheet> {
  final List<TextEditingController> _pinControllers = List.generate(
    4,
    (_) => TextEditingController(),
  );
  bool _isLoading = false;

  @override
  void dispose() {
    for (var controller in _pinControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  bool get _isPINComplete {
    return _pinControllers.every((controller) => controller.text.isNotEmpty);
  }

  String get _pin {
    return _pinControllers.map((c) => c.text).join();
  }

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorExtension>()!;
    final appFonts = Theme.of(context).extension<AppFontThemeExtension>()!;

    return Padding(
      padding: EdgeInsets.all(24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Enter your 4-digit code',
            style: appFonts.textBaseMedium.copyWith(
              color: appColors.textPrimary,
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 32.h),
          OtpInputWidget(
            length: 4,
            controllers: _pinControllers,
            onCompleted: (pin) => setState(() {}),
          ),
          const Spacer(),
          RideNowButton(
            title: 'Continue',
            onTap: _handleContinue,
            isLoading: _isLoading,
            width: double.infinity,
            height: 48.h,
          ),
        ],
      ),
    );
  }

  /// Verifies PIN and initiates withdrawal
  Future<void> _handleContinue() async {
    if (!_isPINComplete) return;

    setState(() => _isLoading = true);

    try {
      final walletProvider = context.read<WalletProvider>();

      final response = await walletProvider.initiateWithdrawal(
        amount: widget.amount,
        bankAccountId: widget.bankAccount.id,
        withdrawalPin: _pin,
      );

      if (!mounted) return;

      if (response?['requiresOtp'] == true) {
        Navigator.pop(context); // Close PIN sheet

        RideNowBottomSheet.show(
          context: context,
          height: 380.h,
          backgroundColor: Colors.white,
          borderRadius: 16.r,
          hideBottomNav: false,
          child: FinalizeWithdrawalBottomSheet(
            transferCode: response?['transferCode'] ?? '',
            transactionId: response?['transaction_id'] ?? '',
          ),
        );
      } else {
        SnackBarHelper.showSuccess(
          context,
          response?['message'] ??
              'Withdrawal of ${widget.amount.formatAmountWithCurrency()} initiated successfully',
        );

        Navigator.pop(context);
      }
    } catch (e) {
      if (!mounted) return;

      SnackBarHelper.showError(
        context,
        ErrorMessageParser.parseWithdrawalError(e),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
