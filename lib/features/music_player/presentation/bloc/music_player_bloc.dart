library;

import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/song.dart';
import '../../domain/usecases/play_song.dart';
import '../../domain/usecases/load_playlist.dart';
import '../../domain/repositories/audio_player_repository.dart';
import '../../data/datasources/player_state_local_data_source.dart';
import 'music_player_event.dart';
import 'music_player_state.dart';

/// BLoC pour gérer l'état du lecteur de musique
class MusicPlayerBloc extends Bloc<MusicPlayerEvent, MusicPlayerState> {
  final PlaySong playSong;
  final LoadPlaylist loadPlaylist;
  final AudioPlayerRepository audioPlayerRepository;
  final PlayerStateLocalDataSource playerStateLocalDataSource;

  StreamSubscription? _playbackStateSubscription;
  StreamSubscription? _currentSongSubscription;
  StreamSubscription? _positionSubscription;
  StreamSubscription? _durationSubscription;
  StreamSubscription? _shuffleModeSubscription;
  StreamSubscription? _repeatModeSubscription;
  
  // Flag to ignore playback state changes right after loading
  bool _ignoreNextPlaybackStateChange = false;

  MusicPlayerBloc({
    required this.playSong,
    required this.loadPlaylist,
    required this.audioPlayerRepository,
    required this.playerStateLocalDataSource,
  }) : super(MusicPlayerInitial()) {
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
    on<RestorePlayerStateEvent>(_onRestorePlayerState);
    on<SavePlayerStateEvent>(_onSavePlayerState);
    on<GetCurrentQueueEvent>(_onGetCurrentQueue);
    on<ReorderQueueEvent>(_onReorderQueue);
    on<RemoveFromQueueEvent>(_onRemoveFromQueue);
    on<ClearQueueEvent>(_onClearQueue);

    _listenToPlayerStreams();
    
    // Restore saved state on init
    add(RestorePlayerStateEvent());
  }

