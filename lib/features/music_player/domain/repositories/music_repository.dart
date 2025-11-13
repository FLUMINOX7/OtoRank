library;

import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/song.dart';
import '../entities/playlist.dart';
import '../entities/ranked_playlist.dart';

/// Interface du repository pour la gestion de la musique
abstract class MusicRepository {
  /// Récupère toutes les chansons locales du téléphone
  Future<Either<Failure, List<Song>>> getLocalSongs();

  /// Récupère une chanson par son ID
  Future<Either<Failure, Song>> getSongById(String id);

  /// Recherche des chansons par titre, artiste ou album
  Future<Either<Failure, List<Song>>> searchSongs(String query);

  /// Récupère toutes les playlists (normales et ranked)
  Future<Either<Failure, List<Playlist>>> getAllPlaylists();

  /// Récupère toutes les playlists ranked
  Future<Either<Failure, List<RankedPlaylist>>> getRankedPlaylists();

  /// Récupère une playlist par son ID
  Future<Either<Failure, Playlist>> getPlaylistById(String id);

  /// Crée une nouvelle playlist
  Future<Either<Failure, Playlist>> createPlaylist({
    required String name,
    List<Song>? songs,
    String? coverArtPath,
  });

  /// Crée une nouvelle playlist ranked
  Future<Either<Failure, RankedPlaylist>> createRankedPlaylist({
    required String name,
    required String rank,
    List<Song>? songs,
    String? coverArtPath,
  });

  /// Met à jour une playlist
  Future<Either<Failure, Playlist>> updatePlaylist(Playlist playlist);

  /// Met à jour le rang d'une playlist ranked
  Future<Either<Failure, RankedPlaylist>> updatePlaylistRank({
    required String playlistId,
    required String newRank,
  });

  /// Ajoute une chanson à une playlist
  Future<Either<Failure, Playlist>> addSongToPlaylist({
    required String playlistId,
    required Song song,
  });

  /// Retire une chanson d'une playlist
  Future<Either<Failure, Playlist>> removeSongFromPlaylist({
    required String playlistId,
    required String songId,
  });

  /// Supprime une playlist
  Future<Either<Failure, void>> deletePlaylist(String playlistId);

  /// Réorganise les chansons dans une playlist
  Future<Either<Failure, Playlist>> reorderPlaylistSongs({
    required String playlistId,
    required int oldIndex,
    required int newIndex,
  });
}
