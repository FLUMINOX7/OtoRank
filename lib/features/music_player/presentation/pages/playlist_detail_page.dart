/// Page de détails d'une playlist avec gestion des chansons
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/playlist.dart';
import '../../domain/entities/ranked_playlist.dart';
import '../../domain/entities/song.dart';
import '../bloc/music_player_bloc.dart';
import '../bloc/music_player_event.dart';
import '../bloc/playlist_bloc.dart';
import '../bloc/playlist_event.dart';
import '../bloc/playlist_state.dart';
import 'add_songs_to_playlist_sheet.dart';

class PlaylistDetailPage extends StatefulWidget {
  final String playlistId;
  final bool isRankedPlaylist;

  const PlaylistDetailPage({
    super.key,
    required this.playlistId,
    this.isRankedPlaylist = false,
  });

  @override
  State<PlaylistDetailPage> createState() => _PlaylistDetailPageState();
}

class _PlaylistDetailPageState extends State<PlaylistDetailPage> {
  @override
  void initState() {
    super.initState();
    _loadPlaylist();
  }

  void _loadPlaylist() {
    context.read<PlaylistBloc>().add(LoadAllPlaylistsEvent());
  }

  Playlist? _findPlaylist(PlaylistState state) {
    if (state is PlaylistLoaded || state is PlaylistsLoaded) {
      final playlists = state is PlaylistsLoaded 
          ? [...state.playlists, ...state.rankedPlaylists.map((rp) => rp.playlist)]
          : (state as PlaylistLoaded).playlists;

      return playlists.firstWhere(
        (p) => p.id == widget.playlistId,
        orElse: () => Playlist(
          id: '',
          name: '',
          songs: [],
          createdDate: DateTime.now(),
        ),
      );
    }
    return null;
  }

  void _showAddSongsSheet(List<Song> availableSongs, Playlist playlist) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddSongsToPlaylistSheet(
        availableSongs: availableSongs,
        onSongsSelected: (selectedSongs) {
          context.read<PlaylistBloc>().add(
                AddSongsToPlaylistEvent(
                  playlistId: playlist.id,
                  songs: selectedSongs,
                ),
              );
        },
      ),
    );
  }

  void _removeSong(String songId, Playlist playlist) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Song'),
        content: const Text('Are you sure you want to remove this song from the playlist?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<PlaylistBloc>().add(
                    RemoveSongFromPlaylistEvent(
                      playlistId: playlist.id,
                      songId: songId,
                    ),
                  );
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Playlist Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<PlaylistBloc>().add(LoadAllPlaylistsEvent());
            },
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: BlocBuilder<PlaylistBloc, PlaylistState>(
        builder: (context, state) {
          if (state is PlaylistLoading) {
            return const Center(child: CircularProgressIndicator());
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
                    onPressed: _loadPlaylist,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final playlist = _findPlaylist(state);

          if (playlist == null || playlist.id.isEmpty) {
            return const Center(
              child: Text('Playlist not found'),
            );
          }

          // Check if this is a ranked playlist
          String? playlistRank;
          if (state is PlaylistsLoaded) {
            final rankedPlaylist = state.rankedPlaylists
                .firstWhere(
                  (rp) => rp.playlist.id == playlist.id,
                  orElse: () => RankedPlaylist(
                    playlist: playlist,
                    rank: '',
                  ),
                );
            if (rankedPlaylist.rank.isNotEmpty) {
              playlistRank = rankedPlaylist.rank;
            }
          }

          final isRanked = playlistRank != null;
          final songs = playlist.songs;

          return Column(
            children: [
              // Playlist header
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).primaryColor,
                      Theme.of(context).primaryColor.withOpacity(0.6),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      isRanked ? Icons.stars : Icons.playlist_play,
                      size: 64,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      playlist.name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    if (isRanked && playlistRank != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _getRankColor(playlistRank),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Rank $playlistRank',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    const SizedBox(height: 8),
                    Text(
                      '${songs.length} song${songs.length != 1 ? 's' : ''}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

              // Action buttons
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: songs.isEmpty
                            ? null
                            : () {
                                context.read<MusicPlayerBloc>().add(
                                      LoadPlaylistEvent(
                                        songs,
                                        startIndex: 0,
                                      ),
                                    );
                              },
                        icon: const Icon(Icons.play_arrow),
                        label: const Text('Play All'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // Get all available songs from the music player state
                          final playlistState = context.read<PlaylistBloc>().state;
                          
                          print('DEBUG: playlistState type: ${playlistState.runtimeType}');
                          print('DEBUG: allSongs: ${playlistState.allSongs?.length ?? 0} songs');
                          
                          if (playlistState.allSongs != null && playlistState.allSongs!.isNotEmpty) {
                            _showAddSongsSheet(playlistState.allSongs!, playlist);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('No songs available yet. Please wait... (${playlistState.allSongs?.length ?? 0} songs loaded)'),
                                duration: const Duration(seconds: 3),
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Add Songs'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Song list
              Expanded(
                child: songs.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.music_off,
                              size: 64,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'No songs in this playlist',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: songs.length,
                        itemBuilder: (context, index) {
                          final song = songs[index];

                          return Dismissible(
                            key: Key(song.id),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              color: Colors.red,
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              child: const Icon(
                                Icons.delete,
                                color: Colors.white,
                              ),
                            ),
                            confirmDismiss: (direction) async {
                              _removeSong(song.id, playlist);
                              return false; // Don't auto-dismiss, wait for bloc update
                            },
                            child: ListTile(
                              leading: CircleAvatar(
                                child: Text('${index + 1}'),
                              ),
                              title: Text(song.title),
                              subtitle: song.artist != null
                                  ? Text(song.artist!)
                                  : null,
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (song.duration != null)
                                    Text(
                                      _formatDuration(song.duration!),
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  IconButton(
                                    icon: const Icon(Icons.play_arrow),
                                    onPressed: () {
                                      context.read<MusicPlayerBloc>().add(
                                            LoadPlaylistEvent(
                                              songs,
                                              startIndex: index,
                                            ),
                                          );
                                    },
                                  ),
                                ],
                              ),
                              onTap: () {
                                context.read<MusicPlayerBloc>().add(
                                      LoadPlaylistEvent(
                                        songs,
                                        startIndex: index,
                                      ),
                                    );
                              },
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Color _getRankColor(String rank) {
    switch (rank.toUpperCase()) {
      case 'S':
        return Colors.purple;
      case 'A':
        return Colors.red;
      case 'B':
        return Colors.orange;
      case 'C':
        return Colors.blue;
      case 'D':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}
