import 'dart:math';

import '../pixel_point.dart';
import '../tools.dart';
import 'shape_util.dart';

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

// Heart shape tool - perfect for pixel art characters and decorations
class HeartTool extends ShapeTool {
  HeartTool() : super(PixelTool.contour); // Using contour as base type

  @override
  List<PixelPoint<int>> generateShapePoints(
    PixelPoint<int> start,
    PixelPoint<int> end,
    int width,
    int height,
  ) {
    final points = <PixelPoint<int>>[];

    final centerX = (start.x + end.x) / 2;
    final centerY = (start.y + end.y) / 2;
    final scale = max((end.x - start.x).abs(), (end.y - start.y).abs()) / 20.0;

    // Heart equation: (x²+y²-1)³ - x²y³ = 0
    // Modified for pixel art with proper scaling
    for (double t = 0; t <= 2 * pi; t += 0.1) {
      final x = 16 * pow(sin(t), 3);
      final y = 13 * cos(t) - 5 * cos(2 * t) - 2 * cos(3 * t) - cos(4 * t);

      final pixelX = (centerX + x * scale).round();
      final pixelY = (centerY - y * scale).round(); // Negative for correct orientation

      if (_isValidCoord(pixelX, pixelY, width, height)) {
        points.add(PixelPoint(pixelX, pixelY, color: start.color));
      }
    }

    return _removeDuplicates(points);
  }
}

// Diamond/rhombus shape tool
class DiamondTool extends ShapeTool {
  DiamondTool() : super(PixelTool.contour);

  @override
  List<PixelPoint<int>> generateShapePoints(
    PixelPoint<int> start,
    PixelPoint<int> end,
    int width,
    int height,
  ) {
    final points = <PixelPoint<int>>[];

    final centerX = (start.x + end.x) / 2;
    final centerY = (start.y + end.y) / 2;
    final radiusX = (end.x - start.x).abs() / 2;
    final radiusY = (end.y - start.y).abs() / 2;

    // Diamond vertices
    final top = PixelPoint(centerX.round(), (centerY - radiusY).round(), color: start.color);
    final right = PixelPoint((centerX + radiusX).round(), centerY.round(), color: start.color);
    final bottom = PixelPoint(centerX.round(), (centerY + radiusY).round(), color: start.color);
    final left = PixelPoint((centerX - radiusX).round(), centerY.round(), color: start.color);

    // Draw diamond edges
    points.addAll(_drawLine(top, right, width, height));
    points.addAll(_drawLine(right, bottom, width, height));
    points.addAll(_drawLine(bottom, left, width, height));
    points.addAll(_drawLine(left, top, width, height));

    return _removeDuplicates(points);
  }
}

// Arrow shape tool - great for UI elements and indicators
class ArrowTool extends ShapeTool {
  ArrowTool() : super(PixelTool.arrow);

