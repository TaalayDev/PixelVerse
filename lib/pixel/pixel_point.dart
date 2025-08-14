import 'dart:math';

class PixelPoint<T extends num> extends Point<T> {
  PixelPoint(
    super.x,
    super.y, {
    this.color = 0,
  });

  final int color;

  @override
  String toString() => 'PixelPoint($x, $y)';

  @override
  bool operator ==(Object other) => other is PixelPoint && x == other.x && y == other.y && color == other.color;

  @override
  int get hashCode => super.hashCode ^ color.hashCode;
}

extension PixelPointCopyWith on PixelPoint<int> {
  PixelPoint<int> copyWith({int? color}) {
    return PixelPoint(x, y, color: color ?? this.color);
  }
}
