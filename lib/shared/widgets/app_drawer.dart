/// Drawer de navigation principal
/// 
/// Menu latéral permettant de naviguer entre les différentes
/// fonctionnalités de l'application.
library;

import 'package:flutter/material.dart';

/// Widget du drawer de navigation principal
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.secondary,
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Icon(
                  Icons.music_note,
                  size: 64,
                  color: Colors.white,
                ),
                const SizedBox(height: 8),
                const Text(
                  'OtoRank',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Music & Fitness App',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          _buildDrawerItem(
            context,
            icon: Icons.home,
            title: 'Accueil',
            route: '/',
          ),
          const Divider(),
          _buildSectionHeader(context, 'Musique'),
          _buildDrawerItem(
            context,
            icon: Icons.music_note,
            title: 'Music Player',
            subtitle: 'Playlists ranked',
            route: '/music-player',
          ),
          _buildDrawerItem(
            context,
            icon: Icons.download,
            title: 'YouTube Downloader',
            subtitle: 'Télécharger MP3/M4A',
            route: '/youtube-downloader',
          ),
          _buildDrawerItem(
            context,
            icon: Icons.note,
            title: 'Notes',
            subtitle: 'Paroles & notes',
            route: '/notes',
          ),
          _buildDrawerItem(
            context,
            icon: Icons.edit,
            title: 'Audio Editor',
            subtitle: 'Tronquer audio',
            route: '/audio-editor',
          ),
          const Divider(),
          _buildSectionHeader(context, 'Fitness'),
          _buildDrawerItem(
            context,
            icon: Icons.timer,
            title: 'Tabata Timer',
            subtitle: 'Chronomètre fitness',
            route: '/tabata-timer',
          ),
        ],
      ),
    );
  }

  /// Construit un header de section dans le drawer
  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  /// Construit un élément de menu dans le drawer
  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    required String route,
  }) {
    final currentRoute = ModalRoute.of(context)?.settings.name;
    final isSelected = currentRoute == route;

    return ListTile(
      leading: Icon(
        icon,
        color: isSelected
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).iconTheme.color,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : null,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            )
          : null,
      selected: isSelected,
      selectedTileColor:
          Theme.of(context).colorScheme.primary.withOpacity(0.1),
      onTap: () {
        Navigator.pop(context); // Ferme le drawer
        if (!isSelected) {
          Navigator.pushNamed(context, route);
        }
      },
    );
  }
}
