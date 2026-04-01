import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:ridenowappsss/core/utils/extensions/app_color_extension.dart';
import 'package:ridenowappsss/core/utils/extensions/app_font_extension.dart';
import 'package:ridenowappsss/modules/ride/presentation/views/widgets/ride_confirmation_bottom_sheet.dart';
import 'package:ridenowappsss/modules/wallet/presentation/providers/wallet_provider.dart';
import 'package:ridenowappsss/core/utils/extensions/amount_extension_validations_utils.dart';

class AmountBottomSheet {
  static void show(
    BuildContext context, {
    required String destination,
    required String pickup,
    required Function() onTopUp,
  }) {
    final appColors = Theme.of(context).extension<AppColorExtension>()!;
    final appFonts = Theme.of(context).extension<AppFontThemeExtension>()!;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.transparent,
      builder:
          (context) => _AmountBottomSheetContent(
            appColors: appColors,
            appFonts: appFonts,
            destination: destination,
            pickup: pickup,
            onTopUp: onTopUp,
          ),
    );
  }
}

class _AmountBottomSheetContent extends StatefulWidget {
  final AppColorExtension appColors;
  final AppFontThemeExtension appFonts;
  final String destination;
  final String pickup;
  final Function() onTopUp;

  const _AmountBottomSheetContent({
    required this.appColors,
    required this.appFonts,
    required this.destination,
    required this.pickup,
    required this.onTopUp,
  });

  @override
  State<_AmountBottomSheetContent> createState() =>
      _AmountBottomSheetContentState();
}

class _AmountBottomSheetContentState extends State<_AmountBottomSheetContent> {
  final TextEditingController _amountController = TextEditingController();
  bool _isAutoAccept = false;
  String? _errorMessage;
  Color _containerColor = Colors.transparent;

  @override
  void initState() {
    super.initState();
    // Fetch wallet balance when the bottom sheet opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WalletProvider>().fetchBalance();
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  bool get _isAmountValid {
    final text = _amountController.text.replaceAll(',', '').trim();
    return text.isNotEmpty && (int.tryParse(text) ?? 0) > 0;
  }

  void _validateAndContinue(WalletProvider walletProvider) {
    final amount = _amountController.text.replaceAll(',', '').trim();

    if (amount.isEmpty) {
      setState(() {
        _errorMessage = 'You need to enter an amount to book a driver';
        _containerColor = widget.appColors.red50;
      });
      return;
    }

    final amountValue = double.tryParse(amount);
    if (amountValue == null) {
      setState(() {
        _errorMessage = 'Please enter a valid amount';
        _containerColor = widget.appColors.red50;
      });
      return;
    }

    final balance = walletProvider.walletBalance?.balance ?? 0.0;

    if (amountValue > balance) {
      setState(() {
        _errorMessage = 'You don\'t have enough in your wallet. Top up';
        _containerColor = widget.appColors.red50;
      });
      return;
    }

    Navigator.pop(context);

    // Show the RideConfirmationSheet with pickup and destination
    RideConfirmationSheet.show(
      context,
      rideAmount: amount,
      destination: widget.destination,
      pickup: widget.pickup,
      onTopUp: widget.onTopUp,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 380.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.r),
          topRight: Radius.circular(20.r),
        ),
      ),
      child: Column(
        children: [
          _DragHandle(appColors: widget.appColors),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 24.h),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: double.infinity,
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: _containerColor,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color:
                            _errorMessage != null
                                ? (widget.appColors.red500)
                                : Colors.transparent,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'How much do you want to pay',
                          style: widget.appFonts.textSmRegular.copyWith(
                            color: widget.appColors.textSecondary,
                            fontSize: 13.sp,
                          ),
                        ),
                        SizedBox(height: 8.h),

