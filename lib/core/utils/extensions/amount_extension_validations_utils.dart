import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ridenowappsss/core/utils/constants/api_constant.dart';
import 'package:ridenowappsss/core/utils/extensions/app_color_extension.dart';

extension AmountFormatter on String {
  /// Formats a string amount with commas as thousand separators
  String formatAmount() {
    final cleanAmount = replaceAll(RegExp(r'[^0-9.]'), '');
    if (cleanAmount.isEmpty) return '0';
    final parts = cleanAmount.split('.');
    final intPart = int.tryParse(parts[0]) ?? 0;
    final formatted = intPart.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
    if (parts.length > 1) {
      return '$formatted.${parts[1]}';
    }
    return formatted;
  }

  /// Formats a string amount with currency prefix and thousand separators
  String formatAmountWithCurrency({String currency = 'N'}) {
    return '$currency${formatAmount()}';
  }
}

/// Extension for formatting numeric amounts (double/int)
extension NumericAmountFormatter on num {
  /// Formats a numeric value with commas as thousand separators
  String formatAmount() {
    return toString().formatAmount();
  }

  /// Formats a numeric value with currency prefix and thousand separators
  String formatAmountWithCurrency({String currency = 'N'}) {
    return '$currency${formatAmount()}';
  }
}

/// Extension for formatting account numbers
extension AccountNumberFormatter on String {
  /// Formats account number with dashes (e.g., 123-45-6789)
  String formatAccountNumber() {
    if (length >= 10) {
      return '${substring(0, 3)}-${substring(3, 5)}-${substring(5)}';
    }
    return this;
  }
}

// ============================================================================
// VALIDATORS
// ============================================================================

class WithdrawalValidator {
  static String? validateAmount(String value, double balance) {
    if (value.isEmpty) return null;

    final cleanValue = value.replaceAll(',', '');
    final amount = double.tryParse(cleanValue);

    if (amount == null) {
      return 'Invalid amount';
    }

    if (amount <= 0) {
      return 'Amount must be greater than zero';
    }

    if (amount > balance) {
      return 'You don\'t have this amount in your wallet.';
    }

    return null;
  }

  static bool isValidAmount(String value, double balance) {
    return validateAmount(value, balance) == null && value.isNotEmpty;
  }
}

// ============================================================================
// UTILITIES
// ============================================================================

class ClipboardHelper {
  static Future<void> copyToClipboard(
    BuildContext context,
    String text, {
    String? successMessage,
  }) async {
    await Clipboard.setData(ClipboardData(text: text));

    if (!context.mounted) return;

    final appColors = Theme.of(context).extension<AppColorExtension>()!;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(successMessage ?? WithdrawalConstants.copySuccessMessage),
        duration: WithdrawalConstants.snackBarDuration,
        backgroundColor: appColors.blue600,
      ),
    );
  }
}

class SnackBarHelper {
  static void showSuccess(BuildContext context, String message) {
    if (!context.mounted) return;

    final appColors = Theme.of(context).extension<AppColorExtension>()!;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: appColors.green400,
        duration: WithdrawalConstants.snackBarDuration,
      ),
    );
  }

  static void showError(BuildContext context, String message) {
    if (!context.mounted) return;

    final appColors = Theme.of(context).extension<AppColorExtension>()!;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: appColors.red400,
        duration: WithdrawalConstants.snackBarDuration,
      ),
    );
  }
}

class ErrorMessageParser {
  static String parseWithdrawalError(dynamic error) {
    final errorStr = error.toString().toLowerCase();

    if (errorStr.contains('invalid') || errorStr.contains('incorrect')) {
      return 'Invalid withdrawal PIN';
    }

    if (errorStr.contains('insufficient')) {
      return 'Insufficient balance';
    }

    return 'Failed to process withdrawal';
  }

  static String parsePINCreationError(dynamic error) {
    return 'Failed to create PIN: ${error.toString()}';
  }
}

// ============================================================================
// INPUT FORMATTERS
// ============================================================================

class CommaInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    final formatted = newValue.text.formatAmount();

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
