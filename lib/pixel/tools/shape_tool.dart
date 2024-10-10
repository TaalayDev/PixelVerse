import 'dart:math';
import 'dart:ui';

class ShapeUtils {
  final int width;
  final int height;

  ShapeUtils({
    required this.width,
    required this.height,
  });

  List<Point<int>> getBrushPixels(int x, int y, int size) {
    final pixels = <Point<int>>[];
    if (size == 1) {
      pixels.add(Point(x, y));
      return pixels;
    } else if (size == 2) {
      pixels.add(Point(x, y));
      pixels.add(Point(x + 1, y));
      pixels.add(Point(x + 1, y + 1));
      pixels.add(Point(x, y + 1));

      return pixels;
    }

    for (int i = 0; i < size; i++) {
      for (int j = 0; j < size; j++) {
        final px = x + i;
        final py = y + j;
        if (px >= 0 && px < width && py >= 0 && py < height) {
          pixels.add(Point(px, py));
        }
      }
    }

    return pixels;
  }

  List<Point<int>> getCirclePoints(int centerX, int centerY, int radius) {
    final points = <Point<int>>[];
    if (radius == 1) {
      points.add(Point(centerX, centerY));
      return points;
    } else if (radius == 2) {
      points.add(Point(centerX, centerY));
      points.add(Point(centerX + 1, centerY));
      points.add(Point(centerX + 1, centerY + 1));
      points.add(Point(centerX, centerY + 1));

      return points;
    }

    for (int y = -radius; y <= radius; y++) {
      for (int x = -radius; x <= radius; x++) {
        if (x * x + y * y <= radius * radius) {
          final px = centerX + x;
          final py = centerY + y;
          if (px >= 0 && px < width && py >= 0 && py < height) {
            points.add(Point(px, py));
          }
        }
      }
    }

    return points;
  }

  List<Point<int>> getLinePixels(int x0, int y0, int x1, int y1) {
    final pixels = <Point<int>>[];

    int dx = (x1 - x0).abs();
    int dy = -(y1 - y0).abs();
    int sx = x0 < x1 ? 1 : -1;
    int sy = y0 < y1 ? 1 : -1;
    int err = dx + dy;

    int x = x0;
    int y = y0;

    while (true) {
      if (x >= 0 && x < width && y >= 0 && y < height) {
        pixels.add(Point(x, y));
      }

      if (x == x1 && y == y1) break;

      int e2 = 2 * err;
      if (e2 >= dy) {
        err += dy;
        x += sx;
      }
      if (e2 <= dx) {
        err += dx;
        y += sy;
      }
    }

    return pixels;
  }

  List<Point<int>> getRectanglePixels(int x0, int y0, int x1, int y1) {
    final pixels = <Point<int>>[];

    int left = min(x0, x1);
    int right = max(x0, x1);
    int top = min(y0, y1);
    int bottom = max(y0, y1);

    // Top and bottom edges
    for (int x = left; x <= right; x++) {
      if (top >= 0 && top < height) {
        if (x >= 0 && x < width) pixels.add(Point(x, top));
      }
      if (bottom >= 0 && bottom < height && top != bottom) {
        if (x >= 0 && x < width) pixels.add(Point(x, bottom));
      }
    }

    // Left and right edges
    for (int y = top + 1; y < bottom; y++) {
      if (left >= 0 && left < width) {
        if (y >= 0 && y < height) pixels.add(Point(left, y));
      }
      if (right >= 0 && right < width && left != right) {
        if (y >= 0 && y < height) pixels.add(Point(right, y));
      }
    }

    return pixels;
  }

  List<Point<int>> getCirclePixels(int x0, int y0, int x1, int y1) {
    final pixels = <Point<int>>[];

    int dx = x1 - x0;
    int dy = y1 - y0;
    int radius = sqrt(dx * dx + dy * dy).round();

    int f = 1 - radius;
    int ddF_x = 0;
    int ddF_y = -2 * radius;
    int x = 0;
    int y = radius;

    addCirclePoints(pixels, x0, y0, x, y);

    while (x < y) {
      if (f >= 0) {
        y--;
        ddF_y += 2;
        f += ddF_y;
      }
      x++;
      ddF_x += 2;
      f += ddF_x + 1;

      addCirclePoints(pixels, x0, y0, x, y);
    }

    return pixels;
  }

