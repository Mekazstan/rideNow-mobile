import 'package:ridenowappsss/modules/ride/data/repositories/places_repository.dart';
import 'package:ridenowappsss/modules/ride/data/models/ride_api_models.dart';

class AutoAcceptNearestRideUseCase {
  final PlacesRepository _repository;

  AutoAcceptNearestRideUseCase(this._repository);

  Future<AutoAcceptNearestResponse> execute(String rideId, int maxWaitMinutes) {
    return _repository.autoAcceptNearestRide(rideId, maxWaitMinutes);
  }
}
