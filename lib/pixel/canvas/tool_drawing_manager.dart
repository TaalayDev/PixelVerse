import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

import '../../pixel/tools.dart';
import '../../pixel/tools/fill_tool.dart';
import '../../pixel/tools/pencil_tool.dart';
import '../../pixel/tools/selection_tool.dart';
import '../../pixel/tools/eyedropper_tool.dart';
import '../../pixel/tools/pen_tool.dart';
import '../../pixel/tools/shape_tool.dart';
import '../../pixel/tools/shape_util.dart';
import '../../data.dart';
import '../pixel_point.dart';
import 'canvas_controller.dart';

/// Manages tool-specific drawing operations
class ToolDrawingManager {
  final int width;
  final int height;
  final Function(Color)? onColorPicked;
  final Function(SelectionModel?)? onSelectionChanged;
  final Function(SelectionModel)? onMoveSelection;
  final Function(List<PixelPoint<int>>?)? onSelectionEnd;

  late final SelectionUtils _selectionUtils;
  late final ShapeUtils _shapeUtils;

  // Tool instances
  late final FillTool _fillTool;
  late final PencilTool _pencilTool;
  late final PenTool _penTool;
  late final LineTool _lineTool;
  late final RectangleTool _rectangleTool;
  late final OvalToolBresenham _circleTool;
  late final SelectionTool _selectionTool;
  late final EyedropperTool _eyedropperTool;

  final Random _random = Random();

  ToolDrawingManager({
    required this.width,
    required this.height,
    this.onColorPicked,
    this.onSelectionChanged,
    this.onMoveSelection,
    this.onSelectionEnd,
  }) {
    _initializeTools();
  }

  void _initializeTools() {
    _selectionUtils = SelectionUtils(
      width: width,
      height: height,
      size: () => Size(width.toDouble(), height.toDouble()),
      onSelectionChanged: onSelectionChanged,
      onMoveSelection: onMoveSelection,
      onSelectionEnd: (s) {},
      update: (callback) => callback(),
    );

    _shapeUtils = ShapeUtils(
      width: width,
      height: height,
    );

    _fillTool = FillTool();
    _pencilTool = PencilTool();
    _penTool = PenTool();
    _lineTool = LineTool();
    _rectangleTool = RectangleTool();
    _circleTool = OvalToolBresenham();
    _selectionTool = SelectionTool(_selectionUtils, _circleTool);
    _eyedropperTool = EyedropperTool(
      onColorPicked: (color) => onColorPicked?.call(color),
    );
  }

  Tool _getTool(PixelTool toolType) {
    switch (toolType) {
      case PixelTool.pencil:
        return _pencilTool;
      case PixelTool.pen:
        return _penTool;
      case PixelTool.line:
        return _lineTool;
      case PixelTool.rectangle:
        return _rectangleTool;
      case PixelTool.circle:
        return _circleTool;
      case PixelTool.fill:
        return _fillTool;
      case PixelTool.select:
        return _selectionTool;
      case PixelTool.eyedropper:
        return _eyedropperTool;
      default:
        return _pencilTool;
    }
  }

  void handleTap(PixelTool toolType, PixelDrawDetails details) {
    final tool = _getTool(toolType);
    tool.onStart(details);
  }

  void startDrawing(PixelTool toolType, PixelDrawDetails details) {
    final tool = _getTool(toolType);
    tool.onStart(details);
  }

  void continueDrawing(PixelTool toolType, PixelDrawDetails details) {
    final tool = _getTool(toolType);
    tool.onMove(details);
  }

  void endDrawing(PixelTool toolType, PixelDrawDetails details) {
    final tool = _getTool(toolType);
    tool.onEnd(details);
  }

  void handlePenTap(
    PixelDrawDetails details,
    PixelCanvasController controller, {
    VoidCallback? onPathClosed,
  }) {
    final position = details.position;
    final penPoints = List<Offset>.from(controller.penPoints);
    const closeThreshold = 10.0;

    if (penPoints.isNotEmpty) {
      final startPoint = penPoints[0];
      if ((position - startPoint).distance <= closeThreshold) {
        // Close the path
        penPoints.add(startPoint);
        _finalizePenPath(penPoints, details, controller);
        onPathClosed?.call();
      } else {
        // Add new point
        penPoints.add(position);
        controller.setPenPoints(penPoints);
      }
    } else {
      // Start new path
      penPoints.add(position);
      controller.setPenPoints(penPoints);
      controller.setDrawingPenPath(true);
    }
  }

  void handleSelectionStart(PixelDrawDetails details) {
    _selectionTool.onStart(details);
  }

  void handleSelectionEnd(PixelDrawDetails details) {
    _selectionTool.onEnd(details);
    onSelectionEnd?.call(_selectionTool.previewPoints);
  }

  void handleSelectionUpdate(PixelDrawDetails details) {
    _selectionTool.onMove(details);
  }

