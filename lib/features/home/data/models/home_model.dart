/// Modèle de données Home
/// 
/// Les modèles sont la représentation technique des entités.
/// Ils gèrent la sérialisation/désérialisation des données.
library;

import '../../domain/entities/home_entity.dart';

/// Modèle de données pour Home
class HomeModel extends HomeEntity {
  const HomeModel({
    required super.id,
    required super.title,
    required super.description,
    required super.createdAt,
  });
  
  /// Crée un HomeModel depuis un JSON
  factory HomeModel.fromJson(Map<String, dynamic> json) {
    return HomeModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
  
  /// Convertit le HomeModel en JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'created_at': createdAt.toIso8601String(),
    };
  }
  
  /// Crée un HomeModel depuis une entité
  factory HomeModel.fromEntity(HomeEntity entity) {
    return HomeModel(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      createdAt: entity.createdAt,
    );
  }
}
