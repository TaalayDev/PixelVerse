import 'dart:ui' as ui;
import 'dart:ui';

import 'package:flutter/material.dart';

import '../../data.dart';
import '../pixel_point.dart';
import '../tools.dart';
import 'canvas_controller.dart';
import 'layer_cache_manager.dart';

/// Custom painter for rendering the pixel canvas
class PixelCanvasPainter extends CustomPainter {
  final int width;
  final int height;
  final PixelCanvasController controller;
  final LayerCacheManager cacheManager;
  final PixelTool currentTool;
  final Color currentColor;

  PixelCanvasPainter({
    required this.width,
    required this.height,
    required this.controller,
    required this.cacheManager,
    required this.currentTool,
    required this.currentColor,
  }) : super(repaint: Listenable.merge([controller, cacheManager]));

  @override
  void paint(Canvas canvas, Size size) {
    canvas.saveLayer(Offset.zero & size, Paint());

    final pixelWidth = size.width / width;
    final pixelHeight = size.height / height;

    // Draw grid background
    _drawGrid(canvas, size, pixelWidth, pixelHeight);

    // Draw layers
    _drawLayers(canvas, size, pixelWidth, pixelHeight);

    // Draw UI overlays
    // _drawSelectionRect(canvas, pixelWidth, pixelHeight);
    _drawGradient(canvas, size);
    _drawPenPath(canvas);

    // if (controller.selectionPoints.isNotEmpty) {
    //   _drawSelectionOverlay(canvas, size, pixelWidth, pixelHeight);
    // }

    if (controller.previewPixels.isEmpty) {
      _drawHoverPreview(canvas, size, pixelWidth, pixelHeight);
    }

    canvas.restore();
  }

  void _drawGrid(Canvas canvas, Size size, double pixelWidth, double pixelHeight) {
    final paint = Paint()
      ..color = Colors.grey.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5 / controller.zoomLevel;

    // Vertical lines
    for (int x = 0; x <= width; x++) {
      canvas.drawLine(
        Offset(x * pixelWidth, 0),
        Offset(x * pixelWidth, size.height),
        paint,
      );
    }

    // Horizontal lines
    for (int y = 0; y <= height; y++) {
      canvas.drawLine(
        Offset(0, y * pixelHeight),
        Offset(size.width, y * pixelHeight),
        paint,
      );
    }
  }

  void _drawLayers(Canvas canvas, Size size, double pixelWidth, double pixelHeight) {
    final canvasRect = Offset.zero & size;

    for (int i = 0; i < controller.layers.length; i++) {
      final layer = controller.layers[i];

      if (!layer.isVisible) continue;

      canvas.saveLayer(canvasRect, Paint());

      final cachedImage = cacheManager.getLayerImage(layer.layerId);

      if (cachedImage != null) {
        _drawCachedLayer(canvas, cachedImage, canvasRect);
      } else {
        _drawLayerPixels(canvas, layer, pixelWidth, pixelHeight);
      }

      if (i == controller.currentLayerIndex) {
        _drawPreviewPixels(canvas, size, pixelWidth, pixelHeight);
      }

      canvas.restore();
    }
  }

  void _drawCachedLayer(Canvas canvas, ui.Image image, Rect canvasRect) {
    final imageRect = Rect.fromLTWH(
      0,
      0,
      image.width.toDouble(),
      image.height.toDouble(),
    );

    canvas.drawImageRect(
      image,
      imageRect,
      canvasRect,
      Paint(),
    );
  }

