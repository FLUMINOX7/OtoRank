/// Exemple d'entité du domaine Home
/// 
/// Les entités représentent les objets métier de l'application.
/// Elles sont indépendantes de toute implémentation technique.
import 'package:equatable/equatable.dart';

/// Entité représentant un élément Home (exemple)
/// TODO: Adapter selon vos besoins métier
class HomeEntity extends Equatable {
  final String id;
  final String title;
  final String description;
  final DateTime createdAt;
  
  const HomeEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.createdAt,
  });
  
  @override
  List<Object?> get props => [id, title, description, createdAt];
}
