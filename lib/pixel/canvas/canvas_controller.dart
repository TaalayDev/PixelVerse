import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../data.dart';
import '../../pixel/tools.dart';
import '../effects/effects.dart';
import '../pixel_point.dart';
import 'layer_cache_manager.dart';

/// Controls the state and operations of the pixel canvas
class PixelCanvasController extends ChangeNotifier {
  final int width;
  final int height;
  final LayerCacheManager cacheManager;

  // Canvas state
  List<Layer> _layers = [];
  int _currentLayerIndex = 0;
  PixelTool _currentTool = PixelTool.pencil;
  double _zoomLevel = 1.0;
  Offset _offset = Offset.zero;
  List<PixelPoint<int>> _previewPixels = [];
  Uint32List _cachedPixels = Uint32List(0);

  // Drawing state
  SelectionModel? _selectionRect;
  List<Offset> _penPoints = [];
  bool _isDrawingPenPath = false;
  Offset? _gradientStart;
  Offset? _gradientEnd;

  Uint32List _processedPreviewPixels = Uint32List(0);
  bool _previewEffectsEnabled = true;

  PixelCanvasController({
    required this.width,
    required this.height,
    required List<Layer> layers,
    required int currentLayerIndex,
    required this.cacheManager,
  })  : _layers = List.from(layers),
        _currentLayerIndex = currentLayerIndex,
        _cachedPixels = Uint32List(width * height);

  // Getters
  List<Layer> get layers => _layers;
  int get currentLayerIndex => _currentLayerIndex;
  PixelTool get currentTool => _currentTool;
  double get zoomLevel => _zoomLevel;
  Offset get offset => _offset;
  List<PixelPoint<int>> get previewPixels => _previewPixels;
  Uint32List get cachedPixels => _cachedPixels;
  SelectionModel? get selectionRect => _selectionRect;
  List<Offset> get penPoints => _penPoints;
  bool get isDrawingPenPath => _isDrawingPenPath;
  Offset? get gradientStart => _gradientStart;
  Offset? get gradientEnd => _gradientEnd;

  Uint32List get processedPreviewPixels => _processedPreviewPixels;
  bool get previewEffectsEnabled => _previewEffectsEnabled;

  Layer get currentLayer => _layers[_currentLayerIndex];
  int get currentLayerId => currentLayer.layerId;

  void initialize(List<Layer> layers) {
    _layers = List.from(layers);
    _updateCachedPixels(cacheAll: true);
    notifyListeners();
  }

  void updateLayers(List<Layer> layers) {
    if (!listEquals(_layers, layers)) {
      final bool needsFullCache = _layers.length != layers.length;
      _layers = List.from(layers);
      _updateCachedPixels(cacheAll: needsFullCache);

      scheduleMicrotask(() {
        // Clear preview pixels after canvas is updated
        clearPreviewPixels();
      });
      notifyListeners();
    }
  }

  void setCurrentLayerIndex(int index) {
    if (_currentLayerIndex != index && index >= 0 && index < _layers.length) {
      _currentLayerIndex = index;
      _updateCachedPixels();
      notifyListeners();
    }
  }

  void setCurrentTool(PixelTool tool) {
    if (_currentTool != tool) {
      _currentTool = tool;
      _clearDrawingState();
      notifyListeners();
    }
  }

  void setZoomLevel(double zoom) {
    if (_zoomLevel != zoom) {
      _zoomLevel = zoom.clamp(0.5, 10.0);
      notifyListeners();
    }
  }

  void setOffset(Offset offset) {
    if (_offset != offset) {
      _offset = offset;
      notifyListeners();
    }
  }

  void setPreviewEffectsEnabled(bool enabled) {
    if (_previewEffectsEnabled != enabled) {
      _previewEffectsEnabled = enabled;
      _updatePreviewPixelsWithEffects();
      notifyListeners();
    }
  }

  void setPreviewPixels(List<PixelPoint<int>> pixels) {
    _previewPixels = pixels;
    _updateCurrentLayerCache();
    _updatePreviewPixelsWithEffects();
    notifyListeners();
  }

  void clearPreviewPixels() {
    _clearPreviewPixels();
    notifyListeners();
  }

