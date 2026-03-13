

import 'dart:convert';
import 'package:flutter/services.dart';

class SmileIDConfig {
  final String partnerId;
  final String authToken;
  final bool useSandbox;
  final String? callbackUrl;

  SmileIDConfig({
    required this.partnerId,
    required this.authToken,
    required this.useSandbox,
    this.callbackUrl,
  });

  factory SmileIDConfig.fromJson(Map<String, dynamic> json) {
    final config = json['smile_config'] as Map<String, dynamic>;
    return SmileIDConfig(
      partnerId: config['partner_id'] as String,
      authToken: config['api_key'] as String,
      useSandbox: config['environment'] == 'sandbox',
      callbackUrl: config['identity_verification_callback_url'] as String?,
    );
  }
}

class SmileIDConfigService {
  static SmileIDConfig? _config;

  /// Load Smile ID configuration from JSON file
  static Future<SmileIDConfig> loadConfig() async {
    if (_config != null) return _config!;

    try {
      final jsonString = await rootBundle.loadString(
        'assets/smile_config.json',
      );
      final jsonData = json.decode(jsonString) as Map<String, dynamic>;
      _config = SmileIDConfig.fromJson(jsonData);
      return _config!;
    } catch (e) {
      throw Exception('Failed to load Smile ID configuration: $e');
    }
  }

  /// Get loaded configuration
  static SmileIDConfig? get config => _config;

  /// Clear cached configuration
  static void clearConfig() {
    _config = null;
  }
}
