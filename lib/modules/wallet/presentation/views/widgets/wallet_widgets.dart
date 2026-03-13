import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:ridenowappsss/core/utils/extensions/app_color_extension.dart';
import 'package:ridenowappsss/core/utils/extensions/app_font_extension.dart';
import 'package:ridenowappsss/modules/wallet/data/models/wallet_models.dart';
import 'package:ridenowappsss/modules/wallet/presentation/providers/wallet_provider.dart';
import 'package:ridenowappsss/modules/wallet/presentation/views/widgets/transaction_listview.dart';
import 'package:ridenowappsss/shared/widgets/ride_now_bottomsheet.dart';
import 'package:ridenowappsss/shared/widgets/ridenow_textfield.dart';
import 'package:ridenowappsss/shared/widgets/shimmer_widget.dart';

class BalanceDisplay extends StatelessWidget {
  final String balance;
  final String currency;
  final bool isVisible;
  final VoidCallback onToggleVisibility;

  const BalanceDisplay({
    super.key,
    required this.balance,
    required this.currency,
    required this.isVisible,
    required this.onToggleVisibility,
  });

  /// Formats balance with thousand separators
  String _formatBalance(String balance) {
    final numericBalance = double.tryParse(balance.replaceAll(',', '')) ?? 0.0;
    final formatter = NumberFormat('#,###');
    return formatter.format(numericBalance.round());
  }

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorExtension>()!;
    final appFonts = Theme.of(context).extension<AppFontThemeExtension>()!;
    final formattedBalance = _formatBalance(balance);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          isVisible ? '$currency $formattedBalance' : '****',
          style: appFonts.textSmMedium.copyWith(
            color: appColors.textPrimary,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(width: 8.w),
        GestureDetector(
          onTap: onToggleVisibility,
          child: Icon(
            isVisible ? Icons.visibility : Icons.visibility_off,
            color: appColors.gray300,
            size: 16.sp,
          ),
        ),
      ],
    );
  }
}

/// Container for deposit and withdraw action buttons
class WalletActionButtons extends StatelessWidget {
  final VoidCallback onDeposit;
  final VoidCallback onWithdraw;

  const WalletActionButtons({
    super.key,
    required this.onDeposit,
    required this.onWithdraw,
  });

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorExtension>()!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          WalletActionButton(
            onTap: onDeposit,
            color: appColors.pink500,
            label: 'Deposit',
          ),
          WalletActionButton(
            onTap: onWithdraw,
            color: appColors.blue600,
            label: 'Withdraw',
          ),
        ],
      ),
    );
  }
}

/// Individual wallet action button
class WalletActionButton extends StatelessWidget {
  final VoidCallback onTap;
  final Color color;
  final String label;

