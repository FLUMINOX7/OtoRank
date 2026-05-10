/// Use case pour retirer des chansons d'une playlist
library;

import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/music_repository.dart';

class RemoveSongsFromPlaylist {
  final MusicRepository repository;

  RemoveSongsFromPlaylist(this.repository);

  Future<Either<Failure, void>> call(String playlistId, List<String> songIds) async {
    // Remove songs one by one
    for (final songId in songIds) {
      final result = await repository.removeSongFromPlaylist(
        playlistId: playlistId,
        songId: songId,
      );
      
      if (result.isLeft()) {
        return result.fold(
          (failure) => Left(failure),
          (_) => const Right(null),
        );
      }
    }
    
    return const Right(null);
  }
}
