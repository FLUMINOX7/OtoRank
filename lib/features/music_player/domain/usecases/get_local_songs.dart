library;

import 'package:dartz/dartz.dart';
import 'package:otorank/core/errors/failures.dart';
import '../repositories/music_repository.dart';
import '../entities/song.dart';

/// Use case pour récupérer toutes les chansons locales
class GetLocalSongs {
  final MusicRepository repository;

  const GetLocalSongs(this.repository);

  Future<Either<Failure, List<Song>>> call() async {
    return await repository.getLocalSongs();
  }
}
