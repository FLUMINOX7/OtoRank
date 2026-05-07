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
import '../widgets/mini_player_widget.dart';
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
  static const Color _phoenixRed = Color(0xFF7A0B16);
  static const Color _phoenixOrange = Color(0xFFC55A11);
  static const Color _phoenixPurple = Color(0xFF2E0F4F);

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
          ? widget.isRankedPlaylist
              ? [...state.rankedPlaylists.map((rp) => rp.playlist), ...state.playlists]
              : [...state.playlists, ...state.rankedPlaylists.map((rp) => rp.playlist)]
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

  void _playPlaylist(List<Song> songs) {
    if (songs.isEmpty) return;

    final shuffledSongs = List<Song>.from(songs)..shuffle();

    context.read<MusicPlayerBloc>().add(
          LoadPlaylistEvent(
            shuffledSongs,
            startIndex: 0,
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
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [_phoenixRed, _phoenixOrange, _phoenixPurple],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
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
          if (state is PlaylistsLoaded && widget.isRankedPlaylist) {
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

          return Stack(
            children: [
              Positioned.fill(
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.black,
                          _phoenixPurple.withOpacity(0.22),
                          _phoenixRed.withOpacity(0.18),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          top: -40,
                          left: -40,
                          child: Container(
                            width: 220,
                            height: 220,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _phoenixRed.withOpacity(0.18),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 120,
                          right: -30,
                          child: Container(
                            width: 200,
                            height: 200,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _phoenixOrange.withOpacity(0.14),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: -80,
                          left: 40,
                          child: Container(
                            width: 240,
                            height: 240,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _phoenixPurple.withOpacity(0.16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Column(
                children: [
                  // Playlist header
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [_phoenixRed, _phoenixOrange, _phoenixPurple],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          isRanked ? Icons.stars : Icons.playlist_play,
                          size: 48,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          playlist.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 6),
                        if (isRanked)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _phoenixPurple,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Rank $playlistRank',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        const SizedBox(height: 4),
                        Text(
                          '${songs.length} song${songs.length != 1 ? 's' : ''}',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
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
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  _phoenixRed.withOpacity(0.28),
                                  _phoenixOrange.withOpacity(0.2),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ElevatedButton.icon(
                              onPressed: songs.isEmpty ? null : () => _playPlaylist(songs),
                              icon: const Icon(Icons.shuffle),
                              label: const Text('Play'),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  _phoenixOrange.withOpacity(0.2),
                                  _phoenixPurple.withOpacity(0.3),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ElevatedButton.icon(
                              onPressed: () {
                                // Get all available songs from the music player state
                                final playlistState = context.read<PlaylistBloc>().state;
                                final availableSongs = playlistState.allSongs ?? <Song>[];

                                if (availableSongs.isNotEmpty) {
                                  _showAddSongsSheet(availableSongs, playlist);
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('No songs available yet. Please wait... (${availableSongs.length} songs loaded)'),
                                      duration: const Duration(seconds: 3),
                                    ),
                                  );
                                }
                              },
                              icon: const Icon(Icons.add),
                              label: const Text('Add Songs'),
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
                              return Card(
                                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                elevation: 2,
                                child: ListTile(
                                  leading: Hero(
                                    tag: 'playlist-song-icon-${song.id}',
                                    child: CircleAvatar(
                                      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                                      child: Icon(
                                        Icons.music_note,
                                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                                      ),
                                    ),
                                  ),
                                  title: Text(
                                    song.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  subtitle: song.artist != null
                                      ? Text(
                                          song.artist!,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: Colors.grey[400],
                                            fontSize: 12,
                                          ),
                                        )
                                      : null,
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (song.duration != null)
                                        Text(
                                          _formatDuration(song.duration!),
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 12,
                                          ),
                                        ),
                                      Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          borderRadius: BorderRadius.circular(24),
                                          onTap: () {
                                            context.read<MusicPlayerBloc>().add(
                                                  LoadPlaylistEvent(
                                                    songs,
                                                    startIndex: index,
                                                  ),
                                                );
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              Icons.play_arrow,
                                              color: Theme.of(context).colorScheme.primary,
                                              size: 24,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  onLongPress: () => _removeSong(song.id, playlist),
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
                  const MiniPlayerWidget(),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}
