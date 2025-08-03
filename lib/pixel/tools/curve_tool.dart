import 'dart:math' as math;
import 'dart:ui';

import '../pixel_point.dart';
import '../tools.dart';

/// Tool for drawing smooth curves using Bézier curves
/// User creates two points, then moves mouse to define the curve direction
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

  @override
  void onStart(PixelDrawDetails details) {
    final position = details.position;

    if (!_hasStartPoint) {
      // Set the first point
      _startPoint = position;
      _hasStartPoint = true;
      _currentPixels.clear();

      // Add a single pixel at start point for visual feedback
      final pixelPos = details.pixelPosition;
      if (_isValidPoint(pixelPos, details.width, details.height)) {
        _currentPixels.add(pixelPos);
        details.onPixelsUpdated(_currentPixels);
      }
    } else if (!_hasEndPoint) {
      // Set the second point
      _endPoint = position;
      _hasEndPoint = true;
      _isDefiningCurve = true;

      // Draw straight line between start and end for now
      _updateCurvePreview(details, position);
    } else if (_isDefiningCurve) {
      // Finalize the curve
      _controlPoint = position;
      _finalizeCurve(details);
    }
  }

  @override
  void onMove(PixelDrawDetails details) {
    if (_hasStartPoint && _hasEndPoint && _isDefiningCurve) {
      // Update curve preview as mouse moves
      _updateCurvePreview(details, details.position);
    }
  }

  @override
  void onEnd(PixelDrawDetails details) {
    // This tool uses clicks rather than drag, so onEnd doesn't finalize
    // The curve is finalized in onStart when the third click happens
  }

  void _updateCurvePreview(PixelDrawDetails details, Offset currentPosition) {
    if (_startPoint == null || _endPoint == null) return;

    _controlPoint = currentPosition;
    _currentPixels.clear();

    // Generate curve points using quadratic Bézier curve
    final curvePoints = _generateBezierCurve(
      _startPoint!,
      _controlPoint!,
      _endPoint!,
      details.size,
      details.width,
      details.height,
    );

    // Apply stroke width if needed
    List<PixelPoint<int>> finalPixels = [];
    if (details.strokeWidth == 1) {
      finalPixels = curvePoints;
    } else {
      finalPixels = _applyStrokeWidth(curvePoints, details);
    }

    // Apply modifier if present
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
    // The curve is already drawn in _currentPixels, just update it one final time
    details.onPixelsUpdated(_currentPixels);

    // Reset state for next curve
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

  /// Generate points along a quadratic Bézier curve
  List<PixelPoint<int>> _generateBezierCurve(
    Offset start,
    Offset control,
    Offset end,
    Size canvasSize,
    int canvasWidth,
    int canvasHeight,
  ) {
    final points = <PixelPoint<int>>[];
    final pixelWidth = canvasSize.width / canvasWidth;
    final pixelHeight = canvasSize.height / canvasHeight;

    // Calculate the number of steps based on curve length
    final curveLength = _estimateCurveLength(start, control, end);
    final steps = (curveLength * 2).ceil().clamp(10, 200); // Adaptive resolution

    for (int i = 0; i <= steps; i++) {
      final t = i / steps;
      final point = _quadraticBezier(start, control, end, t);

      final pixelX = (point.dx / pixelWidth).floor();
      final pixelY = (point.dy / pixelHeight).floor();

      if (_isValidPoint(
        PixelPoint(pixelX, pixelY, color: 0),
        canvasWidth,
        canvasHeight,
      )) {
        final pixelPoint = PixelPoint(pixelX, pixelY, color: 0);

        // Avoid duplicate consecutive points
        if (points.isEmpty || points.last.x != pixelPoint.x || points.last.y != pixelPoint.y) {
          points.add(pixelPoint);
        }
      }
    }

    return points;
  }

  /// Calculate a point on a quadratic Bézier curve
  Offset _quadraticBezier(Offset p0, Offset p1, Offset p2, double t) {
    final oneMinusT = 1 - t;
    final x = oneMinusT * oneMinusT * p0.dx + 2 * oneMinusT * t * p1.dx + t * t * p2.dx;
    final y = oneMinusT * oneMinusT * p0.dy + 2 * oneMinusT * t * p1.dy + t * t * p2.dy;
    return Offset(x, y);
  }

  /// Estimate the length of the curve for adaptive resolution
  double _estimateCurveLength(Offset start, Offset control, Offset end) {
    // Approximate using the control polygon
    final d1 = (control - start).distance;
    final d2 = (end - control).distance;
    final d3 = (end - start).distance;
    return (d1 + d2 + d3) / 2;
  }

  /// Apply stroke width to curve points
  List<PixelPoint<int>> _applyStrokeWidth(
    List<PixelPoint<int>> curvePoints,
    PixelDrawDetails details,
  ) {
    final thickenedPoints = <PixelPoint<int>>[];
    final halfStroke = details.strokeWidth ~/ 2;

    for (final point in curvePoints) {
      for (int dx = -halfStroke; dx <= halfStroke; dx++) {
        for (int dy = -halfStroke; dy <= halfStroke; dy++) {
          final newX = point.x + dx;
          final newY = point.y + dy;

          if (_isValidPoint(
            PixelPoint(newX, newY, color: 0),
            details.width,
            details.height,
          )) {
            final thickenedPoint = PixelPoint(
              newX,
              newY,
              color: details.color.value,
            );

            if (!thickenedPoints.contains(thickenedPoint)) {
              thickenedPoints.add(thickenedPoint);
            }
          }
        }
      }
    }

    return thickenedPoints;
  }

  bool _isValidPoint(PixelPoint<int> point, int width, int height) {
    return point.x >= 0 && point.x < width && point.y >= 0 && point.y < height;
  }

  // Getters for current state (useful for UI feedback)
  bool get hasStartPoint => _hasStartPoint;
  bool get hasEndPoint => _hasEndPoint;
  bool get isDefiningCurve => _isDefiningCurve;
  Offset? get startPoint => _startPoint;
  Offset? get endPoint => _endPoint;
  Offset? get controlPoint => _controlPoint;
}
