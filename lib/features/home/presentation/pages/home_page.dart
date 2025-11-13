/// Page d'accueil de l'application
/// 
/// Première page affichée au lancement de l'application.
library;

import 'package:flutter/material.dart';
import '../../../../shared/widgets/app_drawer.dart';

/// Page d'accueil
class HomePage extends StatelessWidget {
  const HomePage({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OtoRank'),
        centerTitle: true,
      ),
      drawer: const AppDrawer(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo ou icône de l'application
            Icon(
              Icons.star,
              size: 100,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 24),
            
            // Titre de bienvenue
            Text(
              'Bienvenue sur OtoRank',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            
            // Description
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'Music Player & Fitness App',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 48),
            
            // Boutons d'action rapide
            Wrap(
              spacing: 16,
              runSpacing: 16,
              alignment: WrapAlignment.center,
              children: [
                _buildQuickAccessButton(
                  context,
                  icon: Icons.music_note,
                  label: 'Music Player',
                  route: '/music-player',
                ),
                _buildQuickAccessButton(
                  context,
                  icon: Icons.download,
                  label: 'YouTube',
                  route: '/youtube-downloader',
                ),
                _buildQuickAccessButton(
                  context,
                  icon: Icons.timer,
                  label: 'Tabata',
                  route: '/tabata-timer',
                ),
              ],
            ),
            const SizedBox(height: 32),
            Text(
              '👈 Ouvrez le menu pour plus d\'options',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontStyle: FontStyle.italic,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  /// Construit un bouton d'accès rapide
  Widget _buildQuickAccessButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String route,
  }) {
    return ElevatedButton(
      onPressed: () => Navigator.pushNamed(context, route),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 32),
          const SizedBox(height: 8),
          Text(label),
        ],
      ),
    );
  }
}
