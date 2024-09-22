import 'dart:collection';
import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../core/tools.dart';
import '../data.dart';

part 'pixel_controller_provider.g.dart';

class Layer extends Equatable {
  final String name;
  final List<Color> pixels;
  final bool isVisible;
  final bool isLocked;
  final double opacity;

  const Layer(
    this.name,
    this.pixels, {
    this.isVisible = true,
    this.isLocked = false,
    this.opacity = 1.0,
  });

  @override
  List<Object?> get props => [name, pixels, isVisible, isLocked, opacity];
}

class PixelDrawState extends Equatable {
  final int width;
  final int height;
  final List<Color> pixels;
  final int currentLayerIndex;
  final Color currentColor;
  final PixelTool currentTool;
  final MirrorAxis mirrorAxis;
  final SelectionModel? selectionRect;
  final bool canUndo;
  final bool canRedo;

  const PixelDrawState({
    required this.width,
    required this.height,
    required this.pixels,
    this.currentLayerIndex = 0,
    required this.currentColor,
    required this.currentTool,
    required this.mirrorAxis,
    required this.selectionRect,
    this.canUndo = false,
    this.canRedo = false,
  });

  PixelDrawState copyWith({
    int? width,
    int? height,
    List<Color>? pixels,
    Color? currentColor,
    PixelTool? currentTool,
    MirrorAxis? mirrorAxis,
    bool? canUndo,
    bool? canRedo,
    SelectionModel? selectionRect,
    List<List<Color>>? undoStack,
    List<List<Color>>? redoStack,
  }) {
    return PixelDrawState(
      width: width ?? this.width,
      height: height ?? this.height,
      pixels: pixels ?? this.pixels,
      currentColor: currentColor ?? this.currentColor,
      currentTool: currentTool ?? this.currentTool,
      mirrorAxis: mirrorAxis ?? this.mirrorAxis,
      selectionRect: selectionRect ?? this.selectionRect,
      canUndo: canUndo ?? this.canUndo,
      canRedo: canRedo ?? this.canRedo,
    );
  }

  @override
  List<Object?> get props => [
        width,
        height,
        pixels,
        currentColor,
        currentTool,
        mirrorAxis,
        selectionRect,
        canUndo,
        canRedo,
        currentLayerIndex,
      ];
}

@riverpod
class PixelDrawNotifier extends _$PixelDrawNotifier {
  PixelTool get currentTool => state.currentTool;
  set currentTool(PixelTool tool) => state = state.copyWith(currentTool: tool);
  MirrorAxis get mirrorAxis => state.mirrorAxis;
  int get width => state.width;
  int get height => state.height;
  Color get currentColor => state.currentColor;
  set currentColor(Color color) => state = state.copyWith(currentColor: color);

  final List<List<Color>> _undoStack = [];
  final List<List<Color>> _redoStack = [];

  bool get canUndo => _undoStack.isNotEmpty;
  bool get canRedo => _redoStack.isNotEmpty;

  SelectionModel? _selectionRect;
  SelectionModel? _originalSelectionRect;
  List<MapEntry<Point<int>, Color>> _selectedPixels = [];
  List<Color> _cachedPixels = [];

  @override
  PixelDrawState build({int width = 32, int height = 32}) {
    return PixelDrawState(
      width: width,
      height: height,
      pixels: List.filled(width * height, Colors.transparent),
      currentColor: Colors.black,
      currentTool: PixelTool.pencil,
      mirrorAxis: MirrorAxis.vertical,
      selectionRect: null,
    );
  }

  void setPixel(int x, int y) {
    if (x >= 0 && x < width && y >= 0 && y < height) {
      if (_selectionRect != null && !_isPointInSelection(x, y)) {
        return;
      }

      _drawPixel(x, y);
      if (currentTool == PixelTool.mirror) {
        _drawMirroredPixels(x, y);
      }

      if (_selectionRect != null) {
        _selectedPixels.add(MapEntry(Point(x, y), currentColor));
      }
    }
  }

  void _drawPixel(int x, int y) {
    final pixels = state.pixels;
    pixels[y * width + x] = currentColor;
    state = state.copyWith(pixels: pixels);
  }

