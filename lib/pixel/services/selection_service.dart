import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../data.dart';
import '../pixel_point.dart';
import '../pixel_utils.dart';

enum TransformMode {
  none,
  move,
  scale,
  rotate,
}

enum ScaleHandle {
  topLeft,
  topCenter,
  topRight,
  rightCenter,
  bottomRight,
  bottomCenter,
  bottomLeft,
  leftCenter,
}

class TransformationState {
  final Offset centerPoint;
  final double scale;
  final double rotation;
  final Offset translation;
  final TransformMode mode;

  const TransformationState({
    this.centerPoint = Offset.zero,
    this.scale = 1.0,
    this.rotation = 0.0,
    this.translation = Offset.zero,
    this.mode = TransformMode.none,
  });

  TransformationState copyWith({
    Offset? centerPoint,
    double? scale,
    double? rotation,
    Offset? translation,
    TransformMode? mode,
  }) {
    return TransformationState(
      centerPoint: centerPoint ?? this.centerPoint,
      scale: scale ?? this.scale,
      rotation: rotation ?? this.rotation,
      translation: translation ?? this.translation,
      mode: mode ?? this.mode,
    );
  }
}

class SelectionService {
  final int width;
  final int height;

  List<PixelPoint<int>>? _selectionRect;
  List<PixelPoint<int>>? _originalSelectionRect;
  List<PixelPoint<int>> _selectedPixels = [];
  Uint32List _cachedPixels = Uint32List(0);
  Uint32List? _originalSelectedPixels;

  // Transformation state
  TransformationState _transformState = const TransformationState();
  bool _isTransforming = false;
  Offset? _customCenterPoint;

  List<PixelPoint<int>>? get currentSelection => _selectionRect;
  bool get hasSelection => _selectionRect != null && _selectionRect!.isNotEmpty;
  TransformationState get transformState => _transformState;
  bool get isTransforming => _isTransforming;
  Offset? get customCenterPoint => _customCenterPoint;

  SelectionService({required this.width, required this.height});

  void setSelection(List<PixelPoint<int>>? selection, Uint32List layerPixels) {
    _selectionRect = selection?.isNotEmpty == true ? List<PixelPoint<int>>.from(selection!) : null;
    _originalSelectionRect = selection != null ? List<PixelPoint<int>>.from(selection) : null;

    if (selection != null && selection.isNotEmpty) {
      _cachedPixels = Uint32List.fromList(layerPixels);
      _selectedPixels = _getSelectedPixels(selection, layerPixels);
      _originalSelectedPixels = Uint32List.fromList(layerPixels);

      // Reset transformation state
      _transformState = const TransformationState();
      _isTransforming = false;
      _customCenterPoint = null;

      // Remove selected pixels from the cache
      _removeSelectedPixelsFromCache();
    } else {
      _selectedPixels = [];
      _cachedPixels = Uint32List(0);
      _originalSelectedPixels = null;
      _transformState = const TransformationState();
      _isTransforming = false;
      _customCenterPoint = null;
    }
  }

  Offset getSelectionCenter() {
    if (_selectionRect == null || _selectionRect!.isEmpty) return Offset.zero;

    final bounds = _getSelectionBounds(_selectionRect!);
    return Offset(
      bounds.minX + (bounds.maxX - bounds.minX) / 2,
      bounds.minY + (bounds.maxY - bounds.minY) / 2,
    );
  }

  Offset getTransformCenter() {
    return _customCenterPoint ?? getSelectionCenter();
  }

  void setCustomCenterPoint(Offset? centerPoint) {
    _customCenterPoint = centerPoint;
  }

  void startTransformation(TransformMode mode) {
    if (!hasSelection) return;

    _isTransforming = true;
    _transformState = _transformState.copyWith(mode: mode);
  }

  void updateTransformation({
    double? scale,
    double? rotation,
    Offset? translation,
  }) {
    if (!_isTransforming) return;

    _transformState = _transformState.copyWith(
      scale: scale ?? _transformState.scale,
      rotation: rotation ?? _transformState.rotation,
      translation: translation ?? _transformState.translation,
      centerPoint: getTransformCenter(),
    );

    _applyTransformation();
  }

  void _applyTransformation() {
    if (_originalSelectedPixels == null || _selectedPixels.isEmpty) return;

    final bounds = _getSelectionBounds(_originalSelectionRect!);
    final selectionWidth = bounds.maxX - bounds.minX + 1;
    final selectionHeight = bounds.maxY - bounds.minY + 1;

    // Create a temporary image with the selected pixels
    final selectionPixels = Uint32List(selectionWidth * selectionHeight);

    for (final pixel in _selectedPixels) {
      final localX = pixel.x - bounds.minX;
      final localY = pixel.y - bounds.minY;

      if (localX >= 0 && localX < selectionWidth && localY >= 0 && localY < selectionHeight) {
        final index = localY * selectionWidth + localX;
        if (index < selectionPixels.length) {
          selectionPixels[index] = pixel.color;
        }
      }
    }

    // Apply transformations
    Uint32List transformedPixels = selectionPixels;

    if (_transformState.scale != 1.0) {
      transformedPixels = PixelUtils.applyScale(
        transformedPixels,
        selectionWidth,
        selectionHeight,
        _transformState.scale,
        selectionWidth / 2,
        selectionHeight / 2,
        1, // bilinear interpolation
        0, // transparent background
      );
    }

    if (_transformState.rotation != 0.0) {
      transformedPixels = PixelUtils.applyRotation(
        transformedPixels,
        selectionWidth,
        selectionHeight,
        _transformState.rotation,
        selectionWidth / 2,
        selectionHeight / 2,
        1.0, // zoom
        1, // bilinear interpolation
        0, // transparent background
      );
    }

    // Convert back to PixelPoint list with translation applied
    final transformedPixelPoints = <PixelPoint<int>>[];
    final centerOffset = getTransformCenter();
    final translationX = _transformState.translation.dx;
    final translationY = _transformState.translation.dy;

    for (int y = 0; y < selectionHeight; y++) {
      for (int x = 0; x < selectionWidth; x++) {
        final index = y * selectionWidth + x;
        if (index < transformedPixels.length) {
          final color = transformedPixels[index];
          if (color != 0) {
            // Skip transparent pixels
            final worldX = (bounds.minX + x - centerOffset.dx + translationX + centerOffset.dx).round();
            final worldY = (bounds.minY + y - centerOffset.dy + translationY + centerOffset.dy).round();

            if (worldX >= 0 && worldX < width && worldY >= 0 && worldY < height) {
              transformedPixelPoints.add(PixelPoint(worldX, worldY, color: color));
            }
          }
        }
      }
    }

    // Update selection bounds to match transformed area
    if (transformedPixelPoints.isNotEmpty) {
      _selectionRect = _createSelectionBounds(transformedPixelPoints);
    }
  }

