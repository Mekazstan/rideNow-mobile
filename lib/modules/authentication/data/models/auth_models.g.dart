// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DeviceInfo _$DeviceInfoFromJson(Map<String, dynamic> json) => DeviceInfo(
  platform: json['platform'] as String,
  version: json['version'] as String,
  deviceId: json['device_id'] as String,
);

Map<String, dynamic> _$DeviceInfoToJson(DeviceInfo instance) =>
    <String, dynamic>{
      'platform': instance.platform,
      'version': instance.version,
      'device_id': instance.deviceId,
    };

LoginRequest _$LoginRequestFromJson(Map<String, dynamic> json) => LoginRequest(
  email: json['email'] as String,
  password: json['password'] as String,
  deviceInfo: DeviceInfo.fromJson(json['device_info'] as Map<String, dynamic>),
);

Map<String, dynamic> _$LoginRequestToJson(LoginRequest instance) =>
    <String, dynamic>{
      'email': instance.email,
      'password': instance.password,
      'device_info': instance.deviceInfo.toJson(),
    };

SignUpRequest _$SignUpRequestFromJson(Map<String, dynamic> json) =>
    SignUpRequest(
      userType: json['user_type'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      phone: json['phone'] as String,
      email: json['email'] as String,
      password: json['password'] as String,
      confirmPassword: json['confirm_password'] as String,
    );

Map<String, dynamic> _$SignUpRequestToJson(SignUpRequest instance) =>
    <String, dynamic>{
      'user_type': instance.userType,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'phone': instance.phone,
      'email': instance.email,
      'password': instance.password,
      'confirm_password': instance.confirmPassword,
    };

SocialAuthRequest _$SocialAuthRequestFromJson(Map<String, dynamic> json) =>
    SocialAuthRequest(
      provider: json['provider'] as String,
      userType: json['user_type'] as String?,
      accessToken: json['access_token'] as String,
      deviceInfo: DeviceInfo.fromJson(
        json['device_info'] as Map<String, dynamic>,
      ),
    );

Map<String, dynamic> _$SocialAuthRequestToJson(SocialAuthRequest instance) =>
    <String, dynamic>{
      'provider': instance.provider,
      if (instance.userType case final value?) 'user_type': value,
      'access_token': instance.accessToken,
      'device_info': instance.deviceInfo.toJson(),
    };

SendVerificationRequest _$SendVerificationRequestFromJson(
  Map<String, dynamic> json,
) => SendVerificationRequest(email: json['email'] as String);

Map<String, dynamic> _$SendVerificationRequestToJson(
  SendVerificationRequest instance,
) => <String, dynamic>{'email': instance.email};

SendVerificationResponse _$SendVerificationResponseFromJson(
  Map<String, dynamic> json,
) => SendVerificationResponse(
  success: json['success'] as bool,
  message: json['message'] as String,
  expiresIn: (json['expires_in'] as num).toInt(),
);

Map<String, dynamic> _$SendVerificationResponseToJson(
  SendVerificationResponse instance,
) => <String, dynamic>{
  'success': instance.success,
  'message': instance.message,
  'expires_in': instance.expiresIn,
};

EmailVerificationRequest _$EmailVerificationRequestFromJson(
  Map<String, dynamic> json,
) => EmailVerificationRequest(
  email: json['email'] as String,
  verificationCode: json['verification_code'] as String,
);

Map<String, dynamic> _$EmailVerificationRequestToJson(
  EmailVerificationRequest instance,
) => <String, dynamic>{
  'email': instance.email,
  'verification_code': instance.verificationCode,
};

EmailVerificationResponse _$EmailVerificationResponseFromJson(
  Map<String, dynamic> json,
) => EmailVerificationResponse(
  success: json['success'] as bool,
  message: json['message'] as String,
  user: User.fromJson(json['user'] as Map<String, dynamic>),
  token: json['token'] as String,
  refreshToken: json['refresh_token'] as String,
  nextStep: json['next_step'] as String,
  isNewUser: json['is_new_user'] as bool?,
  tokenExpiresIn: (json['token_expires_in'] as num).toInt(),
);

Map<String, dynamic> _$EmailVerificationResponseToJson(
  EmailVerificationResponse instance,
) => <String, dynamic>{
  'success': instance.success,
  'message': instance.message,
  'user': instance.user.toJson(),
  'token': instance.token,
  'refresh_token': instance.refreshToken,
  'next_step': instance.nextStep,
  if (instance.isNewUser case final value?) 'is_new_user': value,
  'token_expires_in': instance.tokenExpiresIn,
};

User _$UserFromJson(Map<String, dynamic> json) => User(
  id: json['id'] as String,
  userType: json['userType'] as String,
  firstName: json['firstName'] as String,
  lastName: json['lastName'] as String,
  email: json['email'] as String,
  phone: json['phone'] as String,
  dateOfBirth: json['dateOfBirth'] as String?,
  profilePhoto: json['profilePhoto'] as String?,
  emailVerified: json['emailVerified'] as bool,
  phoneVerified: json['phoneVerified'] as bool,
  status: json['status'] as String,
  verificationStatus: json['verificationStatus'] as String,
  createdAt: json['createdAt'] as String,
  updatedAt: json['updatedAt'] as String,
  rating: (json['rating'] as num?)?.toDouble(),
  totalRides: (json['totalRides'] as num).toInt(),
  locationSharingEnabled: json['locationSharingEnabled'] as bool? ?? false,
  detectiveModeEnabled: json['detectiveModeEnabled'] as bool? ?? false,
  currentRole: json['current_role'] as String?,
  activeRoles: (json['active_roles'] as List<dynamic>?)?.map((e) => e as String).toList() ?? const ['rider'],
  driverOnboardingStatus: json['driver_onboarding_status'] as String? ?? 'pending',
);

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'id': instance.id,
      'userType': instance.userType,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'email': instance.email,
      'phone': instance.phone,
      'dateOfBirth': instance.dateOfBirth,
      'profilePhoto': instance.profilePhoto,
      'emailVerified': instance.emailVerified,
      'phoneVerified': instance.phoneVerified,
      'status': instance.status,
      'verificationStatus': instance.verificationStatus,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
      'rating': instance.rating,
      'totalRides': instance.totalRides,
      'locationSharingEnabled': instance.locationSharingEnabled,
      'detectiveModeEnabled': instance.detectiveModeEnabled,
      'current_role': instance.currentRole,
      'active_roles': instance.activeRoles,
      'driver_onboarding_status': instance.driverOnboardingStatus,
    };

