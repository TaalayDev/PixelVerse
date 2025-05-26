import 'package:flutter/material.dart';

import '../../pixel/tools.dart';
import '../pixel_point.dart';
import 'canvas_controller.dart';
import 'tool_drawing_manager.dart';

/// Handles all gesture input for the pixel canvas
class CanvasGestureHandler {
  final PixelCanvasController controller;
  final ToolDrawingManager toolManager;

  // Callbacks
  final VoidCallback onStartDrawing;
  final VoidCallback onFinishDrawing;
  final Function(List<PixelPoint<int>>) onDrawShape;
  final Function(double, Offset)? onStartDrag;
  final Function(double, Offset)? onDrag;
  final Function(double, Offset)? onDragEnd;
  final VoidCallback? onUndo;

  // Gesture state
  int _pointerCount = 0;
  Offset? _panStartPosition;
  Offset? _twoFingerStartFocalPoint;
  int? _twoFingerStartTimeMs;
  double? _initialTwoFingerScale;
  bool _isTwoFingerPotentiallyUndo = false;
  Offset _normalizedOffset = Offset.zero;

  // Drawing state
  bool _isDrawingActive = false;

  CanvasGestureHandler({
    required this.controller,
    required this.toolManager,
    required this.onStartDrawing,
    required this.onFinishDrawing,
    required this.onDrawShape,
    this.onStartDrag,
    this.onDrag,
    this.onDragEnd,
    this.onUndo,
  });

  void handleScaleStart(
    ScaleStartDetails details,
    PixelTool currentTool,
    PixelDrawDetails drawDetails,
  ) {
    _pointerCount = details.pointerCount;

    if (_pointerCount == 1) {
      _handleSingleFingerStart(details, currentTool, drawDetails);
    } else if (_pointerCount == 2) {
      _handleTwoFingerStart(details);
    }
  }

  void handleScaleUpdate(
    ScaleUpdateDetails details,
    PixelTool currentTool,
    PixelDrawDetails drawDetails,
  ) {
    _pointerCount = details.pointerCount;

    if (_pointerCount == 1) {
      _handleSingleFingerUpdate(details, currentTool, drawDetails);
    } else if (_pointerCount == 2) {
      _handleTwoFingerUpdate(details);
    }
  }

  void handleScaleEnd(
    ScaleEndDetails details,
    PixelTool currentTool,
    PixelDrawDetails drawDetails,
  ) {
    final wasUndoAttempt = _isTwoFingerPotentiallyUndo;
    final startTimeForUndo = _twoFingerStartTimeMs;
    final currentPointerCountAtEnd = _pointerCount;

    _resetTwoFingerState();

    if (wasUndoAttempt && startTimeForUndo != null && currentPointerCountAtEnd == 2) {
      if (_handleUndoGesture(startTimeForUndo)) {
        _pointerCount = 0;
        _isDrawingActive = false;
        return;
      }
    }

    if (_pointerCount == 1) {
      _handleSingleFingerEnd(currentTool, drawDetails);
    }

    _pointerCount = 0;
  }

  void handleTapDown(
    TapDownDetails details,
    PixelTool currentTool,
    PixelDrawDetails drawDetails,
  ) {
    if (_shouldHandleDirectTap(currentTool)) {
      onStartDrawing();
      toolManager.handleTap(currentTool, drawDetails);

      if (_shouldFinishImmediately(currentTool)) {
        _finishDrawing();
      }
    } else if (currentTool == PixelTool.pen) {
      toolManager.handlePenTap(drawDetails, controller);
    } else if (currentTool == PixelTool.select) {
      toolManager.handleSelectionStart(drawDetails);
    } else {
      _startDrawing(currentTool, drawDetails);
    }
  }

  void handleTapUp(
    TapUpDetails details,
    PixelTool currentTool,
    PixelDrawDetails drawDetails,
  ) {
    if (!_shouldHandleDirectTap(currentTool) && currentTool != PixelTool.select) {
      _finishDrawing();
    } else if (currentTool == PixelTool.select) {
      toolManager.handleSelectionEnd(drawDetails);
    }
  }

