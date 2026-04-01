import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ridenowappsss/core/services/toast_service.dart';
import 'package:ridenowappsss/core/utils/extensions/app_color_extension.dart';
import 'package:ridenowappsss/core/utils/extensions/app_font_extension.dart';
import 'package:ridenowappsss/modules/wallet/data/models/wallet_models.dart';
import 'package:ridenowappsss/modules/wallet/presentation/providers/wallet_provider.dart';
import 'package:ridenowappsss/modules/wallet/presentation/views/widgets/transaction_listview.dart';
import 'package:ridenowappsss/shared/widgets/ride_now_bottomsheet.dart';
import 'package:ridenowappsss/shared/widgets/ridenow_textfield.dart';
import 'package:ridenowappsss/shared/widgets/shimmer_widget.dart';
import 'package:ridenowappsss/core/utils/extensions/amount_extension_validations_utils.dart';

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



  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorExtension>()!;
    final appFonts = Theme.of(context).extension<AppFontThemeExtension>()!;
    final formattedBalance = balance.formatAmount();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          isVisible ? '$currency$formattedBalance' : '****',
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

class ActiveFilterIndicator extends StatelessWidget {
  final DateTime? startDate;
  final DateTime? endDate;
  final VoidCallback onClear;

  const ActiveFilterIndicator({
    super.key,
    required this.startDate,
    required this.endDate,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    if (startDate == null && endDate == null) return const SizedBox.shrink();

    final appColors = Theme.of(context).extension<AppColorExtension>()!;
    final appFonts = Theme.of(context).extension<AppFontThemeExtension>()!;

    String filterText = '';
    if (startDate != null && endDate != null) {
      filterText =
          '${DateFormat('MMM dd').format(startDate!)} - ${DateFormat('MMM dd').format(endDate!)}';
    } else if (startDate != null) {
      filterText = 'From ${DateFormat('MMM dd').format(startDate!)}';
    } else if (endDate != null) {
      filterText = 'To ${DateFormat('MMM dd').format(endDate!)}';
    }

    return Padding(
      padding: EdgeInsets.only(top: 8.h),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: appColors.blue50,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: appColors.blue100),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.filter_list, size: 16.sp, color: appColors.blue600),
            SizedBox(width: 8.w),
            Text(
              'Filter: $filterText',
              style: appFonts.textSmMedium.copyWith(
                color: appColors.blue600,
                fontSize: 12.sp,
              ),
            ),
            SizedBox(width: 12.w),
            GestureDetector(
              onTap: onClear,
              child: Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: appColors.blue600.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.close, size: 14.sp, color: appColors.blue600),
              ),
            ),
          ],
        ),
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

    if (provider.transactions.isEmpty &&
        !provider.isLoading &&
        !provider.isFilterActive) {
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

    // Derive the display label: pending withdrawals show "Processing"
    final statusLabel = (transaction.status.toLowerCase() == 'pending' &&
            transaction.isWithdrawal)
        ? 'Processing'
        : transaction.status;

    return InkWell(
      onTap:
          transaction.status.toLowerCase() == 'pending'
              ? () => _showPendingTransactionDetails(context)
              : null,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        constraints: BoxConstraints(minHeight: 65.h),
        margin: EdgeInsets.only(bottom: 12.h),
        width: double.infinity,
        decoration: BoxDecoration(
          color: colors['container'],
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: colors['statusBorder']!, width: 0.5),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    transaction.description,
                    style: appFonts.textSmMedium.copyWith(
                      color: appColors.gray900,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                TransactionStatusBadge(
                  status: statusLabel,
                  backgroundColor: colors['statusBg']!,
                  textColor: colors['statusText']!,
                  borderColor: colors['statusBorder']!,
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  transaction.formattedDate,
                  style: appFonts.textXsRegular.copyWith(
                    color: appColors.gray500,
                  ),
                ),
                Text(
                  '${transaction.isDeposit ? "+" : "-"}${transaction.amount.formatAmountWithCurrency()}',
                  style: appFonts.textSmBold.copyWith(
                    color: colors['amount'],
                  ),
                ),
              ],
            ),
            if (transaction.status.toLowerCase() == 'pending' && transaction.isDeposit) ...[
              SizedBox(height: 8.h),
              const Divider(height: 1),
              SizedBox(height: 8.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Tap to complete payment',
                    style: appFonts.textXsMedium.copyWith(
                      color: appColors.blue600,
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 10.sp,
                    color: appColors.blue600,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showPendingTransactionDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => PendingTransactionSheet(transaction: transaction),
    );
  }
}

class PendingTransactionSheet extends StatelessWidget {
  final WalletTransaction transaction;

  const PendingTransactionSheet({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorExtension>()!;
    final appFonts = Theme.of(context).extension<AppFontThemeExtension>()!;

    final isBankTransfer =
        transaction.description.toLowerCase().contains('bank transfer') ||
        transaction.paymentMetadata != null;

    final metadata = transaction.paymentMetadata;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      padding: EdgeInsets.fromLTRB(24.w, 12.h, 24.w, 32.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: appColors.gray200,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ),
          SizedBox(height: 24.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                transaction.isDeposit
                    ? 'Complete Deposit'
                    : 'Withdrawal Processing',
                style: appFonts.textLgBold.copyWith(
                  color: appColors.gray900,
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(
                    color: appColors.gray100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.close, size: 20.sp),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Text(
            transaction.isDeposit
                ? 'You have a pending deposit of ${transaction.amount.abs().formatAmountWithCurrency()}. Please complete the payment below.'
                : 'Your withdrawal of ${transaction.amount.abs().formatAmountWithCurrency()} is being processed. Funds will be sent to the account below.',
            style: appFonts.textSmRegular.copyWith(
              color: appColors.gray600,
            ),
          ),
          SizedBox(height: 24.h),
          if (isBankTransfer && metadata != null) ...[
            _buildDetailRow(
              context,
              'Account Number',
              metadata['account_number']?.toString() ?? 'N/A',
              showCopy: true,
            ),
            SizedBox(height: 16.h),
            _buildDetailRow(
              context,
              'Bank Name',
              metadata['bank_name']?.toString() ?? 'N/A',
            ),
            SizedBox(height: 16.h),
            _buildDetailRow(
              context,
              'Account Name',
              metadata['account_name']?.toString() ?? 'N/A',
            ),
          ] else if (transaction.paymentUrl != null) ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _openPaymentUrl(transaction.paymentUrl!);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: appColors.blue600,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Continue to Paystack',
                  style: appFonts.textBaseBold.copyWith(color: Colors.white),
                ),
              ),
            ),
          ] else if (transaction.isWithdrawal) ...[
            // Withdrawal — show a success confirmation message
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: appColors.green50,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle_outline, color: appColors.green400),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      'Withdrawal sent successfully. Funds typically arrive within 1–3 business days depending on your bank.',
                      style: appFonts.textSmMedium.copyWith(
                        color: appColors.green600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: appColors.red50,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: appColors.red600),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      'Payment details are currently unavailable for this transaction.',
                      style: appFonts.textSmMedium.copyWith(
                        color: appColors.red600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value,
      {bool showCopy = false}) {
    final appColors = Theme.of(context).extension<AppColorExtension>()!;
    final appFonts = Theme.of(context).extension<AppFontThemeExtension>()!;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: appColors.gray50,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: appColors.gray100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: appFonts.textXsMedium.copyWith(color: appColors.gray500),
          ),
          SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  value,
                  style:
                      appFonts.textMdBold.copyWith(color: appColors.gray900),
                ),
              ),
              if (showCopy)
                GestureDetector(
                  onTap: () async {
                    await Clipboard.setData(ClipboardData(text: value));
                    if (context.mounted) {
                      ToastService.showSuccess('$label copied to clipboard');
                    }
                  },
                  child: Icon(Icons.copy, size: 20.sp, color: appColors.blue600),
                ),
            ],
          ),
        ],
      ),
    );
  }
  void _openPaymentUrl(String url) async {
    final uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('Error launching URL: $e');
    }
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
