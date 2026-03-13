import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:ridenowappsss/core/storage/local_storage.dart';
import 'package:ridenowappsss/core/utils/constants/api_constant.dart';
import 'package:ridenowappsss/modules/ride/data/models/available_drvers.dart';
import 'package:ridenowappsss/modules/ride/data/models/place_details.dart';
import 'package:ridenowappsss/modules/ride/data/models/place_prediction.dart';
import 'package:ridenowappsss/modules/ride/data/models/ride_request_model.dart';

abstract class PlacesRemoteDataSource {
  Future<List<PlacePrediction>> getPredictions(
    String query, {
    double? latitude,
    double? longitude,
  });

  Future<PlaceDetails?> getPlaceDetails(String placeId);

  Future<Map<String, dynamic>?> getDirections({
    required double originLat,
    required double originLng,
    required double destLat,
    required double destLng,
  });

  Future<CreateRideResponse> createRide(CreateRideRequest request);

  Future<AvailableDriversResponse> getAvailableDrivers(String rideId);

  Future<CounterOffersResponse> getCounterOffers(String rideId);

  Future<RideDetails?> getRideDetails(String rideId);

  Future<DriverStatusResponse> getDriverStatus(String rideId);

  Future<RideCodeResponse> getRideCode(String rideId);

  Future<void> selectDriver(
    String rideId,
    String driverId,
    double acceptedFare,
  );

  Future<void> acceptCounterOffer(String rideId, String offerId);

  Future<void> declineCounterOffer(String rideId, String offerId);

  Future<void> cancelRide(String rideId);

  Future<PlaceDetails?> reverseGeocode(double lat, double lng);
}

class PlacesRemoteDataSourceImpl implements PlacesRemoteDataSource {
  final http.Client _client;
  final SecureStorageService _storageService;
  final String _baseUrl;

  PlacesRemoteDataSourceImpl({
    http.Client? client,
    required SecureStorageService storageService,
    String? baseUrl,
  }) : _client = client ?? http.Client(),
       _storageService = storageService,
       _baseUrl = baseUrl ?? ApiConstants.baseUrl;

  @override
  Future<List<PlacePrediction>> getPredictions(
    String query, {
    double? latitude,
    double? longitude,
  }) async {
    try {
      final queryParams = {
        'input': query,
        'key': ApiConstants.googleMapsApiKey,
        'components': 'country:${ApiConstants.countryCode}',
      };

      if (latitude != null && longitude != null) {
        queryParams['location'] = '$latitude,$longitude';
        queryParams['radius'] = ApiConstants.searchRadiusMeters.toString();
      }

      final uri = Uri.parse(
        '${ApiConstants.googleMapsBaseUrl}/place/autocomplete/json',
      ).replace(queryParameters: queryParams);

      debugPrint('🔍 Fetching predictions for: $query');

      final response = await _client
          .get(uri)
          .timeout(
            const Duration(seconds: 20),
            onTimeout: () {
              debugPrint('⏰ Predictions request timed out after 20 seconds');
              throw TimeoutException('Request timed out');
            },
          );

      if (response.statusCode == 200) {
        return compute(_parsePredictions, response.body);
      } else {
        debugPrint('❌ Predictions API error: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      debugPrint('❌ Error fetching predictions: $e');
      return [];
    }
  }

  static List<PlacePrediction> _parsePredictions(String body) {
    final data = json.decode(body) as Map<String, dynamic>;
    final status = data['status'] as String?;

    if (status != 'OK' && status != 'ZERO_RESULTS') {
      return [];
    }

    return (data['predictions'] as List?)
            ?.map((p) => PlacePrediction.fromJson(p as Map<String, dynamic>))
            .toList() ??
        [];
  }

  @override
  Future<PlaceDetails?> getPlaceDetails(String placeId) async {
    try {
      final uri = Uri.parse(
        '${ApiConstants.googleMapsBaseUrl}/place/details/json',
      ).replace(
        queryParameters: {
          'place_id': placeId,
          'key': ApiConstants.googleMapsApiKey,
          'fields': 'geometry,formatted_address,name',
        },
      );

      final response = await _client
          .get(uri)
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () {
              debugPrint('⏰ Place details request timed out');
              throw TimeoutException('Request timed out');
            },
          );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final status = data['status'] as String?;
        if (status != 'OK') return null;

        final result = data['result'] as Map<String, dynamic>?;
        if (result != null) {
          return PlaceDetails.fromJson(result);
        }
      }
      return null;
    } catch (e) {
      debugPrint('❌ Error fetching place details: $e');
      return null;
    }
  }