  const WalletActionButton({
    super.key,
    required this.onTap,
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final appFonts = Theme.of(context).extension<AppFontThemeExtension>()!;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 41.h,
        width: 146.w,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset('assets/deposit.svg', height: 16.sp, width: 16.sp),
            SizedBox(width: 8.w),
            Text(
              label,
              style: appFonts.textBaseMedium.copyWith(
                color: Colors.white,
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Manages transaction list states (loading, error, empty, success)
class WalletTransactionsList extends StatelessWidget {
  final WalletProvider provider;
  final ScrollController scrollController;
  final VoidCallback onRetry;

  const WalletTransactionsList({
    super.key,
    required this.provider,
    required this.scrollController,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    if (provider.isLoading && !provider.hasData) {
      return const TransactionsListShimmer(itemCount: 6);
    }

    if (provider.hasError) {
      return TransactionsErrorState(onRetry: onRetry);
    }

    if (provider.transactions.isEmpty && !provider.isLoading) {
      return const TransactionsEmptyState();
    }

    return TransactionsListView(
      provider: provider,
      scrollController: scrollController,
    );
  }
}

/// Date header for transaction groups
class TransactionDateHeader extends StatelessWidget {
  final String dateGroup;
  final bool isCurrentDay;
  final VoidCallback? onFilterTap;

  const TransactionDateHeader({
    super.key,
    required this.dateGroup,
    this.isCurrentDay = false,
    this.onFilterTap,
  });

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorExtension>()!;
    final appFonts = Theme.of(context).extension<AppFontThemeExtension>()!;

    return Padding(
      padding: EdgeInsets.only(top: 16.h, bottom: 12.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            dateGroup,
            style: appFonts.textSmMedium.copyWith(
              color: appColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (isCurrentDay && onFilterTap != null)
            GestureDetector(
              onTap: onFilterTap,
              child: SvgPicture.asset(
                'assets/more.svg',
                height: 19.sp,
                width: 19.sp,
              ),
            ),
        ],
      ),
    );
  }
}

/// Displays individual transaction with dynamic styling
class TransactionItem extends StatelessWidget {
  final WalletTransaction transaction;

  const TransactionItem({super.key, required this.transaction});

  /// Formats amount with thousand separators
  String _formatAmount(double amount) {
    final formatter = NumberFormat('#,###');
    return formatter.format(amount.round());
  }

  /// Returns colors based on transaction type
  Map<String, Color> _getTransactionColors(
    WalletTransaction transaction,
    AppColorExtension appColors,
  ) {
    Color containerColor, titleColor, dateColor, amountColor;

    if (transaction.isWithdrawal) {
      containerColor = appColors.red50;
      titleColor = appColors.red400;
      dateColor = appColors.red200;
      amountColor = appColors.red600;
    } else if (transaction.isDeposit) {
      containerColor = appColors.gray100;
      titleColor = appColors.gray400;
      dateColor = appColors.gray300;
      amountColor = appColors.gray600;
    } else {
      containerColor = appColors.orange50;
      titleColor = appColors.orange400;
      dateColor = appColors.orange200;
      amountColor = appColors.gray600;
    }

    final statusColors = _getStatusColors(transaction.status, appColors);

    return {
      'container': containerColor,
      'title': titleColor,
      'date': dateColor,
      'amount': amountColor,
      'statusBg': statusColors['bg']!,
      'statusText': statusColors['text']!,
      'statusBorder': statusColors['border']!,
    };
  }

  /// Returns colors based on transaction status
  Map<String, Color> _getStatusColors(
    String status,
    AppColorExtension appColors,
  ) {
    final normalizedStatus = status.toLowerCase();

    if (normalizedStatus == 'successful' ||
        normalizedStatus == 'success' ||
        normalizedStatus == 'completed') {
      return {
        'bg': appColors.green100,
        'text': appColors.green400,
        'border': appColors.green400,
      };
    } else if (normalizedStatus == 'pending') {
      return {
        'bg': appColors.orange100,
        'text': appColors.orange300,
        'border': appColors.orange300,
      };
    } else {
      return {
        'bg': appColors.red100,
        'text': appColors.red400,
        'border': appColors.red400,
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorExtension>()!;
    final appFonts = Theme.of(context).extension<AppFontThemeExtension>()!;
    final colors = _getTransactionColors(transaction, appColors);

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      height: 65.h,
      width: double.infinity,
      decoration: BoxDecoration(
        color: colors['container'],
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 10),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    transaction.description,
                    style: appFonts.textSmMedium.copyWith(
                      color: colors['title'],
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                TransactionStatusBadge(
                  status: transaction.status,
                  backgroundColor: colors['statusBg']!,
                  textColor: colors['statusText']!,
                  borderColor: colors['statusBorder']!,
                ),
              ],
            ),
            SizedBox(height: 6.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  transaction.formattedDate,
                  style: appFonts.textSmMedium.copyWith(
                    color: colors['date'],
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                Text(
                  '${transaction.currency} ${_formatAmount(transaction.amount)}',
                  style: appFonts.textSmMedium.copyWith(
                    color: colors['amount'],
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Status badge for transaction item
class TransactionStatusBadge extends StatelessWidget {
  final String status;
  final Color backgroundColor;
  final Color textColor;
  final Color borderColor;

  const TransactionStatusBadge({
    super.key,
    required this.status,
    required this.backgroundColor,
    required this.textColor,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final appFonts = Theme.of(context).extension<AppFontThemeExtension>()!;

    return Container(
      height: 18.h,
      padding: EdgeInsets.symmetric(horizontal: 8.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: borderColor),
        color: backgroundColor,
      ),
      child: Center(
        child: Text(
          status,
          style: appFonts.textSmMedium.copyWith(
            color: textColor,
            fontSize: 12.sp,
            fontWeight: FontWeight.w300,
          ),
        ),
      ),
    );
  }
}

/// Error state with retry button
class TransactionsErrorState extends StatelessWidget {
  final VoidCallback onRetry;

  const TransactionsErrorState({super.key, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorExtension>()!;
    final appFonts = Theme.of(context).extension<AppFontThemeExtension>()!;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64.sp, color: appColors.red400),
          SizedBox(height: 16.h),
          Text(
            'Failed to load transactions',
            style: appFonts.textBaseMedium.copyWith(
              color: appColors.textPrimary,
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Please try again',
            style: appFonts.textSmRegular.copyWith(
              color: appColors.gray500,
              fontSize: 14.sp,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24.h),
          ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(
              backgroundColor: appColors.blue600,
              padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 12.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            child: Text(
              'Retry',
              style: appFonts.textBaseMedium.copyWith(
                color: Colors.white,
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Empty state when no transactions exist
class TransactionsEmptyState extends StatelessWidget {
  const TransactionsEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorExtension>()!;
    final appFonts = Theme.of(context).extension<AppFontThemeExtension>()!;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 64.sp,
            color: appColors.gray400,
          ),
          SizedBox(height: 16.h),
          Text(
            'No transactions yet',
            style: appFonts.textBaseMedium.copyWith(
              color: appColors.textPrimary,
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Your transaction history will appear here',
            style: appFonts.textSmRegular.copyWith(
              color: appColors.gray500,
              fontSize: 14.sp,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Bottom sheet for filtering transactions by date
class DateFilterBottomSheet extends StatefulWidget {
  final DateTime? selectedStartDate;
  final DateTime? selectedEndDate;
  final Function(DateTime?, DateTime?) onApplyFilter;
  final VoidCallback? onClearFilter;

  const DateFilterBottomSheet({
    super.key,
    this.selectedStartDate,
    this.selectedEndDate,
    required this.onApplyFilter,
    this.onClearFilter,
  });

  @override
  State<DateFilterBottomSheet> createState() => _DateFilterBottomSheetState();
}

class _DateFilterBottomSheetState extends State<DateFilterBottomSheet> {
  DateTime? _fromDate;
  DateTime? _toDate;
  String? _selectedFilter;

  @override
  void initState() {
    super.initState();
    _fromDate = widget.selectedStartDate;
    _toDate = widget.selectedEndDate;
  }

  /// Handles quick filter selection
  void _selectQuickFilter(String filter) {
    setState(() {
      _selectedFilter = filter;
      final now = DateTime.now();

      switch (filter) {
        case 'Today':
          _fromDate = DateTime(now.year, now.month, now.day);
          _toDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
          break;
        case 'last 7 days':
          _fromDate = now.subtract(const Duration(days: 7));
          _toDate = now;
          break;
        case 'Last 14 days':
          _fromDate = now.subtract(const Duration(days: 14));
          _toDate = now;
          break;
        case 'Last Month':
          _fromDate = DateTime(now.year, now.month - 1, 1);
          _toDate = DateTime(now.year, now.month, 0, 23, 59, 59);
          break;
        case 'Custom':
          _selectedFilter = 'Custom';
          break;
        default:
          _fromDate = null;
          _toDate = null;
      }
    });
  }

  /// Opens date picker for custom date selection
  Future<void> _pickDate(bool isFromDate) async {
    final initialDate =
        isFromDate
            ? (_fromDate ?? DateTime.now())
            : (_toDate ?? DateTime.now());

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        final appColors = Theme.of(context).extension<AppColorExtension>()!;
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: appColors.blue600,
              onPrimary: Colors.white,
              surface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      setState(() {
        _selectedFilter = 'Custom';
        if (isFromDate) {
          _fromDate = pickedDate;
        } else {
          _toDate = pickedDate;
        }
      });
    }
  }

  /// Applies selected filters and closes bottom sheet
  void _applyFilters() {
    widget.onApplyFilter(_fromDate, _toDate);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorExtension>()!;
    final appFonts = Theme.of(context).extension<AppFontThemeExtension>()!;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 24.h),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.r),
                  color: appColors.blue50,
                ),
                child: Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Choose filter date',
                        style: appFonts.textSmMedium.copyWith(
                          color: appColors.textPrimary,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 16.h),
                      _FilterRadioOption(
                        label: 'Today',
                        isSelected: _selectedFilter == 'Today',
                        onTap: () => _selectQuickFilter('Today'),
                      ),
                      SizedBox(height: 12.h),
                      _FilterRadioOption(
                        label: 'last 7 days',
                        isSelected: _selectedFilter == 'last 7 days',
                        onTap: () => _selectQuickFilter('last 7 days'),
                      ),
                      SizedBox(height: 12.h),
                      _FilterRadioOption(
                        label: 'Last 14 days',
                        isSelected: _selectedFilter == 'Last 14 days',
                        onTap: () => _selectQuickFilter('Last 14 days'),
                      ),
                      SizedBox(height: 12.h),
                      _FilterRadioOption(
                        label: 'Last Month',
                        isSelected: _selectedFilter == 'Last Month',
                        onTap: () => _selectQuickFilter('Last Month'),
                      ),
                      SizedBox(height: 12.h),
                      _FilterRadioOption(
                        label: 'Custom',
                        isSelected: _selectedFilter == 'Custom',
                        onTap: () => _selectQuickFilter('Custom'),
                      ),
                    ],
                  ),
                ),
              ),
              if (_selectedFilter == 'Custom') ...[
                SizedBox(height: 24.h),
                RidenowTextfield(
                  fieldName: 'From',
                  hintText: 'Date',
                  controller: TextEditingController(
                    text:
                        _fromDate != null
                            ? DateFormat('dd/MM/yyyy').format(_fromDate!)
                            : '',
                  ),
                  readOnly: true,
                  onTap: () => _pickDate(true),
                ),
                SizedBox(height: 16.h),
                RidenowTextfield(
                  fieldName: 'To',
                  hintText: 'Date',
                  controller: TextEditingController(
                    text:
                        _toDate != null
                            ? DateFormat('dd/MM/yyyy').format(_toDate!)
                            : '',
                  ),
                  readOnly: true,
                  onTap: () => _pickDate(false),
                ),
              ],
              SizedBox(height: 24.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _applyFilters,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: appColors.blue600,
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Apply',
                    style: appFonts.textBaseMedium.copyWith(
                      color: Colors.white,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Radio button option for filter selection
class _FilterRadioOption extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterRadioOption({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorExtension>()!;
    final appFonts = Theme.of(context).extension<AppFontThemeExtension>()!;

    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 20.w,
            height: 20.h,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? (appColors.blue500) : (appColors.gray300),
                width: 2,
              ),
              color: Colors.transparent,
            ),
            child:
                isSelected
                    ? Center(
                      child: Container(
                        width: 10.w,
                        height: 10.h,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: appColors.blue500,
                        ),
                      ),
                    )
                    : null,
          ),
          SizedBox(width: 12.w),
          Text(
            label,
            style: appFonts.textSmMedium.copyWith(
              color: appColors.textPrimary,
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

/// Shows date filter bottom sheet
void showDateFilterBottomSheet({
  required BuildContext context,
  DateTime? selectedStartDate,
  DateTime? selectedEndDate,
  required Function(DateTime?, DateTime?) onApplyFilter,
  VoidCallback? onClearFilter,
}) {
  RideNowBottomSheet.show(
    height: 390,
    context: context,
    isScrollControlled: true,
    child: DateFilterBottomSheet(
      selectedStartDate: selectedStartDate,
      selectedEndDate: selectedEndDate,
      onApplyFilter: onApplyFilter,
      onClearFilter: onClearFilter,
    ),
  );
}
