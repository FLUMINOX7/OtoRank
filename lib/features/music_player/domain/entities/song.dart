library;

import 'package:equatable/equatable.dart';

/// Entité représentant une chanson/musique
class Song extends Equatable {
  final String id;
  final String title;
  final String? artist;
  final String? album;
  final String filePath;
  final Duration? duration;
  final String? artworkPath;
  final DateTime addedDate;

  const Song({
    required this.id,
    required this.title,
    this.artist,
    this.album,
    required this.filePath,
    this.duration,
    this.artworkPath,
    required this.addedDate,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        artist,
        album,
        filePath,
        duration,
        artworkPath,
        addedDate,
      ];
}
