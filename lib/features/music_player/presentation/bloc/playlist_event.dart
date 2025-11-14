library;

import 'package:equatable/equatable.dart';
import '../../domain/entities/playlist.dart';
import '../../domain/entities/ranked_playlist.dart';
import '../../domain/entities/song.dart';

/// Events pour le PlaylistBloc
abstract class PlaylistEvent extends Equatable {
  const PlaylistEvent();

  @override
  List<Object?> get props => [];
}

class LoadAllPlaylistsEvent extends PlaylistEvent {}

class LoadRankedPlaylistsEvent extends PlaylistEvent {}

class CreatePlaylistEvent extends PlaylistEvent {
  final String name;
  final List<Song>? songs;
  final String? coverArtPath;

  const CreatePlaylistEvent({
    required this.name,
    this.songs,
    this.coverArtPath,
  });

  @override
  List<Object?> get props => [name, songs, coverArtPath];
}

class CreateRankedPlaylistEvent extends PlaylistEvent {
  final String name;
  final String rank;
  final List<Song>? songs;
  final String? coverArtPath;

  const CreateRankedPlaylistEvent({
    required this.name,
    required this.rank,
    this.songs,
    this.coverArtPath,
  });

  @override
  List<Object?> get props => [name, rank, songs, coverArtPath];
}

class UpdatePlaylistRankEvent extends PlaylistEvent {
  final String playlistId;
  final String newRank;

  const UpdatePlaylistRankEvent({
    required this.playlistId,
    required this.newRank,
  });

  @override
  List<Object?> get props => [playlistId, newRank];
}

class UpdatePlaylistEvent extends PlaylistEvent {
  final Playlist playlist;

  const UpdatePlaylistEvent(this.playlist);

  @override
  List<Object?> get props => [playlist];
}

class AddSongToPlaylistEvent extends PlaylistEvent {
  final String playlistId;
  final Song song;

  const AddSongToPlaylistEvent({
    required this.playlistId,
    required this.song,
  });

  @override
  List<Object?> get props => [playlistId, song];
}

class AddSongsToPlaylistEvent extends PlaylistEvent {
  final String playlistId;
  final List<Song> songs;

  const AddSongsToPlaylistEvent({
    required this.playlistId,
    required this.songs,
  });

  @override
  List<Object?> get props => [playlistId, songs];
}

class RemoveSongFromPlaylistEvent extends PlaylistEvent {
  final String playlistId;
  final String songId;

  const RemoveSongFromPlaylistEvent({
    required this.playlistId,
    required this.songId,
  });

  @override
  List<Object?> get props => [playlistId, songId];
}

class DeletePlaylistEvent extends PlaylistEvent {
  final String playlistId;

  const DeletePlaylistEvent(this.playlistId);

  @override
  List<Object?> get props => [playlistId];
}

class ReorderPlaylistSongsEvent extends PlaylistEvent {
  final String playlistId;
  final int oldIndex;
  final int newIndex;

  const ReorderPlaylistSongsEvent({
    required this.playlistId,
    required this.oldIndex,
    required this.newIndex,
  });

  @override
  List<Object?> get props => [playlistId, oldIndex, newIndex];
}
