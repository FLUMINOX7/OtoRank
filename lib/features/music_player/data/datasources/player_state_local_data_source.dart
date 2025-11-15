library;

import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// Local data source for persisting player state
class PlayerStateLocalDataSource {
  static const String _keyCurrentSongId = 'current_song_id';
  static const String _keyCurrentSongPath = 'current_song_path';
  static const String _keyCurrentSongTitle = 'current_song_title';
  static const String _keyCurrentSongArtist = 'current_song_artist';
  static const String _keyPosition = 'position_ms';
  static const String _keyWasPlaying = 'was_playing';
  
  final SharedPreferences sharedPreferences;
  
  PlayerStateLocalDataSource(this.sharedPreferences);
  
  /// Save current player state
  Future<void> savePlayerState({
    required String songId,
    required String songPath,
    required String songTitle,
    String? songArtist,
    required int positionMs,
    required bool wasPlaying,
  }) async {
    await Future.wait([
      sharedPreferences.setString(_keyCurrentSongId, songId),
      sharedPreferences.setString(_keyCurrentSongPath, songPath),
      sharedPreferences.setString(_keyCurrentSongTitle, songTitle),
      sharedPreferences.setString(_keyCurrentSongArtist, songArtist ?? ''),
      sharedPreferences.setInt(_keyPosition, positionMs),
      sharedPreferences.setBool(_keyWasPlaying, wasPlaying),
    ]);
  }
  
  /// Get saved player state
  Map<String, dynamic>? getSavedPlayerState() {
    final songId = sharedPreferences.getString(_keyCurrentSongId);
    final songPath = sharedPreferences.getString(_keyCurrentSongPath);
    final songTitle = sharedPreferences.getString(_keyCurrentSongTitle);
    
    if (songId == null || songPath == null || songTitle == null) {
      return null;
    }
    
    return {
      'songId': songId,
      'songPath': songPath,
      'songTitle': songTitle,
      'songArtist': sharedPreferences.getString(_keyCurrentSongArtist),
      'positionMs': sharedPreferences.getInt(_keyPosition) ?? 0,
      'wasPlaying': sharedPreferences.getBool(_keyWasPlaying) ?? false,
    };
  }
  
  /// Clear saved player state
  Future<void> clearPlayerState() async {
    await Future.wait([
      sharedPreferences.remove(_keyCurrentSongId),
      sharedPreferences.remove(_keyCurrentSongPath),
      sharedPreferences.remove(_keyCurrentSongTitle),
      sharedPreferences.remove(_keyCurrentSongArtist),
      sharedPreferences.remove(_keyPosition),
      sharedPreferences.remove(_keyWasPlaying),
    ]);
  }
}
