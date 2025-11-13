library;

import 'package:dartz/dartz.dart';
import 'package:otorank/core/errors/failures.dart';
import '../repositories/audio_player_repository.dart';
import '../entities/song.dart';

/// Use case pour jouer une chanson
class PlaySong {
  final AudioPlayerRepository repository;

  const PlaySong(this.repository);

  Future<Either<Failure, void>> call(Song song) async {
    return await repository.playSong(song);
  }
}
