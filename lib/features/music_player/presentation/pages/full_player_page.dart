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
    return BlocListener<MusicPlayerBloc, MusicPlayerState>(
      listener: (context, state) {
        // Si la queue est vide, revenir à la page principale
        if (state.queue.isEmpty) {
          Future.delayed(const Duration(milliseconds: 300), () {
            if (context.mounted) {
              Navigator.of(context).popUntil((route) => route.isFirst);
            }
          });
        }
      },
      child: Scaffold(
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
            // ...existing code...
            // (tout le reste du builder reste inchangé)
            // ...existing code...
          },
        ),
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
