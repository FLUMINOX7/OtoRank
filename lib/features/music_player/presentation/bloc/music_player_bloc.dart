library;

import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/song.dart';
import '../../domain/usecases/play_song.dart';
import '../../domain/usecases/load_playlist.dart';
import '../../domain/repositories/audio_player_repository.dart';
import 'music_player_event.dart';
import 'music_player_state.dart';

/// BLoC pour gérer l'état du lecteur de musique
class MusicPlayerBloc extends Bloc<MusicPlayerEvent, MusicPlayerState> {
  final PlaySong playSong;
  final LoadPlaylist loadPlaylist;
  final AudioPlayerRepository audioPlayerRepository;

  StreamSubscription? _playbackStateSubscription;
  StreamSubscription? _currentSongSubscription;
  StreamSubscription? _positionSubscription;
  StreamSubscription? _durationSubscription;
  StreamSubscription? _shuffleModeSubscription;
  StreamSubscription? _repeatModeSubscription;

  MusicPlayerBloc({
    required this.playSong,
    required this.loadPlaylist,
    required this.audioPlayerRepository,
  }) : super(const MusicPlayerInitial()) {
    on<PlaySongEvent>(_onPlaySong);
    on<LoadPlaylistEvent>(_onLoadPlaylist);
    on<PauseEvent>(_onPause);
    on<ResumeEvent>(_onResume);
    on<StopEvent>(_onStop);
    on<SkipToNextEvent>(_onSkipToNext);
    on<SkipToPreviousEvent>(_onSkipToPrevious);
    on<SeekToEvent>(_onSeekTo);
    on<SetShuffleModeEvent>(_onSetShuffleMode);
    on<SetRepeatModeEvent>(_onSetRepeatMode);
    on<SetVolumeEvent>(_onSetVolume);
    on<SetPlaybackSpeedEvent>(_onSetPlaybackSpeed);
    on<PlaybackStateChangedEvent>(_onPlaybackStateChanged);
    on<CurrentSongChangedEvent>(_onCurrentSongChanged);
    on<PositionChangedEvent>(_onPositionChanged);
    on<DurationChangedEvent>(_onDurationChanged);

    _listenToPlayerStreams();
  }

  void _listenToPlayerStreams() {
    _playbackStateSubscription = audioPlayerRepository.playbackStateStream.listen(
      (playbackState) {
        add(PlaybackStateChangedEvent(playbackState));
      },
    );

    _currentSongSubscription = audioPlayerRepository.currentSongStream.listen(
      (song) {
        add(CurrentSongChangedEvent(song));
      },
    );

    _positionSubscription = audioPlayerRepository.positionStream.listen(
      (position) {
        add(PositionChangedEvent(position));
      },
    );

    _durationSubscription = audioPlayerRepository.durationStream.listen(
      (duration) {
        add(DurationChangedEvent(duration));
      },
    );

    _shuffleModeSubscription = audioPlayerRepository.shuffleModeStream.listen(
      (isShuffled) {
        // Pas d'event car déjà géré dans SetShuffleMode
      },
    );

    _repeatModeSubscription = audioPlayerRepository.repeatModeStream.listen(
      (repeatMode) {
        // Pas d'event car déjà géré dans SetRepeatMode
      },
    );
  }

  Future<void> _onPlaySong(PlaySongEvent event, Emitter<MusicPlayerState> emit) async {
    emit(MusicPlayerLoading(
      currentSong: event.song,
      isShuffled: state.isShuffled,
      repeatMode: state.repeatMode,
      volume: state.volume,
      playbackSpeed: state.playbackSpeed,
    ));

    final result = await playSong(event.song);
    
    result.fold(
      (failure) => emit(MusicPlayerError(
        message: failure.message,
        currentSong: event.song,
        playbackState: PlaybackState.stopped,
        position: Duration.zero,
        duration: null,
        isShuffled: state.isShuffled,
        repeatMode: state.repeatMode,
        volume: state.volume,
        playbackSpeed: state.playbackSpeed,
      )),
      (_) {
        // L'état sera mis à jour par les streams
      },
    );
  }

  Future<void> _onLoadPlaylist(LoadPlaylistEvent event, Emitter<MusicPlayerState> emit) async {
    emit(MusicPlayerLoading(
      isShuffled: state.isShuffled,
      repeatMode: state.repeatMode,
      volume: state.volume,
      playbackSpeed: state.playbackSpeed,
    ));

    final result = await loadPlaylist(event.songs, startIndex: event.startIndex);
    
    result.fold(
      (failure) => emit(MusicPlayerError(
        message: failure.message,
        playbackState: PlaybackState.stopped,
        position: Duration.zero,
        duration: null,
        isShuffled: state.isShuffled,
        repeatMode: state.repeatMode,
        volume: state.volume,
        playbackSpeed: state.playbackSpeed,
      )),
      (_) {
        // L'état sera mis à jour par les streams
      },
    );
  }

