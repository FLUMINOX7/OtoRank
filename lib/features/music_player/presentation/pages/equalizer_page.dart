library;

import 'package:flutter/material.dart';

/// Page d'égaliseur avec contrôles de fréquences et presets
class EqualizerPage extends StatefulWidget {
  const EqualizerPage({super.key});

  @override
  State<EqualizerPage> createState() => _EqualizerPageState();
}

class _EqualizerPageState extends State<EqualizerPage> {
  // Bands de fréquences (Hz) et leurs valeurs (dB: -12 to +12)
  final Map<String, double> _bandValues = {
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

  String _selectedPreset = 'Flat';
  
  final Map<String, Map<String, double>> _presets = {
    'Flat': {
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
    },
    'Rock': {
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
    },
    'Pop': {
      '60 Hz': -1.0,
      '170 Hz': 2.0,
      '310 Hz': 4.0,
      '600 Hz': 4.0,
      '1 kHz': 3.0,
      '3 kHz': 1.0,
      '6 kHz': -1.0,
      '12 kHz': -2.0,
      '14 kHz': -2.0,
      '16 kHz': -2.0,
    },
    'Jazz': {
      '60 Hz': 3.0,
      '170 Hz': 2.0,
      '310 Hz': 1.0,
      '600 Hz': 1.0,
      '1 kHz': 0.0,
      '3 kHz': 1.0,
      '6 kHz': 2.0,
      '12 kHz': 3.0,
      '14 kHz': 4.0,
      '16 kHz': 4.0,
    },
    'Classical': {
      '60 Hz': 3.0,
      '170 Hz': 2.0,
      '310 Hz': 1.0,
      '600 Hz': 0.0,
      '1 kHz': 0.0,
      '3 kHz': 0.0,
      '6 kHz': -1.0,
      '12 kHz': -2.0,
      '14 kHz': -3.0,
      '16 kHz': -4.0,
    },
    'Bass Boost': {
      '60 Hz': 8.0,
      '170 Hz': 6.0,
      '310 Hz': 4.0,
      '600 Hz': 2.0,
      '1 kHz': 0.0,
      '3 kHz': 0.0,
      '6 kHz': 0.0,
      '12 kHz': 0.0,
      '14 kHz': 0.0,
      '16 kHz': 0.0,
    },
    'Treble Boost': {
      '60 Hz': 0.0,
      '170 Hz': 0.0,
      '310 Hz': 0.0,
      '600 Hz': 0.0,
      '1 kHz': 0.0,
      '3 kHz': 2.0,
      '6 kHz': 4.0,
      '12 kHz': 6.0,
      '14 kHz': 7.0,
      '16 kHz': 8.0,
    },
    'Vocal Boost': {
      '60 Hz': -2.0,
      '170 Hz': -1.0,
      '310 Hz': 0.0,
      '600 Hz': 2.0,
      '1 kHz': 4.0,
      '3 kHz': 5.0,
      '6 kHz': 3.0,
      '12 kHz': 1.0,
      '14 kHz': 0.0,
      '16 kHz': 0.0,
    },
  };

  void _applyPreset(String preset) {
    setState(() {
      _selectedPreset = preset;
      _bandValues.addAll(_presets[preset]!);
    });
    
    // TODO: Apply to audio player
    print('🎵 Applied preset: $preset');
  }

  void _resetEqualizer() {
    setState(() {
      _selectedPreset = 'Flat';
      _bandValues.updateAll((key, value) => 0.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Equalizer'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Reset',
            onPressed: _resetEqualizer,
          ),
        ],
      ),
      body: Column(
        children: [
          // Presets
          Container(
            height: 120,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Presets',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: _presets.keys.map((preset) {
                      final isSelected = preset == _selectedPreset;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(preset),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) {
                              _applyPreset(preset);
                            }
                          },
                          selectedColor: Theme.of(context).colorScheme.primary,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : null,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          const Divider(),

          // Custom mode indicator
          if (_selectedPreset == 'Flat' && _bandValues.values.any((v) => v != 0.0))
            Container(
              padding: const EdgeInsets.all(8),
              color: Theme.of(context).colorScheme.primaryContainer,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.tune,
                    size: 20,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Custom EQ',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
            ),

          // Frequency bands
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: _bandValues.entries.map((entry) {
                  return Expanded(
                    child: Column(
                      children: [
                        // Value indicator
                        Text(
                          '${entry.value >= 0 ? '+' : ''}${entry.value.toStringAsFixed(1)}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: entry.value == 0 
                                ? Colors.grey 
                                : entry.value > 0 
                                    ? Colors.green 
                                    : Colors.red,
                          ),
                        ),
                        const SizedBox(height: 8),
                        
                        // Vertical slider
                        Expanded(
                          child: RotatedBox(
                            quarterTurns: 3,
                            child: SliderTheme(
                              data: SliderThemeData(
                                trackHeight: 3,
                                thumbShape: const RoundSliderThumbShape(
                                  enabledThumbRadius: 6,
                                ),
                                overlayShape: const RoundSliderOverlayShape(
                                  overlayRadius: 12,
                                ),
                              ),
                              child: Slider(
                                value: entry.value,
                                min: -12.0,
                                max: 12.0,
                                divisions: 48,
                                onChanged: (value) {
                                  setState(() {
                                    _bandValues[entry.key] = value;
                                    // Mark as custom if not matching any preset
                                    bool matchesPreset = false;
                                    for (var preset in _presets.entries) {
                                      if (preset.value.toString() == _bandValues.toString()) {
                                        _selectedPreset = preset.key;
                                        matchesPreset = true;
                                        break;
                                      }
                                    }
                                    if (!matchesPreset && _selectedPreset != 'Flat') {
                                      _selectedPreset = 'Flat';
                                    }
                                  });
                                  
                                  // TODO: Apply to audio player in real-time
                                  print('🎛️ ${entry.key}: ${value.toStringAsFixed(1)} dB');
                                },
                              ),
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 8),
                        
                        // Frequency label
                        Text(
                          entry.key,
                          style: const TextStyle(fontSize: 10),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // Info and save button
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Drag sliders to adjust frequency bands (-12 dB to +12 dB)',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // TODO: Save custom preset
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Equalizer settings saved'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    icon: const Icon(Icons.save),
                    label: const Text('Save Custom Preset'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
