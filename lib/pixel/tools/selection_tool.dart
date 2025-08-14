import 'dart:math';

import 'package:flutter/material.dart';

import '../../data/models/selection_model.dart';
import '../pixel_point.dart';
import '../tools.dart';
import 'shape_tool.dart';

/// A utility class for handling selection operations in the PixelCanvas
class SelectionUtils {
  final int width;
  final int height;
  final Size Function() size;
  final Function(SelectionModel?)? onSelectionChanged;
  final Function(SelectionModel)? onMoveSelection;
  final Function(SelectionModel?)? onSelectionEnd;
  final Function(Function()) update;

  SelectionModel? selectionRect;
  bool isDraggingSelection = false;
  Offset? lastPanPosition;
  Offset? startPosition;
  Offset? endPosition;

  SelectionUtils({
    required this.width,
    required this.height,
    required this.size,
    required this.onSelectionChanged,
    required this.onMoveSelection,
    required this.onSelectionEnd,
    required this.update,
  });

  bool isPointInsideSelection(Offset position) {
    if (selectionRect == null) return false;

    final canvasSize = size();
    if (canvasSize.width == 0 || canvasSize.height == 0) {
      debugPrint('SelectionUtils: Canvas size is zero: $canvasSize');
      return false;
    }

    final pixelWidth = canvasSize.width / width;
    final pixelHeight = canvasSize.height / height;

    final selX = selectionRect!.x;
    final selY = selectionRect!.y;
    final selWidth = selectionRect!.width;
    final selHeight = selectionRect!.height;

    final x = (position.dx / pixelWidth).floor();
    final y = (position.dy / pixelHeight).floor();

    final isInside = x >= selX && x < selX + selWidth && y >= selY && y < selY + selHeight;

    return isInside;
  }

  bool inInSelectionBounds(int x, int y) {
    if (selectionRect == null) return true;

    final selX = selectionRect!.x;
    final selY = selectionRect!.y;
    final selWidth = selectionRect!.width;
    final selHeight = selectionRect!.height;

    return x >= selX && x < selX + selWidth && y >= selY && y < selY + selHeight;
  }

  void startSelection(Offset position) {
    final canvasSize = size();
    if (canvasSize.width == 0 || canvasSize.height == 0) {
      debugPrint('SelectionUtils: Cannot start selection - canvas size is zero: $canvasSize');
      return;
    }

    final pixelWidth = canvasSize.width / width;
    final pixelHeight = canvasSize.height / height;

    final x = (position.dx / pixelWidth).floor();
    final y = (position.dy / pixelHeight).floor();

    startPosition = position;
    endPosition = position;

    update(() {
      selectionRect = SelectionModel(
        x: x,
        y: y,
        width: 1,
        height: 1,
        canvasSize: canvasSize,
      );
    });
    onSelectionChanged?.call(selectionRect);
  }

  void updateSelection(Offset position) {
    if (startPosition == null) {
      debugPrint('SelectionUtils: Cannot update selection - no start position');
      return;
    }

    final canvasSize = size();
    if (canvasSize.width == 0 || canvasSize.height == 0) {
      debugPrint('SelectionUtils: Cannot update selection - canvas size is zero: $canvasSize');
      return;
    }

    final pixelWidth = canvasSize.width / width;
    final pixelHeight = canvasSize.height / height;

    // Use floor() for start position to get exact pixel coordinate
    final startX = (startPosition!.dx / pixelWidth).floor();
    final startY = (startPosition!.dy / pixelHeight).floor();

    // Use round() for end position to make selection more inclusive
    // This ensures that if user drags to 30.34x40.56, it rounds to (30,41)
    // giving a more intuitive selection behavior
    final x = (position.dx / pixelWidth).round();
    final y = (position.dy / pixelHeight).round();

    endPosition = position;

    final minX = min(startX, x);
    final minY = min(startY, y);
    final maxX = max(startX, x);
    final maxY = max(startY, y);

    final selectionWidth = maxX - minX + 1;
    final selectionHeight = maxY - minY + 1;

    update(() {
      selectionRect = SelectionModel(
        x: minX,
        y: minY,
        width: selectionWidth,
        height: selectionHeight,
        canvasSize: canvasSize,
      );
    });
    onSelectionChanged?.call(selectionRect);
  }

