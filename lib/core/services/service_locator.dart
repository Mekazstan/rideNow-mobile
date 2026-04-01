import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:ridenowappsss/core/services/location_service.dart';
import 'package:ridenowappsss/core/services/network_services.dart';
import 'package:ridenowappsss/core/storage/local_storage.dart';
import 'package:ridenowappsss/core/utils/constants/api_constant.dart';
import 'package:ridenowappsss/core/utils/helpers/marker_manager.dart';
import 'package:ridenowappsss/core/utils/helpers/polyline_decoder.dart';
import 'package:ridenowappsss/modules/ride/data/data_sources/driver_remote_data_source.dart';
import 'package:ridenowappsss/modules/ride/data/data_sources/places_remote_data_source.dart';
import 'package:ridenowappsss/modules/ride/data/repositories/driver_repository.dart';
import 'package:ridenowappsss/modules/ride/data/repositories/places_repository.dart';
import 'package:ridenowappsss/modules/ride/presentation/providers/driver_provider.dart';
import 'package:ridenowappsss/modules/ride/presentation/providers/rider_provider.dart';
import 'package:ridenowappsss/core/storage/ride_persistence.dart';
import 'package:ridenowappsss/core/services/socket_service.dart';

final getIt = GetIt.instance;

void setupServiceLocator() {
  // HTTP Clients
  getIt.registerLazySingleton<http.Client>(() => http.Client());

  // Storage Service
  getIt.registerLazySingleton<SecureStorageService>(
    () => SecureStorageService(),
  );

  getIt.registerLazySingleton<RidePersistenceService>(
    () => RidePersistenceService(),
  );

  // Network Service (DioClient) - DioClient creates its own Dio instance internally
  getIt.registerLazySingleton<DioClient>(() => DioClient());
  
  // Real-time Service
  getIt.registerLazySingleton<SocketService>(() => SocketService());

  // Register Dio instance from DioClient
  getIt.registerLazySingleton<Dio>(() => getIt<DioClient>().dio);

  // Data sources
  getIt.registerLazySingleton<PlacesRemoteDataSource>(
    () => PlacesRemoteDataSourceImpl(
      client: getIt<http.Client>(),
      storageService: getIt<SecureStorageService>(),
      baseUrl: ApiConstants.baseUrl,
    ),
  );
  
  getIt.registerLazySingleton<DriverRemoteDataSource>(
    () => DriverRemoteDataSourceImpl(
      storageService: getIt<SecureStorageService>(),
    ),
  );

  // Utilities
  getIt.registerLazySingleton<PolylineDecoder>(() => PolylineDecoderImpl());

  // Repositories
  getIt.registerLazySingleton<PlacesRepository>(
    () => PlacesRepositoryImpl(
      remoteDataSource: getIt<PlacesRemoteDataSource>(),
      dioClient: getIt<DioClient>(),
      polylineDecoder: getIt<PolylineDecoder>(),
    ),
  );

  getIt.registerLazySingleton<DriverRepository>(
    () => DriverRepositoryImpl(
      remoteDataSource: getIt<DriverRemoteDataSource>(),
    ),
  );

  // Services
  getIt.registerLazySingleton<LocationService>(() => LocationServiceImpl());

  // Managers
  getIt.registerFactory<MarkerManager>(() => MarkerManagerImpl());

  // ViewModels
  getIt.registerFactory<RideProvider>(
    () => RideProvider(
      locationService: getIt<LocationService>(),
      placesRepository: getIt<PlacesRepository>(),
      markerManager: getIt<MarkerManager>(),
      persistenceService: getIt<RidePersistenceService>(),
    ),
  );

  getIt.registerFactory<DriverProvider>(
    () => DriverProvider(
      repository: getIt<DriverRepository>(),
      locationService: getIt<LocationService>(),
      placesRepository: getIt<PlacesRepository>(),
    ),
  );
}
