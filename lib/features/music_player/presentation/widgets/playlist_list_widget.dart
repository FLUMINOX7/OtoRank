library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/playlist.dart';
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
          final items = _buildPlaylistItems(state);

          return Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF1A0A2F),
                  Color(0xFF2A1039),
                  Color(0xFF3B1528),
                  Color(0xFF140A16),
                ],
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: -60,
                  left: -30,
                  child: Container(
                    width: 220,
                    height: 220,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          Color(0x66FF6A00),
                          Color(0x22FF2D55),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 40,
                  right: -50,
                  child: Container(
                    width: 180,
                    height: 180,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          Color(0x55FF3D00),
                          Color(0x22B43DFF),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                if (items.isEmpty)
                  Center(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 24),
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        color: const Color(0xAA120B1A),
                        border: Border.all(color: const Color(0x66FF6A00), width: 1.2),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 72,
                            height: 72,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [Color(0xFFFF5A00), Color(0xFFB432FF)],
                              ),
                            ),
                            child: const Icon(Icons.local_fire_department, color: Colors.white, size: 34),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'No playlists yet',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Create your first ranked or normal playlist.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white70),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton.icon(
                            onPressed: () => _showCreateMenu(context),
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: const Color(0xFFED4B00),
                              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            icon: const Icon(Icons.add),
                            label: const Text('Add Playlist'),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  RefreshIndicator(
                    onRefresh: () async {
                      context.read<PlaylistBloc>().add(LoadAllPlaylistsEvent());
                    },
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 90),
                      children: [
                        Row(
                          children: [
                            const Expanded(
                              child: Text(
                                'Playlists',
                                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
                              ),
                            ),
                            ElevatedButton.icon(
                              onPressed: () => _showCreateMenu(context),
                              icon: const Icon(Icons.add, size: 18),
                              label: const Text('Add'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFED4B00),
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        ...items.map((item) => _buildPlaylistItemTile(context, item)),
                      ],
                    ),
                  ),
              ],
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  List<_PlaylistItem> _buildPlaylistItems(PlaylistsLoaded state) {
    final items = [
      ...state.rankedPlaylists.map(
        (rankedPlaylist) => _PlaylistItem.ranked(
          rankedPlaylist,
          rankedPlaylist.rankOrder ?? PlaylistRank.getOrder(rankedPlaylist.rank),
        ),
      ),
      ...state.playlists.map((playlist) => _PlaylistItem.normal(playlist, 1000)),
    ];

    items.sort((left, right) => left.name.toLowerCase().compareTo(right.name.toLowerCase()));
    return items;
  }

  void _showCreateMenu(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Create playlist'),
        content: const Text('Choose the playlist type.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              _showCreateNormalPlaylistDialog(context);
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

  void _showCreateNormalPlaylistDialog(BuildContext context) {
    _showCreatePlaylistDialog(context);
  }

  Widget _buildPlaylistItemTile(BuildContext context, _PlaylistItem item) {
    final isRanked = item.isRanked || _isPseudoRanked(item.playlist);
    final effectivePlaylist = item.isRanked ? item.rankedPlaylist!.playlist : item.playlist!;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      color: Colors.transparent,
      elevation: 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _openPlaylist(context, effectivePlaylist.id, item.isRanked),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xCC341839),
                Color(0xCC4D1E2F),
                Color(0xCC6A280A),
              ],
            ),
            border: Border.all(
              color: isRanked ? const Color(0xAAFF6A00) : const Color(0x88A24BFF),
              width: 1.2,
            ),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            leading: Hero(
              tag: 'playlist-${effectivePlaylist.id}',
              child: CircleAvatar(
                backgroundColor: isRanked
                    ? _getRankColor(item.isRanked ? item.rankedPlaylist!.rank : _extractPseudoRank(effectivePlaylist.name))
                    : const Color(0xFF8A3BFF),
                child: isRanked
                    ? Text(
                        item.isRanked ? item.rankedPlaylist!.rank : _extractPseudoRank(effectivePlaylist.name),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.playlist_play, color: Colors.white),
              ),
            ),
            title: Text(
              _cleanPlaylistName(effectivePlaylist.name),
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            subtitle: Row(
              children: [
                Text(
                  '${effectivePlaylist.songCount} song${effectivePlaylist.songCount != 1 ? 's' : ''}',
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    color: isRanked ? const Color(0x33FF6A00) : const Color(0x338A3BFF),
                    border: Border.all(
                      color: isRanked ? const Color(0xAAFF6A00) : const Color(0x88A24BFF),
                    ),
                  ),
                  child: Text(
                    isRanked ? 'Ranked' : 'Normal',
                    style: TextStyle(
                      color: isRanked ? const Color(0xFFFFC08C) : const Color(0xFFD5B2FF),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            trailing: PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.white),
              onSelected: (value) {
                switch (value) {
                  case 'open':
                    _openPlaylist(context, effectivePlaylist.id, item.isRanked);
                    break;
                  case 'rename':
                    _showRenameDialog(context, effectivePlaylist);
                    break;
                  case 'change_rank':
                    if (item.isRanked) {
                      _showChangeRankDialog(context, effectivePlaylist, item.rankedPlaylist!.rank);
                    }
                    break;
                  case 'delete':
                    _showDeleteDialog(context, effectivePlaylist);
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
                if (item.isRanked)
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
      ),
    );
  }

  bool _isPseudoRanked(Playlist? playlist) {
    if (playlist == null) {
      return false;
    }
    return playlist.name.contains(' [RANK ');
  }

  String _extractPseudoRank(String playlistName) {
    final match = RegExp(r'\[RANK\s+([SABCD])\]').firstMatch(playlistName.toUpperCase());
    return match?.group(1) ?? 'A';
  }

  String _cleanPlaylistName(String playlistName) {
    return playlistName.replaceFirst(RegExp(r'\s*\[RANK\s+[SABCD]\]$', caseSensitive: false), '').trim();
  }

  void _openPlaylist(BuildContext context, String playlistId, bool isRanked) {
    Navigator.pushNamed(
      context,
      '/playlist-detail',
      arguments: {
        'playlistId': playlistId,
        'isRanked': isRanked,
      },
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
                items: PlaylistRank.creatableRanks.map((rank) {
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
                  // Temporary safe-mode: create as a normal playlist to avoid ranked type issues.
                  context.read<PlaylistBloc>().add(
                        CreatePlaylistEvent(name: '${nameController.text} [RANK $selectedRank]'),
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
                items: PlaylistRank.creatableRanks.map((rank) {
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

class _PlaylistItem {
  final Playlist? playlist;
  final RankedPlaylist? rankedPlaylist;
  final int sortOrder;

  _PlaylistItem._({this.playlist, this.rankedPlaylist, required this.sortOrder});

  factory _PlaylistItem.normal(Playlist playlist, int sortOrder) {
    return _PlaylistItem._(playlist: playlist, sortOrder: sortOrder);
  }

  factory _PlaylistItem.ranked(RankedPlaylist rankedPlaylist, int sortOrder) {
    return _PlaylistItem._(rankedPlaylist: rankedPlaylist, sortOrder: sortOrder);
  }

  bool get isRanked => rankedPlaylist != null;
  String get name => isRanked ? rankedPlaylist!.playlist.name : playlist!.name;
}
