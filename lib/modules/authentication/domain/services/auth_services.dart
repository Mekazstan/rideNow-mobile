import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:http_parser/http_parser.dart';
import 'package:ridenowappsss/core/services/device_info_service.dart';
import 'package:ridenowappsss/core/services/network_services.dart';
import 'package:ridenowappsss/core/storage/local_storage.dart';
import 'package:ridenowappsss/core/utils/constants/api_constant.dart';
import 'package:ridenowappsss/modules/authentication/data/models/auth_models.dart';

class AuthService {
  final DioClient _dioClient = DioClient();
  final SecureStorageService _secureStorage = SecureStorageService();

  // ============================================================
  // API ENDPOINTS
  // ============================================================

  static const String _loginEndpoint = '/auth/signin';
  static const String _signUpEndpoint = '/auth/signup';
  static const String _socialSignUpEndpoint = '/auth/signup/social';
  static const String _socialSignInEndpoint = '/auth/signin/social';
  static const String _logoutEndpoint = '/auth/logout';
  static const String _refreshTokenEndpoint = '/auth/refresh';
  static const String _sendVerificationEndpoint = '/auth/send-verification';
  static const String _verifyEmailEndpoint = '/auth/verify-email';

  // ============================================================
  // USER PROFILE
  // ============================================================

  Future<User> getProfile() async {
    try {
      if (kDebugMode) {
        print('=== Get User Profile ===');
        print('Endpoint: ${ApiConstants.profileEndpoint}');
      }

      final response = await _dioClient.get(ApiConstants.profileEndpoint);

      if (kDebugMode) {
        print('Profile Response: ${response.data}');
      }

      final responseData = response.data;

      if (responseData == null) {
        throw ApiException(message: 'Empty response from server');
      }

      final userData = responseData['data'];

      if (userData == null) {
        throw ApiException(message: 'No user data in response');
      }

      return User.fromJson(userData);
    } catch (e) {
      if (kDebugMode) {
        print('Get Profile Error: $e');
      }
      rethrow;
    }
  }

  // ============================================================
  // PROFILE PHOTO UPLOAD
  // ============================================================

  Future<ProfilePhotoUploadResponse> uploadProfilePhoto(File photoFile) async {
    try {
      if (kDebugMode) {
        print('=== Upload Profile Photo ===');
        print('Endpoint: ${ApiConstants.uploadProfilePhotoEndpoint}');
      }

      final fileSize = await photoFile.length();
      if (fileSize > 5 * 1024 * 1024) {
        throw ValidationException({'file': 'File size exceeds 5MB limit'});
      }

      final fileName = photoFile.path.split('/').last.toLowerCase();
      final validExtensions = ['jpg', 'jpeg', 'png'];
      final extension = fileName.split('.').last;

      if (!validExtensions.contains(extension)) {
        throw ValidationException({
          'file': 'Only JPG, JPEG, and PNG files are allowed',
        });
      }

      MediaType mediaType;
      if (extension == 'png') {
        mediaType = MediaType('image', 'png');
      } else {
        mediaType = MediaType('image', 'jpeg');
      }

      final multipartFile = await MultipartFile.fromFile(
        photoFile.path,
        filename: fileName,
        contentType: mediaType,
      );

      final formData = FormData.fromMap({'file': multipartFile});

      final response = await _dioClient.post(
        ApiConstants.uploadProfilePhotoEndpoint,
        data: formData,
        options: Options(headers: {'Content-Type': 'multipart/form-data'}),
      );

      return ProfilePhotoUploadResponse.fromJson(response.data);
    } catch (e) {
      if (kDebugMode) {
        print('Upload Profile Photo Error: $e');
      }
      rethrow;
    }
  }

  // ============================================================
  // DELETE ACCOUNT
  // ============================================================

  Future<void> deleteAccount() async {
    try {
      if (kDebugMode) {
        print('=== Delete Account ===');
        print('Endpoint: ${ApiConstants.profileEndpoint}');
      }

      final response = await _dioClient.delete(ApiConstants.profileEndpoint);

      if (kDebugMode) {
        print('Delete Account Response: ${response.data}');
      }

      // Clear all stored data after successful deletion
      await _secureStorage.clearAll();

      if (kDebugMode) {
        print('All local data cleared after account deletion');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Delete Account Error: $e');
      }
      rethrow;
    }
  }

  // ============================================================
  // EMAIL AUTHENTICATION
  // ============================================================

  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      final deviceInfoMap = await DeviceInfoService.getDeviceInfo();
      final deviceInfo = DeviceInfo(
        platform: deviceInfoMap['platform']!,
        version: deviceInfoMap['version']!,
        deviceId: deviceInfoMap['device_id']!,
      );

      final loginRequest = LoginRequest(
        email: email.trim(),
        password: password,
        deviceInfo: deviceInfo,
      );

      final response = await _dioClient.post(
        _loginEndpoint,
        data: loginRequest.toJson(),
      );

      final authResponse = AuthResponse.fromJson(response.data);
      _dioClient.setAuthToken(authResponse.token);

