library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/music_player_bloc.dart';
import '../bloc/music_player_event.dart';
import '../bloc/music_player_state.dart';
import '../../domain/repositories/audio_player_repository.dart';
import 'dart:math' as math;

/// Full-screen immersive music player page
class FullPlayerPage extends StatefulWidget {
  const FullPlayerPage({super.key});

  @override
  State<FullPlayerPage> createState() => _FullPlayerPageState();
}

class _FullPlayerPageState extends State<FullPlayerPage> with TickerProviderStateMixin {
  late AnimationController _albumRotationController;
  late AnimationController _waveformController;
  
  @override
  void initState() {
    super.initState();
    _albumRotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
    
    _waveformController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..repeat(reverse: true);
  }
  
  @override
  void dispose() {
    _albumRotationController.dispose();
    _waveformController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: BlocBuilder<MusicPlayerBloc, MusicPlayerState>(
        builder: (context, state) {
          final song = state.currentSong;
          if (song == null) {
            return const Center(
              child: Text(
                'No song playing',
                style: TextStyle(color: Colors.white70),
              ),
            );
          }

          final isPlaying = state.playbackState == PlaybackState.playing;
          if (!isPlaying) {
            _albumRotationController.stop();
          } else {
            if (!_albumRotationController.isAnimating) {
              _albumRotationController.repeat();
            }
          }

          final progress = state.duration != null && state.duration!.inMilliseconds > 0
              ? state.position.inMilliseconds / state.duration!.inMilliseconds
              : 0.0;

          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF4A148C), // Deep purple
                  Colors.black,
                  Colors.black,
                  const Color(0xFFE64A19), // Red
                ],
                stops: const [0.0, 0.3, 0.7, 1.0],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // Header with back button
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.keyboard_arrow_down, size: 32, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const Text(
                          'Now Playing',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.queue_music, color: Colors.white),
                              onPressed: () {
                                Navigator.pushNamed(context, '/queue');
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.equalizer, color: Colors.white),
                              onPressed: () {
                                Navigator.pushNamed(context, '/equalizer');
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.more_vert, color: Colors.white),
                              onPressed: () {
                                // TODO: Show options menu
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Album Art with rotation animation
                  Expanded(
                    flex: 3,
                    child: Center(
                      child: Hero(
                        tag: 'song-icon-${song.id}',
                        child: AnimatedBuilder(
                          animation: _albumRotationController,
                          builder: (context, child) {
                            return Transform.rotate(
                              angle: isPlaying ? _albumRotationController.value * 2 * math.pi : 0,
                              child: child,
                            );
                          },
                          child: Container(
                            width: 280,
                            height: 280,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Color(0xFF4A148C),
                                  Color(0xFFE64A19),
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF4A148C).withOpacity(0.5),
                                  blurRadius: 40,
                                  spreadRadius: 10,
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.music_note,
                                size: 120,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Waveform visualization
                  SizedBox(
                    height: 60,
                    child: AnimatedBuilder(
                      animation: _waveformController,
                      builder: (context, child) {
                        return CustomPaint(
                          painter: WaveformPainter(
                            progress: progress,
                            isPlaying: isPlaying,
                            animationValue: _waveformController.value,
                          ),
                          size: Size(MediaQuery.of(context).size.width, 60),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Song info
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: Column(
                      children: [
                        Text(
                          song.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        if (song.artist != null)
                          Text(
                            song.artist!,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                            textAlign: TextAlign.center,
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Progress bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: Column(
                      children: [
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            trackHeight: 3,
                            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                            overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
                            activeTrackColor: Colors.white,
                            inactiveTrackColor: Colors.white24,
                            thumbColor: Colors.white,
                            overlayColor: Colors.white24,
                          ),
                          child: Slider(
                            value: progress.clamp(0.0, 1.0),
                            onChanged: (value) {
                              final newPosition = Duration(
                                milliseconds: (value * (state.duration?.inMilliseconds ?? 0)).toInt(),
                              );
                              context.read<MusicPlayerBloc>().add(SeekToEvent(newPosition));
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _formatDuration(state.position),
                                style: const TextStyle(color: Colors.white70, fontSize: 12),
                              ),
                              Text(
                                _formatDuration(state.duration ?? Duration.zero),
                                style: const TextStyle(color: Colors.white70, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Playback controls
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Shuffle
                        IconButton(
                          icon: Icon(
                            Icons.shuffle,
                            color: state.isShuffled ? const Color(0xFFE64A19) : Colors.white60,
                            size: 28,
                          ),
                          onPressed: () {
                            context.read<MusicPlayerBloc>().add(
                              SetShuffleModeEvent(!state.isShuffled),
                            );
                          },
                        ),
                        
                        // Previous
                        IconButton(
                          icon: const Icon(Icons.skip_previous, color: Colors.white, size: 40),
                          onPressed: () {
                            context.read<MusicPlayerBloc>().add(SkipToPreviousEvent());
                          },
                        ),
                        
                        // Play/Pause
                        Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [Color(0xFF4A148C), Color(0xFFE64A19)],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFE64A19).withOpacity(0.5),
                                blurRadius: 20,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: IconButton(
                            icon: Icon(
                              isPlaying ? Icons.pause : Icons.play_arrow,
                              color: Colors.white,
                              size: 36,
                            ),
                            onPressed: () {
                              if (isPlaying) {
                                context.read<MusicPlayerBloc>().add(PauseEvent());
                              } else {
                                context.read<MusicPlayerBloc>().add(ResumeEvent());
                              }
                            },
                          ),
                        ),
                        
                        // Next
                        IconButton(
                          icon: const Icon(Icons.skip_next, color: Colors.white, size: 40),
                          onPressed: () {
                            context.read<MusicPlayerBloc>().add(SkipToNextEvent());
                          },
                        ),
                        
                        // Repeat
                        IconButton(
                          icon: Icon(
                            state.repeatMode == RepeatMode.one
                                ? Icons.repeat_one
                                : Icons.repeat,
                            color: state.repeatMode != RepeatMode.off
                                ? const Color(0xFFE64A19)
                                : Colors.white60,
                            size: 28,
                          ),
                          onPressed: () {
                            RepeatMode newMode;
                            if (state.repeatMode == RepeatMode.off) {
                              newMode = RepeatMode.all;
                            } else if (state.repeatMode == RepeatMode.all) {
                              newMode = RepeatMode.one;
                            } else {
                              newMode = RepeatMode.off;
                            }
                            context.read<MusicPlayerBloc>().add(SetRepeatModeEvent(newMode));
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Additional controls
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.playlist_play, color: Colors.white60, size: 28),
                          onPressed: () {
                            // TODO: Show queue
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.equalizer, color: Colors.white60, size: 28),
                          onPressed: () {
                            // TODO: Show equalizer
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.timer, color: Colors.white60, size: 28),
                          onPressed: () {
                            // TODO: Show sleep timer
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.share, color: Colors.white60, size: 28),
                          onPressed: () {
                            // TODO: Share song
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}

/// Custom painter for waveform visualization
class WaveformPainter extends CustomPainter {
  final double progress;
  final bool isPlaying;
  final double animationValue;

  WaveformPainter({
    required this.progress,
    required this.isPlaying,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const barCount = 50;
    final barWidth = size.width / barCount;
    final paint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < barCount; i++) {
      final x = i * barWidth;
      final normalizedPosition = i / barCount;
      
      // Create wave effect
      final wave = math.sin((normalizedPosition * 4 * math.pi) + (animationValue * 2 * math.pi));
      final baseHeight = isPlaying ? 20 + (wave * 15) : 10;
      final height = baseHeight * (1 + (math.sin(normalizedPosition * math.pi * 2) * 0.5));
      
      // Color based on progress
      if (normalizedPosition <= progress) {
        paint.color = Colors.white;
      } else {
        paint.color = Colors.white24;
      }
      
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          x + barWidth * 0.2,
          (size.height - height) / 2,
          barWidth * 0.6,
          height,
        ),
        const Radius.circular(2),
      );
      
      canvas.drawRRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(WaveformPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.isPlaying != isPlaying ||
        oldDelegate.animationValue != animationValue;
  }
}
