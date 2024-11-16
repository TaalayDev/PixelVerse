import 'dart:ui' as ui;
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../core/utils/cursor_manager.dart';
import '../../pixel/tools/selection_tool.dart';
import '../../core.dart';
import '../../pixel/tools.dart';
import '../../data.dart';
import '../../pixel/tools/shape_tool.dart';

class _CacheModel {
  ui.Image? image;
  bool isDirty = true;
}

class _CacheController extends ChangeNotifier {
  final Map<int, _CacheModel> _cachedLayerImages;

  Function()? _onCacheUpdated;

  _CacheController() : _cachedLayerImages = {};

  void updateLayerImage(int layer, ui.Image image) {
    if (_cachedLayerImages.containsKey(layer)) {
      _cachedLayerImages[layer]!.image = image;
      _cachedLayerImages[layer]!.isDirty = false;
    } else {
      _cachedLayerImages[layer] = _CacheModel()
        ..image = image
        ..isDirty = false;
    }
    _onCacheUpdated?.call();
    notifyListeners();
  }

  void markLayerDirty(int layer) {
    _cachedLayerImages[layer]?.isDirty = true;
    notifyListeners();
  }

  void _createImage(
    int layer,
    Uint32List pixels,
    int width,
    int height,
  ) async {
    final image =
        await ImageHelper.createImageFromPixels(pixels, width, height);
    updateLayerImage(layer, image);
  }