  @override
  List<PixelPoint<int>> generateShapePoints(
    PixelPoint<int> start,
    PixelPoint<int> end,
    int width,
    int height,
  ) {
    final points = <PixelPoint<int>>[];

    final dx = end.x - start.x;
    final dy = end.y - start.y;
    final length = sqrt(dx * dx + dy * dy);

    if (length < 2) {
      if (_isValidCoord(start.x, start.y, width, height)) {
        points.add(PixelPoint(start.x, start.y, color: start.color));
      }
      return points;
    }

    // Normalize direction vector
    final unitX = dx / length;
    final unitY = dy / length;

    // Threshold to switch between single-line and thick arrow
    const thicknessThreshold = 30.0;

    if (length < thicknessThreshold) {
      // --- Single-line arrow ---
      points.addAll(_drawLine(start, end, width, height));

      // Arrowhead
      final headLength = max(3.0, length * 0.4);
      const angle = pi / 6; // 30 degrees

      // Vector for first part of arrowhead
      final headX1 = end.x - headLength * (unitX * cos(angle) - unitY * sin(angle));
      final headY1 = end.y - headLength * (unitY * cos(angle) + unitX * sin(angle));
      points.addAll(_drawLine(end, PixelPoint(headX1.round(), headY1.round(), color: start.color), width, height));

      // Vector for second part of arrowhead
      final headX2 = end.x - headLength * (unitX * cos(-angle) - unitY * sin(-angle));
      final headY2 = end.y - headLength * (unitY * cos(-angle) + unitX * sin(-angle));
      points.addAll(_drawLine(end, PixelPoint(headX2.round(), headY2.round(), color: start.color), width, height));
    } else {
      // --- Thick arrow ---
      final headLength = length * 0.3;
      final headWidth = headLength * 0.6;
      final shaftWidth = max(1.0, length * 0.08); // Thickness scaling

      // Calculate arrow points
      final shaftEndX = start.x + unitX * (length - headLength);
      final shaftEndY = start.y + unitY * (length - headLength);

      // Perpendicular vector for width
      final perpX = -unitY;
      final perpY = unitX;

      // Shaft points defining the polygon
      final shaftPoints = [
        PixelPoint((start.x + perpX * shaftWidth / 2).round(), (start.y + perpY * shaftWidth / 2).round(),
            color: start.color),
        PixelPoint((shaftEndX + perpX * shaftWidth / 2).round(), (shaftEndY + perpY * shaftWidth / 2).round(),
            color: start.color),
        PixelPoint((shaftEndX + perpX * headWidth / 2).round(), (shaftEndY + perpY * headWidth / 2).round(),
            color: start.color),
        PixelPoint(end.x, end.y, color: start.color), // Arrow tip
        PixelPoint((shaftEndX - perpX * headWidth / 2).round(), (shaftEndY - perpY * headWidth / 2).round(),
            color: start.color),
        PixelPoint((shaftEndX - perpX * shaftWidth / 2).round(), (shaftEndY - perpY * shaftWidth / 2).round(),
            color: start.color),
        PixelPoint((start.x - perpX * shaftWidth / 2).round(), (start.y - perpY * shaftWidth / 2).round(),
            color: start.color),
      ];

      // Connect all points to form arrow outline
      for (int i = 0; i < shaftPoints.length; i++) {
        final current = shaftPoints[i];
        final next = shaftPoints[(i + 1) % shaftPoints.length];
        points.addAll(_drawLine(current, next, width, height));
      }
    }

    return _removeDuplicates(points);
  }
}

// Hexagon shape tool - perfect for game tiles and geometric patterns
class HexagonTool extends ShapeTool {
  HexagonTool() : super(PixelTool.contour);

  @override
  List<PixelPoint<int>> generateShapePoints(
    PixelPoint<int> start,
    PixelPoint<int> end,
    int width,
    int height,
  ) {
    final points = <PixelPoint<int>>[];

    final centerX = (start.x + end.x) / 2;
    final centerY = (start.y + end.y) / 2;
    final radius = sqrt((end.x - start.x) * (end.x - start.x) + (end.y - start.y) * (end.y - start.y)) / 2;

    final hexPoints = <PixelPoint<int>>[];

    // Generate 6 vertices of hexagon
    for (int i = 0; i < 6; i++) {
      final angle = i * pi / 3; // 60 degrees between each vertex
      final x = centerX + radius * cos(angle);
      final y = centerY + radius * sin(angle);
      hexPoints.add(PixelPoint(x.round(), y.round(), color: start.color));
    }

    // Connect all vertices
    for (int i = 0; i < hexPoints.length; i++) {
      final current = hexPoints[i];
      final next = hexPoints[(i + 1) % hexPoints.length];
      points.addAll(_drawLine(current, next, width, height));
    }

    return _removeDuplicates(points);
  }
}

// Lightning bolt shape tool - great for effects and power-ups
class LightningTool extends ShapeTool {
  LightningTool() : super(PixelTool.contour);

