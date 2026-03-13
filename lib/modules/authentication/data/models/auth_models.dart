import 'package:json_annotation/json_annotation.dart';

part 'auth_models.g.dart';

// ============================================================
// DEVICE INFO
// ============================================================

@JsonSerializable()
class DeviceInfo {
  final String platform;
  final String version;
  @JsonKey(name: 'device_id')
  final String deviceId;

  DeviceInfo({
    required this.platform,
    required this.version,
    required this.deviceId,
  });

  factory DeviceInfo.fromJson(Map<String, dynamic> json) =>
      _$DeviceInfoFromJson(json);
  Map<String, dynamic> toJson() => _$DeviceInfoToJson(this);
}

// ============================================================
// AUTHENTICATION REQUESTS
// ============================================================

@JsonSerializable()
class LoginRequest {
  final String email;
  final String password;
  @JsonKey(name: 'device_info')
  final DeviceInfo deviceInfo;

  LoginRequest({
    required this.email,
    required this.password,
    required this.deviceInfo,
  });

  factory LoginRequest.fromJson(Map<String, dynamic> json) =>
      _$LoginRequestFromJson(json);
  Map<String, dynamic> toJson() => _$LoginRequestToJson(this);
}

@JsonSerializable()
class SignUpRequest {
  @JsonKey(name: 'user_type')
  final String userType;
  final String firstName;
  final String lastName;
  final String phone;
  final String email;
  final String password;
  @JsonKey(name: 'confirm_password')
  final String confirmPassword;

  SignUpRequest({
    required this.userType,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.email,
    required this.password,
    required this.confirmPassword,
  });

  factory SignUpRequest.fromJson(Map<String, dynamic> json) =>
      _$SignUpRequestFromJson(json);
  Map<String, dynamic> toJson() => _$SignUpRequestToJson(this);
}

@JsonSerializable()
class SocialAuthRequest {
  final String provider;
  @JsonKey(name: 'user_type', includeIfNull: false)
  final String? userType;
  @JsonKey(name: 'access_token')
  final String accessToken;
  @JsonKey(name: 'device_info')
  final DeviceInfo deviceInfo;

  SocialAuthRequest({
    required this.provider,
    this.userType,
    required this.accessToken,
    required this.deviceInfo,
  });

  factory SocialAuthRequest.fromJson(Map<String, dynamic> json) =>
      _$SocialAuthRequestFromJson(json);
  Map<String, dynamic> toJson() => _$SocialAuthRequestToJson(this);
}

// ============================================================
// VERIFICATION REQUESTS & RESPONSES
// ============================================================

@JsonSerializable()
class SendVerificationRequest {
  final String email;

  SendVerificationRequest({required this.email});

  factory SendVerificationRequest.fromJson(Map<String, dynamic> json) =>
      _$SendVerificationRequestFromJson(json);
  Map<String, dynamic> toJson() => _$SendVerificationRequestToJson(this);
}

@JsonSerializable()
class SendVerificationResponse {
  final bool success;
  final String message;
  @JsonKey(name: 'expires_in')
  final int expiresIn;

  SendVerificationResponse({
    required this.success,
    required this.message,
    required this.expiresIn,
  });

  factory SendVerificationResponse.fromJson(Map<String, dynamic> json) =>
      _$SendVerificationResponseFromJson(json);
  Map<String, dynamic> toJson() => _$SendVerificationResponseToJson(this);
}

@JsonSerializable()
class EmailVerificationRequest {
  final String email;
  @JsonKey(name: 'verification_code')
  final String verificationCode;

  EmailVerificationRequest({
    required this.email,
    required this.verificationCode,
  });

  factory EmailVerificationRequest.fromJson(Map<String, dynamic> json) =>
      _$EmailVerificationRequestFromJson(json);
  Map<String, dynamic> toJson() => _$EmailVerificationRequestToJson(this);
}

@JsonSerializable()
class EmailVerificationResponse {
  final bool success;
  final String message;
  final User user;
  final String token;
  @JsonKey(name: 'refresh_token')
  final String refreshToken;
  @JsonKey(name: 'next_step')
  final String nextStep;
  @JsonKey(name: 'is_new_user')
  final bool isNewUser;
  @JsonKey(name: 'token_expires_in')
  final int tokenExpiresIn;

  EmailVerificationResponse({
    required this.success,
    required this.message,
    required this.user,
    required this.token,
    required this.refreshToken,
    required this.nextStep,
    required this.isNewUser,
    required this.tokenExpiresIn,
  });

  factory EmailVerificationResponse.fromJson(Map<String, dynamic> json) =>
      _$EmailVerificationResponseFromJson(json);
  Map<String, dynamic> toJson() => _$EmailVerificationResponseToJson(this);
}

// ============================================================
// USER MODEL - FIXED
// ============================================================

@JsonSerializable()
class User {
  final String id;
  final String userType;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String? dateOfBirth;
  final String? profilePhoto;
  final bool emailVerified;
  final bool phoneVerified;
  final String status;
  final String verificationStatus;
  final String createdAt;
  final String updatedAt;
  final double? rating;
  final int totalRides;

