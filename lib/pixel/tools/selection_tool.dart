import 'dart:ui';

import 'package:flutter/material.dart';

import '../../data.dart';

class SelectionUtils {
  int width;
  int height;
  Size Function() size;
  final Function(SelectionModel)? onMoveSelection;
  final Function(SelectionModel?)? onSelectionChanged;
  final Function(Function()) update;

  SelectionUtils({
    required this.width,
    required this.height,
    required this.size,
    this.onMoveSelection,
    this.onSelectionChanged,
    required this.update,
  });

  Offset _dragOffset = Offset.zero;
  Offset? _lastPanPosition;
  bool _isDraggingSelection = false;

  Offset? get lastPanPosition => _lastPanPosition;
  set lastPanPosition(Offset? value) {
    _lastPanPosition = value;
  }

  bool get isDraggingSelection => _isDraggingSelection;
  set isDraggingSelection(bool value) {
    _isDraggingSelection = value;
  }

  Rect? _selectionRect;
  Offset? _selectionStart;
  Offset? _selectionCurrent;

  Rect? get selectionRect => _selectionRect;
  set selectionRect(Rect? value) {
    _selectionRect = value;
  }

  void startDraggingSelection(Offset position) {
    update(() {
      _isDraggingSelection = true;
      _dragOffset = Offset.zero;
      _lastPanPosition = position;
    });
  }

  void updateDraggingSelection(Offset delta) {
    final boxSize = size();
    final pixelWidth = boxSize.width / width;
    final pixelHeight = boxSize.height / height;

    // Accumulate the delta movement
    _dragOffset += delta;

    // Calculate the integer pixel movement
    final dx = (_dragOffset.dx / pixelWidth).round();
    final dy = (_dragOffset.dy / pixelHeight).round();

    if (dx != 0 || dy != 0) {
      update(() {
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
      });
    }
  }

  void endDraggingSelection() {
    update(() {
      _isDraggingSelection = false;
      _dragOffset = Offset.zero;
      _lastPanPosition = null;
    });
  }

  void startSelection(Offset position) {
    update(() {
      _selectionStart = position;
      _selectionCurrent = position;
      _selectionRect = Rect.fromPoints(_selectionStart!, _selectionCurrent!);

      _isDraggingSelection = false;

      onSelectionChanged?.call(null);
    });
  }

  void updateSelection(Offset position) {
    update(() {
      _selectionCurrent = position;
      _selectionRect = Rect.fromPoints(_selectionStart!, _selectionCurrent!);
    });
  }

  void endSelection() {
    final boxSize = size();
    final pixelWidth = boxSize.width / width;
    final pixelHeight = boxSize.height / height;

    final selectionRect = _selectionRect;
    if (selectionRect == null) return;
    if (selectionRect.width < pixelWidth ||
        selectionRect.height < pixelHeight) {
      update(() {
        _selectionRect = null;
      });
      return;
    }

    int x0 = (selectionRect.left / pixelWidth).floor();
    int y0 = (selectionRect.top / pixelHeight).floor();
    int x1 = (selectionRect.right / pixelWidth).ceil();
    int y1 = (selectionRect.bottom / pixelHeight).ceil();

    x0 = x0.clamp(0, width - 1);
    y0 = y0.clamp(0, height - 1);
    x1 = x1.clamp(0, width);
    y1 = y1.clamp(0, height);

    update(() {
      _isDraggingSelection = true;
    });

    onSelectionChanged?.call(SelectionModel(
      x: x0,
      y: y0,
      width: x1 - x0,
      height: y1 - y0,
    ));
  }

  bool isPointInsideSelection(Offset point) {
    if (_selectionRect == null) return false;
    return _selectionRect!.contains(point);
  }

  bool inInSelectionBounds(int x, int y) {
    final selectionRect = _selectionRect;

    if (selectionRect == null) return true;
    final boxSize = size();
    final pixelWidth = boxSize.width / width;
    final pixelHeight = boxSize.height / height;

    final x0 = (selectionRect.left / pixelWidth).floor();
    final y0 = (selectionRect.top / pixelHeight).floor();
    final x1 = (selectionRect.right / pixelWidth).ceil();
    final y1 = (selectionRect.bottom / pixelHeight).ceil();

    return x >= x0 && x < x1 && y >= y0 && y < y1;
  }
}
