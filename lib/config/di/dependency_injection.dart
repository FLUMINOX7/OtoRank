/// Configuration de l'injection de dépendances
/// 
/// Ce fichier configure GetIt pour l'injection de dépendances.
/// Toutes les dépendances de l'application sont enregistrées ici.
library;

import '../../features/music_player/di/music_player_injection.dart';

/// Initialise toutes les dépendances
Future<void> initializeDependencies() async {
  // Initialise les dépendances du music player
  await initMusicPlayerDependencies();
  
  // TODO: Ajouter les autres features ici
}
