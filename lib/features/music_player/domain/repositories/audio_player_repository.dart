library;

import 'package:dartz/dartz.dart';
import 'package:otorank/core/errors/failures.dart';
import '../entities/song.dart';

/// États de lecture du player
enum PlaybackState {
  playing,
  paused,
  stopped,
  loading,
  buffering,
  completed,
}

/// Modes de répétition
enum RepeatMode {
  off,
  one,
  all,
}

/// Interface du repository pour le contrôle du lecteur audio
abstract class AudioPlayerRepository {
  /// Charge et joue une chanson
  Future<Either<Failure, void>> playSong(Song song);

  /// Charge une liste de chansons (queue)
  Future<Either<Failure, void>> loadPlaylist(List<Song> songs, {int startIndex = 0});

  /// Récupère la queue actuelle
  List<Song> getCurrentQueue();

  /// Réordonne la queue
  Future<Either<Failure, void>> reorderQueue(int oldIndex, int newIndex);

  /// Retire une chanson de la queue
  Future<Either<Failure, void>> removeFromQueue(int index);

  /// Vide la queue
  Future<Either<Failure, void>> clearQueue();

  /// Met en pause la lecture
  Future<Either<Failure, void>> pause();

  /// Reprend la lecture
  Future<Either<Failure, void>> resume();

  /// Arrête la lecture
  Future<Either<Failure, void>> stop();

  /// Passe à la chanson suivante
  Future<Either<Failure, void>> skipToNext();

  /// Revient à la chanson précédente
  Future<Either<Failure, void>> skipToPrevious();

  /// Se déplace à une position spécifique dans la chanson
  Future<Either<Failure, void>> seekTo(Duration position);

  /// Change le mode de lecture aléatoire
  Future<Either<Failure, void>> setShuffleMode(bool enabled);

  /// Change le mode de répétition
  Future<Either<Failure, void>> setRepeatMode(RepeatMode mode);

  /// Change le volume (0.0 à 1.0)
  Future<Either<Failure, void>> setVolume(double volume);

  /// Change la vitesse de lecture (0.5 à 2.0)
  Future<Either<Failure, void>> setPlaybackSpeed(double speed);

  /// Récupère l'état actuel de lecture
  Stream<PlaybackState> get playbackStateStream;

  /// Récupère la position actuelle dans la chanson
  Stream<Duration> get positionStream;

  /// Récupère la durée totale de la chanson
  Stream<Duration?> get durationStream;

  /// Récupère la chanson en cours de lecture
  Stream<Song?> get currentSongStream;

  /// Récupère le mode shuffle
  Stream<bool> get shuffleModeStream;

  /// Récupère le mode repeat
  Stream<RepeatMode> get repeatModeStream;

  /// Récupère la chanson courante (synchrone)
  Song? get currentSong;

  /// Libère les ressources
  Future<void> dispose();
}
