/// Widget pour sélectionner des chansons à ajouter à une playlist
library;

import 'package:flutter/material.dart';
import '../../domain/entities/song.dart';

class AddSongsToPlaylistSheet extends StatefulWidget {
  final List<Song> availableSongs;
  final Function(List<Song>) onSongsSelected;

  const AddSongsToPlaylistSheet({
    super.key,
    required this.availableSongs,
    required this.onSongsSelected,
  });

  @override
  State<AddSongsToPlaylistSheet> createState() => _AddSongsToPlaylistSheetState();
}

class _AddSongsToPlaylistSheetState extends State<AddSongsToPlaylistSheet> {
  final Set<String> _selectedSongIds = {};
  String _searchQuery = '';

  List<Song> get _filteredSongs {
    if (_searchQuery.isEmpty) return widget.availableSongs;
    
    return widget.availableSongs.where((song) {
      final query = _searchQuery.toLowerCase();
      return song.title.toLowerCase().contains(query) ||
             (song.artist?.toLowerCase().contains(query) ?? false) ||
             (song.album?.toLowerCase().contains(query) ?? false);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final selectedSongs = widget.availableSongs
        .where((song) => _selectedSongIds.contains(song.id))
        .toList();

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[600],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    const Text(
                      'Select Songs',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    if (_selectedSongIds.isNotEmpty)
                      Text(
                        '${_selectedSongIds.length} selected',
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              // Search bar
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search songs...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
              ),

              // Song list
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: _filteredSongs.length,
                  itemBuilder: (context, index) {
                    final song = _filteredSongs[index];
                    final isSelected = _selectedSongIds.contains(song.id);

                    return CheckboxListTile(
                      value: isSelected,
                      onChanged: (selected) {
                        setState(() {
                          if (selected == true) {
                            _selectedSongIds.add(song.id);
                          } else {
                            _selectedSongIds.remove(song.id);
                          }
                        });
                      },
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
                      secondary: const CircleAvatar(
                        child: Icon(Icons.music_note),
                      ),
                    );
                  },
                ),
              ),

              // Add button
              if (_selectedSongIds.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          widget.onSongsSelected(selectedSongs);
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text(
                          'Add ${_selectedSongIds.length} song${_selectedSongIds.length != 1 ? 's' : ''}',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