  void _updatePreviewPixelsWithEffects() {
    final currentLayer = _layers[_currentLayerIndex];

    if (!_previewEffectsEnabled || _previewPixels.isEmpty || currentLayer.effects.isEmpty) {
      if (_processedPreviewPixels.isNotEmpty) {
        _processedPreviewPixels = Uint32List(0);
      }
      return;
    }

    // Create temporary pixel buffer from preview pixels
    final tempPixels = Uint32List(width * height);

    for (final point in _previewPixels) {
      final index = point.y * width + point.x;
      if (index >= 0 && index < tempPixels.length) {
        tempPixels[index] = point.color;
      }
    }

    _processedPreviewPixels = EffectsManager.applyMultipleEffects(tempPixels, width, height, currentLayer.effects);
  }

  void setSelection(SelectionModel? selection) {
    _selectionRect = selection;
    notifyListeners();
  }

  void setPenPoints(List<Offset> points) {
    _penPoints = points;
    notifyListeners();
  }

  void setDrawingPenPath(bool isDrawing) {
    _isDrawingPenPath = isDrawing;
    notifyListeners();
  }

  void setGradient(Offset? start, Offset? end) {
    _gradientStart = start;
    _gradientEnd = end;
    notifyListeners();
  }

  /// Transform screen position to canvas coordinates
  Offset transformPosition(Offset screenPosition) {
    return (screenPosition - _offset) / _zoomLevel;
  }

  /// Transform canvas coordinates to screen position
  Offset transformToScreen(Offset canvasPosition) {
    return canvasPosition * _zoomLevel + _offset;
  }

  /// Check if a point is within canvas bounds
  bool isValidPoint(int x, int y) {
    return x >= 0 && x < width && y >= 0 && y < height;
  }

  /// Convert screen offset to pixel coordinates
  Point<int> getPixelCoordinates(Offset position, Size canvasSize) {
    final pixelWidth = canvasSize.width / width;
    final pixelHeight = canvasSize.height / height;

    return Point<int>(
      (position.dx / pixelWidth).floor(),
      (position.dy / pixelHeight).floor(),
    );
  }

  void _updateCachedPixels({bool cacheAll = false}) {
    _cachedPixels = Uint32List(width * height);

    for (var i = 0; i < _layers.length; i++) {
      final layer = _layers[i];
      if (!layer.isVisible) {
        cacheManager.removeLayer(layer.layerId);
        continue;
      }

      final processedPixels = layer.processedPixels;
      _cachedPixels = _mergePixels(_cachedPixels, processedPixels);

      if (i == _currentLayerIndex || cacheAll) {
        cacheManager.updateLayer(layer.layerId, processedPixels, width, height);
      }
    }

    // Add preview pixels to current layer
    if (_previewPixels.isNotEmpty) {
      _cachedPixels = _mergePixelsWithPoints(_cachedPixels, _previewPixels);
    }
  }

  void _updateCurrentLayerCache() {
    if (_currentLayerIndex < _layers.length) {
      final layer = _layers[_currentLayerIndex];
      final processedPixels = layer.processedPixels;
      cacheManager.updateLayer(layer.layerId, processedPixels, width, height);
    }
  }

  void _clearPreviewPixels() {
    _previewPixels = [];
    _processedPreviewPixels = Uint32List(0);
    _gradientStart = null;
  }

  void _clearDrawingState() {
    _clearPreviewPixels();
    _penPoints = [];
    _isDrawingPenPath = false;
    _gradientStart = null;
    _gradientEnd = null;
  }

  Uint32List _mergePixels(Uint32List base, Uint32List overlay) {
    final merged = Uint32List.fromList(base);
    for (int i = 0; i < overlay.length && i < merged.length; i++) {
      if (overlay[i] != 0) {
        merged[i] = overlay[i];
      }
    }
    return merged;
  }

  Uint32List _mergePixelsWithPoints(
    Uint32List base,
    List<PixelPoint<int>> points,
  ) {
    final merged = Uint32List.fromList(base);
    for (final point in points) {
      final index = point.y * width + point.x;
      if (index >= 0 && index < merged.length) {
        merged[index] = _currentTool == PixelTool.eraser ? Colors.transparent.value : point.color;
      }
    }
    return merged;
  }

  @override
  void dispose() {
    super.dispose();
  }
}
