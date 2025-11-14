/// Use case pour ajouter des chansons à une playlist normale
library;

import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/song.dart';
import '../repositories/music_repository.dart';

class AddSongsToPlaylist {
  final MusicRepository repository;

  AddSongsToPlaylist(this.repository);

  Future<Either<Failure, void>> call(String playlistId, List<Song> songs) async {
    // Add songs one by one
    for (final song in songs) {
      final result = await repository.addSongToPlaylist(
        playlistId: playlistId,
        song: song,
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
