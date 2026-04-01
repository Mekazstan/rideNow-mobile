import 'package:flutter/foundation.dart';
import 'package:ridenowappsss/modules/ride/data/data_sources/driver_remote_data_source.dart';
import 'package:ridenowappsss/modules/ride/data/models/driver_ride_request.dart';
import 'package:ridenowappsss/modules/wallet/data/models/driver_analytics_models.dart';

abstract class DriverRepository {
  Future<RideRequestsResponse> getRideRequests(RideRequestsQuery query);
  Future<AcceptRideResponse> acceptRide(AcceptRideRequest request);
  Future<void> rejectRide(String rideId);
  Future<DailyLimitStatus> getDriverStatus();
  Future<Map<String, dynamic>> getVerificationStatus();
  Future<void> goOnline(double lat, double lng, String location);
  Future<void> goOffline();
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
}

class DriverRepositoryImpl implements DriverRepository {
  final DriverRemoteDataSource _remoteDataSource;

  DriverRepositoryImpl({required DriverRemoteDataSource remoteDataSource})
    : _remoteDataSource = remoteDataSource;

  @override
  Future<RideRequestsResponse> getRideRequests(RideRequestsQuery query) async {
    try {
      return await _remoteDataSource.getRideRequests(query);
    } catch (e) {
      debugPrint('❌ Repository: Error fetching ride requests: $e');
      rethrow;
    }
  }

  @override
  Future<AcceptRideResponse> acceptRide(AcceptRideRequest request) async {
    try {
      return await _remoteDataSource.acceptRide(request);
    } catch (e) {
      debugPrint('❌ Repository: Error accepting ride: $e');
      rethrow;
    }
  }

  @override
  Future<void> rejectRide(String rideId) async {
    try {
      await _remoteDataSource.rejectRide(rideId);
    } catch (e) {
      debugPrint('❌ Repository: Error rejecting ride: $e');
      rethrow;
    }
  }

  @override
  Future<DailyLimitStatus> getDriverStatus() async {
    try {
      return await _remoteDataSource.getDriverStatus();
    } catch (e) {
      debugPrint('❌ Repository: Error fetching driver status: $e');
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> getVerificationStatus() async {
    try {
      return await _remoteDataSource.getVerificationStatus();
    } catch (e) {
      debugPrint('❌ Repository: Error fetching verification status: $e');
      rethrow;
    }
  }

  @override
  Future<void> goOnline(double lat, double lng, String location) async {
    try {
      await _remoteDataSource.goOnline(lat, lng, location);
    } catch (e) {
      debugPrint('❌ Repository: Error going online: $e');
      rethrow;
    }
  }

  @override
  Future<void> goOffline() async {
    try {
      await _remoteDataSource.goOffline();
    } catch (e) {
      debugPrint('❌ Repository: Error going offline: $e');
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
      return await _remoteDataSource.updateLocation(
        lat: lat,
        lng: lng,
        address: address,
        heading: heading,
        speed: speed,
      );
    } catch (e) {
      debugPrint('❌ Repository: Error updating location: $e');
      rethrow;
    }
  }

  @override
  Future<void> notifyArrival(String rideId, String type, double lat, double lng, String address) async {
    try {
      await _remoteDataSource.notifyArrival(rideId, type, lat, lng, address);
    } catch (e) {
      debugPrint('❌ Repository: Error notifying arrival: $e');
      rethrow;
    }
  }

  @override
  Future<void> startRide(String rideId, String rideCode, double lat, double lng, String address) async {
    try {
      await _remoteDataSource.startRide(rideId, rideCode, lat, lng, address);
    } catch (e) {
      debugPrint('❌ Repository: Error starting ride: $e');
      rethrow;
    }
  }

  @override
  Future<void> completeRide(String rideId, double lat, double lng, String address) async {
    try {
      await _remoteDataSource.completeRide(rideId, lat, lng, address);
    } catch (e) {
      debugPrint('❌ Repository: Error completing ride: $e');
      rethrow;
    }
  }

  @override
  Future<void> cancelActiveRide(String rideId, String reason, String? customReason, double lat, double lng, String address) async {
    try {
      await _remoteDataSource.cancelActiveRide(rideId, reason, customReason, lat, lng, address);
    } catch (e) {
      debugPrint('❌ Repository: Error cancelling active ride: $e');
      rethrow;
    }
  }
}
