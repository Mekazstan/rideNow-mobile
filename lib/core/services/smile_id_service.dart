// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:smile_id/smile_id.dart';
import 'package:smile_id/generated/smileid_messages.g.dart';
import 'package:smile_id/products/biometric/smile_id_biometric_kyc.dart';

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

  /// Initialize Smile ID
  /// The SDK automatically loads assets/smile_config.json if it exists
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      // Load config from JSON file for the service's own use (e.g. useSandbox check)
      final configString = await rootBundle.loadString(
        'assets/smile_config.json',
      );
      _config = json.decode(configString);

      final useSandbox = _config!['smile_config']['environment'] == 'sandbox';
      final partnerId = _config!['smile_config']['partner_id'].toString();

      debugPrint('🔧 Initializing Smile ID Native SDK:');
      debugPrint('   Partner ID: $partnerId');
      debugPrint('   Environment: ${useSandbox ? "Sandbox" : "Production"}');

      // Initialize the SDK with explicit config to be safe
      SmileID.initializeWithConfig(
        config: FlutterConfig(
          partnerId: partnerId,
          authToken: _config!['smile_config']['api_key'] ?? '',
          prodBaseUrl:
              _config!['smile_config']['prod_base_url'] ??
              'https://api.smileidentity.com/v1',
          sandboxBaseUrl:
              _config!['smile_config']['sandbox_base_url'] ??
              'https://testapi.smileidentity.com/v1',
        ),
        useSandbox: useSandbox,
        enableCrashReporting: true,
      );

      // Small delay for native side to settle
      await Future.delayed(const Duration(milliseconds: 300));

      _initialized = true;
      debugPrint('✅ Smile ID SDK initialized successfully');
    } catch (e, stackTrace) {
      debugPrint('❌ Smile ID initialization error: $e');
      debugPrint('   Stack trace: $stackTrace');
      // Still set true to prevent hanging the app on subsequent calls
      _initialized = true;
    }
  }

  /// Check if using sandbox
  bool get useSandbox {
    if (!_initialized || _config == null) {
      return true;
    }
    return _config!['smile_config']['environment'] == 'sandbox';
  }

  /// Start Biometric KYC flow using the native SDK widget
  /// This corresponds to "Enhanced KYC" in the Smile ID ecosystem for mobile
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
    if (!_initialized) {
      await initialize();
    }

    // Check internet connectivity
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult.contains(ConnectivityResult.none)) {
      if (!context.mounted) return null;
      _showErrorDialog(
        context,
        'No Internet Connection',
        'Please check your internet connection and try again.',
      );
      return null;
    }

    // Request camera permission upfront
    final cameraStatus = await Permission.camera.request();
    if (!cameraStatus.isGranted) {
      if (!context.mounted) return null;
      _showErrorDialog(
        context,
        'Camera Permission Required',
        'Please grant camera permission to proceed with verification.',
      );
      return null;
    }

    final jobId = generateJobId();
    debugPrint('🚀 Starting Biometric KYC flow');
    debugPrint('   User ID: $userId');
    debugPrint('   Job ID: $jobId');

    try {
      // Use SmileIDBiometricKYC widget which handles the UI flow
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => SmileIDBiometricKYC(
                userId: userId,
                jobId: jobId,
                country: country,
                idType: idType,
                idNumber: idNumber,
                firstName: firstName,
                lastName: lastName,
                dob: dateOfBirth,
                consentGrantedDate: DateTime.now().toIso8601String(),
                personalDetailsConsentGranted: true,
                contactInformationConsentGranted: true,
                documentInformationConsentGranted: true,
                allowAgentMode: false,
                showAttribution: true,
                showInstructions: true,
                onSuccess: (String jsonResult) {
                  debugPrint('📋 Biometric KYC Success: $jsonResult');
                  Navigator.of(context).pop(jsonResult);
                },
                onError: (String error) {
                  debugPrint('❌ Biometric KYC Error: $error');
                  Navigator.of(context).pop({'error': error});
                },
              ),
        ),
      );

      if (result is String) {
        final decoded = json.decode(result);
        return SmileIDResult(
          success: true,
          message: 'Verification completed successfully',
          jobId: jobId,
          userId: userId,
          data: decoded,
        );
      } else if (result is Map && result.containsKey('error')) {
        return SmileIDResult(
          success: false,
          message: result['error'],
          jobId: jobId,
          userId: userId,
        );
      }

      return SmileIDResult(
        success: false,
        message: 'Verification was cancelled',
        jobId: jobId,
        userId: userId,
      );
    } catch (e, stackTrace) {
      debugPrint('❌ Biometric KYC Exception: $e');
      debugPrint('   Stack trace: $stackTrace');
      return SmileIDResult(
        success: false,
        message: 'Error during verification: $e',
        jobId: jobId,
        userId: userId,
      );
    }
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