  void _handleSingleFingerStart(
    ScaleStartDetails details,
    PixelTool currentTool,
    PixelDrawDetails drawDetails,
  ) {
    if (currentTool == PixelTool.drag) {
      _panStartPosition = details.focalPoint - controller.offset;
      onStartDrag?.call(controller.zoomLevel, controller.offset);
    } else {
      onStartDrawing();
      toolManager.startDrawing(currentTool, drawDetails);
      _isDrawingActive = true;
    }
  }

  void _handleSingleFingerUpdate(
    ScaleUpdateDetails details,
    PixelTool currentTool,
    PixelDrawDetails drawDetails,
  ) {
    if (currentTool == PixelTool.drag) {
      final newOffset = details.focalPoint - _panStartPosition!;
      controller.setOffset(newOffset);
      onDrag?.call(controller.zoomLevel, newOffset);
    } else if (_isDrawingActive) {
      toolManager.continueDrawing(currentTool, drawDetails);
    }
  }

  void _handleSingleFingerEnd(
    PixelTool currentTool,
    PixelDrawDetails drawDetails,
  ) {
    if (currentTool == PixelTool.drag) {
      onDragEnd?.call(controller.zoomLevel, controller.offset);
    } else if (_isDrawingActive) {
      toolManager.endDrawing(currentTool, drawDetails);
      _finishDrawing();
    }
    _isDrawingActive = false;
  }

  void _handleTwoFingerStart(ScaleStartDetails details) {
    _twoFingerStartFocalPoint = details.focalPoint;
    _twoFingerStartTimeMs = DateTime.now().millisecondsSinceEpoch;
    _initialTwoFingerScale = controller.zoomLevel;
    _isTwoFingerPotentiallyUndo = true;
    _normalizedOffset = (controller.offset - details.focalPoint) / controller.zoomLevel;
  }

  void _handleTwoFingerUpdate(ScaleUpdateDetails details) {
    if (_isTwoFingerPotentiallyUndo) {
      final distanceMoved = (details.focalPoint - _twoFingerStartFocalPoint!).distance;
      if (distanceMoved > 20.0 || (details.scale - 1.0).abs() > 0.05) {
        _isTwoFingerPotentiallyUndo = false;
      }
    }

    final newScale = (_initialTwoFingerScale! * details.scale).clamp(0.5, 10.0);
    final newOffset = details.focalPoint + _normalizedOffset * newScale;

    controller.setZoomLevel(newScale);
    controller.setOffset(newOffset);
    onDrag?.call(newScale, newOffset);
  }

  bool _handleUndoGesture(int startTimeForUndo) {
    final endTimeMs = DateTime.now().millisecondsSinceEpoch;
    final durationMs = endTimeMs - startTimeForUndo;

    if (durationMs < 350) {
      debugPrint("Two-finger tap for UNDO detected. Duration: $durationMs ms");
      onUndo?.call();
      return true;
    }
    return false;
  }

  void _startDrawing(PixelTool currentTool, PixelDrawDetails drawDetails) {
    onStartDrawing();
    toolManager.startDrawing(currentTool, drawDetails);
    _isDrawingActive = true;
  }

  void _finishDrawing() {
    final previewPixels = List<PixelPoint<int>>.from(controller.previewPixels);
    controller.clearPreviewPixels();

    if (previewPixels.isNotEmpty) {
      onDrawShape(previewPixels);
    }

    onFinishDrawing();
    _isDrawingActive = false;
  }

  void _resetTwoFingerState() {
    _isTwoFingerPotentiallyUndo = false;
    _twoFingerStartFocalPoint = null;
    _twoFingerStartTimeMs = null;
    _initialTwoFingerScale = null;
  }

  bool _shouldHandleDirectTap(PixelTool tool) {
    return tool == PixelTool.fill || tool == PixelTool.eyedropper;
  }

  bool _shouldFinishImmediately(PixelTool tool) {
    return tool == PixelTool.fill || tool == PixelTool.eyedropper;
  }
}