  void _drawLayerPixels(Canvas canvas, Layer layer, double pixelWidth, double pixelHeight) {
    final paint = Paint()..style = PaintingStyle.fill;
    final processedPixels = layer.processedPixels;

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final index = y * width + x;
        if (index >= processedPixels.length) continue;

        final color = Color(processedPixels[index]);
        if (color.alpha == 0) continue;

        final rect = Rect.fromLTWH(
          x * pixelWidth,
          y * pixelHeight,
          pixelWidth,
          pixelHeight,
        );

        canvas.drawRect(rect, paint..color = color);
      }
    }
  }

  void _drawPreviewPixels(Canvas canvas, Size size, double pixelWidth, double pixelHeight) {
    if (controller.processedPreviewPixels.isNotEmpty && currentTool != PixelTool.eraser) {
      return _drawProcessedPreviewPixels(canvas, size, pixelWidth, pixelHeight);
    }

    final previewPixels = controller.previewPixels;
    if (previewPixels.isEmpty) return;

    _drawPixelsAsVertices(canvas, previewPixels, pixelWidth, pixelHeight);
  }

  void _drawProcessedPreviewPixels(Canvas canvas, Size size, double pixelWidth, double pixelHeight) {
    final processedPixels = controller.processedPreviewPixels;
    if (processedPixels.isEmpty) return;

    final List<Offset> positions = [];
    final List<Color> colors = [];
    final List<int> indices = [];
    int vertexIndex = 0;

    final isErasing = controller.currentTool == PixelTool.eraser;

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final index = y * width + x;
        if (index >= processedPixels.length) continue;

        final color = Color(processedPixels[index]);
        if (!isErasing && color.alpha == 0) continue;

        final left = x * pixelWidth;
        final top = y * pixelHeight;
        final right = left + pixelWidth;
        final bottom = top + pixelHeight;

        // Quad vertices
        positions.addAll([
          Offset(left, top),
          Offset(right, top),
          Offset(right, bottom),
          Offset(left, bottom),
        ]);

        // Colors for each vertex
        colors.addAll([color, color, color, color]);

        // Triangle indices for the quad
        indices.addAll([
          vertexIndex,
          vertexIndex + 1,
          vertexIndex + 2,
          vertexIndex,
          vertexIndex + 2,
          vertexIndex + 3,
        ]);

        vertexIndex += 4;
      }
    }

    if (positions.isNotEmpty) {
      final vertices = Vertices(
        VertexMode.triangles,
        positions,
        colors: colors,
        indices: indices,
      );

      final blendMode = isErasing ? BlendMode.clear : BlendMode.srcOver;
      canvas.drawVertices(vertices, blendMode, Paint()..blendMode = blendMode);
    }
  }

  void _drawSelectionOverlay(
    Canvas canvas,
    Size size,
    double pixelWidth,
    double pixelHeight,
  ) {
    final selectionPoints = controller.selectionPoints;
    if (selectionPoints.isEmpty) return;

    final paint = Paint()
      ..color = Colors.blue.withOpacity(0.5)
      ..style = PaintingStyle.fill;

    for (final point in selectionPoints) {
      final left = point.x * pixelWidth;
      final top = point.y * pixelHeight;
      final right = left + pixelWidth;
      final bottom = top + pixelHeight;

      canvas.drawRect(Rect.fromLTRB(left, top, right, bottom), paint);
    }
  }

  void _drawPixelsAsVertices(
    Canvas canvas,
    List<PixelPoint<int>> pixels,
    double pixelWidth,
    double pixelHeight,
  ) {
    final List<Offset> positions = [];
    final List<Color> colors = [];
    final List<int> indices = [];
    int vertexIndex = 0;

    final isErasing = controller.currentTool == PixelTool.eraser;

    for (final point in pixels) {
      final color = Color(point.color);
      if (!isErasing && color.alpha == 0) {
        continue;
      }

      final left = point.x * pixelWidth;
      final top = point.y * pixelHeight;
      final right = left + pixelWidth;
      final bottom = top + pixelHeight;

      // Quad vertices
      positions.addAll([
        Offset(left, top),
        Offset(right, top),
        Offset(right, bottom),
        Offset(left, bottom),
      ]);

      // Colors for each vertex
      colors.addAll([color, color, color, color]);

      // Triangle indices for the quad
      indices.addAll([
        vertexIndex,
        vertexIndex + 1,
        vertexIndex + 2,
        vertexIndex,
        vertexIndex + 2,
        vertexIndex + 3,
      ]);

      vertexIndex += 4;
    }

    if (positions.isNotEmpty) {
      final vertices = Vertices(
        VertexMode.triangles,
        positions,
        colors: colors,
        indices: indices,
      );

      final blendMode = isErasing ? BlendMode.clear : BlendMode.srcOver;
      canvas.drawVertices(vertices, blendMode, Paint()..blendMode = blendMode);
    }
  }

  void _drawHoverPreview(Canvas canvas, Size size, double pixelWidth, double pixelHeight) {
    final hoverPixels = controller.hoverPreviewPixels;
    if (hoverPixels.isEmpty) return;

    final List<Offset> positions = [];
    final List<Color> colors = [];
    final List<int> indices = [];
    int vertexIndex = 0;

    final isErasing = controller.currentTool == PixelTool.eraser;

    for (final point in hoverPixels) {
      final baseColor = Color(point.color);

      // Make hover preview semi-transparent and slightly different
      final Color hoverColor;
      if (isErasing) {
        // For eraser, show red semi-transparent preview
        hoverColor = Colors.red.withOpacity(0.4);
      } else {
        // For other tools, show the color with reduced opacity
        hoverColor = baseColor.withOpacity(0.6);
      }

      final left = point.x * pixelWidth;
      final top = point.y * pixelHeight;
      final right = left + pixelWidth;
      final bottom = top + pixelHeight;

      // Quad vertices
      positions.addAll([
        Offset(left, top),
        Offset(right, top),
        Offset(right, bottom),
        Offset(left, bottom),
      ]);

      // Colors for each vertex
      colors.addAll([hoverColor, hoverColor, hoverColor, hoverColor]);

      // Triangle indices for the quad
      indices.addAll([
        vertexIndex,
        vertexIndex + 1,
        vertexIndex + 2,
        vertexIndex,
        vertexIndex + 2,
        vertexIndex + 3,
      ]);

      vertexIndex += 4;
    }

    if (positions.isNotEmpty) {
      final vertices = Vertices(
        VertexMode.triangles,
        positions,
        colors: colors,
        indices: indices,
      );

      // Draw hover preview with blend mode that shows on top
      canvas.drawVertices(vertices, BlendMode.srcOver, Paint());

      // Add a subtle border for better visibility
      _drawHoverBorder(canvas, hoverPixels, pixelWidth, pixelHeight);
    }
  }

  void _drawHoverBorder(Canvas canvas, List<PixelPoint<int>> hoverPixels, double pixelWidth, double pixelHeight) {
    if (hoverPixels.isEmpty) return;

    final borderPaint = Paint()
      ..color = Colors.white.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0 / controller.zoomLevel;

    // Find the bounding box of hover pixels
    int minX = hoverPixels.first.x;
    int maxX = hoverPixels.first.x;
    int minY = hoverPixels.first.y;
    int maxY = hoverPixels.first.y;

    for (final pixel in hoverPixels) {
      minX = minX < pixel.x ? minX : pixel.x;
      maxX = maxX > pixel.x ? maxX : pixel.x;
      minY = minY < pixel.y ? minY : pixel.y;
      maxY = maxY > pixel.y ? maxY : pixel.y;
    }

    // Draw border around the hover area
    final rect = Rect.fromLTWH(
      minX * pixelWidth,
      minY * pixelHeight,
      (maxX - minX + 1) * pixelWidth,
      (maxY - minY + 1) * pixelHeight,
    );

    canvas.drawRect(rect, borderPaint);
  }

  void _drawGradient(Canvas canvas, Size size) {
    final gradientStart = controller.gradientStart;
    final gradientEnd = controller.gradientEnd;

    if (gradientStart == null || gradientEnd == null) return;

    final gradientPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment(
          gradientStart.dx / size.width,
          gradientStart.dy / size.height,
        ),
        end: Alignment(
          gradientEnd.dx / size.width,
          gradientEnd.dy / size.height,
        ),
        colors: [Colors.black, Colors.transparent],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      gradientPaint,
    );
  }

  void _drawPenPath(Canvas canvas) {
    final penPoints = controller.penPoints;
    if (!controller.isDrawingPenPath || penPoints.isEmpty) return;

    final penPaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5 / controller.zoomLevel;

    final path = Path();

    if (penPoints.length == 1) {
      // Single point - draw a circle
      canvas.drawCircle(
        penPoints.first,
        2.0 / controller.zoomLevel,
        penPaint..style = PaintingStyle.fill,
      );
    } else {
      // Multiple points - draw connected lines
      path.moveTo(penPoints.first.dx, penPoints.first.dy);
      for (int i = 1; i < penPoints.length; i++) {
        path.lineTo(penPoints[i].dx, penPoints[i].dy);
      }

      canvas.drawPath(path, penPaint);

      // Show closing indicator if near start point
      if (penPoints.length > 2 && (penPoints.last - penPoints.first).distance <= 15) {
        final dashPaint = Paint()
          ..color = Colors.green
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5 / controller.zoomLevel;

        canvas.drawLine(penPoints.last, penPoints.first, dashPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant PixelCanvasPainter oldDelegate) {
    return oldDelegate.controller != controller ||
        oldDelegate.cacheManager != cacheManager ||
        oldDelegate.width != width ||
        oldDelegate.height != height ||
        oldDelegate.currentTool != currentTool ||
        oldDelegate.currentColor != currentColor;
  }
}
