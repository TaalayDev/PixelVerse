import 'dart:typed_data';

import 'package:equatable/equatable.dart';

class Layer extends Equatable {
  final int id;
  final String name;
  final Uint32List pixels;
  final bool isVisible;
  final bool isLocked;
  final double opacity;

  const Layer(
    this.id,
    this.name,
    this.pixels, {
    this.isVisible = true,
    this.isLocked = false,
    this.opacity = 1.0,
  });

  Layer copyWith({
    String? name,
    Uint32List? pixels,
    bool? isVisible,
    bool? isLocked,
    double? opacity,
  }) {
    return Layer(
      id,
      name ?? this.name,
      pixels ?? this.pixels,
      isVisible: isVisible ?? this.isVisible,
      isLocked: isLocked ?? this.isLocked,
      opacity: opacity ?? this.opacity,
    );
  }

  @override
  List<Object?> get props => [name, pixels, isVisible, isLocked, opacity];
}
