import 'dart:ui' as ui;
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../data.dart';
import 'tools.dart';

class PixelGridController extends ChangeNotifier {
  final int width;
  final int height;
  List<Layer> layers;
  final Function(int x, int y) onTapPixel;
  final Function(List<Point<int>>) onBrushStroke;
  final Function() onStartDrawing;
  final Function() onFinishDrawing;

  final Function(SelectionModel?)? onSelectionChanged;
  final Function(SelectionModel)? onMoveSelection;
  final Function(Color)? onColorPicked;
  final Function(List<Color>)? onGradientApplied;
  final Function(double)? onRotateSelection;
  final Function(List<Point<int>>) onDrawShape;
  final Function(double, Offset)? onZoom;

  int brushSize;
  int sprayIntensity;
  PixelTool currentTool;
  MirrorAxis mirrorAxis;
  Color currentColor;

  void setlayers(List<Layer> layers) {
    this.layers = layers;
    _updateCachedPixels();
    notifyListeners();
  }

  PixelGridController({
    required this.width,
    required this.height,
    required this.layers,
    required this.onTapPixel,
    required this.onBrushStroke,
    required this.currentTool,
    required this.currentColor,
    required this.onDrawShape,
    required this.onStartDrawing,
    required this.onFinishDrawing,
    this.onColorPicked,
    this.brushSize = 1,
    this.onSelectionChanged,
    this.onMoveSelection,
    this.onGradientApplied,
    this.onRotateSelection,
    this.sprayIntensity = 5,
    double zoomLevel = 1.0,
    Offset currentOffset = Offset.zero,
    this.mirrorAxis = MirrorAxis.vertical,
    this.onZoom,
  })  : _currentScale = zoomLevel,
        _currentOffset = currentOffset {
    _updateCachedPixels();
  }

  final boxKey = GlobalKey();
  final random = Random();

  Offset? _previousPosition;

  Offset? _startPosition;
  Offset? _currentPosition;
  List<Point<int>> _previewPixels = [];
  List<Point<int>> get previewPixels => _previewPixels;

  List<Offset> _penPoints = [];
  List<Offset> get pentPonts => _penPoints;
  bool _isDrawingPenPath = false;
  bool get isDrawingPenPath => _isDrawingPenPath;
  bool _isClosingPath = false;

  Rect? _selectionRect;
  Rect? get selectionRect => _selectionRect;
  bool _isDraggingSelection = false;
  Offset? _selectionStart;
  Offset? _selectionCurrent;

  Offset? _gradientStart;
  Offset? get gradientStart => _gradientStart;
  Offset? _gradientEnd;
  Offset? get gradientEnd => _gradientEnd;

  Offset _dragOffset = Offset.zero;
  Offset? _lastPanPosition;

  // Variables for zooming and panning
  double _currentScale;
  double get currentScale => _currentScale;
  Offset _currentOffset;
  Offset get currentOffset => _currentOffset;
  Offset _normalizedOffset = Offset.zero;
  Offset? _panStartPosition;

  set zoomLevel(double zoom) {
    _currentScale = zoom;
    notifyListeners();
  }

  set currentOffset(Offset offset) {
    _currentOffset = offset;
    notifyListeners();
  }

  // Gesture details
  int _pointerCount = 0;
  final _closeThreshold = 10.0;

  late Uint32List _cachedPixels = Uint32List(width * height);

  RenderBox get renderBox =>
      boxKey.currentContext!.findRenderObject() as RenderBox;

  void _updateCachedPixels() {
    _cachedPixels = Uint32List(width * height);
    for (final layer in layers.where((layer) => layer.isVisible)) {
      _cachedPixels = _mergePixels(_cachedPixels, layer.pixels);
    }
  }

