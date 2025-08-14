import 'dart:ui';

import 'package:flutter/material.dart';

import '../pixel_point.dart';
import '../tools.dart';

class LassoTool extends Tool {
  LassoTool() : super(PixelTool.lasso);

  List<Offset> _points = [];
  List<PixelPoint<int>> _selectedPixels = [];
  bool _isDrawing = false;
  static const _closeThreshold = 10.0;

  @override
  void onStart(PixelDrawDetails details) {
    if (!_isDrawing) {
      _points = [details.position];
      _isDrawing = true;
      _selectedPixels.clear();
    }
  }

  @override
  void onMove(PixelDrawDetails details) {
    if (_isDrawing) {
      final startPoint = _points.first;
      if ((details.position - startPoint).distance <= _closeThreshold && _points.length > 2) {
        // Close the path if near the start point
        _points.add(startPoint);
        _finalizeLasso(details);
      } else {
        _points.add(details.position);
      }
    }
  }

  @override
  void onEnd(PixelDrawDetails details) {
    if (_isDrawing) {
      _finalizeLasso(details);
    }
  }

  void _finalizeLasso(PixelDrawDetails details) {
    _isDrawing = false;
    if (_points.length < 3) {
      _points.clear();
      return;
    }

    // Convert lasso points to pixel coordinates
    final path = Path();
    path.moveTo(_points.first.dx, _points.first.dy);

    for (int i = 1; i < _points.length; i++) {
      path.lineTo(_points[i].dx, _points[i].dy);
    }
    path.close();

    // Find pixels inside the lasso path
    final pixelWidth = details.size.width / details.width;
    final pixelHeight = details.size.height / details.height;

    for (int y = 0; y < details.height; y++) {
      for (int x = 0; x < details.width; x++) {
        final pixelCenter = Offset(
          (x + 0.5) * pixelWidth,
          (y + 0.5) * pixelHeight,
        );

        if (path.contains(pixelCenter)) {
          _selectedPixels.add(PixelPoint(
            x,
            y,
            color: details.currentLayer.pixels[y * details.width + x],
          ));
        }
      }
    }

    // Update selected pixels
    details.onPixelsUpdated(_selectedPixels);
  }

  List<Offset> get previewPoints => _points;
  bool get isDrawing => _isDrawing;
}
