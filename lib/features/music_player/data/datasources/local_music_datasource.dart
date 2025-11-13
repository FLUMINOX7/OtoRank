library;

import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/song_model.dart';
import 'package:uuid/uuid.dart';

/// Data source local pour scanner les fichiers audio
abstract class LocalMusicDataSource {
  /// Scanne et récupère tous les fichiers audio du téléphone
  Future<List<SongModel>> scanLocalMusic();

  /// Récupère une chanson par son ID depuis le cache
  Future<SongModel?> getSongById(String id);

  /// Recherche des chansons
  Future<List<SongModel>> searchSongs(String query);
}

class LocalMusicDataSourceImpl implements LocalMusicDataSource {
  final Uuid uuid = const Uuid();
  
  // Extensions audio supportées
  static const List<String> _audioExtensions = [
    '.mp3',
    '.m4a',
    '.aac',
    '.wav',
    '.flac',
    '.ogg',
    '.opus',
  ];

  @override
  Future<List<SongModel>> scanLocalMusic() async {
    try {
      final List<SongModel> songs = [];
      
      // Récupère les répertoires standards de musique sur Android
      final List<Directory> musicDirectories = await _getMusicDirectories();
      
      for (final directory in musicDirectories) {
        if (await directory.exists()) {
          await _scanDirectory(directory, songs);
        }
      }
      
      return songs;
    } catch (e) {
      throw Exception('Erreur lors du scan des fichiers audio: $e');
    }
  }

  @override
  Future<SongModel?> getSongById(String id) async {
    // Cette méthode pourrait être optimisée avec un cache local
    final songs = await scanLocalMusic();
    try {
      return songs.firstWhere((song) => song.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<SongModel>> searchSongs(String query) async {
    final songs = await scanLocalMusic();
    final lowercaseQuery = query.toLowerCase();
    
    return songs.where((song) {
      return song.title.toLowerCase().contains(lowercaseQuery) ||
          (song.artist?.toLowerCase().contains(lowercaseQuery) ?? false) ||
          (song.album?.toLowerCase().contains(lowercaseQuery) ?? false);
    }).toList();
  }

  /// Récupère les répertoires de musique standards
  Future<List<Directory>> _getMusicDirectories() async {
    final List<Directory> directories = [];
    
    try {
      // Répertoire de stockage externe (Android)
      if (Platform.isAndroid) {
        // /storage/emulated/0/Music
        final externalStorage = Directory('/storage/emulated/0/Music');
        if (await externalStorage.exists()) {
          directories.add(externalStorage);
        }
        
        // /storage/emulated/0/Download (pour les musiques téléchargées)
        final downloadDir = Directory('/storage/emulated/0/Download');
        if (await downloadDir.exists()) {
          directories.add(downloadDir);
        }
      }
      
      // Répertoire documents de l'application (fallback)
      try {
        final appDir = await getApplicationDocumentsDirectory();
        final appMusicDir = Directory('${appDir.path}/Music');
        if (await appMusicDir.exists()) {
          directories.add(appMusicDir);
        }
      } catch (e) {
        // Ignore si on ne peut pas accéder au répertoire de l'app
      }
    } catch (e) {
      // En cas d'erreur, retourne au moins un répertoire vide
    }
    
    return directories;
  }

  /// Scanne récursivement un répertoire pour trouver les fichiers audio
  Future<void> _scanDirectory(Directory directory, List<SongModel> songs) async {
    try {
      await for (final entity in directory.list(recursive: true, followLinks: false)) {
        if (entity is File && _isAudioFile(entity.path)) {
          final song = await _createSongFromFile(entity);
          if (song != null) {
            songs.add(song);
          }
        }
      }
    } catch (e) {
      // Ignore les erreurs de permission sur certains dossiers
    }
  }

  /// Vérifie si le fichier est un fichier audio supporté
  bool _isAudioFile(String path) {
    return _audioExtensions.any((ext) => path.toLowerCase().endsWith(ext));
  }

  /// Crée un SongModel à partir d'un fichier
  Future<SongModel?> _createSongFromFile(File file) async {
    try {
      final fileName = file.path.split('/').last;
      final titleWithoutExt = fileName.substring(0, fileName.lastIndexOf('.'));
      
      // Parse le nom de fichier pour extraire artiste et titre
      // Format commun: "Artiste - Titre.mp3"
      String title = titleWithoutExt;
      String? artist;
      
      if (titleWithoutExt.contains(' - ')) {
        final parts = titleWithoutExt.split(' - ');
        if (parts.length >= 2) {
          artist = parts[0].trim();
          title = parts.sublist(1).join(' - ').trim();
        }
      }
      
      final stats = await file.stat();
      
      return SongModel(
        id: uuid.v4(),
        title: title,
        artist: artist,
        filePath: file.path,
        addedDate: stats.modified,
        // La durée et l'artwork seront extraits plus tard avec un package de métadonnées
      );
    } catch (e) {
      return null;
    }
  }
}
