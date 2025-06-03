import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../data.dart';
import '../pixel_point.dart';

class SelectionService {
  final int width;
  final int height;

  List<PixelPoint<int>>? _selectionRect;
  List<PixelPoint<int>>? _originalSelectionRect;
  List<PixelPoint<int>> _selectedPixels = [];
  Uint32List _cachedPixels = Uint32List(0);

  List<PixelPoint<int>>? get currentSelection => _selectionRect;
  bool get hasSelection => _selectionRect != null && _selectionRect!.isNotEmpty;

  SelectionService({required this.width, required this.height});

  void setSelection(List<PixelPoint<int>>? selection, Uint32List layerPixels) {
    _selectionRect = selection?.isNotEmpty == true ? List<PixelPoint<int>>.from(selection!) : null;
    _originalSelectionRect = selection != null ? List<PixelPoint<int>>.from(selection) : null;

    if (selection != null && selection.isNotEmpty) {
      _cachedPixels = Uint32List.fromList(layerPixels);
      _selectedPixels = _getSelectedPixels(selection, layerPixels);
      // Remove selected pixels from the cache
      _removeSelectedPixelsFromCache();
    } else {
      _selectedPixels = [];
      _cachedPixels = Uint32List(0);
    }
  }

  Uint32List moveSelection({
    required List<PixelPoint<int>> newTargetSelection,
    required Point delta,
    required Uint32List currentLayerPixels,
  }) {
    if (_originalSelectionRect == null || _originalSelectionRect!.isEmpty || _selectedPixels.isEmpty) {
      _selectionRect = List<PixelPoint<int>>.from(newTargetSelection);
      return currentLayerPixels;
    }

    final pixelsToModify = Uint32List.fromList(_cachedPixels);

    for (final entry in _selectedPixels) {
      final originalPoint = entry;
      final color = entry.color;

      final newX = originalPoint.x + delta.x.toInt();
      final newY = originalPoint.y + delta.y.toInt();

      if (newX >= 0 && newX < width && newY >= 0 && newY < height) {
        final newIndex = newY * width + newX;
        if (newIndex >= 0 && newIndex < pixelsToModify.length) {
          pixelsToModify[newIndex] = color;
        }
      }
    }

    _selectionRect = List<PixelPoint<int>>.from(newTargetSelection);

    return pixelsToModify;
  }

  void clearSelection() {
    _selectionRect = null;
    _originalSelectionRect = null;
    _selectedPixels = [];
    _cachedPixels = Uint32List(0);
  }

  bool isPointInSelection(int x, int y) {
    if (_selectionRect == null || _selectionRect!.isEmpty) return false;
    return _isPointInSelection(x, y, _selectionRect!);
  }

  bool _isPointInSelection(int x, int y, List<PixelPoint<int>> selection) {
    final bounds = _getSelectionBounds(selection);
    return x >= bounds.minX && x <= bounds.maxX && y >= bounds.minY && y <= bounds.maxY;
  }

  bool isPointsInSelection(List<Point<int>> points) {
    if (_selectionRect == null || _selectionRect!.isEmpty) return true;

    final bounds = _getSelectionBounds(_selectionRect!);
    for (final point in points) {
      if (point.x < bounds.minX || point.x > bounds.maxX || point.y < bounds.minY || point.y > bounds.maxY) {
        return false;
      }
    }
    return true;
  }

  List<PixelPoint<int>>? constrainSelectionToBounds({
    required List<PixelPoint<int>> selection,
    required int width,
    required int height,
  }) {
    final constrainedSelection = <PixelPoint<int>>[];

    for (final point in selection) {
      if (point.x >= 0 && point.x < width && point.y >= 0 && point.y < height) {
        constrainedSelection.add(point);
      }
    }

    return constrainedSelection.isEmpty ? null : constrainedSelection;
  }

