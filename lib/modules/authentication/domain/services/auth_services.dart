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
  static const String _switchRoleEndpoint = '/auth/switch-role';
  static const String _startDriverOnboardingEndpoint = '/auth/start-driver-onboarding';

  // ============================================================
  // ROLE MANAGEMENT
  // ============================================================

  Future<AuthResponse> switchRole(String targetRole) async {
    try {
      if (kDebugMode) {
        print('=== Switch Role ===');
        print('Target Role: $targetRole');
      }

      final response = await _dioClient.patch(
        _switchRoleEndpoint,
        data: {'target_role': targetRole},
      );

      return AuthResponse.fromJson(response.data);
    } catch (e) {
      if (kDebugMode) {
        print('Switch Role Error: $e');
      }
      rethrow;
    }
  }

  Future<Map<String, dynamic>> startDriverOnboarding() async {
    try {
      if (kDebugMode) {
        print('=== Start Driver Onboarding ===');
      }

      final response = await _dioClient.post(_startDriverOnboardingEndpoint);
      return response.data as Map<String, dynamic>;
    } catch (e) {
      if (kDebugMode) {
        print('Start Driver Onboarding Error: $e');
      }
      rethrow;
    }
  }

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

  Future<User> updateProfile({
    String? firstName,
    String? lastName,
    String? phone,
    String? dateOfBirth,
  }) async {
    try {
      if (kDebugMode) {
        print('=== Update User Profile ===');
        print('Endpoint: ${ApiConstants.profileEndpoint}');
      }

      final Map<String, dynamic> data = {};
      if (firstName != null && firstName.isNotEmpty) data['firstName'] = firstName;
      if (lastName != null && lastName.isNotEmpty) data['lastName'] = lastName;
      if (phone != null && phone.isNotEmpty) data['phone'] = phone;
      if (dateOfBirth != null && dateOfBirth.isNotEmpty) data['dateOfBirth'] = dateOfBirth;

      final response = await _dioClient.patch(
        ApiConstants.profileEndpoint,
        data: data,
      );

      if (kDebugMode) {
        print('Update Profile Response: ${response.data}');
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
        print('Update Profile Error: $e');
      }
      rethrow;
    }
  }

  Future<Map<String, dynamic>> submitBioData({
    required String fullName,
    required String dateOfBirth,
    String? phone,
  }) async {
    try {
      if (kDebugMode) {
        print('=== Submit Bio Data ===');
        print('Endpoint: ${ApiConstants.submitBioDataEndpoint}');
      }

      final Map<String, dynamic> data = {
        'full_name': fullName,
        'date_of_birth': dateOfBirth,
      };
      if (phone != null && phone.isNotEmpty) data['phone_number'] = phone;

      final response = await _dioClient.post(
        ApiConstants.submitBioDataEndpoint,
        data: data,
      );

      return response.data as Map<String, dynamic>;
    } catch (e) {
      if (kDebugMode) {
        print('Submit Bio Data Error: $e');
      }
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> fetchOnboardingStatus([String? role]) async {
    try {
      final response = await _dioClient.get(
        '/onboardings/status',
        queryParameters: role != null ? {'role': role} : null,
      );
      return response.data as Map<String, dynamic>?;
    } catch (e) {
      if (kDebugMode) print('fetchOnboardingStatus error: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>> submitVehicleSetup({
    required String licensePlate,
    required String vehicleType,
    String? make,
    String? model,
    int? year,
    String? color,
    List<File>? carImageFiles,
    File? identificationFile,
    String? identificationType,
    String? identificationNumber,
  }) async {
    try {
      final Map<String, dynamic> data = {
        'license_plate': licensePlate,
        'vehicle_type': vehicleType,
        if (make != null) 'make': make,
        if (model != null) 'model': model,
        if (year != null) 'year': year,
        if (color != null) 'color': color,
        if (identificationType != null) 'identification_type': identificationType,
        if (identificationNumber != null) 'identification_number': identificationNumber,
      };

      final formData = FormData.fromMap(data);

      if (carImageFiles != null && carImageFiles.isNotEmpty) {
        for (var file in carImageFiles) {
          formData.files.add(
            MapEntry(
              'car_image_files',
              await MultipartFile.fromFile(file.path),
            ),
          );
        }
      }

      if (identificationFile != null) {
        formData.files.add(
          MapEntry(
            'identification_file',
            await MultipartFile.fromFile(identificationFile.path),
          ),
        );
      }

      final response = await _dioClient.post(
        ApiConstants.driversVehicleSetupEndpoint,
        data: formData,
        options: Options(headers: {'Content-Type': 'multipart/form-data'}),
      );
      
      return response.data;
    } catch (e) {
      if (kDebugMode) {
        print('Submit Vehicle Setup Error: $e');
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

  Future<Map<String, dynamic>> batchUploadDriverDocuments({
    required List<Map<String, dynamic>> documents,
  }) async {
    try {
      final response = await _dioClient.post(
        ApiConstants.driversDocumentsBatchEndpoint,
        data: {'documents': documents},
      );
      return response.data;
    } catch (e) {
      if (kDebugMode) {
        print('Batch Upload Driver Documents Error: $e');
      }
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getDriverVerificationStatus() async {
    try {
      final response = await _dioClient.get(
        ApiConstants.getDriverVerificationStatusEndpoint,
      );
      if (response.data != null && response.data['data'] != null) {
        return response.data['data'];
      }
      return response.data ?? {};
    } catch (e) {
      if (kDebugMode) {
        print('Get Driver Verification Status Error: $e');
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
      if (authResponse.token != null) {
        _dioClient.setAuthToken(authResponse.token!);
      }

      return authResponse;
    } catch (e) {
      rethrow;
    }
  }

  Future<AuthResponse> signUp({
    required String userType,
    String? firstName,
    String? lastName,
    String? phone,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    try {
      final requestData = <String, dynamic>{
        'user_type': userType,
        if (firstName?.trim().isNotEmpty == true) 'firstName': firstName!.trim(),
        if (lastName?.trim().isNotEmpty == true) 'lastName': lastName!.trim(),
        if (phone?.trim().isNotEmpty == true) 'phone': phone!.trim(),
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
      if (authResponse.token != null) {
        _dioClient.setAuthToken(authResponse.token!);
      }

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
      if (authResponse.token != null) {
        _dioClient.setAuthToken(authResponse.token!);
      }

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
      if (authResponse.token != null) {
        _dioClient.setAuthToken(authResponse.token!);
      }

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
      if (authResponse.token != null) {
        _dioClient.setAuthToken(authResponse.token!);
      }

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

  // ============================================================
  // ONBOARDING PROGRESSION
  // ============================================================

  Future<bool> handlePermissionsAndContacts({
    required Map<String, bool> permissions,
    required List<Map<String, dynamic>> emergencyContacts,
  }) async {
    try {
      if (kDebugMode) {
        print('=== Handle Permissions and Contacts ===');
        print('Permissions: $permissions');
        print('Contacts Count: ${emergencyContacts.length}');
      }

      await _dioClient.post(
        ApiConstants.permissionsContactsEndpoint,
        data: {
          'permissions': permissions,
          'emergency_contacts': emergencyContacts,
        },
      );
      return true;
    } catch (e) {
      if (kDebugMode) print('Handle Permissions and Contacts Error: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> completeIdentityVerification({
    required Map<String, dynamic> smileSessionData,
  }) async {
    try {
      if (kDebugMode) {
        print('=== Complete Identity Verification ===');
        print('Smile Session Data: $smileSessionData');
      }

      final response = await _dioClient.post(
        ApiConstants.identityVerificationEndpoint,
        data: {
          'smile_session_data': smileSessionData,
        },
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      if (kDebugMode) print('Complete Identity Verification Error: $e');
      rethrow;
    }
  }
}
