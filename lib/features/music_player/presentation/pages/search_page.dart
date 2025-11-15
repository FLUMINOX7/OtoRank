library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/song.dart';
import '../../domain/usecases/get_local_songs.dart';
import '../../di/music_player_injection.dart';
import '../bloc/music_player_bloc.dart';
import '../bloc/music_player_event.dart';

/// Page de recherche de chansons
class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _filterType = 'all'; // all, artist, album, title
  
  List<Song>? _allSongs;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadSongs();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
            _allSongs = songs;
            _isLoading = false;
          });
        }
      },
    );
  }

  List<Song> _filterSongs(List<Song> songs) {
    if (_searchQuery.isEmpty) {
      return songs;
    }

    final query = _searchQuery.toLowerCase();

    return songs.where((song) {
      switch (_filterType) {
        case 'artist':
          return song.artist?.toLowerCase().contains(query) ?? false;
        case 'title':
          return song.title.toLowerCase().contains(query);
        case 'all':
        default:
          return song.title.toLowerCase().contains(query) ||
              (song.artist?.toLowerCase().contains(query) ?? false);
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Search songs...',
            hintStyle: TextStyle(color: Colors.white70),
            border: InputBorder.none,
            icon: Icon(Icons.search, color: Colors.white),
          ),
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
            });
          },
        ),
        actions: [
          if (_searchQuery.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                setState(() {
                  _searchController.clear();
                  _searchQuery = '';
                });
              },
            ),
        ],
      ),
      body: Column(
        children: [
          // Filtres
          Container(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                const Text('Filter: '),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('All'),
                  selected: _filterType == 'all',
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _filterType = 'all');
                    }
                  },
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Title'),
                  selected: _filterType == 'title',
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _filterType = 'title');
                    }
                  },
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Artist'),
                  selected: _filterType == 'artist',
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _filterType = 'artist');
                    }
                  },
                ),
              ],
            ),
          ),
          
          // Résultats
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(
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
                      )
                    : _buildSongsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSongsList() {
    if (_allSongs == null || _allSongs!.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.music_off, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No songs found',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    final filteredSongs = _filterSongs(_allSongs!);

    if (_searchQuery.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Search for songs',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              '${_allSongs!.length} songs available',
              style: TextStyle(color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    if (filteredSongs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.music_off, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No results found',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Try a different search term',
              style: TextStyle(color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: filteredSongs.length,
      itemBuilder: (context, index) {
        final song = filteredSongs[index];
        
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            child: const Icon(Icons.music_note),
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
                )
              : null,
          trailing: IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              // TODO: Show options menu
            },
          ),
          onTap: () {
            // Play this song with all filtered songs as queue
            context.read<MusicPlayerBloc>().add(
              LoadPlaylistEvent(filteredSongs, startIndex: index),
            );
            Navigator.pop(context);
          },
        );
      },
    );
  }
}