  List<PixelPoint<int>> _getSelectedPixels(
    List<PixelPoint<int>> selection,
    Uint32List pixels,
  ) {
    final selectedPixels = <PixelPoint<int>>[];
    final bounds = _getSelectionBounds(selection);

    for (int y = bounds.minY; y <= bounds.maxY; y++) {
      for (int x = bounds.minX; x <= bounds.maxX; x++) {
        final index = y * width + x;
        if (index >= 0 && index < pixels.length) {
          final color = pixels[index];
          if (color != Colors.transparent.value) {
            selectedPixels.add(PixelPoint(x, y, color: color));
          }
        }
      }
    }

    return selectedPixels;
  }

  void _removeSelectedPixelsFromCache() {
    if (_originalSelectionRect == null || _originalSelectionRect!.isEmpty || _selectedPixels.isEmpty) return;

    for (final entry in _selectedPixels) {
      final originalPoint = entry;
      final index = originalPoint.y * width + originalPoint.x;

      if (index >= 0 && index < _cachedPixels.length) {
        _cachedPixels[index] = Colors.transparent.value;
      }
    }
  }

  bool _isPointInOriginalSelection(int x, int y) {
    if (_originalSelectionRect == null || _originalSelectionRect!.isEmpty) return false;
    return _isPointInSelection(x, y, _originalSelectionRect!);
  }

  List<PixelPoint<int>> fromPointsToSelection(List<Point<int>> points) {
    if (points.isEmpty) {
      return [];
    }

    return points.map((point) => PixelPoint<int>(point.x, point.y)).toList();
  }

  // Helper method to get bounds of a selection
  _SelectionBounds _getSelectionBounds(List<PixelPoint<int>> selection) {
    if (selection.isEmpty) {
      return _SelectionBounds(minX: 0, minY: 0, maxX: 0, maxY: 0);
    }

    int minX = selection.first.x;
    int minY = selection.first.y;
    int maxX = selection.first.x;
    int maxY = selection.first.y;

    for (final point in selection) {
      minX = min(minX, point.x);
      minY = min(minY, point.y);
      maxX = max(maxX, point.x);
      maxY = max(maxY, point.y);
    }

    return _SelectionBounds(minX: minX, minY: minY, maxX: maxX, maxY: maxY);
  }

  // Create selection from two points (for rectangle selection)
  List<PixelPoint<int>>? createSelectionFromPoints({
    required Offset startPoint,
    required Offset endPoint,
    required Size canvasSize,
    required int gridWidth,
    required int gridHeight,
  }) {
    final pixelWidth = canvasSize.width / gridWidth;
    final pixelHeight = canvasSize.height / gridHeight;

    final startX = (startPoint.dx / pixelWidth).floor();
    final startY = (startPoint.dy / pixelHeight).floor();
    final endX = (endPoint.dx / pixelWidth).floor();
    final endY = (endPoint.dy / pixelHeight).floor();

    final minX = min(startX, endX);
    final minY = min(startY, endY);
    final maxX = max(startX, endX);
    final maxY = max(startY, endY);

    final width = maxX - minX + 1;
    final height = maxY - minY + 1;

    if (width <= 1 || height <= 1) return null;

    final selection = <PixelPoint<int>>[];
    for (int y = minY; y <= maxY; y++) {
      for (int x = minX; x <= maxX; x++) {
        selection.add(PixelPoint<int>(x, y));
      }
    }

    return selection;
  }

  // Create rectangular selection from bounds
  List<PixelPoint<int>> createRectangularSelection({
    required int x,
    required int y,
    required int width,
    required int height,
  }) {
    final selection = <PixelPoint<int>>[];

    for (int dy = 0; dy < height; dy++) {
      for (int dx = 0; dx < width; dx++) {
        final px = x + dx;
        final py = y + dy;
        if (px >= 0 && px < this.width && py >= 0 && py < this.height) {
          selection.add(PixelPoint<int>(px, py));
        }
      }
    }

    return selection;
  }
}

// Helper class for selection bounds
class _SelectionBounds {
  final int minX;
  final int minY;
  final int maxX;
  final int maxY;

  _SelectionBounds({
    required this.minX,
    required this.minY,
    required this.maxX,
    required this.maxY,
  });
}
