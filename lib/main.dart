/// Point d'entrée de l'application OtoRank
/// 
/// Cette application suit l'architecture Clean Architecture
/// et les meilleures pratiques Flutter.
library;

import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'config/routes/app_routes.dart';
import 'config/di/dependency_injection.dart';
import 'core/utils/logger.dart';

/// Fonction principale de l'application
void main() async {
  // S'assure que les bindings Flutter sont initialisés
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialise les dépendances
  await initializeDependencies();
  
  Logger.info('Application OtoRank démarrée');
  
  // Lance l'application
  runApp(const OtoRankApp());
}

/// Widget racine de l'application
class OtoRankApp extends StatelessWidget {
  const OtoRankApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Configuration de l'application
      title: 'OtoRank',
      debugShowCheckedModeBanner: false,
      
      // Thème sombre uniquement (noir, violet ténèbre, rouge cramoisi)
      theme: AppTheme.darkTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      
      // Configuration de la navigation
      initialRoute: AppRoutes.home,
      routes: AppRoutes.routes,
      onGenerateRoute: AppRoutes.onGenerateRoute,
      onUnknownRoute: AppRoutes.onUnknownRoute,
    );
  }
}