  void endSelection() {
    if (selectionRect != null && (selectionRect!.width <= 1 || selectionRect!.height <= 1)) {
      // If selection is too small, clear it
      debugPrint('SelectionUtils: Selection too small, clearing');
      clearSelection();
      return;
    }

    startPosition = null;
    endPosition = null;

    // Notify selection changed callback
    onSelectionChanged?.call(selectionRect);
    onSelectionEnd?.call(selectionRect);
  }

  void clearSelection() {
    debugPrint('SelectionUtils: Clearing selection');
    update(() {
      selectionRect = null;
      isDraggingSelection = false;
      lastPanPosition = null;
      startPosition = null;
      endPosition = null;
    });
    onSelectionChanged?.call(null);
  }

  void startDraggingSelection(Offset position) {
    lastPanPosition = position;
    isDraggingSelection = true;
  }

  void updateDraggingSelection(Offset delta) {
    final canvasSize = size();
    if (canvasSize.width == 0 || canvasSize.height == 0) {
      debugPrint('SelectionUtils: Cannot update dragging selection - canvas size is zero: $canvasSize');
      return;
    }

    if (selectionRect == null || !isDraggingSelection) return;

    final pixelWidth = canvasSize.width / width;
    final pixelHeight = canvasSize.height / height;

    // Convert delta from screen coordinates to grid coordinates
    final pixelDeltaX = (delta.dx / pixelWidth).round();
    final pixelDeltaY = (delta.dy / pixelHeight).round();

    if (pixelDeltaX == 0 && pixelDeltaY == 0) return;

    // Calculate new selection position, ensuring it stays within canvas bounds
    int newX = selectionRect!.x + pixelDeltaX;
    int newY = selectionRect!.y + pixelDeltaY;

    final updatedSelection = SelectionModel(
      x: newX,
      y: newY,
      width: selectionRect!.width,
      height: selectionRect!.height,
      canvasSize: canvasSize,
    );

    update(() {
      selectionRect = updatedSelection;
    });

    // Notify selection moved callback
    onMoveSelection?.call(updatedSelection);
  }

  void endDraggingSelection() {
    isDraggingSelection = false;
    lastPanPosition = null;

    // Notify selection changed callback
    onSelectionChanged?.call(selectionRect);
  }
}

/// Implementation of SelectionTool that conforms to the Tool interface
class SelectionTool extends ShapeTool {
  final SelectionUtils utils;
  final ShapeTool rectangleTool;

  SelectionTool(this.utils, this.rectangleTool) : super(PixelTool.select);

  // @override
  // void onStart(PixelDrawDetails details) {
  //   if (utils.isPointInsideSelection(details.position)) {
  //     utils.startDraggingSelection(details.position);
  //   } else {
  //     utils.startSelection(details.position);
  //   }
  // }

  // @override
  // void onMove(PixelDrawDetails details) {
  //   if (utils.isDraggingSelection) {
  //     if (utils.lastPanPosition != null) {
  //       final delta = details.position - utils.lastPanPosition!;
  //       utils.updateDraggingSelection(delta);
  //       utils.lastPanPosition = details.position;
  //     }
  //   } else {
  //     utils.updateSelection(details.position);
  //   }
  // }

  // @override
  // void onEnd(PixelDrawDetails details) {
  //   if (utils.isDraggingSelection) {
  //     utils.endDraggingSelection();
  //   } else {
  //     utils.endSelection();
  //   }
  // }

  @override
  List<PixelPoint<int>> generateShapePoints(PixelPoint<int> start, PixelPoint<int> end, int width, int height) {
    return rectangleTool.generateShapePoints(start, end, width, height);
  }
}