  Uint32List get pixels {
    Uint32List pixels = _cachedPixels;
    for (int i = 0; i < _previewPixels.length; i++) {
      final point = _previewPixels[i];
      final index = point.y * width + point.x;
      if (index >= 0 && index < _cachedPixels.length) {
        pixels[index] = currentTool == PixelTool.eraser
            ? Colors.transparent.value
            : currentColor.value;
      }
    }
    return pixels;
  }

  void onScaleStart(ScaleStartDetails details) {
    _pointerCount = details.pointerCount;
    if (_pointerCount == 1) {
      // One finger touch
      if (currentTool == PixelTool.drag) {
        _panStartPosition = details.focalPoint - _currentOffset;
      } else {
        _handlePanStart(details.localFocalPoint);
      }
    } else if (_pointerCount == 2) {
      // Two finger touch for zooming
      _normalizedOffset = (_currentOffset - details.focalPoint) / _currentScale;
    }
  }

  void onScaleUpdate(ScaleUpdateDetails details) {
    _pointerCount = details.pointerCount;
    if (_pointerCount == 1) {
      // One finger touch
      if (currentTool == PixelTool.drag) {
        _currentOffset = details.focalPoint - _panStartPosition!;

        onZoom?.call(_currentScale, _currentOffset);
        notifyListeners();
      } else {
        _handlePanUpdate(details.localFocalPoint);
      }
    } else if (_pointerCount == 2) {
      // Two finger touch for zooming and panning
      _currentScale = (_currentScale * details.scale).clamp(0.5, 10.0);
      _currentOffset = details.focalPoint + _normalizedOffset * _currentScale;
      notifyListeners();

      onZoom?.call(_currentScale, _currentOffset);
    }
  }

  void onScaleEnd(ScaleEndDetails details) {
    if (_pointerCount == 1) {
      if (currentTool == PixelTool.drag) {
        // Do nothing
      } else {
        _handlePanEnd();
        onFinishDrawing();
      }
    }
    _pointerCount = 0;
  }

  void onTapDown(TapDownDetails details) {
    final transformedPosition =
        (details.localPosition - _currentOffset) / _currentScale;
    if (currentTool == PixelTool.fill) {
      onTapPixel(
        (transformedPosition.dx / renderBox.size.width * width).floor(),
        (transformedPosition.dy / renderBox.size.height * height).floor(),
      );
    } else if (currentTool == PixelTool.eyedropper) {
      _handleEyedropper(transformedPosition);
    } else if (currentTool == PixelTool.select) {
      if (!_isPointInsideSelection(transformedPosition)) {
        _startSelection(transformedPosition);
      }
    } else {
      // widget.onStartDrawing();
      _startDrawing(transformedPosition);
    }
  }

  void onTapUp(TapUpDetails details) {
    _endDrawing();
    onFinishDrawing();
  }

  void _handlePanStart(Offset position) {
    // Adjust for scale and offset
    final transformedPosition = (position - _currentOffset) / _currentScale;
    if (currentTool == PixelTool.select) {
      if (_isPointInsideSelection(transformedPosition)) {
        _startDraggingSelection(transformedPosition);
      } else {
        _startSelection(transformedPosition);
      }
    } else if (currentTool == PixelTool.eyedropper) {
      _handleEyedropper(transformedPosition);
    } else if (currentTool == PixelTool.gradient) {
      _startGradient(transformedPosition);
    } else if (currentTool == PixelTool.pen) {
      onStartDrawing();
      _handlePenTap(transformedPosition);
    } else {
      // widget.onStartDrawing();
      _startDrawing(transformedPosition);
    }
  }

  void _handlePanUpdate(Offset position) {
    // Adjust for scale and offset
    final transformedPosition = (position - _currentOffset) / _currentScale;
    if (currentTool == PixelTool.select) {
      if (_isDraggingSelection) {
        final delta = transformedPosition - _lastPanPosition!;
        _updateDraggingSelection(delta);
        _lastPanPosition = transformedPosition;
      } else {
        _updateSelection(transformedPosition);
      }
    } else if (currentTool == PixelTool.eyedropper) {
      _handleEyedropper(transformedPosition);
    } else if (currentTool == PixelTool.gradient) {
      _updateGradient(transformedPosition);
    } else if (currentTool == PixelTool.pen && _isDrawingPenPath) {
      _handlePenDrag(transformedPosition);
    } else {
      _updateDrawing(transformedPosition);
    }
  }

