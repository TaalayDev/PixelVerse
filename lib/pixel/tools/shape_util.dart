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
    } else {
      final halfSize = size ~/ 2;
      for (int i = -halfSize; i <= halfSize; i++) {
        for (int j = -halfSize; j <= halfSize; j++) {
          final px = x + i;
          final py = y + j;
          if (px >= 0 && px < width && py >= 0 && py < height) {
            pixels.add(PixelPoint(px, py));
          }
        }
      }
    } //

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
    return _getBresenhamLine(x0, y0, x1, y1);
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
    return _getBresenhamLine(x0, y0, x1, y1);
  }

  /// Improved pen path generation with pixel-perfect curves and anti-aliasing
  List<PixelPoint<int>> getPenPathPixels(
    List<Offset> penPoints, {
    required Size size,
    bool close = false,
  }) {
    if (penPoints.length < 2) return [];

    final pixelWidth = size.width / width;
    final pixelHeight = size.height / height;

    // Convert screen coordinates to pixel coordinates
    final pixelPoints = penPoints
        .map((point) => Point<double>(
              point.dx / pixelWidth,
              point.dy / pixelHeight,
            ))
        .toList();

    // Generate smooth path using improved curve generation
    final pathPixels = _generateSmoothPixelPath(pixelPoints, close: close);

    // Remove duplicates while preserving order
    final uniquePixels = _removeDuplicatePixels(pathPixels);

    return uniquePixels;
  }

  /// Generate smooth pixel path with adaptive curve sampling
  List<PixelPoint<int>> _generateSmoothPixelPath(List<Point<double>> points, {bool close = false}) {
    if (points.length < 2) return [];

    final pathPixels = <PixelPoint<int>>[];

    if (points.length == 2) {
      // Straight line for two points
      final line = _getBresenhamLine(
        points[0].x.round(),
        points[0].y.round(),
        points[1].x.round(),
        points[1].y.round(),
      );
      pathPixels.addAll(line);
    } else {
      // Smooth curves for multiple points
      pathPixels.addAll(_generateCatmullRomSpline(points, close: close));
    }

    return pathPixels.where((p) => p.x >= 0 && p.x < width && p.y >= 0 && p.y < height).toList();
  }

  /// Generate smooth curve using Catmull-Rom spline with pixel-perfect sampling
  List<PixelPoint<int>> _generateCatmullRomSpline(List<Point<double>> points, {bool close = false}) {
    final splinePixels = <PixelPoint<int>>[];

    // Add first point
    splinePixels.add(PixelPoint(points[0].x.round(), points[0].y.round()));

    for (int i = 0; i < points.length - 1; i++) {
      final p0 = i > 0 ? points[i - 1] : points[i];
      final p1 = points[i];
      final p2 = points[i + 1];
      final p3 = i < points.length - 2 ? points[i + 2] : points[i + 1];

      // Generate curve segment
      final segmentPixels = _catmullRomSegment(p0, p1, p2, p3);

      // Connect segments with lines to ensure no gaps
      if (splinePixels.isNotEmpty && segmentPixels.isNotEmpty) {
        final connectionLine = _getBresenhamLine(
          splinePixels.last.x,
          splinePixels.last.y,
          segmentPixels.first.x,
          segmentPixels.first.y,
        );
        // Skip first point to avoid duplication
        splinePixels.addAll(connectionLine.skip(1));
      }

      splinePixels.addAll(segmentPixels);
    }

    // Close path if requested
    if (close && splinePixels.length > 2) {
      final closingLine = _getBresenhamLine(
        splinePixels.last.x,
        splinePixels.last.y,
        splinePixels.first.x,
        splinePixels.first.y,
      );
      splinePixels.addAll(closingLine.skip(1));
    }

    return splinePixels;
  }

  /// Generate a single Catmull-Rom spline segment
  List<PixelPoint<int>> _catmullRomSegment(Point<double> p0, Point<double> p1, Point<double> p2, Point<double> p3) {
    final segmentPixels = <PixelPoint<int>>[];

    // Calculate segment length for adaptive sampling
    final segmentLength = sqrt((p1.x - p0.x) * (p1.x - p0.x) + (p1.y - p0.y) * (p1.y - p0.y)) +
        sqrt((p2.x - p1.x) * (p2.x - p1.x) + (p2.y - p1.y) * (p2.y - p1.y)) +
        sqrt((p3.x - p2.x) * (p3.x - p2.x) + (p3.y - p2.y) * (p3.y - p2.y));
    final steps = max((segmentLength * 2).round(), 10); // At least 10 steps

    Point<double>? lastPixelPos;

    for (int step = 0; step <= steps; step++) {
      final t = step / steps;
      final point = _catmullRomInterpolate(p0, p1, p2, p3, t);

      final pixelPos = Point<double>(point.x, point.y);

      if (lastPixelPos != null) {
        // Connect with line to ensure no gaps
        final linePixels = _getBresenhamLine(
          lastPixelPos.x.round(),
          lastPixelPos.y.round(),
          pixelPos.x.round(),
          pixelPos.y.round(),
        );

        // Skip first point to avoid duplication
        if (segmentPixels.isNotEmpty) {
          segmentPixels.addAll(linePixels.skip(1));
        } else {
          segmentPixels.addAll(linePixels);
        }
      } else {
        segmentPixels.add(PixelPoint(pixelPos.x.round(), pixelPos.y.round()));
      }

      lastPixelPos = pixelPos;
    }

    return segmentPixels;
  }

  /// Catmull-Rom spline interpolation
  Point<double> _catmullRomInterpolate(
      Point<double> p0, Point<double> p1, Point<double> p2, Point<double> p3, double t) {
    final t2 = t * t;
    final t3 = t2 * t;

    // Catmull-Rom basis functions
    final b0 = -0.5 * t3 + t2 - 0.5 * t;
    final b1 = 1.5 * t3 - 2.5 * t2 + 1.0;
    final b2 = -1.5 * t3 + 2.0 * t2 + 0.5 * t;
    final b3 = 0.5 * t3 - 0.5 * t2;

    final x = b0 * p0.x + b1 * p1.x + b2 * p2.x + b3 * p3.x;
    final y = b0 * p0.y + b1 * p1.y + b2 * p2.y + b3 * p3.y;

    return Point<double>(x, y);
  }

  /// Bresenham's line algorithm for pixel-perfect lines
  List<PixelPoint<int>> _getBresenhamLine(int x0, int y0, int x1, int y1) {
    final pixels = <PixelPoint<int>>[];

    int dx = (x1 - x0).abs();
    int dy = -(y1 - y0).abs();
    int sx = x0 < x1 ? 1 : -1;
    int sy = y0 < y1 ? 1 : -1;
    int err = dx + dy;

    int x = x0;
    int y = y0;

    while (true) {
      pixels.add(PixelPoint(x, y));
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

  /// Remove duplicate pixels while preserving order
  List<PixelPoint<int>> _removeDuplicatePixels(List<PixelPoint<int>> pixels) {
    final seen = <String>{};
    final unique = <PixelPoint<int>>[];

    for (final pixel in pixels) {
      final key = '${pixel.x},${pixel.y}';
      if (!seen.contains(key)) {
        seen.add(key);
        unique.add(pixel);
      }
    }

    return unique;
  }

  List<PixelPoint<int>> getLinePoints(int x0, int y0, int x1, int y1) {
    return _getBresenhamLine(x0, y0, x1, y1);
  }
}
