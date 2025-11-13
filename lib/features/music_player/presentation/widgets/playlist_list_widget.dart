library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/playlist_bloc.dart';
import '../bloc/playlist_event.dart';
import '../bloc/playlist_state.dart';
import '../../domain/entities/ranked_playlist.dart';

/// Widget affichant la liste des playlists
class PlaylistListWidget extends StatelessWidget {
  const PlaylistListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlaylistBloc, PlaylistState>(
      builder: (context, state) {
        if (state is PlaylistLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (state is PlaylistError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(state.message),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    context.read<PlaylistBloc>().add(LoadAllPlaylistsEvent());
                  },
                  child: const Text('Réessayer'),
                ),
              ],
            ),
          );
        }

        if (state is PlaylistsLoaded) {
          if (state.playlists.isEmpty && state.rankedPlaylists.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.playlist_add, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('Aucune playlist'),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => _showCreatePlaylistDialog(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Créer une playlist'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<PlaylistBloc>().add(LoadAllPlaylistsEvent());
            },
            child: ListView(
              children: [
                // Playlists Ranked
                if (state.rankedPlaylists.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const Text(
                          'Playlists Classées',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () => _showCreateRankedPlaylistDialog(context),
                        ),
                      ],
                    ),
                  ),
                  ...state.rankedPlaylists.map((rp) => _buildRankedPlaylistTile(context, rp)),
                ],
                
                // Playlists Normales
                if (state.playlists.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const Text(
                          'Playlists',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () => _showCreatePlaylistDialog(context),
                        ),
                      ],
                    ),
                  ),
                  ...state.playlists.map((p) => _buildPlaylistTile(context, p)),
                ],
              ],
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildRankedPlaylistTile(BuildContext context, RankedPlaylist rankedPlaylist) {
    final playlist = rankedPlaylist.playlist;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getRankColor(rankedPlaylist.rank),
          child: Text(
            rankedPlaylist.rank,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(playlist.name),
        subtitle: Text('${playlist.songCount} chanson(s)'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          // TODO: Ouvrir la playlist
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Playlist: ${playlist.name}')),
          );
        },
      ),
    );
  }

  Widget _buildPlaylistTile(BuildContext context, playlist) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: const CircleAvatar(
          child: Icon(Icons.playlist_play),
        ),
        title: Text(playlist.name),
        subtitle: Text('${playlist.songCount} chanson(s)'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          // TODO: Ouvrir la playlist
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Playlist: ${playlist.name}')),
          );
        },
      ),
    );
  }

  Color _getRankColor(String rank) {
    switch (rank) {
      case 'S':
        return Colors.red;
      case 'A':
        return Colors.orange;
      case 'B':
        return Colors.yellow;
      case 'C':
        return Colors.green;
      case 'D':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  void _showCreatePlaylistDialog(BuildContext context) {
    final nameController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Nouvelle Playlist'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Nom de la playlist',
            hintText: 'Ma playlist',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                context.read<PlaylistBloc>().add(
                      CreatePlaylistEvent(name: nameController.text),
                    );
                Navigator.pop(dialogContext);
              }
            },
            child: const Text('Créer'),
          ),
        ],
      ),
    );
  }

  void _showCreateRankedPlaylistDialog(BuildContext context) {
    final nameController = TextEditingController();
    String selectedRank = 'S';
    
    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Nouvelle Playlist Classée'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nom de la playlist',
                  hintText: 'Ma playlist',
                ),
                autofocus: true,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedRank,
                decoration: const InputDecoration(
                  labelText: 'Rang',
                ),
                items: PlaylistRank.defaultRanks.keys.map((rank) {
                  return DropdownMenuItem(
                    value: rank,
                    child: Text(rank),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => selectedRank = value);
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty) {
                  context.read<PlaylistBloc>().add(
                        CreateRankedPlaylistEvent(
                          name: nameController.text,
                          rank: selectedRank,
                        ),
                      );
                  Navigator.pop(dialogContext);
                }
              },
              child: const Text('Créer'),
            ),
          ],
        ),
      ),
    );
  }
}
