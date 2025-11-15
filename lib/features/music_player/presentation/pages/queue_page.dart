library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/music_player_bloc.dart';
import '../bloc/music_player_event.dart';
import '../bloc/music_player_state.dart';

/// Page affichant la queue de lecture avec drag-to-reorder
class QueuePage extends StatelessWidget {
  const QueuePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Load current queue on page open
    context.read<MusicPlayerBloc>().add(GetCurrentQueueEvent());
    
    return BlocListener<MusicPlayerBloc, MusicPlayerState>(
      listener: (context, state) {
        // Auto-close page when queue is cleared
        if (state is MusicPlayerStopped || state.queue.isEmpty) {
          // Add a small delay to show the snackbar
          Future.delayed(const Duration(milliseconds: 300), () {
            if (context.mounted) {
              Navigator.pop(context);
            }
          });
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Queue'),
          actions: [
            BlocBuilder<MusicPlayerBloc, MusicPlayerState>(
              builder: (context, state) {
                final hasQueue = state.queue.isNotEmpty;
                
                return IconButton(
                  icon: const Icon(Icons.clear_all),
                  tooltip: 'Clear queue',
                  onPressed: hasQueue
                      ? () {
                          showDialog(
                            context: context,
                            builder: (dialogContext) => AlertDialog(
                              title: const Text('Clear Queue'),
                              content: const Text('Are you sure you want to clear the entire queue?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(dialogContext),
                                  child: const Text('Cancel'),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    context.read<MusicPlayerBloc>().add(ClearQueueEvent());
                                    Navigator.pop(dialogContext);
                                    
                                    // Show confirmation snackbar
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Queue cleared'),
                                        duration: Duration(milliseconds: 500),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                  ),
                                  child: const Text('Clear'),
                                ),
                              ],
                            ),
                          );
                        }
                      : null,
                );
              },
            ),
          ],
        ),
        body: BlocBuilder<MusicPlayerBloc, MusicPlayerState>(
        builder: (context, state) {
          final currentSong = state.currentSong;
          final queue = state.queue;
          
          if (queue.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.queue_music, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Queue is empty',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Play a song to start',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          // Find current song index
          final currentIndex = currentSong != null 
              ? queue.indexWhere((s) => s.id == currentSong.id)
              : -1;

          return Column(
            children: [
              // Current song header
              if (currentIndex >= 0)
                Container(
                  color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(Icons.play_arrow, color: Colors.green),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Now Playing',
                              style: TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                            Text(
                              queue[currentIndex].title,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (queue[currentIndex].artist != null)
                              Text(
                                queue[currentIndex].artist!,
                                style: const TextStyle(fontSize: 14, color: Colors.grey),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              
              // Queue list
              Expanded(
                child: queue.length > 1
                    ? ReorderableListView.builder(
                        onReorder: (oldIndex, newIndex) {
                          // Adjust for header if present
                          context.read<MusicPlayerBloc>().add(
                            ReorderQueueEvent(oldIndex, newIndex),
                          );
                        },
                        itemCount: queue.length,
                        buildDefaultDragHandles: false,
                        itemBuilder: (context, index) {
                          final song = queue[index];
                          final isCurrent = index == currentIndex;
                          
                          return Dismissible(
                            key: ValueKey(song.id),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              color: Colors.red,
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 16),
                              child: const Icon(Icons.delete, color: Colors.white),
                            ),
                            confirmDismiss: (direction) async {
                              if (isCurrent) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Cannot remove currently playing song'),
                                  ),
                                );
                                return false;
                              }
                              return true;
                            },
                            onDismissed: (direction) {
                              context.read<MusicPlayerBloc>().add(
                                RemoveFromQueueEvent(index),
                              );
                            },
                            child: ListTile(
                              leading: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (!isCurrent)
                                    ReorderableDragStartListener(
                                      index: index,
                                      child: const Icon(Icons.drag_handle, color: Colors.grey),
                                    ),
                                  const SizedBox(width: 8),
                                  CircleAvatar(
                                    backgroundColor: isCurrent 
                                        ? Colors.green
                                        : Theme.of(context).colorScheme.primaryContainer,
                                    child: isCurrent
                                        ? const Icon(Icons.music_note, size: 20)
                                        : Text('${index + 1}'),
                                  ),
                                ],
                              ),
                              title: Text(
                                song.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                                  color: isCurrent ? Colors.green : null,
                                ),
                              ),
                              subtitle: song.artist != null
                                  ? Text(
                                      song.artist!,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    )
                                  : null,
                              trailing: !isCurrent
                                  ? IconButton(
                                      icon: const Icon(Icons.close, size: 20),
                                      onPressed: () {
                                        context.read<MusicPlayerBloc>().add(
                                          RemoveFromQueueEvent(index),
                                        );
                                      },
                                    )
                                  : null,
                            ),
                          );
                        },
                      )
                    : const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.playlist_add, size: 48, color: Colors.grey),
                              SizedBox(height: 16),
                              Text(
                                'No more songs in queue',
                                style: TextStyle(fontSize: 16, color: Colors.grey),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Add songs from a playlist or all songs',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ),
              ),
            ],
          );
        },
      ),
      ),
    );
  }
}