  void _handlePanEnd() {
    if (currentTool == PixelTool.select) {
      if (_isDraggingSelection) {
        _endDraggingSelection();
      } else {
        _endSelection();
      }
    } else if (currentTool == PixelTool.gradient) {
      _endGradient();
    } else if (currentTool == PixelTool.pen) {
      if (_isClosingPath) {
        // Close and finalize the path
        _penPoints.add(_penPoints[0]);
        _finalizePenPath();
      } else {
        // Continue drawing
        _handlePenPanEnd();
      }
    } else {
      _endDrawing();
    }
  }

  void _handleEyedropper(Offset position) {
    final pixelWidth = renderBox.size.width / width;
    final pixelHeight = renderBox.size.height / height;

    final x = (position.dx / pixelWidth).floor();
    final y = (position.dy / pixelHeight).floor();

    if (x >= 0 && x < width && y >= 0 && y < height) {
      final pickedColor = _cachedPixels[y * width + x];
      onColorPicked?.call(Color(pickedColor));
    }
  }

  void _handlePenTap(Offset position) {
    if (_penPoints.isNotEmpty) {
      final startPoint = _penPoints[0];
      if ((position - startPoint).distance <= _closeThreshold) {
        // Close the path
        _penPoints.add(startPoint); // Connect back to the starting point
        _finalizePenPath();
      } else {
        // Add new point
        _penPoints.add(position);
      }
    } else {
      onStartDrawing();
      _penPoints.add(position);
      _isDrawingPenPath = true;
    }
    notifyListeners();
  }

  void _handlePenDrag(Offset position) {
    if (_penPoints.isNotEmpty) {
      final startPoint = _penPoints[0];
      _currentPosition = position;

      if ((position - startPoint).distance <= _closeThreshold) {
        _isClosingPath = true;
      } else {
        _isClosingPath = false;
      }
    }
    notifyListeners();
  }

  void _handlePenPanEnd() {
    if (_penPoints.length > 1) {
      // Convert the path into pixels and draw it
      final pixels = _getPenPathPixels(_penPoints);
      onDrawShape(pixels);
      onFinishDrawing();
      _penPoints.clear();
      _isDrawingPenPath = false;
      notifyListeners();
    }
  }

  void _finalizePenPath() {
    if (_penPoints.length > 1) {
      // Convert the path into pixels and draw it
      final pixels = _getPenPathPixels(_penPoints, close: true);
      onDrawShape(pixels);
      onFinishDrawing();
    }
    _penPoints.clear();
    _isDrawingPenPath = false;
    _isClosingPath = false;
    notifyListeners();
  }

  void _startGradient(Offset position) {
    _gradientStart = position;
    _gradientEnd = position;
    notifyListeners();
  }

  void _updateGradient(Offset position) {
    _gradientEnd = position;
    notifyListeners();
  }

  void _endGradient() {
    if (_gradientStart != null && _gradientEnd != null) {
      final pixelWidth = renderBox.size.width / width;
      final pixelHeight = renderBox.size.height / height;

      final startX = (_gradientStart!.dx / pixelWidth).floor();
      final startY = (_gradientStart!.dy / pixelHeight).floor();
      final endX = (_gradientEnd!.dx / pixelWidth).floor();
      final endY = (_gradientEnd!.dy / pixelHeight).floor();

      final gradientColors =
          _generateGradientColors(startX, startY, endX, endY);
      onGradientApplied?.call(gradientColors);
    }

    _gradientStart = null;
    _gradientEnd = null;
    notifyListeners();
  }

