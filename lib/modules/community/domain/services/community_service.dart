import 'package:flutter/foundation.dart';
import 'package:ridenowappsss/core/services/network_services.dart';
import 'package:ridenowappsss/core/utils/constants/api_constant.dart';
import 'package:ridenowappsss/modules/authentication/data/models/emergency_contact_model.dart';
import 'package:ridenowappsss/modules/community/data/models/community_models.dart';

class CommunityService {
  final DioClient _dioClient = DioClient();

  Future<LiveRideResponse> getLiveRide({required String shareToken}) async {
    try {
      final response = await _dioClient.get(
        '${ApiConstants.liveRideEndpoint}/$shareToken',
      );
      return LiveRideResponse.fromJson(response.data);
    } catch (e) {
      if (kDebugMode) {
        print('Get live ride error: $e');
      }
      rethrow;
    }
  }

  Future<SharedRidesResponse> getSharedRides() async {
    try {
      final response = await _dioClient.get(ApiConstants.sharedRidesEndpoint);
      return SharedRidesResponse.fromJson(response.data);
    } catch (e) {
      if (kDebugMode) {
        print('Get shared rides error: $e');
      }
      rethrow;
    }
  }

  Future<StopSharingResponse> stopSharingRide({required String rideId}) async {
    try {
      final endpoint = ApiConstants.stopSharingRideEndpoint.replaceAll(
        '{rideId}',
        rideId,
      );
      final response = await _dioClient.delete(endpoint);
      return StopSharingResponse.fromJson(response.data);
    } catch (e) {
      if (kDebugMode) {
        print('Stop sharing ride error: $e');
      }
      rethrow;
    }
  }

  Future<StopSharingResponse> stopWatchingRide({required String rideId}) async {
    try {
      final endpoint = ApiConstants.stopWatchingRideEndpoint.replaceAll(
        '{rideId}',
        rideId,
      );
      final response = await _dioClient.delete(endpoint);
      return StopSharingResponse.fromJson(response.data);
    } catch (e) {
      if (kDebugMode) {
        print('Stop watching ride error: $e');
      }
      rethrow;
    }
  }

  Future<ShareLocationResponse> shareLocation({
    required List<String> contactIds,
    required int durationMinutes,
    required String rideId,
  }) async {
    try {
      final request = ShareLocationRequest(
        contactIds: contactIds,
        durationMinutes: durationMinutes,
        rideId: rideId,
      );

      final response = await _dioClient.post(
        ApiConstants.shareLocationEndpoint,
        data: request.toJson(),
      );
      return ShareLocationResponse.fromJson(response.data);
    } catch (e) {
      if (kDebugMode) {
        print('Share location error: $e');
      }
      rethrow;
    }
  }

  Future<SharedLocationResponse> getSharedLocation({
    required String userId,
  }) async {
    try {
      final response = await _dioClient.get(
        '${ApiConstants.sharedLocationsEndpoint}/$userId',
      );
      return SharedLocationResponse.fromJson(response.data);
    } catch (e) {
      if (kDebugMode) {
        print('Get shared location error: $e');
      }
      rethrow;
    }
  }

  // --- Contact Management ---

  Future<List<EmergencyContact>> getContacts() async {
    try {
      final response = await _dioClient.get(ApiConstants.contactsEndpoint);
      final List<dynamic> contactsJson = response.data['contacts'];
      return contactsJson.map((json) => EmergencyContact.fromJson(json)).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Get contacts error: $e');
      }
      rethrow;
    }
  }

  Future<String> createContact({
    required String name,
    required String phone,
    String? email,
  }) async {
    try {
      final response = await _dioClient.post(
        ApiConstants.contactsEndpoint,
        data: {
          'name': name,
          'phone': phone,
          'email': email,
        },
      );
      return response.data['id'] as String;
    } catch (e) {
      if (kDebugMode) {
        print('Create contact error: $e');
      }
      rethrow;
    }
  }

  Future<void> deleteContact({required String contactId}) async {
    try {
      await _dioClient.delete('${ApiConstants.contactsEndpoint}/$contactId');
    } catch (e) {
      if (kDebugMode) {
        print('Delete contact error: $e');
      }
      rethrow;
    }
  }
}
