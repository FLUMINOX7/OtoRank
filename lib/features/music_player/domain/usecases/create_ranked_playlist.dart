library;

import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../repositories/music_repository.dart';
import '../entities/ranked_playlist.dart';
import '../entities/song.dart';

/// Use case pour créer une nouvelle playlist ranked
class CreateRankedPlaylist {
  final MusicRepository repository;

  const CreateRankedPlaylist(this.repository);

  Future<Either<Failure, RankedPlaylist>> call({
    required String name,
    required String rank,
    List<Song>? songs,
    String? coverArtPath,
  }) async {
    return await repository.createRankedPlaylist(
      name: name,
      rank: rank,
      songs: songs,
      coverArtPath: coverArtPath,
    );
  }
}
