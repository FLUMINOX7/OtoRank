/// Configuration des routes de l'application
/// 
/// Ce fichier définit toutes les routes et la navigation
/// dans l'application.
library;

import 'package:flutter/material.dart';
import '../../features/home/presentation/pages/home_page.dart';

/// Classe gérant les routes de l'application
class AppRoutes {
  // Noms des routes
  static const String home = '/';
  static const String splash = '/splash';
  
  /// Map des routes de l'application
  static Map<String, WidgetBuilder> routes = {
    home: (context) => const HomePage(),
    // Ajoutez d'autres routes ici au fur et à mesure
  };
  
  /// Générateur de routes pour gérer les routes dynamiques
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    // Vous pouvez gérer ici les routes avec paramètres
    // Exemple:
    // if (settings.name == '/details') {
    //   final args = settings.arguments as DetailsArguments;
    //   return MaterialPageRoute(
    //     builder: (context) => DetailsPage(args: args),
    //   );
    // }
    
    return null; // Route non trouvée
  }
  
  /// Page d'erreur pour les routes non trouvées
  static Route<dynamic> onUnknownRoute(RouteSettings settings) {
    return MaterialPageRoute(
      builder: (context) => Scaffold(
        appBar: AppBar(
          title: const Text('Erreur'),
        ),
        body: Center(
          child: Text('Page non trouvée: ${settings.name}'),
        ),
      ),
    );
  }
  
  AppRoutes._(); // Constructeur privé
}
