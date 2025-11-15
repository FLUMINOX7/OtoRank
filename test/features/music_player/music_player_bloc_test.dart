import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:otorank/features/music_player/presentation/bloc/music_player_bloc.dart';
import 'package:otorank/features/music_player/presentation/bloc/music_player_event.dart';
import 'package:otorank/features/music_player/presentation/bloc/music_player_state.dart';
import 'package:otorank/features/music_player/domain/entities/song.dart';
import 'package:otorank/features/music_player/domain/usecases/play_song.dart';
import 'package:otorank/features/music_player/domain/usecases/load_playlist.dart';
import 'package:otorank/features/music_player/domain/repositories/audio_player_repository.dart';
import 'package:otorank/features/music_player/data/datasources/player_state_local_data_source.dart';

// Mocks
class MockPlaySong extends Mock implements PlaySong {}
class MockLoadPlaylist extends Mock implements LoadPlaylist {}
class MockAudioPlayerRepository extends Mock implements AudioPlayerRepository {}
class MockPlayerStateLocalDataSource extends Mock implements PlayerStateLocalDataSource {}

void main() {
  group('MusicPlayerBloc Tests', () {
    late PlaySong mockPlaySong;
    late LoadPlaylist mockLoadPlaylist;
    late AudioPlayerRepository mockAudioPlayerRepository;
    late PlayerStateLocalDataSource mockPlayerStateLocalDataSource;

    setUp(() {
      mockPlaySong = MockPlaySong();
      mockLoadPlaylist = MockLoadPlaylist();
      mockAudioPlayerRepository = MockAudioPlayerRepository();
      mockPlayerStateLocalDataSource = MockPlayerStateLocalDataSource();

      // Setup default returns
      when(() => mockAudioPlayerRepository.getCurrentQueue()).thenReturn([]);
      when(() => mockAudioPlayerRepository.playbackStateStream).thenAnswer(
        (_) => Stream.value(PlaybackState.stopped),
      );
      when(() => mockAudioPlayerRepository.positionStream).thenAnswer(
        (_) => Stream.value(Duration.zero),
      );
      when(() => mockAudioPlayerRepository.durationStream).thenAnswer(
        (_) => Stream.value(null),
      );
      when(() => mockAudioPlayerRepository.shuffleModeStream).thenAnswer(
        (_) => Stream.value(false),
      );
      when(() => mockAudioPlayerRepository.repeatModeStream).thenAnswer(
        (_) => Stream.value(RepeatMode.off),
      );
      when(() => mockPlayerStateLocalDataSource.getSavedPlayerState()).thenReturn(null);
    });

    test('Initial state should be MusicPlayerInitial', () {
      final bloc = MusicPlayerBloc(
        playSong: mockPlaySong,
        loadPlaylist: mockLoadPlaylist,
        audioPlayerRepository: mockAudioPlayerRepository,
        playerStateLocalDataSource: mockPlayerStateLocalDataSource,
      );

      expect(bloc.state, isA<MusicPlayerInitial>());
      bloc.close();
    });

    blocTest<MusicPlayerBloc, MusicPlayerState>(
      'GetCurrentQueueEvent should emit state with current queue',
      build: () {
        final songs = [
          Song(
            id: '1',
            title: 'Test Song',
            filePath: '/path/test.mp3',
            addedDate: DateTime.now(),
          ),
        ];
        when(() => mockAudioPlayerRepository.getCurrentQueue()).thenReturn(songs);
        
        return MusicPlayerBloc(
          playSong: mockPlaySong,
          loadPlaylist: mockLoadPlaylist,
          audioPlayerRepository: mockAudioPlayerRepository,
          playerStateLocalDataSource: mockPlayerStateLocalDataSource,
        );
      },
      act: (bloc) => bloc.add(GetCurrentQueueEvent()),
      expect: () => [
        isA<MusicPlayerState>().having(
          (state) => state.queue.length,
          'queue length',
          1,
        ),
      ],
    );

    blocTest<MusicPlayerBloc, MusicPlayerState>(
      'ClearQueueEvent should emit MusicPlayerStopped',
      build: () {
        when(() => mockAudioPlayerRepository.clearQueue()).thenAnswer(
          (_) async => const Right(null),
        );
        
        return MusicPlayerBloc(
          playSong: mockPlaySong,
          loadPlaylist: mockLoadPlaylist,
          audioPlayerRepository: mockAudioPlayerRepository,
          playerStateLocalDataSource: mockPlayerStateLocalDataSource,
        );
      },
      act: (bloc) => bloc.add(ClearQueueEvent()),
      expect: () => [isA<MusicPlayerStopped>()],
    );

    blocTest<MusicPlayerBloc, MusicPlayerState>(
      'Multiple ClearQueueEvent calls should emit different MusicPlayerStopped states',
      build: () {
        when(() => mockAudioPlayerRepository.clearQueue()).thenAnswer(
          (_) async => const Right(null),
        );
        
        return MusicPlayerBloc(
          playSong: mockPlaySong,
          loadPlaylist: mockLoadPlaylist,
          audioPlayerRepository: mockAudioPlayerRepository,
          playerStateLocalDataSource: mockPlayerStateLocalDataSource,
        );
      },
      act: (bloc) {
        bloc.add(ClearQueueEvent());
        bloc.add(ClearQueueEvent());
        bloc.add(ClearQueueEvent());
      },
      expect: () => [
        isA<MusicPlayerStopped>(),
        isA<MusicPlayerStopped>(),
        isA<MusicPlayerStopped>(),
      ],
      verify: (bloc) {
        // Verify that the states are different instances due to timestamp
        // This tests the fix for the "clear queue only works first time" bug
        verify(() => mockAudioPlayerRepository.clearQueue()).called(3);
      },
    );

    blocTest<MusicPlayerBloc, MusicPlayerState>(
      'ReorderQueueEvent should update queue order',
      build: () {
        final songs = [
          Song(id: '1', title: 'Song 1', filePath: '/1.mp3', addedDate: DateTime.now()),
          Song(id: '2', title: 'Song 2', filePath: '/2.mp3', addedDate: DateTime.now()),
          Song(id: '3', title: 'Song 3', filePath: '/3.mp3', addedDate: DateTime.now()),
        ];
        
        when(() => mockAudioPlayerRepository.getCurrentQueue()).thenReturn(songs);
        when(() => mockAudioPlayerRepository.reorderQueue(any(), any())).thenAnswer(
          (invocation) async {
            final oldIndex = invocation.positionalArguments[0] as int;
            final newIndex = invocation.positionalArguments[1] as int;
            final reorderedSongs = List<Song>.from(songs);
            final song = reorderedSongs.removeAt(oldIndex);
            reorderedSongs.insert(newIndex, song);
            return Right(reorderedSongs);
          },
        );
        
        return MusicPlayerBloc(
          playSong: mockPlaySong,
          loadPlaylist: mockLoadPlaylist,
          audioPlayerRepository: mockAudioPlayerRepository,
          playerStateLocalDataSource: mockPlayerStateLocalDataSource,
        );
      },
      act: (bloc) => bloc.add(const ReorderQueueEvent(0, 2)),
      expect: () => [
        isA<MusicPlayerState>().having(
          (state) => state.queue[0].id,
          'first song after reorder',
          '2',
        ),
      ],
    );

    blocTest<MusicPlayerBloc, MusicPlayerState>(
      'RemoveFromQueueEvent should remove song from queue',
      build: () {
        final songs = [
          Song(id: '1', title: 'Song 1', filePath: '/1.mp3', addedDate: DateTime.now()),
          Song(id: '2', title: 'Song 2', filePath: '/2.mp3', addedDate: DateTime.now()),
        ];
        
        when(() => mockAudioPlayerRepository.getCurrentQueue()).thenReturn(songs);
        when(() => mockAudioPlayerRepository.removeFromQueue(any())).thenAnswer(
          (invocation) async {
            final index = invocation.positionalArguments[0] as int;
            final remainingSongs = List<Song>.from(songs);
            remainingSongs.removeAt(index);
            return Right(remainingSongs);
          },
        );
        
        return MusicPlayerBloc(
          playSong: mockPlaySong,
          loadPlaylist: mockLoadPlaylist,
          audioPlayerRepository: mockAudioPlayerRepository,
          playerStateLocalDataSource: mockPlayerStateLocalDataSource,
        );
      },
      act: (bloc) => bloc.add(const RemoveFromQueueEvent(1)),
      expect: () => [
        isA<MusicPlayerState>().having(
          (state) => state.queue.length,
          'queue length after removal',
          1,
        ),
      ],
    );
  });
}
