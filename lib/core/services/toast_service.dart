// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ridenowappsss/core/navigation/app_router.dart';

class ToastService {
  static FToast? _fToast;

  // Initialize toast service
  static void init(BuildContext context) {
    _fToast = FToast();
    _fToast!.init(context);
  }

  // Success toast
  static void showSuccess(String message) {
    _showCustomToast(
      message: message,
      backgroundColor: const Color(0xFF10B981),
      icon: Icons.check_circle,
      iconColor: Colors.white,
      duration: const Duration(seconds: 4),
    );
  }

  // Error toast
  static void showError(String message) {
    _showCustomToast(
      message: message,
      backgroundColor: const Color(0xFFEF4444),
      icon: Icons.error,
      iconColor: Colors.white,
      duration: const Duration(seconds: 5),
    );
  }

  // Warning toast
  static void showWarning(String message) {
    _showCustomToast(
      message: message,
      backgroundColor: const Color(0xFFF59E0B),
      icon: Icons.warning,
      iconColor: Colors.white,
      duration: const Duration(seconds: 4),
    );
  }

  // Info toast
  static void showInfo(String message) {
    _showCustomToast(
      message: message,
      backgroundColor: const Color(0xFF3B82F6),
      icon: Icons.info,
      iconColor: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }

  // Network error toast
  static void showNetworkError(String message, {VoidCallback? onRetry}) {
    if (_fToast == null) return;

    Widget toast = Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: const BoxDecoration(
              color: Color(0xFFEF4444),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.wifi_off, color: Colors.white, size: 20.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: Colors.black,
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (onRetry != null) ...[
            SizedBox(width: 8.w),
            TextButton(
              onPressed: onRetry,
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                backgroundColor: const Color(0xFFEF4444),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6.r),
                ),
              ),
              child: Text(
                'Retry',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );

    _fToast!.showToast(
      child: toast,
      gravity: ToastGravity.TOP,
      toastDuration: const Duration(seconds: 6),
    );
  }

  // Authentication error toast (401)
  static void showAuthError(String message, {VoidCallback? onRetry}) {
    if (_fToast == null) return;

    Widget toast = Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: const BoxDecoration(
              color: Color(0xFFEF4444),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.lock, color: Colors.white, size: 20.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: Colors.black,
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (onRetry != null) ...[
            SizedBox(width: 8.w),
            TextButton(
              onPressed: onRetry,
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                backgroundColor: const Color(0xFFEF4444),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6.r),
                ),
              ),
              child: Text(
                'Try Again',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );

    _fToast!.showToast(
      child: toast,
      gravity: ToastGravity.TOP,
      toastDuration: const Duration(seconds: 5),
    );
  }

  // Server error toast (5xx)
  static void showServerError(String message, {VoidCallback? onRetry}) {
    if (_fToast == null) return;

    Widget toast = Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: const BoxDecoration(
              color: Color(0xFFDC2626),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.dns, color: Colors.white, size: 20.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: Colors.black,
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (onRetry != null) ...[
            SizedBox(width: 8.w),
            TextButton(
              onPressed: onRetry,
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                backgroundColor: const Color(0xFFDC2626),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6.r),
                ),
              ),
              child: Text(
                'Retry',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );

    _fToast!.showToast(
      child: toast,
      gravity: ToastGravity.TOP,
      toastDuration: const Duration(seconds: 6),
    );
  }

  // Rate limit error toast (429)
  static void showRateLimitError(String message) {
    _showCustomToast(
      message: message,
      backgroundColor: const Color(0xFFF97316),
      icon: Icons.schedule,
      iconColor: Colors.white,
      duration: const Duration(seconds: 8),
    );
  }

  // Handle errors based on status code
  static void handleErrorByStatusCode(
    int statusCode, {
    String? message,
    VoidCallback? onRetry,
  }) {
    final errorInfo = _getErrorInfoByStatusCode(statusCode, message);

    switch (errorInfo['type']) {
      case 'auth':
        showAuthError(errorInfo['message']!, onRetry: onRetry);
        break;
      case 'server':
        showServerError(errorInfo['message']!, onRetry: onRetry);
        break;
      case 'rate_limit':
        showRateLimitError(errorInfo['message']!);
        break;
      case 'warning':
        showWarning(errorInfo['message']!);
        break;
      case 'network':
        showNetworkError(errorInfo['message']!, onRetry: onRetry);
        break;
      default:
        showError(errorInfo['message']!);
        break;
    }
  }

  // Get error information based on status code
  static Map<String, String> _getErrorInfoByStatusCode(
    int statusCode,
    String? customMessage,
  ) {
    switch (statusCode) {
      case 400:
        return {
          'type': 'error',
          'message':
              customMessage ?? 'Invalid request. Please check your input.',
        };
      case 401:
        return {
          'type': 'auth',
          'message':
              customMessage ??
              'Password incorrect. Please double-check and try again.',
        };
      case 403:
        return {
          'type': 'error',
          'message': customMessage ?? 'Access denied. Please contact support.',
        };
      case 404:
        return {
          'type': 'error',
          'message': customMessage ?? 'Resource not found.',
        };
      case 408:
        return {
          'type': 'network',
          'message': customMessage ?? 'Request timeout. Please try again.',
        };
      case 422:
        return {
          'type': 'warning',
          'message': customMessage ?? 'Please check your input.',
        };
      case 429:
        return {
          'type': 'rate_limit',
          'message':
              customMessage ?? 'Too many attempts. Please wait a moment.',
        };
      case 500:
        return {
          'type': 'server',
          'message': customMessage ?? 'Server error. Please try again later.',
        };
      case 502:
      case 503:
      case 504:
        return {
          'type': 'server',
          'message':
              customMessage ??
              'Service temporarily unavailable. Please try again later.',
        };
      case 0:
        return {
          'type': 'network',
          'message':
              customMessage ??
              'Connection failed. Please check your internet connection.',
        };
      default:
        return {
          'type': 'error',
          'message': customMessage ?? 'An unexpected error occurred.',
        };
    }
  }

  static void _showCustomToast({
    required String message,
    required Color backgroundColor,
    required IconData icon,
    required Color iconColor,
    required Duration duration,
  }) {
    // Ensure FToast is initialized — screens must call ToastService.init(context) before async calls
    if (_fToast == null) return;

    Widget toast = Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      margin: EdgeInsets.symmetric(horizontal: 24.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        color: Colors.white.withOpacity(0.95),
        border: Border.all(
          color: backgroundColor.withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: backgroundColor.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: backgroundColor.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: backgroundColor,
              size: 20.sp,
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message,
                  style: TextStyle(
                    color: const Color(0xFF1F2937),
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    _fToast!.showToast(
      child: toast,
      gravity: ToastGravity.TOP,
      toastDuration: duration,
    );
  }

  // Remove all toasts
  static void removeAllToasts() {
    _fToast?.removeCustomToast();
  }
}
