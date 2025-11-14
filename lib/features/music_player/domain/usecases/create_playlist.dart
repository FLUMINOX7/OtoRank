library;

import 'package:dartz/dartz.dart';
import 'package:otorank/core/errors/failures.dart';
import '../repositories/music_repository.dart';
import '../entities/playlist.dart';
import '../entities/song.dart';

/// Use case pour créer une nouvelle playlist
class CreatePlaylist {
  final MusicRepository repository;

  const CreatePlaylist(this.repository);

  Future<Either<Failure, Playlist>> call({
    required String name,
    List<Song>? songs,
    String? coverArtPath,
  }) async {
    return await repository.createPlaylist(
      name: name,
      songs: songs,
      coverArtPath: coverArtPath,
    );
  }
}
