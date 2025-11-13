/// Configuration de l'injection de dépendances
/// 
/// Ce fichier configure GetIt pour l'injection de dépendances.
/// Toutes les dépendances de l'application sont enregistrées ici.
/// 
/// Note: Nécessite l'ajout du package get_it dans pubspec.yaml
/// TODO: Décommenter une fois get_it ajouté

// import 'package:get_it/get_it.dart';

// final sl = GetIt.instance; // Service Locator

/// Initialise toutes les dépendances
Future<void> initializeDependencies() async {
  // TODO: Enregistrer les dépendances ici
  
  // Exemple:
  // // Core
  // sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));
  
  // // Features - Home
  // // Bloc
  // sl.registerFactory(() => HomeBloc(sl()));
  
  // // Use cases
  // sl.registerLazySingleton(() => GetHomeData(sl()));
  
  // // Repository
  // sl.registerLazySingleton<HomeRepository>(
  //   () => HomeRepositoryImpl(
  //     remoteDataSource: sl(),
  //     localDataSource: sl(),
  //     networkInfo: sl(),
  //   ),
  // );
  
  // // Data sources
  // sl.registerLazySingleton<HomeRemoteDataSource>(
  //   () => HomeRemoteDataSourceImpl(client: sl()),
  // );
  
  // sl.registerLazySingleton<HomeLocalDataSource>(
  //   () => HomeLocalDataSourceImpl(sharedPreferences: sl()),
  // );
  
  // // External
  // final sharedPreferences = await SharedPreferences.getInstance();
  // sl.registerLazySingleton(() => sharedPreferences);
  // sl.registerLazySingleton(() => http.Client());
}
