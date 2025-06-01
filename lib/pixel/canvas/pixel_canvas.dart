import 'package:flutter/material.dart' hide SelectionOverlay;

import '../../core/utils/cursor_manager.dart';
import '../../pixel/tools/mirror_modifier.dart';
import '../../pixel/tools.dart';
import '../../data.dart';
import '../pixel_draw_state.dart';
import '../pixel_point.dart';

import 'canvas_controller.dart';
import 'canvas_gesture_handler.dart';
import 'canvas_painter.dart';
import 'layer_cache_manager.dart';
import 'tool_drawing_manager.dart';
import 'widgets/selection_overlay.dart';

class PixelCanvas extends StatefulWidget {
  final int width;
  final int height;
  final List<Layer> layers;
  final int currentLayerIndex;
  final PixelTool currentTool;
  final Color currentColor;
  final PixelModifier modifier;
  final int brushSize;
  final int sprayIntensity;
  final MirrorAxis mirrorAxis;
  final double zoomLevel;
  final Offset currentOffset;

  final Stream<PixelDrawEvent>? eventStream;

  // Callbacks
  final Function(int x, int y) onTapPixel;
  final Function() onStartDrawing;
  final Function() onFinishDrawing;
  final Function(List<PixelPoint<int>>) onDrawShape;
  final Function(SelectionModel?)? onSelectionChanged;
  final Function(SelectionModel)? onMoveSelection;
  final Function(Color)? onColorPicked;
  final Function(List<Color>)? onGradientApplied;
  final Function(double, Offset)? onStartDrag;
  final Function(double, Offset)? onDrag;
  final Function(double, Offset)? onDragEnd;
  final Function()? onUndo;

  const PixelCanvas({
    super.key,
    required this.width,
    required this.height,
    required this.layers,
    required this.currentLayerIndex,
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
    this.sprayIntensity = 5,
    this.zoomLevel = 1.0,
    this.currentOffset = Offset.zero,
    this.mirrorAxis = MirrorAxis.vertical,
    this.eventStream,
    this.onStartDrag,
    this.onDrag,
    this.onDragEnd,
    this.onUndo,
  });

  @override
  State<PixelCanvas> createState() => _PixelCanvasState();
}

class _PixelCanvasState extends State<PixelCanvas> {
  final _boxKey = GlobalKey();

  late final PixelCanvasController _controller;
  late final CanvasGestureHandler _gestureHandler;
  late final LayerCacheManager _cacheManager;
  late final ToolDrawingManager _toolManager;

