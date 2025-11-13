library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/usecases/get_local_songs.dart';
import '../../domain/entities/song.dart';
import '../../di/music_player_injection.dart';
import '../bloc/music_player_bloc.dart';
import '../bloc/music_player_event.dart';

/// Widget affichant la liste des chansons locales
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
        setState(() {
          _isLoading = false;
          _error = failure.message;
        });
      },
      (songs) {
        setState(() {
          _songs = songs;
          _isLoading = false;
        });
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
              child: const Text('Réessayer'),
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
            const Text('Aucune chanson trouvée'),
            const SizedBox(height: 8),
            const Text(
              'Placez vos fichiers audio dans Music/',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadSongs,
              child: const Text('Actualiser'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadSongs,
      child: ListView.builder(
        itemCount: _songs!.length,
        itemBuilder: (context, index) {
          final song = _songs![index];
          return ListTile(
            leading: const CircleAvatar(
              child: Icon(Icons.music_note),
            ),
            title: Text(song.title),
            subtitle: Text(song.artist ?? 'Artiste inconnu'),
            trailing: IconButton(
              icon: const Icon(Icons.play_arrow),
              onPressed: () {
                // Charge toute la liste et joue la chanson sélectionnée
                context.read<MusicPlayerBloc>().add(
                      LoadPlaylistEvent(_songs!, startIndex: index),
                    );
              },
            ),
            onTap: () {
              // Joue juste cette chanson
              context.read<MusicPlayerBloc>().add(PlaySongEvent(song));
            },
          );
        },
      ),
    );
  }
}