  @override
  List<PixelPoint<int>> generateShapePoints(
    PixelPoint<int> start,
    PixelPoint<int> end,
    int width,
    int height,
  ) {
    final points = <PixelPoint<int>>[];

    final dx = end.x - start.x;
    final dy = end.y - start.y;

    // Create lightning bolt points as fractions of the total distance
    final lightningPoints = [
      PixelPoint(start.x, start.y, color: start.color),
      PixelPoint((start.x + dx * 0.2).round(), (start.y + dy * 0.3).round(), color: start.color),
      PixelPoint((start.x + dx * 0.6).round(), (start.y + dy * 0.25).round(), color: start.color),
      PixelPoint((start.x + dx * 0.4).round(), (start.y + dy * 0.5).round(), color: start.color),
      PixelPoint((start.x + dx * 0.8).round(), (start.y + dy * 0.45).round(), color: start.color),
      PixelPoint((start.x + dx * 0.5).round(), (start.y + dy * 0.7).round(), color: start.color),
      PixelPoint((start.x + dx * 0.9).round(), (start.y + dy * 0.75).round(), color: start.color),
      PixelPoint(end.x, end.y, color: start.color),
    ];

    // Connect lightning points
    for (int i = 0; i < lightningPoints.length - 1; i++) {
      points.addAll(_drawLine(lightningPoints[i], lightningPoints[i + 1], width, height));
    }

    return _removeDuplicates(points);
  }
}

// Cross/plus shape tool - useful for markers and UI elements
class CrossTool extends ShapeTool {
  CrossTool() : super(PixelTool.contour);

  @override
  List<PixelPoint<int>> generateShapePoints(
    PixelPoint<int> start,
    PixelPoint<int> end,
    int width,
    int height,
  ) {
    final points = <PixelPoint<int>>[];

    final centerX = (start.x + end.x) / 2;
    final centerY = (start.y + end.y) / 2;
    final radiusX = (end.x - start.x).abs() / 2;
    final radiusY = (end.y - start.y).abs() / 2;

    // Vertical line of cross
    final top = PixelPoint(centerX.round(), (centerY - radiusY).round(), color: start.color);
    final bottom = PixelPoint(centerX.round(), (centerY + radiusY).round(), color: start.color);
    points.addAll(_drawLine(top, bottom, width, height));

    // Horizontal line of cross
    final left = PixelPoint((centerX - radiusX).round(), centerY.round(), color: start.color);
    final right = PixelPoint((centerX + radiusX).round(), centerY.round(), color: start.color);
    points.addAll(_drawLine(left, right, width, height));

    return _removeDuplicates(points);
  }
}

// Triangle shape tool with proper pixel art rendering
class TriangleTool extends ShapeTool {
  TriangleTool() : super(PixelTool.contour);

  @override
  List<PixelPoint<int>> generateShapePoints(
    PixelPoint<int> start,
    PixelPoint<int> end,
    int width,
    int height,
  ) {
    final points = <PixelPoint<int>>[];

    // Create equilateral triangle
    final centerX = (start.x + end.x) / 2;
    final centerY = (start.y + end.y) / 2;
    final radius = sqrt((end.x - start.x) * (end.x - start.x) + (end.y - start.y) * (end.y - start.y)) / 2;

    // Triangle vertices (pointing up)
    final top = PixelPoint(centerX.round(), (centerY - radius).round(), color: start.color);
    final bottomLeft = PixelPoint((centerX - radius * cos(pi / 6)).round(), (centerY + radius * sin(pi / 6)).round(),
        color: start.color);
    final bottomRight = PixelPoint((centerX + radius * cos(pi / 6)).round(), (centerY + radius * sin(pi / 6)).round(),
        color: start.color);

    // Draw triangle edges
    points.addAll(_drawLine(top, bottomLeft, width, height));
    points.addAll(_drawLine(bottomLeft, bottomRight, width, height));
    points.addAll(_drawLine(bottomRight, top, width, height));

    return _removeDuplicates(points);
  }
}

// Spiral shape tool - creates interesting decorative patterns
class SpiralTool extends ShapeTool {
  SpiralTool() : super(PixelTool.contour);

  @override
  List<PixelPoint<int>> generateShapePoints(
    PixelPoint<int> start,
    PixelPoint<int> end,
    int width,
    int height,
  ) {
    final points = <PixelPoint<int>>[];

    final centerX = (start.x + end.x) / 2;
    final centerY = (start.y + end.y) / 2;
    final maxRadius = sqrt((end.x - start.x) * (end.x - start.x) + (end.y - start.y) * (end.y - start.y)) / 2;

    const turns = 3; // Number of spiral turns
    const steps = 100; // Resolution of spiral

    for (int i = 0; i < steps; i++) {
      final t = i / (steps - 1); // 0 to 1
      final angle = turns * 2 * pi * t;
      final radius = maxRadius * t;

      final x = centerX + radius * cos(angle);
      final y = centerY + radius * sin(angle);

      if (_isValidCoord(x.round(), y.round(), width, height)) {
        points.add(PixelPoint(x.round(), y.round(), color: start.color));
      }
    }

    return _removeDuplicates(points);
  }
}

