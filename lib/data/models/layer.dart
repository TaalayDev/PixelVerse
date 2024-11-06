import 'dart:typed_data';

import 'package:equatable/equatable.dart';

class Layer with EquatableMixin {
  final int layerId;
  final String id;
  final String name;
  final Uint32List pixels;
  final bool isVisible;
  final bool isLocked;
  final double opacity;
  final int order;

  Layer({
    required this.layerId,
    required this.id,
    required this.name,
    required this.pixels,
    this.isVisible = true,
    this.isLocked = false,
    this.opacity = 1.0,
    this.order = 0,
  });

  Layer copyWith({
    int? layerId,
    String? id,
    String? name,
    Uint32List? pixels,
    bool? isVisible,
    bool? isLocked,
    double? opacity,
    int? order,
  }) {
    return Layer(
      layerId: layerId ?? this.layerId,
      id: id ?? this.id,
      name: name ?? this.name,
      pixels: pixels ?? this.pixels,
      isVisible: isVisible ?? this.isVisible,
      isLocked: isLocked ?? this.isLocked,
      opacity: opacity ?? this.opacity,
      order: order ?? this.order,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'layerId': layerId,
      'id': id,
      'name': name,
      'pixels': pixels.toList(),
      'isVisible': isVisible,
      'isLocked': isLocked,
      'opacity': opacity,
      'order': order,
    };
  }

  factory Layer.fromJson(Map<String, dynamic> json) {
    return Layer(
      layerId: json['layerId'] as int,
      id: json['id'] as String,
      name: json['name'] as String,
      pixels: Uint32List.fromList((json['pixels'] as List).cast<int>()),
      isVisible: json['isVisible'] as bool,
      isLocked: json['isLocked'] as bool,
      opacity: json['opacity'] as double,
      order: json['order'] as int? ?? 0,
    );
  }

  @override
  List<Object?> get props =>
      [id, layerId, name, pixels, isVisible, isLocked, opacity, order];
}
