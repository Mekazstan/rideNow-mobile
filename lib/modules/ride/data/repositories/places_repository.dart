import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ridenowappsss/core/services/network_services.dart';
import 'package:ridenowappsss/core/utils/constants/api_constant.dart';
import 'package:ridenowappsss/core/utils/helpers/polyline_decoder.dart';
import 'package:ridenowappsss/modules/ride/data/data_sources/places_remote_data_source.dart';
import 'package:ridenowappsss/modules/ride/data/models/available_drvers.dart';
import 'package:ridenowappsss/modules/ride/data/models/place_details.dart';
import 'package:ridenowappsss/modules/ride/data/models/place_prediction.dart';
import 'package:ridenowappsss/modules/ride/data/models/ride_request_model.dart';
import 'package:ridenowappsss/modules/ride/data/models/route_model.dart';
import 'package:ridenowappsss/modules/ride/data/models/ride_api_models.dart';

abstract class PlacesRepository {
  Future<List<PlacePrediction>> searchPlaces(
    String query, {
    double? latitude,
    double? longitude,
  });

  Future<PlaceDetails?> getPlaceDetails(String placeId);

  Future<RouteModel?> getRoute({
    required LatLng origin,
    required LatLng destination,
  });

  Future<PlaceDetails?> geocodeAddress(String address);

  Future<CreateRideResponse> createRide(CreateRideRequest request);

  Future<AvailableDriversResponse> getAvailableDrivers(String rideId);

  Future<CounterOffersResponse> getCounterOffers(String rideId);

  Future<String?> fetchUserProfilePhoto();

  Future<RideDetails?> getRideDetails(String rideId);

  Future<DriverStatusResponse> getDriverStatus(String rideId);

  Future<RideCodeResponse> getRideCode(String rideId);

  void cancelPendingRequests();

  Future<void> selectDriver(
    String rideId,
    String driverId,
    double acceptedFare,
  );

  Future<void> acceptCounterOffer(String rideId, String offerId);

  Future<void> declineCounterOffer(String rideId, String offerId);

  Future<PlaceDetails?> reverseGeocodeAddress(double lat, double lng);

  Future<RideHistoryResponse> getRiderHistory();
  Future<RideDetails?> getActiveRide();
  Future<void> cancelRide(String rideId, {String? reason, String? otherReason});
  Future<AutoAcceptNearestResponse> autoAcceptNearestRide(String rideId, int maxWaitMinutes);
  Future<ChatHistoryResponse> getChatHistory(String rideId);
  Future<SendMessageResponse> sendMessage(String rideId, String message);
}

class PlacesRepositoryImpl implements PlacesRepository {
  final PlacesRemoteDataSource _remoteDataSource;
  final PolylineDecoder _polylineDecoder;
  final DioClient _dioClient;

  Timer? _debounceTimer;

  PlacesRepositoryImpl({
    required PlacesRemoteDataSource remoteDataSource,
    required DioClient dioClient,
    PolylineDecoder? polylineDecoder,
  }) : _remoteDataSource = remoteDataSource,
       _dioClient = dioClient,
       _polylineDecoder = polylineDecoder ?? PolylineDecoderImpl();

  @override
  Future<List<PlacePrediction>> searchPlaces(
    String query, {
    double? latitude,
    double? longitude,
  }) async {
    _debounceTimer?.cancel();

    final completer = Completer<List<PlacePrediction>>();

    _debounceTimer = Timer(ApiConstants.debounceDelay, () async {
      try {
        final predictions = await _remoteDataSource.getPredictions(
          query,
          latitude: latitude,
          longitude: longitude,
        );

        if (!completer.isCompleted) {
          completer.complete(predictions);
        }
      } catch (e) {
        debugPrint('❌ Error in searchPlaces: $e');

        if (!completer.isCompleted) {
          completer.complete([]);
        }
      }
    });
    return completer.future.timeout(
      const Duration(seconds: 25),
      onTimeout: () {
        debugPrint('⚠️ Search timed out for query: $query');
        return [];
      },
    );
  }

  @override
  Future<PlaceDetails?> getPlaceDetails(String placeId) async {
    try {
      return await _remoteDataSource.getPlaceDetails(placeId);
    } catch (e) {
      debugPrint('❌ Error getting place details: $e');
      return null;
    }
  }

  @override
  Future<RouteModel?> getRoute({
    required LatLng origin,
    required LatLng destination,
  }) async {
    try {
      final response = await _remoteDataSource.getDirections(
        originLat: origin.latitude,
        originLng: origin.longitude,
        destLat: destination.latitude,
        destLng: destination.longitude,
      );

      if (response == null) return null;

      final points = await _polylineDecoder.decode(
        response['polyline'] as String,
      );

      return RouteModel(
        points: points,
        distance: response['distance'] as String,
        duration: response['duration'] as String,
      );
    } catch (e) {
      debugPrint('❌ Error getting route: $e');
      return null;
    }
  }

