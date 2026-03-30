// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:ridenowappsss/core/utils/extensions/app_color_extension.dart';
import 'package:ridenowappsss/core/utils/extensions/app_font_extension.dart';
import 'package:ridenowappsss/modules/wallet/presentation/providers/bank_account_provider.dart';
import 'package:ridenowappsss/modules/wallet/presentation/views/widgets/choose_bank_account.dart';
import 'package:ridenowappsss/shared/widgets/ride_now_bottomsheet.dart';
import 'package:ridenowappsss/shared/widgets/ridenow_textfield.dart';
import 'package:ridenowappsss/core/services/toast_service.dart';

class AddANewBankAccount2 extends StatefulWidget {
  final String? selectedBankName;
  final String? selectedBankCode;
  final String? bankLogo;

  const AddANewBankAccount2({
    super.key,
    this.selectedBankName,
    this.selectedBankCode,
    this.bankLogo,
  });

  @override
  State<AddANewBankAccount2> createState() => _AddANewBankAccount2State();
}

class _AddANewBankAccount2State extends State<AddANewBankAccount2> {
  final TextEditingController _accountNumberController =
      TextEditingController();
  bool _isAddingAccount = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.selectedBankName != null && widget.selectedBankCode != null) {
        final viewModel = context.read<BankAccountProvider>();
        viewModel.setBankDetails(
          bankName: widget.selectedBankName!,
          bankCode: widget.selectedBankCode!,
        );
      }
    });

    _accountNumberController.addListener(() {
      context.read<BankAccountProvider>().onAccountNumberChanged(
        _accountNumberController.text,
      );
    });
  }

  @override
  void dispose() {
    _accountNumberController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message, {required bool isError}) {
    if (!mounted) return;

    if (isError) {
      ToastService.showError(message);
    } else {
      ToastService.showSuccess(message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorExtension>()!;
    final appFonts = Theme.of(context).extension<AppFontThemeExtension>()!;

    return Consumer<BankAccountProvider>(
      builder: (context, viewModel, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add a new bank account',
              style: appFonts.textSmMedium.copyWith(
                color: appColors.textPrimary,
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 25.h),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildBankDisplay(viewModel, appColors, appFonts),
                      SizedBox(height: 12.h),
                      Divider(color: appColors.gray300),
                      SizedBox(height: 17.h),
                      RidenowTextfield(
                        fieldName: 'Account number',
                        hintText: '0000000000',
                        controller: _accountNumberController,
                        maxLength: 10,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        enabled: !_isAddingAccount,
                      ),
                      SizedBox(height: 12.h),
                      _buildValidationStatus(
                        context,
                        viewModel,
                        appColors,
                        appFonts,
                      ),
                      SizedBox(height: 24.h),
                      _buildAddButton(viewModel, appColors, appFonts),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Displays selected bank information
  Widget _buildBankDisplay(
    BankAccountProvider viewModel,
    AppColorExtension appColors,
    AppFontThemeExtension appFonts,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: appColors.blue50.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: appColors.blue200),
      ),
      child: Row(
        children: [
          _buildBankLogo(widget.bankLogo ?? viewModel.selectedBankCode, appColors),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Selected Bank',
                  style: appFonts.textSmMedium.copyWith(
                    color: appColors.gray400,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  viewModel.selectedBankName ?? 'No bank selected',
                  style: appFonts.textSmMedium.copyWith(
                    color: appColors.textPrimary,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Shows account validation status
  Widget _buildValidationStatus(
    BuildContext context,
    BankAccountProvider viewModel,
    AppColorExtension appColors,
    AppFontThemeExtension appFonts,
  ) {
    if (!viewModel.isValidating &&
        viewModel.accountHolderName == null &&
        viewModel.errorMessage == null) {
      return const SizedBox.shrink();
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (viewModel.isValidating)
            _buildValidatingIndicator(appColors, appFonts)
          else if (viewModel.isAccountValid)
            _buildSuccessIndicator(viewModel, appColors, appFonts)
          else if (viewModel.hasError)
            _buildErrorIndicator(viewModel, appColors, appFonts),
        ],
      ),
    );
  }

  Widget _buildValidatingIndicator(
    AppColorExtension appColors,
    AppFontThemeExtension appFonts,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: appColors.blue50,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: appColors.blue200),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 16.w,
            height: 16.h,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(appColors.blue600),
            ),
          ),
          SizedBox(width: 12.w),
          Text(
            'Verifying account number...',
            style: appFonts.textSmMedium.copyWith(
              color: appColors.blue700,
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessIndicator(
    BankAccountProvider viewModel,
    AppColorExtension appColors,
    AppFontThemeExtension appFonts,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: appColors.green50,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: appColors.green200),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: appColors.green600, size: 20.sp),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Account Verified',
                  style: appFonts.textSmMedium.copyWith(
                    color: appColors.green700,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  viewModel.accountHolderName!,
                  style: appFonts.textSmMedium.copyWith(
                    color: appColors.green800,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorIndicator(
    BankAccountProvider viewModel,
    AppColorExtension appColors,
    AppFontThemeExtension appFonts,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: appColors.red50,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: appColors.red200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.error_outline, color: appColors.red600, size: 20.sp),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              viewModel.errorMessage ?? 'Verification failed',
              style: appFonts.textSmMedium.copyWith(
                color: appColors.red700,
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton(
    BankAccountProvider viewModel,
    AppColorExtension appColors,
    AppFontThemeExtension appFonts,
  ) {
    final isEnabled = viewModel.canAddAccount && !_isAddingAccount;

    return GestureDetector(
      onTap: isEnabled ? () => _handleAddAccount(context) : null,
      child: Container(
        height: 49.h,
        width: double.infinity,
        decoration: BoxDecoration(
          color: isEnabled ? appColors.blue600 : appColors.gray100,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child:
            _isAddingAccount
                ? Center(
                  child: SizedBox(
                    width: 20.w,
                    height: 20.h,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                )
                : Padding(
                  padding: EdgeInsets.all(12.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        'assets/add.svg',
                        color:
                            isEnabled ? appColors.textWhite : appColors.gray500,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        'Add account number',
                        style: appFonts.textMdBold.copyWith(
                          color:
                              isEnabled
                                  ? appColors.textWhite
                                  : appColors.gray500,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
      ),
    );
  }

  /// Handles bank account addition with validation and error handling
  Future<void> _handleAddAccount(BuildContext context) async {
    final viewModel = context.read<BankAccountProvider>();

    if (!viewModel.canAddAccount) {
      _showSnackBar(
        'Please enter a valid account number and verify it',
        isError: true,
      );
      return;
    }

    if (_isAddingAccount) return;

    if (viewModel.selectedBankName == null ||
        viewModel.selectedBankCode == null ||
        viewModel.accountHolderName == null ||
        viewModel.accountNumber.isEmpty) {
      _showSnackBar(
        'Missing required information. Please try again.',
        isError: true,
      );
      return;
    }

    setState(() {
      _isAddingAccount = true;
    });

    try {
      final bankAccount = await viewModel.addBankAccount();

      if (!mounted) return;

      setState(() {
        _isAddingAccount = false;
      });

      if (bankAccount != null) {
        _showSnackBar('Bank account added successfully', isError: false);
        await Future.delayed(const Duration(milliseconds: 500));

        if (!mounted) return;
        Navigator.pop(context);

        await Future.delayed(const Duration(milliseconds: 300));

        if (!mounted) return;

        final bankAccountViewModel = context.read<BankAccountProvider>();
        await bankAccountViewModel.fetchBankAccounts();

        if (!mounted) return;

        RideNowBottomSheet.show(
          context: context,
          height: 389.h,
          backgroundColor: Colors.white,
          borderRadius: 16.r,
          child: const ChooseBankAccount(),
        );
      } else {
        final errorMsg = viewModel.errorMessage ?? 'Failed to add bank account';
        _showSnackBar(errorMsg, isError: true);
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isAddingAccount = false;
      });

      String errorMessage = 'An error occurred. Please try again.';

      final errorStr = e.toString().toLowerCase();
      if (errorStr.contains('duplicate') ||
          errorStr.contains('already exists')) {
        errorMessage = 'This account already exists';
      } else if (errorStr.contains('network') ||
          errorStr.contains('connection')) {
        errorMessage = 'Network error. Please check your connection.';
      } else if (errorStr.contains('timeout')) {
        errorMessage = 'Request timeout. Please try again.';
      } else if (errorStr.contains('400')) {
        errorMessage = 'Invalid account details. Please check and try again.';
      } else if (errorStr.contains('401') || errorStr.contains('403')) {
        errorMessage = 'Authentication error. Please login again.';
      } else if (errorStr.contains('500')) {
        errorMessage = 'Server error. Please try again later.';
      }

      _showSnackBar(errorMessage, isError: true);
    }
  }

  Widget _buildBankLogo(String? logoIdentifier, AppColorExtension appColors) {
    if (logoIdentifier == null) {
      return Icon(Icons.account_balance, size: 24.sp, color: appColors.blue600);
    }

    final logoUrl = logoIdentifier.startsWith('http')
        ? logoIdentifier
        : 'https://cdn.paystack.co/bank/logos/$logoIdentifier.png';

    return Container(
      width: 36.w,
      height: 36.w,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: appColors.blue200, width: 1),
      ),
      child: ClipOval(
        child: Image.network(
          logoUrl,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return Center(
              child: Icon(
                Icons.account_balance,
                size: 20.sp,
                color: appColors.blue600,
              ),
            );
          },
        ),
      ),
    );
  }
}
