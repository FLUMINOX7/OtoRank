library;

import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../repositories/audio_player_repository.dart';
import '../entities/song.dart';

/// Use case pour charger une playlist dans le player
class LoadPlaylist {
  final AudioPlayerRepository repository;

  const LoadPlaylist(this.repository);

  Future<Either<Failure, void>> call(List<Song> songs, {int startIndex = 0}) async {
    return await repository.loadPlaylist(songs, startIndex: startIndex);
  }
}