  List<Color> _generateGradientColors(
    int startX,
    int startY,
    int endX,
    int endY,
  ) {
    final gradientColors =
        List<Color>.filled(width * height, Colors.transparent);
    final gradient = LinearGradient(
      begin: Alignment(startX / width, startY / height),
      end: Alignment(endX / width, endY / height),
      colors: [currentColor, Colors.transparent],
    );

    return gradientColors;
  }

  bool _isPointInsideSelection(Offset point) {
    if (_selectionRect == null) return false;
    return _selectionRect!.contains(point);
  }

  void _startDraggingSelection(Offset position) {
    _isDraggingSelection = true;
    _dragOffset = Offset.zero;
    _lastPanPosition = position;
    notifyListeners();
  }

  void _updateDraggingSelection(Offset delta) {
    final boxSize = renderBox.size;
    final pixelWidth = boxSize.width / width;
    final pixelHeight = boxSize.height / height;

    // Accumulate the delta movement
    _dragOffset += delta;

    // Calculate the integer pixel movement
    final dx = (_dragOffset.dx / pixelWidth).round();
    final dy = (_dragOffset.dy / pixelHeight).round();

    if (dx != 0 || dy != 0) {
      _selectionRect = _selectionRect!.shift(Offset(
        dx * pixelWidth,
        dy * pixelHeight,
      ));
      _dragOffset = Offset(
        _dragOffset.dx - dx * pixelWidth,
        _dragOffset.dy - dy * pixelHeight,
      );

      // Create a new SelectionModel
      final newSelectionModel = SelectionModel(
        x: _selectionRect!.left ~/ pixelWidth,
        y: _selectionRect!.top ~/ pixelHeight,
        width: _selectionRect!.width ~/ pixelWidth,
        height: _selectionRect!.height ~/ pixelHeight,
      );

      // Call the controller to move the selection
      onMoveSelection?.call(newSelectionModel);
      notifyListeners();
    }
  }

  void _endDraggingSelection() {
    _isDraggingSelection = false;
    _dragOffset = Offset.zero;
    _lastPanPosition = null;
    notifyListeners();
  }

  void _startSelection(Offset position) {
    _selectionStart = position;
    _selectionCurrent = position;
    _selectionRect = Rect.fromPoints(_selectionStart!, _selectionCurrent!);

    _isDraggingSelection = false;

    onSelectionChanged?.call(null);
    notifyListeners();
  }

  void _updateSelection(Offset position) {
    _selectionCurrent = position;
    _selectionRect = Rect.fromPoints(_selectionStart!, _selectionCurrent!);
    notifyListeners();
  }

  void _startDrawing(Offset position) {
    _startPosition = position;
    _handleDrawing(position);
  }

  void _updateDrawing(Offset position) {
    _currentPosition = position;
    _handleDrawing(position);
  }

  void _endSelection() {
    final boxSize = renderBox.size;
    final pixelWidth = boxSize.width / width;
    final pixelHeight = boxSize.height / height;

    if (_selectionRect == null) return;
    if (_selectionRect!.width < pixelWidth ||
        _selectionRect!.height < pixelHeight) {
      _selectionRect = null;
      notifyListeners();
      return;
    }

    int x0 = (_selectionRect!.left / pixelWidth).floor();
    int y0 = (_selectionRect!.top / pixelHeight).floor();
    int x1 = (_selectionRect!.right / pixelWidth).ceil();
    int y1 = (_selectionRect!.bottom / pixelHeight).ceil();

    x0 = x0.clamp(0, width - 1);
    y0 = y0.clamp(0, height - 1);
    x1 = x1.clamp(0, width);
    y1 = y1.clamp(0, height);

    _isDraggingSelection = true;
    notifyListeners();

    onSelectionChanged?.call(SelectionModel(
      x: x0,
      y: y0,
      width: x1 - x0,
      height: y1 - y0,
    ));
  }

