import 'dart:math';
import 'dart:ui';

import '../pixel_point.dart';

class ShapeUtils {
  final int width;
  final int height;

  ShapeUtils({
    required this.width,
    required this.height,
  });

  List<PixelPoint<int>> getBrushPixels(int x, int y, int size) {
    final pixels = <PixelPoint<int>>[];
    if (size == 1) {
      pixels.add(PixelPoint(x, y));
      return pixels;
    } else if (size == 2) {
      pixels.add(PixelPoint(x, y));
      pixels.add(PixelPoint(x + 1, y));
      pixels.add(PixelPoint(x + 1, y + 1));
      pixels.add(PixelPoint(x, y + 1));

      return pixels;
    }

    for (int i = 0; i < size; i++) {
      for (int j = 0; j < size; j++) {
        final px = x + i;
        final py = y + j;
        if (px >= 0 && px < width && py >= 0 && py < height) {
          pixels.add(PixelPoint(px, py));
        }
      }
    }

    return pixels;
  }

  List<PixelPoint<int>> getCirclePoints(int centerX, int centerY, int radius) {
    final points = <PixelPoint<int>>[];
    if (radius == 1) {
      points.add(PixelPoint(centerX, centerY));
      return points;
    } else if (radius == 2) {
      points.add(PixelPoint(centerX, centerY));
      points.add(PixelPoint(centerX + 1, centerY));
      points.add(PixelPoint(centerX + 1, centerY + 1));
      points.add(PixelPoint(centerX, centerY + 1));

      return points;
    }

    for (int y = -radius; y <= radius; y++) {
      for (int x = -radius; x <= radius; x++) {
        if (x * x + y * y <= radius * radius) {
          final px = centerX + x;
          final py = centerY + y;
          if (px >= 0 && px < width && py >= 0 && py < height) {
            points.add(PixelPoint(px, py));
          }
        }
      }
    }

    return points;
  }

