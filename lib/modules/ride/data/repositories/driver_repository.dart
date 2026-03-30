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
}
