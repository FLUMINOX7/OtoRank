/// Use case pour récupérer les données Home
/// 
/// Les use cases contiennent la logique métier de l'application.
/// Chaque use case effectue une seule action.
library;

import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/home_entity.dart';
import '../repositories/home_repository.dart';

/// Use case pour récupérer les données home
class GetHomeDataUseCase {
  final HomeRepository repository;
  
  GetHomeDataUseCase(this.repository);
  
  /// Exécute le use case
  /// 
  /// Retourne [Right(List<HomeEntity>)] en cas de succès
  /// Retourne [Left(Failure)] en cas d'erreur
  Future<Either<Failure, List<HomeEntity>>> call() async {
    return await repository.getHomeData();
  }
}

/// Classe de base pour les use cases avec paramètres
/// 
/// Exemple d'utilisation:
/// ```dart
/// class GetHomeById extends UseCase<HomeEntity, String> {
///   final HomeRepository repository;
///   
///   GetHomeById(this.repository);
///   
///   @override
///   Future<Either<Failure, HomeEntity>> call(String params) async {
///     return await repository.getHomeById(params);
///   }
/// }
/// ```
abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

/// Classe pour les use cases sans paramètres
class NoParams {
  const NoParams();
}