  @override
  Future<PlaceDetails?> geocodeAddress(String address) async {
    try {
      if (address.trim().isEmpty) return null;

      final predictions = await searchPlaces(address);

      if (predictions.isEmpty) {
        debugPrint('⚠️ No predictions found for address: $address');
        return null;
      }

      final placeDetails = await getPlaceDetails(predictions.first.placeId);

      if (placeDetails != null) {
        debugPrint('✅ Geocoded address: $address');
      } else {
        debugPrint(
          '⚠️ Could not get place details for: ${predictions.first.placeId}',
        );
      }

      return placeDetails;
    } catch (e) {
      debugPrint('❌ Error geocoding address "$address": $e');
      return null;
    }
  }

  @override
  Future<CreateRideResponse> createRide(CreateRideRequest request) async {
    try {
      return await _remoteDataSource.createRide(request);
    } catch (e) {
      debugPrint('❌ Repository: Error creating ride: $e');
      rethrow;
    }
  }

  @override
  Future<AvailableDriversResponse> getAvailableDrivers(String rideId) async {
    try {
      debugPrint('📍 Repository: Fetching available drivers for ride: $rideId');
      return await _remoteDataSource.getAvailableDrivers(rideId);
    } catch (e) {
      debugPrint('❌ Repository: Error fetching available drivers: $e');
      rethrow;
    }
  }

  @override
  Future<CounterOffersResponse> getCounterOffers(String rideId) async {
    try {
      debugPrint('📍 Repository: Fetching counter offers for ride: $rideId');
      return await _remoteDataSource.getCounterOffers(rideId);
    } catch (e) {
      debugPrint('❌ Repository: Error fetching counter offers: $e');
      rethrow;
    }
  }

  @override
  Future<String?> fetchUserProfilePhoto() async {
    try {
      debugPrint(
        '📸 RemoteDataSource: Fetching user profile photo from backend...',
      );
      final response = await _dioClient.get(ApiConstants.profileEndpoint);

      if (response.data != null && response.data['data'] != null) {
        final profilePhoto = response.data['data']['profilePhoto'] as String?;
        debugPrint('✅ Profile photo URL retrieved: $profilePhoto');
        return profilePhoto;
      }

      debugPrint('⚠️ No profile photo in response');
      return null;
    } catch (e) {
      debugPrint('❌ Error fetching profile photo: $e');
      return null;
    }
  }

  @override
  Future<RideDetails?> getRideDetails(String rideId) async {
    return await _remoteDataSource.getRideDetails(rideId);
  }

  @override
  Future<DriverStatusResponse> getDriverStatus(String rideId) async {
    return await _remoteDataSource.getDriverStatus(rideId);
  }

  @override
  Future<RideCodeResponse> getRideCode(String rideId) async {
    return await _remoteDataSource.getRideCode(rideId);
  }

  @override
  void cancelPendingRequests() {
    _debounceTimer?.cancel();
  }

  @override
  Future<void> selectDriver(
    String rideId,
    String driverId,
    double acceptedFare,
  ) async {
    await _remoteDataSource.selectDriver(rideId, driverId, acceptedFare);
  }

  @override
  Future<void> acceptCounterOffer(String rideId, String offerId) async {
    await _remoteDataSource.acceptCounterOffer(rideId, offerId);
  }

  @override
  Future<void> declineCounterOffer(String rideId, String offerId) async {
    await _remoteDataSource.declineCounterOffer(rideId, offerId);
  }

  @override
  Future<void> cancelRide(String rideId, {String? reason, String? otherReason}) async {
    await _remoteDataSource.cancelRide(rideId, reason: reason, otherReason: otherReason);
  }

  @override
  Future<AutoAcceptNearestResponse> autoAcceptNearestRide(String rideId, int maxWaitMinutes) async {
    return await _remoteDataSource.autoAcceptNearestRide(rideId, maxWaitMinutes);
  }

  @override
  Future<RideDetails?> getActiveRide() async {
    return await _remoteDataSource.getActiveRide();
  }

  @override
  Future<PlaceDetails?> reverseGeocodeAddress(double lat, double lng) async {
    return await _remoteDataSource.reverseGeocode(lat, lng);
  }

  @override
  Future<RideHistoryResponse> getRiderHistory() async {
    return await _remoteDataSource.getRiderHistory();
  }



  @override
  Future<ChatHistoryResponse> getChatHistory(String rideId) async {
    return await _remoteDataSource.getChatHistory(rideId);
  }

  @override
  Future<SendMessageResponse> sendMessage(String rideId, String message) async {
    return await _remoteDataSource.sendMessage(rideId, message);
  }
}
