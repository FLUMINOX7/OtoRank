/// Implémentation du repository Home
/// 
/// Fait le lien entre la couche Domain et les sources de données.
/// Gère la logique de cache et de récupération des données.
library;

import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/home_entity.dart';
import '../../domain/repositories/home_repository.dart';
import '../datasources/home_local_datasource.dart';
import '../datasources/home_remote_datasource.dart';

/// Implémentation du HomeRepository
class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteDataSource remoteDataSource;
  final HomeLocalDataSource localDataSource;
  final NetworkInfo networkInfo;
  
  HomeRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });
  
  @override
  Future<Either<Failure, List<HomeEntity>>> getHomeData() async {
    // Vérifie la connexion réseau
    final isConnected = await networkInfo.isConnected;
    
    if (isConnected) {
      // Si connecté, récupère depuis l'API
      try {
        final remoteData = await remoteDataSource.getHomeData();
        // Cache les données récupérées
        await localDataSource.cacheHomeData(remoteData);
        return Right(remoteData);
      } on ServerException {
        return const Left(ServerFailure());
      } on NetworkException {
        return const Left(NetworkFailure());
      } catch (e) {
        return Left(GeneralFailure(e.toString()));
      }
    } else {
      // Si pas de connexion, récupère depuis le cache
      try {
        final cachedData = await localDataSource.getCachedHomeData();
        return Right(cachedData);
      } on CacheException {
        return const Left(CacheFailure('Aucune donnée en cache disponible'));
      } catch (e) {
        return Left(GeneralFailure(e.toString()));
      }
    }
  }
}
