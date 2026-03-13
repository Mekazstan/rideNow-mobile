import 'package:ridenowappsss/modules/ride/data/repositories/places_repository.dart';

class CancelRideUseCase {
  final PlacesRepository _repository;

  CancelRideUseCase(this._repository);

  Future<void> execute(
    String rideId, {
    required String reason,
    String? otherReason,
  }) {
    return _repository.cancelRide(
      rideId,
      reason: reason,
      otherReason: otherReason,
    );
  }
}