  void _endDrawing() {
    if (currentTool == PixelTool.line ||
        currentTool == PixelTool.rectangle ||
        currentTool == PixelTool.circle ||
        currentTool == PixelTool.pencil ||
        currentTool == PixelTool.eraser ||
        currentTool == PixelTool.mirror) {
      onDrawShape(_previewPixels);
    }
    _previewPixels.clear();
    _previousPosition = null;
    _startPosition = null;
    _currentPosition = null;
    notifyListeners();
  }

  void _onTapPixel(int x, int y) {
    if (!_inInSelectionBounds(x, y)) return;
    _previewPixels.add(Point(x, y));
  }

  bool _inInSelectionBounds(int x, int y) {
    if (_selectionRect == null) return true;
    final boxSize = renderBox.size;
    final pixelWidth = boxSize.width / width;
    final pixelHeight = boxSize.height / height;

    final x0 = (_selectionRect!.left / pixelWidth).floor();
    final y0 = (_selectionRect!.top / pixelHeight).floor();
    final x1 = (_selectionRect!.right / pixelWidth).ceil();
    final y1 = (_selectionRect!.bottom / pixelHeight).ceil();

    return x >= x0 && x < x1 && y >= y0 && y < y1;
  }

  List<Point<int>> _filterPoints(List<Point<int>> pixels) {
    if (_selectionRect == null) return pixels;
    return pixels.where((point) {
      return _inInSelectionBounds(point.x, point.y);
    }).toList();
  }

  void _handleDrawing(Offset position) {
    final pixelWidth = renderBox.size.width / width;
    final pixelHeight = renderBox.size.height / height;

    final x = (position.dx / pixelWidth).floor();
    final y = (position.dy / pixelHeight).floor();

    if (x >= 0 && x < width && y >= 0 && y < height) {
      if (currentTool == PixelTool.pencil || currentTool == PixelTool.eraser) {
        if (_previousPosition != null) {
          final previousX = (_previousPosition!.dx / pixelWidth).floor();
          final previousY = (_previousPosition!.dy / pixelHeight).floor();
          _drawLine(previousX, previousY, x, y);
        } else {
          _onTapPixel(x, y);
        }
        _previousPosition = position;
        notifyListeners();
      } else if (currentTool == PixelTool.line) {
        if (_startPosition != null && _currentPosition != null) {
          final startX = (_startPosition!.dx / pixelWidth).floor();
          final startY = (_startPosition!.dy / pixelHeight).floor();
          _previewPixels = _filterPoints(_getLinePixels(startX, startY, x, y));
          notifyListeners();
        }
      } else if (currentTool == PixelTool.rectangle) {
        if (_startPosition != null && _currentPosition != null) {
          final startX = (_startPosition!.dx / pixelWidth).floor();
          final startY = (_startPosition!.dy / pixelHeight).floor();
          _previewPixels = _filterPoints(
            _getRectanglePixels(startX, startY, x, y),
          );
          notifyListeners();
        }
      } else if (currentTool == PixelTool.circle) {
        if (_startPosition != null && _currentPosition != null) {
          final startX = (_startPosition!.dx / pixelWidth).floor();
          final startY = (_startPosition!.dy / pixelHeight).floor();
          _previewPixels =
              _filterPoints(_getCirclePixels(startX, startY, x, y));
          notifyListeners();
        }
      } else if (currentTool == PixelTool.brush) {
        final pixelsToUpdate = <Point<int>>[];

        if (_previousPosition != null) {
          final previousX = (_previousPosition!.dx / pixelWidth).floor();
          final previousY = (_previousPosition!.dy / pixelHeight).floor();

          final linePoints = _getLinePoints(previousX, previousY, x, y);
          for (final point in linePoints) {
            final circlePoints = _getCirclePoints(point.x, point.y, brushSize);
            pixelsToUpdate.addAll(circlePoints);
          }
        } else {
          final circlePoints = _getCirclePoints(x, y, brushSize);
          pixelsToUpdate.addAll(circlePoints);
        }

        _previousPosition = position;
        onBrushStroke(_filterPoints(pixelsToUpdate));
      } else if (currentTool == PixelTool.mirror) {
        _drawMirror(position, x, y, pixelWidth, pixelHeight);
      } else if (currentTool == PixelTool.pixelPerfectLine) {
        if (_previousPosition != null) {
          final previousX = (_previousPosition!.dx / pixelWidth).floor();
          final previousY = (_previousPosition!.dy / pixelHeight).floor();

          final linePixels =
              _getPixelPerfectLinePixels(previousX, previousY, x, y);
          for (final point in linePixels) {
            _onTapPixel(point.x, point.y);
          }
        } else {
          _onTapPixel(x, y);
        }
        _previousPosition = position;
        notifyListeners();
      } else if (currentTool == PixelTool.sprayPaint) {
        final intensity = sprayIntensity;
        final pixelsToUpdate = <Point<int>>[];

        if (_previousPosition != null) {
          final previousX = (_previousPosition!.dx / pixelWidth).floor();
          final previousY = (_previousPosition!.dy / pixelHeight).floor();

          final linePoints = _getLinePoints(previousX, previousY, x, y);
          for (final point in linePoints) {
            for (int i = 0; i < intensity; i++) {
              final offsetX = random.nextInt(brushSize * 2) - brushSize;
              final offsetY = random.nextInt(brushSize * 2) - brushSize;
              final px = point.x + offsetX;
              final py = point.y + offsetY;
              if (px >= 0 && px < width && py >= 0 && py < height) {
                pixelsToUpdate.add(Point(px, py));
              }
            }
          }
        } else {
          pixelsToUpdate.add(Point(x, y));
        }

        _previousPosition = position;
        onBrushStroke(_filterPoints(pixelsToUpdate));
      }
    }
  }

