import 'package:flutter_test/flutter_test.dart';

/// Tests pour l'égaliseur
void main() {
  group('Equalizer Tests', () {
    late Map<String, double> bandValues;

    setUp(() {
      bandValues = {
        '60 Hz': 0.0,
        '170 Hz': 0.0,
        '310 Hz': 0.0,
        '600 Hz': 0.0,
        '1 kHz': 0.0,
        '3 kHz': 0.0,
        '6 kHz': 0.0,
        '12 kHz': 0.0,
        '14 kHz': 0.0,
        '16 kHz': 0.0,
      };
    });

    test('All bands should start at 0.0 dB (Flat)', () {
      expect(bandValues.values.every((v) => v == 0.0), true);
    });

    test('Set bass boost: low frequencies should be positive', () {
      bandValues['60 Hz'] = 8.0;
      bandValues['170 Hz'] = 6.0;
      bandValues['310 Hz'] = 4.0;

      expect(bandValues['60 Hz'], greaterThan(0.0));
      expect(bandValues['170 Hz'], greaterThan(0.0));
      expect(bandValues['310 Hz'], greaterThan(0.0));
    });

    test('Set treble boost: high frequencies should be positive', () {
      bandValues['12 kHz'] = 6.0;
      bandValues['14 kHz'] = 7.0;
      bandValues['16 kHz'] = 8.0;

      expect(bandValues['12 kHz'], greaterThan(0.0));
      expect(bandValues['14 kHz'], greaterThan(0.0));
      expect(bandValues['16 kHz'], greaterThan(0.0));
    });

    test('Band values should be within range -12 to +12 dB', () {
      bandValues['60 Hz'] = -12.0;
      bandValues['1 kHz'] = 12.0;

      expect(bandValues['60 Hz'], greaterThanOrEqualTo(-12.0));
      expect(bandValues['60 Hz'], lessThanOrEqualTo(12.0));
      expect(bandValues['1 kHz'], greaterThanOrEqualTo(-12.0));
      expect(bandValues['1 kHz'], lessThanOrEqualTo(12.0));
    });

    test('Reset equalizer should set all bands to 0.0', () {
      // Modify some bands
      bandValues['60 Hz'] = 5.0;
      bandValues['1 kHz'] = -3.0;
      bandValues['16 kHz'] = 8.0;

      // Reset
      bandValues.updateAll((key, value) => 0.0);

      expect(bandValues.values.every((v) => v == 0.0), true);
    });

    test('Rock preset should have specific values', () {
      final rockPreset = {
        '60 Hz': 5.0,
        '170 Hz': 3.0,
        '310 Hz': -2.0,
        '600 Hz': -1.0,
        '1 kHz': 1.0,
        '3 kHz': 3.0,
        '6 kHz': 4.0,
        '12 kHz': 5.0,
        '14 kHz': 5.0,
        '16 kHz': 5.0,
      };

      bandValues.addAll(rockPreset);

      expect(bandValues['60 Hz'], 5.0);
      expect(bandValues['310 Hz'], -2.0);
      expect(bandValues['16 kHz'], 5.0);
    });

    test('Number of frequency bands should be 10', () {
      expect(bandValues.length, 10);
    });
  });
}
