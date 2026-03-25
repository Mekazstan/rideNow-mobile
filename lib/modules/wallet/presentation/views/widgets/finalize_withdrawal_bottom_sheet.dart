import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:ridenowappsss/core/utils/extensions/app_color_extension.dart';
import 'package:ridenowappsss/core/utils/extensions/app_font_extension.dart';
import 'package:ridenowappsss/modules/wallet/presentation/providers/wallet_provider.dart';
import 'package:ridenowappsss/shared/widgets/ridenow_button.dart';

class FinalizeWithdrawalBottomSheet extends StatefulWidget {
  final String transferCode;
  final String transactionId;

  const FinalizeWithdrawalBottomSheet({
    Key? key,
    required this.transferCode,
    required this.transactionId,
  }) : super(key: key);

  @override
  State<FinalizeWithdrawalBottomSheet> createState() =>
      _FinalizeWithdrawalBottomSheetState();
}

class _FinalizeWithdrawalBottomSheetState
    extends State<FinalizeWithdrawalBottomSheet> {
  final TextEditingController _otpController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _finalize() async {
    if (_otpController.text.trim().isEmpty) {
      setState(() => _errorMessage = 'Please enter the OTP');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final walletProvider =
          Provider.of<WalletProvider>(context, listen: false);
      final result = await walletProvider.finalizeWithdrawal(
        transferCode: widget.transferCode,
        otp: _otpController.text.trim(),
        transactionId: widget.transactionId,
      );

      if (mounted) {
        final appColors = Theme.of(context).extension<AppColorExtension>()!;
        Navigator.pop(context); // Close sheet
        
        // Show success
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result?['message'] ?? 'Withdrawal completed successfully'),
            backgroundColor: appColors.green500,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString().replaceAll('Exception: ', '');
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorExtension>()!;
    final appFonts = Theme.of(context).extension<AppFontThemeExtension>()!;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Enter OTP',
                style: appFonts.textBaseMedium.copyWith(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w600,
                  color: appColors.textPrimary,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.close, color: appColors.textSecondary),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            'Please enter the OTP sent to your email or phone number by Paystack.',
            style: appFonts.textBaseRegular.copyWith(
              fontSize: 14.sp,
              color: appColors.textSecondary,
            ),
          ),
          SizedBox(height: 24.h),
          TextField(
            controller: _otpController,
            keyboardType: TextInputType.number,
            maxLength: 6,
            decoration: InputDecoration(
              hintText: 'Enter 6-digit OTP',
              errorText: _errorMessage,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: const Color(0xFFE2E8F0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: const Color(0xFFE2E8F0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: appColors.brandDefault),
              ),
            ),
          ),
          SizedBox(height: 24.h),
          RideNowButton(
            title: 'Finalize Withdrawal',
            isLoading: _isLoading,
            onTap: _finalize,
          ),
        ],
      ),
    );
  }
}
