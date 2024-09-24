import 'dart:typed_data';

import 'package:equatable/equatable.dart';

import 'layer.dart';

class Project with EquatableMixin {
  final int id;
  final String name;
  final int width;
  final int height;
  final List<Layer> layers;
  final Uint8List? thumbnail;
  final DateTime createdAt;
  final DateTime editedAt;

  Project({
    required this.id,
    required this.name,
    required this.width,
    required this.height,
    required this.createdAt,
    required this.editedAt,
    this.thumbnail,
    this.layers = const [],
  });

  Project copyWith({
    int? id,
    String? name,
    int? width,
    int? height,
    List<Layer>? layers,
    Uint8List? thumbnail,
    DateTime? createdAt,
    DateTime? editedAt,
  }) {
    return Project(
      id: id ?? this.id,
      name: name ?? this.name,
      width: width ?? this.width,
      height: height ?? this.height,
      layers: layers ?? this.layers,
      thumbnail: thumbnail ?? this.thumbnail,
      createdAt: createdAt ?? this.createdAt,
      editedAt: editedAt ?? this.editedAt,
    );
  }

  @override
  List<Object?> get props => [id, name, width, height];
}
