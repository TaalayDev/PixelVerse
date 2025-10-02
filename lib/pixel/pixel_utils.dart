import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../data/models/layer.dart';

abstract final class PixelUtils {
  static Uint32List mergeLayersPixels({
    required int width,
    required int height,
    required List<Layer> layers,
  }) {
    final pixels = Uint32List(width * height);
    final layersPixels = layers.reversed
        .where((l) => l.isVisible && l.opacity > 0)
        .map(
          (l) => (pixels: l.processedPixels, opacity: l.opacity),
        )
        .toList();

    for (final item in layersPixels) {
      final processedPixels = item.pixels;
      final opacity = item.opacity;
      for (int i = 0; i < pixels.length; i++) {
        pixels[i] = pixels[i] == 0 ? applyAlpha(processedPixels[i], opacity) : pixels[i];
      }
    }
    return pixels;
  }

  static int applyAlpha(int color, double alpha) {
    if (color == 0 || alpha >= 1.0) return color;
    if (alpha <= 0.0) return 0;

    final a = ((color >> 24) & 0xFF);
    final r = ((color >> 16) & 0xFF);
    final g = ((color >> 8) & 0xFF);
    final b = (color & 0xFF);

    final newA = (a * alpha).round().clamp(0, 255);
    final newR = (r * alpha).round().clamp(0, 255);
    final newG = (g * alpha).round().clamp(0, 255);
    final newB = (b * alpha).round().clamp(0, 255);

    return (newA << 24) | (newR << 16) | (newG << 8) | newB;
  }

