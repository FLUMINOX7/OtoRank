/// Page d'accueil de l'application
/// 
/// Première page affichée au lancement de l'application.
import 'package:flutter/material.dart';

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
                'Votre application mobile professionnelle',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 48),
            
            // Bouton d'action exemple
            ElevatedButton.icon(
              onPressed: () {
                // TODO: Implémenter l'action
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Fonctionnalité à implémenter'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              icon: const Icon(Icons.play_arrow),
              label: const Text('Commencer'),
            ),
          ],
        ),
      ),
    );
  }
}
