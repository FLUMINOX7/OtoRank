/// Page principale du Music Player
/// 
/// Gère la lecture de musique, les playlists et le système de ranking.
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../shared/widgets/app_drawer.dart';
import '../bloc/playlist_bloc.dart';
import '../bloc/playlist_event.dart';
import '../widgets/mini_player_widget.dart';
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
    // Sur Android 13+, on demande audio, sinon storage
    Permission permission = Permission.audio;
    
    // Vérifie d'abord si la permission est déjà accordée
    PermissionStatus status = await permission.status;
    
    if (status.isGranted) {
      setState(() {
        _permissionsGranted = true;
      });
      if (mounted) {
        context.read<PlaylistBloc>().add(LoadAllPlaylistsEvent());
      }
      return;
    }
    
    // Si pas encore accordée, demande la permission
    if (status.isDenied) {
      status = await permission.request();
    }
    
    // Si toujours refusée, vérifie si définitivement refusée
    if (status.isDenied || status.isPermanentlyDenied) {
      if (mounted) {
        _showPermissionDialog(status.isPermanentlyDenied);
      }
      return;
    }
    
    // Permission accordée
    if (status.isGranted) {
      setState(() {
        _permissionsGranted = true;
      });
      if (mounted) {
        context.read<PlaylistBloc>().add(LoadAllPlaylistsEvent());
      }
    }
  }
  
  void _showPermissionDialog(bool isPermanent) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permission Required'),
        content: Text(
          isPermanent
              ? 'Music access permission has been permanently denied. '
                'Please enable it manually in the app settings.'
              : 'This app needs access to your audio files to '
                'play your music.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              if (isPermanent) {
                openAppSettings();
              } else {
                _requestPermissions();
              }
            },
            child: Text(isPermanent ? 'Open Settings' : 'Retry'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Music Player'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.music_note), text: 'Songs'),
            Tab(icon: Icon(Icons.playlist_play), text: 'Playlists'),
          ],
        ),
      ),
      drawer: const AppDrawer(),
      body: _permissionsGranted
          ? Column(
              children: [
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
                // Mini player en bas (persistant)
                const MiniPlayerWidget(),
              ],
            )
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.storage, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'Storage permission required',
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _requestPermissions,
                    child: const Text('Allow'),
                  ),
                ],
              ),
            ),
    );
  }
}
