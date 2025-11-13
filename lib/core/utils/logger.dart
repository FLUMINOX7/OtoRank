/// Utilitaire de logging pour l'application
/// 
/// Fournit des méthodes pour logger différents niveaux de messages
/// (debug, info, warning, error) de manière cohérente.
library;

import 'dart:developer' as developer;

/// Classe utilitaire pour le logging
class Logger {
  static const String _tag = 'OtoRank';
  
  /// Log un message de debug
  static void debug(String message, {String? tag}) {
    developer.log(
      message,
      name: tag ?? _tag,
      level: 500, // Debug level
    );
  }
  
  /// Log un message d'information
  static void info(String message, {String? tag}) {
    developer.log(
      message,
      name: tag ?? _tag,
      level: 800, // Info level
    );
  }
  
  /// Log un avertissement
  static void warning(String message, {String? tag}) {
    developer.log(
      message,
      name: tag ?? _tag,
      level: 900, // Warning level
    );
  }
  
  /// Log une erreur
  static void error(String message, {Object? error, StackTrace? stackTrace, String? tag}) {
    developer.log(
      message,
      name: tag ?? _tag,
      level: 1000, // Error level
      error: error,
      stackTrace: stackTrace,
    );
  }
  
  Logger._(); // Constructeur privé
}
