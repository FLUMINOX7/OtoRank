library;

import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:just_audio/just_audio.dart';
import 'package:otorank/core/errors/failures.dart';
import '../../domain/entities/song.dart';
import '../../domain/repositories/audio_player_repository.dart';

/// Implémentation du AudioPlayerRepository avec just_audio
class AudioPlayerRepositoryImpl implements AudioPlayerRepository {
  final AudioPlayer _audioPlayer;
  
  // Streams controllers
  final StreamController<PlaybackState> _playbackStateController =
      StreamController<PlaybackState>.broadcast();
  final StreamController<Song?> _currentSongController =
      StreamController<Song?>.broadcast();
  final StreamController<bool> _shuffleModeController =
      StreamController<bool>.broadcast();
  final StreamController<RepeatMode> _repeatModeController =
      StreamController<RepeatMode>.broadcast();

  Song? _currentSong;
  List<Song> _currentPlaylist = [];
  bool _isShuffled = false;
  RepeatMode _repeatMode = RepeatMode.off;

  AudioPlayerRepositoryImpl(this._audioPlayer) {
    _initializePlayer();
  }

  void _initializePlayer() {
    // Écoute les changements d'état du player
    _audioPlayer.playerStateStream.listen((playerState) {
      final playbackState = _mapPlayerState(playerState);
      _playbackStateController.add(playbackState);
    });

    // Écoute la fin de la lecture
    _audioPlayer.processingStateStream.listen((processingState) {
      if (processingState == ProcessingState.completed) {
        _playbackStateController.add(PlaybackState.completed);
        _handleSongCompleted();
      }
    });
  }

  PlaybackState _mapPlayerState(PlayerState playerState) {
    if (playerState.playing) {
      return PlaybackState.playing;
    } else if (playerState.processingState == ProcessingState.loading ||
        playerState.processingState == ProcessingState.buffering) {
      return PlaybackState.loading;
    } else {
      return PlaybackState.paused;
    }
  }

  void _handleSongCompleted() async {
    // Gère la répétition et passage automatique au suivant
    if (_repeatMode == RepeatMode.one) {
      await _audioPlayer.seek(Duration.zero);
      await _audioPlayer.play();
    } else if (_repeatMode == RepeatMode.all || _currentPlaylist.length > 1) {
      await skipToNext();
    }
  }