  List<PixelPoint<int>> _createSelectionBounds(List<PixelPoint<int>> pixels) {
    if (pixels.isEmpty) return [];

    int minX = pixels.first.x;
    int minY = pixels.first.y;
    int maxX = pixels.first.x;
    int maxY = pixels.first.y;

    for (final pixel in pixels) {
      minX = min(minX, pixel.x);
      maxX = max(maxX, pixel.x);
      minY = min(minY, pixel.y);
      maxY = max(maxY, pixel.y);
    }

    final selection = <PixelPoint<int>>[];
    for (int y = minY; y <= maxY; y++) {
      for (int x = minX; x <= maxX; x++) {
        selection.add(PixelPoint(x, y));
      }
    }

    return selection;
  }

  Uint32List applyTransformationToPixels(Uint32List currentLayerPixels) {
    if (!_isTransforming || _selectedPixels.isEmpty) {
      return currentLayerPixels;
    }

    final result = Uint32List.fromList(_cachedPixels);

    // Apply the transformed pixels
    final bounds = _getSelectionBounds(_originalSelectionRect!);
    final selectionWidth = bounds.maxX - bounds.minX + 1;
    final selectionHeight = bounds.maxY - bounds.minY + 1;

    // Create selection pixel array
    final selectionPixels = Uint32List(selectionWidth * selectionHeight);
    for (final pixel in _selectedPixels) {
      final localX = pixel.x - bounds.minX;
      final localY = pixel.y - bounds.minY;

      if (localX >= 0 && localX < selectionWidth && localY >= 0 && localY < selectionHeight) {
        final index = localY * selectionWidth + localX;
        if (index < selectionPixels.length) {
          selectionPixels[index] = pixel.color;
        }
      }
    }

    // Apply transformations
    Uint32List transformedPixels = selectionPixels;

    if (_transformState.scale != 1.0) {
      transformedPixels = PixelUtils.applyScale(
        transformedPixels,
        selectionWidth,
        selectionHeight,
        _transformState.scale,
        selectionWidth / 2,
        selectionHeight / 2,
        1, // bilinear interpolation
        0, // transparent background
      );
    }

    if (_transformState.rotation != 0.0) {
      transformedPixels = PixelUtils.applyRotation(
        transformedPixels,
        selectionWidth,
        selectionHeight,
        _transformState.rotation,
        selectionWidth / 2,
        selectionHeight / 2,
        1.0, // zoom
        1, // bilinear interpolation
        0, // transparent background
      );
    }

    // Apply transformed pixels to result
    final centerOffset = getTransformCenter();
    final translationX = _transformState.translation.dx;
    final translationY = _transformState.translation.dy;

    for (int y = 0; y < selectionHeight; y++) {
      for (int x = 0; x < selectionWidth; x++) {
        final index = y * selectionWidth + x;
        if (index < transformedPixels.length) {
          final color = transformedPixels[index];
          if (color != 0) {
            final worldX = (bounds.minX + x - centerOffset.dx + translationX + centerOffset.dx).round();
            final worldY = (bounds.minY + y - centerOffset.dy + translationY + centerOffset.dy).round();

            if (worldX >= 0 && worldX < width && worldY >= 0 && worldY < height) {
              final worldIndex = worldY * width + worldX;
              if (worldIndex < result.length) {
                result[worldIndex] = color;
              }
            }
          }
        }
      }
    }

    return result;
  }

  void confirmTransformation() {
    if (!_isTransforming) return;

    _isTransforming = false;
    _transformState = const TransformationState();
    _customCenterPoint = null;
  }

  void cancelTransformation() {
    if (!_isTransforming) return;

    _isTransforming = false;
    _transformState = const TransformationState();
    _customCenterPoint = null;

    // Restore original selection
    if (_originalSelectionRect != null) {
      _selectionRect = List<PixelPoint<int>>.from(_originalSelectionRect!);
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
    _originalSelectedPixels = null;
    _transformState = const TransformationState();
    _isTransforming = false;
    _customCenterPoint = null;
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

  List<PixelPoint<int>> fromPointsToSelection(List<Point<int>> points) {
    if (points.isEmpty) {
      return [];
    }

    return points.map((point) => PixelPoint<int>(point.x, point.y)).toList();
  }

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
