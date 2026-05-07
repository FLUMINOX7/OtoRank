library;

import 'package:equatable/equatable.dart';
import 'playlist.dart';

/// Entité représentant une playlist avec un système de classement
/// L'utilisateur peut attribuer un rang personnalisé (S, A, B, C, etc.)
class RankedPlaylist extends Equatable {
  final Playlist playlist;
  final String rank; // Ex: "S", "A", "B", "C", "D", ou personnalisé
  final int? rankOrder; // Ordre numérique pour le tri (0 = meilleur)

  const RankedPlaylist({
    required this.playlist,
    required this.rank,
    this.rankOrder,
  });

  /// Retourne l'ID de la playlist
  String get id => playlist.id;

  /// Retourne le nom de la playlist
  String get name => playlist.name;

  /// Copie avec modification
  RankedPlaylist copyWith({
    Playlist? playlist,
    String? rank,
    int? rankOrder,
  }) {
    return RankedPlaylist(
      playlist: playlist ?? this.playlist,
      rank: rank ?? this.rank,
      rankOrder: rankOrder ?? this.rankOrder,
    );
  }

  @override
  List<Object?> get props => [playlist, rank, rankOrder];
}

/// Rangs prédéfinis pour faciliter l'utilisation
class PlaylistRank {
  static const String s = 'S';
  static const String a = 'A';
  static const String b = 'B';
  static const String c = 'C';
  static const String d = 'D';
  static const String unranked = 'Unranked';

  /// Rangs proposés à la création d'une playlist classée.
  static const List<String> creatableRanks = [s, a, b, c, d];

  /// Liste des rangs par défaut avec leur ordre
  static const Map<String, int> defaultRanks = {
    s: 0,
    a: 1,
    b: 2,
    c: 3,
    d: 4,
    unranked: 999,
  };

  /// Retourne l'ordre d'un rang
  static int getOrder(String rank) {
    return defaultRanks[rank] ?? 999;
  }
}
