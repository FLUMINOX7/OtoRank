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

  static const BoxConstraints _controlConstraints = BoxConstraints(
    minWidth: 34,
    minHeight: 34,
  );

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MusicPlayerBloc, MusicPlayerState>(
      builder: (context, state) {
        // Show mini-player if there's a current song
        if (state.currentSong == null) {
          return const SizedBox.shrink();
        }

        final isPlaying = state.playbackState == PlaybackState.playing;
        final isLoading = state.playbackState == PlaybackState.loading;
        final song = state.currentSong!;
        final progress = state.duration != null && state.duration!.inMilliseconds > 0
            ? state.position.inMilliseconds / state.duration!.inMilliseconds
            : 0.0;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, -3),
              ),
            ],
          ),
          child: GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, '/full-player');
            },
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
                  child: SizedBox(
                    height: 46,
                    child: Row(
                      children: [
                        // Song info
                        const Icon(Icons.music_note, size: 28),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 300),
                                transitionBuilder: (child, animation) {
                                  return FadeTransition(
                                    opacity: animation,
                                    child: SlideTransition(
                                      position: Tween<Offset>(
                                        begin: const Offset(0, 0.2),
                                        end: Offset.zero,
                                      ).animate(animation),
                                      child: child,
                                    ),
                                  );
                                },
                                child: Text(
                                  song.title,
                                  key: ValueKey('title-${song.id}'),
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (song.artist != null)
                                AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 300),
                                  transitionBuilder: (child, animation) {
                                    return FadeTransition(
                                      opacity: animation,
                                      child: child,
                                    );
                                  },
                                  child: Text(
                                    song.artist!,
                                    key: ValueKey('artist-${song.id}'),
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey[400],
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                            ],
                          ),
                        ),

                        // Playback controls
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: _controlConstraints,
                          icon: const Icon(Icons.skip_previous),
                          iconSize: 22,
                          onPressed: isLoading
                              ? null
                              : () {
                                  context.read<MusicPlayerBloc>().add(SkipToPreviousEvent());
                                },
                        ),
                        AnimatedScale(
                          scale: isLoading ? 0.9 : 1.0,
                          duration: const Duration(milliseconds: 150),
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            constraints: _controlConstraints,
                            icon: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 200),
                              transitionBuilder: (child, animation) {
                                return ScaleTransition(
                                  scale: animation,
                                  child: child,
                                );
                              },
                              child: Icon(
                                isLoading
                                    ? Icons.hourglass_empty
                                    : (isPlaying ? Icons.pause : Icons.play_arrow),
                                key: ValueKey(isLoading ? 'loading' : (isPlaying ? 'pause' : 'play')),
                                size: 28,
                              ),
                            ),
                            onPressed: isLoading
                                ? null
                                : () {
                                    if (isPlaying) {
                                      context.read<MusicPlayerBloc>().add(PauseEvent());
                                    } else {
                                      context.read<MusicPlayerBloc>().add(ResumeEvent());
                                    }
                                  },
                          ),
                        ),
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: _controlConstraints,
                          icon: const Icon(Icons.skip_next),
                          iconSize: 22,
                          onPressed: isLoading
                              ? null
                              : () {
                                  context.read<MusicPlayerBloc>().add(SkipToNextEvent());
                                },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
