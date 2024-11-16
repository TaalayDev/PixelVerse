import 'dart:typed_data';

import 'package:equatable/equatable.dart';

import 'animation_frame_model.dart';

class Project with EquatableMixin {
  final int id;
  final String name;
  final int width;
  final int height;
  // final List<Layer> layers;
  final List<AnimationFrame> frames;
  final List<AnimationStateModel> states;
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
    this.states = const [],
    this.frames = const [],
  });

  Project copyWith({
    int? id,
    String? name,
    int? width,
    int? height,
    List<AnimationStateModel>? states,
    List<AnimationFrame>? frames,
    Uint8List? thumbnail,
    DateTime? createdAt,
    DateTime? editedAt,
  }) {
    return Project(
      id: id ?? this.id,
      name: name ?? this.name,
      width: width ?? this.width,
      height: height ?? this.height,
      states: states ?? this.states,
      frames: frames ?? this.frames,
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
      'states': states.map((state) => state.toJson()).toList(),
      'frames': frames.map((frame) => frame.toJson()).toList(),
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
      states: (json['states'] as List)
          .map(
            (state) =>
                AnimationStateModel.fromJson(state as Map<String, dynamic>),
          )
          .toList(),
      frames: (json['frames'] as List)
          .map(
            (layer) => AnimationFrame.fromJson(layer as Map<String, dynamic>),
          )
          .toList(),
      thumbnail: json['thumbnail'] != null
          ? Uint8List.fromList(json['thumbnail'].cast<int>())
          : null,
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int),
      editedAt: DateTime.fromMillisecondsSinceEpoch(json['editedAt'] as int),
    );
  }

  @override
  List<Object?> get props =>
      [id, name, width, height, frames, states, thumbnail, createdAt, editedAt];
}