  List<PixelPoint<int>> getLinePixels(int x0, int y0, int x1, int y1) {
    final pixels = <PixelPoint<int>>[];

    int dx = (x1 - x0).abs();
    int dy = -(y1 - y0).abs();
    int sx = x0 < x1 ? 1 : -1;
    int sy = y0 < y1 ? 1 : -1;
    int err = dx + dy;

    int x = x0;
    int y = y0;

    while (true) {
      if (x >= 0 && x < width && y >= 0 && y < height) {
        pixels.add(PixelPoint(x, y));
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

  List<PixelPoint<int>> getRectanglePixels(int x0, int y0, int x1, int y1) {
    final pixels = <PixelPoint<int>>[];

    int left = min(x0, x1);
    int right = max(x0, x1);
    int top = min(y0, y1);
    int bottom = max(y0, y1);

    // Top and bottom edges
    for (int x = left; x <= right; x++) {
      if (top >= 0 && top < height) {
        if (x >= 0 && x < width) pixels.add(PixelPoint(x, top));
      }
      if (bottom >= 0 && bottom < height && top != bottom) {
        if (x >= 0 && x < width) pixels.add(PixelPoint(x, bottom));
      }
    }

    // Left and right edges
    for (int y = top + 1; y < bottom; y++) {
      if (left >= 0 && left < width) {
        if (y >= 0 && y < height) pixels.add(PixelPoint(left, y));
      }
      if (right >= 0 && right < width && left != right) {
        if (y >= 0 && y < height) pixels.add(PixelPoint(right, y));
      }
    }

    return pixels;
  }

  List<PixelPoint<int>> getCirclePixels(int x0, int y0, int x1, int y1) {
    final pixels = <PixelPoint<int>>[];

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

  void addCirclePoints(
    List<PixelPoint<int>> pixels,
    int x0,
    int y0,
    int x,
    int y,
  ) {
    List<PixelPoint<int>> points = [
      PixelPoint(x0 + x, y0 + y),
      PixelPoint(x0 - x, y0 + y),
      PixelPoint(x0 + x, y0 - y),
      PixelPoint(x0 - x, y0 - y),
      PixelPoint(x0 + y, y0 + x),
      PixelPoint(x0 - y, y0 + x),
      PixelPoint(x0 + y, y0 - x),
      PixelPoint(x0 - y, y0 - x),
    ];

    for (var point in points) {
      if (point.x >= 0 && point.x < width && point.y >= 0 && point.y < height) {
        pixels.add(point);
      }
    }
  }

  List<PixelPoint<int>> getPixelPerfectLinePixels(
    int x0,
    int y0,
    int x1,
    int y1,
  ) {
    final pixels = <PixelPoint<int>>[];

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
        pixels.add(PixelPoint(x, y));
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
        pixels.add(PixelPoint(x, y));
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
        return (point.x - prevPoint.x).abs() == 1 && (point.y - prevPoint.y).abs() == 1;
      });
    }

    return pixels;
  }

  List<PixelPoint<int>> getPenPathPixels(
    List<Offset> penPoints, {
    required Size size,
    bool close = false,
  }) {
    final pixelSet = <String>{}; // Use Set for O(1) lookup instead of contains()
    final pixels = <PixelPoint<int>>[];

    if (penPoints.length < 2) return pixels;

    Path path = Path();
    path.moveTo(penPoints[0].dx, penPoints[0].dy);

    // Improved curve generation with better control points
    for (int i = 1; i < penPoints.length - 1; i++) {
      final prev = penPoints[i - 1];
      final curr = penPoints[i];
      final next = penPoints[i + 1];

      // Calculate control points for smoother curves
      final controlPoint1 = Offset(
        prev.dx + (curr.dx - prev.dx) * 0.5,
        prev.dy + (curr.dy - prev.dy) * 0.5,
      );
      final controlPoint2 = Offset(
        curr.dx + (next.dx - curr.dx) * 0.5,
        curr.dy + (next.dy - curr.dy) * 0.5,
      );

      path.cubicTo(
        controlPoint1.dx,
        controlPoint1.dy,
        controlPoint2.dx,
        controlPoint2.dy,
        (curr.dx + next.dx) / 2,
        (curr.dy + next.dy) / 2,
      );
    }

    // Handle the last segment
    if (penPoints.length >= 2) {
      final lastPoint = penPoints.last;
      path.lineTo(lastPoint.dx, lastPoint.dy);
    }

    if (close) {
      path.close();
    }

    // Rasterize the path into pixels with improved sampling
    final pathMetrics = path.computeMetrics();
    for (final metric in pathMetrics) {
      final extractPath = metric.extractPath(0, metric.length);
      final pathPoints = _rasterizePathSmooth(extractPath, size, pixelSet);
      pixels.addAll(pathPoints);
    }

    return pixels;
  }

  List<PixelPoint<int>> _rasterizePathSmooth(Path path, Size size, Set<String> pixelSet) {
    final pixels = <PixelPoint<int>>[];
    final pathMetrics = path.computeMetrics();

    final pixelWidth = size.width / width;
    final pixelHeight = size.height / height;

    for (final metric in pathMetrics) {
      final length = metric.length;

      // Adaptive sampling: more samples for longer/more complex paths
      // Minimum 2 samples per pixel unit to ensure smooth coverage
      final minSamples = (length / min(pixelWidth, pixelHeight) * 2).ceil();
      final numSamples = max(minSamples, 100); // Minimum 100 samples for smoothness

      Offset? previousPixelPos;

      for (int i = 0; i <= numSamples; i++) {
        final distance = (i / numSamples) * length;
        final tangent = metric.getTangentForOffset(distance);

        if (tangent != null) {
          final position = tangent.position;
          final ix = (position.dx / pixelWidth).floor();
          final iy = (position.dy / pixelHeight).floor();

          if (ix >= 0 && ix < width && iy >= 0 && iy < height) {
            // Fill gaps between consecutive samples using line drawing
            if (previousPixelPos != null) {
              final prevIx = (previousPixelPos.dx / pixelWidth).floor();
              final prevIy = (previousPixelPos.dy / pixelHeight).floor();

              // Use Bresenham's line algorithm to fill gaps
              final linePixels = _drawLine(prevIx, prevIy, ix, iy);
              for (final linePixel in linePixels) {
                final key = '${linePixel.x},${linePixel.y}';
                if (!pixelSet.contains(key) &&
                    linePixel.x >= 0 &&
                    linePixel.x < width &&
                    linePixel.y >= 0 &&
                    linePixel.y < height) {
                  pixelSet.add(key);
                  pixels.add(linePixel);
                }
              }
            }

            final key = '$ix,$iy';
            if (!pixelSet.contains(key)) {
              pixelSet.add(key);
              pixels.add(PixelPoint(ix, iy));
            }

            previousPixelPos = position;
          }
        }
      }
    }

    return pixels;
  }

// Bresenham's line algorithm for gap filling
  List<PixelPoint<int>> _drawLine(int x0, int y0, int x1, int y1) {
    final points = <PixelPoint<int>>[];

    final dx = (x1 - x0).abs();
    final dy = (y1 - y0).abs();
    final sx = x0 < x1 ? 1 : -1;
    final sy = y0 < y1 ? 1 : -1;
    var err = dx - dy;

    var x = x0;
    var y = y0;

    while (true) {
      points.add(PixelPoint(x, y));

      if (x == x1 && y == y1) break;

      final e2 = 2 * err;
      if (e2 > -dy) {
        err -= dy;
        x += sx;
      }
      if (e2 < dx) {
        err += dx;
        y += sy;
      }
    }

    return points;
  }

// Alternative version with sub-pixel anti-aliasing (optional)
  List<PixelPoint<int>> _rasterizePathAntiAliased(Path path, Size size, Set<String> pixelSet) {
    final pixels = <PixelPoint<int>>[];
    final pathMetrics = path.computeMetrics();

    final pixelWidth = size.width / width;
    final pixelHeight = size.height / height;

    for (final metric in pathMetrics) {
      final length = metric.length;
      final numSamples = (length * 4).ceil(); // Higher sampling for anti-aliasing

      for (int i = 0; i <= numSamples; i++) {
        final distance = (i / numSamples) * length;
        final tangent = metric.getTangentForOffset(distance);

        if (tangent != null) {
          final position = tangent.position;

          // Sample multiple sub-pixels around the main pixel
          for (double dx = -0.5; dx <= 0.5; dx += 0.25) {
            for (double dy = -0.5; dy <= 0.5; dy += 0.25) {
              final subPos = Offset(position.dx + dx, position.dy + dy);
              final ix = (subPos.dx / pixelWidth).floor();
              final iy = (subPos.dy / pixelHeight).floor();

              if (ix >= 0 && ix < width && iy >= 0 && iy < height) {
                final key = '$ix,$iy';
                if (!pixelSet.contains(key)) {
                  pixelSet.add(key);
                  pixels.add(PixelPoint(ix, iy));
                }
              }
            }
          }
        }
      }
    }

    return pixels;
  }

  List<PixelPoint<int>> getLinePoints(int x0, int y0, int x1, int y1) {
    final points = <PixelPoint<int>>[];

    int dx = (x1 - x0).abs();
    int dy = -(y1 - y0).abs();
    int sx = x0 < x1 ? 1 : -1;
    int sy = y0 < y1 ? 1 : -1;
    int err = dx + dy;

    int x = x0;
    int y = y0;

    while (true) {
      points.add(PixelPoint(x, y));
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
