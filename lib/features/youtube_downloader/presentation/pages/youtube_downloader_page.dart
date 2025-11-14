/// Page de téléchargement depuis YouTube
/// 
/// Permet de rechercher et télécharger des musiques depuis YouTube
/// et les convertir en MP3/M4A.
library;

import 'package:flutter/material.dart';
import '../../../../shared/widgets/app_drawer.dart';

/// Page pour télécharger de la musique depuis YouTube
class YouTubeDownloaderPage extends StatelessWidget {
  const YouTubeDownloaderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('YouTube Downloader'),
      ),
      drawer: const AppDrawer(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.download,
              size: 100,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 24),
            Text(
              'YouTube Downloader',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'Téléchargez vos musiques préférées depuis YouTube\net convertissez-les en MP3 ou M4A',
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              '📥 À venir bientôt...',
              style: TextStyle(
                fontSize: 18,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
