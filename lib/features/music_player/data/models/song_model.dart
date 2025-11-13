library;

import '../../domain/entities/song.dart';

/// Model de la chanson avec méthodes de sérialisation
class SongModel extends Song {
  const SongModel({
    required super.id,
    required super.title,
    super.artist,
    super.album,
    required super.filePath,
    super.duration,
    super.artworkPath,
    required super.addedDate,
  });

  /// Crée un SongModel à partir d'un JSON
  factory SongModel.fromJson(Map<String, dynamic> json) {
    return SongModel(
      id: json['id'] as String,
      title: json['title'] as String,
      artist: json['artist'] as String?,
      album: json['album'] as String?,
      filePath: json['filePath'] as String,
      duration: json['duration'] != null
          ? Duration(milliseconds: json['duration'] as int)
          : null,
      artworkPath: json['artworkPath'] as String?,
      addedDate: DateTime.parse(json['addedDate'] as String),
    );
  }

  /// Convertit le SongModel en JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
      'album': album,
      'filePath': filePath,
      'duration': duration?.inMilliseconds,
      'artworkPath': artworkPath,
      'addedDate': addedDate.toIso8601String(),
    };
  }

  /// Crée un SongModel à partir d'une Song entity
  factory SongModel.fromEntity(Song song) {
    return SongModel(
      id: song.id,
      title: song.title,
      artist: song.artist,
      album: song.album,
      filePath: song.filePath,
      duration: song.duration,
      artworkPath: song.artworkPath,
      addedDate: song.addedDate,
    );
  }

  /// Convertit le SongModel en Song entity
  Song toEntity() {
    return Song(
      id: id,
      title: title,
      artist: artist,
      album: album,
      filePath: filePath,
      duration: duration,
      artworkPath: artworkPath,
      addedDate: addedDate,
    );
  }
}