  void _drawMirror(
    Offset position,
    int x,
    int y,
    double pixelWidth,
    double pixelHeight,
  ) {
    if (_previousPosition != null) {
      final previousX = (_previousPosition!.dx / pixelWidth).floor();
      final previousY = (_previousPosition!.dy / pixelHeight).floor();
      _drawLine(previousX, previousY, x, y);

      switch (mirrorAxis) {
        case MirrorAxis.horizontal:
          final mirrorY = height - 1 - y;
          _drawLine(previousX, previousY, x, mirrorY);
          break;
        case MirrorAxis.vertical:
          final mirrorX = width - 1 - x;
          _drawLine(width - 1 - previousX, previousY, mirrorX, y);
          break;
        case MirrorAxis.both:
          final mirrorX = width - 1 - x;
          final mirrorY = height - 1 - y;
          _drawLine(width - 1 - previousX, previousY, mirrorX, y);
          _drawLine(previousX, previousY, x, mirrorY);
          _drawLine(width - 1 - previousX, previousY, mirrorX, mirrorY);

          break;
      }
    } else {
      _onTapPixel(x, y);
      final mirrorX = width - 1 - x;
      _onTapPixel(mirrorX, y);
    }
    _previousPosition = position;
    notifyListeners();
  }

  List<Point<int>> _getPenPathPixels(
    List<Offset> penPoints, {
    bool close = false,
  }) {
    final pixels = <Point<int>>[];

    if (penPoints.length < 2) return pixels;

    final path = Path();
    path.moveTo(penPoints[0].dx, penPoints[0].dy);

    for (int i = 1; i < penPoints.length - 1; i++) {
      final x0 = penPoints[i].dx;
      final y0 = penPoints[i].dy;
      final x1 = penPoints[i + 1].dx;
      final y1 = penPoints[i + 1].dy;
      path.quadraticBezierTo(x0, y0, (x0 + x1) / 2, (y0 + y1) / 2);
    }

    if (close) {
      path.close();
    }

    // Rasterize the path into pixels
    final pathMetrics = path.computeMetrics();
    for (final metric in pathMetrics) {
      final extractPath = metric.extractPath(0, metric.length);
      final pathPoints = _rasterizePath(extractPath);
      pixels.addAll(pathPoints);
    }

    return pixels;
  }

