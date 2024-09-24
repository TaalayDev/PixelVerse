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

  Layer({
    required this.layerId,
    required this.id,
    required this.name,
    required this.pixels,
    this.isVisible = true,
    this.isLocked = false,
    this.opacity = 1.0,
  });

  Layer copyWith({
    int? layerId,
    String? id,
    String? name,
    Uint32List? pixels,
    bool? isVisible,
    bool? isLocked,
    double? opacity,
  }) {
    return Layer(
      layerId: layerId ?? this.layerId,
      id: id ?? this.id,
      name: name ?? this.name,
      pixels: pixels ?? this.pixels,
      isVisible: isVisible ?? this.isVisible,
      isLocked: isLocked ?? this.isLocked,
      opacity: opacity ?? this.opacity,
    );
  }

  @override
  List<Object?> get props =>
      [id, layerId, name, pixels, isVisible, isLocked, opacity];
}