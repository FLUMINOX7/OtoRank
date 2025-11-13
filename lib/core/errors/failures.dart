/// Classes d'erreur pour la gestion des échecs
/// 
/// Ce fichier définit les différents types d'erreurs qui peuvent survenir
/// dans l'application. Basé sur le principe de Clean Architecture.
library;

import 'package:equatable/equatable.dart';

/// Classe abstraite de base pour tous les échecs
abstract class Failure extends Equatable {
  final String message;
  
  const Failure(this.message);
  
  @override
  List<Object> get props => [message];
}

/// Erreur serveur (5xx)
class ServerFailure extends Failure {
  const ServerFailure([String message = 'Erreur serveur']) : super(message);
}

/// Erreur de connexion réseau
class NetworkFailure extends Failure {
  const NetworkFailure([String message = 'Erreur de connexion réseau']) 
      : super(message);
}

/// Erreur de cache
class CacheFailure extends Failure {
  const CacheFailure([String message = 'Erreur de cache']) : super(message);
}

/// Erreur de validation
class ValidationFailure extends Failure {
  const ValidationFailure([String message = 'Erreur de validation']) 
      : super(message);
}

/// Erreur d'authentification
class AuthenticationFailure extends Failure {
  const AuthenticationFailure([String message = 'Erreur d\'authentification']) 
      : super(message);
}

/// Erreur non autorisée (403)
class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure([String message = 'Accès non autorisé']) 
      : super(message);
}

/// Erreur générique
class GeneralFailure extends Failure {
  const GeneralFailure([String message = 'Une erreur est survenue']) 
      : super(message);
}
