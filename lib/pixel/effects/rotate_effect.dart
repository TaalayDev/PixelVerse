part of 'effects.dart';

/// Effect that creates smooth rotation animation around a center point
class RotateEffect extends Effect {
  RotateEffect([Map<String, dynamic>? parameters])
      : super(
          EffectType.rotate,
          parameters ??
              const {
                'speed': 0.5, // Rotation speed (0-1)
                'direction': 1, // 1 = clockwise, -1 = counterclockwise
                'centerX': 0.5, // Rotation center X (0-1)
                'centerY': 0.5, // Rotation center Y (0-1)
                'interpolation': 1, // 0 = nearest, 1 = bilinear
                'backgroundMode': 0, // 0 = transparent, 1 = repeat, 2 = mirror
                'zoom': 1.0, // Scale factor during rotation (0.5-2.0)
                'time': 0.0, // Animation time parameter (0-1)
              },
        );

  @override
  Map<String, dynamic> getDefaultParameters() {
    return {
      'speed': 0.5,
      'direction': 1,
      'centerX': 0.5,
      'centerY': 0.5,
      'interpolation': 1,
      'backgroundMode': 0,
      'zoom': 1.0,
      'time': 0.0,
    };
  }

  @override
  Map<String, dynamic> getMetadata() {
    return {
      'speed': {
        'label': 'Rotation Speed',
        'description': 'How fast the image rotates.',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
      'direction': {
        'label': 'Direction',
        'description': 'Rotation direction.',
        'type': 'select',
        'options': {
          1: 'Clockwise',
          -1: 'Counter-clockwise',
        },
      },
      'centerX': {
        'label': 'Center X',
        'description': 'Horizontal center of rotation (0 = left, 1 = right).',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
      'centerY': {
        'label': 'Center Y',
        'description': 'Vertical center of rotation (0 = top, 1 = bottom).',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
      'interpolation': {
        'label': 'Interpolation',
        'description': 'Pixel sampling method for smoother rotation.',
        'type': 'select',
        'options': {
          0: 'Nearest (Pixelated)',
          1: 'Bilinear (Smooth)',
        },
      },
      'backgroundMode': {
        'label': 'Background Mode',
        'description': 'How to handle areas outside the original image.',
        'type': 'select',
        'options': {
          0: 'Transparent',
          1: 'Repeat Pattern',
          2: 'Mirror',
        },
      },
      'zoom': {
        'label': 'Zoom Level',
        'description': 'Scale factor applied during rotation.',
        'type': 'slider',
        'min': 0.5,
        'max': 2.0,
        'divisions': 100,
      },
    };
  }

  @override
  Uint32List apply(Uint32List pixels, int width, int height) {
    final speed = parameters['speed'] as double;
    final direction = parameters['direction'] as int;
    final centerX = parameters['centerX'] as double;
    final centerY = parameters['centerY'] as double;
    final interpolation = parameters['interpolation'] as int;
    final backgroundMode = parameters['backgroundMode'] as int;
    final zoom = parameters['zoom'] as double;
    final time = parameters['time'] as double;

    final result = Uint32List(pixels.length);

    // Calculate current rotation angle
    final animTime = time * speed * direction * 2 * pi;
    final cosAngle = cos(animTime);
    final sinAngle = sin(animTime);

    // Calculate rotation center in pixels
    final rotCenterX = centerX * width;
    final rotCenterY = centerY * height;

    // Apply zoom factor
    final scaledZoom = 1.0 / zoom; // Inverse for sampling

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final destIndex = y * width + x;

        // Translate to center, apply rotation and zoom, then translate back
        final dx = (x - rotCenterX) * scaledZoom;
        final dy = (y - rotCenterY) * scaledZoom;

        // Apply reverse rotation to find source pixel
        final sourceX = rotCenterX + dx * cosAngle + dy * sinAngle;
        final sourceY = rotCenterY - dx * sinAngle + dy * cosAngle;

        // Sample pixel based on interpolation mode
        if (interpolation == 0) {
          // Nearest neighbor (pixelated)
          result[destIndex] = _sampleNearest(pixels, width, height, sourceX, sourceY, backgroundMode);
        } else {
          // Bilinear interpolation (smooth)
          result[destIndex] = _sampleBilinear(pixels, width, height, sourceX, sourceY, backgroundMode);
        }
      }
    }

    return result;
  }

  /// Sample using nearest neighbor interpolation
  int _sampleNearest(Uint32List pixels, int width, int height, double x, double y, int backgroundMode) {
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
  int _sampleBilinear(Uint32List pixels, int width, int height, double x, double y, int backgroundMode) {
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
  int _getPixelAt(Uint32List pixels, int width, int height, int x, int y, int backgroundMode) {
    final (sampX, sampY) = _handleBounds(x, y, width, height, backgroundMode);

    if (sampX == -1 || sampY == -1) {
      return 0; // Transparent
    }

    final index = sampY * width + sampX;
    return index < pixels.length ? pixels[index] : 0;
  }

  /// Handle boundary conditions based on background mode
  (int, int) _handleBounds(int x, int y, int width, int height, int backgroundMode) {
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
  int _interpolatePixels(int pixel00, int pixel10, int pixel01, int pixel11, double wx, double wy) {
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
    final a = _lerp2D(a00, a10, a01, a11, wx, wy).round().clamp(0, 255);
    final r = _lerp2D(r00, r10, r01, r11, wx, wy).round().clamp(0, 255);
    final g = _lerp2D(g00, g10, g01, g11, wx, wy).round().clamp(0, 255);
    final b = _lerp2D(b00, b10, b01, b11, wx, wy).round().clamp(0, 255);

    return (a << 24) | (r << 16) | (g << 8) | b;
  }

  /// 2D linear interpolation helper
  double _lerp2D(int v00, int v10, int v01, int v11, double wx, double wy) {
    // Interpolate along X axis
    final v0 = v00 * (1 - wx) + v10 * wx;
    final v1 = v01 * (1 - wx) + v11 * wx;

    // Interpolate along Y axis
    return v0 * (1 - wy) + v1 * wy;
  }
}
