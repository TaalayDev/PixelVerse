import 'package:hive/hive.dart';
import 'package:equatable/equatable.dart';

import 'layer.dart';

part 'project_model.g.dart';

@HiveType(typeId: 0)
class Project extends HiveObject with EquatableMixin {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final int width;
  @HiveField(3)
  final int height;
  @HiveField(4)
  final List<Layer> layers;
  @HiveField(5)
  final DateTime createdAt;
  @HiveField(6)
  final DateTime editedAt;

  Project({
    required this.id,
    required this.name,
    required this.width,
    required this.height,
    required this.createdAt,
    required this.editedAt,
    this.layers = const [],
  });

  Project copyWith({
    String? name,
    int? width,
    int? height,
    List<Layer>? layers,
    DateTime? createdAt,
    DateTime? editedAt,
  }) {
    return Project(
      id: id,
      name: name ?? this.name,
      width: width ?? this.width,
      height: height ?? this.height,
      layers: layers ?? this.layers,
      createdAt: createdAt ?? this.createdAt,
      editedAt: editedAt ?? this.editedAt,
    );
  }

  @override
  List<Object?> get props =>
      [id, name, width, height, layers, createdAt, editedAt];
}
