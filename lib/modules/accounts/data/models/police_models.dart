import 'package:json_annotation/json_annotation.dart';

part 'police_models.g.dart';

// ============================================================
// POLICE STATION MODELS
// ============================================================

@JsonSerializable()
class PoliceStation {
  final String name;
  final String address;
  final String? phone;

  PoliceStation({required this.name, required this.address, this.phone});

  factory PoliceStation.fromJson(Map<String, dynamic> json) =>
      _$PoliceStationFromJson(json);
  Map<String, dynamic> toJson() => _$PoliceStationToJson(this);
}

@JsonSerializable()
class PoliceStationsData {
  final List<PoliceStation> stations;
  final int total;

  PoliceStationsData({required this.stations, required this.total});

  factory PoliceStationsData.fromJson(Map<String, dynamic> json) =>
      _$PoliceStationsDataFromJson(json);
  Map<String, dynamic> toJson() => _$PoliceStationsDataToJson(this);
}

@JsonSerializable()
class PoliceStationsResponse {
  final bool success;
  final String message;
  final PoliceStationsData data;

  PoliceStationsResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory PoliceStationsResponse.fromJson(Map<String, dynamic> json) =>
      _$PoliceStationsResponseFromJson(json);
  Map<String, dynamic> toJson() => _$PoliceStationsResponseToJson(this);
}

// ============================================================
// PRIVACY SETTINGS MODELS
// ============================================================

@JsonSerializable()
class PrivacySettingsRequest {
  final bool locationSharingEnabled;
  final bool detectiveModeEnabled;

  PrivacySettingsRequest({
    required this.locationSharingEnabled,
    required this.detectiveModeEnabled,
  });

  factory PrivacySettingsRequest.fromJson(Map<String, dynamic> json) =>
      _$PrivacySettingsRequestFromJson(json);
  Map<String, dynamic> toJson() => _$PrivacySettingsRequestToJson(this);
}

@JsonSerializable()
class PrivacySettingsData {
  final bool locationSharingEnabled;
  final bool detectiveModeEnabled;
  final String updatedAt;

  PrivacySettingsData({
    required this.locationSharingEnabled,
    required this.detectiveModeEnabled,
    required this.updatedAt,
  });

  factory PrivacySettingsData.fromJson(Map<String, dynamic> json) =>
      _$PrivacySettingsDataFromJson(json);
  Map<String, dynamic> toJson() => _$PrivacySettingsDataToJson(this);
}

@JsonSerializable()
class PrivacySettingsResponse {
  final bool success;
  final String message;
  final PrivacySettingsData data;

  PrivacySettingsResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory PrivacySettingsResponse.fromJson(Map<String, dynamic> json) =>
      _$PrivacySettingsResponseFromJson(json);
  Map<String, dynamic> toJson() => _$PrivacySettingsResponseToJson(this);
}
