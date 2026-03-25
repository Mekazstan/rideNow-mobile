// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:smile_id/smile_id.dart';
import 'package:smile_id/products/selfie/smile_id_smart_selfie_enrollment.dart';
import 'package:smile_id/products/selfie/smile_id_smart_selfie_authentication.dart';

/// Result class for Smile ID operations
class SmileIDResult {
  final bool success;
  final String? message;
  final dynamic data;
  final String? jobId;
  final String? userId;

  SmileIDResult({
    required this.success,
    this.message,
    this.data,
    this.jobId,
    this.userId,
  });

  @override
  String toString() {
    return 'SmileIDResult(success: $success, message: $message, jobId: $jobId)';
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data,
      'jobId': jobId,
      'userId': userId,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }
}

class SmileIDService {
  static final SmileIDService _instance = SmileIDService._internal();
  factory SmileIDService() => _instance;
  SmileIDService._internal();

  bool _initialized = false;
  Map<String, dynamic>? _config;

  Future<void> initialize() async {
    if (_initialized) return;

    try {
      debugPrint('🔧 Initializing Smile ID Native SDK...');
      
      // Load config from JSON file for the service's own use (e.g. useSandbox check)
      final configString = await rootBundle.loadString(
        'assets/smile_config.json',
      );
      _config = json.decode(configString);


      SmileID.initialize(
        useSandbox: useSandbox,
        enableCrashReporting: true,
      );

      _initialized = true;
      debugPrint('✅ Smile ID SDK initialized successfully (Sandbox: $useSandbox)');
    } catch (e, stackTrace) {
      debugPrint('❌ Smile ID initialization error: $e');
      debugPrint('   Stack trace: $stackTrace');
      _initialized = true;
    }
  }

  /// Check if using sandbox
  bool get useSandbox {
    if (_config == null) {
      return true;
    }
    return _config!['environment'] == 'sandbox';
  }

  /// Start SmartSelfie Enrollment flow using the native SDK widget
  /// This corresponds to creating a biometric profile for future login
  Future<SmileIDResult?> startSmartSelfieEnrollment({
    required BuildContext context,
    required String userId,
    bool allowAgentMode = false,
    bool showInstructions = true,
  }) async {
    if (!_initialized) {
      await initialize();
    }

    final jobId = generateJobId();
    debugPrint('🚀 Starting SmartSelfie Enrollment flow');
    debugPrint('   User ID: $userId');
    debugPrint('   Job ID: $jobId');

    try {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => SmileIDSmartSelfieEnrollment(
                userId: userId,
                allowAgentMode: allowAgentMode,
                showInstructions: showInstructions,
                onSuccess: (resultJson) {
                  Navigator.pop(context, resultJson);
                },
                onError: (errorMessage) {
                  Navigator.pop(context, Exception(errorMessage));
                },
              ),
        ),
      );

      if (result is String) {
        debugPrint('📋 SmartSelfie Enrollment Success: $result');
        return SmileIDResult(
          success: true,
          message: 'Enrollment completed successfully',
          jobId: jobId,
          userId: userId,
          data: result,
        );
      } else if (result is Exception) {
        debugPrint('❌ SmartSelfie Enrollment Error: $result');
        return SmileIDResult(
          success: false,
          message: result.toString(),
          jobId: jobId,
          userId: userId,
        );
      }

      return SmileIDResult(
        success: false,
        message: 'Enrollment was cancelled',
        jobId: jobId,
        userId: userId,
      );
    } catch (e, stackTrace) {
      debugPrint('❌ SmartSelfie Enrollment Exception: $e');
      debugPrint('   Stack trace: $stackTrace');
      return SmileIDResult(
        success: false,
        message: 'Error during enrollment: $e',
        jobId: jobId,
        userId: userId,
      );
    }
  }

  @Deprecated('Use startSmartSelfieEnrollment instead')
  Future<SmileIDResult?> startEnhancedKycWithUI({
    required BuildContext context,
    required String userId,
    String? firstName,
    String? lastName,
    String? idType,
    String? idNumber,
    String? dateOfBirth,
    String country = 'NG',
  }) async {
    return await startSmartSelfieEnrollment(
      context: context,
      userId: userId,
    );
  }

  /// Quick verification
  Future<SmileIDResult?> startQuickVerification({
    required BuildContext context,
    required String userId,
    String? firstName,
    String? lastName,
  }) async {
    return await startEnhancedKycWithUI(
      context: context,
      userId: userId,
      firstName: firstName,
      lastName: lastName,
    );
  }

  /// Generate unique job ID
  String generateJobId() {
    return 'job_${DateTime.now().millisecondsSinceEpoch}';
  }

  /// Generate unique user ID
  String generateUserId() {
    return 'user_${DateTime.now().millisecondsSinceEpoch}';
  }

  Future<SmileIDResult?> startBiometricAuthentication({
    required BuildContext context,
    required String userId,
    bool allowAgentMode = false,
  }) async {
    if (!_initialized) {
      await initialize();
    }

    final jobId = generateJobId();
    debugPrint('🚀 Starting Biometric Authentication flow');
    debugPrint('   User ID: $userId');
    debugPrint('   Job ID: $jobId');

    try {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => SmileIDSmartSelfieAuthentication(
                userId: userId,
                allowAgentMode: allowAgentMode,
                onSuccess: (resultJson) {
                  Navigator.pop(context, resultJson);
                },
                onError: (errorMessage) {
                  Navigator.pop(context, Exception(errorMessage));
                },
              ),
        ),
      );

      if (result is String) {
        debugPrint('📋 Biometric Auth Success: $result');
        return SmileIDResult(
          success: true,
          message: 'Authentication completed successfully',
          jobId: jobId,
          userId: userId,
          data: result,
        );
      } else if (result is Exception) {
        debugPrint('❌ Biometric Auth Error: $result');
        return SmileIDResult(
          success: false,
          message: result.toString(),
          jobId: jobId,
          userId: userId,
        );
      }

      return SmileIDResult(
        success: false,
        message: 'Authentication was cancelled',
        jobId: jobId,
        userId: userId,
      );
    } catch (e, stackTrace) {
      debugPrint('❌ Biometric Auth Exception: $e');
      debugPrint('   Stack trace: $stackTrace');
      return SmileIDResult(
        success: false,
        message: 'Error during authentication: $e',
        jobId: jobId,
        userId: userId,
      );
    }
  }

  /// Check if service is initialized
  bool get isInitialized => _initialized;

  static void _showErrorDialog(
    BuildContext context,
    String title,
    String message,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }
}
