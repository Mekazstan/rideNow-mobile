import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FirstTimeUserService {
  static const String _firstTimeUserKey = 'is_first_time_user';
  static Future<bool> isFirstTimeUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_firstTimeUserKey) ?? true;
    } catch (e) {
      return true;
    } 
  }

  static Future<void> markUserAsReturning() async {
    try { 
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_firstTimeUserKey, false);
    } catch (e) {
      if (kDebugMode) {
        print('Error marking user as returning: $e');
      } 
    }
  }

  static Future<void> resetFirstTimeUserFlag() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_firstTimeUserKey, true);
    } catch (e) {
      if (kDebugMode) {
        print('Error resetting first-time user flag: $e');
      }
    }
  }
}
