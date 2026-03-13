import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ridenowappsss/core/utils/extensions/app_color_extension.dart';
import 'package:ridenowappsss/core/utils/extensions/app_font_extension.dart';
import 'package:ridenowappsss/modules/wallet/data/models/wallet_models.dart';
import 'package:ridenowappsss/modules/wallet/presentation/providers/wallet_provider.dart';
import 'package:ridenowappsss/modules/wallet/presentation/views/widgets/wallet_widgets.dart';

class TransactionsListView extends StatelessWidget {
  final WalletProvider provider;
  final ScrollController scrollController;

  const TransactionsListView({
    super.key,
    required this.provider,
    required this.scrollController,
  });

  bool _shouldShowFilterIcon() {
    return provider.transactions.isNotEmpty || provider.isFilterActive;
  }

  int _calculateTotalItems(Map<String, List<WalletTransaction>> grouped) {
    if (grouped.isEmpty && _shouldShowFilterIcon()) {
      return 2;
    }

    int count = grouped.length;
    grouped.forEach((_, transactions) {
      count += transactions.length;
    });
    return count;
  }

  Widget _buildListItem(
    BuildContext context,
    int index,
    Map<String, List<WalletTransaction>> grouped,
  ) {
    if (grouped.isEmpty && _shouldShowFilterIcon()) {
      if (index == 0) {
        return TransactionDateHeader(
          dateGroup: _getFilterHeaderText(),
          isCurrentDay: true,
          onFilterTap: () => _showDateFilterSheet(context),
        );
      } else {
        return _buildFilteredEmptyState(context);
      }
    }

    final dateGroups = grouped.keys.toList();
    int currentPos = 0;

    for (int groupIndex = 0; groupIndex < dateGroups.length; groupIndex++) {
      final dateGroup = dateGroups[groupIndex];
      final transactions = grouped[dateGroup]!;

      if (currentPos == index) {
        final isFirstGroup = groupIndex == 0;
        return TransactionDateHeader(
          dateGroup: dateGroup,
          isCurrentDay: isFirstGroup && _shouldShowFilterIcon(),
          onFilterTap:
              isFirstGroup && _shouldShowFilterIcon()
                  ? () => _showDateFilterSheet(context)
                  : null,
        );
      }
      currentPos++;

      for (int i = 0; i < transactions.length; i++) {
        if (currentPos == index) {
          return TransactionItem(transaction: transactions[i]);
        }
        currentPos++;
      }
    }

    return const SizedBox.shrink();
  }

  String _getFilterHeaderText() {
    if (provider.filterStartDate != null) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final filterDate = DateTime(
        provider.filterStartDate!.year,
        provider.filterStartDate!.month,
        provider.filterStartDate!.day,
      );

      if (filterDate == today) {
        return 'Today';
      } else if (filterDate == today.subtract(const Duration(days: 1))) {
        return 'Yesterday';
      }
    }
    return 'Filtered Results';
  }

  Widget _buildFilteredEmptyState(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorExtension>()!;
    final appFonts = Theme.of(context).extension<AppFontThemeExtension>()!;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 40.h),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.filter_list_off, size: 48.sp, color: appColors.gray400),
            SizedBox(height: 12.h),
            Text(
              'No transactions found',
              style: appFonts.textBaseMedium.copyWith(
                color: appColors.textPrimary,
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              'Try adjusting your filter',
              style: appFonts.textSmRegular.copyWith(
                color: appColors.gray500,
                fontSize: 12.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDateFilterSheet(BuildContext context) {
    showDateFilterBottomSheet(
      context: context,
      selectedStartDate: provider.filterStartDate,
      selectedEndDate: provider.filterEndDate,
      onApplyFilter: (startDate, endDate) {
        provider.applyDateFilter(startDate, endDate);
      },
      onClearFilter: () {
        provider.clearDateFilter();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorExtension>()!;
    final grouped = provider.groupedTransactions;

    return ListView.builder(
      controller: scrollController,
      itemCount:
          _calculateTotalItems(grouped) + (provider.isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _calculateTotalItems(grouped)) {
          return Padding(
            padding: EdgeInsets.all(16.h),
            child: Center(
              child: CircularProgressIndicator(color: appColors.blue600),
            ),
          );
        }

        return _buildListItem(context, index, grouped);
      },
    );
  }
}