  void _listenToPlayerStreams() {
    _playbackStateSubscription = audioPlayerRepository.playbackStateStream.listen(
      (playbackState) {
        add(PlaybackStateChangedEvent(playbackState));
      },
    );

    // DO NOT listen to currentSongStream - we manage currentSong internally
    // The stream was causing race conditions and overwriting our state
    
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
    final currentQueue = audioPlayerRepository.getCurrentQueue();
    
    emit(MusicPlayerLoading(
      currentSong: event.song,
      isShuffled: state.isShuffled,
      repeatMode: state.repeatMode,
      volume: state.volume,
      playbackSpeed: state.playbackSpeed,
      queue: currentQueue,
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
        queue: currentQueue,
      )),
      (_) {
        final newQueue = audioPlayerRepository.getCurrentQueue();
        // Emit playing state immediately so mini-player shows up
        emit(MusicPlayerPlaying(
          currentSong: event.song,
          position: Duration.zero,
          duration: null,
          isShuffled: state.isShuffled,
          repeatMode: state.repeatMode,
          volume: state.volume,
          playbackSpeed: state.playbackSpeed,
          queue: newQueue,
        ));
      },
    );
  }

  Future<void> _onLoadPlaylist(LoadPlaylistEvent event, Emitter<MusicPlayerState> emit) async {
    print('🎵 [BLOC] LoadPlaylist called with ${event.songs.length} songs, startIndex: ${event.startIndex}');
    
    // Get the song that will be loaded
    final newSong = event.songs.isNotEmpty 
        ? event.songs[event.startIndex.clamp(0, event.songs.length - 1)]
        : null;
    
    if (newSong == null) {
      print('❌ [BLOC] No song to load');
      return;
    }
    
    // ALGORITHME PRO :
    // 1. Vérifier si on a déjà un mini-player (currentSong existe)
    final hasExistingPlayer = state.currentSong != null;
    
    if (hasExistingPlayer) {
      // 2. On a déjà un player
      final isSameSong = state.currentSong?.id == newSong.id;
      
      if (isSameSong) {
        print('🔄 [BLOC] Même chanson cliquée, relancer depuis le début');
        // Même chanson → rejouer depuis le début
        await audioPlayerRepository.seekTo(Duration.zero);
        await audioPlayerRepository.resume();
      } else {
        print('🎵 [BLOC] Nouvelle chanson, changer et jouer');
        // Chanson différente → charger et jouer
      }
    } else {
      print('🎵 [BLOC] Premier mini-player, afficher et jouer');
      // Pas de player → créer et jouer
    }
    
    // Émettre DIRECTEMENT l'état Playing (pas de Loading!)
    // Le mini-player reste interactif pendant le chargement
    emit(MusicPlayerPlaying(
      currentSong: newSong,
      position: Duration.zero,
      duration: null,
      isShuffled: state.isShuffled,
      repeatMode: state.repeatMode,
      volume: state.volume,
      playbackSpeed: state.playbackSpeed,
      queue: event.songs,
    ));
    
    print('✅ [BLOC] État Playing émis immédiatement avec: ${newSong.title}');
    
    // Maintenant charger la chanson en arrière-plan
    _ignoreNextPlaybackStateChange = true;
    
    final result = await loadPlaylist(event.songs, startIndex: event.startIndex);
    
    result.fold(
      (failure) {
        print('❌ [BLOC] LoadPlaylist failed: ${failure.message}');
        _ignoreNextPlaybackStateChange = false;
        final currentQueue = audioPlayerRepository.getCurrentQueue();
        emit(MusicPlayerError(
          message: failure.message,
          playbackState: PlaybackState.stopped,
          position: Duration.zero,
          duration: null,
          isShuffled: state.isShuffled,
          repeatMode: state.repeatMode,
          volume: state.volume,
          playbackSpeed: state.playbackSpeed,
          queue: currentQueue,
        ));
      },
      (_) {
        print('✅ [BLOC] LoadPlaylist success en arrière-plan');
        
        // Clear the flag after a short delay
        Future.delayed(const Duration(milliseconds: 500), () {
          _ignoreNextPlaybackStateChange = false;
          print('🔓 [BLOC] Re-enabled playback state changes');
        });
      },
    );
  }

  Future<void> _onPause(PauseEvent event, Emitter<MusicPlayerState> emit) async {
    print('⏸️ [BLOC] Pause requested, current song: ${state.currentSong?.title}');
    await audioPlayerRepository.pause();
    // Save state when user manually pauses
    add(SavePlayerStateEvent());
    
    // Emit paused state immediately to avoid stream overwriting it
    _ignoreNextPlaybackStateChange = true;
    final currentQueue = audioPlayerRepository.getCurrentQueue();
    emit(MusicPlayerPaused(
      currentSong: state.currentSong,
      position: state.position,
      duration: state.duration,
      isShuffled: state.isShuffled,
      repeatMode: state.repeatMode,
      volume: state.volume,
      playbackSpeed: state.playbackSpeed,
      queue: currentQueue,
    ));
    
    Future.delayed(const Duration(milliseconds: 200), () {
      _ignoreNextPlaybackStateChange = false;
    });
  }

  Future<void> _onResume(ResumeEvent event, Emitter<MusicPlayerState> emit) async {
    print('▶️ [BLOC] Resume requested, current song: ${state.currentSong?.title}');
    
    // If we have a song but player hasn't loaded it yet (restored state case)
    // Load it first, starting from 0
    if (state.currentSong != null) {
      try {
        final currentPlayerSong = audioPlayerRepository.currentSong;
        if (currentPlayerSong?.id != state.currentSong?.id) {
          print('📂 [BLOC] Loading song from restored state: ${state.currentSong!.title}');
          // Just load and play from the beginning
          await audioPlayerRepository.playSong(state.currentSong!);
          print('✅ [BLOC] Song loaded, playing from start');
        } else {
          // Song already loaded, just resume
          print('▶️ [BLOC] Song already loaded, resuming playback');
          await audioPlayerRepository.resume();
        }
      } catch (e) {
        print('❌ [BLOC] Error loading/resuming song: $e');
      }
    } else {
      await audioPlayerRepository.resume();
    }
    
    // Emit playing state immediately
    _ignoreNextPlaybackStateChange = true;
    final currentQueue = audioPlayerRepository.getCurrentQueue();
    emit(MusicPlayerPlaying(
      currentSong: state.currentSong,
      position: state.position,
      duration: state.duration,
      isShuffled: state.isShuffled,
      repeatMode: state.repeatMode,
      volume: state.volume,
      playbackSpeed: state.playbackSpeed,
      queue: currentQueue,
    ));
    
    Future.delayed(const Duration(milliseconds: 200), () {
      _ignoreNextPlaybackStateChange = false;
    });
  }

  Future<void> _onStop(StopEvent event, Emitter<MusicPlayerState> emit) async {
    await audioPlayerRepository.stop();
    emit(MusicPlayerStopped());
  }

  Future<void> _onSkipToNext(SkipToNextEvent event, Emitter<MusicPlayerState> emit) async {
    print('⏭️ [BLOC] Skip to next requested');
    await audioPlayerRepository.skipToNext();
    
    // Update current song after skip
    final newSong = audioPlayerRepository.currentSong;
    print('🎵 [BLOC] New song after skip next: ${newSong?.title}');
    
    if (newSong != null && newSong.id != state.currentSong?.id) {
      _ignoreNextPlaybackStateChange = true;
      emit(_copyStateWith(currentSong: newSong, position: Duration.zero));
      
      Future.delayed(const Duration(milliseconds: 300), () {
        _ignoreNextPlaybackStateChange = false;
      });
    }
  }

  Future<void> _onSkipToPrevious(SkipToPreviousEvent event, Emitter<MusicPlayerState> emit) async {
    print('⏮️ [BLOC] Skip to previous requested');
    await audioPlayerRepository.skipToPrevious();
    
    // Update current song after skip
    final newSong = audioPlayerRepository.currentSong;
    print('🎵 [BLOC] New song after skip previous: ${newSong?.title}');
    
    if (newSong != null && newSong.id != state.currentSong?.id) {
      _ignoreNextPlaybackStateChange = true;
      emit(_copyStateWith(currentSong: newSong, position: Duration.zero));
      
      Future.delayed(const Duration(milliseconds: 300), () {
        _ignoreNextPlaybackStateChange = false;
      });
    }
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
    // Ignore if we just loaded a playlist
    if (_ignoreNextPlaybackStateChange) {
      print('⏭️ [BLOC] Ignoring playback state change: ${event.state} (flag set)');
      return;
    }
    
    print('📢 [BLOC] Playback state changed to: ${event.state}');
    
    // Don't emit if we're in loading state - let the play/load handlers do it
    if (state.playbackState == PlaybackState.loading) {
      print('⏭️ [BLOC] Ignoring playback state change: still in loading');
      return;
    }
    
    final currentQueue = audioPlayerRepository.getCurrentQueue();
    
    if (event.state == PlaybackState.playing) {
      emit(MusicPlayerPlaying(
        currentSong: state.currentSong,
        position: state.position,
        duration: state.duration,
        isShuffled: state.isShuffled,
        repeatMode: state.repeatMode,
        volume: state.volume,
        playbackSpeed: state.playbackSpeed,
        queue: currentQueue,
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
        queue: currentQueue,
      ));
    } else if (event.state == PlaybackState.stopped) {
      emit(MusicPlayerStopped());
    }
  }

  void _onCurrentSongChanged(CurrentSongChangedEvent event, Emitter<MusicPlayerState> emit) {
    // Only update if the song actually changed to avoid overwriting states
    if (state.currentSong?.id != event.song?.id) {
      emit(_copyStateWith(currentSong: event.song));
    }
  }

  void _onPositionChanged(PositionChangedEvent event, Emitter<MusicPlayerState> emit) {
    emit(_copyStateWith(position: event.position));
  }

  void _onDurationChanged(DurationChangedEvent event, Emitter<MusicPlayerState> emit) {
    emit(_copyStateWith(duration: event.duration));
  }

  Future<void> _onRestorePlayerState(RestorePlayerStateEvent event, Emitter<MusicPlayerState> emit) async {
    print('💾 [BLOC] Restoring player state...');
    final savedState = playerStateLocalDataSource.getSavedPlayerState();
    
    if (savedState != null) {
      print('✅ [BLOC] Found saved state: ${savedState['songTitle']}');
      
      // Recreate the song from saved data
      final song = Song(
        id: savedState['songId'],
        title: savedState['songTitle'],
        artist: savedState['songArtist']?.isEmpty == true ? null : savedState['songArtist'],
        filePath: savedState['songPath'],
        duration: null,
        addedDate: DateTime.now(),
      );
      
      // Just show the mini-player with song info at position 0, DON'T load or play
      emit(MusicPlayerPaused(
        currentSong: song,
        position: Duration.zero,  // ✅ Toujours à 0, pas de sauvegarde de position
        duration: null,
        isShuffled: state.isShuffled,
        repeatMode: state.repeatMode,
        volume: state.volume,
        playbackSpeed: state.playbackSpeed,
        queue: const [],
      ));
      
      print('✅ [BLOC] State restored (paused at 0:00), mini-player should show.');
      
      // DON'T load the song in the player - let user click play button
    } else {
      print('ℹ️ [BLOC] No saved state found');
    }
  }

  Future<void> _onSavePlayerState(SavePlayerStateEvent event, Emitter<MusicPlayerState> emit) async {
    final song = state.currentSong;
    if (song != null) {
      print('💾 [BLOC] Saving player state: ${song.title} at position 0:00');
      
      await playerStateLocalDataSource.savePlayerState(
        songId: song.id,
        songPath: song.filePath,
        songTitle: song.title,
        songArtist: song.artist,
        positionMs: 0,  // ✅ Toujours sauvegarder à 0
        wasPlaying: false,  // ✅ Toujours en pause
      );
    }
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
    List<Song>? queue,
  }) {
    final newQueue = queue ?? state.queue;
    
    final newState = state.playbackState == PlaybackState.playing
        ? MusicPlayerPlaying(
            currentSong: currentSong ?? state.currentSong,
            position: position ?? state.position,
            duration: duration ?? state.duration,
            isShuffled: isShuffled ?? state.isShuffled,
            repeatMode: repeatMode ?? state.repeatMode,
            volume: volume ?? state.volume,
            playbackSpeed: playbackSpeed ?? state.playbackSpeed,
            queue: newQueue,
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
                queue: newQueue,
              )
            : state;

    return newState;
  }

  Future<void> _onGetCurrentQueue(
    GetCurrentQueueEvent event,
    Emitter<MusicPlayerState> emit,
  ) async {
    final queue = audioPlayerRepository.getCurrentQueue();
    emit(_copyStateWith(queue: queue));
  }

  Future<void> _onReorderQueue(
    ReorderQueueEvent event,
    Emitter<MusicPlayerState> emit,
  ) async {
    final result = await audioPlayerRepository.reorderQueue(
      event.oldIndex,
      event.newIndex,
    );
    
    result.fold(
      (failure) => print('Error reordering queue: ${failure.toString()}'),
      (_) {
        final newQueue = audioPlayerRepository.getCurrentQueue();
        emit(_copyStateWith(queue: newQueue));
      },
    );
  }

  Future<void> _onRemoveFromQueue(
    RemoveFromQueueEvent event,
    Emitter<MusicPlayerState> emit,
  ) async {
    final result = await audioPlayerRepository.removeFromQueue(event.index);
    
    result.fold(
      (failure) => print('Error removing from queue: ${failure.toString()}'),
      (_) {
        final newQueue = audioPlayerRepository.getCurrentQueue();
        final currentSong = audioPlayerRepository.currentSong;
        emit(_copyStateWith(
          currentSong: currentSong,
          queue: newQueue,
        ));
      },
    );
  }

  Future<void> _onClearQueue(
    ClearQueueEvent event,
    Emitter<MusicPlayerState> emit,
  ) async {
    final result = await audioPlayerRepository.clearQueue();
    
    result.fold(
      (failure) => print('Error clearing queue: ${failure.toString()}'),
      (_) {
        // Émettre Stopped avec un nouveau timestamp pour forcer le rebuild
        emit(MusicPlayerStopped());
      },
    );
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
