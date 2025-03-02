import 'package:flutter/material.dart';
import '../tools.dart';

/// Tool for picking colors from the canvas
class EyedropperTool extends Tool {
  final Function(Color) onColorPicked;

  EyedropperTool({required this.onColorPicked}) : super(PixelTool.eyedropper);

  @override
  void onStart(PixelDrawDetails details) {
    _pickColor(details);
  }

  @override
  void onMove(PixelDrawDetails details) {
    _pickColor(details);
  }

  @override
  void onEnd(PixelDrawDetails details) {
    // Nothing to do on end
  }

  void _pickColor(PixelDrawDetails details) {
    final x = details.pixelPosition.x;
    final y = details.pixelPosition.y;

    if (x >= 0 && x < details.width && y >= 0 && y < details.height) {
      final pixelIndex = y * details.width + x;

      if (pixelIndex >= 0 && pixelIndex < details.currentLayer.pixels.length) {
        final colorValue = details.currentLayer.pixels[pixelIndex];
        if (colorValue != 0) {
          onColorPicked(Color(colorValue));
        }
      }
    }
  }
}
