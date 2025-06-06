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

  final Map<int, PointerEvent> _activePointers = {};
  bool _isRawPointerDrawing = false;

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
    } else if (currentTool != PixelTool.drag) {
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
    } else if (!_isDrawingActive) {
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

    if (previewPixels.isNotEmpty) {
      onDrawShape(previewPixels);
    }

    onFinishDrawing();
    _isDrawingActive = false;
  }

  void finishDrawing() {
    if (_isRawPointerDrawing) {
      _finishRawPointerDrawing();
    } else {
      _finishDrawing();
    }
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

  void handlePointerDown(
    PointerDownEvent event,
    PixelTool currentTool,
    PixelDrawDetails drawDetails,
  ) {
    _activePointers[event.pointer] = event;
    final pointerCount = _activePointers.length;

    if (pointerCount == 1) {
      _handleSinglePointerDown(event, currentTool, drawDetails);
    } else if (pointerCount == 2) {
      _handleTwoPointerDown(event, currentTool);
    }
  }

  void handlePointerMove(
    PointerMoveEvent event,
    PixelTool currentTool,
    PixelDrawDetails drawDetails,
  ) {
    if (!_activePointers.containsKey(event.pointer)) return;

    _activePointers[event.pointer] = event;
    final pointerCount = _activePointers.length;

    if (pointerCount == 1) {
      _handleSinglePointerMove(event, currentTool, drawDetails);
    } else if (pointerCount == 2) {
      _handleTwoPointerMove(event, currentTool);
    }
  }

  void handlePointerUp(
    PointerUpEvent event,
    PixelTool currentTool,
    PixelDrawDetails drawDetails,
  ) {
    _activePointers.remove(event.pointer);
    final pointerCount = _activePointers.length;

    if (pointerCount == 0) {
      _handleAllPointersUp(event, currentTool, drawDetails);
    } else if (pointerCount == 1) {
      // Switched from multi-touch to single touch
      _handleMultiToSinglePointer(currentTool);
    }
  }

  void _handleSinglePointerDown(
    PointerDownEvent event,
    PixelTool currentTool,
    PixelDrawDetails drawDetails,
  ) {
    if (currentTool == PixelTool.drag) {
      _panStartPosition = event.position - controller.offset;
      onStartDrag?.call(controller.zoomLevel, controller.offset);
    } else if (_shouldHandleDirectTap(currentTool)) {
      // Immediate tools like fill, eyedropper
      onStartDrawing();
      toolManager.handleSelectionEnd(drawDetails);
      toolManager.handleTap(currentTool, drawDetails);

      if (_shouldFinishImmediately(currentTool)) {
        _finishDrawing();
      }
    } else if (currentTool == PixelTool.pen) {
      toolManager.handlePenTap(
        drawDetails,
        controller,
        onPathClosed: () {
          _finishDrawing();
        },
      );
    } else if (currentTool == PixelTool.select) {
      toolManager.handleSelectionStart(drawDetails);
    } else {
      // Drawing tools - start immediately
      onStartDrawing();
      toolManager.handleSelectionEnd(drawDetails);
      toolManager.startDrawing(currentTool, drawDetails);
      _isRawPointerDrawing = true;
    }
  }

  void _handleSinglePointerMove(
    PointerMoveEvent event,
    PixelTool currentTool,
    PixelDrawDetails drawDetails,
  ) {
    if (currentTool == PixelTool.drag && _panStartPosition != null) {
      final newOffset = event.position - _panStartPosition!;
      controller.setOffset(newOffset);
      onDrag?.call(controller.zoomLevel, newOffset);
    } else if (_isRawPointerDrawing) {
      toolManager.continueDrawing(currentTool, drawDetails);
    } else if (currentTool == PixelTool.select) {
      // Handle selection dragging
      toolManager.handleSelectionUpdate(drawDetails);
    }
  }

  void _handleTwoPointerDown(
    PointerDownEvent event,
    PixelTool currentTool,
  ) {
    // Stop any ongoing drawing when second finger touches
    if (_isRawPointerDrawing) {
      _finishRawPointerDrawing();
    }

    // Initialize two-finger gesture (zoom/pan or undo)
    final pointers = _activePointers.values.toList();
    if (pointers.length >= 2) {
      final pointer1 = pointers[0];
      final pointer2 = pointers[1];
      final focalPoint = Offset(
        (pointer1.position.dx + pointer2.position.dx) / 2,
        (pointer1.position.dy + pointer2.position.dy) / 2,
      );

      _twoFingerStartFocalPoint = focalPoint;
      _twoFingerStartTimeMs = DateTime.now().millisecondsSinceEpoch;
      _initialTwoFingerScale = controller.zoomLevel;
      _isTwoFingerPotentiallyUndo = true;
      _normalizedOffset = (controller.offset - focalPoint) / controller.zoomLevel;
    }
  }

  void _handleTwoPointerMove(
    PointerMoveEvent event,
    PixelTool currentTool,
  ) {
    final pointers = _activePointers.values.toList();
    if (pointers.length < 2) return;

    final pointer1 = pointers[0];
    final pointer2 = pointers[1];

    // Calculate current focal point and scale
    final currentFocalPoint = Offset(
      (pointer1.position.dx + pointer2.position.dx) / 2,
      (pointer1.position.dy + pointer2.position.dy) / 2,
    );

    final currentDistance = (pointer1.position - pointer2.position).distance;
    final initialDistance = _getInitialTwoPointerDistance();

    if (_isTwoFingerPotentiallyUndo && _twoFingerStartFocalPoint != null) {
      final distanceMoved = (currentFocalPoint - _twoFingerStartFocalPoint!).distance;
      final scaleChange = initialDistance > 0 ? (currentDistance / initialDistance - 1.0).abs() : 0.0;

      // Cancel undo potential if significant movement or scaling
      if (distanceMoved > 20.0 || scaleChange > 0.05) {
        _isTwoFingerPotentiallyUndo = false;
      }
    }

    // Apply zoom and pan
    if (initialDistance > 0 && _initialTwoFingerScale != null) {
      final scale = currentDistance / initialDistance;
      final newScale = (_initialTwoFingerScale! * scale).clamp(0.5, 10.0);
      final newOffset = currentFocalPoint + _normalizedOffset * newScale;

      controller.setZoomLevel(newScale);
      controller.setOffset(newOffset);
      onDrag?.call(newScale, newOffset);
    }
  }

  void _handleAllPointersUp(
    PointerUpEvent event,
    PixelTool currentTool,
    PixelDrawDetails drawDetails,
  ) {
    // Check for undo gesture
    if (_isTwoFingerPotentiallyUndo && _twoFingerStartTimeMs != null) {
      if (_handleUndoGesture(_twoFingerStartTimeMs!)) {
        _resetPointerState();
        return;
      }
    }

    // Handle single-finger tool completion
    if (currentTool == PixelTool.drag) {
      onDragEnd?.call(controller.zoomLevel, controller.offset);
    } else if (_isRawPointerDrawing) {
      toolManager.endDrawing(currentTool, drawDetails);
      _finishRawPointerDrawing();
    } else if (currentTool == PixelTool.select) {
      toolManager.handleSelectionEnd(drawDetails);
    }

    _resetPointerState();
  }

  void _handleMultiToSinglePointer(PixelTool currentTool) {
    // Reset two-finger state when going from 2+ fingers to 1
    _resetTwoFingerState();

    // Could potentially restart single-finger operation here if needed
    debugPrint("Switched from multi-touch to single touch");
  }

  void _finishRawPointerDrawing() {
    if (_isRawPointerDrawing) {
      final previewPixels = List<PixelPoint<int>>.from(controller.previewPixels);

      if (previewPixels.isNotEmpty) {
        onDrawShape(previewPixels);
      }

      onFinishDrawing();
      _isRawPointerDrawing = false;
    }
  }

  void _resetPointerState() {
    _isRawPointerDrawing = false;
    _panStartPosition = null;
    _resetTwoFingerState();
  }

  double _getInitialTwoPointerDistance() {
    if (_activePointers.length < 2) return 0.0;

    final pointers = _activePointers.values.toList();
    return (pointers[0].position - pointers[1].position).distance;
  }

  // Helper method to handle pointer cancel events
  void handlePointerCancel(
    PointerCancelEvent event,
    PixelTool currentTool,
    PixelDrawDetails drawDetails,
  ) {
    _activePointers.remove(event.pointer);

    // Clean up any ongoing operations
    if (_activePointers.isEmpty) {
      if (_isRawPointerDrawing) {
        // Don't finish drawing on cancel - just clean up
        controller.clearPreviewPixels();
        onFinishDrawing();
        _isRawPointerDrawing = false;
      }
      _resetPointerState();
    }
  }

  // Helper method to check if there are active drawing operations
  bool get hasActivePointers => _activePointers.isNotEmpty;

  // Helper method to get current pointer count
  int get activePointerCount => _activePointers.length;
}
