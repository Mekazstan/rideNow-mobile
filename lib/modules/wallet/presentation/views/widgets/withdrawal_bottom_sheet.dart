import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:ridenowappsss/core/utils/extensions/amount_extension_validations_utils.dart';
import 'package:ridenowappsss/modules/wallet/data/models/wallet_models.dart';
import 'package:ridenowappsss/modules/wallet/presentation/providers/wallet_provider.dart';
import 'package:ridenowappsss/modules/wallet/presentation/views/widgets/amount_input_bank_account_details.dart';
import 'package:ridenowappsss/modules/wallet/presentation/views/widgets/create_and_verify_withdrawal_pin.dart';
import 'package:ridenowappsss/modules/wallet/presentation/views/widgets/wallet_balance_card.dart';
import 'package:ridenowappsss/shared/widgets/ride_now_bottomsheet.dart';
import 'package:ridenowappsss/shared/widgets/ridenow_button.dart';

class WithdrawBottomSheetContent extends StatefulWidget {
  final BankAccount selectedBankAccount;

  const WithdrawBottomSheetContent({
    super.key,
    required this.selectedBankAccount,
  });

  @override
  State<WithdrawBottomSheetContent> createState() =>
      _WithdrawBottomSheetContentState();
}

class _WithdrawBottomSheetContentState
    extends State<WithdrawBottomSheetContent> {
  final TextEditingController _amountController = TextEditingController();
  bool _isAmountValid = false;
  String? _errorMessage;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WalletProvider>(
      builder: (context, walletProvider, _) {
        return SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                BalanceCard(
                  balance: walletProvider.walletBalance?.balance ?? 0,
                  currency: walletProvider.walletBalance?.currency ?? 'NGN',
                  hasError: _errorMessage != null,
                ),
                SizedBox(height: 24.h),
                AmountInput(
                  controller: _amountController,
                  errorMessage: _errorMessage,
                  onAmountChanged:
                      (value) => _handleAmountChange(
                        value,
                        walletProvider.walletBalance?.balance ?? 0,
                      ),
                ),
                SizedBox(height: 24.h),
                BankAccountDetails(
                  bankAccount: widget.selectedBankAccount,
                  onChangeBankAccount: _handleChangeBankAccount,
                ),
                SizedBox(height: 40.h),
                RideNowButton(
                  title: 'Continue',
                  onTap: _handleContinue,
                  width: double.infinity,
                  height: 48.h,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _handleAmountChange(String value, double balance) {
    setState(() {
      _errorMessage = WithdrawalValidator.validateAmount(value, balance);
      _isAmountValid = WithdrawalValidator.isValidAmount(value, balance);
    });
  }

  void _handleChangeBankAccount() {
    Navigator.pop(context);
  }

  void _handleContinue() {
    if (!_isAmountValid) return;

    final cleanAmount = _amountController.text.replaceAll(',', '');
    final amount = double.parse(cleanAmount);
    final walletProvider = Provider.of<WalletProvider>(context, listen: false);

    Navigator.pop(context);

    RideNowBottomSheet.show(
      context: context,
      height: 300.h,
      backgroundColor: Colors.white,
      borderRadius: 16.r,
      hideBottomNav: false,
      child: walletProvider.hasWithdrawalPin
          ? VerifyWithdrawalPINBottomSheet(
              bankAccount: widget.selectedBankAccount,
              amount: amount,
            )
          : CreateWithdrawalPINBottomSheet(
              bankAccount: widget.selectedBankAccount,
              amount: amount,
            ),
    );
  }
}
