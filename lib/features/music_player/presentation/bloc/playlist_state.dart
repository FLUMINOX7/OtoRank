library;

import 'package:equatable/equatable.dart';
import '../../domain/entities/playlist.dart';
import '../../domain/entities/ranked_playlist.dart';
import '../../domain/entities/song.dart';

/// States pour le PlaylistBloc
abstract class PlaylistState extends Equatable {
  final List<Song>? allSongs;
  
  const PlaylistState({this.allSongs});

  @override
  List<Object?> get props => [allSongs];
}

class PlaylistInitial extends PlaylistState {
  const PlaylistInitial() : super();
}

class PlaylistLoading extends PlaylistState {
  const PlaylistLoading({super.allSongs});
}

class PlaylistLoaded extends PlaylistState {
  final List<Playlist> playlists;

  const PlaylistLoaded({
    required this.playlists,
    super.allSongs,
  });

  @override
  List<Object?> get props => [playlists, allSongs];
}

class PlaylistsLoaded extends PlaylistState {
  final List<Playlist> playlists;
  final List<RankedPlaylist> rankedPlaylists;

  const PlaylistsLoaded({
    required this.playlists,
    required this.rankedPlaylists,
    super.allSongs,
  });

  @override
  List<Object?> get props => [playlists, rankedPlaylists, allSongs];
}

class PlaylistCreated extends PlaylistState {
  final Playlist playlist;

  const PlaylistCreated(this.playlist, {super.allSongs});

  @override
  List<Object?> get props => [playlist, allSongs];
}

class RankedPlaylistCreated extends PlaylistState {
  final RankedPlaylist rankedPlaylist;

  const RankedPlaylistCreated(this.rankedPlaylist, {super.allSongs});

  @override
  List<Object?> get props => [rankedPlaylist, allSongs];
}

class PlaylistUpdated extends PlaylistState {
  final Playlist playlist;

  const PlaylistUpdated(this.playlist, {super.allSongs});

  @override
  List<Object?> get props => [playlist, allSongs];
}

class PlaylistRankUpdated extends PlaylistState {
  final RankedPlaylist rankedPlaylist;

  const PlaylistRankUpdated(this.rankedPlaylist, {super.allSongs});

  @override
  List<Object?> get props => [rankedPlaylist, allSongs];
}

class PlaylistDeleted extends PlaylistState {
  final String playlistId;

  const PlaylistDeleted(this.playlistId, {super.allSongs});

  @override
  List<Object?> get props => [playlistId, allSongs];
}

class PlaylistError extends PlaylistState {
  final String message;

  const PlaylistError(this.message, {super.allSongs});

  @override
  List<Object?> get props => [message, allSongs];
}
