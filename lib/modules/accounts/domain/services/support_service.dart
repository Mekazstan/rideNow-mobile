import 'package:flutter/foundation.dart';
import 'package:ridenowappsss/core/services/network_services.dart';
import 'package:ridenowappsss/modules/accounts/data/models/police_models.dart';
import 'package:ridenowappsss/modules/accounts/data/models/support_models.dart';

class SupportService {
  final DioClient _dioClient = DioClient();

  // ============================================================
  // API ENDPOINTS
  // ============================================================

  static const String _ambulanceServicesEndpoint =
      '/emergencys/ambulance-services';
  static const String _policeStationsEndpoint = '/emergencys/police-stations';
  static const String _privacySettingsEndpoint = '/emergencys/privacy-settings';
  static const String _faqsEndpoint = '/supports/helps/faqs';
  static const String _ticketsEndpoint = '/supports/tickets';

  // ============================================================
  // AMBULANCE SERVICES
  // ============================================================

  Future<AmbulanceServicesResponse> getAmbulanceServices() async {
    try {
      if (kDebugMode) {
        print('=== Get Ambulance Services ===');
        print('Endpoint: $_ambulanceServicesEndpoint');
      }

      final response = await _dioClient.get(_ambulanceServicesEndpoint);

      if (kDebugMode) {
        print('Ambulance Services Response: ${response.data}');
      }

      return AmbulanceServicesResponse.fromJson(response.data);
    } catch (e) {
      if (kDebugMode) {
        print('Get Ambulance Services Error: $e');
      }
      rethrow;
    }
  }

  // ============================================================
  // POLICE STATIONS
  // ============================================================

  Future<PoliceStationsResponse> getPoliceStations({String? location}) async {
    try {
      if (kDebugMode) {
        print('=== Get Police Stations ===');
        print('Endpoint: $_policeStationsEndpoint');
        print('Location: $location');
      }

      final queryParameters = <String, dynamic>{};
      if (location != null && location.trim().isNotEmpty) {
        queryParameters['location'] = location.trim();
      }

      final response = await _dioClient.get(
        _policeStationsEndpoint,
        queryParameters: queryParameters,
      );

      if (kDebugMode) {
        print('Police Stations Response: ${response.data}');
      }

      return PoliceStationsResponse.fromJson(response.data);
    } catch (e) {
      if (kDebugMode) {
        print('Get Police Stations Error: $e');
      }
      rethrow;
    }
  }

  // ============================================================
  // PRIVACY SETTINGS
  // ============================================================

  Future<PrivacySettingsResponse> updateLocationSharing({
    required bool enabled,
  }) async {
    try {
      if (kDebugMode) {
        print('=== Update Location Sharing ===');
        print('Endpoint: $_privacySettingsEndpoint');
        print('Location Sharing Enabled: $enabled');
      }

      final requestData = {'locationSharingEnabled': enabled};

      if (kDebugMode) {
        print('Request Data: $requestData');
      }

      final response = await _dioClient.patch(
        _privacySettingsEndpoint,
        data: requestData,
      );

      if (kDebugMode) {
        print('Location Sharing Response: ${response.data}');
      }

      return PrivacySettingsResponse.fromJson(response.data);
    } catch (e) {
      if (kDebugMode) {
        print('Update Location Sharing Error: $e');
      }
      rethrow;
    }
  }

  Future<PrivacySettingsResponse> updateDetectiveMode({
    required bool enabled,
  }) async {
    try {
      if (kDebugMode) {
        print('=== Update Detective Mode ===');
        print('Endpoint: $_privacySettingsEndpoint');
        print('Detective Mode Enabled: $enabled');
      }

      final requestData = {'detectiveModeEnabled': enabled};

      if (kDebugMode) {
        print('Request Data: $requestData');
      }

      final response = await _dioClient.patch(
        _privacySettingsEndpoint,
        data: requestData,
      );

      if (kDebugMode) {
        print('Detective Mode Response: ${response.data}');
      }

      return PrivacySettingsResponse.fromJson(response.data);
    } catch (e) {
      if (kDebugMode) {
        print('Update Detective Mode Error: $e');
      }
      rethrow;
    }
  }

  // ============================================================
  // FAQs
  // ============================================================

  Future<FaqResponse> getFaqs({bool includeCategories = true}) async {
    try {
      if (kDebugMode) {
        print('=== Get FAQs ===');
        print('Endpoint: $_faqsEndpoint');
      }

      final response = await _dioClient.get(
        _faqsEndpoint,
        queryParameters: {'include_categories': includeCategories.toString()},
      );

      if (kDebugMode) {
        print('FAQs Response: ${response.data}');
      }

      return FaqResponse.fromJson(response.data['data']);
    } catch (e) {
      if (kDebugMode) {
        print('Get FAQs Error: $e');
      }
      rethrow;
    }
  }

  // ============================================================
  // SUBMIT TICKET
  // ============================================================

  Future<CreateTicketResponse> createTicket({
    required String name,
    required String description,
  }) async {
    try {
      if (kDebugMode) {
        print('=== Create Ticket ===');
        print('Endpoint: $_ticketsEndpoint');
      }

      final requestData = CreateTicketRequest(
        name: name.trim(),
        description: description.trim(),
      );

      if (kDebugMode) {
        print('Request Data: ${requestData.toJson()}');
      }

      final response = await _dioClient.post(
        _ticketsEndpoint,
        data: requestData.toJson(),
      );

      if (kDebugMode) {
        print('Create Ticket Response: ${response.data}');
      }

      return CreateTicketResponse.fromJson(response.data);
    } catch (e) {
      if (kDebugMode) {
        print('Create Ticket Error: $e');
      }
      rethrow;
    }
  }
  
  Future<TicketsResponse> getUserTickets() async {
    try {
      if (kDebugMode) {
        print('=== Get User Tickets ===');
        print('Endpoint: $_ticketsEndpoint');
      }

      final response = await _dioClient.get(_ticketsEndpoint);

      if (kDebugMode) {
        print('User Tickets Response: ${response.data}');
      }

      return TicketsResponse.fromJson(response.data);
    } catch (e) {
      if (kDebugMode) {
        print('Get User Tickets Error: $e');
      }
      rethrow;
    }
  }
}