// Pixel Cloud shape tool - organic, cloud-like shapes
class CloudTool extends ShapeTool {
  CloudTool() : super(PixelTool.cloud);

  @override
  List<PixelPoint<int>> generateShapePoints(
    PixelPoint<int> start,
    PixelPoint<int> end,
    int width,
    int height,
  ) {
    // Calculate bounding box
    final left = min(start.x, end.x);
    final top = min(start.y, end.y);
    final cloudWidth = (end.x - start.x).abs() + 1;
    final cloudHeight = (end.y - start.y).abs() + 1;
    final centerX = left + cloudWidth / 2;
    final centerY = top + cloudHeight / 2;

    // Improved cloud shape: more horizontal, puffy, with varied bump sizes
    final baseRadius = max(cloudWidth * 0.2, cloudHeight * 0.3);
    final cloudCenters = <List<double>>[
      [centerX - baseRadius * 1.2, centerY, baseRadius * 0.8], // Left bump
      [centerX, centerY, baseRadius * 1.2], // Center bump (larger)
      [centerX + baseRadius * 1.2, centerY, baseRadius * 0.8], // Right bump
      [centerX - baseRadius * 0.6, centerY - baseRadius * 0.5, baseRadius * 0.6], // Top-left small bump
      [centerX + baseRadius * 0.6, centerY - baseRadius * 0.5, baseRadius * 0.6], // Top-right small bump
      [centerX, centerY - baseRadius * 0.8, baseRadius * 0.7], // Top center bump
    ];

    // Create ShapeUtils instance to get filled circle points
    final shapeUtils = ShapeUtils(width: width, height: height);

    // Collect all filled pixels from overlapping circles (union)
    final filledPixels = <String>{};
    for (final center in cloudCenters) {
      final cx = center[0].round();
      final cy = center[1].round();
      final r = center[2].round();
      final bumpPixels = shapeUtils.getCirclePoints(cx, cy, r);
      for (final pixel in bumpPixels) {
        final key = '${pixel.x},${pixel.y}';
        filledPixels.add(key);
      }
    }

    // Extract border pixels: pixels with at least one empty neighbor
    final borderPoints = <PixelPoint<int>>[];
    for (final key in filledPixels) {
      final parts = key.split(',');
      final x = int.parse(parts[0]);
      final y = int.parse(parts[1]);

      // Check 4-directional neighbors
      final neighbors = [
        '${x - 1},$y',
        '${x + 1},$y',
        '$x,${y - 1}',
        '$x,${y + 1}',
      ];

      bool isBorder = false;
      for (final neighbor in neighbors) {
        if (!filledPixels.contains(neighbor)) {
          isBorder = true;
          break;
        }
      }

      // Also consider edges of canvas as border
      if (x == 0 || x == width - 1 || y == 0 || y == height - 1) {
        isBorder = true;
      }

      if (isBorder && _isValidCoord(x, y, width, height)) {
        borderPoints.add(PixelPoint(x, y, color: start.color));
      }
    }

    return borderPoints;
  }
}

// Shared utility methods for all shape tools
extension ShapeToolUtils on ShapeTool {
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
      if (_isValidCoord(x0, y0, width, height)) {
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

  bool _isValidCoord(int x, int y, int width, int height) {
    return x >= 0 && x < width && y >= 0 && y < height;
  }

  List<PixelPoint<int>> _removeDuplicates(List<PixelPoint<int>> points) {
    final seen = <String>{};
    final unique = <PixelPoint<int>>[];

    for (final point in points) {
      final key = '${point.x},${point.y}';
      if (!seen.contains(key)) {
        seen.add(key);
        unique.add(point);
      }
    }

    return unique;
  }
}

// Helper function used by all shape tools
bool _isValidPoint(Point<int> point, int width, int height) {
  return point.x >= 0 && point.x < width && point.y >= 0 && point.y < height;
}
