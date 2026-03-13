import 'package:flutter/material.dart';
import 'package:ridenowappsss/core/services/toast_service.dart';
import 'package:ridenowappsss/modules/authentication/data/models/auth_models.dart';

class ErrorService {
  static void handleAuthError(Exception error, {VoidCallback? onRetry}) {
    if (_isNetworkError(error)) {
      ToastService.showNetworkError(
        _getErrorMessage(error) ?? 'Connection failed',
        onRetry: onRetry,
      );
      return;
    }

    // Handle based on status code
    final statusCode = _getStatusCode(error);
    if (statusCode != null) {
      ToastService.handleErrorByStatusCode(
        statusCode,
        message: _getErrorMessage(error),
        onRetry: onRetry,
      );
    } else {
      ToastService.showError(
        _getErrorMessage(error) ?? 'Login failed. Please try again.',
      );
    }
  }

  // Handle general errors with status code mapping
  static void handleError(Exception error, {VoidCallback? onRetry}) {
    if (_isNetworkError(error)) {
      ToastService.showNetworkError(
        _getErrorMessage(error) ?? 'Connection failed',
        onRetry: onRetry,
      );
      return;
    }

    // Handle based on status code
    final statusCode = _getStatusCode(error);
    if (statusCode != null) {
      ToastService.handleErrorByStatusCode(
        statusCode,
        message: _getErrorMessage(error),
        onRetry: onRetry,
      );
    } else if (error is ValidationException) {
      ToastService.showWarning(
        _getErrorMessage(error) ?? 'Please check your input.',
      );
    } else {
      ToastService.showError(
        _getErrorMessage(error) ?? 'Something went wrong. Please try again.',
      );
    }
  }

  // Show success messages
  static void showSuccess(String message) {
    ToastService.showSuccess(message);
  }

  // Handle specific status codes directly
  static void handleStatusCode(
    int statusCode, {
    String? message,
    VoidCallback? onRetry,
  }) {
    ToastService.handleErrorByStatusCode(
      statusCode,
      message: message,
      onRetry: onRetry,
    );
  }

  // Check if error is network-related
  static bool _isNetworkError(Exception error) {
    if (error is NetworkException) return true;

    final message = _getErrorMessage(error)?.toLowerCase() ?? '';
    return message.contains('network') ||
        message.contains('connection') ||
        message.contains('timeout') ||
        message.contains('socket') ||
        _getStatusCode(error) == 0;
  }

  // Get status code from exception
  static int? _getStatusCode(Exception error) {
    if (error is ApiException) {
      return error.statusCode;
    }
    if (error is NetworkException) {
      return 0;
    }
    return null;
  }

  // Get error message from exception
  static String? _getErrorMessage(Exception error) {
    if (error is ApiException) {
      return error.message;
    }
    if (error is NetworkException) {
      return error.message;
    }
    if (error is ValidationException) {
      return error.errors.values.join(', ');
    }
    return error.toString();
  }
}
