import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:ridenowappsss/modules/authentication/data/models/auth_models.dart';
import 'package:ridenowappsss/modules/community/data/models/community_models.dart';
import 'package:ridenowappsss/modules/community/domain/services/community_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum CommunityState { initial, loading, loaded, error }

class CommunityProvider extends ChangeNotifier {
  final CommunityService _communityService = CommunityService();
  static const String _sharedRidesCacheKey = 'shared_rides_cache';

  CommunityState _state = CommunityState.initial;
  List<SharedRide> _sharedRides = [];
  LiveRideDetails? _liveRideDetails;
  SharedLocationData? _sharedLocationData;
  Exception? _lastError;
  bool _isSharingLocation = false;
  bool _isStoppingShare = false;

  CommunityState get state => _state;
  List<SharedRide> get sharedRides => _sharedRides;
  LiveRideDetails? get liveRideDetails => _liveRideDetails;
  SharedLocationData? get sharedLocationData => _sharedLocationData;
  Exception? get lastError => _lastError;
  bool get isSharingLocation => _isSharingLocation;
  bool get isStoppingShare => _isStoppingShare;
  bool get isLoading => _state == CommunityState.loading;

  CommunityProvider() {
    _loadCachedSharedRides();
  }

  Future<void> _loadCachedSharedRides() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? cachedData = prefs.getString(_sharedRidesCacheKey);
      if (cachedData != null) {
        final List<dynamic> decoded = jsonDecode(cachedData);
        _sharedRides = decoded
            .map((json) => SharedRide.fromJson(json as Map<String, dynamic>))
            .toList();
        _state = CommunityState.loaded;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading cached shared rides: $e');
    }
  }

  Future<void> _cacheSharedRides() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String encoded = jsonEncode(
        _sharedRides.map((ride) => ride.toJson()).toList(),
      );
      await prefs.setString(_sharedRidesCacheKey, encoded);
    } catch (e) {
      debugPrint('Error caching shared rides: $e');
    }
  }

  String? get errorMessage {
    if (_lastError == null) return null;
    if (_lastError is ApiException) return (_lastError as ApiException).message;
    if (_lastError is NetworkException) {
      return (_lastError as NetworkException).message;
    }
    return 'An unexpected error occurred. Please try again.';
  }

  Future<bool> fetchSharedRides() async {
    try {
      if (_sharedRides.isEmpty) {
        _state = CommunityState.loading;
        notifyListeners();
      }
      
      _lastError = null;
      final response = await _communityService.getSharedRides();
      _sharedRides = response.sharedRides;
      await _cacheSharedRides();
      
      _state = CommunityState.loaded;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _setError(e);
      return false;
    } on NetworkException catch (e) {
      _setError(e);
      return false;
    } catch (e) {
      if (kDebugMode) {
        print('Fetch shared rides error: $e');
      }
      _setError(NetworkException('Failed to load shared rides'));
      return false;
    }
  }

  Future<bool> fetchLiveRide({required String shareToken}) async {
    try {
      _state = CommunityState.loading;
      _lastError = null;
      notifyListeners();

      final response = await _communityService.getLiveRide(
        shareToken: shareToken,
      );
      _liveRideDetails = response.ride;
      _state = CommunityState.loaded;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _setError(e);
      return false;
    } on NetworkException catch (e) {
      _setError(e);
      return false;
    } catch (e) {
      if (kDebugMode) {
        print('Fetch live ride error: $e');
      }
      _setError(NetworkException('Failed to load ride details'));
      return false;
    }
  }

  Future<bool> stopSharingRide({required String rideId}) async {
    try {
      _isStoppingShare = true;
      _lastError = null;
      notifyListeners();

      await _communityService.stopSharingRide(rideId: rideId);

      _sharedRides.removeWhere((ride) => ride.rideId == rideId);
      await _cacheSharedRides();
      
      _isStoppingShare = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _isStoppingShare = false;
      _setError(e);
      return false;
    } on NetworkException catch (e) {
      _isStoppingShare = false;
      _setError(e);
      return false;
    } catch (e) {
      if (kDebugMode) {
        print('Stop sharing ride error: $e');
      }
      _isStoppingShare = false;
      _setError(NetworkException('Failed to stop sharing'));
      return false;
    }
  }

  Future<bool> stopWatchingRide({required String rideId}) async {
    try {
      _isStoppingShare = true;
      _lastError = null;
      notifyListeners();

      await _communityService.stopWatchingRide(rideId: rideId);

      _sharedRides.removeWhere((ride) => ride.rideId == rideId);
      await _cacheSharedRides();
      
      _isStoppingShare = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _isStoppingShare = false;
      _setError(e);
      return false;
    } on NetworkException catch (e) {
      _isStoppingShare = false;
      _setError(e);
      return false;
    } catch (e) {
      if (kDebugMode) {
        print('Stop watching ride error: $e');
      }
      _isStoppingShare = false;
      _setError(NetworkException('Failed to stop watching'));
      return false;
    }
  }

  Future<ShareLocationResponse?> shareLocation({
    required String rideId,
    required int durationMinutes,
  }) async {
    try {
      _isSharingLocation = true;
      _lastError = null;
      notifyListeners();

      final response = await _communityService.shareLocation(
        contactIds: [],
        durationMinutes: durationMinutes,
        rideId: rideId,
      );

      _isSharingLocation = false;
      notifyListeners();
      return response;
    } on ApiException catch (e) {
      _isSharingLocation = false;
      _setError(e);
      return null;
    } on NetworkException catch (e) {
      _isSharingLocation = false;
      _setError(e);
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Share location error: $e');
      }
      _isSharingLocation = false;
      _setError(NetworkException('Failed to share location'));
      return null;
    }
  }

  Future<bool> fetchSharedLocation({required String userId}) async {
    try {
      _state = CommunityState.loading;
      _lastError = null;
      notifyListeners();

      final response = await _communityService.getSharedLocation(
        userId: userId,
      );
      _sharedLocationData = response.data;
      _state = CommunityState.loaded;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _setError(e);
      return false;
    } on NetworkException catch (e) {
      _setError(e);
      return false;
    } catch (e) {
      if (kDebugMode) {
        print('Fetch shared location error: $e');
      }
      _setError(NetworkException('Failed to load location'));
      return false;
    }
  }

  void _setError(Exception error) {
    _state = CommunityState.error;
    _lastError = error;
    notifyListeners();
  }

  void clearError() {
    _lastError = null;
    notifyListeners();
  }
}
