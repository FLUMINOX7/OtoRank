library;

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_all_playlists.dart';
import '../../domain/usecases/get_ranked_playlists.dart';
import '../../domain/usecases/create_playlist.dart';
import '../../domain/usecases/create_ranked_playlist.dart';
import '../../domain/usecases/update_playlist_rank.dart';
import '../../domain/usecases/add_songs_to_playlist.dart';
import '../../domain/usecases/remove_songs_from_playlist.dart';
import '../../domain/usecases/get_local_songs.dart';
import '../../domain/repositories/music_repository.dart';
import '../../domain/entities/ranked_playlist.dart';
import 'playlist_event.dart';
import 'playlist_state.dart';

/// BLoC pour gérer l'état des playlists
class PlaylistBloc extends Bloc<PlaylistEvent, PlaylistState> {
  final GetAllPlaylists getAllPlaylists;
  final GetRankedPlaylists getRankedPlaylists;
  final CreatePlaylist createPlaylist;
  final CreateRankedPlaylist createRankedPlaylist;
  final UpdatePlaylistRank updatePlaylistRank;
  final AddSongsToPlaylist addSongsToPlaylist;
  final RemoveSongsFromPlaylist removeSongsFromPlaylist;
  final GetLocalSongs getLocalSongs;
  final MusicRepository musicRepository;

  PlaylistBloc({
    required this.getAllPlaylists,
    required this.getRankedPlaylists,
    required this.createPlaylist,
    required this.createRankedPlaylist,
    required this.updatePlaylistRank,
    required this.addSongsToPlaylist,
    required this.removeSongsFromPlaylist,
    required this.getLocalSongs,
    required this.musicRepository,
  }) : super(const PlaylistInitial()) {
    on<LoadAllPlaylistsEvent>(_onLoadAllPlaylists);
    on<LoadRankedPlaylistsEvent>(_onLoadRankedPlaylists);
    on<CreatePlaylistEvent>(_onCreatePlaylist);
    on<CreateRankedPlaylistEvent>(_onCreateRankedPlaylist);
    on<UpdatePlaylistEvent>(_onUpdatePlaylist);
    on<UpdatePlaylistRankEvent>(_onUpdatePlaylistRank);
    on<AddSongToPlaylistEvent>(_onAddSongToPlaylist);
    on<AddSongsToPlaylistEvent>(_onAddSongsToPlaylist);
    on<RemoveSongFromPlaylistEvent>(_onRemoveSongFromPlaylist);
    on<DeletePlaylistEvent>(_onDeletePlaylist);
    on<ReorderPlaylistSongsEvent>(_onReorderPlaylistSongs);
  }

  Future<void> _onLoadAllPlaylists(
    LoadAllPlaylistsEvent event,
    Emitter<PlaylistState> emit,
  ) async {
    emit(PlaylistLoading(allSongs: state.allSongs));

    // Load all songs first
    final songsResult = await getLocalSongs();
    
    final playlistsResult = await getAllPlaylists();
    final rankedPlaylistsResult = await getRankedPlaylists();

    songsResult.fold(
      (failure) => emit(PlaylistError(failure.message, allSongs: state.allSongs)),
      (songs) {
        playlistsResult.fold(
          (failure) => emit(PlaylistError(failure.message, allSongs: songs)),
          (playlists) {
            final rankedPlaylists = rankedPlaylistsResult.fold(
              (_) => <RankedPlaylist>[],
              (value) => value,
            );

            emit(PlaylistsLoaded(
              playlists: playlists,
              rankedPlaylists: rankedPlaylists,
              allSongs: songs,
            ));
          },
        );
      },
    );
  }

  Future<void> _onLoadRankedPlaylists(
    LoadRankedPlaylistsEvent event,
    Emitter<PlaylistState> emit,
  ) async {
    emit(PlaylistLoading());

    final result = await getRankedPlaylists();

    result.fold(
      (failure) => emit(PlaylistError(failure.message)),
      (rankedPlaylists) => emit(PlaylistsLoaded(
        playlists: [],
        rankedPlaylists: rankedPlaylists,
      )),
    );
  }

  Future<void> _onCreatePlaylist(
    CreatePlaylistEvent event,
    Emitter<PlaylistState> emit,
  ) async {
    emit(PlaylistLoading());

    final result = await createPlaylist(
      name: event.name,
      songs: event.songs,
      coverArtPath: event.coverArtPath,
    );

    result.fold(
      (failure) => emit(PlaylistError(failure.message)),
      (playlist) {
        emit(PlaylistCreated(playlist));
        add(LoadAllPlaylistsEvent());
      },
    );
  }

