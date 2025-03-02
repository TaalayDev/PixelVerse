import 'dart:collection';
import 'dart:math';
import 'dart:typed_data';

import '../../core/pixel_point.dart';
import '../tools.dart';

class FillTool extends Tool {
  FillTool() : super(PixelTool.fill);

  @override
  void onStart(PixelDrawDetails details) {
    final point = details.pixelPosition;
    if (_isValidPoint(point, details.width, details.height)) {
      final pixels = _floodFill(
        details.currentLayer.pixels,
        point,
        details.color.value,
        details.width,
        details.height,
        details.modifier,
      );
      details.onPixelsUpdated(pixels);
    }
  }

  @override
  void onMove(PixelDrawDetails details) {
    // Fill tool only operates on start
  }

  @override
  void onEnd(PixelDrawDetails details) {
    // No cleanup needed
  }

  List<PixelPoint<int>> _floodFill(
    Uint32List pixels,
    PixelPoint<int> startPoint,
    int newColor,
    int width,
    int height,
    Modifier? modifier,
  ) {
    final fillPoints = <PixelPoint<int>>{};
    final targetColor = pixels[startPoint.y * width + startPoint.x];

    // Don't fill if colors are the same
    if (targetColor == newColor) {
      return [];
    }

    // Queue for flood fill
    final queue = Queue<PixelPoint<int>>();
    queue.add(startPoint);
    fillPoints.add(startPoint);

    // Add modifier point if needed
    if (modifier != null) {
      final modPoint = modifier.apply(startPoint, width, height);
      queue.addAll(modPoint);
      fillPoints.addAll(modPoint);
    }

    while (queue.isNotEmpty) {
      final point = queue.removeFirst();
      final x = point.x;
      final y = point.y;

      // Check 4-connected neighbors
      final neighbors = [
        PixelPoint(x + 1, y, color: newColor),
        PixelPoint(x - 1, y, color: newColor),
        PixelPoint(x, y + 1, color: newColor),
        PixelPoint(x, y - 1, color: newColor),
      ];

      for (final neighbor in neighbors) {
        if (!_isValidPoint(neighbor, width, height)) continue;

        final index = neighbor.y * width + neighbor.x;
        if (pixels[index] == targetColor && !fillPoints.contains(neighbor)) {
          queue.add(neighbor);
          fillPoints.add(neighbor);

          // Handle modifier
          if (modifier != null) {
            final modPoint = modifier.apply(neighbor, width, height);
            if (!fillPoints.contains(modPoint)) {
              queue.addAll(modPoint);
              fillPoints.addAll(modPoint);
            }
          }
        }
      }
    }

    return fillPoints.toList();
  }

  bool _isValidPoint(PixelPoint<int> point, int width, int height) {
    return point.x >= 0 && point.x < width && point.y >= 0 && point.y < height;
  }
}

// Optional: Extended version with advanced features
class AdvancedFillTool extends FillTool {
  final double tolerance;
  final bool contiguous;

  AdvancedFillTool({
    this.tolerance = 0.0,
    this.contiguous = true,
  });

  @override
  List<PixelPoint<int>> _floodFill(
    Uint32List pixels,
    PixelPoint<int> startPoint,
    int newColor,
    int width,
    int height,
    Modifier? modifier,
  ) {
    if (contiguous) {
      return _contiguousFill(
        pixels,
        startPoint,
        newColor,
        width,
        height,
        modifier,
      );
    } else {
      return _globalFill(pixels, startPoint, newColor, width, height, modifier);
    }
  }

  List<PixelPoint<int>> _contiguousFill(
    Uint32List pixels,
    PixelPoint<int> startPoint,
    int newColor,
    int width,
    int height,
    Modifier? modifier,
  ) {
    final fillPoints = <PixelPoint<int>>{};
    final targetColor = pixels[startPoint.y * width + startPoint.x];

    if (_colorsMatch(targetColor, newColor)) {
      return [];
    }

    final queue = Queue<PixelPoint<int>>();
    queue.add(startPoint);
    fillPoints.add(startPoint);

    while (queue.isNotEmpty) {
      final point = queue.removeFirst();
      final x = point.x;
      final y = point.y;

      // Check 8-connected neighbors for more natural fill
      for (int dy = -1; dy <= 1; dy++) {
        for (int dx = -1; dx <= 1; dx++) {
          if (dx == 0 && dy == 0) continue;

          final neighbor = PixelPoint(x + dx, y + dy, color: newColor);
          if (!_isValidPoint(neighbor, width, height)) continue;

          final index = neighbor.y * width + neighbor.x;
          if (_colorWithinTolerance(pixels[index], targetColor) &&
              !fillPoints.contains(neighbor)) {
            queue.add(neighbor);
            fillPoints.add(neighbor);

            if (modifier != null) {
              final modPoint = modifier.apply(neighbor, width, height);
              if (!fillPoints.contains(modPoint)) {
                queue.addAll(modPoint);
                fillPoints.addAll(modPoint);
              }
            }
          }
        }
      }
    }

    return fillPoints.toList();
  }

  List<PixelPoint<int>> _globalFill(
    Uint32List pixels,
    PixelPoint<int> startPoint,
    int newColor,
    int width,
    int height,
    Modifier? modifier,
  ) {
    final fillPoints = <PixelPoint<int>>{};
    final targetColor = pixels[startPoint.y * width + startPoint.x];

    if (_colorsMatch(targetColor, newColor)) {
      return [];
    }

    // Check all pixels in the image
    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final index = y * width + x;
        if (_colorWithinTolerance(pixels[index], targetColor)) {
          final point = PixelPoint(x, y, color: newColor);
          fillPoints.add(point);

          if (modifier != null) {
            final modPoint = modifier.apply(point, width, height);
            fillPoints.addAll(modPoint);
          }
        }
      }
    }

    return fillPoints.toList();
  }

  bool _colorWithinTolerance(int color1, int color2) {
    if (tolerance == 0.0) return color1 == color2;

    final r1 = (color1 >> 16) & 0xFF;
    final g1 = (color1 >> 8) & 0xFF;
    final b1 = color1 & 0xFF;
    final a1 = (color1 >> 24) & 0xFF;

    final r2 = (color2 >> 16) & 0xFF;
    final g2 = (color2 >> 8) & 0xFF;
    final b2 = color2 & 0xFF;
    final a2 = (color2 >> 24) & 0xFF;

    final diff = sqrt(
        pow(r1 - r2, 2) + pow(g1 - g2, 2) + pow(b1 - b2, 2) + pow(a1 - a2, 2));

    return diff <= (tolerance * 441.67); // 441.67 = sqrt(255^2 * 4)
  }

  bool _colorsMatch(int color1, int color2) {
    return _colorWithinTolerance(color1, color2);
  }
}
