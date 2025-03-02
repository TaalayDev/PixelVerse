import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

import '../../data/models/selection_model.dart';
import '../tools.dart';

/// A utility class for handling selection operations in the PixelCanvas
class SelectionUtils {
  final int width;
  final int height;
  final Size Function() size;
  final Function(SelectionModel?)? onSelectionChanged;
  final Function(SelectionModel)? onMoveSelection;
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
    required this.update,
  });

  bool isPointInsideSelection(Offset position) {
    if (selectionRect == null) return false;

    final pixelWidth = size().width / width;
    final pixelHeight = size().height / height;

    final selX = selectionRect!.x;
    final selY = selectionRect!.y;
    final selWidth = selectionRect!.width;
    final selHeight = selectionRect!.height;

    final x = (position.dx / pixelWidth).floor();
    final y = (position.dy / pixelHeight).floor();

    return x >= selX &&
        x < selX + selWidth &&
        y >= selY &&
        y < selY + selHeight;
  }

  bool inInSelectionBounds(int x, int y) {
    if (selectionRect == null) return true;

    final selX = selectionRect!.x;
    final selY = selectionRect!.y;
    final selWidth = selectionRect!.width;
    final selHeight = selectionRect!.height;

    return x >= selX &&
        x < selX + selWidth &&
        y >= selY &&
        y < selY + selHeight;
  }

  void startSelection(Offset position) {
    final pixelWidth = size().width / width;
    final pixelHeight = size().height / height;

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
      );
    });
  }

  void updateSelection(Offset position) {
    if (startPosition == null) return;

    final pixelWidth = size().width / width;
    final pixelHeight = size().height / height;

    final startX = (startPosition!.dx / pixelWidth).floor();
    final startY = (startPosition!.dy / pixelHeight).floor();

    final x = (position.dx / pixelWidth).floor();
    final y = (position.dy / pixelHeight).floor();

    endPosition = position;

    final minX = startX < x ? startX : x;
    final minY = startY < y ? startY : y;
    final maxX = startX > x ? startX : x;
    final maxY = startY > y ? startY : y;

    final selectionWidth = maxX - minX + 1;
    final selectionHeight = maxY - minY + 1;

    update(() {
      selectionRect = SelectionModel(
        x: minX,
        y: minY,
        width: selectionWidth,
        height: selectionHeight,
      );
    });
  }

  void endSelection() {
    if (selectionRect != null &&
        (selectionRect!.width <= 1 || selectionRect!.height <= 1)) {
      // If selection is too small, clear it
      clearSelection();
      return;
    }

    startPosition = null;
    endPosition = null;

    // Notify selection changed callback
    onSelectionChanged?.call(selectionRect);
  }

  void clearSelection() {
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
    if (selectionRect == null || !isDraggingSelection) return;

    final pixelWidth = size().width / width;
    final pixelHeight = size().height / height;

    // Convert delta from screen coordinates to grid coordinates
    final pixelDeltaX = (delta.dx / pixelWidth).round();
    final pixelDeltaY = (delta.dy / pixelHeight).round();

    if (pixelDeltaX == 0 && pixelDeltaY == 0) return;

    // Calculate new selection position, ensuring it stays within canvas bounds
    int newX = selectionRect!.x + pixelDeltaX;
    int newY = selectionRect!.y + pixelDeltaY;

    // Constrain selection to canvas bounds
    newX = newX.clamp(0, width - selectionRect!.width);
    newY = newY.clamp(0, height - selectionRect!.height);

    final updatedSelection = SelectionModel(
      x: newX,
      y: newY,
      width: selectionRect!.width,
      height: selectionRect!.height,
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
class SelectionTool extends Tool {
  final SelectionUtils utils;

  SelectionTool(this.utils) : super(PixelTool.select);

  @override
  void onStart(PixelDrawDetails details) {
    if (utils.isPointInsideSelection(details.position)) {
      utils.startDraggingSelection(details.position);
    } else {
      utils.startSelection(details.position);
    }
  }

  @override
  void onMove(PixelDrawDetails details) {
    if (utils.isDraggingSelection) {
      if (utils.lastPanPosition != null) {
        final delta = details.position - utils.lastPanPosition!;
        utils.updateDraggingSelection(delta);
        utils.lastPanPosition = details.position;
      }
    } else {
      utils.updateSelection(details.position);
    }
  }

  @override
  void onEnd(PixelDrawDetails details) {
    if (utils.isDraggingSelection) {
      utils.endDraggingSelection();
    } else {
      utils.endSelection();
    }
  }
}
