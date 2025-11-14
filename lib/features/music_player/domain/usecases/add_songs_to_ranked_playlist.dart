/// Use case pour ajouter des chansons à une playlist ranked avec un rank spécifique
library;

import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/song.dart';
import '../repositories/music_repository.dart';

class AddSongsToRankedPlaylist {
  final MusicRepository repository;

  AddSongsToRankedPlaylist(this.repository);

  Future<Either<Failure, void>> call(
    String playlistId,
    List<Song> songs,
    String rank,
  ) async {
    // For ranked playlists, we add songs one by one
    // The rank is already set at playlist level, not per song
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
