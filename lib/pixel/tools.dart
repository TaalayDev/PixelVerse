import 'package:flutter/material.dart';

enum PixelTool {
  pencil,
  fill,
  eraser,
  line,
  rectangle,
  circle,
  select,
  eyedropper,
  brush,
  // mirror,
  gradient,
  rotate,
  pixelPerfectLine,
  sprayPaint,
  drag,
  contour,
  pen;

  MouseCursor get cursor {
    switch (this) {
      case PixelTool.pencil:
        return SystemMouseCursors.precise;
      case PixelTool.brush:
        return SystemMouseCursors.precise;
      case PixelTool.eraser:
        return SystemMouseCursors.precise;
      case PixelTool.fill:
        return SystemMouseCursors.click;
      case PixelTool.eyedropper:
        return SystemMouseCursors.precise;
      case PixelTool.select:
        return SystemMouseCursors.cell;
      case PixelTool.line:
      case PixelTool.rectangle:
      case PixelTool.circle:
        return SystemMouseCursors.cell;
      case PixelTool.gradient:
        return SystemMouseCursors.click;
      case PixelTool.sprayPaint:
        return SystemMouseCursors.precise;
      case PixelTool.drag:
        return SystemMouseCursors.grab;
      default:
        return SystemMouseCursors.basic;
    }
  }
}

enum PixelModifier {
  none,
  mirror;

  bool get isNone => this == PixelModifier.none;
  bool get isMirror => this == PixelModifier.mirror;
}

enum MirrorAxis { horizontal, vertical, both }
