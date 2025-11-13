library;

import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../repositories/music_repository.dart';
import '../entities/playlist.dart';

/// Use case pour récupérer toutes les playlists
class GetAllPlaylists {
  final MusicRepository repository;

  const GetAllPlaylists(this.repository);

  Future<Either<Failure, List<Playlist>>> call() async {
    return await repository.getAllPlaylists();
  }
}
