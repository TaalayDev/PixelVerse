import 'dart:ui';
import 'dart:math';

import '../pixel_point.dart';
import '../tools.dart';
import 'shape_util.dart';

class PenTool extends Tool {
  List<PixelPoint<int>> _currentPixels = [];
  List<Offset> _pathPoints = [];
  bool _isDrawing = false;
  bool _isClosingPath = false;
  final _closeThreshold = 10.0;

  PenTool() : super(PixelTool.pen);

  @override
  void onStart(PixelDrawDetails details) {
    if (!_isDrawing) {
      _currentPixels = [];
      _pathPoints = [];
      _isDrawing = true;
    }

    final position = details.position;

    if (_pathPoints.isNotEmpty) {
      final startPoint = _pathPoints[0];
      if ((position - startPoint).distance <= _closeThreshold) {
        // Close the path if close to the starting point
        _pathPoints.add(startPoint);
        _finalizePath(details);
      } else {
        // Add new point to the path
        _pathPoints.add(position);
        _updatePathPreview(details);
      }
    } else {
      // First point in the path
      _pathPoints.add(position);
      _updatePathPreview(details);
    }
  }

  @override
  void onMove(PixelDrawDetails details) {
    if (!_isDrawing || _pathPoints.isEmpty) return;

    final position = details.position;
    final startPoint = _pathPoints[0];

    // Check if we're close to the starting point to close the path
    if ((position - startPoint).distance <= _closeThreshold) {
      _isClosingPath = true;
    } else {
      _isClosingPath = false;
    }
  }

  @override
  void onEnd(PixelDrawDetails details) {
    if (_isClosingPath && _pathPoints.length > 2) {
      // Close and finalize the path
      _pathPoints.add(_pathPoints[0]);
      _finalizePath(details);
    }
  }

  void _updatePathPreview(PixelDrawDetails details) {
    if (_pathPoints.length < 2) {
      // Single point - just show the point
      final pixelPos = details.pixelPosition;
      if (_isValidPoint(pixelPos, details.width, details.height)) {
        _currentPixels = [PixelPoint(pixelPos.x, pixelPos.y, color: details.color.value)];
        details.onPixelsUpdated(_currentPixels);
      }
      return;
    }

    // Generate preview of the current path
    final shapeUtils = ShapeUtils(
      width: details.width,
      height: details.height,
    );

    _currentPixels = shapeUtils.getPenPathPixels(
      _pathPoints,
      close: false,
      size: details.size,
    );

    // Apply color to pixels
    final coloredPixels =
        _currentPixels.map((point) => PixelPoint(point.x, point.y, color: details.color.value)).toList();

    // Apply stroke width if needed
    List<PixelPoint<int>> finalPixels;
    if (details.strokeWidth > 1) {
      finalPixels = _applyStrokeWidth(coloredPixels, details);
    } else {
      finalPixels = coloredPixels;
    }

    // Apply modifiers if needed
    if (details.modifier != null) {
      final modifiedPixels = <PixelPoint<int>>[];
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

  void _finalizePath(PixelDrawDetails details) {
    if (_pathPoints.length < 3) return; // Need at least 3 points for a path

    // Convert path to pixel points using improved ShapeUtils
    final shapeUtils = ShapeUtils(
      width: details.width,
      height: details.height,
    );

    _currentPixels = shapeUtils.getPenPathPixels(
      _pathPoints,
      close: true,
      size: details.size,
    );

    // Apply color to pixels
    final coloredPixels =
        _currentPixels.map((point) => PixelPoint(point.x, point.y, color: details.color.value)).toList();

    // Apply stroke width if needed
    List<PixelPoint<int>> finalPixels;
    if (details.strokeWidth > 1) {
      finalPixels = _applyStrokeWidth(coloredPixels, details);
    } else {
      finalPixels = coloredPixels;
    }

    // Apply modifiers if needed
    if (details.modifier != null) {
      final modifiedPixels = <PixelPoint<int>>[];
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

    // Reset state
    _isDrawing = false;
    _isClosingPath = false;
    _pathPoints = [];
    _currentPixels = [];
  }

  /// Apply stroke width to the path pixels
  List<PixelPoint<int>> _applyStrokeWidth(
    List<PixelPoint<int>> pathPixels,
    PixelDrawDetails details,
  ) {
    if (details.strokeWidth <= 1) return pathPixels;

    final thickenedPoints = <PixelPoint<int>>[];
    final halfStroke = details.strokeWidth ~/ 2;
    final added = <String>{};

    for (final point in pathPixels) {
      // Create a circular brush pattern for more natural strokes
      final radius = halfStroke;

      for (int dy = -radius; dy <= radius; dy++) {
        for (int dx = -radius; dx <= radius; dx++) {
          // Use circular pattern instead of square
          if (dx * dx + dy * dy <= radius * radius) {
            final newX = point.x + dx;
            final newY = point.y + dy;
            final key = '$newX,$newY';

            if (!added.contains(key) &&
                _isValidPoint(PixelPoint(newX, newY, color: 0), details.width, details.height)) {
              added.add(key);
              thickenedPoints.add(PixelPoint(
                newX,
                newY,
                color: point.color,
              ));
            }
          }
        }
      }
    }

    return thickenedPoints;
  }

  /// Get current path points for preview rendering
  List<Offset> get pathPoints => List.unmodifiable(_pathPoints);

  /// Check if currently drawing a path
  bool get isDrawing => _isDrawing;

  /// Check if close to starting point
  bool get isClosingPath => _isClosingPath;

  /// Get close threshold distance
  double get closeThreshold => _closeThreshold;

  /// Force close the current path
  void forceClosePath(PixelDrawDetails details) {
    if (_isDrawing && _pathPoints.length > 2) {
      _pathPoints.add(_pathPoints[0]);
      _finalizePath(details);
    }
  }

  /// Cancel current path without finalizing
  void cancelPath() {
    _isDrawing = false;
    _isClosingPath = false;
    _pathPoints.clear();
    _currentPixels.clear();
  }

  /// Reset tool state
  void reset() {
    cancelPath();
  }

  bool _isValidPoint(PixelPoint<int> point, int width, int height) {
    return point.x >= 0 && point.x < width && point.y >= 0 && point.y < height;
  }
}
