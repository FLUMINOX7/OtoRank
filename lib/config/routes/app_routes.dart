/// Configuration des routes de l'application
/// 
/// Ce fichier définit toutes les routes et la navigation
/// dans l'application.
library;

import 'package:flutter/material.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/music_player/presentation/pages/music_player_page.dart';
import '../../features/youtube_downloader/presentation/pages/youtube_downloader_page.dart';
import '../../features/notes/presentation/pages/notes_page.dart';
import '../../features/audio_editor/presentation/pages/audio_editor_page.dart';
import '../../features/tabata_timer/presentation/pages/tabata_timer_page.dart';

/// Classe gérant les routes de l'application
class AppRoutes {
  // Noms des routes
  static const String home = '/';
  static const String musicPlayer = '/music-player';
  static const String youtubeDownloader = '/youtube-downloader';
  static const String notes = '/notes';
  static const String audioEditor = '/audio-editor';
  static const String tabataTimer = '/tabata-timer';
  
  /// Map des routes de l'application
  static Map<String, WidgetBuilder> routes = {
    home: (context) => const HomePage(),
    musicPlayer: (context) => const MusicPlayerPage(),
    youtubeDownloader: (context) => const YouTubeDownloaderPage(),
    notes: (context) => const NotesPage(),
    audioEditor: (context) => const AudioEditorPage(),
    tabataTimer: (context) => const TabataTimerPage(),
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
