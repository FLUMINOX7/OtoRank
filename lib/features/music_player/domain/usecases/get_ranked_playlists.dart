library;

import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../repositories/music_repository.dart';
import '../entities/ranked_playlist.dart';

/// Use case pour récupérer toutes les playlists ranked
class GetRankedPlaylists {
  final MusicRepository repository;

  const GetRankedPlaylists(this.repository);

  Future<Either<Failure, List<RankedPlaylist>>> call() async {
    return await repository.getRankedPlaylists();
  }
}
