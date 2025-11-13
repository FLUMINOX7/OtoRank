/// Exceptions personnalisées de l'application
/// 
/// Ce fichier définit les exceptions levées au niveau de la couche Data
/// qui seront ensuite converties en Failures au niveau du Domain.
library;

/// Exception serveur
class ServerException implements Exception {
  final String message;
  
  const ServerException([this.message = 'Erreur serveur']);
  
  @override
  String toString() => 'ServerException: $message';
}

/// Exception de connexion réseau
class NetworkException implements Exception {
  final String message;
  
  const NetworkException([this.message = 'Pas de connexion réseau']);
  
  @override
  String toString() => 'NetworkException: $message';
}

/// Exception de cache
class CacheException implements Exception {
  final String message;
  
  const CacheException([this.message = 'Erreur de cache']);
  
  @override
  String toString() => 'CacheException: $message';
}

/// Exception d'authentification
class AuthenticationException implements Exception {
  final String message;
  
  const AuthenticationException([this.message = 'Authentification échouée']);
  
  @override
  String toString() => 'AuthenticationException: $message';
}

/// Exception non autorisée
class UnauthorizedException implements Exception {
  final String message;
  
  const UnauthorizedException([this.message = 'Accès non autorisé']);
  
  @override
  String toString() => 'UnauthorizedException: $message';
}