  List<Point<int>> _rasterizePath(Path path) {
    final pixels = <Point<int>>[];
    final pathMetrics = path.computeMetrics();

    final pixelWidth = renderBox.size.width / width;
    final pixelHeight = renderBox.size.height / height;

    for (final metric in pathMetrics) {
      final length = metric.length;
      final numSamples = length.toInt(); // Number of samples along the path

      for (int i = 0; i <= numSamples; i++) {
        final distance = (i / numSamples) * length;
        final tangent = metric.getTangentForOffset(distance);
        if (tangent != null) {
          final position = tangent.position;
          final ix = (position.dx / pixelWidth).floor();
          final iy = (position.dy / pixelHeight).floor();
          if (ix >= 0 && ix < width && iy >= 0 && iy < height) {
            final point = Point(ix, iy);
            if (!pixels.contains(point)) {
              pixels.add(point);
            }
          }
        }
      }
    }

    return pixels;
  }

  List<Point<int>> _getLinePoints(int x0, int y0, int x1, int y1) {
    final points = <Point<int>>[];

    int dx = (x1 - x0).abs();
    int dy = -(y1 - y0).abs();
    int sx = x0 < x1 ? 1 : -1;
    int sy = y0 < y1 ? 1 : -1;
    int err = dx + dy;

    int x = x0;
    int y = y0;

    while (true) {
      points.add(Point(x, y));
      if (x == x1 && y == y1) break;
      int e2 = 2 * err;
      if (e2 >= dy) {
        err += dy;
        x += sx;
      }
      if (e2 <= dx) {
        err += dx;
        y += sy;
      }
    }

    return points;
  }

  List<Point<int>> _getCirclePoints(int centerX, int centerY, int radius) {
    final points = <Point<int>>[];

    for (int y = -radius; y <= radius; y++) {
      for (int x = -radius; x <= radius; x++) {
        if (x * x + y * y <= radius * radius) {
          final px = centerX + x;
          final py = centerY + y;
          if (px >= 0 && px < width && py >= 0 && py < height) {
            points.add(Point(px, py));
          }
        }
      }
    }

    return points;
  }

  List<Point<int>> _getLinePixels(int x0, int y0, int x1, int y1) {
    final pixels = <Point<int>>[];

    int dx = (x1 - x0).abs();
    int dy = -(y1 - y0).abs();
    int sx = x0 < x1 ? 1 : -1;
    int sy = y0 < y1 ? 1 : -1;
    int err = dx + dy;

    int x = x0;
    int y = y0;

    while (true) {
      if (x >= 0 && x < width && y >= 0 && y < height) {
        pixels.add(Point(x, y));
      }

      if (x == x1 && y == y1) break;

      int e2 = 2 * err;
      if (e2 >= dy) {
        err += dy;
        x += sx;
      }
      if (e2 <= dx) {
        err += dx;
        y += sy;
      }
    }

    return pixels;
  }

  List<Point<int>> _getRectanglePixels(int x0, int y0, int x1, int y1) {
    final pixels = <Point<int>>[];

    int left = min(x0, x1);
    int right = max(x0, x1);
    int top = min(y0, y1);
    int bottom = max(y0, y1);

    // Top and bottom edges
    for (int x = left; x <= right; x++) {
      if (top >= 0 && top < height) {
        if (x >= 0 && x < width) pixels.add(Point(x, top));
      }
      if (bottom >= 0 && bottom < height && top != bottom) {
        if (x >= 0 && x < width) pixels.add(Point(x, bottom));
      }
    }

    // Left and right edges
    for (int y = top + 1; y < bottom; y++) {
      if (left >= 0 && left < width) {
        if (y >= 0 && y < height) pixels.add(Point(left, y));
      }
      if (right >= 0 && right < width && left != right) {
        if (y >= 0 && y < height) pixels.add(Point(right, y));
      }
    }

    return pixels;
  }

