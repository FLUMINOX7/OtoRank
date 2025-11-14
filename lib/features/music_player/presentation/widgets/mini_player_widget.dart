library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/music_player_bloc.dart';
import '../bloc/music_player_event.dart';
import '../bloc/music_player_state.dart';
import '../../domain/repositories/audio_player_repository.dart';

/// Compact mini player widget displayed at the bottom
class MiniPlayerWidget extends StatelessWidget {
  const MiniPlayerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MusicPlayerBloc, MusicPlayerState>(
      builder: (context, state) {
        // Show mini-player if there's a current song or if loading with a song
        if (state.currentSong == null) {
          return const SizedBox.shrink();
        }

        final isPlaying = state.playbackState == PlaybackState.playing;
        final isLoading = state.playbackState == PlaybackState.loading;
        final song = state.currentSong!;
        final progress = state.duration != null && state.duration!.inMilliseconds > 0
            ? state.position.inMilliseconds / state.duration!.inMilliseconds
            : 0.0;

        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Progress bar
              LinearProgressIndicator(
                value: progress,
                minHeight: 2,
                backgroundColor: Colors.grey[800],
              ),
              
              // Player controls
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  children: [
                    // Song info
                    const Icon(Icons.music_note, size: 32),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            song.title,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (song.artist != null)
                            Text(
                              song.artist!,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[400],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                    
                    // Playback controls
                    IconButton(
                      icon: const Icon(Icons.skip_previous),
                      onPressed: isLoading ? null : () {
                        context.read<MusicPlayerBloc>().add(SkipToPreviousEvent());
                      },
                    ),
                    IconButton(
                      icon: Icon(
                        isLoading 
                            ? Icons.hourglass_empty 
                            : (isPlaying ? Icons.pause : Icons.play_arrow),
                        size: 32,
                      ),
                      onPressed: isLoading ? null : () {
                        if (isPlaying) {
                          context.read<MusicPlayerBloc>().add(PauseEvent());
                        } else {
                          context.read<MusicPlayerBloc>().add(ResumeEvent());
                        }
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.skip_next),
                      onPressed: isLoading ? null : () {
                        context.read<MusicPlayerBloc>().add(SkipToNextEvent());
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
