import 'dart:ui' as ui;
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../pixel/effects/effects.dart';
import '../../pixel/tools/fill_tool.dart';
import '../../pixel/tools/pencil_tool.dart';
import '../../pixel/tools/selection_tool.dart';
import '../../pixel/tools/eyedropper_tool.dart';
import '../../core/pixel_point.dart';
import '../../core/utils/cursor_manager.dart';
import '../../pixel/tools/mirror_modifier.dart';
import '../../pixel/tools/pen_tool.dart';
import '../../core.dart';
import '../../pixel/tools.dart';
import '../../data.dart';
import '../../pixel/tools/shape_tool.dart';
import '../../pixel/tools/shape_util.dart';

class _CacheModel {
  ui.Image? image;
  bool isDirty = true;
}

class _CacheController extends ChangeNotifier {
  final Map<int, _CacheModel> _cachedLayerImages;
  bool _isDirtyBatch = false;
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
    // Only mark if it's not already dirty to avoid unnecessary repaints
    if (_cachedLayerImages[layer]?.isDirty == false) {
      _cachedLayerImages[layer]?.isDirty = true;

      // If we're not in a batch operation, notify listeners immediately
      if (!_isDirtyBatch) {
        notifyListeners();
      }
    }
  }

  void batchOperation(Function() operation) {
    _isDirtyBatch = true;
    operation();
    _isDirtyBatch = false;
    notifyListeners(); // Only notify once at the end
  }

  void _createImage(
    int layer,
    Uint32List pixels,
    int width,
    int height,
  ) async {
    final image = await ImageHelper.createImageFromPixels(
      pixels,
      width,
      height,
    );
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

class PixelCanvas extends StatefulWidget {
  final int width;
  final int height;
  final List<Layer> layers;
  final Function(int x, int y) onTapPixel;
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
  final Function(List<PixelPoint<int>>) onDrawShape;

  final double zoomLevel;
  final Offset currentOffset;
  final Function(double, Offset)? onStartDrag;
  final Function(double, Offset)? onDrag;
  final Function(double, Offset)? onDragEnd;
  final int currentLayerIndex;

  const PixelCanvas({
    super.key,
    required this.width,
    required this.height,
    required this.layers,
    required this.onTapPixel,
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
  State<PixelCanvas> createState() => _PixelCanvasState();
}

class _PixelCanvasState extends State<PixelCanvas> {
  final _boxKey = GlobalKey();
  final random = Random();

  Offset? _previousPosition;
  Offset? _startPosition;
  Offset? _currentPosition;
  List<PixelPoint<int>> _previewPixels = [];

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

  // Tool instances
  late final _selectionUtils = SelectionUtils(
    width: widget.width,
    height: widget.height,
    size: () => context.size!,
    onSelectionChanged: widget.onSelectionChanged,
    onMoveSelection: (selection) {
      widget.onMoveSelection?.call(selection);
    },
    update: setState,
  );

  late final _shapeTool = ShapeUtils(
    width: widget.width,
    height: widget.height,
  );

  final fillTool = FillTool();
  final pencilTool = PencilTool();
  final penTool = PenTool();
  final lineTool = LineTool();
  final rectangleTool = RectangleTool();
  final circleTool = OvalTool();
  late final selectionTool = SelectionTool(_selectionUtils);
  late final eyedropperTool = EyedropperTool(
    onColorPicked: (color) => widget.onColorPicked?.call(color),
  );

  Tool get tool {
    switch (widget.currentTool) {
      case PixelTool.pencil:
        return pencilTool;
      case PixelTool.pen:
        return penTool;
      case PixelTool.line:
        return lineTool;
      case PixelTool.rectangle:
        return rectangleTool;
      case PixelTool.circle:
        return circleTool;
      case PixelTool.fill:
        return fillTool;
      case PixelTool.select:
        return selectionTool;
      case PixelTool.eyedropper:
        return eyedropperTool;
      default:
        return pencilTool;
    }
  }

  late var drawDetails = PixelDrawDetails(
    position: Offset.zero,
    size: Size.zero, // Will be set in build
    width: widget.width,
    height: widget.height,
    currentLayer: widget.layers[widget.currentLayerIndex],
    color: widget.currentColor,
    strokeWidth: widget.brushSize,
    modifier: modifier,
    onPixelsUpdated: (pixels) {
      setState(() {
        _previewPixels = pixels;
      });
    },
  );

  Modifier? get modifier {
    if (widget.modifier == PixelModifier.mirror) {
      return MirrorModifier(widget.mirrorAxis);
    }
    return null;
  }

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
  void didUpdateWidget(covariant PixelCanvas oldWidget) {
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

      // Apply effects processing to the layer pixels
      final processedPixels = _getLayerProcessedPixels(
        widget.width,
        widget.height,
        layer,
      );

      _cachedPixels = _mergePixels(_cachedPixels, processedPixels);

      if (i == widget.currentLayerIndex) {
        _cacheController._createImage(
          layer.layerId,
          processedPixels,
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
          processedPixels,
          widget.width,
          widget.height,
        );
        _cacheController.markLayerDirty(layer.layerId);
      }
    }
  }

  Uint32List _getLayerProcessedPixels(int width, int height, Layer layer) {
    if (layer.effects.isEmpty) {
      return layer.pixels;
    }

    return EffectsManager.applyMultipleEffects(
      layer.pixels,
      width,
      height,
      layer.effects,
    );
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
              final transformedPosition =
                  (details.localFocalPoint - _currentOffset) / _currentScale;

              drawDetails = drawDetails.copyWith(
                position: transformedPosition,
                size: context.size ?? Size.zero,
                currentLayer: widget.layers[widget.currentLayerIndex],
                color: widget.currentColor,
                strokeWidth: widget.brushSize,
                modifier: () => modifier,
              );

              widget.onStartDrawing();
              tool.onStart(drawDetails);
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
              final transformedPosition =
                  (details.localFocalPoint - _currentOffset) / _currentScale;

              drawDetails = drawDetails.copyWith(
                position: transformedPosition,
                color: widget.currentColor,
              );
              tool.onMove(drawDetails);
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
              // Use a microtask to ensure UI updates complete before submitting
              tool.onEnd(drawDetails);

              // Use Future.microtask to separate the state updates
              Future.microtask(() {
                _submitDrawing();
                widget.onFinishDrawing();
              });
            }
          }
          _pointerCount = 0;
        },
        onTapDown: (details) {
          final transformedPosition =
              (details.localPosition - _currentOffset) / _currentScale;

          drawDetails = drawDetails.copyWith(
            position: transformedPosition,
            size: context.size ?? Size.zero,
            currentLayer: widget.layers[widget.currentLayerIndex],
            color: widget.currentColor,
          );

          if (widget.currentTool == PixelTool.fill ||
              widget.currentTool == PixelTool.eyedropper) {
            widget.onStartDrawing();

            tool.onStart(drawDetails);
            if (widget.currentTool == PixelTool.fill ||
                widget.currentTool == PixelTool.eyedropper) {
              _submitDrawing();
              widget.onFinishDrawing();
            }
          } else if (widget.currentTool == PixelTool.pen) {
            _handlePenTap(transformedPosition);
          } else if (widget.currentTool == PixelTool.select) {
            selectionTool.onStart(drawDetails);
          } else {
            widget.onStartDrawing();
            _startDrawing(transformedPosition);
          }
        },
        onTapUp: (details) {
          if (widget.currentTool != PixelTool.fill &&
              widget.currentTool != PixelTool.eyedropper &&
              widget.currentTool != PixelTool.select) {
            // Use Future.microtask to separate the state updates
            Future.microtask(() {
              _submitDrawing();
              widget.onFinishDrawing();
            });
          } else if (widget.currentTool == PixelTool.select) {
            selectionTool.onEnd(drawDetails);
          }
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
              selectionRect: _selectionUtils.selectionRect,
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

  void _submitDrawing() {
    // Batch all state changes together to prevent multiple redraws
    if (widget.currentTool == PixelTool.line ||
        widget.currentTool == PixelTool.rectangle ||
        widget.currentTool == PixelTool.circle ||
        widget.currentTool == PixelTool.pencil ||
        widget.currentTool == PixelTool.eraser ||
        widget.currentTool == PixelTool.brush ||
        widget.currentTool == PixelTool.sprayPaint ||
        widget.currentTool == PixelTool.fill) {
      // Create a copy of preview pixels before clearing
      final pixelsToDraw = List<PixelPoint<int>>.from(_previewPixels);

      // Clear variables first without triggering a redraw
      _previousPosition = null;
      _startPosition = null;
      _currentPosition = null;
      //_previewPixels = [];

      // Then mark layer as dirty
      _cacheController.markLayerDirty(currentLayerId);

      // Finally submit the drawing to parent - do this last
      widget.onDrawShape(pixelsToDraw);
    } else {
      // For other tools, just clear the preview pixels
      setState(() {
        _previewPixels = [];
        _previousPosition = null;
        _startPosition = null;
        _currentPosition = null;
      });
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

  void _finalizePenPath() {
    if (_penPoints.length > 1) {
      // Convert the path into pixels and draw it
      final pixels = _shapeTool.getPenPathPixels(
        _penPoints,
        close: true,
        size: context.size!,
      );

      final coloredPixels = pixels.map((point) {
        return PixelPoint(
          point.x,
          point.y,
          color: widget.currentColor.value,
        );
      }).toList();

      widget.onDrawShape(coloredPixels);
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

  List<PixelPoint<int>> _filterPoints(List<PixelPoint<int>> pixels) {
    if (_selectionUtils.selectionRect == null) return pixels;
    return pixels.where((point) {
      return _selectionUtils.inInSelectionBounds(point.x, point.y);
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
        final pixelsToUpdate = <PixelPoint<int>>[];

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
      } else if (widget.currentTool == PixelTool.sprayPaint) {
        final intensity = widget.sprayIntensity;
        final brushSize = widget.brushSize;
        final pixelsToUpdate = <PixelPoint<int>>[];

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
                pixelsToUpdate.add(PixelPoint(
                  px,
                  py,
                  color: widget.currentColor.value,
                ));
              }
            }
          }
        } else {
          pixelsToUpdate.add(PixelPoint(
            x,
            y,
            color: widget.currentColor.value,
          ));
        }

        _previousPosition = position;
        _previewPixels.addAll(_filterPoints(pixelsToUpdate));
        setState(() {});
      }
    }
  }

  void _onTapPixel(int x, int y) {
    if (!_selectionUtils.inInSelectionBounds(x, y)) return;
    _previewPixels.add(PixelPoint(x, y, color: widget.currentColor.value));
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
    List<PixelPoint<int>> points,
    int color,
  ) {
    final mergedPixels = Uint32List.fromList(pixels);
    for (final point in points) {
      final index = point.y * widget.width + point.x;
      if (index >= 0 && index < pixels.length) {
        mergedPixels[index] = point.color != 0 ? point.color : color;
      }
    }
    return mergedPixels;
  }
}

/// CustomPainter for rendering the pixel grid and pixel data
class _PixelGridPainter extends CustomPainter {
  final int width;
  final int height;
  final Uint32List pixels;
  final List<PixelPoint<int>> previewPixels;
  final PixelModifier previewModifier;
  final Color previewColor;
  final SelectionModel? selectionRect;
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

    // Draw grid background
    _drawGridBackground(canvas, size, pixelWidth, pixelHeight);

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
        // Draw the preview pixels on the current layer
        if (i == currentLayerIndex) {
          _drawPreviewPixels(canvas, size, pixelWidth, pixelHeight);
        }
        canvas.restore();
      }
    } else {
      _drawPixels(canvas, size, pixelWidth, pixelHeight);
    }

    // Draw selection rectangle if active
    if (selectionRect != null &&
        selectionRect!.width > 0 &&
        selectionRect!.height > 0) {
      _drawSelectionRect(canvas, pixelWidth, pixelHeight);
    }

    // Draw gradient if active
    if (gradientStart != null && gradientEnd != null) {
      _drawGradient(canvas, size);
    }

    // Draw pen path preview if active
    if (isDrawingPenPath && penPoints.isNotEmpty) {
      _drawPenPathPreview(canvas);
    }

    canvas.restore();
  }

  void _drawGridBackground(
      Canvas canvas, Size size, double pixelWidth, double pixelHeight) {
    final paint = Paint()
      ..color = Colors.grey.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5 / scale;

    for (int x = 0; x <= width; x++) {
      canvas.drawLine(
        Offset(x * pixelWidth, 0),
        Offset(x * pixelWidth, size.height),
        paint,
      );
    }

    for (int y = 0; y <= height; y++) {
      canvas.drawLine(
        Offset(0, y * pixelHeight),
        Offset(size.width, y * pixelHeight),
        paint,
      );
    }
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
      final color = Color(point.color != 0 ? point.color : previewColor.value);
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
    }

    if (positions.isNotEmpty) {
      final vertices = Vertices(
        VertexMode.triangles,
        positions,
        colors: colors,
        indices: indices,
      );

      final paint = Paint()..blendMode = blendMode;
      canvas.drawVertices(vertices, BlendMode.srcOver, paint);
    }
  }

  void _drawSelectionRect(
      Canvas canvas, double pixelWidth, double pixelHeight) {
    final rect = Rect.fromLTWH(
      selectionRect!.x * pixelWidth,
      selectionRect!.y * pixelHeight,
      selectionRect!.width * pixelWidth,
      selectionRect!.height * pixelHeight,
    );

    // Draw fill with semi-transparent blue
    canvas.drawRect(
      rect,
      Paint()
        ..color = Colors.blueAccent.withOpacity(0.2)
        ..style = PaintingStyle.fill,
    );

    // Draw border with solid blue
    canvas.drawRect(
      rect,
      Paint()
        ..color = Colors.blue
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0 / scale,
    );

    // Draw handles at corners
    const handleSize = 6.0;
    final handlePaint = Paint()..color = Colors.blue;

    final handles = [
      Rect.fromCenter(
        center: rect.topLeft,
        width: handleSize / scale,
        height: handleSize / scale,
      ),
      Rect.fromCenter(
        center: rect.topRight,
        width: handleSize / scale,
        height: handleSize / scale,
      ),
      Rect.fromCenter(
        center: rect.bottomLeft,
        width: handleSize / scale,
        height: handleSize / scale,
      ),
      Rect.fromCenter(
        center: rect.bottomRight,
        width: handleSize / scale,
        height: handleSize / scale,
      ),
    ];

    for (final handle in handles) {
      canvas.drawRect(handle, handlePaint);
    }
  }

  void _drawGradient(Canvas canvas, Size size) {
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

  void _drawPenPathPreview(Canvas canvas) {
    final penPaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5 / scale;

    final path = Path();

    if (penPoints.isEmpty) return;

    path.moveTo(penPoints.first.dx, penPoints.first.dy);

    if (penPoints.length == 1) {
      // For single point, draw a small circle
      canvas.drawCircle(
        penPoints.first,
        2.0 / scale,
        penPaint..style = PaintingStyle.fill,
      );
    } else {
      // For multiple points, draw connected lines
      for (int i = 1; i < penPoints.length; i++) {
        path.lineTo(penPoints[i].dx, penPoints[i].dy);
      }

      // If we're close to the start point, show a dashed line to indicate closing
      if (penPoints.length > 2 &&
          (penPoints.last - penPoints.first).distance <= 15) {
        final dashPaint = Paint()
          ..color = Colors.green
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5 / scale;

        canvas.drawLine(
          penPoints.last,
          penPoints.first,
          dashPaint,
        );
      }
    }

    canvas.drawPath(path, penPaint);
  }

  @override
  bool shouldRepaint(covariant _PixelGridPainter oldDelegate) {
    return true; // Always repaint to ensure smooth updates
  }
}
