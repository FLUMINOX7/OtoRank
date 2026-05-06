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
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (state is PlaylistsLoaded) {
          // If there are no playlists at all, show a single button to create one
          if (state.playlists.isEmpty && state.rankedPlaylists.isEmpty) {
            return Center(
              child: ElevatedButton.icon(
                onPressed: () => _showInitialCreateDialog(context),
                icon: const Icon(Icons.add),
                label: const Text('Create Playlist'),
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14)),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<PlaylistBloc>().add(LoadAllPlaylistsEvent());
            },
            child: ListView(
              children: [
                // Section Ranked Playlists (toujours affichée)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber),
                      const SizedBox(width: 8),
                      const Text(
                        'Ranked Playlists',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      ElevatedButton.icon(
                        onPressed: () => _showCreateRankedPlaylistDialog(context),
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('New'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                      ),
                    ],
                  ),
                ),
                if (state.rankedPlaylists.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Center(
                          child: Text(
                            'No ranked playlists yet',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ),
                      ),
                    ),
                  )
                else
                  ...state.rankedPlaylists.map((rp) => _buildRankedPlaylistTile(context, rp)),
                
                const SizedBox(height: 24),
                
                // Section Playlists Normales (toujours affichée)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(Icons.playlist_play),
                      const SizedBox(width: 8),
                      const Text(
                        'Normal Playlists',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      ElevatedButton.icon(
                        onPressed: () => _showCreatePlaylistDialog(context),
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('New'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                      ),
                    ],
                  ),
                ),
                if (state.playlists.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Center(
                          child: Text(
                            'No normal playlists yet',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ),
                      ),
                    ),
                  )
                else
                  ...state.playlists.map((p) => _buildPlaylistTile(context, p)),
                
                const SizedBox(height: 80), // Espace pour le mini-player
              ],
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  void _showInitialCreateDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Create Playlist'),
        content: const Text('Create a normal playlist or a ranked playlist?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              _showCreatePlaylistDialog(context);
            },
            child: const Text('Normal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              _showCreateRankedPlaylistDialog(context);
            },
            child: const Text('Ranked'),
          ),
        ],
      ),
    );
  }

  Widget _buildRankedPlaylistTile(BuildContext context, RankedPlaylist rankedPlaylist) {
    final playlist = rankedPlaylist.playlist;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: 3,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.pushNamed(
            context,
            '/playlist-detail',
            arguments: {
              'playlistId': playlist.id,
              'isRanked': true,
            },
          );
        },
        child: ListTile(
          leading: Hero(
            tag: 'playlist-${playlist.id}',
            child: CircleAvatar(
              backgroundColor: _getRankColor(rankedPlaylist.rank),
              child: Text(
                rankedPlaylist.rank,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          title: Text(
            playlist.name,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Text('${playlist.songCount} song${playlist.songCount != 1 ? 's' : ''}'),
          trailing: PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              switch (value) {
                case 'open':
                  Navigator.pushNamed(
                    context,
                    '/playlist-detail',
                    arguments: {
                      'playlistId': playlist.id,
                      'isRanked': true,
                    },
                  );
                  break;
                case 'rename':
                  _showRenameDialog(context, playlist);
                  break;
                case 'change_rank':
                  _showChangeRankDialog(context, playlist, rankedPlaylist.rank);
                  break;
                case 'delete':
                  _showDeleteDialog(context, playlist);
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'open',
                child: Row(
                  children: [
                    Icon(Icons.open_in_new),
                    SizedBox(width: 8),
                    Text('Open'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'rename',
                child: Row(
                  children: [
                    Icon(Icons.edit),
                    SizedBox(width: 8),
                    Text('Rename'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'change_rank',
                child: Row(
                  children: [
                    Icon(Icons.star),
                    SizedBox(width: 8),
                    Text('Change Rank'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Delete', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaylistTile(BuildContext context, playlist) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.pushNamed(
            context,
            '/playlist-detail',
            arguments: {
              'playlistId': playlist.id,
              'isRanked': false,
            },
          );
        },
        child: ListTile(
          leading: Hero(
            tag: 'playlist-${playlist.id}',
            child: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
              child: Icon(
                Icons.playlist_play,
                color: Theme.of(context).colorScheme.onSecondaryContainer,
              ),
            ),
          ),
          title: Text(
            playlist.name,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Text('${playlist.songCount} song${playlist.songCount != 1 ? 's' : ''}'),
          trailing: PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              switch (value) {
                case 'open':
                  Navigator.pushNamed(
                    context,
                    '/playlist-detail',
                    arguments: {
                      'playlistId': playlist.id,
                      'isRanked': false,
                    },
                  );
                  break;
                case 'rename':
                  _showRenameDialog(context, playlist);
                  break;
                case 'delete':
                  _showDeleteDialog(context, playlist);
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'open',
                child: Row(
                  children: [
                    Icon(Icons.open_in_new),
                    SizedBox(width: 8),
                    Text('Open'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'rename',
                child: Row(
                  children: [
                    Icon(Icons.edit),
                    SizedBox(width: 8),
                    Text('Rename'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Delete', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ),
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
        title: const Text('New Playlist'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Playlist name',
            hintText: 'My playlist',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
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
            child: const Text('Create'),
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
          title: const Text('New Ranked Playlist'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Playlist name',
                  hintText: 'My playlist',
                ),
                autofocus: true,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedRank,
                decoration: const InputDecoration(
                  labelText: 'Rank',
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
              child: const Text('Cancel'),
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
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }

  void _showRenameDialog(BuildContext context, dynamic playlist) {
    final nameController = TextEditingController(text: playlist.name);
    
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Rename Playlist'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Playlist Name',
            hintText: 'My playlist',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty && nameController.text != playlist.name) {
                // Update playlist name
                final updatedPlaylist = playlist.copyWith(
                  name: nameController.text,
                  modifiedDate: DateTime.now(),
                );
                
                context.read<PlaylistBloc>().musicRepository.updatePlaylist(updatedPlaylist).then((result) {
                  result.fold(
                    (failure) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: ${failure.message}')),
                      );
                    },
                    (_) {
                      context.read<PlaylistBloc>().add(LoadAllPlaylistsEvent());
                    },
                  );
                });
                Navigator.pop(dialogContext);
              }
            },
            child: const Text('Rename'),
          ),
        ],
      ),
    );
  }

  void _showChangeRankDialog(BuildContext context, dynamic playlist, String currentRank) {
    String selectedRank = currentRank;
    
    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Change Rank'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Playlist: ${playlist.name}'),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedRank,
                decoration: const InputDecoration(
                  labelText: 'Rank',
                ),
                items: PlaylistRank.defaultRanks.keys.map((rank) {
                  return DropdownMenuItem(
                    value: rank,
                    child: Row(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            color: _getRankColor(rank),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              rank,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                        Text(rank),
                      ],
                    ),
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
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (selectedRank != currentRank) {
                  context.read<PlaylistBloc>().add(
                        UpdatePlaylistRankEvent(
                          playlistId: playlist.id,
                          newRank: selectedRank,
                        ),
                      );
                }
                Navigator.pop(dialogContext);
              },
              child: const Text('Change'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, dynamic playlist) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Playlist'),
        content: Text('Are you sure you want to delete "${playlist.name}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () {
              context.read<PlaylistBloc>().add(DeletePlaylistEvent(playlist.id));
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Playlist "${playlist.name}" deleted')),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