  void _drawMirroredPixels(int x, int y) {
    switch (mirrorAxis) {
      case MirrorAxis.horizontal:
        int mirroredY = height - 1 - y;
        _drawPixel(x, mirroredY);
        break;
      case MirrorAxis.vertical:
        int mirroredX = width - 1 - x;
        _drawPixel(mirroredX, y);
        break;
      case MirrorAxis.both:
        int mirroredX = width - 1 - x;
        int mirroredY = height - 1 - y;
        _drawPixel(mirroredX, y); // Vertical mirror
        _drawPixel(x, mirroredY); // Horizontal mirror
        _drawPixel(mirroredX, mirroredY); // Both axes
        break;
    }
  }

  void updatePixels(List<Point<int>> pixels) {
    final newPixels = List<Color>.from(state.pixels);

    for (final point in pixels) {
      int index = point.y * state.width + point.x;
      if (index >= 0 && index < newPixels.length) {
        newPixels[index] = currentColor;
      }
    }

    state = state.copyWith(pixels: newPixels);
  }

  void fill(int x, int y) {
    if (x < 0 || x >= width || y < 0 || y >= height) return;

    final pixels = List<Color>.from(state.pixels);
    final targetColor = pixels[y * width + x];
    if (targetColor == currentColor) return;

    saveState();

    final queue = Queue<Point<int>>();
    queue.add(Point(x, y));

    while (queue.isNotEmpty) {
      final point = queue.removeFirst();
      final px = point.x;
      final py = point.y;

      if (px < 0 || px >= width || py < 0 || py >= height) continue;
      if (pixels[py * width + px] != targetColor) continue;

      if (_selectionRect != null && !_isPointInSelection(px, py)) {
        continue;
      }

      pixels[py * width + px] = currentColor;

      queue.add(Point(px + 1, py));
      queue.add(Point(px - 1, py));
      queue.add(Point(px, py + 1));
      queue.add(Point(px, py - 1));

      if (_selectionRect != null) {
        _selectedPixels.add(MapEntry(Point(px, py), currentColor));
      }
    }

    state = state.copyWith(pixels: pixels);
  }

  void drawShape(List<Point<int>> points) {
    for (final point in points) {
      setPixel(point.x, point.y);
    }
  }

  void applyContour(
    int startX,
    int startY,
    Color contourColor, {
    int thickness = 1,
  }) {
    saveState();

    final width = state.width;
    final height = state.height;
    final pixels = List<Color>.from(state.pixels);
    final targetColor = pixels[startY * width + startX];

    if (targetColor == Colors.transparent) return;
    print('Applying contour at $startX, $startY');
    // Use a Set to avoid duplicate points
    final contourPoints = <Point<int>>{};

    // Directions to check neighboring pixels (8-connectivity)
    final directions = [
      Point(0, -1), // Up
      Point(1, -1), // Up-right
      Point(1, 0), // Right
      Point(1, 1), // Down-right
      Point(0, 1), // Down
      Point(-1, 1), // Down-left
      Point(-1, 0), // Left
      Point(-1, -1), // Up-left
    ];

    // Flood fill to find all connected pixels
    final visited = Set<Point<int>>();
    final queue = Queue<Point<int>>();
    queue.add(Point(startX, startY));

    while (queue.isNotEmpty) {
      final point = queue.removeFirst();
      final x = point.x;
      final y = point.y;

      if (!visited.add(point)) continue;

      for (final dir in directions) {
        final nx = x + dir.x;
        final ny = y + dir.y;
        if (nx >= 0 && nx < width && ny >= 0 && ny < height) {
          final neighborColor = pixels[ny * width + nx];
          if (neighborColor == targetColor &&
              !visited.contains(Point(nx, ny))) {
            queue.add(Point(nx, ny));
          } else if (neighborColor != targetColor) {
            // Edge pixel; add to contour points
            contourPoints.add(point);
          }
        }
      }
    }

    // Apply contour thickness
    for (int t = 0; t < thickness; t++) {
      final newContourPoints = <Point<int>>{};
      for (final point in contourPoints) {
        for (final dir in directions) {
          final nx = point.x + dir.x;
          final ny = point.y + dir.y;
          if (nx >= 0 && nx < width && ny >= 0 && ny < height) {
            final index = ny * width + nx;
            if (pixels[index] != targetColor && pixels[index] != contourColor) {
              pixels[index] = contourColor;
              newContourPoints.add(Point(nx, ny));
            }
          }
        }
      }
      contourPoints.addAll(newContourPoints);
    }

    // Update the state
    state = state.copyWith(pixels: pixels, canUndo: true, canRedo: false);
  }

  void clear() {
    saveState();

    state = state.copyWith(
      pixels: List.filled(width * height, Colors.transparent),
      canUndo: true,
      canRedo: false,
    );
  }

