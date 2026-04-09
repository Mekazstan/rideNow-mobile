import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:ridenowappsss/core/storage/local_storage.dart';
import 'package:ridenowappsss/core/utils/constants/api_constant.dart';
import 'package:ridenowappsss/modules/ride/data/models/driver_ride_request.dart';
import 'package:ridenowappsss/modules/wallet/data/models/driver_analytics_models.dart';
import 'package:ridenowappsss/modules/ride/data/models/driver_vehicle_model.dart';

abstract class DriverRemoteDataSource {
  Future<RideRequestsResponse> getRideRequests(RideRequestsQuery query);
  Future<AcceptRideResponse> acceptRide(AcceptRideRequest request);
  Future<void> rejectRide(String rideId);
  Future<DailyLimitStatus> getDriverStatus();
  Future<Map<String, dynamic>> getVerificationStatus();
  Future<void> goOnline(double lat, double lng, String location, String vehicleId);
  Future<void> goOffline();
  Future<VehiclesResponse> getVehicles();
  Future<Map<String, dynamic>> updateLocation({
    required double lat,
    required double lng,
    String? address,
    double? heading,
    double? speed,
  });
  Future<void> notifyArrival(String rideId, String type, double lat, double lng, String address);
  Future<void> startRide(String rideId, String rideCode, double lat, double lng, String address);
  Future<void> completeRide(String rideId, double lat, double lng, String address);
  Future<void> cancelActiveRide(String rideId, String reason, String? customReason, double lat, double lng, String address);
  Future<Map<String, dynamic>> sendCounterOffer(String rideId, double amount);
}

class DriverRemoteDataSourceImpl implements DriverRemoteDataSource {
  final http.Client _client;
  final SecureStorageService _storageService;
  final String _baseUrl;

  DriverRemoteDataSourceImpl({
    http.Client? client,
    required SecureStorageService storageService,
    String? baseUrl,
  }) : _client = client ?? http.Client(),
       _storageService = storageService,
       _baseUrl = baseUrl ?? ApiConstants.baseUrl;

