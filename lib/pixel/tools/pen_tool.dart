import 'dart:ui';

import '../../core/pixel_point.dart';
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
      }
    } else {
      // First point in the path
      _pathPoints.add(position);
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

  void _finalizePath(PixelDrawDetails details) {
    if (_pathPoints.length < 3) return; // Need at least 3 points for a path

    // Convert path to pixel points using ShapeUtils
    final updatedShapeUtils = ShapeUtils(
      width: details.width,
      height: details.height,
    );

    _currentPixels = updatedShapeUtils.getPenPathPixels(
      _pathPoints,
      close: true,
      size: details.size,
    );

    // Apply modifiers if needed
    if (details.modifier != null) {
      final modifier = details.modifier!;
      List<PixelPoint<int>> modifiedPixels = [];

      for (final point in _currentPixels) {
        modifiedPixels.add(point);

        final modPoints = modifier.apply(
          point,
          details.width,
          details.height,
        );

        modifiedPixels.addAll(modPoints);
      }

      _currentPixels = modifiedPixels;
    }

    details.onPixelsUpdated(_currentPixels);

    // Reset state
    _isDrawing = false;
    _isClosingPath = false;
    _pathPoints = [];
    _currentPixels = [];
  }
}
