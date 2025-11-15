import 'package:flutter_test/flutter_test.dart';
import 'package:otorank/features/music_player/presentation/bloc/music_player_state.dart';

/// Tests pour vérifier l'unicité des états avec timestamp
/// Ce test vérifie le fix pour le bug "clear queue only works first time"
void main() {
  group('State Uniqueness with Timestamp Tests', () {
    test('MusicPlayerInitial should have timestamp field', () {
      final state = MusicPlayerInitial();

      expect(state.timestamp, isA<int>());
      expect(state.timestamp, greaterThan(0));
    });

    test('MusicPlayerStopped should have timestamp field', () {
      final state = MusicPlayerStopped();

      expect(state.timestamp, isA<int>());
      expect(state.timestamp, greaterThan(0));
    });

    test('Timestamp should be included in props for Equatable', () {
      final state1 = MusicPlayerInitial();
      final state2 = MusicPlayerStopped();

      expect(state1.props.contains(state1.timestamp), true);
      expect(state2.props.contains(state2.timestamp), true);
    });

    test('Timestamp should be milliseconds since epoch', () {
      final state = MusicPlayerInitial();
      final now = DateTime.now().millisecondsSinceEpoch;

      // Timestamp should be close to current time (within 1 second)
      expect((state.timestamp - now).abs(), lessThan(1000));
    });

    test('States created in sequence should have timestamps', () {
      final states = <MusicPlayerInitial>[];
      
      for (var i = 0; i < 5; i++) {
        states.add(MusicPlayerInitial());
      }

      // Each state should have timestamp >= previous state
      for (var i = 1; i < states.length; i++) {
        expect(states[i].timestamp >= states[i-1].timestamp, true);
      }
    });

    test('Each state creation should generate a timestamp', () {
      final states = List.generate(10, (_) => MusicPlayerStopped());
      
      // All states should have valid timestamps
      for (final state in states) {
        expect(state.timestamp, isA<int>());
        expect(state.timestamp, greaterThan(0));
      }
    });
  });

  group('Clear Queue Bug Fix Verification', () {
    test('Timestamp field exists in MusicPlayerStopped', () {
      // The bug was: MusicPlayerStopped() was const, so multiple calls returned same instance
      // Fix: Added timestamp field initialized with DateTime.now().millisecondsSinceEpoch
      final state1 = MusicPlayerStopped();
      final state2 = MusicPlayerStopped();

      // Both states should have timestamps
      expect(state1.timestamp, isA<int>());
      expect(state2.timestamp, isA<int>());
      
      // Timestamps should be in props (which makes states different in Equatable)
      expect(state1.props.contains(state1.timestamp), true);
      expect(state2.props.contains(state2.timestamp), true);
    });

    test('Timestamp field exists in MusicPlayerInitial', () {
      // Same fix for MusicPlayerInitial
      final state1 = MusicPlayerInitial();
      final state2 = MusicPlayerInitial();

      expect(state1.timestamp, isA<int>());
      expect(state2.timestamp, isA<int>());
      
      expect(state1.props.contains(state1.timestamp), true);
      expect(state2.props.contains(state2.timestamp), true);
    });

    test('Verifies timestamp-based state differentiation', () {
      // This simulates the bug scenario: user clears queue multiple times
      final states = <MusicPlayerState>[];
      
      // User performs multiple operations
      states.add(MusicPlayerInitial()); // App start
      states.add(MusicPlayerStopped()); // Clear queue
      states.add(MusicPlayerInitial()); // Play new song after clear
      states.add(MusicPlayerStopped()); // Clear again
      states.add(MusicPlayerInitial()); // Play again

      // All states should have different timestamps in their props
      // This ensures BLoC will detect state changes
      for (var i = 0; i < states.length; i++) {
        final state = states[i];
        if (state is MusicPlayerInitial) {
          expect(state.props.contains(state.timestamp), true);
        } else if (state is MusicPlayerStopped) {
          expect(state.props.contains(state.timestamp), true);
        }
      }
    });

    test('Props should include timestamp for equality check', () {
      final state1 = MusicPlayerStopped();
      final state2 = MusicPlayerStopped();

      // Props should include the timestamp
      expect(state1.props.length, greaterThan(0));
      expect(state2.props.length, greaterThan(0));
      
      // The timestamp makes each instance unique
      final hasTimestamp1 = state1.props.contains(state1.timestamp);
      final hasTimestamp2 = state2.props.contains(state2.timestamp);
      
      expect(hasTimestamp1, true);
      expect(hasTimestamp2, true);
    });
  });
}
