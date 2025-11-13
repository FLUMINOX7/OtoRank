library;

import 'package:equatable/equatable.dart';
import '../../domain/entities/playlist.dart';
import '../../domain/entities/ranked_playlist.dart';

/// States pour le PlaylistBloc
abstract class PlaylistState extends Equatable {
  const PlaylistState();

  @override
  List<Object?> get props => [];
}

class PlaylistInitial extends PlaylistState {}

class PlaylistLoading extends PlaylistState {}

class PlaylistsLoaded extends PlaylistState {
  final List<Playlist> playlists;
  final List<RankedPlaylist> rankedPlaylists;

  const PlaylistsLoaded({
    required this.playlists,
    required this.rankedPlaylists,
  });

  @override
  List<Object?> get props => [playlists, rankedPlaylists];
}

class PlaylistCreated extends PlaylistState {
  final Playlist playlist;

  const PlaylistCreated(this.playlist);

  @override
  List<Object?> get props => [playlist];
}

class RankedPlaylistCreated extends PlaylistState {
  final RankedPlaylist rankedPlaylist;

  const RankedPlaylistCreated(this.rankedPlaylist);

  @override
  List<Object?> get props => [rankedPlaylist];
}

class PlaylistUpdated extends PlaylistState {
  final Playlist playlist;

  const PlaylistUpdated(this.playlist);

  @override
  List<Object?> get props => [playlist];
}

class PlaylistRankUpdated extends PlaylistState {
  final RankedPlaylist rankedPlaylist;

  const PlaylistRankUpdated(this.rankedPlaylist);

  @override
  List<Object?> get props => [rankedPlaylist];
}

class PlaylistDeleted extends PlaylistState {
  final String playlistId;

  const PlaylistDeleted(this.playlistId);

  @override
  List<Object?> get props => [playlistId];
}

class PlaylistError extends PlaylistState {
  final String message;

  const PlaylistError(this.message);

  @override
  List<Object?> get props => [message];
}
