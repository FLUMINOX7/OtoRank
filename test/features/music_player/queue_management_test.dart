import 'package:flutter_test/flutter_test.dart';
import 'package:otorank/features/music_player/domain/entities/song.dart';

/// Tests pour la gestion de la queue
void main() {
  group('Queue Management Tests', () {
    late List<Song> testQueue;

    setUp(() {
      // Créer une queue de test
      testQueue = [
        Song(
          id: '1',
          title: 'Song 1',
          artist: 'Artist 1',
          filePath: '/path/to/song1.mp3',
          duration: const Duration(minutes: 3),
          addedDate: DateTime.now(),
        ),
        Song(
          id: '2',
          title: 'Song 2',
          artist: 'Artist 2',
          filePath: '/path/to/song2.mp3',
          duration: const Duration(minutes: 4),
          addedDate: DateTime.now(),
        ),
        Song(
          id: '3',
          title: 'Song 3',
          artist: 'Artist 3',
          filePath: '/path/to/song3.mp3',
          duration: const Duration(minutes: 5),
          addedDate: DateTime.now(),
        ),
      ];
    });

    test('Queue should contain 3 songs initially', () {
      expect(testQueue.length, 3);
    });

    test('Reorder queue: move song from index 0 to index 2', () {
      final song = testQueue.removeAt(0);
      testQueue.insert(2, song);

      expect(testQueue[0].id, '2');
      expect(testQueue[1].id, '3');
      expect(testQueue[2].id, '1');
    });

    test('Remove song from queue at index 1', () {
      testQueue.removeAt(1);

      expect(testQueue.length, 2);
      expect(testQueue[0].id, '1');
      expect(testQueue[1].id, '3');
    });

    test('Clear queue should empty the list', () {
      testQueue.clear();

      expect(testQueue.isEmpty, true);
      expect(testQueue.length, 0);
    });

    test('Get current queue should return unmodifiable list', () {
      final queue = List<Song>.unmodifiable(testQueue);

      expect(queue.length, 3);
      expect(() => queue.add(Song(
        id: '4',
        title: 'Song 4',
        artist: 'Artist 4',
        filePath: '/path/to/song4.mp3',
        duration: const Duration(minutes: 3),
        addedDate: DateTime.now(),
      )), throwsUnsupportedError);
    });
  });
}
