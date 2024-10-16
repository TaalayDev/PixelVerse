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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'width': width,
      'height': height,
      'layers': layers
          .map((layer) => {
                'id': layer.id,
                'layerId': layer.layerId,
                'name': layer.name,
                'pixels': layer.pixels.toList(),
                'isVisible': layer.isVisible,
                'isLocked': layer.isLocked,
                'opacity': layer.opacity,
              })
          .toList(),
      'thumbnail': thumbnail?.toList(),
      'createdAt': createdAt.millisecondsSinceEpoch,
      'editedAt': editedAt.millisecondsSinceEpoch,
    };
  }

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'] as int,
      name: json['name'] as String,
      width: json['width'] as int,
      height: json['height'] as int,
      layers: (json['layers'] as List)
          .map((layer) => Layer(
                id: layer['id'] as String,
                layerId: layer['layerId'] as int,
                name: layer['name'] as String,
                pixels:
                    Uint32List.fromList((layer['pixels'] as List).cast<int>()),
                isVisible: layer['isVisible'] as bool,
                isLocked: layer['isLocked'] as bool,
                opacity: layer['opacity'] as double,
              ))
          .toList(),
      thumbnail: json['thumbnail'] != null
          ? Uint8List.fromList(json['thumbnail'].cast<int>())
          : null,
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int),
      editedAt: DateTime.fromMillisecondsSinceEpoch(json['editedAt'] as int),
    );
  }

  @override
  List<Object?> get props => [id, name, width, height];
}
