import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';

class DeviceInfoService {
  static Future<Map<String, String>> getDeviceInfo() async {
    final deviceInfo = DeviceInfoPlugin();

    try {
      if (kIsWeb) {
        final webInfo = await deviceInfo.webBrowserInfo;
        return {
          'platform': 'web',
          'version': webInfo.browserName.name,
          'device_id': 'web_${DateTime.now().millisecondsSinceEpoch}',
        };
      } else if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        return {
          'platform': 'android',
          'version': androidInfo.version.release,
          'device_id': androidInfo.id,
        };
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        return {
          'platform': 'ios',
          'version': iosInfo.systemVersion,
          'device_id': iosInfo.identifierForVendor ?? 'unknown_ios_device',
        };
      } else {
        return {
          'platform': 'unknown',
          'version': '1.0.0',
          'device_id': 'unknown_${DateTime.now().millisecondsSinceEpoch}',
        };
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error getting device info: $e');
      }
      return {
        'platform': 'unknown',
        'version': '1.0.0',
        'device_id': 'fallback_${DateTime.now().millisecondsSinceEpoch}',
      };
    }
  }
}