  List<Point<int>> _getCirclePixels(int x0, int y0, int x1, int y1) {
    final pixels = <Point<int>>[];

    int dx = x1 - x0;
    int dy = y1 - y0;
    int radius = sqrt(dx * dx + dy * dy).round();

    int f = 1 - radius;
    int ddF_x = 0;
    int ddF_y = -2 * radius;
    int x = 0;
    int y = radius;

    _addCirclePoints(pixels, x0, y0, x, y);

    while (x < y) {
      if (f >= 0) {
        y--;
        ddF_y += 2;
        f += ddF_y;
      }
      x++;
      ddF_x += 2;
      f += ddF_x + 1;

      _addCirclePoints(pixels, x0, y0, x, y);
    }

    return pixels;
  }

  void _addCirclePoints(List<Point<int>> pixels, int x0, int y0, int x, int y) {
    List<Point<int>> points = [
      Point(x0 + x, y0 + y),
      Point(x0 - x, y0 + y),
      Point(x0 + x, y0 - y),
      Point(x0 - x, y0 - y),
      Point(x0 + y, y0 + x),
      Point(x0 - y, y0 + x),
      Point(x0 + y, y0 - x),
      Point(x0 - y, y0 - x),
    ];

    for (var point in points) {
      if (point.x >= 0 && point.x < width && point.y >= 0 && point.y < height) {
        pixels.add(point);
      }
    }
  }

  void _drawLine(int x0, int y0, int x1, int y1) {
    // Implement Bresenham's line algorithm
    int dx = (x1 - x0).abs();
    int dy = (y1 - y0).abs();
    int sx = x0 < x1 ? 1 : -1;
    int sy = y0 < y1 ? 1 : -1;
    int err = dx - dy;

    while (true) {
      _onTapPixel(x0, y0);

      if (x0 == x1 && y0 == y1) break;
      int e2 = 2 * err;
      if (e2 > -dy) {
        err -= dy;
        x0 += sx;
      }
      if (e2 < dx) {
        err += dx;
        y0 += sy;
      }
    }
  }

  List<Point<int>> _getPixelPerfectLinePixels(int x0, int y0, int x1, int y1) {
    final pixels = <Point<int>>[];

    int dx = x1 - x0;
    int dy = y1 - y0;

    int absDx = dx.abs();
    int absDy = dy.abs();

    int x = x0;
    int y = y0;

    int sx = dx > 0 ? 1 : -1;
    int sy = dy > 0 ? 1 : -1;

    if (absDx > absDy) {
      int err = absDx ~/ 2;
      for (int i = 0; i <= absDx; i++) {
        pixels.add(Point(x, y));
        err -= absDy;
        if (err < 0) {
          y += sy;
          err += absDx;
        }
        x += sx;
      }
    } else {
      int err = absDy ~/ 2;
      for (int i = 0; i <= absDy; i++) {
        pixels.add(Point(x, y));
        err -= absDx;
        if (err < 0) {
          x += sx;
          err += absDy;
        }
        y += sy;
      }
    }

    // Remove diagonal steps only when the distance between points is small
    if (absDx <= 1 && absDy <= 1) {
      pixels.removeWhere((point) {
        int index = pixels.indexOf(point);
        if (index == 0) return false;
        Point<int> prevPoint = pixels[index - 1];
        return (point.x - prevPoint.x).abs() == 1 &&
            (point.y - prevPoint.y).abs() == 1;
      });
    }

    return pixels;
  }

  Uint32List _mergePixels(Uint32List pixels1, Uint32List pixels2) {
    final mergedPixels = Uint32List.fromList(pixels1);
    for (int i = 0; i < pixels2.length; i++) {
      if (pixels2[i] != 0) {
        mergedPixels[i] = pixels2[i];
      }
    }

    return mergedPixels;
  }

  // Callbacks (to be set externally)
}