  Future<void> _onPause(PauseEvent event, Emitter<MusicPlayerState> emit) async {
    await audioPlayerRepository.pause();
  }

  Future<void> _onResume(ResumeEvent event, Emitter<MusicPlayerState> emit) async {
    await audioPlayerRepository.resume();
  }

  Future<void> _onStop(StopEvent event, Emitter<MusicPlayerState> emit) async {
    await audioPlayerRepository.stop();
    emit(const MusicPlayerStopped());
  }

  Future<void> _onSkipToNext(SkipToNextEvent event, Emitter<MusicPlayerState> emit) async {
    await audioPlayerRepository.skipToNext();
  }

  Future<void> _onSkipToPrevious(SkipToPreviousEvent event, Emitter<MusicPlayerState> emit) async {
    await audioPlayerRepository.skipToPrevious();
  }

  Future<void> _onSeekTo(SeekToEvent event, Emitter<MusicPlayerState> emit) async {
    await audioPlayerRepository.seekTo(event.position);
  }

  Future<void> _onSetShuffleMode(SetShuffleModeEvent event, Emitter<MusicPlayerState> emit) async {
    await audioPlayerRepository.setShuffleMode(event.enabled);
    emit(_copyStateWith(isShuffled: event.enabled));
  }

  Future<void> _onSetRepeatMode(SetRepeatModeEvent event, Emitter<MusicPlayerState> emit) async {
    await audioPlayerRepository.setRepeatMode(event.mode);
    emit(_copyStateWith(repeatMode: event.mode));
  }

  Future<void> _onSetVolume(SetVolumeEvent event, Emitter<MusicPlayerState> emit) async {
    await audioPlayerRepository.setVolume(event.volume);
    emit(_copyStateWith(volume: event.volume));
  }

  Future<void> _onSetPlaybackSpeed(SetPlaybackSpeedEvent event, Emitter<MusicPlayerState> emit) async {
    await audioPlayerRepository.setPlaybackSpeed(event.speed);
    emit(_copyStateWith(playbackSpeed: event.speed));
  }

  void _onPlaybackStateChanged(PlaybackStateChangedEvent event, Emitter<MusicPlayerState> emit) {
    if (event.state == PlaybackState.playing) {
      emit(MusicPlayerPlaying(
        currentSong: state.currentSong,
        position: state.position,
        duration: state.duration,
        isShuffled: state.isShuffled,
        repeatMode: state.repeatMode,
        volume: state.volume,
        playbackSpeed: state.playbackSpeed,
      ));
    } else if (event.state == PlaybackState.paused) {
      emit(MusicPlayerPaused(
        currentSong: state.currentSong,
        position: state.position,
        duration: state.duration,
        isShuffled: state.isShuffled,
        repeatMode: state.repeatMode,
        volume: state.volume,
        playbackSpeed: state.playbackSpeed,
      ));
    } else if (event.state == PlaybackState.stopped) {
      emit(const MusicPlayerStopped());
    }
  }

  void _onCurrentSongChanged(CurrentSongChangedEvent event, Emitter<MusicPlayerState> emit) {
    emit(_copyStateWith(currentSong: event.song));
  }

  void _onPositionChanged(PositionChangedEvent event, Emitter<MusicPlayerState> emit) {
    emit(_copyStateWith(position: event.position));
  }

  void _onDurationChanged(DurationChangedEvent event, Emitter<MusicPlayerState> emit) {
    emit(_copyStateWith(duration: event.duration));
  }

  MusicPlayerState _copyStateWith({
    Song? currentSong,
    PlaybackState? playbackState,
    Duration? position,
    Duration? duration,
    bool? isShuffled,
    RepeatMode? repeatMode,
    double? volume,
    double? playbackSpeed,
  }) {
    final newState = state.playbackState == PlaybackState.playing
        ? MusicPlayerPlaying(
            currentSong: currentSong ?? state.currentSong,
            position: position ?? state.position,
            duration: duration ?? state.duration,
            isShuffled: isShuffled ?? state.isShuffled,
            repeatMode: repeatMode ?? state.repeatMode,
            volume: volume ?? state.volume,
            playbackSpeed: playbackSpeed ?? state.playbackSpeed,
          )
        : state.playbackState == PlaybackState.paused
            ? MusicPlayerPaused(
                currentSong: currentSong ?? state.currentSong,
                position: position ?? state.position,
                duration: duration ?? state.duration,
                isShuffled: isShuffled ?? state.isShuffled,
                repeatMode: repeatMode ?? state.repeatMode,
                volume: volume ?? state.volume,
                playbackSpeed: playbackSpeed ?? state.playbackSpeed,
              )
            : state;

    return newState;
  }

  @override
  Future<void> close() {
    _playbackStateSubscription?.cancel();
    _currentSongSubscription?.cancel();
    _positionSubscription?.cancel();
    _durationSubscription?.cancel();
    _shuffleModeSubscription?.cancel();
    _repeatModeSubscription?.cancel();
    return super.close();
  }
}
