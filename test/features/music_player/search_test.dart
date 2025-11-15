import 'package:flutter_test/flutter_test.dart';
import 'package:otorank/features/music_player/domain/entities/song.dart';

/// Tests pour la fonctionnalité de recherche
void main() {
  group('Search Functionality Tests', () {
    late List<Song> allSongs;

    setUp(() {
      allSongs = [
        Song(
          id: '1',
          title: 'Bohemian Rhapsody',
          artist: 'Queen',
          filePath: '/path/to/song1.mp3',
          duration: const Duration(minutes: 6),
          addedDate: DateTime.now(),
        ),
        Song(
          id: '2',
          title: 'Imagine',
          artist: 'John Lennon',
          filePath: '/path/to/song2.mp3',
          duration: const Duration(minutes: 3),
          addedDate: DateTime.now(),
        ),
        Song(
          id: '3',
          title: 'Stairway to Heaven',
          artist: 'Led Zeppelin',
          filePath: '/path/to/song3.mp3',
          duration: const Duration(minutes: 8),
          addedDate: DateTime.now(),
        ),
        Song(
          id: '4',
          title: 'Hotel California',
          artist: 'Eagles',
          filePath: '/path/to/song4.mp3',
          duration: const Duration(minutes: 6, seconds: 30),
          addedDate: DateTime.now(),
        ),
        Song(
          id: '5',
          title: 'Imagine Dragons',
          artist: 'Radioactive',
          filePath: '/path/to/song5.mp3',
          duration: const Duration(minutes: 3, seconds: 6),
          addedDate: DateTime.now(),
        ),
      ];
    });

    List<Song> filterByTitle(List<Song> songs, String query) {
      if (query.isEmpty) return songs;
      return songs.where((song) =>
        song.title.toLowerCase().contains(query.toLowerCase())
      ).toList();
    }

    List<Song> filterByArtist(List<Song> songs, String query) {
      if (query.isEmpty) return songs;
      return songs.where((song) =>
        song.artist?.toLowerCase().contains(query.toLowerCase()) ?? false
      ).toList();
    }

    List<Song> filterByAll(List<Song> songs, String query) {
      if (query.isEmpty) return songs;
      return songs.where((song) =>
        song.title.toLowerCase().contains(query.toLowerCase()) ||
        (song.artist?.toLowerCase().contains(query.toLowerCase()) ?? false)
      ).toList();
    }

    test('Search by title: "imagine" should return 2 songs', () {
      final results = filterByTitle(allSongs, 'imagine');

      expect(results.length, 2);
      expect(results[0].title, 'Imagine');
      expect(results[1].title, 'Imagine Dragons');
    });

    test('Search by artist: "queen" should return 1 song', () {
      final results = filterByArtist(allSongs, 'queen');

      expect(results.length, 1);
      expect(results[0].artist, 'Queen');
    });

    test('Search by all: "heaven" should return 1 song', () {
      final results = filterByAll(allSongs, 'heaven');

      expect(results.length, 1);
      expect(results[0].title, 'Stairway to Heaven');
    });

    test('Search with empty query should return all songs', () {
      final results = filterByAll(allSongs, '');

      expect(results.length, 5);
    });

    test('Search for non-existent term should return empty list', () {
      final results = filterByAll(allSongs, 'xyz123');

      expect(results.isEmpty, true);
    });

    test('Search should be case-insensitive', () {
      final resultsLower = filterByTitle(allSongs, 'bohemian');
      final resultsUpper = filterByTitle(allSongs, 'BOHEMIAN');
      final resultsMixed = filterByTitle(allSongs, 'BoHeMiAn');

      expect(resultsLower.length, 1);
      expect(resultsUpper.length, 1);
      expect(resultsMixed.length, 1);
    });
  });
}
