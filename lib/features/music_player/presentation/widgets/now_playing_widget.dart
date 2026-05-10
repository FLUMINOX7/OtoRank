library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/music_player_bloc.dart';
import '../bloc/music_player_event.dart';
import '../bloc/music_player_state.dart';
import '../../domain/repositories/audio_player_repository.dart';

/// Widget affichant le lecteur audio en cours
class NowPlayingWidget extends StatelessWidget {
  const NowPlayingWidget({super.key});

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MusicPlayerBloc, MusicPlayerState>(
      builder: (context, state) {
        if (state.currentSong == null) {
          return Container(
            padding: const EdgeInsets.all(16),
            child: const Text(
              'Aucune chanson en lecture',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          );
        }

        final isPlaying = state.playbackState == PlaybackState.playing;
        final song = state.currentSong!;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Titre et artiste
              Row(
                children: [
                  const Icon(Icons.music_note, size: 40),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          song.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (song.artist != null)
                          Text(
                            song.artist!,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[400],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Barre de progression
              Column(
                children: [
                  Slider(
                    value: state.position.inSeconds.toDouble(),
                    max: (state.duration?.inSeconds ?? 0).toDouble().clamp(1, double.infinity),
                    onChanged: (value) {
                      context.read<MusicPlayerBloc>().add(
                            SeekToEvent(Duration(seconds: value.toInt())),
                          );
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(_formatDuration(state.position)),
                        Text(_formatDuration(state.duration ?? Duration.zero)),
                      ],
                    ),
                  ),
                ],
              ),
              
              // Contrôles de lecture
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Shuffle
                  IconButton(
                    icon: Icon(
                      Icons.shuffle,
                      color: state.isShuffled
                          ? Theme.of(context).colorScheme.primary
                          : null,
                    ),
                    onPressed: () {
                      context.read<MusicPlayerBloc>().add(
                            SetShuffleModeEvent(!state.isShuffled),
                          );
                    },
                  ),
                  
                  // Previous
                  IconButton(
                    icon: const Icon(Icons.skip_previous, size: 32),
                    onPressed: () {
                      context.read<MusicPlayerBloc>().add(SkipToPreviousEvent());
                    },
                  ),
                  
                  // Play/Pause
                  IconButton(
                    icon: Icon(
                      isPlaying ? Icons.pause_circle : Icons.play_circle,
                      size: 48,
                    ),
                    onPressed: () {
                      if (isPlaying) {
                        context.read<MusicPlayerBloc>().add(PauseEvent());
                      } else {
                        context.read<MusicPlayerBloc>().add(ResumeEvent());
                      }
                    },
                  ),
                  
                  // Next
                  IconButton(
                    icon: const Icon(Icons.skip_next, size: 32),
                    onPressed: () {
                      context.read<MusicPlayerBloc>().add(SkipToNextEvent());
                    },
                  ),
                  
                  // Repeat
                  IconButton(
                    icon: Icon(
                      state.repeatMode == RepeatMode.off
                          ? Icons.repeat
                          : state.repeatMode == RepeatMode.one
                              ? Icons.repeat_one
                              : Icons.repeat,
                      color: state.repeatMode != RepeatMode.off
                          ? Theme.of(context).colorScheme.primary
                          : null,
                    ),
                    onPressed: () {
                      final nextMode = state.repeatMode == RepeatMode.off
                          ? RepeatMode.all
                          : state.repeatMode == RepeatMode.all
                              ? RepeatMode.one
                              : RepeatMode.off;
                      context.read<MusicPlayerBloc>().add(
                            SetRepeatModeEvent(nextMode),
                          );
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
