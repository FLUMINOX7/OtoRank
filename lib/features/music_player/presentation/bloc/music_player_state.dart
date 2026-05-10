library;

import 'package:equatable/equatable.dart';
import '../../domain/entities/song.dart';
import '../../domain/repositories/audio_player_repository.dart';

/// States pour le MusicPlayerBloc
abstract class MusicPlayerState extends Equatable {
  final Song? currentSong;
  final PlaybackState playbackState;
  final Duration position;
  final Duration? duration;
  final bool isShuffled;
  final RepeatMode repeatMode;
  final double volume;
  final double playbackSpeed;
  final List<Song> queue;

  const MusicPlayerState({
    this.currentSong,
    required this.playbackState,
    this.position = Duration.zero,
    this.duration,
    this.isShuffled = false,
    this.repeatMode = RepeatMode.off,
    this.volume = 1.0,
    this.playbackSpeed = 1.0,
    this.queue = const [],
  });

  @override
  List<Object?> get props => [
        currentSong,
        playbackState,
        position,
        duration,
        isShuffled,
        repeatMode,
        volume,
        playbackSpeed,
        queue,
      ];
}

class MusicPlayerInitial extends MusicPlayerState {
  final int timestamp;
  
  MusicPlayerInitial()
      : timestamp = DateTime.now().millisecondsSinceEpoch,
        super(
          playbackState: PlaybackState.stopped,
        );

  @override
  List<Object?> get props => [...super.props, timestamp];
}

class MusicPlayerPlaying extends MusicPlayerState {
  const MusicPlayerPlaying({
    required super.currentSong,
    required super.position,
    required super.duration,
    required super.isShuffled,
    required super.repeatMode,
    required super.volume,
    required super.playbackSpeed,
    required super.queue,
  }) : super(
          playbackState: PlaybackState.playing,
        );
}

class MusicPlayerPaused extends MusicPlayerState {
  const MusicPlayerPaused({
    required super.currentSong,
    required super.position,
    required super.duration,
    required super.isShuffled,
    required super.repeatMode,
    required super.volume,
    required super.playbackSpeed,
    required super.queue,
  }) : super(
          playbackState: PlaybackState.paused,
        );
}

class MusicPlayerStopped extends MusicPlayerState {
  final int timestamp;
  
  MusicPlayerStopped()
      : timestamp = DateTime.now().millisecondsSinceEpoch,
        super(
          playbackState: PlaybackState.stopped,
          queue: const [],
        );

  @override
  List<Object?> get props => [...super.props, timestamp];
}

class MusicPlayerLoading extends MusicPlayerState {
  const MusicPlayerLoading({
    super.currentSong,
    required super.isShuffled,
    required super.repeatMode,
    required super.volume,
    required super.playbackSpeed,
    required super.queue,
  }) : super(
          playbackState: PlaybackState.loading,
        );
}

class MusicPlayerError extends MusicPlayerState {
  final String message;

  const MusicPlayerError({
    required this.message,
    super.currentSong,
    required super.playbackState,
    required super.position,
    required super.duration,
    required super.isShuffled,
    required super.repeatMode,
    required super.volume,
    required super.playbackSpeed,
    required super.queue,
  });

  @override
  List<Object?> get props => [
        ...super.props,
        message,
      ];
}
