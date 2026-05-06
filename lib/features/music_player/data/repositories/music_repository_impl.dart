library;

import 'package:dartz/dartz.dart';
import 'package:otorank/core/errors/failures.dart';
import '../../domain/entities/song.dart';
import '../../domain/entities/playlist.dart';
import '../../domain/entities/ranked_playlist.dart';
import '../../domain/repositories/music_repository.dart';
import '../datasources/local_music_datasource.dart';
import '../datasources/playlist_local_datasource.dart';
import '../models/playlist_model.dart';
import '../models/ranked_playlist_model.dart';
import '../models/song_model.dart';
import 'package:uuid/uuid.dart';

/// Implémentation du MusicRepository
class MusicRepositoryImpl implements MusicRepository {
  final LocalMusicDataSource localMusicDataSource;
  final PlaylistLocalDataSource playlistLocalDataSource;
  final Uuid uuid = const Uuid();

  MusicRepositoryImpl({
    required this.localMusicDataSource,
    required this.playlistLocalDataSource,
  });

  @override
  Future<Either<Failure, List<Song>>> getLocalSongs() async {
    try {
      final songs = await localMusicDataSource.scanLocalMusic();
      return Right(songs);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Song>> getSongById(String id) async {
    try {
      final song = await localMusicDataSource.getSongById(id);
      if (song == null) {
        return Left(CacheFailure(message: 'Chanson non trouvée'));
      }
      return Right(song);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Song>>> searchSongs(String query) async {
    try {
      final songs = await localMusicDataSource.searchSongs(query);
      return Right(songs);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Playlist>>> getAllPlaylists() async {
    try {
      final playlists = await playlistLocalDataSource.getAllPlaylists();
      return Right(playlists);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<RankedPlaylist>>> getRankedPlaylists() async {
    try {
      final rankedPlaylists = await playlistLocalDataSource.getRankedPlaylists();
      return Right(rankedPlaylists);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Playlist>> getPlaylistById(String id) async {
    try {
      final playlist = await playlistLocalDataSource.getPlaylistById(id);
      if (playlist == null) {
        return Left(CacheFailure(message: 'Playlist non trouvée'));
      }
      return Right(playlist);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Playlist>> createPlaylist({
    required String name,
    List<Song>? songs,
    String? coverArtPath,
  }) async {
    try {
      final playlist = PlaylistModel(
        id: uuid.v4(),
        name: name,
        songs: songs ?? [],
        createdDate: DateTime.now(),
        coverArtPath: coverArtPath,
      );
      
      await playlistLocalDataSource.savePlaylist(playlist);
      return Right(playlist);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, RankedPlaylist>> createRankedPlaylist({
    required String name,
    required String rank,
    List<Song>? songs,
    String? coverArtPath,
  }) async {
    try {
      final playlist = PlaylistModel(
        id: uuid.v4(),
        name: name,
        songs: songs ?? [],
        createdDate: DateTime.now(),
        coverArtPath: coverArtPath,
      );
      
      final rankedPlaylist = RankedPlaylistModel(
        playlist: playlist,
        rank: rank,
        rankOrder: PlaylistRank.getOrder(rank),
      );
      
      await playlistLocalDataSource.saveRankedPlaylist(rankedPlaylist);
      return Right(rankedPlaylist);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Playlist>> updatePlaylist(Playlist playlist) async {
    try {
      final updatedPlaylist = PlaylistModel.fromEntity(playlist).copyWith(
        modifiedDate: DateTime.now(),
      );
      
      await playlistLocalDataSource.savePlaylist(updatedPlaylist);
      return Right(updatedPlaylist);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, RankedPlaylist>> updatePlaylistRank({
    required String playlistId,
    required String newRank,
  }) async {
    try {
      // Récupère la playlist actuelle
      final playlistResult = await getPlaylistById(playlistId);
      
      return playlistResult.fold(
        (failure) => Left(failure),
        (playlist) async {
          // Vérifie si c'est une ranked playlist
          final rankedPlaylists = await playlistLocalDataSource.getRankedPlaylists();
          RankedPlaylistModel? existingRanked;
          
          for (final rp in rankedPlaylists) {
            if (rp.id == playlistId) {
              existingRanked = rp;
              break;
            }
          }
          
          if (existingRanked == null) {
            return Left(CacheFailure(message: 'Playlist ranked non trouvée'));
          }
          
          final updatedRanked = existingRanked.copyWith(
            rank: newRank,
            rankOrder: PlaylistRank.getOrder(newRank),
          );
          
          await playlistLocalDataSource.saveRankedPlaylist(updatedRanked);
          return Right(updatedRanked);
        },
      );
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Playlist>> addSongToPlaylist({
    required String playlistId,
    required Song song,
  }) async {
    try {
      final playlistResult = await getPlaylistById(playlistId);
      
      return playlistResult.fold(
        (failure) => Left(failure),
        (playlist) async {
          // Avoid duplicates
          final alreadyPresent = playlist.songs.any((s) => s.id == song.id);

          final updatedSongs = alreadyPresent
              ? List<Song>.from(playlist.songs)
              : List<Song>.from(playlist.songs)..add(song);

          final updatedPlaylist = playlist.copyWith(
            songs: updatedSongs,
            modifiedDate: DateTime.now(),
          );

          // Propagate to lower-ranked playlists with the same base name
          try {
            final rankedPlaylists = await playlistLocalDataSource.getRankedPlaylists();

            // Find if this playlist is a ranked playlist
            RankedPlaylistModel? targetRanked;
            for (final rp in rankedPlaylists) {
              if (rp.playlist.id == playlist.id) {
                targetRanked = rp;
                break;
              }
            }

            if (targetRanked != null) {
              final targetOrder = targetRanked.rankOrder ?? PlaylistRank.getOrder(targetRanked.rank);

              // For all ranked playlists with same base name and order >= targetOrder,
              // ensure the song is present (propagate to equal or lower ranks)
              for (final rp in rankedPlaylists) {
                final sameName = rp.playlist.name == targetRanked.playlist.name;
                final rpOrder = rp.rankOrder ?? PlaylistRank.getOrder(rp.rank);
                if (sameName && rpOrder >= targetOrder) {
                  final exists = rp.playlist.songs.any((s) => s.id == song.id);
                  if (!exists) {
                    final newSongs = List<Song>.from(rp.playlist.songs)..add(song);
                    final updatedRpPlaylist = PlaylistModel.fromEntity(rp.playlist).copyWith(
                      songs: newSongs,
                      modifiedDate: DateTime.now(),
                    );
                    final updatedRanked = RankedPlaylistModel(
                      playlist: updatedRpPlaylist,
                      rank: rp.rank,
                      rankOrder: rp.rankOrder,
                    );
                    await playlistLocalDataSource.saveRankedPlaylist(updatedRanked);
                  }
                }
              }
            }
          } catch (e) {
            // If propagation fails, continue but log via failure return below if needed
          }

          return await updatePlaylist(updatedPlaylist);
        },
      );
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Playlist>> removeSongFromPlaylist({
    required String playlistId,
    required String songId,
  }) async {
    try {
      final playlistResult = await getPlaylistById(playlistId);
      
      return playlistResult.fold(
        (failure) => Left(failure),
        (playlist) async {
          final updatedSongs = playlist.songs
              .where((song) => song.id != songId)
              .toList();
          final updatedPlaylist = playlist.copyWith(
            songs: updatedSongs,
            modifiedDate: DateTime.now(),
          );
          
          return await updatePlaylist(updatedPlaylist);
        },
      );
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deletePlaylist(String playlistId) async {
    try {
      await playlistLocalDataSource.deletePlaylist(playlistId);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Playlist>> reorderPlaylistSongs({
    required String playlistId,
    required int oldIndex,
    required int newIndex,
  }) async {
    try {
      final playlistResult = await getPlaylistById(playlistId);
      
      return playlistResult.fold(
        (failure) => Left(failure),
        (playlist) async {
          final updatedSongs = List<Song>.from(playlist.songs);
          final song = updatedSongs.removeAt(oldIndex);
          updatedSongs.insert(newIndex, song);
          
          final updatedPlaylist = playlist.copyWith(
            songs: updatedSongs,
            modifiedDate: DateTime.now(),
          );
          
          return await updatePlaylist(updatedPlaylist);
        },
      );
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }
}