  /// Applies scale transformation to the image pixels.
  static Uint32List applyScale(
    Uint32List pixels,
    int width,
    int height,
    double scale,
    double centerX,
    double centerY,
    int interpolation,
    int backgroundMode,
  ) {
    final result = Uint32List(pixels.length);
    final invScale = 1.0 / scale;

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final destIndex = y * width + x;
        final dx = (x - centerX);
        final dy = (y - centerY);
        final sourceX = centerX + dx * invScale;
        final sourceY = centerY + dy * invScale;

        if (interpolation == 0) {
          result[destIndex] = _sampleNearest(pixels, width, height, sourceX, sourceY, backgroundMode);
        } else {
          result[destIndex] = _sampleBilinear(pixels, width, height, sourceX, sourceY, backgroundMode);
        }
      }
    }

    return result;
  }

  /// Applies rotation transformation to the image pixels.
  static Uint32List applyRotation(
    Uint32List pixels,
    int width,
    int height,
    double angle,
    double centerX,
    double centerY,
    double zoom,
    int interpolation,
    int backgroundMode,
  ) {
    final result = Uint32List(pixels.length);

    final cosAngle = math.cos(angle);
    final sinAngle = math.sin(angle);

    final invZoom = 1.0 / zoom;

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final destIndex = y * width + x;

        final dx = (x - centerX) * invZoom;
        final dy = (y - centerY) * invZoom;

        final sourceX = centerX + dx * cosAngle - dy * sinAngle;
        final sourceY = centerY + dx * sinAngle + dy * cosAngle;

        if (interpolation == 0) {
          result[destIndex] = _sampleNearest(pixels, width, height, sourceX, sourceY, backgroundMode);
        } else {
          result[destIndex] = _sampleBilinear(pixels, width, height, sourceX, sourceY, backgroundMode);
        }
      }
    }

    return result;
  }

  /// Sample using nearest neighbor interpolation
  static int _sampleNearest(Uint32List pixels, int width, int height, double x, double y, int backgroundMode) {
    final intX = x.round();
    final intY = y.round();

    // Handle out-of-bounds sampling based on background mode
    final (sampX, sampY) = _handleBounds(intX, intY, width, height, backgroundMode);

    if (sampX == -1 || sampY == -1) {
      return 0; // Transparent
    }

    final index = sampY * width + sampX;
    return index < pixels.length ? pixels[index] : 0;
  }

  /// Sample using bilinear interpolation for smoother results
  static int _sampleBilinear(Uint32List pixels, int width, int height, double x, double y, int backgroundMode) {
    // Get the four surrounding pixels
    final x0 = x.floor();
    final y0 = y.floor();
    final x1 = x0 + 1;
    final y1 = y0 + 1;

    // Calculate interpolation weights
    final wx = x - x0;
    final wy = y - y0;

    // Sample the four corners
    final pixel00 = _getPixelAt(pixels, width, height, x0, y0, backgroundMode);
    final pixel10 = _getPixelAt(pixels, width, height, x1, y0, backgroundMode);
    final pixel01 = _getPixelAt(pixels, width, height, x0, y1, backgroundMode);
    final pixel11 = _getPixelAt(pixels, width, height, x1, y1, backgroundMode);

    // Perform bilinear interpolation for each channel
    return _interpolatePixels(pixel00, pixel10, pixel01, pixel11, wx, wy);
  }

  /// Get pixel at specific coordinates with boundary handling
  static int _getPixelAt(Uint32List pixels, int width, int height, int x, int y, int backgroundMode) {
    final (sampX, sampY) = _handleBounds(x, y, width, height, backgroundMode);

    if (sampX == -1 || sampY == -1) {
      return 0; // Transparent
    }

    final index = sampY * width + sampX;
    return index < pixels.length ? pixels[index] : 0;
  }

  /// Handle boundary conditions based on background mode
  static (int, int) _handleBounds(int x, int y, int width, int height, int backgroundMode) {
    switch (backgroundMode) {
      case 0: // Transparent
        if (x < 0 || x >= width || y < 0 || y >= height) {
          return (-1, -1);
        }
        return (x, y);

      case 1: // Repeat
        final wrappedX = x % width;
        final wrappedY = y % height;
        return (wrappedX < 0 ? wrappedX + width : wrappedX, wrappedY < 0 ? wrappedY + height : wrappedY);

      case 2: // Mirror
        int mirrorX = x;
        int mirrorY = y;

        // Mirror X
        if (mirrorX < 0) {
          mirrorX = -mirrorX - 1;
        } else if (mirrorX >= width) {
          mirrorX = 2 * width - mirrorX - 1;
        }
        mirrorX = mirrorX.clamp(0, width - 1);

        // Mirror Y
        if (mirrorY < 0) {
          mirrorY = -mirrorY - 1;
        } else if (mirrorY >= height) {
          mirrorY = 2 * height - mirrorY - 1;
        }
        mirrorY = mirrorY.clamp(0, height - 1);

        return (mirrorX, mirrorY);

      default:
        return (x.clamp(0, width - 1), y.clamp(0, height - 1));
    }
  }

  /// Perform bilinear interpolation between four pixels
  static int _interpolatePixels(int pixel00, int pixel10, int pixel01, int pixel11, double wx, double wy) {
    // Extract ARGB components for each pixel
    final a00 = (pixel00 >> 24) & 0xFF;
    final r00 = (pixel00 >> 16) & 0xFF;
    final g00 = (pixel00 >> 8) & 0xFF;
    final b00 = pixel00 & 0xFF;

    final a10 = (pixel10 >> 24) & 0xFF;
    final r10 = (pixel10 >> 16) & 0xFF;
    final g10 = (pixel10 >> 8) & 0xFF;
    final b10 = pixel10 & 0xFF;

    final a01 = (pixel01 >> 24) & 0xFF;
    final r01 = (pixel01 >> 16) & 0xFF;
    final g01 = (pixel01 >> 8) & 0xFF;
    final b01 = pixel01 & 0xFF;

    final a11 = (pixel11 >> 24) & 0xFF;
    final r11 = (pixel11 >> 16) & 0xFF;
    final g11 = (pixel11 >> 8) & 0xFF;
    final b11 = pixel11 & 0xFF;

    // Interpolate each channel
    final a = _lerp2D(a00.toDouble(), a10.toDouble(), a01.toDouble(), a11.toDouble(), wx, wy).round().clamp(0, 255);
    final r = _lerp2D(r00.toDouble(), r10.toDouble(), r01.toDouble(), r11.toDouble(), wx, wy).round().clamp(0, 255);
    final g = _lerp2D(g00.toDouble(), g10.toDouble(), g01.toDouble(), g11.toDouble(), wx, wy).round().clamp(0, 255);
    final b = _lerp2D(b00.toDouble(), b10.toDouble(), b01.toDouble(), b11.toDouble(), wx, wy).round().clamp(0, 255);

    return (a << 24) | (r << 16) | (g << 8) | b;
  }

  /// 2D linear interpolation helper
  static double _lerp2D(double v00, double v10, double v01, double v11, double wx, double wy) {
    // Interpolate along X axis
    final v0 = v00 * (1 - wx) + v10 * wx;
    final v1 = v01 * (1 - wx) + v11 * wx;

    // Interpolate along Y axis
    return v0 * (1 - wy) + v1 * wy;
  }

  static Uint32List resize(
    Uint32List pixels,
    int srcWidth,
    int srcHeight,
    int targetWidth,
    int targetHeight,
    int interpolation,
    int backgroundMode,
  ) {
    if (targetWidth <= 0 || targetHeight <= 0) return Uint32List(0);

    final result = Uint32List(targetWidth * targetHeight);

    final scaleX = srcWidth / targetWidth.toDouble();
    final scaleY = srcHeight / targetHeight.toDouble();

    for (int y = 0; y < targetHeight; y++) {
      for (int x = 0; x < targetWidth; x++) {
        final sourceX = x * scaleX;
        final sourceY = y * scaleY;

        final color = interpolation == 0
            ? _sampleNearest(pixels, srcWidth, srcHeight, sourceX, sourceY, backgroundMode)
            : _sampleBilinear(pixels, srcWidth, srcHeight, sourceX, sourceY, backgroundMode);

        result[y * targetWidth + x] = color;
      }
    }

    return result;
  }

  static Uint32List applyRotationWithBounds(
    Uint32List pixels,
    int srcWidth,
    int srcHeight,
    double angle,
    Rect originalBounds,
    Rect rotatedBounds,
    Offset center,
    int interpolation,
    int backgroundMode,
  ) {
    final targetWidth = rotatedBounds.width.round();
    final targetHeight = rotatedBounds.height.round();
    if (targetWidth <= 0 || targetHeight <= 0) return Uint32List(0);

    final result = Uint32List(targetWidth * targetHeight);

    final cosAngle = math.cos(angle);
    final sinAngle = math.sin(angle);

    for (int y = 0; y < targetHeight; y++) {
      for (int x = 0; x < targetWidth; x++) {
        final worldDestX = rotatedBounds.left + x;
        final worldDestY = rotatedBounds.top + y;

        final dx = worldDestX - center.dx;
        final dy = worldDestY - center.dy;

        final sourceWorldX = center.dx + dx * cosAngle - dy * sinAngle;
        final sourceWorldY = center.dy + dx * sinAngle + dy * cosAngle;

        final sourceX = sourceWorldX - originalBounds.left;
        final sourceY = sourceWorldY - originalBounds.top;

        final color = interpolation == 0
            ? _sampleNearest(pixels, srcWidth, srcHeight, sourceX, sourceY, backgroundMode)
            : _sampleBilinear(pixels, srcWidth, srcHeight, sourceX, sourceY, backgroundMode);

        result[y * targetWidth + x] = color;
      }
    }

    return result;
  }
}
