/// Constantes globales de l'application
/// 
/// Ce fichier contient toutes les constantes utilisées dans l'application
/// comme les URL d'API, les clés, les valeurs de configuration, etc.
class AppConstants {
  // Configuration de l'application
  static const String appName = 'OtoRank';
  static const String appVersion = '1.0.0';
  
  // URLs API (à définir selon vos besoins)
  static const String baseUrl = 'https://api.otorank.com';
  static const String apiVersion = 'v1';
  
  // Timeouts
  static const int connectionTimeout = 30000; // 30 secondes
  static const int receiveTimeout = 30000;
  
  // Clés de stockage local
  static const String userTokenKey = 'user_token';
  static const String userDataKey = 'user_data';
  
  // Configuration des assets
  static const String imagesPath = 'assets/images';
  static const String iconsPath = 'assets/icons';
  static const String fontsPath = 'assets/fonts';
  
  AppConstants._(); // Constructeur privé pour empêcher l'instanciation
}