  @override
  void initState() {
    super.initState();
    _initializeComponents();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.eventStream?.listen((event) {
        if (event is ClosePenPathEvent) {
          _finishPenPath();
        }
      });
    });
  }

  void _finishPenPath() {
    final details = _createDrawDetails(Offset.zero);

    _toolManager.closePenPath(_controller, details, close: false);
    _gestureHandler.finishDrawing();
  }

  void _initializeComponents() {
    _cacheManager = LayerCacheManager(
      width: widget.width,
      height: widget.height,
    );

    _controller = PixelCanvasController(
      width: widget.width,
      height: widget.height,
      layers: widget.layers,
      currentLayerIndex: widget.currentLayerIndex,
      cacheManager: _cacheManager,
    );

    _toolManager = ToolDrawingManager(
      width: widget.width,
      height: widget.height,
      onColorPicked: widget.onColorPicked,
      onSelectionChanged: (selection) {
        _controller.setSelection(selection);
        if (selection == null) {
          widget.onSelectionChanged!(selection);
        }
      },
      onMoveSelection: (selection) {
        _controller.setSelection(selection);

        widget.onMoveSelection?.call(selection);
      },
      onSelectionEnd: (selection) {
        final newSelection = selection?.copyWith(canvasSize: context.size ?? Size.zero);
        _controller.setSelection(newSelection);
        widget.onSelectionChanged?.call(newSelection);
      },
    );

    _gestureHandler = CanvasGestureHandler(
      controller: _controller,
      toolManager: _toolManager,
      onStartDrawing: widget.onStartDrawing,
      onFinishDrawing: widget.onFinishDrawing,
      onDrawShape: widget.onDrawShape,
      onStartDrag: widget.onStartDrag,
      onDrag: widget.onDrag,
      onDragEnd: widget.onDragEnd,
      onUndo: widget.onUndo,
    );

    _controller.initialize(widget.layers);
  }

  @override
  void didUpdateWidget(covariant PixelCanvas oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.layers != oldWidget.layers) {
      _controller.updateLayers(widget.layers);
    }

    if (widget.currentLayerIndex != oldWidget.currentLayerIndex) {
      _controller.setCurrentLayerIndex(widget.currentLayerIndex);
    }

    if (widget.currentTool != oldWidget.currentTool) {
      _controller.setCurrentTool(widget.currentTool);
    }

    if (widget.zoomLevel != oldWidget.zoomLevel) {
      _controller.setZoomLevel(widget.zoomLevel);
    }

    if (widget.currentOffset != oldWidget.currentOffset) {
      _controller.setOffset(widget.currentOffset);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _cacheManager.dispose();
    super.dispose();
  }

  bool _shouldShowHoverPreview(PixelTool tool) {
    return [
      PixelTool.pencil,
      PixelTool.eraser,
      PixelTool.line,
      PixelTool.rectangle,
      PixelTool.circle,
    ].contains(tool);
  }

  void _updateHoverPreview(Offset? position) {
    if (position == null || !_shouldShowHoverPreview(widget.currentTool)) {
      return _controller.setHoverPosition(null);
    }

    final brushStroke = _toolManager.generateBrushStroke(
      position,
      position,
      widget.brushSize,
      widget.currentColor,
      context.size ?? Size.zero,
    );
    _controller.setHoverPosition(position, previewPixels: brushStroke);
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      key: _boxKey,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Stack(
            fit: StackFit.expand,
            children: [
              Listener(
                onPointerDown: (event) {
                  _gestureHandler.handlePointerDown(
                    event,
                    widget.currentTool,
                    _createDrawDetails(event.localPosition),
                  );
                },
                onPointerMove: (event) {
                  _gestureHandler.handlePointerMove(
                    event,
                    widget.currentTool,
                    _createDrawDetails(event.localPosition),
                  );
                },
                onPointerUp: (event) {
                  _gestureHandler.handlePointerUp(
                    event,
                    widget.currentTool,
                    _createDrawDetails(event.localPosition),
                  );
                },
                child: MouseRegion(
                  cursor: _getCursor(),
                  onHover: (event) {
                    _controller.setHoverPosition(event.localPosition);
                    _updateHoverPreview(event.localPosition);
                  },
                  onExit: (event) {
                    _controller.setHoverPosition(null);
                  },
                  child: CustomPaint(
                    painter: PixelCanvasPainter(
                      width: widget.width,
                      height: widget.height,
                      controller: _controller,
                      cacheManager: _cacheManager,
                      currentTool: widget.currentTool,
                      currentColor: widget.currentColor,
                    ),
                    size: Size.infinite,
                  ),
                ),
              ),
              LayoutBuilder(builder: (context, constraints) {
                return SelectionOverlay(
                  selection: _controller.selectionRect,
                  zoomLevel: widget.zoomLevel,
                  canvasOffset: widget.currentOffset,
                  canvasWidth: widget.width,
                  canvasHeight: widget.height,
                  canvasSize: constraints.biggest,
                  onSelectionMove: (selection) {
                    final updatedSelection = selection;
                    _controller.setSelection(updatedSelection);
                    widget.onMoveSelection?.call(updatedSelection);
                  },
                  onSelectionEnd: () {
                    // widget.onMoveSelection?.call(_controller.selectionRect);
                  },
                );
              }),
            ],
          );
        },
      ),
    );
  }

  PixelDrawDetails _createDrawDetails(Offset position) {
    return PixelDrawDetails(
      position: position,
      size: context.size ?? Size.zero,
      width: widget.width,
      height: widget.height,
      currentLayer: widget.layers[widget.currentLayerIndex],
      color: widget.currentColor,
      strokeWidth: widget.brushSize,
      modifier: _getModifier(),
      onPixelsUpdated: (pixels) {
        _controller.setPreviewPixels(pixels);
      },
    );
  }

  Modifier? _getModifier() {
    if (widget.modifier == PixelModifier.mirror) {
      return MirrorModifier(widget.mirrorAxis);
    }
    return null;
  }

  MouseCursor _getCursor() {
    return CursorManager.instance.getCursor(widget.currentTool) ?? widget.currentTool.cursor;
  }
}
