/// Navigation drawer
/// 
/// Side menu to navigate between different
/// features of the application.
library;

import 'package:flutter/material.dart';

/// Main navigation drawer widget
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            margin: EdgeInsets.zero,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
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
                  size: 56,
                  color: Colors.white,
                ),
                const SizedBox(height: 6),
                const Text(
                  '音ランク',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Your Music, Ranked',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          _buildDrawerItem(
            context,
            icon: Icons.home,
            title: 'Home',
            route: '/',
          ),
          const Divider(),
          _buildSectionHeader(context, 'Features'),
          _buildDrawerItem(
            context,
            icon: Icons.library_music,
            title: 'Music Player',
            subtitle: 'Ranked playlists',
            route: '/music-player',
          ),
          _buildDrawerItem(
            context,
            icon: Icons.download_rounded,
            title: 'YouTube Converter',
            subtitle: 'Convert YouTube audio',
            route: '/youtube-downloader',
          ),
          _buildDrawerItem(
            context,
            icon: Icons.audiotrack,
            title: 'Audio Editor',
            subtitle: 'Trim audio files',
            route: '/audio-editor',
          ),
          _buildDrawerItem(
            context,
            icon: Icons.note_alt_outlined,
            title: 'Notes',
            subtitle: 'Lyrics & notes',
            route: '/notes',
          ),
          _buildDrawerItem(
            context,
            icon: Icons.timer,
            title: 'Tabata Timer',
            subtitle: 'Workout timer',
            route: '/tabata-timer',
          ),
        ],
      ),
    );
  }

  /// Builds a section header in the drawer
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

  /// Builds a menu item in the drawer
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
        Navigator.pop(context); // Close the drawer
        if (!isSelected) {
          Navigator.pushNamed(context, route);
        }
      },
    );
  }
}
