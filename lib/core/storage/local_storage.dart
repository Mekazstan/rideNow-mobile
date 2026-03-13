

// ignore_for_file: empty_catches

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

import 'package:ridenowappsss/modules/authentication/data/models/auth_models.dart';
import 'package:ridenowappsss/modules/authentication/data/models/emergency_contact_model.dart';

class SecureStorageService {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.unlocked),
  );

  // Storage keys
  static const String _tokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userKey = 'user_data';
  static const String _tokenExpiryKey = 'token_expiry';
  static const String _isLoggedInKey = 'is_logged_in';
  static const String _loginTimeKey = 'login_time';
  static const String _emergencyContactsKey = 'emergency_contacts';
  static const String _smileIdVerifiedKey = 'smile_id_verified';

  /// Save authentication data
  Future<void> saveAuthData({
    required String token,
    required String refreshToken,
    required User user,
    required int tokenExpiresIn,
  }) async {
    try {
      final expiryTime = DateTime.now().add(Duration(seconds: tokenExpiresIn));
      final loginTime = DateTime.now().toIso8601String();

      await Future.wait([
        _storage.write(key: _tokenKey, value: token),
        _storage.write(key: _refreshTokenKey, value: refreshToken),
        _storage.write(key: _userKey, value: jsonEncode(user.toJson())),
        _storage.write(
          key: _tokenExpiryKey,
          value: expiryTime.toIso8601String(),
        ),
        _storage.write(key: _isLoggedInKey, value: 'true'),
        _storage.write(key: _loginTimeKey, value: loginTime),
      ]);
    } catch (e) {
      throw Exception('Failed to save authentication data: $e');
    }
  }

  /// Get saved authentication token
  Future<String?> getAuthToken() async {
    try {
      return await _storage.read(key: _tokenKey);
    } catch (e) {
      return null;
    }
  }

  /// Get saved refresh token
  Future<String?> getRefreshToken() async {
    try {
      return await _storage.read(key: _refreshTokenKey);
    } catch (e) {
      return null;
    }
  }

  /// Get saved user data
  Future<User?> getUserData() async {
    try {
      final userJson = await _storage.read(key: _userKey);
      if (userJson != null) {
        return User.fromJson(jsonDecode(userJson));
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Get login time
  Future<DateTime?> getLoginTime() async {
    try {
      final loginTimeString = await _storage.read(key: _loginTimeKey);
      if (loginTimeString != null) {
        return DateTime.parse(loginTimeString);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Check if token is expired
  Future<bool> isTokenExpired() async {
    try {
      final expiryString = await _storage.read(key: _tokenExpiryKey);
      if (expiryString != null) {
        final expiryTime = DateTime.parse(expiryString);
        return DateTime.now().isAfter(expiryTime);
      }
      return true;
    } catch (e) {
      return true;
    }
  }

  /// Check if session is expired
  Future<bool> isSessionExpired() async {
    try {
      final loginTime = await getLoginTime();
      if (loginTime == null) return true;

      final sessionDuration = DateTime.now().difference(loginTime);
      return sessionDuration.inHours >= 2;
    } catch (e) {
      return true;
    }
  }

  /// Get time until session expires
  Future<Duration?> getTimeUntilSessionExpiry() async {
    try {
      final loginTime = await getLoginTime();
      if (loginTime == null) return null;

      final twoHoursLater = loginTime.add(Duration(hours: 2));
      final timeRemaining = twoHoursLater.difference(DateTime.now());

      return timeRemaining.isNegative ? Duration.zero : timeRemaining;
    } catch (e) {
      return null;
    }
  }

  /// Check if user is logged in
  Future<bool> isLoggedIn() async {
    try {
      final isLoggedIn = await _storage.read(key: _isLoggedInKey);
      final token = await getAuthToken();
      final isTokenExpired = await this.isTokenExpired();
      final isSessionExpired = await this.isSessionExpired();

      return isLoggedIn == 'true' &&
          token != null &&
          !isTokenExpired &&
          !isSessionExpired;
    } catch (e) {
      return false;
    }
  }

  /// Update authentication token
  Future<void> updateAuthToken({
    required String token,
    required String refreshToken,
    required int tokenExpiresIn,
  }) async {
    try {
      final expiryTime = DateTime.now().add(Duration(seconds: tokenExpiresIn));

      await Future.wait([
        _storage.write(key: _tokenKey, value: token),
        _storage.write(key: _refreshTokenKey, value: refreshToken),
        _storage.write(
          key: _tokenExpiryKey,
          value: expiryTime.toIso8601String(),
        ),
      ]);
    } catch (e) {
      throw Exception('Failed to update authentication token: $e');
    }
  }

  // ========== Emergency Contacts Methods ==========

  /// Save emergency contacts
  Future<void> saveEmergencyContacts(List<EmergencyContact> contacts) async {
    try {
      final contactsJson = contacts.map((c) => c.toJson()).toList();
      await _storage.write(
        key: _emergencyContactsKey,
        value: jsonEncode(contactsJson),
      );
    } catch (e) {
      throw Exception('Failed to save emergency contacts: $e');
    }
  }

  /// Get emergency contacts
  Future<List<EmergencyContact>> getEmergencyContacts() async {
    try {
      final contactsJson = await _storage.read(key: _emergencyContactsKey);
      if (contactsJson != null) {
        final List<dynamic> decoded = jsonDecode(contactsJson);
        return decoded.map((json) => EmergencyContact.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Add single emergency contact
  Future<void> addEmergencyContact(EmergencyContact contact) async {
    try {
      final contacts = await getEmergencyContacts();
      if (!contacts.any((c) => c.id == contact.id)) {
        contacts.add(contact);
        await saveEmergencyContacts(contacts);
      }
    } catch (e) {
      throw Exception('Failed to add emergency contact: $e');
    }
  }

  /// Remove emergency contact
  Future<void> removeEmergencyContact(String contactId) async {
    try {
      final contacts = await getEmergencyContacts();
      contacts.removeWhere((c) => c.id == contactId);
      await saveEmergencyContacts(contacts);
    } catch (e) {
      throw Exception('Failed to remove emergency contact: $e');
    }
  }

  /// Clear all emergency contacts
  Future<void> clearEmergencyContacts() async {
    try {
      await _storage.delete(key: _emergencyContactsKey);
    } catch (e) {}
  }

  // ========== Smile ID Verification Methods ==========

  /// Mark Smile ID verification as completed
  Future<void> setSmileIdVerified(bool verified) async {
    try {
      await _storage.write(
        key: _smileIdVerifiedKey,
        value: verified.toString(),
      );
    } catch (e) {
      throw Exception('Failed to save Smile ID verification status: $e');
    }
  }

  /// Check if Smile ID verification is completed
  Future<bool> isSmileIdVerified() async {
    try {
      final verified = await _storage.read(key: _smileIdVerifiedKey);
      return verified == 'true';
    } catch (e) {
      return false;
    }
  }

  /// Clear all authentication data
  Future<void> clearAuthData() async {
    try {
      await Future.wait([
        _storage.delete(key: _tokenKey),
        _storage.delete(key: _refreshTokenKey),
        _storage.delete(key: _userKey),
        _storage.delete(key: _tokenExpiryKey),
        _storage.delete(key: _isLoggedInKey),
        _storage.delete(key: _loginTimeKey),
      ]);
    } catch (e) {}
  }

  /// Clear all stored data
  Future<void> clearAll() async {
    try {
      await _storage.deleteAll();
    } catch (e) {}
  }
}
