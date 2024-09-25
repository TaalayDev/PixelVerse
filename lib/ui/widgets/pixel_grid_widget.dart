import 'dart:ui' as ui;
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../core.dart';
import '../../core/tools.dart';
import '../../data.dart';

class _CacheController extends ChangeNotifier {
  ui.Image? _cachedImage;
  bool _isDirty = true;

  Function()? _onCached;

  void updateImage(ui.Image image) {
    _cachedImage = image;
    _onCached?.call();
    notifyListeners();
  }
}

class PixelGrid extends StatefulWidget {
  final int width;
  final int height;
  final List<Layer> layers;
  final Function(int x, int y) onTapPixel;
  final Function(List<Point<int>>) onBrushStroke;
  final Function() onStartDrawing;
  final Function() onFinishDrawing;

  final Function(SelectionModel?)? onSelectionChanged;
  final Function(SelectionModel)? onMoveSelection;
  final Function(Color)? onColorPicked;
  final Function(List<Color>)? onGradientApplied;
  final Function(double)? onRotateSelection;

  final int brushSize;
  final int sprayIntensity;
  final PixelTool currentTool;
  final MirrorAxis mirrorAxis;
  final Color currentColor;
  final Function(List<Point<int>>) onDrawShape;

  final double zoomLevel;
  final Offset currentOffset;
  final Function(double, Offset)? onZoom;

  const PixelGrid({
    super.key,
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
    this.zoomLevel = 1.0,
    this.currentOffset = Offset.zero,
    this.mirrorAxis = MirrorAxis.vertical,
    this.onZoom,
  });

  @override
  _PixelGridState createState() => _PixelGridState();
}

class _PixelGridState extends State<PixelGrid> {
  final _boxKey = GlobalKey();
  final random = Random();

  Offset? _previousPosition;

  Offset? _startPosition;
  Offset? _currentPosition;
  List<Point<int>> _previewPixels = [];

  List<Offset> _penPoints = [];
  bool _isDrawingPenPath = false;
  bool _isClosingPath = false;

  Rect? _selectionRect;
  bool _isDraggingSelection = false;
  Offset? _selectionStart;
  Offset? _selectionCurrent;

  Offset? _gradientStart;
  Offset? _gradientEnd;

  Offset _dragOffset = Offset.zero;
  Offset? _lastPanPosition;

  // Variables for zooming and panning
  late double _currentScale = widget.zoomLevel;
  late Offset _currentOffset = widget.currentOffset;
  Offset _normalizedOffset = Offset.zero;
  Offset? _panStartPosition;

  // Gesture details
  int _pointerCount = 0;
  final _closeThreshold = 10.0;

  late Uint32List _cachedPixels;
  late List<Layer> _cachedLayers;

  RenderBox get renderBox =>
      _boxKey.currentContext!.findRenderObject() as RenderBox;
  final _cacheController = _CacheController();

  @override
  void initState() {
    super.initState();
    _updateCachedPixels();
    _cacheController._onCached = () {
      _previewPixels.clear();
    };
  }

