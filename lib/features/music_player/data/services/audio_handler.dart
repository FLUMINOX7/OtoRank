library;

import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import '../../domain/entities/song.dart';

/// Handler pour le service audio en arrière-plan
class OtoRankAudioHandler extends BaseAudioHandler with QueueHandler, SeekHandler {
  final AudioPlayer _audioPlayer;
  
  // Stocke la queue courante
  final List<Song> _queue = [];
  int? _currentIndex;

  OtoRankAudioHandler(this._audioPlayer) {
    _init();
  }

  void _init() {
    // Synchroniser les états audio avec le service
    _audioPlayer.playbackEventStream.listen((event) {
      final playing = _audioPlayer.playing;
      
      playbackState.add(playbackState.value.copyWith(
        controls: [
          MediaControl.skipToPrevious,
          if (playing) MediaControl.pause else MediaControl.play,
          MediaControl.skipToNext,
          MediaControl.stop,
        ],
        systemActions: const {
          MediaAction.seek,
          MediaAction.seekForward,
          MediaAction.seekBackward,
        },
        androidCompactActionIndices: const [0, 1, 2],
        processingState: const {
          ProcessingState.idle: AudioProcessingState.idle,
          ProcessingState.loading: AudioProcessingState.loading,
          ProcessingState.buffering: AudioProcessingState.buffering,
          ProcessingState.ready: AudioProcessingState.ready,
          ProcessingState.completed: AudioProcessingState.completed,
        }[_audioPlayer.processingState]!,
        playing: playing,
        updatePosition: _audioPlayer.position,
        bufferedPosition: _audioPlayer.bufferedPosition,
        speed: _audioPlayer.speed,
        queueIndex: _currentIndex,
      ));
    });

    // Mettre à jour position périodiquement
    _audioPlayer.positionStream.listen((position) {
      playbackState.add(playbackState.value.copyWith(
        updatePosition: position,
      ));
    });
  }

  /// Charge une liste de chansons
  Future<void> loadQueue(List<Song> songs, {int startIndex = 0}) async {
    _queue.clear();
    _queue.addAll(songs);
    _currentIndex = startIndex;

    // Convertir en MediaItems pour audio_service
    queue.add(_queue.map((song) => MediaItem(
      id: song.id,
      title: song.title,
      artist: song.artist ?? 'Unknown Artist',
      duration: song.duration,
      artUri: null, // TODO: Add album art if available
    )).toList());

    // Mettre à jour le MediaItem courant
    if (_currentIndex != null && _currentIndex! < _queue.length) {
      final currentSong = _queue[_currentIndex!];
      mediaItem.add(MediaItem(
        id: currentSong.id,
        title: currentSong.title,
        artist: currentSong.artist ?? 'Unknown Artist',
        duration: currentSong.duration,
      ));
    }

    // Créer la playlist audio
    final playlist = ConcatenatingAudioSource(
      children: _queue.map((song) {
        return AudioSource.file(song.filePath);
      }).toList(),
    );

    await _audioPlayer.setAudioSource(
      playlist,
      initialIndex: startIndex,
    );
  }

  @override
  Future<void> play() async {
    await _audioPlayer.play();
  }

  @override
  Future<void> pause() async {
    await _audioPlayer.pause();
  }

  @override
  Future<void> stop() async {
    await _audioPlayer.stop();
    await super.stop();
  }

  @override
  Future<void> seek(Duration position) async {
    await _audioPlayer.seek(position);
  }

  @override
  Future<void> skipToNext() async {
    if (_audioPlayer.hasNext) {
      await _audioPlayer.seekToNext();
      _currentIndex = _audioPlayer.currentIndex;
      _updateMediaItem();
    }
  }

  @override
  Future<void> skipToPrevious() async {
    if (_audioPlayer.hasPrevious) {
      await _audioPlayer.seekToPrevious();
      _currentIndex = _audioPlayer.currentIndex;
      _updateMediaItem();
    }
  }