  void _finalizePenPath(
    List<Offset> penPoints,
    PixelDrawDetails details,
    PixelCanvasController controller, {
    bool close = true,
  }) {
    if (penPoints.length > 1) {
      final pixels = _shapeUtils.getPenPathPixels(
        penPoints,
        close: close,
        size: details.size,
      );

      final coloredPixels = pixels.map((point) {
        return PixelPoint(
          point.x,
          point.y,
          color: details.color.value,
        );
      }).toList();

      controller.setPreviewPixels(coloredPixels);
    }

    controller.setPenPoints([]);
    controller.setDrawingPenPath(false);
  }

  void closePenPath(PixelCanvasController controller, PixelDrawDetails details, {bool close = true}) {
    final penPoints = List<Offset>.from(controller.penPoints);
    if (penPoints.isNotEmpty && controller.isDrawingPenPath) {
      _finalizePenPath(penPoints, details, controller, close: close);
    }
  }

  /// Filter points based on current selection
  List<PixelPoint<int>> filterPointsBySelection(List<PixelPoint<int>> pixels) {
    if (_selectionUtils.selectionRect == null) return pixels;

    return pixels.where((point) {
      return _selectionUtils.inInSelectionBounds(point.x, point.y);
    }).toList();
  }

  /// Apply modifier effects to pixels
  List<PixelPoint<int>> applyModifier(
    PixelPoint<int> pixel,
    Modifier? modifier,
  ) {
    if (modifier == null) return [pixel];

    final modifiedPixels = modifier.apply(pixel, width, height);
    return [pixel] +
        modifiedPixels.where((point) {
          return point.x >= 0 &&
              point.x < width &&
              point.y >= 0 &&
              point.y < height &&
              _selectionUtils.inInSelectionBounds(point.x, point.y);
        }).toList();
  }

  /// Generate brush stroke pixels
  List<PixelPoint<int>> generateBrushStroke(
    Offset startPos,
    Offset endPos,
    int brushSize,
    Color color,
    Size canvasSize,
  ) {
    final pixelWidth = canvasSize.width / width;
    final pixelHeight = canvasSize.height / height;

    final startX = (startPos.dx / pixelWidth).floor();
    final startY = (startPos.dy / pixelHeight).floor();
    final endX = (endPos.dx / pixelWidth).floor();
    final endY = (endPos.dy / pixelHeight).floor();

    final List<PixelPoint<int>> pixels = [];
    final linePoints = _shapeUtils.getLinePoints(startX, startY, endX, endY);

    for (final point in linePoints) {
      final brushPixels = _shapeUtils.getBrushPixels(
        point.x,
        point.y,
        brushSize,
      );
      pixels.addAll(brushPixels.map((p) => PixelPoint(
            p.x,
            p.y,
            color: color.value,
          )));
    }

    return filterPointsBySelection(pixels);
  }

  /// Generate spray paint pixels
  List<PixelPoint<int>> generateSprayPixels(
    Offset position,
    int brushSize,
    int intensity,
    Color color,
    Size canvasSize,
  ) {
    final pixelWidth = canvasSize.width / width;
    final pixelHeight = canvasSize.height / height;

    final x = (position.dx / pixelWidth).floor();
    final y = (position.dy / pixelHeight).floor();

    final List<PixelPoint<int>> pixels = [];

    for (int i = 0; i < intensity; i++) {
      final offsetX = _random.nextInt(brushSize * 2) - brushSize;
      final offsetY = _random.nextInt(brushSize * 2) - brushSize;
      final px = x + offsetX;
      final py = y + offsetY;

      if (px >= 0 && px < width && py >= 0 && py < height) {
        pixels.add(PixelPoint(px, py, color: color.value));
      }
    }

    return filterPointsBySelection(pixels);
  }

  /// Generate shape preview pixels
  List<PixelPoint<int>> generateShapePreview(
    PixelTool tool,
    Offset startPos,
    Offset currentPos,
    Color color,
    Size canvasSize,
  ) {
    final pixelWidth = canvasSize.width / width;
    final pixelHeight = canvasSize.height / height;

    final startX = (startPos.dx / pixelWidth).floor();
    final startY = (startPos.dy / pixelHeight).floor();
    final currentX = (currentPos.dx / pixelWidth).floor();
    final currentY = (currentPos.dy / pixelHeight).floor();

    List<PixelPoint<int>> shapePixels = [];

    switch (tool) {
      case PixelTool.line:
        shapePixels = _shapeUtils.getLinePixels(startX, startY, currentX, currentY);
        break;
      case PixelTool.rectangle:
        shapePixels = _shapeUtils.getRectanglePixels(startX, startY, currentX, currentY);
        break;
      case PixelTool.circle:
        shapePixels = _shapeUtils.getCirclePixels(startX, startY, currentX, currentY);
        break;
      default:
        break;
    }

    return filterPointsBySelection(shapePixels
        .map((p) => PixelPoint(
              p.x,
              p.y,
              color: color.value,
            ))
        .toList());
  }
}