AuthResponse _$AuthResponseFromJson(Map<String, dynamic> json) => AuthResponse(
  success: json['success'] as bool,
  message: json['message'] as String,
  user: User.fromJson(json['user'] as Map<String, dynamic>),
  token: json['token'] as String?,
  refreshToken: json['refresh_token'] as String?,
  tokenExpiresIn: (json['token_expires_in'] as num?)?.toInt(),
  nextStep: json['next_step'] as String?,
  isNewUser: json['is_new_user'] as bool?,
);

Map<String, dynamic> _$AuthResponseToJson(AuthResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'user': instance.user.toJson(),
      'token': instance.token,
      'refresh_token': instance.refreshToken,
      if (instance.tokenExpiresIn case final value?) 'token_expires_in': value,
      if (instance.nextStep case final value?) 'next_step': value,
      if (instance.isNewUser case final value?) 'is_new_user': value,
    };

ApiError _$ApiErrorFromJson(Map<String, dynamic> json) => ApiError(
  success: json['success'] as bool,
  message: json['message'] as String,
  errors: (json['errors'] as List<dynamic>?)?.map((e) => e as String).toList(),
  code: json['code'] as String?,
);

Map<String, dynamic> _$ApiErrorToJson(ApiError instance) => <String, dynamic>{
  'success': instance.success,
  'message': instance.message,
  'errors': instance.errors,
  'code': instance.code,
};
