library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:otorank/core/errors/failures.dart';
import '../../domain/usecases/get_local_songs.dart';
import '../../domain/entities/song.dart';
import '../../di/music_player_injection.dart';
import '../bloc/music_player_bloc.dart';
import '../bloc/music_player_event.dart';

/// Widget displaying the list of local songs
class SongListWidget extends StatefulWidget {
  const SongListWidget({super.key});

  @override
  State<SongListWidget> createState() => _SongListWidgetState();
}

class _SongListWidgetState extends State<SongListWidget> {
  List<Song>? _songs;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadSongs();
  }

  Future<void> _loadSongs() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final getLocalSongs = sl<GetLocalSongs>();
    final result = await getLocalSongs();

    result.fold(
      (failure) {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _error = failure.message;
          });
        }
      },
      (songs) {
        if (mounted) {
          setState(() {
            _songs = songs;
            _isLoading = false;
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(_error!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadSongs,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_songs == null || _songs!.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.music_off, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('No songs found'),
            const SizedBox(height: 8),
            const Text(
              'Place your audio files in Music/ folder',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadSongs,
              child: const Text('Refresh'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadSongs,
      child: Column(
        children: [
          // Song counter
          Container(
            padding: const EdgeInsets.all(8),
            alignment: Alignment.centerLeft,
            child: Text(
              '${_songs!.length} song${_songs!.length != 1 ? 's' : ''}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[400],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          // Song list
          Expanded(
            child: ListView.builder(
              itemCount: _songs!.length,
              itemBuilder: (context, index) {
                final song = _songs![index];
                return ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.music_note),
                  ),
                  title: Text(song.title),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.info_outline),
                        onPressed: () {
                          // TODO: Show song details dialog
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.play_arrow),
                        onPressed: () {
                          // Load whole playlist and play selected song
                          context.read<MusicPlayerBloc>().add(
                                LoadPlaylistEvent(_songs!, startIndex: index),
                              );
                        },
                      ),
                    ],
                  ),
                  onTap: () {
                    // Load whole playlist and play selected song
                    context.read<MusicPlayerBloc>().add(
                          LoadPlaylistEvent(_songs!, startIndex: index),
                        );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
