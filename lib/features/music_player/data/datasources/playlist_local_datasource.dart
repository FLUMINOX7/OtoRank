library;

import 'package:hive_flutter/hive_flutter.dart';
import '../models/playlist_model.dart';
import '../models/ranked_playlist_model.dart';
import 'package:uuid/uuid.dart';

/// Data source pour gérer les playlists stockées localement
abstract class PlaylistLocalDataSource {
  /// Récupère toutes les playlists
  Future<List<PlaylistModel>> getAllPlaylists();

  /// Récupère toutes les playlists ranked
  Future<List<RankedPlaylistModel>> getRankedPlaylists();

  /// Récupère une playlist par son ID
  Future<PlaylistModel?> getPlaylistById(String id);

  /// Sauvegarde une playlist
  Future<void> savePlaylist(PlaylistModel playlist);

  /// Sauvegarde une playlist ranked
  Future<void> saveRankedPlaylist(RankedPlaylistModel rankedPlaylist);

  /// Supprime une playlist
  Future<void> deletePlaylist(String id);

  /// Initialise Hive
  Future<void> init();
}

class PlaylistLocalDataSourceImpl implements PlaylistLocalDataSource {
  static const String _playlistsBoxName = 'playlists';
  static const String _rankedPlaylistsBoxName = 'ranked_playlists';
  
  final Uuid uuid = const Uuid();
  Box<Map>? _playlistsBox;
  Box<Map>? _rankedPlaylistsBox;

  @override
  Future<void> init() async {
    await Hive.initFlutter();
    _playlistsBox = await Hive.openBox<Map>(_playlistsBoxName);
    _rankedPlaylistsBox = await Hive.openBox<Map>(_rankedPlaylistsBoxName);
    await _cleanupRankedDuplicates();
  }

  Future<void> _cleanupRankedDuplicates() async {
    final rankedIds = <String>{};

    for (var i = 0; i < rankedPlaylistsBox.length; i++) {
      final data = rankedPlaylistsBox.getAt(i);
      if (data == null) {
        continue;
      }

      final jsonMap = Map<String, dynamic>.from(data);
      final Map<String, dynamic> playlistMap = Map<String, dynamic>.from(jsonMap['playlist']);
      final playlistId = playlistMap['id'] as String?;
      if (playlistId != null) {
        rankedIds.add(playlistId);
      }
    }

    for (var i = playlistsBox.length - 1; i >= 0; i--) {
      final data = playlistsBox.getAt(i);
      if (data == null) {
        continue;
      }

      final jsonMap = Map<String, dynamic>.from(data);
      final playlistId = jsonMap['id'] as String?;
      if (playlistId != null && rankedIds.contains(playlistId)) {
        await playlistsBox.deleteAt(i);
      }
    }
  }

  Box<Map> get playlistsBox {
    if (_playlistsBox == null || !_playlistsBox!.isOpen) {
      throw Exception('Playlists box not initialized');
    }
    return _playlistsBox!;
  }

  Box<Map> get rankedPlaylistsBox {
    if (_rankedPlaylistsBox == null || !_rankedPlaylistsBox!.isOpen) {
      throw Exception('Ranked playlists box not initialized');
    }
    return _rankedPlaylistsBox!;
  }

  @override
  Future<List<PlaylistModel>> getAllPlaylists() async {
    try {
      final rankedIds = <String>{};
      for (var i = 0; i < rankedPlaylistsBox.length; i++) {
        final data = rankedPlaylistsBox.getAt(i);
        if (data == null) {
          continue;
        }

        final jsonMap = Map<String, dynamic>.from(data);
        final Map<String, dynamic> playlistMap = Map<String, dynamic>.from(jsonMap['playlist']);
        final playlistId = playlistMap['id'] as String?;
        if (playlistId != null) {
          rankedIds.add(playlistId);
        }
      }

      final playlists = <PlaylistModel>[];
      
      for (var i = 0; i < playlistsBox.length; i++) {
        final data = playlistsBox.getAt(i);
        if (data != null) {
          final jsonMap = Map<String, dynamic>.from(data);
          final playlistId = jsonMap['id'] as String?;
          if (playlistId == null || !rankedIds.contains(playlistId)) {
            playlists.add(PlaylistModel.fromJson(jsonMap));
          }
        }
      }
      
      return playlists;
    } catch (e) {
      throw Exception('Erreur lors de la récupération des playlists: $e');
    }
  }

