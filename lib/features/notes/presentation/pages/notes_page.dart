/// Page de gestion des notes
/// 
/// Permet de créer et associer des notes (paroles, etc.) aux musiques.
library;

import 'package:flutter/material.dart';

/// Page pour gérer les notes associées aux musiques
class NotesPage extends StatelessWidget {
  const NotesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.note,
              size: 100,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 24),
            Text(
              'Notes',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'Créez des notes pour vos musiques\n(paroles, accords, commentaires...)',
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              '📝 À venir bientôt...',
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
