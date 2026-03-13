import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:ridenowappsss/core/storage/local_storage.dart';

class TokenManagerService {
  Timer? _sessionTimer;
  Timer? _tokenCheckTimer;
  final SecureStorageService _storageService = SecureStorageService();

  Function()? onSessionExpired;

  void startSessionMonitoring({required Function() onExpired}) {
    onSessionExpired = onExpired;

    _tokenCheckTimer = Timer.periodic(
      Duration(minutes: 1),
      (_) => _checkSessionValidity(),
    );

    _setupSessionTimer();
 
    if (kDebugMode) {
      print('=== Token Manager Started ===');
    }
  }

  Future<void> _setupSessionTimer() async {
    try {
      final timeUntilExpiry = await _storageService.getTimeUntilSessionExpiry();

      if (timeUntilExpiry == null || timeUntilExpiry.inSeconds <= 0) {
        if (kDebugMode) {
          print('Session already expired');
        }
        onSessionExpired?.call();
        return;
      }
      _sessionTimer?.cancel();
      _sessionTimer = Timer(timeUntilExpiry, () {
        if (kDebugMode) {
          print('=== Session Expired (2 hours) ===');
        }
        onSessionExpired?.call();
      });

      if (kDebugMode) {
        print('Session will expire in: ${timeUntilExpiry.inMinutes} minutes');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error setting up session timer: $e');
      }
    }
  }

  /// Check if session is still valid
  Future<void> _checkSessionValidity() async {
    try {
      final isSessionExpired = await _storageService.isSessionExpired();
      final isTokenExpired = await _storageService.isTokenExpired();

      if (isSessionExpired || isTokenExpired) {
        if (kDebugMode) {
          print('=== Session/Token Invalid ===');
          print('Session expired: $isSessionExpired');
          print('Token expired: $isTokenExpired');
        }
        onSessionExpired?.call();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error checking session validity: $e');
      }
    }
  }

  /// Reset session timer
  Future<void> resetSessionTimer() async {
    if (kDebugMode) {
      print('=== Resetting Session Timer ===');
    }

    _sessionTimer?.cancel();
    _tokenCheckTimer?.cancel();

    await _setupSessionTimer();

    _tokenCheckTimer = Timer.periodic(
      Duration(minutes: 1),
      (_) => _checkSessionValidity(),
    );
  }

  /// Stop all timers
  void stopMonitoring() {
    if (kDebugMode) {
      print('=== Stopping Token Manager ===');
    }

    _sessionTimer?.cancel();
    _tokenCheckTimer?.cancel();
    _sessionTimer = null;
    _tokenCheckTimer = null;
  }

  /// Dispose and clean up
  void dispose() {
    stopMonitoring();
    onSessionExpired = null;
  }
}