  @override
  Future<List<RankedPlaylistModel>> getRankedPlaylists() async {
    try {
      final rankedPlaylists = <RankedPlaylistModel>[];
      
      for (var i = 0; i < rankedPlaylistsBox.length; i++) {
        final data = rankedPlaylistsBox.getAt(i);
        if (data != null) {
          final jsonMap = Map<String, dynamic>.from(data);
          rankedPlaylists.add(RankedPlaylistModel.fromJson(jsonMap));
        }
      }
      
      // Trie par rank order
      rankedPlaylists.sort((a, b) {
        final orderA = a.rankOrder ?? 999;
        final orderB = b.rankOrder ?? 999;
        return orderA.compareTo(orderB);
      });
      
      return rankedPlaylists;
    } catch (e) {
      throw Exception('Erreur lors de la récupération des playlists ranked: $e');
    }
  }

  @override
  Future<PlaylistModel?> getPlaylistById(String id) async {
    try {
      for (var i = 0; i < playlistsBox.length; i++) {
        final data = playlistsBox.getAt(i);
        if (data != null) {
          final jsonMap = Map<String, dynamic>.from(data);
          final playlist = PlaylistModel.fromJson(jsonMap);
          if (playlist.id == id) {
            return playlist;
          }
        }
      }
      return null;
    } catch (e) {
      throw Exception('Erreur lors de la récupération de la playlist: $e');
    }
  }

  @override
  Future<void> savePlaylist(PlaylistModel playlist) async {
    try {
      final jsonData = playlist.toJson();
      
      // Cherche si la playlist existe déjà
      int? existingIndex;
      for (var i = 0; i < playlistsBox.length; i++) {
        final data = playlistsBox.getAt(i);
        if (data != null) {
          final jsonMap = Map<String, dynamic>.from(data);
          if (jsonMap['id'] == playlist.id) {
            existingIndex = i;
            break;
          }
        }
      }
      
      if (existingIndex != null) {
        await playlistsBox.putAt(existingIndex, jsonData);
      } else {
        await playlistsBox.add(jsonData);
      }
    } catch (e) {
      throw Exception('Erreur lors de la sauvegarde de la playlist: $e');
    }
  }

  @override
  Future<void> saveRankedPlaylist(RankedPlaylistModel rankedPlaylist) async {
    try {
      final jsonData = rankedPlaylist.toJson();

      // Remove any stale normal copy of this ranked playlist.
      for (var i = playlistsBox.length - 1; i >= 0; i--) {
        final data = playlistsBox.getAt(i);
        if (data == null) {
          continue;
        }

        final jsonMap = Map<String, dynamic>.from(data);
        if (jsonMap['id'] == rankedPlaylist.id) {
          await playlistsBox.deleteAt(i);
        }
      }
      
      // Cherche si la ranked playlist existe déjà
      int? existingIndex;
      for (var i = 0; i < rankedPlaylistsBox.length; i++) {
        final data = rankedPlaylistsBox.getAt(i);
        if (data != null) {
          final jsonMap = Map<String, dynamic>.from(data);
          final Map<String, dynamic> playlistMap = 
              Map<String, dynamic>.from(jsonMap['playlist']);
          if (playlistMap['id'] == rankedPlaylist.id) {
            existingIndex = i;
            break;
          }
        }
      }
      
      if (existingIndex != null) {
        await rankedPlaylistsBox.putAt(existingIndex, jsonData);
      } else {
        await rankedPlaylistsBox.add(jsonData);
      }
    } catch (e) {
      throw Exception('Erreur lors de la sauvegarde de la playlist ranked: $e');
    }
  }

  @override
  Future<void> deletePlaylist(String id) async {
    try {
      // Supprime de la box normale
      for (var i = playlistsBox.length - 1; i >= 0; i--) {
        final data = playlistsBox.getAt(i);
        if (data != null) {
          final jsonMap = Map<String, dynamic>.from(data);
          if (jsonMap['id'] == id) {
            await playlistsBox.deleteAt(i);
          }
        }
      }
      
      // Supprime de la box ranked
      for (var i = rankedPlaylistsBox.length - 1; i >= 0; i--) {
        final data = rankedPlaylistsBox.getAt(i);
        if (data != null) {
          final jsonMap = Map<String, dynamic>.from(data);
          final Map<String, dynamic> playlistMap = 
              Map<String, dynamic>.from(jsonMap['playlist']);
          if (playlistMap['id'] == id) {
            await rankedPlaylistsBox.deleteAt(i);
          }
        }
      }
    } catch (e) {
      throw Exception('Erreur lors de la suppression de la playlist: $e');
    }
  }
}