  Future<void> _onCreateRankedPlaylist(
    CreateRankedPlaylistEvent event,
    Emitter<PlaylistState> emit,
  ) async {
    emit(PlaylistLoading());

    final result = await createRankedPlaylist(
      name: event.name,
      rank: event.rank,
      songs: event.songs,
      coverArtPath: event.coverArtPath,
    );

    result.fold(
      (failure) => emit(PlaylistError(failure.message)),
      (rankedPlaylist) {
        emit(RankedPlaylistCreated(rankedPlaylist));
        add(LoadAllPlaylistsEvent());
      },
    );
  }

  Future<void> _onUpdatePlaylistRank(
    UpdatePlaylistRankEvent event,
    Emitter<PlaylistState> emit,
  ) async {
    emit(PlaylistLoading());

    final result = await updatePlaylistRank(
      playlistId: event.playlistId,
      newRank: event.newRank,
    );

    result.fold(
      (failure) => emit(PlaylistError(failure.message)),
      (rankedPlaylist) {
        emit(PlaylistRankUpdated(rankedPlaylist));
        add(LoadAllPlaylistsEvent());
      },
    );
  }

  Future<void> _onUpdatePlaylist(
    UpdatePlaylistEvent event,
    Emitter<PlaylistState> emit,
  ) async {
    emit(PlaylistLoading(allSongs: state.allSongs));

    final result = await musicRepository.updatePlaylist(event.playlist);

    result.fold(
      (failure) => emit(PlaylistError(failure.message, allSongs: state.allSongs)),
      (playlist) {
        emit(PlaylistUpdated(playlist, allSongs: state.allSongs));
        add(LoadAllPlaylistsEvent());
      },
    );
  }

  Future<void> _onAddSongToPlaylist(
    AddSongToPlaylistEvent event,
    Emitter<PlaylistState> emit,
  ) async {
    emit(PlaylistLoading(allSongs: state.allSongs));

    final result = await musicRepository.addSongToPlaylist(
      playlistId: event.playlistId,
      song: event.song,
    );

    result.fold(
      (failure) => emit(PlaylistError(failure.message, allSongs: state.allSongs)),
      (playlist) {
        emit(PlaylistUpdated(playlist, allSongs: state.allSongs));
        add(LoadAllPlaylistsEvent());
      },
    );
  }

  Future<void> _onAddSongsToPlaylist(
    AddSongsToPlaylistEvent event,
    Emitter<PlaylistState> emit,
  ) async {
    emit(PlaylistLoading(allSongs: state.allSongs));

    final result = await addSongsToPlaylist(event.playlistId, event.songs);

    result.fold(
      (failure) => emit(PlaylistError(failure.message, allSongs: state.allSongs)),
      (_) {
        add(LoadAllPlaylistsEvent());
      },
    );
  }

  Future<void> _onRemoveSongFromPlaylist(
    RemoveSongFromPlaylistEvent event,
    Emitter<PlaylistState> emit,
  ) async {
    emit(PlaylistLoading(allSongs: state.allSongs));

    final result = await musicRepository.removeSongFromPlaylist(
      playlistId: event.playlistId,
      songId: event.songId,
    );

    result.fold(
      (failure) => emit(PlaylistError(failure.message, allSongs: state.allSongs)),
      (playlist) {
        emit(PlaylistUpdated(playlist, allSongs: state.allSongs));
        add(LoadAllPlaylistsEvent());
      },
    );
  }

  Future<void> _onDeletePlaylist(
    DeletePlaylistEvent event,
    Emitter<PlaylistState> emit,
  ) async {
    emit(PlaylistLoading());

    final result = await musicRepository.deletePlaylist(event.playlistId);

    result.fold(
      (failure) => emit(PlaylistError(failure.message)),
      (_) {
        emit(PlaylistDeleted(event.playlistId));
        add(LoadAllPlaylistsEvent());
      },
    );
  }

  Future<void> _onReorderPlaylistSongs(
    ReorderPlaylistSongsEvent event,
    Emitter<PlaylistState> emit,
  ) async {
    emit(PlaylistLoading());

    final result = await musicRepository.reorderPlaylistSongs(
      playlistId: event.playlistId,
      oldIndex: event.oldIndex,
      newIndex: event.newIndex,
    );

    result.fold(
      (failure) => emit(PlaylistError(failure.message)),
      (playlist) {
        emit(PlaylistUpdated(playlist));
        add(LoadAllPlaylistsEvent());
      },
    );
  }
}