  @override
  Future<RideRequestsResponse> getRideRequests(RideRequestsQuery query) async {
    try {
      // Get auth token
      final token = await _storageService.getAuthToken();
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      // Build URL with query parameters
      final queryParams = query.toQueryParameters();

      if (queryParams['location'] == null ||
          queryParams['location']!.trim().isEmpty) {
        throw Exception('Location is required');
      }
      if (queryParams['lat'] == null || queryParams['lat']!.isEmpty) {
        throw Exception('Latitude is required');
      }
      if (queryParams['lon'] == null || queryParams['lon']!.isEmpty) {
        throw Exception('Longitude is required');
      }

      final cleanedParams = {
        'location': queryParams['location']!.trim().replaceAll(
          RegExp(r'[^\w\s,.-]'),
          '',
        ),
        'lat': queryParams['lat']!,
        'lon': queryParams['lon']!,
        'radius_km': queryParams['radius_km']!,
      };

      final uri = Uri.parse(
        '$_baseUrl${ApiConstants.driverRideRequestsEndpoint}',
      ).replace(queryParameters: cleanedParams);

      debugPrint('🚗 ==========================================');
      debugPrint('🚗 Fetching ride requests');
      debugPrint('📍 Location: ${cleanedParams['location']}');
      debugPrint(
        '📍 Lat: ${cleanedParams['lat']}, Lon: ${cleanedParams['lon']}',
      );
      debugPrint('📍 Radius: ${cleanedParams['radius_km']}km');
      debugPrint('🔗 Full URL: $uri');
      debugPrint('🔑 Token: ${token.substring(0, 20)}...');
      debugPrint('🚗 ==========================================');

      final response = await _client
          .get(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
              'Accept': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 15));

      debugPrint('📡 Response status: ${response.statusCode}');
      debugPrint('📡 Response body: ${response.body}');

      if (response.statusCode == 200) {
        return compute(_parseRideRequests, response.body);
      } else if (response.statusCode == 400) {
        // Parse error details
        try {
          final errorData = json.decode(response.body) as Map<String, dynamic>;
          final errorMessage = errorData['message'] as String? ?? 'Bad Request';
          final details =
              errorData['error'] as String? ??
              errorData['details'] as String? ??
              errorData['errors'] as String? ??
              '';

          debugPrint('Bad Request Details:');
          debugPrint('   Message: $errorMessage');
          debugPrint('   Details: $details');
          debugPrint('   Full error body: ${response.body}');

          // Check if there's a validation error array
          if (errorData['errors'] is List) {
            final errors = errorData['errors'] as List;
            debugPrint('   Validation Errors: $errors');
          }

          // Provide helpful debugging info
          debugPrint('💡 Debugging Info:');
          debugPrint('   Sent params: $cleanedParams');
          debugPrint('   Expected by backend:');
          debugPrint('      - location: string (e.g., "Lagos, Nigeria")');
          debugPrint('      - lat: number (e.g., 6.5244)');
          debugPrint('      - lon: number (e.g., 3.3792)');
          debugPrint('      - radius_km: number (default: 10)');

          throw Exception(
            '$errorMessage${details.isNotEmpty ? ': $details' : ''}',
          );
        } catch (e) {
          if (e.toString().contains('Exception:')) {
            rethrow;
          }
          debugPrint('Error parsing error response: $e');
          debugPrint('Raw response body: ${response.body}');
          throw Exception(
            'Bad Request - The server rejected the request parameters. Please check your location data.',
          );
        }
      } else if (response.statusCode == 401) {
        throw Exception('Authentication failed. Please log in again.');
      } else if (response.statusCode == 404) {
        throw Exception(
          'Endpoint not found. Please check your API configuration.',
        );
      } else if (response.statusCode == 500) {
        throw Exception('Server error. Please try again later.');
      } else {
        final errorData = json.decode(response.body) as Map<String, dynamic>?;
        final errorMessage =
            errorData?['message'] as String? ??
            errorData?['error'] as String? ??
            'Failed to fetch ride requests (Status: ${response.statusCode})';
        debugPrint('Error fetching ride requests: $errorMessage');
        throw Exception(errorMessage);
      }
    } catch (e) {
      debugPrint('Error in getRideRequests: $e');
      if (e.toString().contains('SocketException') ||
          e.toString().contains('TimeoutException')) {
        throw Exception(
          'Network error. Please check your internet connection.',
        );
      }
      rethrow;
    }
  }

  static RideRequestsResponse _parseRideRequests(String body) {
    final data = json.decode(body) as Map<String, dynamic>;
    return RideRequestsResponse.fromJson(data);
  }

  @override
  Future<AcceptRideResponse> acceptRide(AcceptRideRequest request) async {
    try {
      // Get auth token
      final token = await _storageService.getAuthToken();
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      // rideId goes in the URL path: POST /drivers/ride-requests/:rideId/accept
      final url = '$_baseUrl${ApiConstants.acceptRideEndpoint(request.rideId)}';
      final uri = Uri.parse(url);

      debugPrint('🚗 Accepting ride: ${request.rideId} → $url');

      // Build the body with required fields that AcceptRideDto expects
      final body = <String, dynamic>{
        // driver_location: use the cached last-known location if available,
        // or send a placeholder — the backend geospatially has the driver's position.
        'driver_location': {
          'lat': request.driverLat ?? 0.0,
          'lng': request.driverLng ?? 0.0,
        },
        // estimated_arrival in minutes — send a sensible default if unknown
        'estimated_arrival': request.estimatedArrivalMinutes ?? 5,
      };
      if (request.proposedFare != null) {
        body['accepted_fare'] = request.proposedFare;
      }

      final response = await _client
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: json.encode(body),
          )
          .timeout(const Duration(seconds: 15));

      debugPrint('📡 Response status: ${response.statusCode}');
      debugPrint('📡 Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final acceptResponse = AcceptRideResponse.fromJson(data);
        debugPrint('✅ Ride accepted successfully');
        return acceptResponse;
      } else {
        final errorData = json.decode(response.body) as Map<String, dynamic>?;
        // NestJS validation errors return message as List<String>, not String
        final rawMessage = errorData?['message'];
        final errorMessage = rawMessage is List
            ? (rawMessage as List<dynamic>).join(', ')
            : rawMessage as String? ?? errorData?['error'] as String? ?? 'Failed to accept ride';
        debugPrint('❌ Error accepting ride: $errorMessage');
        throw Exception(errorMessage);
      }
    } catch (e) {
      debugPrint('Error in acceptRide: $e');
      if (e.toString().contains('SocketException') ||
          e.toString().contains('TimeoutException')) {
        throw Exception(
          'Network error. Please check your internet connection.',
        );
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> sendCounterOffer(String rideId, double amount) async {
    try {
      final token = await _storageService.getAuthToken();
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final url = '$_baseUrl${ApiConstants.sendCounterOfferEndpoint(rideId)}';
      final uri = Uri.parse(url);

      debugPrint('🚀 Sending counter offer: $rideId → $amount');

      final body = {
        'amount': amount,
      };

      final response = await _client
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: json.encode(body),
          )
          .timeout(const Duration(seconds: 15));

      debugPrint('📡 Response status: ${response.statusCode}');
      debugPrint('📡 Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        final errorData = json.decode(response.body) as Map<String, dynamic>?;
        final rawMessage = errorData?['message'];
        final errorMessage = rawMessage is List
            ? (rawMessage as List<dynamic>).join(', ')
            : rawMessage as String? ?? errorData?['error'] as String? ?? 'Failed to send counter offer';
        throw Exception(errorMessage);
      }
    } catch (e) {
      debugPrint('Error in sendCounterOffer: $e');
      if (e.toString().contains('SocketException') ||
          e.toString().contains('TimeoutException')) {
        throw Exception('Network error. Please check your internet connection.');
      }
      rethrow;
    }
  }

  @override
  Future<void> rejectRide(String rideId) async {
    try {
      // Get auth token
      final token = await _storageService.getAuthToken();
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      // rideId goes in the URL path: POST /drivers/ride-requests/:rideId/decline
      final url = '$_baseUrl${ApiConstants.rejectRideEndpoint(rideId)}';
      final uri = Uri.parse(url);

      debugPrint('🚗 Rejecting ride: $rideId → $url');

      final response = await _client
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: json.encode({}),
          )
          .timeout(const Duration(seconds: 15));

      debugPrint('📡 Response status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201 || response.statusCode == 204) {
        debugPrint('✅ Ride rejected successfully');
      } else {
        final errorData = json.decode(response.body) as Map<String, dynamic>?;
        final errorMessage =
            errorData?['message'] as String? ??
            errorData?['error'] as String? ??
            'Failed to reject ride';
        debugPrint('❌ Error rejecting ride: $errorMessage');
        throw Exception(errorMessage);
      }
    } catch (e) {
      debugPrint('Error in rejectRide: $e');
      if (e.toString().contains('SocketException') ||
          e.toString().contains('TimeoutException')) {
        throw Exception(
          'Network error. Please check your internet connection.',
        );
      }
      rethrow;
    }
  }

  @override
  Future<DailyLimitStatus> getDriverStatus() async {
    try {
      final token = await _storageService.getAuthToken();
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final uri = Uri.parse('$_baseUrl${ApiConstants.driverDailyLimitStatusEndpoint}');

      final response = await _client.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        return DailyLimitStatus.fromJson(data);
      } else {
        throw Exception('Failed to fetch driver status');
      }
    } catch (e) {
      debugPrint('Error in getDriverStatus: $e');
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> getVerificationStatus() async {
    try {
      final token = await _storageService.getAuthToken();
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final uri = Uri.parse('$_baseUrl${ApiConstants.getDriverVerificationStatusEndpoint}');

      final response = await _client.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Failed to fetch verification status');
      }
    } catch (e) {
      debugPrint('Error in getVerificationStatus: $e');
      rethrow;
    }
  }

  @override
  Future<void> goOnline(double lat, double lng, String location, String vehicleId) async {
    try {
      final token = await _storageService.getAuthToken();
      if (token == null) throw Exception('Authentication token not found');

      final uri = Uri.parse('$_baseUrl${ApiConstants.goOnlineEndpoint}');
      
      // Corrected payload to match GoOnlineDto: current_location (nested) and vehicle_id
      final body = {
        'current_location': {
          'lat': lat,
          'lng': lng,
          'address': location,
        },
        'vehicle_id': vehicleId,
      };

      debugPrint('🚗 Driver going online: ${json.encode(body)}');

      final response = await _client.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(body),
      ).timeout(const Duration(seconds: 15));

      debugPrint('📡 Go online response: ${response.statusCode}');
      debugPrint('📡 Response body: ${response.body}');

      if (response.statusCode != 200 && response.statusCode != 201) {
        final errorData = json.decode(response.body) as Map<String, dynamic>?;
        final rawMessage = errorData?['message'];
        final errorMessage = rawMessage is List
            ? (rawMessage as List<dynamic>).join(', ')
            : rawMessage as String? ?? 'Failed to go online';
        throw Exception(errorMessage);
      }
    } catch (e) {
      debugPrint('Error in goOnline: $e');
      rethrow;
    }
  }

  @override
  Future<VehiclesResponse> getVehicles() async {
    try {
      final token = await _storageService.getAuthToken();
      if (token == null) throw Exception('Authentication token not found');

      final uri = Uri.parse('$_baseUrl/drivers/vehicles');
      final response = await _client.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        return VehiclesResponse.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to fetch vehicles');
      }
    } catch (e) {
      debugPrint('Error in getVehicles: $e');
      rethrow;
    }
  }

  @override
  Future<void> goOffline() async {
    try {
      final token = await _storageService.getAuthToken();
      if (token == null) throw Exception('Authentication token not found');

      final uri = Uri.parse('$_baseUrl${ApiConstants.goOfflineEndpoint}');
      final response = await _client.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode != 200 && response.statusCode != 201 && response.statusCode != 204) {
        final errorData = json.decode(response.body) as Map<String, dynamic>?;
        throw Exception(errorData?['message'] ?? 'Failed to go offline');
      }
    } catch (e) {
      debugPrint('Error in goOffline: $e');
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> updateLocation({
    required double lat,
    required double lng,
    String? address,
    double? heading,
    double? speed,
  }) async {
    try {
      final token = await _storageService.getAuthToken();
      if (token == null) throw Exception('Authentication token not found');

      final uri = Uri.parse('$_baseUrl${ApiConstants.updateLocationEndpoint}');
      
      final body = {
        'location': {
          'lat': lat,
          'lng': lng,
          if (address != null) 'address': address,
          if (heading != null) 'heading': heading,
          if (speed != null) 'speed': speed,
        },
        if (heading != null) 'heading': heading,
        if (speed != null) 'speed': speed,
      };

      debugPrint('🚗 Updating location: ${json.encode(body)}');

      final response = await _client.put(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(body),
      ).timeout(const Duration(seconds: 25));

      debugPrint('📡 Update position response: ${response.statusCode}');
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        final errorData = json.decode(response.body) as Map<String, dynamic>?;
        throw Exception(errorData?['message'] ?? 'Failed to update location');
      }
    } catch (e) {
      debugPrint('❌ Error in updateLocation: $e');
      rethrow;
    }
  }

  @override
  Future<void> notifyArrival(String rideId, String type, double lat, double lng, String address) async {
    try {
      final token = await _storageService.getAuthToken();
      if (token == null) throw Exception('Authentication token not found');

      final url = '$_baseUrl/drivers/rides/$rideId/arrival';
      debugPrint('🚗 Notifying arrival: $rideId → $url');

      final body = {
        'arrival_type': type,
        'location': {
          'lat': lat,
          'lng': lng,
          'address': address
        }
      };

      final response = await _client.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(body),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode != 200 && response.statusCode != 201) {
         final errorData = json.decode(response.body) as Map<String, dynamic>?;
         throw Exception(errorData?['message'] ?? 'Failed to notify arrival');
      }
    } catch (e) {
      debugPrint('❌ Error in notifyArrival: $e');
      rethrow;
    }
  }

  @override
  Future<void> startRide(String rideId, String rideCode, double lat, double lng, String address) async {
     try {
       final token = await _storageService.getAuthToken();
       if (token == null) throw Exception('Authentication token not found');

       final url = '$_baseUrl/drivers/rides/$rideId/start';
       debugPrint('🚗 Starting ride: $rideId → $url');

       final body = {
         'ride_code': rideCode,
         'driver_location': {
           'lat': lat,
           'lng': lng,
           'address': address
         }
       };

       final response = await _client.post(
         Uri.parse(url),
         headers: {
           'Content-Type': 'application/json',
           'Authorization': 'Bearer $token',
         },
         body: json.encode(body),
       ).timeout(const Duration(seconds: 15));

       if (response.statusCode != 200 && response.statusCode != 201) {
          final errorData = json.decode(response.body) as Map<String, dynamic>?;
          throw Exception(errorData?['message'] ?? 'Failed to start ride');
       }
     } catch (e) {
       debugPrint('❌ Error in startRide: $e');
       rethrow;
     }
  }

  @override
  Future<void> completeRide(String rideId, double lat, double lng, String address) async {
     try {
       final token = await _storageService.getAuthToken();
       if (token == null) throw Exception('Authentication token not found');

       final url = '$_baseUrl/drivers/rides/$rideId/complete';
       debugPrint('🚗 Completing ride: $rideId → $url');

       final body = {
         'end_location': {
           'lat': lat,
           'lng': lng,
           'address': address
         }
       };

       final response = await _client.post(
         Uri.parse(url),
         headers: {
           'Content-Type': 'application/json',
           'Authorization': 'Bearer $token',
         },
         body: json.encode(body),
       ).timeout(const Duration(seconds: 15));

       if (response.statusCode != 200 && response.statusCode != 201) {
          final errorData = json.decode(response.body) as Map<String, dynamic>?;
          throw Exception(errorData?['message'] ?? 'Failed to complete ride');
       }
     } catch (e) {
       debugPrint('❌ Error in completeRide: $e');
       rethrow;
     }
  }

  @override
  Future<void> cancelActiveRide(String rideId, String reason, String? customReason, double lat, double lng, String address) async {
     try {
       final token = await _storageService.getAuthToken();
       if (token == null) throw Exception('Authentication token not found');

       final url = '$_baseUrl/drivers/rides/$rideId/cancel';
       debugPrint('🚗 Canceling active ride: $rideId → $url');

       final body = {
         'reason': reason,
         if (customReason != null) 'description': customReason,
         'current_location': {
           'lat': lat,
           'lng': lng,
           'address': address
         }
       };

       final response = await _client.post(
         Uri.parse(url),
         headers: {
           'Content-Type': 'application/json',
           'Authorization': 'Bearer $token',
         },
         body: json.encode(body),
       ).timeout(const Duration(seconds: 15));

       if (response.statusCode != 200 && response.statusCode != 201) {
          final errorData = json.decode(response.body) as Map<String, dynamic>?;
          throw Exception(errorData?['message'] ?? 'Failed to cancel active ride');
       }
     } catch (e) {
       debugPrint('❌ Error in cancelActiveRide: $e');
       rethrow;
     }
  }
}
