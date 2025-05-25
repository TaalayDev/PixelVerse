import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../data.dart';

class SelectionService {
  SelectionModel? _selectionRect;
  SelectionModel? _originalSelectionRect;
  List<MapEntry<Point<int>, int>> _selectedPixels = [];
  Uint32List _cachedPixels = Uint32List(0);

  SelectionModel? get currentSelection => _selectionRect;
  bool get hasSelection => _selectionRect != null;

  void setSelection(SelectionModel? selection, Uint32List layerPixels) {
    _selectionRect = selection;
    _originalSelectionRect = selection;

    if (selection != null) {
      _selectedPixels = _getSelectedPixels(selection, layerPixels);
      _cachedPixels = Uint32List.fromList(layerPixels);
    } else {
      _selectedPixels = [];
      _cachedPixels = Uint32List(0);
    }
  }

  Uint32List moveSelection({
    required SelectionModel newSelection,
    required Uint32List currentPixels,
    required int width,
    required int height,
  }) {
    if (_selectionRect == null || _selectedPixels.isEmpty) {
      return currentPixels;
    }

    // Calculate the difference in positions
    final dx = newSelection.x - _selectionRect!.x;
    final dy = newSelection.y - _selectionRect!.y;

    final pixels = Uint32List.fromList(currentPixels);
    final newSelectedPixels = <MapEntry<Point<int>, int>>[];

    // Clear pixels at old positions
    for (final entry in _selectedPixels) {
      final x = entry.key.x;
      final y = entry.key.y;
      if (x >= 0 && x < width && y >= 0 && y < height) {
        final index = y * width + x;
        pixels[index] = _originalSelectionRect != null && !_isPointInOriginalSelection(x, y)
            ? _cachedPixels[index]
            : Colors.transparent.value;
      }
    }

    // Apply pixels at new positions
    for (final entry in _selectedPixels) {
      final newX = entry.key.x + dx;
      final newY = entry.key.y + dy;

      if (newX >= 0 && newX < width && newY >= 0 && newY < height) {
        final index = newY * width + newX;
        if (entry.value != Colors.transparent.value) {
          pixels[index] = entry.value;
        }
        newSelectedPixels.add(MapEntry(Point(newX, newY), entry.value));
      }
    }

    // Update state
    _selectedPixels = newSelectedPixels;
    _selectionRect = newSelection;

    return pixels;
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
    );
  }

  List<MapEntry<Point<int>, int>> _getSelectedPixels(
    SelectionModel selection,
    Uint32List pixels,
  ) {
    final selectedPixels = <MapEntry<Point<int>, int>>[];
    final width = sqrt(pixels.length).round(); // Assuming square canvas for simplicity

    for (int y = selection.y; y < selection.y + selection.height; y++) {
      for (int x = selection.x; x < selection.x + selection.width; x++) {
        if (x >= 0 && x < width && y >= 0 && y < width) {
          final index = y * width + x;
          if (index < pixels.length) {
            final color = pixels[index];
            selectedPixels.add(MapEntry(Point(x, y), color));
          }
        }
      }
    }

    return selectedPixels;
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
    );
  }
}
