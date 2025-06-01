import 'dart:math';
import 'dart:ui';

import 'package:equatable/equatable.dart';

class SelectionModel extends Equatable {
  final int x;
  final int y;
  final int width;
  final int height;
  final Size canvasSize;
  final List<Point<int>> pixels;

  Rect get rect => Rect.fromLTWH(
        x.toDouble(),
        y.toDouble(),
        width.toDouble(),
        height.toDouble(),
      );

  const SelectionModel({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    required this.canvasSize,
    this.pixels = const [],
  });

  SelectionModel copyWith({
    int? x,
    int? y,
    int? width,
    int? height,
    Size? canvasSize,
    List<Point<int>>? pixels,
  }) {
    return SelectionModel(
      x: x ?? this.x,
      y: y ?? this.y,
      width: width ?? this.width,
      height: height ?? this.height,
      canvasSize: canvasSize ?? this.canvasSize,
      pixels: pixels ?? this.pixels,
    );
  }

  bool contains(Point<int> point) {
    return point.x >= x && point.x < x + width && point.y >= y && point.y < y + height;
  }

  bool intersects(SelectionModel other) {
    return !(other.x >= x + width ||
        other.x + other.width <= x ||
        other.y >= y + height ||
        other.y + other.height <= y);
  }

  @override
  String toString() {
    return 'SelectionModel(x: $x, y: $y, width: $width, height: $height, pixels: ${pixels.length})';
  }

  @override
  List<Object?> get props {
    return [x, y, width, height, pixels, canvasSize];
  }
}
