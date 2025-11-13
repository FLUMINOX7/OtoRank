/// Interface du repository Home
/// 
/// Définit le contrat que l'implémentation du repository doit respecter.
/// Cette interface se trouve dans la couche Domain et est implémentée
/// dans la couche Data.
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/home_entity.dart';

/// Repository abstrait pour la fonctionnalité Home
/// TODO: Adapter les méthodes selon vos besoins
abstract class HomeRepository {
  /// Récupère les données home
  /// 
  /// Retourne [Right(List<HomeEntity>)] en cas de succès
  /// Retourne [Left(Failure)] en cas d'erreur
  Future<Either<Failure, List<HomeEntity>>> getHomeData();
  
  // Ajoutez d'autres méthodes selon vos besoins
  // Future<Either<Failure, HomeEntity>> getHomeById(String id);
  // Future<Either<Failure, void>> saveHomeData(HomeEntity entity);
}
