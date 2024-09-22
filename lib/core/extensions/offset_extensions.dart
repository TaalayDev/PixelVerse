import 'dart:ui';

extension OffsetExtension on Offset {
  Offset operator -(Offset other) => Offset(dx - other.dx, dy - other.dy);
  Offset operator +(Offset other) => Offset(dx + other.dx, dy + other.dy);
  Offset operator /(double value) => Offset(dx / value, dy / value);
  Offset operator *(double value) => Offset(dx * value, dy * value);

  double distanceTo(Offset other) =>
      (dx - other.dx).abs() + (dy - other.dy).abs();

  void calculateDensityOffset(
    Offset other,
    double density,
    Function(Offset) callback,
  ) {
    final difference = other - this;
    final distance = difference.distance;

    if (distance == 0) {
      // Points are the same; invoke callback once.
      callback(this);
      return;
    }

    final direction = difference / distance;

    for (double i = 0; i <= distance; i += density) {
      final point = this + direction * i;
      callback(point);
    }

    // Ensure the last point is included.
    if ((distance % density) != 0) {
      callback(other);
    }
  }

  Offset normalized() {
    final length = distanceTo(Offset.zero);
    return Offset(dx / length, dy / length);
  }
}
