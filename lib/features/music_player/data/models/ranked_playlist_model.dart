library;

import '../../domain/entities/ranked_playlist.dart';
import '../../domain/entities/playlist.dart';
import 'playlist_model.dart';

/// Model de la playlist ranked avec méthodes de sérialisation
class RankedPlaylistModel extends RankedPlaylist {
  const RankedPlaylistModel({
    required super.playlist,
    required super.rank,
    super.rankOrder,
  });

  /// Crée un RankedPlaylistModel à partir d'un JSON
  factory RankedPlaylistModel.fromJson(Map<String, dynamic> json) {
    return RankedPlaylistModel(
      playlist: PlaylistModel.fromJson(_asStringKeyedMap(json['playlist'])),
      rank: json['rank'] as String,
      rankOrder: json['rankOrder'] as int?,
    );
  }

  /// Convertit le RankedPlaylistModel en JSON
  Map<String, dynamic> toJson() {
    return {
      'playlist': PlaylistModel.fromEntity(playlist).toJson(),
      'rank': rank,
      'rankOrder': rankOrder,
    };
  }

  /// Crée un RankedPlaylistModel à partir d'une RankedPlaylist entity
  factory RankedPlaylistModel.fromEntity(RankedPlaylist rankedPlaylist) {
    return RankedPlaylistModel(
      playlist: rankedPlaylist.playlist,
      rank: rankedPlaylist.rank,
      rankOrder: rankedPlaylist.rankOrder,
    );
  }

  /// Convertit le RankedPlaylistModel en RankedPlaylist entity
  RankedPlaylist toEntity() {
    return RankedPlaylist(
      playlist: playlist,
      rank: rank,
      rankOrder: rankOrder,
    );
  }

  @override
  RankedPlaylistModel copyWith({
    Playlist? playlist,
    String? rank,
    int? rankOrder,
  }) {
    return RankedPlaylistModel(
      playlist: playlist ?? this.playlist,
      rank: rank ?? this.rank,
      rankOrder: rankOrder ?? this.rankOrder,
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