  void addCirclePoints(List<Point<int>> pixels, int x0, int y0, int x, int y) {
    List<Point<int>> points = [
      Point(x0 + x, y0 + y),
      Point(x0 - x, y0 + y),
      Point(x0 + x, y0 - y),
      Point(x0 - x, y0 - y),
      Point(x0 + y, y0 + x),
      Point(x0 - y, y0 + x),
      Point(x0 + y, y0 - x),
      Point(x0 - y, y0 - x),
    ];

    for (var point in points) {
      if (point.x >= 0 && point.x < width && point.y >= 0 && point.y < height) {
        pixels.add(point);
      }
    }
  }

  List<Point<int>> getPixelPerfectLinePixels(int x0, int y0, int x1, int y1) {
    final pixels = <Point<int>>[];

    int dx = x1 - x0;
    int dy = y1 - y0;

    int absDx = dx.abs();
    int absDy = dy.abs();

    int x = x0;
    int y = y0;

    int sx = dx > 0 ? 1 : -1;
    int sy = dy > 0 ? 1 : -1;

    if (absDx > absDy) {
      int err = absDx ~/ 2;
      for (int i = 0; i <= absDx; i++) {
        pixels.add(Point(x, y));
        err -= absDy;
        if (err < 0) {
          y += sy;
          err += absDx;
        }
        x += sx;
      }
    } else {
      int err = absDy ~/ 2;
      for (int i = 0; i <= absDy; i++) {
        pixels.add(Point(x, y));
        err -= absDx;
        if (err < 0) {
          x += sx;
          err += absDy;
        }
        y += sy;
      }
    }

    // Remove diagonal steps only when the distance between points is small
    if (absDx <= 1 && absDy <= 1) {
      pixels.removeWhere((point) {
        int index = pixels.indexOf(point);
        if (index == 0) return false;
        Point<int> prevPoint = pixels[index - 1];
        return (point.x - prevPoint.x).abs() == 1 &&
            (point.y - prevPoint.y).abs() == 1;
      });
    }

    return pixels;
  }

  List<Point<int>> getPenPathPixels(
    List<Offset> penPoints, {
    required Size size,
    bool close = false,
  }) {
    final pixels = <Point<int>>[];

    if (penPoints.length < 2) return pixels;

    final path = Path();
    path.moveTo(penPoints[0].dx, penPoints[0].dy);

    for (int i = 1; i < penPoints.length - 1; i++) {
      final x0 = penPoints[i].dx;
      final y0 = penPoints[i].dy;
      final x1 = penPoints[i + 1].dx;
      final y1 = penPoints[i + 1].dy;
      path.quadraticBezierTo(x0, y0, (x0 + x1) / 2, (y0 + y1) / 2);
    }

    if (close) {
      path.close();
    }

    // Rasterize the path into pixels
    final pathMetrics = path.computeMetrics();
    for (final metric in pathMetrics) {
      final extractPath = metric.extractPath(0, metric.length);
      final pathPoints = _rasterizePath(extractPath, size);
      pixels.addAll(pathPoints);
    }

    return pixels;
  }

  List<Point<int>> _rasterizePath(Path path, Size size) {
    final pixels = <Point<int>>[];
    final pathMetrics = path.computeMetrics();

    final pixelWidth = size.width / width;
    final pixelHeight = size.height / height;

    for (final metric in pathMetrics) {
      final length = metric.length;
      final numSamples = length.toInt(); // Number of samples along the path

      for (int i = 0; i <= numSamples; i++) {
        final distance = (i / numSamples) * length;
        final tangent = metric.getTangentForOffset(distance);
        if (tangent != null) {
          final position = tangent.position;
          final ix = (position.dx / pixelWidth).floor();
          final iy = (position.dy / pixelHeight).floor();
          if (ix >= 0 && ix < width && iy >= 0 && iy < height) {
            final point = Point(ix, iy);
            if (!pixels.contains(point)) {
              pixels.add(point);
            }
          }
        }
      }
    }

    return pixels;
  }

  List<Point<int>> getLinePoints(int x0, int y0, int x1, int y1) {
    final points = <Point<int>>[];

    int dx = (x1 - x0).abs();
    int dy = -(y1 - y0).abs();
    int sx = x0 < x1 ? 1 : -1;
    int sy = y0 < y1 ? 1 : -1;
    int err = dx + dy;

    int x = x0;
    int y = y0;

    while (true) {
      points.add(Point(x, y));
      if (x == x1 && y == y1) break;
      int e2 = 2 * err;
      if (e2 >= dy) {
        err += dy;
        x += sx;
      }
      if (e2 <= dx) {
        err += dx;
        y += sy;
      }
    }

    return points;
  }
}