  User({
    required this.id,
    required this.userType,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    this.dateOfBirth,
    this.profilePhoto,
    required this.emailVerified,
    required this.phoneVerified,
    required this.status,
    required this.verificationStatus,
    required this.createdAt,
    required this.updatedAt,
    this.rating,
    required this.totalRides,
  });

  // Factory constructor to match your API response exactly
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      userType: json['userType'] ?? '',
      firstName: json['firstName'] ?? 'User',
      lastName: json['lastName'] ?? 'User',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      dateOfBirth: json['dateOfBirth'],
      profilePhoto: json['profilePhoto'], // Direct mapping
      emailVerified: json['emailVerified'] ?? false,
      phoneVerified: json['phoneVerified'] ?? false,
      status: json['status'] ?? 'active',
      verificationStatus: json['verificationStatus'] ?? '',
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
      rating:
          json['rating'] != null ? (json['rating'] as num).toDouble() : null,
      totalRides: json['totalRides'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userType': userType,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phone': phone,
      'dateOfBirth': dateOfBirth,
      'profilePhoto': profilePhoto,
      'emailVerified': emailVerified,
      'phoneVerified': phoneVerified,
      'status': status,
      'verificationStatus': verificationStatus,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'rating': rating,
      'totalRides': totalRides,
    };
  }

  // CopyWith method for updating user data
  User copyWith({
    String? id,
    String? userType,
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? dateOfBirth,
    String? profilePhoto,
    bool? emailVerified,
    bool? phoneVerified,
    String? status,
    String? verificationStatus,
    String? createdAt,
    String? updatedAt,
    double? rating,
    int? totalRides,
  }) {
    return User(
      id: id ?? this.id,
      userType: userType ?? this.userType,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      profilePhoto: profilePhoto ?? this.profilePhoto,
      emailVerified: emailVerified ?? this.emailVerified,
      phoneVerified: phoneVerified ?? this.phoneVerified,
      status: status ?? this.status,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rating: rating ?? this.rating,
      totalRides: totalRides ?? this.totalRides,
    );
  }
}

// ============================================================
// AUTHENTICATION RESPONSES
// ============================================================

@JsonSerializable()
class AuthResponse {
  final bool success;
  final String message;
  final User user;
  final String token;
  @JsonKey(name: 'refresh_token')
  final String refreshToken;
  @JsonKey(name: 'token_expires_in', includeIfNull: false)
  final int? tokenExpiresIn;
  @JsonKey(name: 'next_step', includeIfNull: false)
  final String? nextStep;
  @JsonKey(name: 'is_new_user', includeIfNull: false)
  final bool? isNewUser;

  AuthResponse({
    required this.success,
    required this.message,
    required this.user,
    required this.token,
    required this.refreshToken,
    this.tokenExpiresIn,
    this.nextStep,
    this.isNewUser,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseFromJson(json);
  Map<String, dynamic> toJson() => _$AuthResponseToJson(this);
}

typedef LoginResponse = AuthResponse;

// ============================================================
// ERROR HANDLING
// ============================================================

@JsonSerializable()
class ApiError {
  final bool success;
  final String message;
  final List<String>? errors;
  final String? code;

  ApiError({
    required this.success,
    required this.message,
    this.errors,
    this.code,
  });

  factory ApiError.fromJson(Map<String, dynamic> json) =>
      _$ApiErrorFromJson(json);
  Map<String, dynamic> toJson() => _$ApiErrorToJson(this);
}

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final List<String>? errors;
  final String? code;

  ApiException({
    required this.message,
    this.statusCode,
    this.errors,
    this.code,
  });

  @override
  String toString() {
    return 'ApiException: $message (Status: $statusCode)';
  }
}

class NetworkException implements Exception {
  final String message;

  NetworkException(this.message);

  @override
  String toString() {
    return 'NetworkException: $message';
  }
}

class ValidationException implements Exception {
  final Map<String, String> errors;

  ValidationException(this.errors);

  @override
  String toString() {
    return 'ValidationException: ${errors.toString()}';
  }
}

// ============================================================
// PROFILE PHOTO UPLOAD RESPONSE
// ============================================================

class ProfilePhotoUploadResponse {
  final bool success;
  final String message;
  final String profilePhotoUrl;

  ProfilePhotoUploadResponse({
    required this.success,
    required this.message,
    required this.profilePhotoUrl,
  });

  factory ProfilePhotoUploadResponse.fromJson(Map<String, dynamic> json) {
    String photoUrl = '';

    if (json['data'] != null) {
      photoUrl =
          json['data']['profilePhoto'] ??
          json['data']['profilePhotoUrl'] ??
          json['data']['url'] ??
          '';
    }

    if (photoUrl.isEmpty) {
      photoUrl =
          json['profilePhoto'] ?? json['profilePhotoUrl'] ?? json['url'] ?? '';
    }

    return ProfilePhotoUploadResponse(
      success: json['success'] ?? true,
      message: json['message'] ?? 'Profile photo uploaded successfully',
      profilePhotoUrl: photoUrl,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'profilePhotoUrl': profilePhotoUrl,
    };
  }
}
