import 'dart:typed_data';

import 'package:flutter/material.dart';

class PixelPreviewPainter extends CustomPainter {
  final Uint32List pixels;
  final int width;
  final int height;

  PixelPreviewPainter({
    required this.pixels,
    required this.width,
    required this.height,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Create a checkerboard background for transparent areas
    final checkerPaint1 = Paint()..color = Colors.grey.shade200;
    final checkerPaint2 = Paint()..color = Colors.grey.shade100;

    final checkerSize = size.width / 10;
    for (int y = 0; y < 10; y++) {
      for (int x = 0; x < 10; x++) {
        canvas.drawRect(
          Rect.fromLTWH(
            x * checkerSize,
            y * checkerSize,
            checkerSize,
            checkerSize,
          ),
          (x + y) % 2 == 0 ? checkerPaint1 : checkerPaint2,
        );
      }
    }

    // Draw the pixels
    final paint = Paint()..style = PaintingStyle.fill;
    final pixelWidth = size.width / width;
    final pixelHeight = size.height / height;

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final index = y * width + x;
        if (index < pixels.length) {
          final color = Color(pixels[index]);
          if (color.alpha == 0) continue;

          paint.color = color;
          canvas.drawRect(
            Rect.fromLTWH(
              x * pixelWidth,
              y * pixelHeight,
              pixelWidth,
              pixelHeight,
            ),
            paint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant PixelPreviewPainter oldDelegate) {
    return oldDelegate.pixels != pixels;
  }
}
