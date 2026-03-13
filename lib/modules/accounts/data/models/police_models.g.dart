// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'police_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PoliceStation _$PoliceStationFromJson(Map<String, dynamic> json) =>
    PoliceStation(
      name: json['name'] as String,
      address: json['address'] as String,
      phone: json['phone'] as String?,
    );

Map<String, dynamic> _$PoliceStationToJson(PoliceStation instance) =>
    <String, dynamic>{
      'name': instance.name,
      'address': instance.address,
      'phone': instance.phone,
    };

PoliceStationsData _$PoliceStationsDataFromJson(Map<String, dynamic> json) =>
    PoliceStationsData(
      stations:
          (json['stations'] as List<dynamic>)
              .map((e) => PoliceStation.fromJson(e as Map<String, dynamic>))
              .toList(),
      total: (json['total'] as num).toInt(),
    );

Map<String, dynamic> _$PoliceStationsDataToJson(PoliceStationsData instance) =>
    <String, dynamic>{'stations': instance.stations, 'total': instance.total};

PoliceStationsResponse _$PoliceStationsResponseFromJson(
  Map<String, dynamic> json,
) => PoliceStationsResponse(
  success: json['success'] as bool,
  message: json['message'] as String,
  data: PoliceStationsData.fromJson(json['data'] as Map<String, dynamic>),
);

Map<String, dynamic> _$PoliceStationsResponseToJson(
  PoliceStationsResponse instance,
) => <String, dynamic>{
  'success': instance.success,
  'message': instance.message,
  'data': instance.data,
};

PrivacySettingsRequest _$PrivacySettingsRequestFromJson(
  Map<String, dynamic> json,
) => PrivacySettingsRequest(
  locationSharingEnabled: json['locationSharingEnabled'] as bool,
  detectiveModeEnabled: json['detectiveModeEnabled'] as bool,
);

Map<String, dynamic> _$PrivacySettingsRequestToJson(
  PrivacySettingsRequest instance,
) => <String, dynamic>{
  'locationSharingEnabled': instance.locationSharingEnabled,
  'detectiveModeEnabled': instance.detectiveModeEnabled,
};

PrivacySettingsData _$PrivacySettingsDataFromJson(Map<String, dynamic> json) =>
    PrivacySettingsData(
      locationSharingEnabled: json['locationSharingEnabled'] as bool,
      detectiveModeEnabled: json['detectiveModeEnabled'] as bool,
      updatedAt: json['updatedAt'] as String,
    );

Map<String, dynamic> _$PrivacySettingsDataToJson(
  PrivacySettingsData instance,
) => <String, dynamic>{
  'locationSharingEnabled': instance.locationSharingEnabled,
  'detectiveModeEnabled': instance.detectiveModeEnabled,
  'updatedAt': instance.updatedAt,
};

PrivacySettingsResponse _$PrivacySettingsResponseFromJson(
  Map<String, dynamic> json,
) => PrivacySettingsResponse(
  success: json['success'] as bool,
  message: json['message'] as String,
  data: PrivacySettingsData.fromJson(json['data'] as Map<String, dynamic>),
);

Map<String, dynamic> _$PrivacySettingsResponseToJson(
  PrivacySettingsResponse instance,
) => <String, dynamic>{
  'success': instance.success,
  'message': instance.message,
  'data': instance.data,
};