  @override
  Future<Map<String, dynamic>?> getDirections({
    required double originLat,
    required double originLng,
    required double destLat,
    required double destLng,
  }) async {
    try {
      final uri = Uri.parse(
        '${ApiConstants.googleMapsBaseUrl}/directions/json',
      ).replace(
        queryParameters: {
          'origin': '$originLat,$originLng',
          'destination': '$destLat,$destLng',
          'key': ApiConstants.googleMapsApiKey,
          'mode': 'driving',
        },
      );

      final response = await _client
          .get(uri)
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final status = data['status'] as String?;
        if (status != 'OK') return null;

        final routes = data['routes'] as List?;
        if (routes != null && routes.isNotEmpty) {
          final route = routes[0] as Map<String, dynamic>;
          final leg = (route['legs'] as List)[0] as Map<String, dynamic>;
          final polyline = route['overview_polyline'] as Map<String, dynamic>;

          return {
            'polyline': polyline['points'] as String,
            'distance': leg['distance']['text'] as String,
            'duration': leg['duration']['text'] as String,
          };
        }
      }
      return null;
    } catch (e) {
      debugPrint('❌ Error fetching directions: $e');
      return null;
    }
  }

  @override
  Future<CreateRideResponse> createRide(CreateRideRequest request) async {
    try {
      final token = await _storageService.getAuthToken();
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final uri = Uri.parse('$_baseUrl${ApiConstants.createRideEndpoint}');
      debugPrint('🚗 Creating ride: ${json.encode(request.toJson())}');

      final response = await _client
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: json.encode(request.toJson()),
          )
          .timeout(const Duration(seconds: 20));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        return CreateRideResponse.fromJson(data);
      } else {
        final errorData = json.decode(response.body) as Map<String, dynamic>?;
        final errorMessage =
            errorData?['message'] as String? ?? 'Failed to create ride';
        throw Exception(errorMessage);
      }
    } catch (e) {
      debugPrint('❌ Error creating ride: $e');
      rethrow;
    }
  }

  @override
  Future<AvailableDriversResponse> getAvailableDrivers(String rideId) async {
    try {
      final token = await _storageService.getAuthToken();
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final endpoint = ApiConstants.getAvailableDriversEndpoint.replaceAll(
        '{rideId}',
        rideId,
      );
      final uri = Uri.parse('$_baseUrl$endpoint');

      final response = await _client
          .get(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        return compute(_parseAvailableDrivers, response.body);
      } else {
        throw Exception('Failed to fetch available drivers');
      }
    } catch (e) {
      debugPrint('❌ Error fetching available drivers: $e');
      rethrow;
    }
  }

  static AvailableDriversResponse _parseAvailableDrivers(String body) {
    final data = json.decode(body);
    return AvailableDriversResponse.fromJson(data);
  }

  @override
  Future<CounterOffersResponse> getCounterOffers(String rideId) async {
    try {
      final token = await _storageService.getAuthToken();
      if (token == null) throw Exception('Authentication token not found');

      final endpoint = ApiConstants.getCounterOffersEndpoint.replaceAll(
        '{rideId}',
        rideId,
      );
      final uri = Uri.parse('$_baseUrl$endpoint');

      final response = await _client
          .get(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        return compute(_parseCounterOffers, response.body);
      } else {
        throw Exception('Failed to fetch counter offers');
      }
    } catch (e) {
      debugPrint('❌ Error fetching counter offers: $e');
      rethrow;
    }
  }

  static CounterOffersResponse _parseCounterOffers(String body) {
    final data = json.decode(body);
    return CounterOffersResponse.fromJson(data);
  }

  @override
  Future<RideDetails?> getRideDetails(String rideId) async {
    try {
      final token = await _storageService.getAuthToken();
      if (token == null) throw Exception('Authentication token not found');

      final uri = Uri.parse(
        '$_baseUrl${ApiConstants.getRideDetailsEndpoint}/$rideId',
      );

      final response = await _client
          .get(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        return compute(_parseRideDetails, response.body);
      }
      return null;
    } catch (e) {
      debugPrint('❌ Error fetching ride details: $e');
      return null;
    }
  }

  static RideDetails? _parseRideDetails(String body) {
    final data = json.decode(body) as Map<String, dynamic>;
    final rideData =
        data['ride'] as Map<String, dynamic>? ??
        data['data'] as Map<String, dynamic>? ??
        data;
    return RideDetails.fromJson(rideData);
  }

  @override
  Future<DriverStatusResponse> getDriverStatus(String rideId) async {
    try {
      final token = await _storageService.getAuthToken();
      if (token == null) throw Exception('Authentication token not found');

      final endpoint = ApiConstants.getRideStatusEndpoint.replaceAll(
        '{rideId}',
        rideId,
      );
      final uri = Uri.parse('$_baseUrl$endpoint');

      final response = await _client
          .get(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        return compute(_parseDriverStatus, response.body);
      } else {
        throw Exception('Failed to fetch driver status');
      }
    } catch (e) {
      debugPrint('❌ Error fetching driver status: $e');
      rethrow;
    }
  }

  static DriverStatusResponse _parseDriverStatus(String body) {
    final data = json.decode(body);
    return DriverStatusResponse.fromJson(data);
  }

  @override
  Future<RideCodeResponse> getRideCode(String rideId) async {
    try {
      final token = await _storageService.getAuthToken();
      if (token == null) throw Exception('Authentication token not found');

      final endpoint = ApiConstants.getRideCodeEndpoint.replaceAll(
        '{rideId}',
        rideId,
      );
      final uri = Uri.parse('$_baseUrl$endpoint');

      final response = await _client
          .get(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return RideCodeResponse.fromJson(data);
      } else {
        throw Exception('Failed to fetch ride code');
      }
    } catch (e) {
      debugPrint('❌ Error fetching ride code: $e');
      rethrow;
    }
  }

  @override
  Future<void> selectDriver(
    String rideId,
    String driverId,
    double acceptedFare,
  ) async {
    try {
      final token = await _storageService.getAuthToken();
      if (token == null) throw Exception('Authentication token not found');

      final endpoint = ApiConstants.selectDriverEndpoint.replaceAll(
        '{rideId}',
        rideId,
      );
      final uri = Uri.parse('$_baseUrl$endpoint');

      debugPrint(
        '🚕 Selecting driver: $driverId for ride: $rideId with fare: $acceptedFare',
      );

      final body = {'driver_id': driverId, 'accepted_fare': acceptedFare};

      debugPrint('📦 Request Body: ${json.encode(body)}');

      final response = await _client
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: json.encode(body),
          )
          .timeout(const Duration(seconds: 20));

      debugPrint(
        '📥 SelectDriver Response: ${response.statusCode} - ${response.body}',
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        final errorData = json.decode(response.body) as Map<String, dynamic>?;
        final errorMessage =
            errorData?['message'] as String? ?? 'Failed to select driver';
        throw Exception('$errorMessage (Status: ${response.statusCode})');
      }
    } catch (e) {
      debugPrint('❌ Error selecting driver: $e');
      rethrow;
    }
  }

  @override
  Future<void> acceptCounterOffer(String rideId, String offerId) async {
    try {
      final token = await _storageService.getAuthToken();
      if (token == null) throw Exception('Authentication token not found');

      final endpoint = ApiConstants.acceptCounterOfferEndpoint
          .replaceAll('{rideId}', rideId)
          .replaceAll('{offerId}', offerId);
      final uri = Uri.parse('$_baseUrl$endpoint');

      debugPrint('🤝 Accepting offer: $offerId for ride: $rideId');

      final response = await _client
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 20));

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to accept offer: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Error accepting offer: $e');
      rethrow;
    }
  }

  @override
  Future<void> declineCounterOffer(String rideId, String offerId) async {
    try {
      final token = await _storageService.getAuthToken();
      if (token == null) throw Exception('Authentication token not found');

      final endpoint = ApiConstants.declineCounterOfferEndpoint
          .replaceAll('{rideId}', rideId)
          .replaceAll('{offerId}', offerId);
      final uri = Uri.parse('$_baseUrl$endpoint');

      debugPrint('👎 Declining offer: $offerId for ride: $rideId');

      final response = await _client
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 20));

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to decline offer: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Error declining offer: $e');
      rethrow;
    }
  }

  @override
  Future<PlaceDetails?> reverseGeocode(double lat, double lng) async {
    try {
      final uri = Uri.parse(
        '${ApiConstants.googleMapsBaseUrl}/geocode/json',
      ).replace(
        queryParameters: {
          'latlng': '$lat,$lng',
          'key': ApiConstants.googleMapsApiKey,
        },
      );

      debugPrint('🔍 Reverse geocoding: $lat, $lng');

      final response = await _client
          .get(uri)
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final status = data['status'] as String?;
        if (status != 'OK') {
          debugPrint('❌ Reverse geocoding error: $status');
          return null;
        }

        final results = data['results'] as List?;
        if (results != null && results.isNotEmpty) {
          // Use the first result (usually the most specific)
          return PlaceDetails.fromJson(results[0] as Map<String, dynamic>);
        }
      } else {
        debugPrint('❌ Reverse geocoding failed: ${response.statusCode}');
      }
      return null;
    } catch (e) {
      debugPrint('❌ Error in reverseGeocode: $e');
      return null;
    }
  }

  @override
  Future<void> cancelRide(String rideId) async {
    try {
      final token = await _storageService.getAuthToken();
      final response = await _client.post(
        Uri.parse('$_baseUrl${ApiConstants.cancelRideEndpoint}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'ride_id': rideId}),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to cancel ride: ${response.body}');
      }
    } catch (e) {
      debugPrint('❌ RemoteDataSource: Error cancelling ride: $e');
      rethrow;
    }
  }
}

// Timeout Exception helper
class TimeoutException implements Exception {
  final String message;
  TimeoutException(this.message);
  @override
  String toString() => 'TimeoutException: $message';
}
