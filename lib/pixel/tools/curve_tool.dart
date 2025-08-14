import 'dart:ui';
import 'dart:math';

import '../pixel_point.dart';
import '../tools.dart';

/// Tool for drawing smooth curves using Bézier curves with pixel-perfect generation
class CurveTool extends Tool {
  List<PixelPoint<int>> _currentPixels = [];

  // Curve state
  Offset? _startPoint;
  Offset? _endPoint;
  Offset? _controlPoint;
  bool _hasStartPoint = false;
  bool _hasEndPoint = false;
  bool _isDefiningCurve = false;

  CurveTool() : super(PixelTool.curve);

  bool get hasStartPoint => _hasStartPoint;
  bool get hasEndPoint => _hasEndPoint;
  bool get isDefiningCurve => _isDefiningCurve;
  Offset? get startPoint => _startPoint;
  Offset? get endPoint => _endPoint;
  Offset? get controlPoint => _controlPoint;

  @override
  void onStart(PixelDrawDetails details) {
    final position = details.position;

    if (!_hasStartPoint) {
      _startPoint = position;
      _hasStartPoint = true;
      _currentPixels.clear();

      // Add a single pixel at start point for visual feedback
      final pixelPos = details.pixelPosition.copyWith(color: details.color.value);
      if (_isValidPoint(pixelPos, details.width, details.height)) {
        _currentPixels.add(pixelPos);
        details.onPixelsUpdated(_currentPixels);
      }
    } else if (!_hasEndPoint) {
      _endPoint = position;
      _hasEndPoint = true;
      _isDefiningCurve = true;

      _updateCurvePreview(details, position);
    } else if (_isDefiningCurve) {
      _controlPoint = position;
      _finalizeCurve(details);
    }
  }

  @override
  void onMove(PixelDrawDetails details) {
    if (_hasStartPoint && _hasEndPoint && _isDefiningCurve) {
      _updateCurvePreview(details, details.position);
    }
  }

  @override
  void onEnd(PixelDrawDetails details) {}

  void _updateCurvePreview(PixelDrawDetails details, Offset currentPosition) {
    if (_startPoint == null || _endPoint == null) return;

    _controlPoint = currentPosition;
    _currentPixels.clear();

    final curvePoints = _generatePixelPerfectBezierCurve(
      _startPoint!,
      _controlPoint!,
      _endPoint!,
      details.size,
      details.width,
      details.height,
    );

    List<PixelPoint<int>> finalPixels = [];
    if (details.strokeWidth == 1) {
      finalPixels = curvePoints.map((p) => PixelPoint(p.x, p.y, color: details.color.value)).toList();
    } else {
      finalPixels = _applyStrokeWidth(curvePoints, details);
    }

    if (details.modifier != null) {
      List<PixelPoint<int>> modifiedPixels = [];
      for (final point in finalPixels) {
        modifiedPixels.add(point);
        final modPoints = details.modifier!.apply(
          point,
          details.width,
          details.height,
        );
        modifiedPixels.addAll(modPoints);
      }
      finalPixels = modifiedPixels;
    }

    _currentPixels = finalPixels;
    details.onPixelsUpdated(_currentPixels);
  }

  void _finalizeCurve(PixelDrawDetails details) {
    details.onPixelsUpdated(_currentPixels);
    _reset();
  }

  void _reset() {
    _startPoint = null;
    _endPoint = null;
    _controlPoint = null;
    _hasStartPoint = false;
    _hasEndPoint = false;
    _isDefiningCurve = false;
    _currentPixels.clear();
  }

  /// Generates pixel-perfect Bézier curve using adaptive sampling and line drawing
  List<PixelPoint<int>> _generatePixelPerfectBezierCurve(
    Offset start,
    Offset control,
    Offset end,
    Size canvasSize,
    int canvasWidth,
    int canvasHeight,
  ) {
    final pixelWidth = canvasSize.width / canvasWidth;
    final pixelHeight = canvasSize.height / canvasHeight;

    // Convert screen coordinates to pixel coordinates
    final startPixel = _screenToPixel(start, pixelWidth, pixelHeight);
    final controlPixel = _screenToPixel(control, pixelWidth, pixelHeight);
    final endPixel = _screenToPixel(end, pixelWidth, pixelHeight);

    // Use adaptive sampling to get curve points
    final curvePixels = _adaptiveBezierSampling(startPixel, controlPixel, endPixel);

    // Connect points with pixel-perfect lines to eliminate gaps
    final connectedPixels = _connectPixelsWithLines(curvePixels);

    // Remove duplicates while preserving order
    final uniquePixels = _removeDuplicatePixels(connectedPixels);

    // Filter out invalid points
    return uniquePixels.where((p) => _isValidPoint(p, canvasWidth, canvasHeight)).toList();
  }

  Point<int> _screenToPixel(Offset screenPos, double pixelWidth, double pixelHeight) {
    return Point<int>(
      (screenPos.dx / pixelWidth).round(),
      (screenPos.dy / pixelHeight).round(),
    );
  }

  /// Adaptive sampling that increases density in curved areas
  List<PixelPoint<int>> _adaptiveBezierSampling(
    Point<int> start,
    Point<int> control,
    Point<int> end,
  ) {
    final points = <PixelPoint<int>>[];

    // Calculate curve length approximation for initial step count
    final approxLength = _approximateCurveLength(start, control, end);
    final baseSteps = max(approxLength ~/ 2, 10); // At least 10 steps

    // Generate points with adaptive subdivision
    _subdivideQuadraticBezier(
      start.x.toDouble(), start.y.toDouble(),
      control.x.toDouble(), control.y.toDouble(),
      end.x.toDouble(), end.y.toDouble(),
      points,
      0.0, 1.0,
      tolerance: 0.5, // Pixel tolerance
      maxDepth: 8,
    );

    return points;
  }

