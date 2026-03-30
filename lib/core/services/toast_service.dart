// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ridenowappsss/core/navigation/app_router.dart';

class ToastService {
  // Success toast
  static void showSuccess(String message) {
    _showSnackBar(
      message: message,
      backgroundColor: const Color(0xFF10B981),
      icon: Icons.check_circle_rounded,
    );
  }

  // Error toast
  static void showError(String message) {
    _showSnackBar(
      message: message,
      backgroundColor: const Color(0xFFEF4444),
      icon: Icons.error_rounded,
    );
  }

  // Warning toast
  static void showWarning(String message) {
    _showSnackBar(
      message: message,
      backgroundColor: const Color(0xFFF59E0B),
      icon: Icons.warning_rounded,
    );
  }

  // Info toast
  static void showInfo(String message) {
    _showSnackBar(
      message: message,
      backgroundColor: const Color(0xFF3B82F6),
      icon: Icons.info_rounded,
    );
  }

  static void showNetworkError(String message, {VoidCallback? onRetry}) {
    _showSnackBar(
      message: message,
      backgroundColor: const Color(0xFFEF4444),
      icon: Icons.wifi_off_rounded,
      actionLabel: onRetry != null ? 'Retry' : null,
      onAction: onRetry,
    );
  }

  static void handleErrorByStatusCode(int statusCode, {String? message, VoidCallback? onRetry}) {
    final errorInfo = _getErrorInfoByStatusCode(statusCode, message);
    
    _showSnackBar(
      message: errorInfo['message'] ?? 'An error occurred',
      backgroundColor: _getColorByType(errorInfo['type'] ?? 'error'),
      icon: _getIconByType(errorInfo['type'] ?? 'error'),
      actionLabel: onRetry != null ? 'Retry' : null,
      onAction: onRetry,
    );
  }

  static Color _getColorByType(String type) {
    switch (type) {
      case 'auth': return const Color(0xFFEF4444);
      case 'server': return const Color(0xFFDC2626);
      case 'rate_limit': return const Color(0xFFF97316);
      case 'warning': return const Color(0xFFF59E0B);
      case 'network': return const Color(0xFFEF4444);
      default: return const Color(0xFFEF4444);
    }
  }

  static IconData _getIconByType(String type) {
    switch (type) {
      case 'auth': return Icons.lock_rounded;
      case 'server': return Icons.dns_rounded;
      case 'rate_limit': return Icons.schedule_rounded;
      case 'warning': return Icons.warning_rounded;
      case 'network': return Icons.wifi_off_rounded;
      default: return Icons.error_rounded;
    }
  }

  static Map<String, String> _getErrorInfoByStatusCode(int statusCode, String? customMessage) {
    switch (statusCode) {
      case 400: return {'type': 'error', 'message': customMessage ?? 'Invalid request. Please check your input.'};
      case 401: return {'type': 'auth', 'message': customMessage ?? 'Incorrect credentials. Please try again.'};
      case 403: return {'type': 'error', 'message': customMessage ?? 'Access denied.'};
      case 404: return {'type': 'error', 'message': customMessage ?? 'Resource not found.'};
      case 429: return {'type': 'rate_limit', 'message': customMessage ?? 'Too many attempts. Please wait.'};
      case 500: return {'type': 'server', 'message': customMessage ?? 'Server error. Please try again later.'};
      default: return {'type': 'error', 'message': customMessage ?? 'An unexpected error occurred.'};
    }
  }

  static void _showSnackBar({
    required String message,
    required Color backgroundColor,
    required IconData icon,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    final messengerState = AppRouter.scaffoldMessengerKey.currentState;
    if (messengerState == null) return;

    try {
      messengerState.hideCurrentSnackBar();
      
      messengerState.showSnackBar(
        SnackBar(
          content: Builder(
            builder: (context) {
              return Container(
                padding: EdgeInsets.symmetric(vertical: 8.h),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, color: Colors.white, size: 20.sp),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Text(
                        message,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          backgroundColor: backgroundColor,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(20.w),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
          elevation: 10,
          duration: const Duration(seconds: 4),
          action: actionLabel != null && onAction != null 
            ? SnackBarAction(
                label: actionLabel,
                textColor: Colors.white,
                onPressed: onAction,
              )
            : null,
        ),
      );
    } catch (e) {
      debugPrint('ToastService Error: $e');
    }
  }

  // Compatibility method for old code that might still call init
  static void init(BuildContext context) {}
  
  static void removeAllToasts() {
    AppRouter.scaffoldMessengerKey.currentState?.hideCurrentSnackBar();
  }
}
