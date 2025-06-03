import 'dart:math';

import '../pixel_point.dart';
import '../tools.dart';

abstract class ShapeTool extends Tool {
  List<PixelPoint<int>> _previewPoints = [];
  PixelPoint<int>? _startPoint;

  List<PixelPoint<int>> get previewPoints => _previewPoints;

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
          modifiedPoints.addAll(modifier.apply(point, details.width, details.height));
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

    // Calculate bounding rectangle
    final left = min(start.x, end.x);
    final right = max(start.x, end.x);
    final top = min(start.y, end.y);
    final bottom = max(start.y, end.y);

    // Calculate center and radii
    final centerX = (left + right) / 2;
    final centerY = (top + bottom) / 2;
    final radiusX = (right - left) / 2;
    final radiusY = (bottom - top) / 2;

    // Handle edge cases
    if (radiusX < 0.5 && radiusY < 0.5) {
      // Single point
      if (_isValidPoint(start.x, start.y, width, height)) {
        points.add(PixelPoint(start.x, start.y, color: start.color));
      }
      return points;
    }

    if (radiusX < 0.5) {
      // Vertical line
      for (int y = top; y <= bottom; y++) {
        if (_isValidPoint(start.x, y, width, height)) {
          points.add(PixelPoint(start.x, y, color: start.color));
        }
      }
      return points;
    }

    if (radiusY < 0.5) {
      // Horizontal line
      for (int x = left; x <= right; x++) {
        if (_isValidPoint(x, start.y, width, height)) {
          points.add(PixelPoint(x, start.y, color: start.color));
        }
      }
      return points;
    }

    // Use a set to avoid duplicate points
    final Set<String> addedPoints = {};

    // Draw ellipse using parametric equations
    final maxRadius = max(radiusX, radiusY);
    final steps = (2 * pi * maxRadius * 1.5).ceil(); // Adjust density as needed

    for (int i = 0; i <= steps; i++) {
      final angle = (2 * pi * i) / steps;
      final x = (centerX + radiusX * cos(angle)).round();
      final y = (centerY + radiusY * sin(angle)).round();

      final key = '$x,$y';
      if (!addedPoints.contains(key) && _isValidPoint(x, y, width, height)) {
        addedPoints.add(key);
        points.add(PixelPoint(x, y, color: start.color));
      }
    }

    return points;
  }

  bool _isValidPoint(int x, int y, int width, int height) {
    return x >= 0 && x < width && y >= 0 && y < height;
  }
}

class OvalToolBresenham extends ShapeTool {
  OvalToolBresenham() : super(PixelTool.circle);

  @override
  List<PixelPoint<int>> generateShapePoints(
    PixelPoint<int> start,
    PixelPoint<int> end,
    int width,
    int height,
  ) {
    final points = <PixelPoint<int>>[];

    // Calculate bounding rectangle
    final left = min(start.x, end.x);
    final right = max(start.x, end.x);
    final top = min(start.y, end.y);
    final bottom = max(start.y, end.y);

    final centerX = ((left + right) / 2).round();
    final centerY = ((top + bottom) / 2).round();
    final radiusX = ((right - left) / 2).round();
    final radiusY = ((bottom - top) / 2).round();

    // Handle degenerate cases
    if (radiusX <= 0 && radiusY <= 0) {
      if (_isValidPoint(centerX, centerY, width, height)) {
        points.add(PixelPoint(centerX, centerY, color: start.color));
      }
      return points;
    }

    if (radiusX <= 0) {
      // Vertical line
      for (int y = top; y <= bottom; y++) {
        if (_isValidPoint(centerX, y, width, height)) {
          points.add(PixelPoint(centerX, y, color: start.color));
        }
      }
      return points;
    }

    if (radiusY <= 0) {
      // Horizontal line
      for (int x = left; x <= right; x++) {
        if (_isValidPoint(x, centerY, width, height)) {
          points.add(PixelPoint(x, centerY, color: start.color));
        }
      }
      return points;
    }

    // Bresenham's ellipse algorithm
    _drawEllipse(points, centerX, centerY, radiusX, radiusY, width, height, start.color);

    return points;
  }

  void _drawEllipse(
    List<PixelPoint<int>> points,
    int centerX,
    int centerY,
    int radiusX,
    int radiusY,
    int width,
    int height,
    int color,
  ) {
    int x = 0;
    int y = radiusY;

    // Region 1 decision parameter
    double p1 = (radiusY * radiusY) - (radiusX * radiusX * radiusY) + (0.25 * radiusX * radiusX);
    int dx = 2 * radiusY * radiusY * x;
    int dy = 2 * radiusX * radiusX * y;

    // Region 1
    while (dx < dy) {
      _addEllipsePoints(points, centerX, centerY, x, y, width, height, color);

      if (p1 < 0) {
        x++;
        dx = 2 * radiusY * radiusY * x;
        p1 = p1 + dx + (radiusY * radiusY);
      } else {
        x++;
        y--;
        dx = 2 * radiusY * radiusY * x;
        dy = 2 * radiusX * radiusX * y;
        p1 = p1 + dx - dy + (radiusY * radiusY);
      }
    }

    // Region 2 decision parameter
    double p2 = ((radiusY * radiusY) * ((x + 0.5) * (x + 0.5))) +
        ((radiusX * radiusX) * ((y - 1) * (y - 1))) -
        (radiusX * radiusX * radiusY * radiusY);

    // Region 2
    while (y >= 0) {
      _addEllipsePoints(points, centerX, centerY, x, y, width, height, color);

      if (p2 > 0) {
        y--;
        dy = 2 * radiusX * radiusX * y;
        p2 = p2 - dy + (radiusX * radiusX);
      } else {
        y--;
        x++;
        dx = 2 * radiusY * radiusY * x;
        dy = 2 * radiusX * radiusX * y;
        p2 = p2 + dx - dy + (radiusX * radiusX);
      }
    }
  }

  void _addEllipsePoints(
    List<PixelPoint<int>> points,
    int centerX,
    int centerY,
    int x,
    int y,
    int width,
    int height,
    int color,
  ) {
    final candidates = [
      [centerX + x, centerY + y],
      [centerX - x, centerY + y],
      [centerX + x, centerY - y],
      [centerX - x, centerY - y],
    ];

    for (final candidate in candidates) {
      final px = candidate[0];
      final py = candidate[1];
      if (_isValidPoint(px, py, width, height)) {
        points.add(PixelPoint(px, py, color: color));
      }
    }
  }

  bool _isValidPoint(int x, int y, int width, int height) {
    return x >= 0 && x < width && y >= 0 && y < height;
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
      final innerX = centerX + (radius * innerRadiusRatio * cos(innerAngle)).round();
      final innerY = centerY + (radius * innerRadiusRatio * sin(innerAngle)).round();

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
