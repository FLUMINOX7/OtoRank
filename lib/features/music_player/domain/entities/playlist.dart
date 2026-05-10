library;

import 'package:equatable/equatable.dart';
import 'song.dart';

/// Entité représentant une playlist normale
class Playlist extends Equatable {
  final String id;
  final String name;
  final List<Song> songs;
  final DateTime createdDate;
  final DateTime? modifiedDate;
  final String? coverArtPath;

  const Playlist({
    required this.id,
    required this.name,
    required this.songs,
    required this.createdDate,
    this.modifiedDate,
    this.coverArtPath,
  });

  /// Retourne le nombre de chansons dans la playlist
  int get songCount => songs.length;

  /// Retourne la durée totale de la playlist
  Duration get totalDuration {
    return songs.fold(
      Duration.zero,
      (total, song) => total + (song.duration ?? Duration.zero),
    );
  }

  /// Copie avec modification
  Playlist copyWith({
    String? id,
    String? name,
    List<Song>? songs,
    DateTime? createdDate,
    DateTime? modifiedDate,
    String? coverArtPath,
  }) {
    return Playlist(
      id: id ?? this.id,
      name: name ?? this.name,
      songs: songs ?? this.songs,
      createdDate: createdDate ?? this.createdDate,
      modifiedDate: modifiedDate ?? this.modifiedDate,
      coverArtPath: coverArtPath ?? this.coverArtPath,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        songs,
        createdDate,
        modifiedDate,
        coverArtPath,
      ];
}
