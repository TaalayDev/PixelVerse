import 'dart:math';

import '../../core/pixel_point.dart';
import '../tools.dart';

abstract class ShapeTool extends Tool {
  List<PixelPoint<int>> _previewPoints = [];
  PixelPoint<int>? _startPoint;

  ShapeTool(super.type);

  @override
  void onStart(PixelDrawDetails details) {
    _startPoint = details.pixelPosition;
    _previewPoints = [];
    _updatePreview(details);
  }

  @override
  void onMove(PixelDrawDetails details) {
    if (_startPoint != null) {
      _updatePreview(details);
    }
  }

  @override
  void onEnd(PixelDrawDetails details) {
    if (_previewPoints.isNotEmpty) {
      details.onPixelsUpdated(_previewPoints);
    }
    _startPoint = null;
    _previewPoints = [];
  }

  void _updatePreview(PixelDrawDetails details) {
    if (_startPoint != null) {
      final currentPoint = details.pixelPosition;
      _previewPoints = generateShapePoints(
        _startPoint!,
        currentPoint,
        details.width,
        details.height,
      );

      // Handle modifiers
      if (details.modifier != null) {
        final modifier = details.modifier!;
        final modifiedPoints = <PixelPoint<int>>[];

        for (final point in _previewPoints) {
          modifiedPoints.add(point);
          modifiedPoints
              .addAll(modifier.apply(point, details.width, details.height));
        }

        _previewPoints = modifiedPoints;
      }

      details.onPixelsUpdated(_previewPoints);
    }
  }

  // Each shape tool must implement this to generate its specific shape points
  List<PixelPoint<int>> generateShapePoints(
    PixelPoint<int> start,
    PixelPoint<int> end,
    int width,
    int height,
  );
}

class LineTool extends ShapeTool {
  LineTool() : super(PixelTool.line);

  @override
  List<PixelPoint<int>> generateShapePoints(
    PixelPoint<int> start,
    PixelPoint<int> end,
    int width,
    int height,
  ) {
    final points = <PixelPoint<int>>[];

    int x0 = start.x;
    int y0 = start.y;
    int x1 = end.x;
    int y1 = end.y;

    final dx = (x1 - x0).abs();
    final dy = (y1 - y0).abs();
    final sx = x0 < x1 ? 1 : -1;
    final sy = y0 < y1 ? 1 : -1;
    var err = dx - dy;

    while (true) {
      if (_isValidPoint(Point(x0, y0), width, height)) {
        points.add(PixelPoint(x0, y0, color: start.color));
      }

      if (x0 == x1 && y0 == y1) break;

      final e2 = 2 * err;
      if (e2 > -dy) {
        err -= dy;
        x0 += sx;
      }
      if (e2 < dx) {
        err += dx;
        y0 += sy;
      }
    }

    return points;
  }
}

class OvalTool extends ShapeTool {
  OvalTool() : super(PixelTool.circle);

  @override
  List<PixelPoint<int>> generateShapePoints(
    PixelPoint<int> start,
    PixelPoint<int> end,
    int width,
    int height,
  ) {
    final points = <PixelPoint<int>>[];

    // Calculate center and radius
    final centerX = (start.x + end.x) ~/ 2;
    final centerY = (start.y + end.y) ~/ 2;
    final radiusX = (end.x - start.x).abs() ~/ 2;
    final radiusY = (end.y - start.y).abs() ~/ 2;

    // Use midpoint circle algorithm modified for ellipse
    int hh = radiusY * radiusY;
    int ww = radiusX * radiusX;
    int hhww = hh * ww;
    int x0 = radiusX;
    int dx = 0;

    // Draw first set of points
    for (int x = -radiusX; x <= radiusX; x++) {
      final y = (radiusY * sqrt(1 - x * x / (radiusX * radiusX))).round();
      final point1 = PixelPoint(centerX + x, centerY + y, color: start.color);
      final point2 = PixelPoint(centerX + x, centerY - y, color: start.color);

      if (_isValidPoint(point1, width, height)) points.add(point1);
      if (_isValidPoint(point2, width, height)) points.add(point2);
    }

    // Draw second set of points
    for (int y = -radiusY; y <= radiusY; y++) {
      final x = (radiusX * sqrt(1 - y * y / (radiusY * radiusY))).round();
      final point1 = PixelPoint(centerX + x, centerY + y, color: start.color);
      final point2 = PixelPoint(centerX - x, centerY + y, color: start.color);

      if (_isValidPoint(point1, width, height)) points.add(point1);
      if (_isValidPoint(point2, width, height)) points.add(point2);
    }

    return points;
  }
}