  @override
  Future<void> skipToQueueItem(int index) async {
    if (index >= 0 && index < _queue.length) {
      await _audioPlayer.seek(Duration.zero, index: index);
      _currentIndex = index;
      _updateMediaItem();
      await _audioPlayer.play();
    }
  }

  @override
  Future<void> setRepeatMode(AudioServiceRepeatMode repeatMode) async {
    final loopMode = switch (repeatMode) {
      AudioServiceRepeatMode.none => LoopMode.off,
      AudioServiceRepeatMode.one => LoopMode.one,
      AudioServiceRepeatMode.all => LoopMode.all,
      _ => LoopMode.off,
    };
    await _audioPlayer.setLoopMode(loopMode);
    
    playbackState.add(playbackState.value.copyWith(
      repeatMode: repeatMode,
    ));
  }

  @override
  Future<void> setShuffleMode(AudioServiceShuffleMode shuffleMode) async {
    final enabled = shuffleMode == AudioServiceShuffleMode.all;
    await _audioPlayer.setShuffleModeEnabled(enabled);
    
    playbackState.add(playbackState.value.copyWith(
      shuffleMode: shuffleMode,
    ));
  }

  void _updateMediaItem() {
    if (_currentIndex != null && _currentIndex! < _queue.length) {
      final currentSong = _queue[_currentIndex!];
      mediaItem.add(MediaItem(
        id: currentSong.id,
        title: currentSong.title,
        artist: currentSong.artist ?? 'Unknown Artist',
        duration: currentSong.duration,
      ));
    }
  }

  /// Récupère la queue actuelle
  List<Song> getCurrentQueue() {
    return List.unmodifiable(_queue);
  }

  /// Réordonne la queue
  Future<void> reorderQueue(int oldIndex, int newIndex) async {
    if (oldIndex < 0 || oldIndex >= _queue.length ||
        newIndex < 0 || newIndex >= _queue.length) {
      return;
    }

    final song = _queue.removeAt(oldIndex);
    _queue.insert(newIndex, song);

    // Recréer la source audio
    final playlist = ConcatenatingAudioSource(
      children: _queue.map((song) {
        return AudioSource.file(song.filePath);
      }).toList(),
    );

    final currentIndex = _audioPlayer.currentIndex ?? 0;
    final currentPosition = _audioPlayer.position;

    await _audioPlayer.setAudioSource(
      playlist,
      initialIndex: currentIndex,
      initialPosition: currentPosition,
    );

    // Mettre à jour la queue dans audio_service
    queue.add(_queue.map((song) => MediaItem(
      id: song.id,
      title: song.title,
      artist: song.artist ?? 'Unknown Artist',
      duration: song.duration,
    )).toList());
  }

  /// Retire une chanson de la queue
  Future<void> removeFromQueue(int index) async {
    if (index < 0 || index >= _queue.length || _queue.length == 1) {
      return;
    }

    final currentIndex = _audioPlayer.currentIndex ?? 0;
    
    // Si on supprime la chanson actuelle, passer à la suivante
    if (index == currentIndex) {
      if (index < _queue.length - 1) {
        await skipToNext();
      } else if (index > 0) {
        await skipToPrevious();
      }
    }

    _queue.removeAt(index);

    // Recréer la source audio
    final playlist = ConcatenatingAudioSource(
      children: _queue.map((song) {
        return AudioSource.file(song.filePath);
      }).toList(),
    );

    final newIndex = _audioPlayer.currentIndex ?? 0;
    final currentPosition = _audioPlayer.position;

    await _audioPlayer.setAudioSource(
      playlist,
      initialIndex: newIndex.clamp(0, _queue.length - 1),
      initialPosition: currentPosition,
    );

    // Mettre à jour la queue
    queue.add(_queue.map((song) => MediaItem(
      id: song.id,
      title: song.title,
      artist: song.artist ?? 'Unknown Artist',
      duration: song.duration,
    )).toList());
  }

  /// Vide la queue
  Future<void> clearQueue() async {
    await _audioPlayer.stop();
    _queue.clear();
    _currentIndex = null;
    queue.add([]);
    mediaItem.add(null);
  }
}
