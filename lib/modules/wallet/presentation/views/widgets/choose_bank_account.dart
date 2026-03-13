// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:ridenowappsss/core/utils/extensions/app_color_extension.dart';
import 'package:ridenowappsss/core/utils/extensions/app_font_extension.dart';
import 'package:ridenowappsss/modules/wallet/data/models/wallet_models.dart';
import 'package:ridenowappsss/modules/wallet/presentation/providers/bank_account_provider.dart';
import 'package:ridenowappsss/modules/wallet/presentation/views/widgets/add_a_new_bank_card.dart';
import 'package:ridenowappsss/modules/wallet/presentation/views/widgets/withdrawal_bottom_sheet.dart';
import 'package:ridenowappsss/shared/widgets/ride_now_bottomsheet.dart';
import 'package:ridenowappsss/shared/widgets/shimmer_widget.dart';

class ChooseBankAccount extends StatefulWidget {
  const ChooseBankAccount({super.key});

  @override
  State<ChooseBankAccount> createState() => _ChooseBankAccountState();
}

class _ChooseBankAccountState extends State<ChooseBankAccount> {
  String? selectedMethod;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeBankAccounts();
    });
  }

  Future<void> _initializeBankAccounts() async {
    final viewModel = context.read<BankAccountProvider>();
    await viewModel.initialize();
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
              'Choose bank account',
              style: appFonts.textSmMedium.copyWith(
                color: appColors.textPrimary,
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 17.h),
            Text(
              'Saved banks',
              style: appFonts.textSmMedium.copyWith(
                color: appColors.gray400,
                fontSize: 12.sp,
                fontWeight: FontWeight.w300,
              ),
            ),
            SizedBox(height: 17.h),
            Expanded(
              child: Column(
                children: [
                  _AddNewBankAccountButton(
                    onTap: () => _addNewBankAccount(context, appColors),
                  ),
                  SizedBox(height: 12.h),
                  Divider(color: appColors.gray300, height: 1),
                  SizedBox(height: 12.h),
                  Expanded(
                    child: _buildBankAccountsList(
                      viewModel,
                      appColors,
                      appFonts,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  /// Builds appropriate state for bank accounts list
  Widget _buildBankAccountsList(
    BankAccountProvider viewModel,
    AppColorExtension appColors,
    AppFontThemeExtension appFonts,
  ) {
    if (viewModel.isLoading && !viewModel.hasSavedAccounts) {
      return const BankAccountListShimmer();
    }

    if (viewModel.hasError && !viewModel.hasSavedAccounts) {
      return _ErrorState(
        errorMessage: viewModel.errorMessage,
        onRetry: viewModel.initialize,
      );
    }

    if (!viewModel.isLoading && viewModel.savedBankAccounts.isEmpty) {
      return const _EmptyState();
    }

    return ListView.separated(
      itemCount: viewModel.savedBankAccounts.length,
      separatorBuilder:
          (context, index) => Column(
            children: [
              SizedBox(height: 12.h),
              Divider(color: appColors.gray300, height: 1),
              SizedBox(height: 12.h),
            ],
          ),
      itemBuilder: (context, index) {
        final bankAccount = viewModel.savedBankAccounts[index];
        final isSelected = selectedMethod == bankAccount.accountNumber;

        return _BankAccountItem(
          bankAccount: bankAccount,
          isSelected: isSelected,
          onTap: () => _handleBankAccountSelection(bankAccount),
        );
      },
    );
  }

  /// Handles bank account selection and opens withdrawal sheet
  void _handleBankAccountSelection(BankAccount bankAccount) {
    setState(() {
      selectedMethod = bankAccount.accountNumber;
    });

    Navigator.pop(context);

    RideNowBottomSheet.show(
      context: context,
      height: 450.h,
      backgroundColor: Colors.white,
      borderRadius: 16.r,
      child: WithdrawBottomSheetContent(selectedBankAccount: bankAccount),
    );
  }

  void _addNewBankAccount(BuildContext context, AppColorExtension appColors) {
    Navigator.pop(context);
    RideNowBottomSheet.show(
      context: context,
      height: 389.h,
      backgroundColor: Colors.white,
      borderRadius: 16.r,
      child: const AddANewBankCard(),
    );
  }
}

class _AddNewBankAccountButton extends StatelessWidget {
  final VoidCallback onTap;

  const _AddNewBankAccountButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorExtension>()!;
    final appFonts = Theme.of(context).extension<AppFontThemeExtension>()!;

    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          SvgPicture.asset(
            'assets/add.svg',
            color: appColors.blue500,
            width: 20.w,
            height: 20.w,
          ),
          SizedBox(width: 8.w),
          Text(
            'Add a new bank account',
            style: appFonts.textSmMedium.copyWith(
              color: appColors.blue500,
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

class _BankAccountItem extends StatelessWidget {
  final BankAccount bankAccount;
  final bool isSelected;
  final VoidCallback onTap;

  const _BankAccountItem({
    required this.bankAccount,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorExtension>()!;
    final appFonts = Theme.of(context).extension<AppFontThemeExtension>()!;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: isSelected ? appColors.blue50 : Colors.transparent,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Row(
          children: [
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
                  SizedBox(height: 6.h),
                  Text(
                    bankAccount.accountHolderName,
                    style: appFonts.textSmMedium.copyWith(
                      color: appColors.gray500,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 12.w),
            Row(
              children: [
                Text(
                  _formatAccountNumber(bankAccount.accountNumber),
                  style: appFonts.textSmMedium.copyWith(
                    color: appColors.blue500,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                SizedBox(width: 8.w),
                GestureDetector(
                  onTap:
                      () =>
                          _copyToClipboard(context, bankAccount.accountNumber),
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
      ),
    );
  }

  /// Formats account number with dashes
  String _formatAccountNumber(String accountNumber) {
    if (accountNumber.length >= 10) {
      return '${accountNumber.substring(0, 3)}-${accountNumber.substring(3, 5)}-${accountNumber.substring(5)}';
    }
    return accountNumber;
  }

  void _copyToClipboard(BuildContext context, String accountNumber) {
    Clipboard.setData(ClipboardData(text: accountNumber));
    final appColors = Theme.of(context).extension<AppColorExtension>()!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Account number copied to clipboard'),
        duration: const Duration(seconds: 1),
        backgroundColor: appColors.blue600,
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String? errorMessage;
  final VoidCallback onRetry;

  const _ErrorState({required this.errorMessage, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorExtension>()!;
    final appFonts = Theme.of(context).extension<AppFontThemeExtension>()!;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48.sp, color: appColors.red400),
          SizedBox(height: 16.h),
          Text(
            'Failed to load bank accounts',
            style: appFonts.textBaseMedium.copyWith(
              color: appColors.textPrimary,
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            errorMessage ?? 'Please try again',
            style: appFonts.textSmRegular.copyWith(
              color: appColors.gray500,
              fontSize: 12.sp,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16.h),
          ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(
              backgroundColor: appColors.blue600,
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 10.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            child: Text(
              'Retry',
              style: appFonts.textBaseMedium.copyWith(
                color: Colors.white,
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorExtension>()!;
    final appFonts = Theme.of(context).extension<AppFontThemeExtension>()!;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.account_balance_outlined,
            size: 48.sp,
            color: appColors.gray400,
          ),
          SizedBox(height: 16.h),
          Text(
            'No bank accounts saved',
            style: appFonts.textBaseMedium.copyWith(
              color: appColors.textPrimary,
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Add a bank account to get started',
            style: appFonts.textSmRegular.copyWith(
              color: appColors.gray500,
              fontSize: 12.sp,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class BankAccountListShimmer extends StatelessWidget {
  const BankAccountListShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 3,
      separatorBuilder:
          (context, index) => Column(
            children: [
              SizedBox(height: 12.h),
              Divider(color: Colors.grey[300], height: 1),
              SizedBox(height: 12.h),
            ],
          ),
      itemBuilder: (context, index) {
        return const BankAccountItemShimmer();
      },
    );
  }
}

class BankAccountItemShimmer extends StatelessWidget {
  const BankAccountItemShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerBox(width: 120.w, height: 14.h, borderRadius: 4.r),
                SizedBox(height: 10.h),
                ShimmerBox(width: 160.w, height: 12.h, borderRadius: 4.r),
              ],
            ),
          ),
          SizedBox(width: 16.w),
          ShimmerBox(width: 100.w, height: 14.h, borderRadius: 4.r),
        ],
      ),
    );
  }
}
