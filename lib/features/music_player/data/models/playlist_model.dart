library;

import '../../domain/entities/playlist.dart';
import '../../domain/entities/song.dart';
import 'song_model.dart';

/// Model de la playlist avec méthodes de sérialisation
class PlaylistModel extends Playlist {
  const PlaylistModel({
    required super.id,
    required super.name,
    required super.songs,
    required super.createdDate,
    super.modifiedDate,
    super.coverArtPath,
  });

  /// Crée un PlaylistModel à partir d'un JSON
  factory PlaylistModel.fromJson(Map<String, dynamic> json) {
    return PlaylistModel(
      id: json['id'] as String,
      name: json['name'] as String,
      songs: (json['songs'] as List<dynamic>)
          .map((song) => SongModel.fromJson(_asStringKeyedMap(song)))
          .toList(),
      createdDate: DateTime.parse(json['createdDate'] as String),
      modifiedDate: json['modifiedDate'] != null
          ? DateTime.parse(json['modifiedDate'] as String)
          : null,
      coverArtPath: json['coverArtPath'] as String?,
    );
  }

  /// Convertit le PlaylistModel en JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'songs': songs.map((song) => SongModel.fromEntity(song).toJson()).toList(),
      'createdDate': createdDate.toIso8601String(),
      'modifiedDate': modifiedDate?.toIso8601String(),
      'coverArtPath': coverArtPath,
    };
  }

  /// Crée un PlaylistModel à partir d'une Playlist entity
  factory PlaylistModel.fromEntity(Playlist playlist) {
    return PlaylistModel(
      id: playlist.id,
      name: playlist.name,
      songs: playlist.songs,
      createdDate: playlist.createdDate,
      modifiedDate: playlist.modifiedDate,
      coverArtPath: playlist.coverArtPath,
    );
  }

  /// Convertit le PlaylistModel en Playlist entity
  Playlist toEntity() {
    return Playlist(
      id: id,
      name: name,
      songs: songs,
      createdDate: createdDate,
      modifiedDate: modifiedDate,
      coverArtPath: coverArtPath,
    );
  }

  @override
  PlaylistModel copyWith({
    String? id,
    String? name,
    List<Song>? songs,
    DateTime? createdDate,
    DateTime? modifiedDate,
    String? coverArtPath,
  }) {
    return PlaylistModel(
      id: id ?? this.id,
      name: name ?? this.name,
      songs: songs ?? this.songs,
      createdDate: createdDate ?? this.createdDate,
      modifiedDate: modifiedDate ?? this.modifiedDate,
      coverArtPath: coverArtPath ?? this.coverArtPath,
    );
  }
}

Map<String, dynamic> _asStringKeyedMap(dynamic value) {
  if (value is Map<String, dynamic>) {
    return value;
  }

  if (value is Map) {
    return Map<String, dynamic>.from(value.map((key, dynamic item) {
      return MapEntry(key.toString(), item);
    }));
  }

  throw TypeError();
}