  @override
  void didUpdateWidget(covariant PixelGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.zoomLevel != oldWidget.zoomLevel) {
      setState(() {
        _currentScale = widget.zoomLevel;
      });
    }
    if (widget.layers != oldWidget.layers) {
      _updateCachedPixels();
    }
  }

  void _updateCachedPixels() {
    _cachedLayers = List<Layer>.from(widget.layers);
    _cachedPixels = Uint32List(widget.width * widget.height);
    for (final layer in widget.layers.where((layer) => layer.isVisible)) {
      _cachedPixels = _mergePixels(_cachedPixels, layer.pixels);
    }
    _cacheController._isDirty = true;
  }

  Uint32List get pixels {
    Uint32List pixels = _cachedPixels;
    for (int i = 0; i < _previewPixels.length; i++) {
      final point = _previewPixels[i];
      final index = point.y * widget.width + point.x;
      if (index >= 0 && index < _cachedPixels.length) {
        pixels[index] = widget.currentTool == PixelTool.eraser
            ? Colors.transparent.value
            : widget.currentColor.value;
      }
    }
    return pixels;
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      key: _boxKey,
      child: GestureDetector(
        onScaleStart: (details) {
          _pointerCount = details.pointerCount;
          print('onScaleStart');
          if (_pointerCount == 1) {
            // One finger touch
            if (widget.currentTool == PixelTool.drag) {
              _panStartPosition = details.focalPoint - _currentOffset;
            } else {
              _handlePanStart(details.localFocalPoint);
            }
          } else if (_pointerCount == 2) {
            // Two finger touch for zooming
            _normalizedOffset =
                (_currentOffset - details.focalPoint) / _currentScale;
          }
        },
        onScaleUpdate: (details) {
          _pointerCount = details.pointerCount;
          if (_pointerCount == 1) {
            // One finger touch
            if (widget.currentTool == PixelTool.drag) {
              setState(() {
                _currentOffset = details.focalPoint - _panStartPosition!;
              });
              widget.onZoom?.call(_currentScale, _currentOffset);
            } else {
              _handlePanUpdate(details.localFocalPoint);
            }
          } else if (_pointerCount == 2) {
            // Two finger touch for zooming and panning
            setState(() {
              _currentScale = (_currentScale * details.scale).clamp(0.5, 10.0);
              _currentOffset =
                  details.focalPoint + _normalizedOffset * _currentScale;
            });

            widget.onZoom?.call(_currentScale, _currentOffset);
          }
        },
        onScaleEnd: (details) {
          if (_pointerCount == 1) {
            if (widget.currentTool == PixelTool.drag) {
              // Do nothing
            } else {
              _handlePanEnd();
              widget.onFinishDrawing();
            }
          }
          _pointerCount = 0;
        },
        onTapDown: (details) {
          final transformedPosition =
              (details.localPosition - _currentOffset) / _currentScale;
          if (widget.currentTool == PixelTool.fill) {
            widget.onTapPixel(
              (transformedPosition.dx / renderBox.size.width * widget.width)
                  .floor(),
              (transformedPosition.dy / renderBox.size.height * widget.height)
                  .floor(),
            );
          } else if (widget.currentTool == PixelTool.eyedropper) {
            _handleEyedropper(transformedPosition);
          } else if (widget.currentTool == PixelTool.select) {
            if (!_isPointInsideSelection(transformedPosition)) {
              _startSelection(transformedPosition);
            }
          } else if (widget.currentTool == PixelTool.pen) {
            _handlePenTap(transformedPosition);
          } else {
            // widget.onStartDrawing();
            _startDrawing(transformedPosition);
          }
        },
        onTapUp: (details) {
          _endDrawing();
          widget.onFinishDrawing();
        },
        child: CustomPaint(
          painter: _PixelGridPainter(
            width: widget.width,
            height: widget.height,
            pixels: pixels,
            previewPixels: _previewPixels,
            previewColor: widget.currentTool == PixelTool.eraser
                ? Colors.transparent
                : widget.currentColor,
            selectionRect: _selectionRect,
            gradientStart: _gradientStart,
            gradientEnd: _gradientEnd,
            scale: _currentScale,
            offset: _currentOffset,
            penPoints: _penPoints,
            isDrawingPenPath: _isDrawingPenPath,
            cacheController: _cacheController,
          ),
          size: Size.infinite,
        ),
      ),
    );
  }

  void _handlePanStart(Offset position) {
    // Adjust for scale and offset
    final transformedPosition = (position - _currentOffset) / _currentScale;
    if (widget.currentTool == PixelTool.select) {
      if (_isPointInsideSelection(transformedPosition)) {
        _startDraggingSelection(transformedPosition);
      } else {
        _startSelection(transformedPosition);
      }
    } else if (widget.currentTool == PixelTool.eyedropper) {
      _handleEyedropper(transformedPosition);
    } else if (widget.currentTool == PixelTool.gradient) {
      _startGradient(transformedPosition);
    } else if (widget.currentTool == PixelTool.pen) {
      widget.onStartDrawing();
      _handlePenTap(transformedPosition);
    } else {
      // widget.onStartDrawing();
      _startDrawing(transformedPosition);
    }
  }

  void _handlePanUpdate(Offset position) {
    // Adjust for scale and offset
    final transformedPosition = (position - _currentOffset) / _currentScale;
    if (widget.currentTool == PixelTool.select) {
      if (_isDraggingSelection) {
        final delta = transformedPosition - _lastPanPosition!;
        _updateDraggingSelection(delta);
        _lastPanPosition = transformedPosition;
      } else {
        _updateSelection(transformedPosition);
      }
    } else if (widget.currentTool == PixelTool.eyedropper) {
      _handleEyedropper(transformedPosition);
    } else if (widget.currentTool == PixelTool.gradient) {
      _updateGradient(transformedPosition);
    } else if (widget.currentTool == PixelTool.pen && _isDrawingPenPath) {
      _handlePenDrag(transformedPosition);
    } else {
      _updateDrawing(transformedPosition);
    }
  }

  void _handlePanEnd() {
    if (widget.currentTool == PixelTool.select) {
      if (_isDraggingSelection) {
        _endDraggingSelection();
      } else {
        _endSelection();
      }
    } else if (widget.currentTool == PixelTool.gradient) {
      _endGradient();
    } else if (widget.currentTool == PixelTool.pen) {
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
    final pixelWidth = renderBox.size.width / widget.width;
    final pixelHeight = renderBox.size.height / widget.height;

    final x = (position.dx / pixelWidth).floor();
    final y = (position.dy / pixelHeight).floor();

    if (x >= 0 && x < widget.width && y >= 0 && y < widget.height) {
      final pickedColor = _cachedPixels[y * widget.width + x];
      widget.onColorPicked?.call(Color(pickedColor));
    }
  }

  void _handlePenTap(Offset position) {
    setState(() {
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
        widget.onStartDrawing();
        _penPoints.add(position);
        _isDrawingPenPath = true;
      }
    });
  }

  void _handlePenDrag(Offset position) {
    setState(() {
      if (_penPoints.isNotEmpty) {
        final startPoint = _penPoints[0];
        _currentPosition = position;

        if ((position - startPoint).distance <= _closeThreshold) {
          _isClosingPath = true;
        } else {
          _isClosingPath = false;
        }
      }
    });
  }

  void _handlePenPanEnd() {
    if (_penPoints.length > 1) {
      // Convert the path into pixels and draw it
      final pixels = _getPenPathPixels(_penPoints);
      widget.onDrawShape(pixels);
      widget.onFinishDrawing();
      setState(() {
        _penPoints.clear();
        _isDrawingPenPath = false;
      });
    }
  }

  void _finalizePenPath() {
    if (_penPoints.length > 1) {
      // Convert the path into pixels and draw it
      final pixels = _getPenPathPixels(_penPoints, close: true);
      widget.onDrawShape(pixels);
      widget.onFinishDrawing();
    }
    setState(() {
      _penPoints.clear();
      _isDrawingPenPath = false;
      _isClosingPath = false;
    });
  }

  void _startGradient(Offset position) {
    setState(() {
      _gradientStart = position;
      _gradientEnd = position;
    });
  }

  void _updateGradient(Offset position) {
    setState(() {
      _gradientEnd = position;
    });
  }

  void _endGradient() {
    if (_gradientStart != null && _gradientEnd != null) {
      final pixelWidth = renderBox.size.width / widget.width;
      final pixelHeight = renderBox.size.height / widget.height;

      final startX = (_gradientStart!.dx / pixelWidth).floor();
      final startY = (_gradientStart!.dy / pixelHeight).floor();
      final endX = (_gradientEnd!.dx / pixelWidth).floor();
      final endY = (_gradientEnd!.dy / pixelHeight).floor();

      final gradientColors =
          _generateGradientColors(startX, startY, endX, endY);
      widget.onGradientApplied?.call(gradientColors);
    }

    setState(() {
      _gradientStart = null;
      _gradientEnd = null;
    });
  }

  List<Color> _generateGradientColors(
    int startX,
    int startY,
    int endX,
    int endY,
  ) {
    final gradientColors =
        List<Color>.filled(widget.width * widget.height, Colors.transparent);
    final gradient = LinearGradient(
      begin: Alignment(startX / widget.width, startY / widget.height),
      end: Alignment(endX / widget.width, endY / widget.height),
      colors: [widget.currentColor, Colors.transparent],
    );

    return gradientColors;
  }

  bool _isPointInsideSelection(Offset point) {
    if (_selectionRect == null) return false;
    return _selectionRect!.contains(point);
  }

  void _startDraggingSelection(Offset position) {
    setState(() {
      _isDraggingSelection = true;
      _dragOffset = Offset.zero;
      _lastPanPosition = position;
    });
  }

  void _updateDraggingSelection(Offset delta) {
    final boxSize = context.size!;
    final pixelWidth = boxSize.width / widget.width;
    final pixelHeight = boxSize.height / widget.height;

    // Accumulate the delta movement
    _dragOffset += delta;

    // Calculate the integer pixel movement
    final dx = (_dragOffset.dx / pixelWidth).round();
    final dy = (_dragOffset.dy / pixelHeight).round();

    if (dx != 0 || dy != 0) {
      setState(() {
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
        widget.onMoveSelection?.call(newSelectionModel);
      });
    }
  }

  void _endDraggingSelection() {
    setState(() {
      _isDraggingSelection = false;
      _dragOffset = Offset.zero;
      _lastPanPosition = null;
    });
  }

  void _startSelection(Offset position) {
    setState(() {
      _selectionStart = position;
      _selectionCurrent = position;
      _selectionRect = Rect.fromPoints(_selectionStart!, _selectionCurrent!);

      _isDraggingSelection = false;

      widget.onSelectionChanged?.call(null);
    });
  }

  void _updateSelection(Offset position) {
    setState(() {
      _selectionCurrent = position;
      _selectionRect = Rect.fromPoints(_selectionStart!, _selectionCurrent!);
    });
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
    final boxSize = context.size!;
    final pixelWidth = boxSize.width / widget.width;
    final pixelHeight = boxSize.height / widget.height;

    if (_selectionRect == null) return;
    if (_selectionRect!.width < pixelWidth ||
        _selectionRect!.height < pixelHeight) {
      setState(() {
        _selectionRect = null;
      });
      return;
    }

    int x0 = (_selectionRect!.left / pixelWidth).floor();
    int y0 = (_selectionRect!.top / pixelHeight).floor();
    int x1 = (_selectionRect!.right / pixelWidth).ceil();
    int y1 = (_selectionRect!.bottom / pixelHeight).ceil();

    x0 = x0.clamp(0, widget.width - 1);
    y0 = y0.clamp(0, widget.height - 1);
    x1 = x1.clamp(0, widget.width);
    y1 = y1.clamp(0, widget.height);

    setState(() {
      _isDraggingSelection = true;
    });

    widget.onSelectionChanged?.call(SelectionModel(
      x: x0,
      y: y0,
      width: x1 - x0,
      height: y1 - y0,
    ));
  }

  void _endDrawing() {
    if (widget.currentTool == PixelTool.line ||
        widget.currentTool == PixelTool.rectangle ||
        widget.currentTool == PixelTool.circle ||
        widget.currentTool == PixelTool.pencil ||
        widget.currentTool == PixelTool.eraser ||
        widget.currentTool == PixelTool.mirror) {
      widget.onDrawShape(_previewPixels);
    }
    // _previewPixels.clear();
    _previousPosition = null;
    _startPosition = null;
    _currentPosition = null;
    setState(() {});
  }

  void _onTapPixel(int x, int y) {
    if (!_inInSelectionBounds(x, y)) return;
    _previewPixels.add(Point(x, y));
  }

  bool _inInSelectionBounds(int x, int y) {
    if (_selectionRect == null) return true;
    final boxSize = context.size!;
    final pixelWidth = boxSize.width / widget.width;
    final pixelHeight = boxSize.height / widget.height;

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
    final pixelWidth = renderBox.size.width / widget.width;
    final pixelHeight = renderBox.size.height / widget.height;

    final x = (position.dx / pixelWidth).floor();
    final y = (position.dy / pixelHeight).floor();

    if (x >= 0 && x < widget.width && y >= 0 && y < widget.height) {
      if (widget.currentTool == PixelTool.pencil ||
          widget.currentTool == PixelTool.eraser) {
        if (_previousPosition != null) {
          final previousX = (_previousPosition!.dx / pixelWidth).floor();
          final previousY = (_previousPosition!.dy / pixelHeight).floor();
          _drawLine(previousX, previousY, x, y);
        } else {
          _onTapPixel(x, y);
        }
        _previousPosition = position;
        setState(() {});
      } else if (widget.currentTool == PixelTool.line) {
        if (_startPosition != null && _currentPosition != null) {
          final startX = (_startPosition!.dx / pixelWidth).floor();
          final startY = (_startPosition!.dy / pixelHeight).floor();
          _previewPixels = _filterPoints(_getLinePixels(startX, startY, x, y));
          setState(() {});
        }
      } else if (widget.currentTool == PixelTool.rectangle) {
        if (_startPosition != null && _currentPosition != null) {
          final startX = (_startPosition!.dx / pixelWidth).floor();
          final startY = (_startPosition!.dy / pixelHeight).floor();
          _previewPixels = _filterPoints(
            _getRectanglePixels(startX, startY, x, y),
          );
          setState(() {});
        }
      } else if (widget.currentTool == PixelTool.circle) {
        if (_startPosition != null && _currentPosition != null) {
          final startX = (_startPosition!.dx / pixelWidth).floor();
          final startY = (_startPosition!.dy / pixelHeight).floor();
          _previewPixels =
              _filterPoints(_getCirclePixels(startX, startY, x, y));
          setState(() {});
        }
      } else if (widget.currentTool == PixelTool.brush) {
        final brushSize = widget.brushSize;
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
        widget.onBrushStroke(_filterPoints(pixelsToUpdate));
      } else if (widget.currentTool == PixelTool.mirror) {
        _drawMirror(position, x, y, pixelWidth, pixelHeight);
      } else if (widget.currentTool == PixelTool.pixelPerfectLine) {
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
        setState(() {});
      } else if (widget.currentTool == PixelTool.sprayPaint) {
        final intensity = widget.sprayIntensity;
        final brushSize = widget.brushSize;
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
              if (px >= 0 &&
                  px < widget.width &&
                  py >= 0 &&
                  py < widget.height) {
                pixelsToUpdate.add(Point(px, py));
              }
            }
          }
        } else {
          pixelsToUpdate.add(Point(x, y));
        }

        _previousPosition = position;
        widget.onBrushStroke(_filterPoints(pixelsToUpdate));
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

      switch (widget.mirrorAxis) {
        case MirrorAxis.horizontal:
          final mirrorY = widget.height - 1 - y;
          _drawLine(previousX, previousY, x, mirrorY);
          break;
        case MirrorAxis.vertical:
          final mirrorX = widget.width - 1 - x;
          _drawLine(widget.width - 1 - previousX, previousY, mirrorX, y);
          break;
        case MirrorAxis.both:
          final mirrorX = widget.width - 1 - x;
          final mirrorY = widget.height - 1 - y;
          _drawLine(widget.width - 1 - previousX, previousY, mirrorX, y);
          _drawLine(previousX, previousY, x, mirrorY);
          _drawLine(widget.width - 1 - previousX, previousY, mirrorX, mirrorY);

          break;
      }
    } else {
      _onTapPixel(x, y);
      final mirrorX = widget.width - 1 - x;
      _onTapPixel(mirrorX, y);
    }
    _previousPosition = position;
    setState(() {});
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

    final pixelWidth = renderBox.size.width / widget.width;
    final pixelHeight = renderBox.size.height / widget.height;

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
          if (ix >= 0 && ix < widget.width && iy >= 0 && iy < widget.height) {
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
          if (px >= 0 && px < widget.width && py >= 0 && py < widget.height) {
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
      if (x >= 0 && x < widget.width && y >= 0 && y < widget.height) {
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
      if (top >= 0 && top < widget.height) {
        if (x >= 0 && x < widget.width) pixels.add(Point(x, top));
      }
      if (bottom >= 0 && bottom < widget.height && top != bottom) {
        if (x >= 0 && x < widget.width) pixels.add(Point(x, bottom));
      }
    }

    // Left and right edges
    for (int y = top + 1; y < bottom; y++) {
      if (left >= 0 && left < widget.width) {
        if (y >= 0 && y < widget.height) pixels.add(Point(left, y));
      }
      if (right >= 0 && right < widget.width && left != right) {
        if (y >= 0 && y < widget.height) pixels.add(Point(right, y));
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
      if (point.x >= 0 &&
          point.x < widget.width &&
          point.y >= 0 &&
          point.y < widget.height) {
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
}

class _PixelGridPainter extends CustomPainter {
  final int width;
  final int height;
  final Uint32List pixels;
  final List<Point<int>> previewPixels;
  final Color previewColor;
  final Rect? selectionRect;
  final Offset? gradientStart;
  final Offset? gradientEnd;

  final double scale;
  final Offset offset;

  final List<Offset> penPoints;
  final bool isDrawingPenPath;
  final _CacheController cacheController;

  _PixelGridPainter({
    required this.width,
    required this.height,
    required this.pixels,
    this.previewPixels = const [],
    this.previewColor = Colors.black,
    this.selectionRect,
    this.gradientStart,
    this.gradientEnd,
    required this.scale,
    required this.offset,
    required this.penPoints,
    required this.isDrawingPenPath,
    required this.cacheController,
  }) : super(repaint: cacheController);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(offset.dx, offset.dy);
    canvas.scale(scale);

    final pixelWidth = size.width / width;
    final pixelHeight = size.height / height;

    // Draw layers pixels
    if (cacheController._cachedImage != null) {
      final imageRect = Rect.fromLTWH(
        0,
        0,
        cacheController._cachedImage!.width.toDouble(),
        cacheController._cachedImage!.height.toDouble(),
      );
      final canvasRect = Offset.zero & size;
      canvas.drawImageRect(
        cacheController._cachedImage!,
        imageRect,
        canvasRect,
        Paint(),
      );
      _drawPreviewPixels(canvas, size, pixelWidth, pixelHeight);
    } else {
      _drawPixels(canvas, size, pixelWidth, pixelHeight);
    }
    if (cacheController._isDirty) {
      cacheController._isDirty = false;
      _createImage(pixels, width, height);
    }

    if (selectionRect != null &&
        selectionRect!.width > 0 &&
        selectionRect!.height > 0) {
      final rect = Rect.fromLTWH(
        selectionRect!.left,
        selectionRect!.top,
        selectionRect!.width,
        selectionRect!.height,
      );
      canvas.drawRect(
        rect,
        Paint()
          ..color = Colors.blueAccent.withOpacity(0.3)
          ..style = PaintingStyle.fill,
      );
      canvas.drawRect(
        rect,
        Paint()
          ..color = Colors.blue
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      );

      const handleSize = 8.0;
      final handlePaint = Paint()..color = Colors.blue;

      final handleTopLeft = Rect.fromLTWH(
        selectionRect!.left - handleSize / 2,
        selectionRect!.top - handleSize / 2,
        handleSize,
        handleSize,
      );
      canvas.drawRect(handleTopLeft, handlePaint);

      final handleTopRight = Rect.fromLTWH(
        selectionRect!.right - handleSize / 2,
        selectionRect!.top - handleSize / 2,
        handleSize,
        handleSize,
      );

      canvas.drawRect(handleTopRight, handlePaint);

      final handleBottomLeft = Rect.fromLTWH(
        selectionRect!.left - handleSize / 2,
        selectionRect!.bottom - handleSize / 2,
        handleSize,
        handleSize,
      );

      canvas.drawRect(handleBottomLeft, handlePaint);

      final handleBottomRight = Rect.fromLTWH(
        selectionRect!.right - handleSize / 2,
        selectionRect!.bottom - handleSize / 2,
        handleSize,
        handleSize,
      );

      canvas.drawRect(handleBottomRight, handlePaint);
    }

    if (gradientStart != null && gradientEnd != null) {
      final gradientPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment(
            gradientStart!.dx / size.width,
            gradientStart!.dy / size.height,
          ),
          end: Alignment(
            gradientEnd!.dx / size.width,
            gradientEnd!.dy / size.height,
          ),
          colors: [Colors.black, Colors.transparent],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

      canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, size.height),
        gradientPaint,
      );
    }

    // Draw the pen path preview
    if (isDrawingPenPath && penPoints.isNotEmpty) {
      final penPaint = Paint()
        ..color = Colors.red
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0 / scale; // Adjust for scale

      final path = Path();
      path.moveTo(penPoints[0].dx, penPoints[0].dy);

      if (penPoints.length == 1) {
        canvas.drawCircle(
          penPoints[0],
          2.0 / scale,
          penPaint..style = PaintingStyle.fill,
        );
      } else if (penPoints.length == 2) {
        path.lineTo(penPoints[1].dx, penPoints[1].dy);
      } else if (penPoints.length == 3) {
        path.quadraticBezierTo(
          penPoints[1].dx,
          penPoints[1].dy,
          penPoints[2].dx,
          penPoints[2].dy,
        );
      } else if (penPoints.length == 4) {
        path.cubicTo(
          penPoints[1].dx,
          penPoints[1].dy,
          penPoints[2].dx,
          penPoints[2].dy,
          penPoints[3].dx,
          penPoints[3].dy,
        );
      } else {
        for (int i = 1; i < penPoints.length - 2; i++) {
          final xc = (penPoints[i].dx + penPoints[i + 1].dx) / 2;
          final yc = (penPoints[i].dy + penPoints[i + 1].dy) / 2;
          path.quadraticBezierTo(penPoints[i].dx, penPoints[i].dy, xc, yc);
        }
        path.quadraticBezierTo(
          penPoints[penPoints.length - 2].dx,
          penPoints[penPoints.length - 2].dy,
          penPoints[penPoints.length - 1].dx,
          penPoints[penPoints.length - 1].dy,
        );
      }

      canvas.drawPath(path, penPaint);
    }

    canvas.restore();
  }

  void _drawPixels(
    Canvas canvas,
    Size size,
    double pixelWidth,
    double pixelHeight,
  ) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final index = y * width + x;
        final color = Color(pixels[index]);
        if (color.alpha == 0) continue;

        final rect = Rect.fromLTWH(
          x * pixelWidth,
          y * pixelHeight,
          pixelWidth,
          pixelHeight,
        );
        canvas.drawRect(rect, paint..color = color);
      }
    }
  }

  void _drawPreviewPixels(
    Canvas canvas,
    Size size,
    double pixelWidth,
    double pixelHeight,
  ) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (final point in previewPixels) {
      final x = point.x;
      final y = point.y;
      final index = y * width + x;
      final color = previewColor;

      final rect = Rect.fromLTWH(
        x * pixelWidth,
        y * pixelHeight,
        pixelWidth,
        pixelHeight,
      );
      canvas.drawRect(rect, paint..color = color);
    }
  }

  void _createImage(
    Uint32List pixels,
    int width,
    int height,
  ) async {
    final image =
        await ImageHelper.createImageFromPixels(pixels, width, height);
    cacheController.updateImage(image);
  }

  @override
  bool shouldRepaint(covariant _PixelGridPainter oldDelegate) {
    return listEquals(pixels, oldDelegate.pixels) ||
        listEquals(previewPixels, oldDelegate.previewPixels) ||
        previewColor != oldDelegate.previewColor ||
        selectionRect != oldDelegate.selectionRect ||
        gradientStart != oldDelegate.gradientStart ||
        gradientEnd != oldDelegate.gradientEnd ||
        scale != oldDelegate.scale ||
        offset != oldDelegate.offset ||
        listEquals(penPoints, oldDelegate.penPoints) ||
        isDrawingPenPath != oldDelegate.isDrawingPenPath;
  }
}
