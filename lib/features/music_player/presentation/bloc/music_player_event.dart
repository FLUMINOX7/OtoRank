library;

import 'package:equatable/equatable.dart';
import '../../domain/entities/song.dart';
import '../../domain/repositories/audio_player_repository.dart';

/// Events pour le MusicPlayerBloc
abstract class MusicPlayerEvent extends Equatable {
  const MusicPlayerEvent();

  @override
  List<Object?> get props => [];
}

class PlaySongEvent extends MusicPlayerEvent {
  final Song song;

  const PlaySongEvent(this.song);

  @override
  List<Object?> get props => [song];
}

class LoadPlaylistEvent extends MusicPlayerEvent {
  final List<Song> songs;
  final int startIndex;

  const LoadPlaylistEvent(this.songs, {this.startIndex = 0});

  @override
  List<Object?> get props => [songs, startIndex];
}

class PauseEvent extends MusicPlayerEvent {}

class ResumeEvent extends MusicPlayerEvent {}

class StopEvent extends MusicPlayerEvent {}

class SkipToNextEvent extends MusicPlayerEvent {}

class SkipToPreviousEvent extends MusicPlayerEvent {}

class SeekToEvent extends MusicPlayerEvent {
  final Duration position;

  const SeekToEvent(this.position);

  @override
  List<Object?> get props => [position];
}

class SetShuffleModeEvent extends MusicPlayerEvent {
  final bool enabled;

  const SetShuffleModeEvent(this.enabled);

  @override
  List<Object?> get props => [enabled];
}

class SetRepeatModeEvent extends MusicPlayerEvent {
  final RepeatMode mode;

  const SetRepeatModeEvent(this.mode);

  @override
  List<Object?> get props => [mode];
}

class SetVolumeEvent extends MusicPlayerEvent {
  final double volume;

  const SetVolumeEvent(this.volume);

  @override
  List<Object?> get props => [volume];
}

class SetPlaybackSpeedEvent extends MusicPlayerEvent {
  final double speed;

  const SetPlaybackSpeedEvent(this.speed);

  @override
  List<Object?> get props => [speed];
}

class PlaybackStateChangedEvent extends MusicPlayerEvent {
  final PlaybackState state;

  const PlaybackStateChangedEvent(this.state);

  @override
  List<Object?> get props => [state];
}

class CurrentSongChangedEvent extends MusicPlayerEvent {
  final Song? song;

  const CurrentSongChangedEvent(this.song);

  @override
  List<Object?> get props => [song];
}

class PositionChangedEvent extends MusicPlayerEvent {
  final Duration position;

  const PositionChangedEvent(this.position);

  @override
  List<Object?> get props => [position];
}

class DurationChangedEvent extends MusicPlayerEvent {
  final Duration? duration;

  const DurationChangedEvent(this.duration);

  @override
  List<Object?> get props => [duration];
}
