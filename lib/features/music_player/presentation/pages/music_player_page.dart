/// Page principale du Music Player
/// 
/// Gère la lecture de musique, les playlists et le système de ranking.
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../di/music_player_injection.dart';
import '../bloc/music_player_bloc.dart';
import '../bloc/playlist_bloc.dart';
import '../bloc/playlist_event.dart';
import '../widgets/now_playing_widget.dart';
import '../widgets/song_list_widget.dart';
import '../widgets/playlist_list_widget.dart';

/// Page du lecteur de musique avec système de playlists ranked
class MusicPlayerPage extends StatefulWidget {
  const MusicPlayerPage({super.key});

  @override
  State<MusicPlayerPage> createState() => _MusicPlayerPageState();
}

class _MusicPlayerPageState extends State<MusicPlayerPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _permissionsGranted = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    // Demande les permissions nécessaires
    final status = await Permission.storage.request();
    if (status.isGranted) {
      setState(() {
        _permissionsGranted = true;
      });
      // Charge les playlists
      if (mounted) {
        context.read<PlaylistBloc>().add(LoadAllPlaylistsEvent());
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Permission de stockage requise pour lire les fichiers audio'),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<MusicPlayerBloc>()),
        BlocProvider(create: (_) => sl<PlaylistBloc>()),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Music Player'),
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(icon: Icon(Icons.music_note), text: 'Chansons'),
              Tab(icon: Icon(Icons.playlist_play), text: 'Playlists'),
            ],
          ),
        ),
        body: _permissionsGranted
            ? Column(
                children: [
                  // Player bar en haut
                  const NowPlayingWidget(),
                  const Divider(height: 1),
                  // Contenu des tabs
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: const [
                        SongListWidget(),
                        PlaylistListWidget(),
                      ],
                    ),
                  ),
                ],
              )
            : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.storage, size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    const Text(
                      'Permission de stockage requise',
                      style: TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _requestPermissions,
                      child: const Text('Autoriser'),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
