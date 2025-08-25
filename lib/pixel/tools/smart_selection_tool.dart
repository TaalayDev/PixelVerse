import 'dart:collection';
import 'dart:typed_data';

import '../pixel_point.dart';
import '../tools.dart';

class SmartSelectionTool extends Tool {
  SmartSelectionTool() : super(PixelTool.smartSelect);

  @override
  void onStart(PixelDrawDetails details) {
    final pixels = details.currentLayer.processedPixels;
    final pixelPosition = details.pixelPosition;

    if (!_isValid(pixelPosition, details.width, details.height)) return;

    final targetColor = pixels[pixelPosition.y * details.width + pixelPosition.x];
    final selectedPoints = _floodFill(
      pixels,
      pixelPosition,
      targetColor,
      details.width,
      details.height,
    );

    details.onPixelsUpdated(selectedPoints);
  }

  @override
  void onMove(PixelDrawDetails details) {
    // Not needed for a tap-based tool
  }

  @override
  void onEnd(PixelDrawDetails details) {
    // Not needed for a tap-based tool
  }

  bool _isValid(PixelPoint<int> point, int width, int height) {
    return point.x >= 0 && point.x < width && point.y >= 0 && point.y < height;
  }

  List<PixelPoint<int>> _floodFill(
    Uint32List pixels,
    PixelPoint<int> start,
    int targetColor,
    int width,
    int height,
  ) {
    final selectedPoints = <PixelPoint<int>>[];
    final queue = Queue<PixelPoint<int>>();
    final visited = <int>{};

    final startIndex = start.y * width + start.x;
    if (pixels[startIndex] != targetColor) return [];

    queue.add(start);
    visited.add(startIndex);

    while (queue.isNotEmpty) {
      final current = queue.removeFirst();
      selectedPoints.add(PixelPoint(current.x, current.y, color: targetColor));

      _checkAndAdd(
        pixels,
        PixelPoint(current.x + 1, current.y),
        targetColor,
        width,
        height,
        queue,
        visited,
      );
      _checkAndAdd(
        pixels,
        PixelPoint(current.x - 1, current.y),
        targetColor,
        width,
        height,
        queue,
        visited,
      );
      _checkAndAdd(
        pixels,
        PixelPoint(current.x, current.y + 1),
        targetColor,
        width,
        height,
        queue,
        visited,
      );
      _checkAndAdd(
        pixels,
        PixelPoint(current.x, current.y - 1),
        targetColor,
        width,
        height,
        queue,
        visited,
      );
    }

    return selectedPoints;
  }

  void _checkAndAdd(
    Uint32List pixels,
    PixelPoint<int> point,
    int targetColor,
    int width,
    int height,
    Queue<PixelPoint<int>> queue,
    Set<int> visited,
  ) {
    if (!_isValid(point, width, height)) return;

    final index = point.y * width + point.x;
    if (visited.contains(index) || pixels[index] != targetColor) return;

    visited.add(index);
    queue.add(point);
  }
}
