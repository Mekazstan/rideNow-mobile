import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ridenowappsss/modules/ride/data/models/location_model.dart';
import 'package:ridenowappsss/modules/ride/presentation/providers/rider_provider.dart';
import 'package:ridenowappsss/core/utils/enums/vehicle_type_enum.dart';

class RidePersistenceService {
  static const String _rideIdKey = 'persist_ride_id';
  static const String _rideStageKey = 'persist_ride_stage';
  static const String _pickupKey = 'persist_pickup_location';
  static const String _destinationKey = 'persist_destination_location';
  static const String _vehicleTypeKey = 'persist_vehicle_type';
  static const String _driverNameKey = 'persist_driver_name';
  static const String _driverRatingKey = 'persist_driver_rating';
  static const String _driverPhotoKey = 'persist_driver_photo';
  static const String _driverEtaKey = 'persist_driver_eta';
  static const String _carModelKey = 'persist_car_model';
  static const String _plateNumberKey = 'persist_plate_number';

  Future<void> saveRideState({
    required String? rideId,
    required RideStage stage,
    required LocationModel? pickup,
    required LocationModel? destination,
    required VehicleType? vehicleType,
    String? driverName,
    double? driverRating,
    String? driverPhoto,
    String? driverEta,
    String? carModel,
    String? plateNumber,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    if (rideId == null) {
      await clearRideState();
      return;
    }

    await prefs.setString(_rideIdKey, rideId);
    await prefs.setInt(_rideStageKey, stage.index);

    if (pickup != null) {
      await prefs.setString(
        _pickupKey,
        jsonEncode({
          'latitude': pickup.latitude,
          'longitude': pickup.longitude,
          'address': pickup.address,
        }),
      );
    }

    if (destination != null) {
      await prefs.setString(
        _destinationKey,
        jsonEncode({
          'latitude': destination.latitude,
          'longitude': destination.longitude,
          'address': destination.address,
        }),
      );
    }

    if (vehicleType != null) {
      await prefs.setString(_vehicleTypeKey, vehicleType.toApiValue());
    }

    if (driverName != null) await prefs.setString(_driverNameKey, driverName);
    if (driverRating != null) {
      await prefs.setDouble(_driverRatingKey, driverRating);
    }
    if (driverPhoto != null) {
      await prefs.setString(_driverPhotoKey, driverPhoto);
    }
    if (driverEta != null) await prefs.setString(_driverEtaKey, driverEta);
    if (carModel != null) await prefs.setString(_carModelKey, carModel);
    if (plateNumber != null) {
      await prefs.setString(_plateNumberKey, plateNumber);
    }
  }

  Future<PersistedRideState?> getPersistedState() async {
    final prefs = await SharedPreferences.getInstance();
    final rideId = prefs.getString(_rideIdKey);

    if (rideId == null) return null;

    final stageIndex = prefs.getInt(_rideStageKey) ?? 0;
    final stage = RideStage.values[stageIndex];

    LocationModel? pickup;
    final pickupJson = prefs.getString(_pickupKey);
    if (pickupJson != null) {
      final data = jsonDecode(pickupJson);
      pickup = LocationModel(
        latitude: data['latitude'],
        longitude: data['longitude'],
        address: data['address'],
      );
    }

    LocationModel? destination;
    final destinationJson = prefs.getString(_destinationKey);
    if (destinationJson != null) {
      final data = jsonDecode(destinationJson);
      destination = LocationModel(
        latitude: data['latitude'],
        longitude: data['longitude'],
        address: data['address'],
      );
    }

    final vehicleApiValue = prefs.getString(_vehicleTypeKey);
    final vehicleType =
        vehicleApiValue != null
            ? vehicleTypeFromApiValue(vehicleApiValue)
            : null;

    return PersistedRideState(
      rideId: rideId,
      stage: stage,
      pickup: pickup,
      destination: destination,
      vehicleType: vehicleType,
      driverName: prefs.getString(_driverNameKey),
      driverRating: prefs.getDouble(_driverRatingKey),
      driverPhoto: prefs.getString(_driverPhotoKey),
      driverEta: prefs.getString(_driverEtaKey),
      carModel: prefs.getString(_carModelKey),
      plateNumber: prefs.getString(_plateNumberKey),
    );
  }

  Future<void> clearRideState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_rideIdKey);
    await prefs.remove(_rideStageKey);
    await prefs.remove(_pickupKey);
    await prefs.remove(_destinationKey);
    await prefs.remove(_vehicleTypeKey);
    await prefs.remove(_driverNameKey);
    await prefs.remove(_driverRatingKey);
    await prefs.remove(_driverPhotoKey);
    await prefs.remove(_driverEtaKey);
    await prefs.remove(_carModelKey);
    await prefs.remove(_plateNumberKey);
  }
}

class PersistedRideState {
  final String rideId;
  final RideStage stage;
  final LocationModel? pickup;
  final LocationModel? destination;
  final VehicleType? vehicleType;
  final String? driverName;
  final double? driverRating;
  final String? driverPhoto;
  final String? driverEta;
  final String? carModel;
  final String? plateNumber;

  PersistedRideState({
    required this.rideId,
    required this.stage,
    this.pickup,
    this.destination,
    this.vehicleType,
    this.driverName,
    this.driverRating,
    this.driverPhoto,
    this.driverEta,
    this.carModel,
    this.plateNumber,
  });
}