                        // Amount Input Field
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '₦',
                              style: widget.appFonts.textBaseMedium.copyWith(
                                color:
                                    _errorMessage != null
                                        ? (widget.appColors.red500)
                                        : widget.appColors.textPrimary,
                                fontSize: 32.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Flexible(
                              child: IntrinsicWidth(
                                child: TextField(
                                  controller: _amountController,
                                  keyboardType: TextInputType.number,
                                  textAlign: TextAlign.center,
                                  autofocus: true,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(RegExp(r'[0-9,]')),
                                    CommaInputFormatter(),
                                  ],
                                  style: widget.appFonts.textBaseMedium
                                      .copyWith(
                                        color:
                                            _errorMessage != null
                                                ? (widget.appColors.red500)
                                                : widget.appColors.textPrimary,
                                        fontSize: 32.sp,
                                        fontWeight: FontWeight.w700,
                                      ),
                                  decoration: InputDecoration(
                                    hintText: '5000',
                                    hintStyle: widget.appFonts.textBaseMedium
                                        .copyWith(
                                          color: widget.appColors.gray300,
                                          fontSize: 32.sp,
                                          fontWeight: FontWeight.w700,
                                        ),
                                    border: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    isDense: true,
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                  onChanged: (value) {
                                    setState(() {
                                      _errorMessage = null;
                                      _containerColor = Colors.transparent;
                                    });
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),

                        // Divider
                        Container(
                          height: 1.h,
                          color:
                              _errorMessage != null
                                  ? (widget.appColors.red500)
                                  : widget.appColors.gray200,
                          margin: EdgeInsets.symmetric(vertical: 8.h),
                        ),

                        // Error Message
                        if (_errorMessage != null)
                          Text(
                            _errorMessage!,
                            style: widget.appFonts.textSmRegular.copyWith(
                              color: widget.appColors.red500,
                              fontSize: 12.sp,
                            ),
                            textAlign: TextAlign.center,
                          ),
                      ],
                    ),
                  ),

                  SizedBox(height: 16.h),

                  // Auto Accept Toggle
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _isAutoAccept = !_isAutoAccept;
                          });
                        },
                        child: Container(
                          width: 44.w,
                          height: 24.h,
                          decoration: BoxDecoration(
                            color:
                                _isAutoAccept
                                    ? widget.appColors.blue500
                                    : widget.appColors.gray200,
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          padding: EdgeInsets.all(2.w),
                          child: AnimatedAlign(
                            duration: const Duration(milliseconds: 200),
                            alignment:
                                _isAutoAccept
                                    ? Alignment.centerRight
                                    : Alignment.centerLeft,
                            child: Container(
                              width: 20.w,
                              height: 20.h,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Text(
                          _amountController.text.isEmpty
                              ? 'Accept the nearest driver automatically.'
                              : 'Accept the nearest driver for ${_amountController.text.formatAmountWithCurrency()} automatically.',
                          style: widget.appFonts.textSmRegular.copyWith(
                            color: widget.appColors.textSecondary,
                            fontSize: 13.sp,
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 24.h),
                ],
              ),
            ),
          ),

          // Continue Button
          Consumer<WalletProvider>(
            builder: (context, walletProvider, _) {
              return Padding(
                padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 32.h),
                child: SizedBox(
                  width: double.infinity,
                  height: 48.h,
                  child: ElevatedButton(
                    onPressed:
                        _isAmountValid
                            ? () => _validateAndContinue(walletProvider)
                            : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          _isAmountValid
                              ? widget.appColors.blue600
                              : widget.appColors.gray200,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      disabledBackgroundColor: widget.appColors.gray200,
                    ),
                    child: Text(
                      'Continue',
                      style: widget.appFonts.textBaseMedium.copyWith(
                        color:
                            _isAmountValid
                                ? Colors.white
                                : widget.appColors.gray400,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _DragHandle extends StatelessWidget {
  final AppColorExtension appColors;

  const _DragHandle({required this.appColors});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: EdgeInsets.only(top: 12.h),
        width: 40.w,
        height: 4.h,
        decoration: BoxDecoration(
          color: appColors.gray300,
          borderRadius: BorderRadius.circular(2.r),
        ),
      ),
    );
  }
}
