import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ridenowappsss/core/utils/constants/api_constant.dart';
import 'package:ridenowappsss/core/utils/extensions/app_color_extension.dart';
import 'package:ridenowappsss/core/services/toast_service.dart';

extension AmountFormatter on String {
  /// Formats a string amount with commas as thousand separators
  String formatAmount() {
    final cleanAmount = replaceAll(RegExp(r'[^0-9.]'), '');
    if (cleanAmount.isEmpty) return '0';
    final parts = cleanAmount.split('.');
    
    // Format integer part
    final intPart = int.tryParse(parts[0]) ?? 0;
    final formattedInt = intPart.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );

    // Handle decimal part
    if (parts.length > 1) {
      final decimalPart = parts[1];
      // If decimal part is just zeros (e.g., .0 or .00), drop it
      if (int.tryParse(decimalPart) == 0) {
        return formattedInt;
      }
      // Otherwise keep up to 2 decimal places
      return '$formattedInt.${decimalPart.length > 2 ? decimalPart.substring(0, 2) : decimalPart}';
    }
    return formattedInt;
  }

  /// Formats a string amount with currency prefix and thousand separators
  String formatAmountWithCurrency({String currency = '₦'}) {
    return '$currency${formatAmount()}';
  }

  /// Converts a formatted amount string (e.g. \"₦484,500\") back to a numeric double
  double toNumber() {
    final cleanString = replaceAll(RegExp(r'[^0-9.]'), '');
    return double.tryParse(cleanString) ?? 0.0;
  }
}

/// Extension for formatting numeric amounts (double/int)
extension NumericAmountFormatter on num {
  /// Formats a numeric value with commas as thousand separators
  String formatAmount() {
    return toString().formatAmount();
  }

  /// Formats a numeric value with currency prefix and thousand separators
  String formatAmountWithCurrency({String currency = '₦'}) {
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

    ToastService.showInfo(successMessage ?? WithdrawalConstants.copySuccessMessage);
  }
}

class SnackBarHelper {
  static void showSuccess(BuildContext context, String message) {
    if (!context.mounted) return;

    final appColors = Theme.of(context).extension<AppColorExtension>()!;

    ToastService.showSuccess(message);
  }

  static void showError(BuildContext context, String message) {
    if (!context.mounted) return;

    final appColors = Theme.of(context).extension<AppColorExtension>()!;

    ToastService.showError(message);
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
