import 'package:ridenowappsss/modules/ride/data/models/ride_request_model.dart';
import 'package:ridenowappsss/modules/ride/data/repositories/places_repository.dart';

class GetRideDetailsUseCase {
  final PlacesRepository _repository;

  GetRideDetailsUseCase(this._repository);

  Future<RideDetails?> execute(String rideId) {
    return _repository.getRideDetails(rideId);
  }
}
