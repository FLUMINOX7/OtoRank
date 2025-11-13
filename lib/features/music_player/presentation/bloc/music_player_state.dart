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

  const MusicPlayerState({
    this.currentSong,
    required this.playbackState,
    this.position = Duration.zero,
    this.duration,
    this.isShuffled = false,
    this.repeatMode = RepeatMode.off,
    this.volume = 1.0,
    this.playbackSpeed = 1.0,
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
      ];
}

class MusicPlayerInitial extends MusicPlayerState {
  const MusicPlayerInitial()
      : super(
          playbackState: PlaybackState.stopped,
        );
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
  }) : super(
          playbackState: PlaybackState.paused,
        );
}

class MusicPlayerStopped extends MusicPlayerState {
  const MusicPlayerStopped()
      : super(
          playbackState: PlaybackState.stopped,
        );
}

class MusicPlayerLoading extends MusicPlayerState {
  const MusicPlayerLoading({
    super.currentSong,
    required super.isShuffled,
    required super.repeatMode,
    required super.volume,
    required super.playbackSpeed,
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
  });

  @override
  List<Object?> get props => [
        ...super.props,
        message,
      ];
}
