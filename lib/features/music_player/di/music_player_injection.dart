library;

import 'package:get_it/get_it.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/datasources/local_music_datasource.dart';
import '../data/datasources/playlist_local_datasource.dart';
import '../data/datasources/player_state_local_data_source.dart';
import '../data/repositories/music_repository_impl.dart';
import '../data/repositories/audio_player_repository_impl.dart';
import '../domain/repositories/music_repository.dart';
import '../domain/repositories/audio_player_repository.dart';
import '../domain/usecases/get_local_songs.dart';
import '../domain/usecases/create_playlist.dart';
import '../domain/usecases/create_ranked_playlist.dart';
import '../domain/usecases/update_playlist_rank.dart';
import '../domain/usecases/get_all_playlists.dart';
import '../domain/usecases/get_ranked_playlists.dart';
import '../domain/usecases/play_song.dart';
import '../domain/usecases/load_playlist.dart';
import '../domain/usecases/add_songs_to_playlist.dart';
import '../domain/usecases/add_songs_to_ranked_playlist.dart';
import '../domain/usecases/remove_songs_from_playlist.dart';
import '../presentation/bloc/music_player_bloc.dart';
import '../presentation/bloc/playlist_bloc.dart';

final sl = GetIt.instance;

/// Initialise l'injection de dépendances pour le music player
Future<void> initMusicPlayerDependencies() async {
  // Blocs
  sl.registerFactory(
    () => MusicPlayerBloc(
      playSong: sl(),
      loadPlaylist: sl(),
      audioPlayerRepository: sl(),
      playerStateLocalDataSource: sl(),
    ),
  );

  sl.registerFactory(
    () => PlaylistBloc(
      getAllPlaylists: sl(),
      getRankedPlaylists: sl(),
      createPlaylist: sl(),
      createRankedPlaylist: sl(),
      updatePlaylistRank: sl(),
      addSongsToPlaylist: sl(),
      removeSongsFromPlaylist: sl(),
      getLocalSongs: sl(),
      musicRepository: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetLocalSongs(sl()));
  sl.registerLazySingleton(() => CreatePlaylist(sl()));
  sl.registerLazySingleton(() => CreateRankedPlaylist(sl()));
  sl.registerLazySingleton(() => UpdatePlaylistRank(sl()));
  sl.registerLazySingleton(() => GetAllPlaylists(sl()));
  sl.registerLazySingleton(() => GetRankedPlaylists(sl()));
  sl.registerLazySingleton(() => PlaySong(sl()));
  sl.registerLazySingleton(() => LoadPlaylist(sl()));
  sl.registerLazySingleton(() => AddSongsToPlaylist(sl()));
  sl.registerLazySingleton(() => AddSongsToRankedPlaylist(sl()));
  sl.registerLazySingleton(() => RemoveSongsFromPlaylist(sl()));

  // Repositories
  sl.registerLazySingleton<MusicRepository>(
    () => MusicRepositoryImpl(
      localMusicDataSource: sl(),
      playlistLocalDataSource: sl(),
    ),
  );

  sl.registerLazySingleton<AudioPlayerRepository>(
    () => AudioPlayerRepositoryImpl(sl()),
  );

  // Data sources
  sl.registerLazySingleton<LocalMusicDataSource>(
    () => LocalMusicDataSourceImpl(),
  );

  sl.registerLazySingleton<PlaylistLocalDataSource>(
    () => PlaylistLocalDataSourceImpl(),
  );

  // Player state persistence
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton(() => PlayerStateLocalDataSource(sl()));

  // External
  sl.registerLazySingleton(() => AudioPlayer());

  // Initialise Hive pour les playlists
  await sl<PlaylistLocalDataSource>().init();
}