  @override
  Future<Either<Failure, void>> playSong(Song song) async {
    try {
      await _audioPlayer.setFilePath(song.filePath);
      await _audioPlayer.play();
      
      _currentSong = song;
      _currentPlaylist = [song];
      _currentSongController.add(song);
      
      return const Right(null);
    } catch (e) {
      return Left(PlayerFailure(message: 'Erreur lors de la lecture: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> loadPlaylist(
    List<Song> songs, {
    int startIndex = 0,
  }) async {
    try {
      if (songs.isEmpty) {
        return Left(PlayerFailure(message: 'La playlist est vide'));
      }

      _currentPlaylist = songs;
      
      // Crée une playlist audio
      final playlist = ConcatenatingAudioSource(
        children: songs.map((song) {
          return AudioSource.file(song.filePath);
        }).toList(),
      );

      await _audioPlayer.setAudioSource(
        playlist,
        initialIndex: startIndex,
      );
      await _audioPlayer.play();

      _currentSong = songs[startIndex];
      _currentSongController.add(_currentSong);

      return const Right(null);
    } catch (e) {
      return Left(PlayerFailure(message: 'Erreur lors du chargement de la playlist: $e'));
    }
  }

  @override
  List<Song> getCurrentQueue() {
    return List.unmodifiable(_currentPlaylist);
  }

  @override
  Future<Either<Failure, void>> reorderQueue(int oldIndex, int newIndex) async {
    try {
      if (oldIndex < 0 || oldIndex >= _currentPlaylist.length ||
          newIndex < 0 || newIndex >= _currentPlaylist.length) {
        return Left(PlayerFailure(message: 'Index invalide'));
      }

      // Réordonne la liste
      final song = _currentPlaylist.removeAt(oldIndex);
      _currentPlaylist.insert(newIndex, song);

      // Recrée la source audio avec le nouvel ordre
      final playlist = ConcatenatingAudioSource(
        children: _currentPlaylist.map((song) {
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

      return const Right(null);
    } catch (e) {
      return Left(PlayerFailure(message: 'Erreur lors du réordonnancement: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> removeFromQueue(int index) async {
    try {
      if (index < 0 || index >= _currentPlaylist.length) {
        return Left(PlayerFailure(message: 'Index invalide'));
      }

      if (_currentPlaylist.length == 1) {
        return clearQueue();
      }

      final currentIndex = _audioPlayer.currentIndex ?? 0;
      
      // Si on supprime la chanson actuelle, passer à la suivante
      if (index == currentIndex) {
        if (index < _currentPlaylist.length - 1) {
          await skipToNext();
        } else if (index > 0) {
          await skipToPrevious();
        }
      }

      _currentPlaylist.removeAt(index);

      // Recrée la source audio
      final playlist = ConcatenatingAudioSource(
        children: _currentPlaylist.map((song) {
          return AudioSource.file(song.filePath);
        }).toList(),
      );

      final newIndex = _audioPlayer.currentIndex ?? 0;
      final currentPosition = _audioPlayer.position;

      await _audioPlayer.setAudioSource(
        playlist,
        initialIndex: newIndex.clamp(0, _currentPlaylist.length - 1),
        initialPosition: currentPosition,
      );

      return const Right(null);
    } catch (e) {
      return Left(PlayerFailure(message: 'Erreur lors de la suppression: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> clearQueue() async {
    try {
      await _audioPlayer.stop();
      _currentPlaylist.clear();
      _currentSong = null;
      _currentSongController.add(null);
      _playbackStateController.add(PlaybackState.stopped);
      return const Right(null);
    } catch (e) {
      return Left(PlayerFailure(message: 'Erreur lors du vidage de la queue: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> pause() async {
    try {
      await _audioPlayer.pause();
      return const Right(null);
    } catch (e) {
      return Left(PlayerFailure(message: 'Erreur lors de la pause: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> resume() async {
    try {
      await _audioPlayer.play();
      return const Right(null);
    } catch (e) {
      return Left(PlayerFailure(message: 'Erreur lors de la reprise: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> stop() async {
    try {
      await _audioPlayer.stop();
      _playbackStateController.add(PlaybackState.stopped);
      return const Right(null);
    } catch (e) {
      return Left(PlayerFailure(message: 'Erreur lors de l\'arrêt: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> skipToNext() async {
    try {
      if (_audioPlayer.hasNext) {
        await _audioPlayer.seekToNext();
        _updateCurrentSong();
      } else if (_repeatMode == RepeatMode.all && _currentPlaylist.isNotEmpty) {
        await _audioPlayer.seek(Duration.zero, index: 0);
        await _audioPlayer.play();
        _currentSong = _currentPlaylist.first;
        _currentSongController.add(_currentSong);
      }
      return const Right(null);
    } catch (e) {
      return Left(PlayerFailure(message: 'Erreur lors du passage au suivant: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> skipToPrevious() async {
    try {
      if (_audioPlayer.hasPrevious) {
        await _audioPlayer.seekToPrevious();
        _updateCurrentSong();
      } else if (_repeatMode == RepeatMode.all && _currentPlaylist.isNotEmpty) {
        await _audioPlayer.seek(Duration.zero, index: _currentPlaylist.length - 1);
        await _audioPlayer.play();
        _currentSong = _currentPlaylist.last;
        _currentSongController.add(_currentSong);
      }
      return const Right(null);
    } catch (e) {
      return Left(PlayerFailure(message: 'Erreur lors du passage au précédent: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> seekTo(Duration position) async {
    try {
      await _audioPlayer.seek(position);
      return const Right(null);
    } catch (e) {
      return Left(PlayerFailure(message: 'Erreur lors du déplacement: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> setShuffleMode(bool enabled) async {
    try {
      await _audioPlayer.setShuffleModeEnabled(enabled);
      _isShuffled = enabled;
      _shuffleModeController.add(enabled);
      return const Right(null);
    } catch (e) {
      return Left(PlayerFailure(message: 'Erreur lors du changement de mode shuffle: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> setRepeatMode(RepeatMode mode) async {
    try {
      _repeatMode = mode;
      _repeatModeController.add(mode);
      
      // Configure just_audio loop mode
      switch (mode) {
        case RepeatMode.off:
          await _audioPlayer.setLoopMode(LoopMode.off);
          break;
        case RepeatMode.one:
          await _audioPlayer.setLoopMode(LoopMode.one);
          break;
        case RepeatMode.all:
          await _audioPlayer.setLoopMode(LoopMode.all);
          break;
      }
      
      return const Right(null);
    } catch (e) {
      return Left(PlayerFailure(message: 'Erreur lors du changement de mode repeat: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> setVolume(double volume) async {
    try {
      await _audioPlayer.setVolume(volume.clamp(0.0, 1.0));
      return const Right(null);
    } catch (e) {
      return Left(PlayerFailure(message: 'Erreur lors du changement de volume: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> setPlaybackSpeed(double speed) async {
    try {
      await _audioPlayer.setSpeed(speed.clamp(0.5, 2.0));
      return const Right(null);
    } catch (e) {
      return Left(PlayerFailure(message: 'Erreur lors du changement de vitesse: $e'));
    }
  }

  void _updateCurrentSong() {
    final currentIndex = _audioPlayer.currentIndex;
    if (currentIndex != null && currentIndex < _currentPlaylist.length) {
      _currentSong = _currentPlaylist[currentIndex];
      _currentSongController.add(_currentSong);
    }
  }

  @override
  Stream<PlaybackState> get playbackStateStream => _playbackStateController.stream;

  @override
  Stream<Duration> get positionStream => _audioPlayer.positionStream;

  @override
  Stream<Duration?> get durationStream => _audioPlayer.durationStream;

  @override
  Stream<Song?> get currentSongStream => _currentSongController.stream;

  @override
  Stream<bool> get shuffleModeStream => _shuffleModeController.stream;

  @override
  Stream<RepeatMode> get repeatModeStream => _repeatModeController.stream;

  @override
  Song? get currentSong => _currentSong;

  @override
  Future<void> dispose() async {
    await _audioPlayer.dispose();
    await _playbackStateController.close();
    await _currentSongController.close();
    await _shuffleModeController.close();
    await _repeatModeController.close();
  }
}
