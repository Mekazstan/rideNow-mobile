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
    int count = provider.isFilterActive ? 1 : 0; // Filter indicator

    if (grouped.isEmpty && _shouldShowFilterIcon()) {
      return count + 1; // Header + Empty state
    }

    count += grouped.length; // Headers
    grouped.forEach((_, transactions) {
      count += transactions.length; // Items
    });
    return count;
  }

  Widget _buildListItem(
    BuildContext context,
    int index,
    Map<String, List<WalletTransaction>> grouped,
  ) {
    int currentIndex = index;

    // 1. Check for Active Filter Indicator
    if (provider.isFilterActive) {
      if (currentIndex == 0) {
        return ActiveFilterIndicator(
          startDate: provider.filterStartDate,
          endDate: provider.filterEndDate,
          onClear: () => provider.clearDateFilter(),
        );
      }
      currentIndex--;
    }

    // 2. Check for Empty State with Filter
    if (grouped.isEmpty && _shouldShowFilterIcon()) {
      if (currentIndex == 0) {
        return TransactionDateHeader(
          dateGroup: _getFilterHeaderText(),
          isCurrentDay: true,
          onFilterTap: () => _showDateFilterSheet(context),
        );
      } else {
        return _buildFilteredEmptyState(context);
      }
    }

    // 3. Normal List Items (Headers and Transactions)
    final dateGroups = grouped.keys.toList();
    int currentPos = 0;

    for (int groupIndex = 0; groupIndex < dateGroups.length; groupIndex++) {
      final dateGroup = dateGroups[groupIndex];
      final transactions = grouped[dateGroup]!;

      if (currentPos == currentIndex) {
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
        if (currentPos == currentIndex) {
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
    final appFonts = Theme.of(context).extension<AppFontThemeExtension>()!;
    final grouped = provider.groupedTransactions;
    final totalItems = _calculateTotalItems(grouped);

    // Show button/spinner if there are more pages
    final showLoadMore = provider.hasMorePages;

    return ListView.builder(
      controller: scrollController,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: totalItems + (showLoadMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == totalItems) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 24.h),
            child: Center(
              child: provider.isLoadingMore
                  ? SizedBox(
                      height: 24.h,
                      width: 24.w,
                      child: CircularProgressIndicator(
                        color: appColors.blue600,
                        strokeWidth: 2,
                      ),
                    )
                  : TextButton(
                      onPressed: () => provider.loadMoreTransactions(),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          horizontal: 24.w,
                          vertical: 12.h,
                        ),
                        backgroundColor: appColors.blue600.withOpacity(0.1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                      child: Text(
                        'Load More',
                        style: appFonts.textSmMedium.copyWith(
                          color: appColors.blue600,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
            ),
          );
        }

        return _buildListItem(context, index, grouped);
      },
    );
  }
}