  @override
  void dispose() {
    for (var image in _cachedLayerImages.entries) {
      image.value.image?.dispose();
    }
    super.dispose();
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
  final PixelModifier modifier;
  final Color currentColor;
  final Function(List<Point<int>>) onDrawShape;

  final double zoomLevel;
  final Offset currentOffset;
  final Function(double, Offset)? onStartDrag;
  final Function(double, Offset)? onDrag;
  final Function(double, Offset)? onDragEnd;
  final int currentLayerIndex;

  const PixelGrid({
    super.key,
    required this.width,
    required this.height,
    required this.layers,
    required this.onTapPixel,
    required this.onBrushStroke,
    required this.currentTool,
    required this.currentColor,
    this.modifier = PixelModifier.none,
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
    this.onStartDrag,
    this.onDrag,
    this.onDragEnd,
    required this.currentLayerIndex,
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

  Offset? _gradientStart;
  Offset? _gradientEnd;

  // Variables for zooming and panning
  late double _currentScale = widget.zoomLevel;
  late Offset _currentOffset = widget.currentOffset;
  late double _scale = widget.zoomLevel;
  late Offset _offset = widget.currentOffset;
  Offset _normalizedOffset = Offset.zero;
  Offset? _panStartPosition;

  // Gesture details
  int _pointerCount = 0;
  final _closeThreshold = 10.0;

  late Uint32List _cachedPixels;
  late List<Layer> _cachedLayers;

  MouseCursor cursor = SystemMouseCursors.basic;

  RenderBox get renderBox =>
      _boxKey.currentContext!.findRenderObject() as RenderBox;
  late final _CacheController _cacheController;
  int get currentLayerId => widget.layers[widget.currentLayerIndex].layerId;

  late final _selectionTool = SelectionUtils(
    width: widget.width,
    height: widget.height,
    size: () => context.size!,
    onMoveSelection: widget.onMoveSelection,
    onSelectionChanged: widget.onSelectionChanged,
    update: (_) {
      setState(_);
    },
  );
  late final _shapeTool = ShapeUtils(
    width: widget.width,
    height: widget.height,
  );

  @override
  void initState() {
    super.initState();
    _cacheController = _CacheController();
    _cacheController._onCacheUpdated = () {
      _previewPixels.clear();
    };
    _updateCachedPixels(cacheAll: true);
    cursor = CursorManager.instance.getCursor(widget.currentTool) ??
        widget.currentTool.cursor;
  }

  @override
  void didUpdateWidget(covariant PixelGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.zoomLevel != oldWidget.zoomLevel) {
      setState(() {
        _currentScale = widget.zoomLevel;
      });
    }
    if (!listEquals(widget.layers, oldWidget.layers)) {
      _updateCachedPixels(
        cacheAll: widget.layers.length != oldWidget.layers.length,
      );
    }
    if (widget.currentTool != oldWidget.currentTool) {
      cursor = CursorManager.instance.getCursor(widget.currentTool) ??
          widget.currentTool.cursor;
    }
  }

  void _updateCachedPixels({bool cacheAll = false}) {
    _cachedLayers = List<Layer>.from(widget.layers);
    _cachedPixels = Uint32List(widget.width * widget.height);
    for (var i = 0; i < _cachedLayers.length; i++) {
      final layer = _cachedLayers[i];
      if (!layer.isVisible) {
        _cacheController._cachedLayerImages.remove(layer.layerId);
        _cacheController.markLayerDirty(layer.layerId);
        continue;
      }

      final layerPixels = Uint32List.fromList(layer.pixels);

      _cachedPixels = _mergePixels(_cachedPixels, layerPixels);
      if (i == widget.currentLayerIndex) {
        _cacheController._createImage(
          layer.layerId,
          layerPixels,
          widget.width,
          widget.height,
        );
        _cachedPixels = _mergePixelsWithPoint(
          _cachedPixels,
          _previewPixels,
          widget.currentTool == PixelTool.eraser
              ? Colors.transparent.value
              : widget.currentColor.value,
        );
        _cacheController.markLayerDirty(layer.layerId);
      } else if (cacheAll) {
        _cacheController._createImage(
          layer.layerId,
          layerPixels,
          widget.width,
          widget.height,
        );
        _cacheController.markLayerDirty(layer.layerId);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      key: _boxKey,
      child: GestureDetector(
        onScaleStart: (details) {
          _pointerCount = details.pointerCount;
          if (_pointerCount == 1) {
            // One finger touch
            if (widget.currentTool == PixelTool.drag) {
              _panStartPosition = details.focalPoint - _offset;
              widget.onStartDrag?.call(_scale, _offset);
            } else {
              _handlePanStart(details.localFocalPoint);
            }
          } else if (_pointerCount == 2) {
            // Two finger touch for zooming
            _normalizedOffset = (_offset - details.focalPoint) / _scale;
          }
        },
        onScaleUpdate: (details) {
          _pointerCount = details.pointerCount;
          if (_pointerCount == 1) {
            // One finger touch
            if (widget.currentTool == PixelTool.drag) {
              setState(() {
                _offset = details.focalPoint - _panStartPosition!;
              });
              widget.onDrag?.call(_scale, _offset);
            } else {
              _handlePanUpdate(details.localFocalPoint);
            }
          } else if (_pointerCount == 2) {
            // Two finger touch for zooming and panning
            setState(() {
              _scale = (_scale * details.scale).clamp(0.5, 10.0);
              _offset = details.focalPoint + _normalizedOffset * _scale;
            });

            widget.onDrag?.call(_scale, _offset);
          }
        },
        onScaleEnd: (details) {
          if (_pointerCount == 1) {
            if (widget.currentTool == PixelTool.drag) {
              widget.onDragEnd?.call(_scale, _offset);
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
            if (!_selectionTool.isPointInsideSelection(transformedPosition)) {
              _selectionTool.startSelection(transformedPosition);
              _selectionTool.endSelection();
            }
          } else if (widget.currentTool == PixelTool.pen) {
            _handlePenTap(transformedPosition);
          } else {
            widget.onStartDrawing();
            _startDrawing(transformedPosition);
          }
        },
        onTapUp: (details) {
          _endDrawing();
          widget.onFinishDrawing();
        },
        child: MouseRegion(
          cursor: cursor,
          child: CustomPaint(
            painter: _PixelGridPainter(
              width: widget.width,
              height: widget.height,
              pixels: _cachedPixels,
              previewPixels: _previewPixels,
              previewColor: widget.currentTool == PixelTool.eraser
                  ? Colors.white
                  : widget.currentColor,
              previewModifier: widget.modifier,
              selectionRect: _selectionTool.selectionRect,
              gradientStart: _gradientStart,
              gradientEnd: _gradientEnd,
              scale: _currentScale,
              offset: _currentOffset,
              penPoints: _penPoints,
              isDrawingPenPath: _isDrawingPenPath,
              blendMode: widget.currentTool == PixelTool.eraser
                  ? BlendMode.clear
                  : BlendMode.srcOver,
              cacheController: _cacheController,
              currentLayerIndex: widget.currentLayerIndex,
              layers: _cachedLayers,
            ),
            size: Size.infinite,
          ),
        ),
      ),
    );
  }

  void _handlePanStart(Offset position) {
    // Adjust for scale and offset
    final transformedPosition = (position - _currentOffset) / _currentScale;
    if (widget.currentTool == PixelTool.select) {
      if (_selectionTool.isPointInsideSelection(transformedPosition)) {
        _selectionTool.startDraggingSelection(transformedPosition);
      } else {
        _selectionTool.startSelection(transformedPosition);
      }
    } else if (widget.currentTool == PixelTool.eyedropper) {
      _handleEyedropper(transformedPosition);
    } else if (widget.currentTool == PixelTool.pen) {
      widget.onStartDrawing();
      _handlePenTap(transformedPosition);
    } else {
      // widget.onStartDrawing();
      // _startDrawing(transformedPosition);
    }
  }

  void _handlePanUpdate(Offset position) {
    // Adjust for scale and offset
    final transformedPosition = (position - _currentOffset) / _currentScale;
    if (widget.currentTool == PixelTool.select) {
      if (_selectionTool.isDraggingSelection) {
        final delta = transformedPosition - _selectionTool.lastPanPosition!;
        _selectionTool.updateDraggingSelection(delta);
        _selectionTool.lastPanPosition = transformedPosition;
      } else {
        _selectionTool.updateSelection(transformedPosition);
      }
    } else if (widget.currentTool == PixelTool.eyedropper) {
      _handleEyedropper(transformedPosition);
    } else if (widget.currentTool == PixelTool.pen && _isDrawingPenPath) {
      _handlePenDrag(transformedPosition);
    } else {
      _updateDrawing(transformedPosition);
    }
  }

  void _handlePanEnd() {
    if (widget.currentTool == PixelTool.select) {
      if (_selectionTool.isDraggingSelection) {
        _selectionTool.endDraggingSelection();
      } else {
        _selectionTool.endSelection();
      }
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
      final pixels = _shapeTool.getPenPathPixels(
        _penPoints,
        size: context.size!,
      );
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
      final pixels = _shapeTool.getPenPathPixels(
        _penPoints,
        close: true,
        size: context.size!,
      );
      widget.onDrawShape(pixels);
      widget.onFinishDrawing();
    }
    setState(() {
      _penPoints.clear();
      _isDrawingPenPath = false;
      _isClosingPath = false;
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

  void _endDrawing() {
    if (widget.currentTool == PixelTool.line ||
        widget.currentTool == PixelTool.rectangle ||
        widget.currentTool == PixelTool.circle ||
        widget.currentTool == PixelTool.pencil ||
        widget.currentTool == PixelTool.eraser ||
        widget.currentTool == PixelTool.brush ||
        widget.currentTool == PixelTool.sprayPaint) {
      widget.onDrawShape(_previewPixels);
    }
    _cacheController.markLayerDirty(currentLayerId);
    // _previewPixels.clear();
    _previousPosition = null;
    _startPosition = null;
    _currentPosition = null;
    setState(() {});
  }

  bool _inInSelectionBounds(int x, int y) {
    return _selectionTool.inInSelectionBounds(x, y);
  }

  void _onTapPixel(int x, int y) {
    if (!_inInSelectionBounds(x, y)) return;
    _previewPixels.add(Point(x, y));
  }

  List<Point<int>> _filterPoints(List<Point<int>> pixels) {
    final selectionRect = _selectionTool.selectionRect;
    if (selectionRect == null) return pixels;
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
      if (widget.currentTool == PixelTool.pencil) {
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
          _previewPixels = _filterPoints(
            _shapeTool.getLinePixels(startX, startY, x, y),
          );
          setState(() {});
        }
      } else if (widget.currentTool == PixelTool.rectangle) {
        if (_startPosition != null && _currentPosition != null) {
          final startX = (_startPosition!.dx / pixelWidth).floor();
          final startY = (_startPosition!.dy / pixelHeight).floor();
          _previewPixels = _filterPoints(
            _shapeTool.getRectanglePixels(startX, startY, x, y),
          );
          setState(() {});
        }
      } else if (widget.currentTool == PixelTool.circle) {
        if (_startPosition != null && _currentPosition != null) {
          final startX = (_startPosition!.dx / pixelWidth).floor();
          final startY = (_startPosition!.dy / pixelHeight).floor();
          _previewPixels = _filterPoints(
            _shapeTool.getCirclePixels(startX, startY, x, y),
          );
          setState(() {});
        }
      } else if (widget.currentTool == PixelTool.brush ||
          widget.currentTool == PixelTool.eraser) {
        final brushSize = widget.brushSize;
        final pixelsToUpdate = <Point<int>>[];

        if (_previousPosition != null) {
          final previousX = (_previousPosition!.dx / pixelWidth).floor();
          final previousY = (_previousPosition!.dy / pixelHeight).floor();

          final linePoints = _shapeTool.getLinePoints(
            previousX,
            previousY,
            x,
            y,
          );
          for (final point in linePoints) {
            final circlePoints = _shapeTool.getBrushPixels(
              point.x,
              point.y,
              brushSize,
            );
            pixelsToUpdate.addAll(circlePoints);
          }
        } else {
          final circlePoints = _shapeTool.getBrushPixels(x, y, brushSize);
          pixelsToUpdate.addAll(circlePoints);
        }

        _previousPosition = position;
        _previewPixels.addAll(_filterPoints(pixelsToUpdate));
        setState(() {});
      } else if (widget.currentTool == PixelTool.pixelPerfectLine) {
        if (_previousPosition != null) {
          final previousX = (_previousPosition!.dx / pixelWidth).floor();
          final previousY = (_previousPosition!.dy / pixelHeight).floor();

          final linePixels = _shapeTool.getPixelPerfectLinePixels(
            previousX,
            previousY,
            x,
            y,
          );
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

          final linePoints = _shapeTool.getLinePoints(
            previousX,
            previousY,
            x,
            y,
          );
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
        _previewPixels.addAll(_filterPoints(pixelsToUpdate));
        setState(() {});
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

  Uint32List _mergePixels(Uint32List pixels1, Uint32List pixels2) {
    final mergedPixels = Uint32List.fromList(pixels1);
    for (int i = 0; i < pixels2.length; i++) {
      if (pixels2[i] != 0) {
        mergedPixels[i] = pixels2[i];
      }
    }

    return mergedPixels;
  }

  Uint32List _mergePixelsWithPoint(
    Uint32List pixels,
    List<Point<int>> points,
    int color,
  ) {
    final mergedPixels = Uint32List.fromList(pixels);
    for (final point in points) {
      final index = point.y * widget.width + point.x;
      if (index >= 0 && index < pixels.length) {
        mergedPixels[index] = color;
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
  final PixelModifier previewModifier;
  final Color previewColor;
  final Rect? selectionRect;
  final Offset? gradientStart;
  final Offset? gradientEnd;

  final double scale;
  final Offset offset;

  final List<Offset> penPoints;
  final bool isDrawingPenPath;
  final BlendMode blendMode;
  final List<Layer> layers;
  final int currentLayerIndex;
  final _CacheController cacheController;

  _PixelGridPainter({
    required this.width,
    required this.height,
    required this.pixels,
    this.previewPixels = const [],
    this.previewModifier = PixelModifier.none,
    this.previewColor = Colors.black,
    this.selectionRect,
    this.gradientStart,
    this.gradientEnd,
    required this.scale,
    required this.offset,
    required this.penPoints,
    required this.isDrawingPenPath,
    required this.layers,
    required this.currentLayerIndex,
    required this.cacheController,
    this.blendMode = BlendMode.srcOver,
  }) : super(repaint: cacheController);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(offset.dx, offset.dy);
    canvas.scale(scale);

    final pixelWidth = size.width / width;
    final pixelHeight = size.height / height;

    // Draw layers pixels
    Rect? imageRect;
    final canvasRect = Offset.zero & size;
    if (cacheController._cachedLayerImages.isNotEmpty) {
      for (int i = 0; i < layers.length; i++) {
        canvas.saveLayer(canvasRect, Paint());
        final layer = layers[i];
        final image = cacheController._cachedLayerImages[layer.layerId]?.image;
        if (image != null) {
          imageRect ??= Rect.fromLTWH(
            0,
            0,
            image.width.toDouble(),
            image.height.toDouble(),
          );
          canvas.drawImageRect(
            image,
            imageRect,
            canvasRect,
            Paint(),
          );
        }
        if (i == currentLayerIndex) {
          _drawPreviewPixels(canvas, size, pixelWidth, pixelHeight);
        }
        canvas.restore();
      }
    } else {
      _drawPixels(canvas, size, pixelWidth, pixelHeight);
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
    final List<Offset> positions = [];
    final List<Color> colors = [];
    final List<int> indices = [];
    int vertexIndex = 0;

    for (final point in previewPixels) {
      final x = point.x;
      final y = point.y;
      final color = previewColor;
      if (color.alpha == 0) continue;

      final double left = x * pixelWidth;
      final double top = y * pixelHeight;
      final double right = left + pixelWidth;
      final double bottom = top + pixelHeight;

      // Define the four vertices of the pixel quad
      positions.add(Offset(left, top));
      positions.add(Offset(right, top));
      positions.add(Offset(right, bottom));
      positions.add(Offset(left, bottom));

      // Add the same color for all four vertices
      colors.add(color);
      colors.add(color);
      colors.add(color);
      colors.add(color);

      // Define indices for the two triangles of the quad
      indices.add(vertexIndex);
      indices.add(vertexIndex + 1);
      indices.add(vertexIndex + 2);

      indices.add(vertexIndex);
      indices.add(vertexIndex + 2);
      indices.add(vertexIndex + 3);

      vertexIndex += 4;

      // Handle mirror modifier if applicable
      if (previewModifier == PixelModifier.mirror) {
        final mirrorX = width - 1 - x;
        final mirrorLeft = mirrorX * pixelWidth;
        final mirrorRight = mirrorLeft + pixelWidth;

        positions.add(Offset(mirrorLeft, top));
        positions.add(Offset(mirrorRight, top));
        positions.add(Offset(mirrorRight, bottom));
        positions.add(Offset(mirrorLeft, bottom));

        colors.add(color);
        colors.add(color);
        colors.add(color);
        colors.add(color);

        indices.add(vertexIndex);
        indices.add(vertexIndex + 1);
        indices.add(vertexIndex + 2);

        indices.add(vertexIndex);
        indices.add(vertexIndex + 2);
        indices.add(vertexIndex + 3);

        vertexIndex += 4;
      }
    }

    final vertices = Vertices(
      VertexMode.triangles,
      positions,
      colors: colors,
      indices: indices,
    );

    final paint = Paint()..blendMode = blendMode;
    canvas.drawVertices(vertices, BlendMode.srcOver, paint);
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