  void undo() {
    if (!canUndo) return;

    var pixels = List<Color>.from(state.pixels);

    _redoStack.add(pixels);
    pixels = _undoStack.removeLast();

    state = state.copyWith(
      pixels: pixels,
      canUndo: _undoStack.isNotEmpty,
      canRedo: _redoStack.isNotEmpty,
    );
  }

  void redo() {
    if (!canRedo) return;

    _undoStack.add(state.pixels);
    state = state.copyWith(
      pixels: _redoStack.removeLast(),
      canUndo: _undoStack.isNotEmpty,
      canRedo: _redoStack.isNotEmpty,
    );
  }

  void saveState() {
    _undoStack.add(state.pixels);
    if (_undoStack.length > 50) {
      _undoStack.removeAt(0);
    }
    _redoStack.clear();
    state = state.copyWith(canUndo: true, canRedo: false);
  }

  void resize(int newWidth, int newHeight) {
    final pixels = List<Color>.from(state.pixels);
    List<Color> newPixels = List.filled(
      newWidth * newHeight,
      Colors.transparent,
    );
    for (int y = 0; y < height && y < newHeight; y++) {
      for (int x = 0; x < width && x < newWidth; x++) {
        newPixels[y * newWidth + x] = pixels[y * width + x];
      }
    }

    state = state.copyWith(
      width: newWidth,
      height: newHeight,
      pixels: newPixels,
    );
  }

  void applyGradient(List<Color> gradientColors) {
    final pixels = List<Color>.from(state.pixels);
    for (int i = 0; i < pixels.length; i++) {
      if (gradientColors[i] != Colors.transparent) {
        pixels[i] = Color.alphaBlend(gradientColors[i], pixels[i]);
      }
    }
    state = state.copyWith(pixels: pixels);
  }

  void setSelection(SelectionModel? selection) {
    _selectionRect = selection;
    _originalSelectionRect = selection;
    if (selection != null) {
      _selectedPixels = _getSelectedPixels(selection);
      _cachedPixels = state.pixels;
    } else {
      _selectedPixels = [];
      _cachedPixels = [];
    }
    state = state.copyWith(selectionRect: selection);
  }

  void moveSelection(SelectionModel model) {
    if (_selectionRect == null) return;

    // Calculate the difference in positions
    final dx = model.x - _selectionRect!.x;
    final dy = model.y - _selectionRect!.y;

    // Create a new list for the updated selected pixels
    List<MapEntry<Point<int>, Color>> newSelectedPixels = [];
    final pixels = List<Color>.from(state.pixels);

    // Clear the pixels at the old positions
    for (final entry in _selectedPixels) {
      final x = entry.key.x;
      final y = entry.key.y;
      if (x >= 0 && x < width && y >= 0 && y < height) {
        final p = y * width + x;
        pixels[p] =
            _originalSelectionRect != null && !_isPointInOriginalSelection(x, y)
                ? _cachedPixels[p]
                : Colors.transparent;
      }
    }

    // Update the positions of selected pixels and apply them to the canvas
    for (final entry in _selectedPixels) {
      final newX = entry.key.x + dx;
      final newY = entry.key.y + dy;
      if (newX >= 0 && newX < width && newY >= 0 && newY < height) {
        pixels[newY * width + newX] = entry.value == Colors.transparent
            ? pixels[newY * width + newX]
            : entry.value;
        newSelectedPixels.add(MapEntry(Point(newX, newY), entry.value));
      }
    }

    // Update the selected pixels list with new positions
    _selectedPixels = newSelectedPixels;

    // Update the selection rectangle
    _selectionRect = model;

    state = state.copyWith(pixels: pixels);
  }

  List<MapEntry<Point<int>, Color>> _getSelectedPixels(
    SelectionModel selection,
  ) {
    List<MapEntry<Point<int>, Color>> selectedPixels = [];
    final pixels = state.pixels;
    for (int y = selection.y; y < selection.y + selection.height; y++) {
      for (int x = selection.x; x < selection.x + selection.width; x++) {
        if (x >= 0 && x < width && y >= 0 && y < height) {
          final color = pixels[y * width + x];
          selectedPixels.add(MapEntry(Point(x, y), color));
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

  bool _isPointInSelection(int x, int y) {
    if (_selectionRect == null) return false;

    final rect = _selectionRect!.rect;
    return x >= rect.left && x < rect.right && y >= rect.top && y < rect.bottom;
  }
}