  /// Recursive subdivision for smooth curves
  void _subdivideQuadraticBezier(double x0, double y0, double x1, double y1, double x2, double y2,
      List<PixelPoint<int>> points, double t0, double t1,
      {required double tolerance, required int maxDepth}) {
    if (maxDepth <= 0) {
      // Add endpoint
      points.add(PixelPoint(x2.round(), y2.round(), color: 0));
      return;
    }

    // Calculate midpoint
    final tMid = (t0 + t1) / 2;
    final midPoint = _evaluateQuadraticBezier(x0, y0, x1, y1, x2, y2, tMid);

    // Calculate expected midpoint if this was a straight line
    final linearMid = Point<double>((x0 + x2) / 2, (y0 + y2) / 2);

    // Check if curve deviates significantly from straight line
    final deviation = sqrt(pow(midPoint.x - linearMid.x, 2) + pow(midPoint.y - linearMid.y, 2));

    if (deviation <= tolerance) {
      // Curve is close to straight line, add endpoint
      points.add(PixelPoint(x2.round(), y2.round(), color: 0));
    } else {
      // Subdivide further
      final mid = _evaluateQuadraticBezier(x0, y0, x1, y1, x2, y2, tMid);

      // Calculate control points for subdivided curves using De Casteljau's algorithm
      final q0 = Point<double>(x0, y0);
      final q1 = Point<double>((x0 + x1) / 2, (y0 + y1) / 2);
      final q2 = Point<double>((x1 + x2) / 2, (y1 + y2) / 2);
      final r0 = Point<double>((q1.x + q2.x) / 2, (q1.y + q2.y) / 2);

      // First half
      _subdivideQuadraticBezier(
        q0.x,
        q0.y,
        q1.x,
        q1.y,
        r0.x,
        r0.y,
        points,
        t0,
        tMid,
        tolerance: tolerance,
        maxDepth: maxDepth - 1,
      );

      // Second half
      _subdivideQuadraticBezier(
        r0.x,
        r0.y,
        q2.x,
        q2.y,
        x2,
        y2,
        points,
        tMid,
        t1,
        tolerance: tolerance,
        maxDepth: maxDepth - 1,
      );
    }
  }

  Point<double> _evaluateQuadraticBezier(
    double x0,
    double y0,
    double x1,
    double y1,
    double x2,
    double y2,
    double t,
  ) {
    final oneMinusT = 1 - t;
    final x = oneMinusT * oneMinusT * x0 + 2 * oneMinusT * t * x1 + t * t * x2;
    final y = oneMinusT * oneMinusT * y0 + 2 * oneMinusT * t * y1 + t * t * y2;
    return Point<double>(x, y);
  }

  double _approximateCurveLength(Point<int> start, Point<int> control, Point<int> end) {
    // Use control polygon approximation
    final d1 = sqrt(pow(control.x - start.x, 2) + pow(control.y - start.y, 2));
    final d2 = sqrt(pow(end.x - control.x, 2) + pow(end.y - control.y, 2));
    final d3 = sqrt(pow(end.x - start.x, 2) + pow(end.y - start.y, 2));

    // Weighted average that tends toward the control polygon length
    return (d1 + d2 + d3) * 0.8;
  }

  /// Connect curve points with pixel-perfect lines to eliminate gaps
  List<PixelPoint<int>> _connectPixelsWithLines(List<PixelPoint<int>> curvePixels) {
    if (curvePixels.length <= 1) return curvePixels;

    final connectedPixels = <PixelPoint<int>>[];
    connectedPixels.add(curvePixels.first);

    for (int i = 1; i < curvePixels.length; i++) {
      final start = curvePixels[i - 1];
      final end = curvePixels[i];

      // Add line pixels between consecutive curve points
      final linePixels = _getBresenhamLine(start, end);

      // Skip the first pixel to avoid duplication
      for (int j = 1; j < linePixels.length; j++) {
        connectedPixels.add(linePixels[j]);
      }
    }

    return connectedPixels;
  }

  /// Bresenham's line algorithm for pixel-perfect lines
  List<PixelPoint<int>> _getBresenhamLine(PixelPoint<int> start, PixelPoint<int> end) {
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
      points.add(PixelPoint(x0, y0, color: 0));

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

  List<PixelPoint<int>> _applyStrokeWidth(
    List<PixelPoint<int>> curvePoints,
    PixelDrawDetails details,
  ) {
    final thickenedPoints = <PixelPoint<int>>[];
    final halfStroke = details.strokeWidth ~/ 2;
    final added = <String>{};

    for (final point in curvePoints) {
      // Add pixels in a square pattern around each point
      for (int dx = -halfStroke; dx <= halfStroke; dx++) {
        for (int dy = -halfStroke; dy <= halfStroke; dy++) {
          final newX = point.x + dx;
          final newY = point.y + dy;
          final key = '$newX,$newY';

          if (!added.contains(key) && _isValidPoint(PixelPoint(newX, newY, color: 0), details.width, details.height)) {
            added.add(key);
            thickenedPoints.add(PixelPoint(
              newX,
              newY,
              color: details.color.value,
            ));
          }
        }
      }
    }

    return thickenedPoints;
  }

  bool _isValidPoint(PixelPoint<int> point, int width, int height) {
    return point.x >= 0 && point.x < width && point.y >= 0 && point.y < height;
  }
}
