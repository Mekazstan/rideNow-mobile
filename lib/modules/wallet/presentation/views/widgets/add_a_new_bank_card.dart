import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:ridenowappsss/core/utils/extensions/app_color_extension.dart';
import 'package:ridenowappsss/core/utils/extensions/app_font_extension.dart';
import 'package:ridenowappsss/modules/wallet/data/models/wallet_models.dart';
import 'package:ridenowappsss/modules/wallet/presentation/providers/banks_provider.dart';
import 'package:ridenowappsss/modules/wallet/presentation/views/widgets/add_a_new_bank_account_2.dart';
import 'package:ridenowappsss/shared/widgets/ride_now_bottomsheet.dart';
import 'package:ridenowappsss/shared/widgets/ride_now_search_bar.dart';
import 'package:ridenowappsss/shared/widgets/shimmer_widget.dart';

class AddANewBankCard extends StatefulWidget {
  const AddANewBankCard({super.key});

  @override
  State<AddANewBankCard> createState() => _AddANewBankCardState();
}

class _AddANewBankCardState extends State<AddANewBankCard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeBanks();
    });
  }

  Future<void> _initializeBanks() async {
    final viewModel = context.read<BanksProvider>();
    await viewModel.initialize();
  }

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorExtension>()!;
    final appFonts = Theme.of(context).extension<AppFontThemeExtension>()!;

    return Consumer<BanksProvider>(
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
            SizedBox(height: 17.h),
            RideNowSearchBar(
              hintText: 'Search banks',
              onChanged: (value) {
                viewModel.searchBanks(value);
              },
            ),
            SizedBox(height: 25.h),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.w),
                child: _buildBanksList(viewModel, appColors, appFonts),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Builds appropriate state for banks list
  Widget _buildBanksList(
    BanksProvider viewModel,
    AppColorExtension appColors,
    AppFontThemeExtension appFonts,
  ) {
    if (viewModel.isLoading && !viewModel.hasBanks) {
      return const BankListShimmer();
    }

    if (viewModel.hasError && !viewModel.hasBanks) {
      return _buildErrorState(viewModel, appColors, appFonts);
    }

    if (viewModel.filteredBanks.isEmpty) {
      return _buildEmptyState(appColors, appFonts);
    }

    return ListView.separated(
      itemCount: viewModel.filteredBanks.length,
      separatorBuilder:
          (context, index) => Column(
            children: [
              SizedBox(height: 12.h),
              Divider(color: appColors.gray300),
            ],
          ),
      itemBuilder: (context, index) {
        final bank = viewModel.filteredBanks[index];
        return _buildBankItem(bank, appColors, appFonts);
      },
    );
  }

  Widget _buildBankItem(
    Bank bank,
    AppColorExtension appColors,
    AppFontThemeExtension appFonts,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        _addBankAccount2(context, appColors, bank.name, bank.code);
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8.h),
        child: Row(
          children: [
            bank.logo != null
                ? Image.network(
                  bank.logo!,
                  width: 24.w,
                  height: 24.h,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.account_balance,
                      size: 24.sp,
                      color: appColors.gray400,
                    );
                  },
                )
                : Icon(
                  Icons.account_balance,
                  size: 24.sp,
                  color: appColors.gray400,
                ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                bank.name,
                style: appFonts.textSmMedium.copyWith(
                  color: appColors.gray600,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(
    BanksProvider viewModel,
    AppColorExtension appColors,
    AppFontThemeExtension appFonts,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48.sp, color: appColors.red400),
          SizedBox(height: 16.h),
          Text(
            'Failed to load banks',
            style: appFonts.textBaseMedium.copyWith(
              color: appColors.textPrimary,
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            viewModel.errorMessage ?? 'Please try again',
            style: appFonts.textSmRegular.copyWith(
              color: appColors.gray500,
              fontSize: 12.sp,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16.h),
          ElevatedButton(
            onPressed: () => viewModel.initialize(),
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

  Widget _buildEmptyState(
    AppColorExtension appColors,
    AppFontThemeExtension appFonts,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 48.sp, color: appColors.gray400),
          SizedBox(height: 16.h),
          Text(
            'No banks found',
            style: appFonts.textBaseMedium.copyWith(
              color: appColors.textPrimary,
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Try a different search term',
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

  /// Opens bottom sheet to add bank account details
  Future<BankAccount?> _addBankAccount2(
    BuildContext context,
    AppColorExtension appColors,
    String selectedBankName,
    String selectedBankCode,
  ) async {
    return await RideNowBottomSheet.show<BankAccount>(
      context: context,
      height: 400.h,
      backgroundColor: Colors.white,
      borderRadius: 16.r,
      child: AddANewBankAccount2(
        selectedBankName: selectedBankName,
        selectedBankCode: selectedBankCode,
      ),
    );
  }
}

class BankListShimmer extends StatelessWidget {
  const BankListShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 8,
      separatorBuilder:
          (context, index) => Column(
            children: [
              SizedBox(height: 12.h),
              Divider(color: Colors.grey[300]),
            ],
          ),
      itemBuilder: (context, index) {
        return const BankItemShimmer();
      },
    );
  }
}

class BankItemShimmer extends StatelessWidget {
  const BankItemShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        children: [
          ShimmerBox(width: 24.w, height: 24.h, borderRadius: 4.r),
          SizedBox(width: 12.w),
          ShimmerBox(width: 180.w, height: 14.h, borderRadius: 4.r),
        ],
      ),
    );
  }
}