class RectangleTool extends ShapeTool {
  RectangleTool() : super(PixelTool.rectangle);

  @override
  List<PixelPoint<int>> generateShapePoints(
    PixelPoint<int> start,
    PixelPoint<int> end,
    int width,
    int height,
  ) {
    final points = <PixelPoint<int>>[];

    final left = min(start.x, end.x);
    final right = max(start.x, end.x);
    final top = min(start.y, end.y);
    final bottom = max(start.y, end.y);

    // Draw horizontal lines
    for (int x = left; x <= right; x++) {
      final topPoint = PixelPoint(x, top, color: start.color);
      final bottomPoint = PixelPoint(x, bottom, color: start.color);

      if (_isValidPoint(topPoint, width, height)) {
        points.add(topPoint);
      }
      if (top != bottom && _isValidPoint(bottomPoint, width, height)) {
        points.add(bottomPoint);
      }
    }

    // Draw vertical lines
    for (int y = top + 1; y < bottom; y++) {
      final leftPoint = PixelPoint(left, y, color: start.color);
      final rightPoint = PixelPoint(right, y, color: start.color);

      if (_isValidPoint(leftPoint, width, height)) {
        points.add(leftPoint);
      }
      if (left != right && _isValidPoint(rightPoint, width, height)) {
        points.add(rightPoint);
      }
    }

    return points;
  }
}

class StarTool extends ShapeTool {
  StarTool() : super(PixelTool.contour);

  @override
  List<PixelPoint<int>> generateShapePoints(
    PixelPoint<int> start,
    PixelPoint<int> end,
    int width,
    int height,
  ) {
    final points = <PixelPoint<int>>[];

    // Calculate center and radius
    final centerX = (start.x + end.x) ~/ 2;
    final centerY = (start.y + end.y) ~/ 2;
    final radius = sqrt(pow(end.x - start.x, 2) + pow(end.y - start.y, 2)) / 2;

    const numPoints = 5; // Number of points in the star
    const innerRadiusRatio = 0.4; // Ratio of inner radius to outer radius

    final angleStep = 2 * pi / numPoints;

    // Generate star points
    for (int i = 0; i < numPoints; i++) {
      // Outer point
      final outerAngle = -pi / 2 + i * angleStep;
      final outerX = centerX + (radius * cos(outerAngle)).round();
      final outerY = centerY + (radius * sin(outerAngle)).round();

      // Inner point
      final innerAngle = outerAngle + angleStep / 2;
      final innerX =
          centerX + (radius * innerRadiusRatio * cos(innerAngle)).round();
      final innerY =
          centerY + (radius * innerRadiusRatio * sin(innerAngle)).round();

      // Connect points with lines
      points.addAll(_drawLine(
        PixelPoint(outerX, outerY, color: start.color),
        PixelPoint(innerX, innerY, color: start.color),
        width,
        height,
      ));

      // Connect to next points
      final nextOuterAngle = -pi / 2 + ((i + 1) % numPoints) * angleStep;
      final nextOuterX = centerX + (radius * cos(nextOuterAngle)).round();
      final nextOuterY = centerY + (radius * sin(nextOuterAngle)).round();

      points.addAll(_drawLine(
        PixelPoint(innerX, innerY, color: start.color),
        PixelPoint(nextOuterX, nextOuterY, color: start.color),
        width,
        height,
      ));
    }

    return points;
  }

  List<PixelPoint<int>> _drawLine(
    PixelPoint<int> start,
    PixelPoint<int> end,
    int width,
    int height,
  ) {
    final points = <PixelPoint<int>>[];

    int x0 = start.x;
    int y0 = start.y;
    int x1 = end.x;
    int y1 = end.y;

    final dx = (x1 - x0).abs();
    final dy = (y1 - y0).abs();
    final sx = x0 < x1 ? 1 : -1;
    final sy = y0 < y1 ? 1 : -1;
    var err = dx - dy;

    while (true) {
      if (_isValidPoint(Point(x0, y0), width, height)) {
        points.add(PixelPoint(x0, y0, color: start.color));
      }

      if (x0 == x1 && y0 == y1) break;

      final e2 = 2 * err;
      if (e2 > -dy) {
        err -= dy;
        x0 += sx;
      }
      if (e2 < dx) {
        err += dx;
        y0 += sy;
      }
    }

    return points;
  }
}

// Helper function used by all shape tools
bool _isValidPoint(Point<int> point, int width, int height) {
  return point.x >= 0 && point.x < width && point.y >= 0 && point.y < height;
}
