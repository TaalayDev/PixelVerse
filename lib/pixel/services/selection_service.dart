import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../data.dart';

class SelectionService {
  final int width;
  final int height;

  SelectionModel? _selectionRect;
  SelectionModel? _originalSelectionRect;
  List<MapEntry<Point<int>, int>> _selectedPixels = [];
  Uint32List _cachedPixels = Uint32List(0);

  SelectionModel? get currentSelection => _selectionRect;
  bool get hasSelection => _selectionRect != null;

  SelectionService({required this.width, required this.height});

  void setSelection(SelectionModel? selection, Uint32List layerPixels) {
    debugPrint('Setting selection: $selection');
    _selectionRect = selection?.copyWith();
    _originalSelectionRect = selection?.copyWith();

    if (selection != null) {
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
    required SelectionModel newTargetSelection,
    required Uint32List currentLayerPixels,
  }) {
    if (_originalSelectionRect == null || _selectedPixels.isEmpty) {
      _selectionRect = newTargetSelection.copyWith();
      return currentLayerPixels;
    }

    final pixelsToModify = Uint32List.fromList(_cachedPixels);
    final origRect = _originalSelectionRect!;

    final dX = ((newTargetSelection.x - origRect.x) * 0.08).floor();
    final dY = ((newTargetSelection.y - origRect.y) * 0.08).floor();

    for (final entry in _selectedPixels) {
      final originalPoint = entry.key;
      final color = entry.value;

      final newX = originalPoint.x + dX;
      final newY = originalPoint.y + dY;

      if (isPointInSelection(newX, newY)) {
        continue; // Skip if the new point is still within the selection bounds
      }

      if (newX >= 0 && newX < width && newY >= 0 && newY < height) {
        final newIndex = newY * width + newX;
        if (newIndex >= 0 && newIndex < pixelsToModify.length) {
          pixelsToModify[newIndex] = color;
        }
      }
    }

    _selectionRect = newTargetSelection.copyWith();

    return pixelsToModify;
  }

  void clearSelection() {
    _selectionRect = null;
    _originalSelectionRect = null;
    _selectedPixels = [];
    _cachedPixels = Uint32List(0);
  }

  bool isPointInSelection(int x, int y) {
    if (_selectionRect == null) return false;

    final rect = _selectionRect!.rect;
    return x >= rect.left && x < rect.right && y >= rect.top && y < rect.bottom;
  }

  bool isPointsInSelection(List<Point<int>> points) {
    if (_selectionRect == null) return true;

    final rect = _selectionRect!.rect;
    for (final point in points) {
      if (point.x < rect.left || point.x >= rect.right || point.y < rect.top || point.y >= rect.bottom) {
        return false;
      }
    }
    return true;
  }

  SelectionModel? constrainSelectionToBounds({
    required SelectionModel selection,
    required int width,
    required int height,
  }) {
    final constrainedX = selection.x.clamp(0, width - selection.width);
    final constrainedY = selection.y.clamp(0, height - selection.height);
    final constrainedWidth = (selection.width).clamp(1, width - constrainedX);
    final constrainedHeight = (selection.height).clamp(1, height - constrainedY);

    if (constrainedX == selection.x &&
        constrainedY == selection.y &&
        constrainedWidth == selection.width &&
        constrainedHeight == selection.height) {
      return selection;
    }

    return SelectionModel(
      x: constrainedX,
      y: constrainedY,
      width: constrainedWidth,
      height: constrainedHeight,
      canvasSize: selection.canvasSize,
    );
  }

  List<MapEntry<Point<int>, int>> _getSelectedPixels(
    SelectionModel selection,
    Uint32List pixels,
  ) {
    final selectedPixels = <MapEntry<Point<int>, int>>[];
    final canvasSize = selection.canvasSize;

    final gridWidth = width;
    final gridHeight = height;

    final pixelWidth = canvasSize.width / width;
    final pixelHeight = canvasSize.height / width;

    final startX = (selection.x / pixelWidth).floor().clamp(0, gridWidth - 1);
    final startY = (selection.y / pixelHeight).floor().clamp(0, gridHeight - 1);
    final endX = ((selection.x + selection.width) / pixelWidth).floor().clamp(0, gridWidth);
    final endY = ((selection.y + selection.height) / pixelHeight).floor().clamp(0, gridHeight);

    for (int y = startY; y < endY; y++) {
      for (int x = startX; x < endX; x++) {
        final index = y * gridWidth + x;
        if (index >= 0 && index < pixels.length) {
          final color = pixels[index];
          if (color == Colors.transparent.value) continue;
          selectedPixels.add(MapEntry(Point(x, y), color));
        }
      }
    }

    return selectedPixels;
  }

  void _removeSelectedPixelsFromCache() {
    if (_originalSelectionRect == null || _selectedPixels.isEmpty) return;

    for (final entry in _selectedPixels) {
      final originalPoint = entry.key;
      final index = originalPoint.y * width + originalPoint.x;

      if (index >= 0 && index < _cachedPixels.length) {
        _cachedPixels[index] = Colors.transparent.value; // Удаляем пиксель из кэша
      }
    }
  }

  bool _isPointInOriginalSelection(int x, int y) {
    if (_originalSelectionRect == null) return false;

    final rect = _originalSelectionRect!.rect;
    return x >= rect.left && x < rect.right && y >= rect.top && y < rect.bottom;
  }

  // Create selection from two points (for rectangle selection)
  SelectionModel? createSelectionFromPoints({
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

    return SelectionModel(
      x: minX,
      y: minY,
      width: width,
      height: height,
      canvasSize: canvasSize,
    );
  }
}