      return authResponse;
    } catch (e) {
      rethrow;
    }
  }

  Future<AuthResponse> signUp({
    required String userType,
    required String firstName,
    required String lastName,
    required String phone,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    try {
      final requestData = {
        'user_type': userType,
        'firstName': firstName.trim(),
        'lastName': lastName.trim(),
        'phone': phone.trim(),
        'email': email.trim(),
        'password': password,
        'confirm_password': confirmPassword,
      };

      if (kDebugMode) {
        print('SignUp Request Data: $requestData');
      }

      final response = await _dioClient.post(
        _signUpEndpoint,
        data: requestData,
      );

      final authResponse = AuthResponse.fromJson(response.data);
      _dioClient.setAuthToken(authResponse.token);

      return authResponse;
    } catch (e) {
      if (kDebugMode) {
        print('SignUp API Error: $e');
      }
      rethrow;
    }
  }

  // ============================================================
  // SOCIAL AUTHENTICATION
  // ============================================================

  Future<AuthResponse> socialSignUp({
    required String provider,
    required String userType,
    required String accessToken,
  }) async {
    try {
      if (kDebugMode) {
        print('=== Social Sign Up ===');
        print('Provider: $provider');
        print('User Type: $userType');
      }

      final deviceInfoMap = await DeviceInfoService.getDeviceInfo();
      final deviceInfo = DeviceInfo(
        platform: deviceInfoMap['platform']!,
        version: deviceInfoMap['version']!,
        deviceId: deviceInfoMap['device_id']!,
      );

      final socialAuthRequest = SocialAuthRequest(
        provider: provider,
        userType: userType,
        accessToken: accessToken,
        deviceInfo: deviceInfo,
      );

      final response = await _dioClient.post(
        _socialSignUpEndpoint,
        data: socialAuthRequest.toJson(),
      );

      if (kDebugMode) {
        print('Social Sign Up Response: ${response.data}');
      }

      final authResponse = AuthResponse.fromJson(response.data);
      _dioClient.setAuthToken(authResponse.token);

      return authResponse;
    } catch (e) {
      if (kDebugMode) {
        print('Social Sign Up Error: $e');
      }
      rethrow;
    }
  }

  Future<AuthResponse> socialSignIn({
    required String provider,
    required String accessToken,
  }) async {
    try {
      if (kDebugMode) {
        print('=== Social Sign In ===');
        print('Provider: $provider');
      }

      final deviceInfoMap = await DeviceInfoService.getDeviceInfo();
      final deviceInfo = DeviceInfo(
        platform: deviceInfoMap['platform']!,
        version: deviceInfoMap['version']!,
        deviceId: deviceInfoMap['device_id']!,
      );

      final socialAuthRequest = SocialAuthRequest(
        provider: provider,
        accessToken: accessToken,
        deviceInfo: deviceInfo,
      );

      final response = await _dioClient.post(
        _socialSignInEndpoint,
        data: socialAuthRequest.toJson(),
      );

      if (kDebugMode) {
        print('Social Sign In Response: ${response.data}');
      }

      final authResponse = AuthResponse.fromJson(response.data);
      _dioClient.setAuthToken(authResponse.token);

      return authResponse;
    } catch (e) {
      if (kDebugMode) {
        print('Social Sign In Error: $e');
      }
      rethrow;
    }
  }

  // ============================================================
  // EMAIL VERIFICATION
  // ============================================================

  Future<SendVerificationResponse> sendVerification({
    required String email,
  }) async {
    try {
      final sendVerificationRequest = SendVerificationRequest(
        email: email.trim(),
      );

      final response = await _dioClient.post(
        _sendVerificationEndpoint,
        data: sendVerificationRequest.toJson(),
      );

      return SendVerificationResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<EmailVerificationResponse> verifyEmail({
    required String email,
    required String verificationCode,
  }) async {
    try {
      final emailVerificationRequest = EmailVerificationRequest(
        email: email.trim(),
        verificationCode: verificationCode.trim(),
      );

      final response = await _dioClient.post(
        _verifyEmailEndpoint,
        data: emailVerificationRequest.toJson(),
      );

      final verificationResponse = EmailVerificationResponse.fromJson(
        response.data,
      );

      _dioClient.setAuthToken(verificationResponse.token);

      return verificationResponse;
    } catch (e) {
      rethrow;
    }
  }

  // ============================================================
  // SESSION MANAGEMENT
  // ============================================================

  Future<void> logout() async {
    try {
      await _dioClient.post(_logoutEndpoint);
    } finally {
      _dioClient.clearAuthToken();
    }
  }

  Future<AuthResponse> refreshToken({required String refreshToken}) async {
    try {
      final response = await _dioClient.post(
        _refreshTokenEndpoint,
        data: {'refresh_token': refreshToken},
      );

      final authResponse = AuthResponse.fromJson(response.data);
      _dioClient.setAuthToken(authResponse.token);

      return authResponse;
    } catch (e) {
      rethrow;
    }
  }

  // ============================================================
  // TOKEN MANAGEMENT
  // ============================================================

  void setAuthToken(String token) {
    _dioClient.setAuthToken(token);
  }

  void clearAuthToken() {
    _dioClient.clearAuthToken();
  }
}
