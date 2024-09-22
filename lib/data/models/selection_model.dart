import 'dart:math';
import 'dart:ui';

class SelectionModel {
  final int x;
  final int y;
  final int width;
  final int height;
  final List<Point<int>> pixels;

  Rect get rect => Rect.fromLTWH(
        x.toDouble(),
        y.toDouble(),
        width.toDouble(),
        height.toDouble(),
      );

  SelectionModel({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    this.pixels = const [],
  });
}
