library;

import 'package:dartz/dartz.dart';
import 'package:otorank/core/errors/failures.dart';
import '../repositories/music_repository.dart';
import '../entities/ranked_playlist.dart';

/// Use case pour mettre à jour le rang d'une playlist
class UpdatePlaylistRank {
  final MusicRepository repository;

  const UpdatePlaylistRank(this.repository);

  Future<Either<Failure, RankedPlaylist>> call({
    required String playlistId,
    required String newRank,
  }) async {
    return await repository.updatePlaylistRank(
      playlistId: playlistId,
      newRank: newRank,
    );
  }
}
