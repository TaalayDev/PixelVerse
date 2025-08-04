part of 'effects.dart';

/// Effect that creates a soft glow around bright areas of the image
class GlowEffect extends Effect {
  GlowEffect([Map<String, dynamic>? parameters])
      : super(
          EffectType.glow,
          parameters ??
              const {
                'radius': 0.5, // Glow radius
                'intensity': 0.6, // Glow intensity
                'threshold': 0.6, // Brightness threshold to glow
                'color': 0, // 0 = original, 1 = white
              },
        );

  @override
  Map<String, dynamic> getDefaultParameters() {
    return {
      'radius': 0.5, // Radius of the glow (0-1)
      'intensity': 0.6, // Intensity of the glow effect (0-1)
      'threshold': 0.6, // Brightness threshold to determine what glows (0-1)
      'color': 0, // Glow color mode (0 = original color, 1 = white)
    };
  }

  @override
  Map<String, dynamic> getMetadata() {
    return {
      'radius': {
        'label': 'Glow Radius',
        'description': 'Controls the radius of the glow effect.',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
      'intensity': {
        'label': 'Glow Intensity',
        'description': 'Controls the intensity of the glow effect.',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
      'threshold': {
        'label': 'Brightness Threshold',
        'description': 'Controls the brightness threshold for the glow effect.',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
      'color': {
        'label': 'Glow Color',
        'description': 'Controls the color of the glow effect.',
        'type': 'slider',
        'min': 0,
        'max': 1,
        'divisions': 100,
      },
    };
  }

  @override
  Uint32List apply(Uint32List pixels, int width, int height) {
    // Get parameters
    final radiusFactor = parameters['radius'] as double;
    final intensity = parameters['intensity'] as double;
    final threshold = parameters['threshold'] as double;
    final colorMode = (parameters['color'] as int).clamp(0, 1);

    // Calculate actual radius based on image size
    final maxSize = max(width, height);
    final radius = (radiusFactor * maxSize * 0.1).round().clamp(1, 10);

    // Create source and result buffers
    final source = Uint32List.fromList(pixels);
    final result = Uint32List.fromList(pixels);

    // Create a buffer for the glow/bloom
    final glowBuffer = Uint32List(width * height);

    // Step 1: Extract bright pixels above threshold to the glow buffer
    for (int i = 0; i < source.length; i++) {
      final pixel = source[i];
      final a = (pixel >> 24) & 0xFF;

      // Skip transparent pixels
      if (a == 0) continue;

      final r = (pixel >> 16) & 0xFF;
      final g = (pixel >> 8) & 0xFF;
      final b = pixel & 0xFF;

      // Calculate brightness (0-1)
      final brightness = (0.299 * r + 0.587 * g + 0.114 * b) / 255;

      // If pixel is bright enough, add it to glow buffer
      if (brightness > threshold) {
        if (colorMode == 0) {
          // Use original color for glow
          glowBuffer[i] = pixel;
        } else {
          // Use white color for glow, preserving alpha
          final glowIntensity = ((brightness - threshold) / (1 - threshold)).clamp(0.0, 1.0);
          final glowValue = (glowIntensity * 255).round().clamp(0, 255);
          glowBuffer[i] = (a << 24) | (glowValue << 16) | (glowValue << 8) | glowValue;
        }
      }
    }

    // Step 2: Blur the glow buffer (box blur for performance)
    final blurredGlow = _applyBoxBlur(glowBuffer, width, height, radius);

    // Step 3: Blend the original image with the glowing parts
    for (int i = 0; i < pixels.length; i++) {
      final originalPixel = source[i];
      final glowPixel = blurredGlow[i];

      final originalA = (originalPixel >> 24) & 0xFF;
      final originalR = (originalPixel >> 16) & 0xFF;
      final originalG = (originalPixel >> 8) & 0xFF;
      final originalB = originalPixel & 0xFF;

      final glowA = (glowPixel >> 24) & 0xFF;
      final glowR = (glowPixel >> 16) & 0xFF;
      final glowG = (glowPixel >> 8) & 0xFF;
      final glowB = glowPixel & 0xFF;

      // Skip if neither pixel has alpha
      if (originalA == 0 && glowA == 0) continue;

      // Blend original and glow with intensity factor
      final intensityFactor = intensity * (glowA / 255);

      // Calculate new color by adding glow to original
      int newA = max(originalA, glowA);
      int newR = _blendAdditive(originalR, (glowR * intensityFactor).round());
      int newG = _blendAdditive(originalG, (glowG * intensityFactor).round());
      int newB = _blendAdditive(originalB, (glowB * intensityFactor).round());

      // Store result
      result[i] = (newA << 24) | (newR << 16) | (newG << 8) | newB;
    }

    return result;
  }

  // Box blur implementation for the glow
  Uint32List _applyBoxBlur(Uint32List source, int width, int height, int radius) {
    // Create temporary and result buffers
    final temp = Uint32List(width * height);
    final result = Uint32List(width * height);

    // Horizontal pass
    for (int y = 0; y < height; y++) {
      // Initialize accumulators for RGBA channels
      int sumA = 0, sumR = 0, sumG = 0, sumB = 0;
      int count = 0;

      // Reset accumulators for each row
      sumA = sumR = sumG = sumB = count = 0;

      // Process each pixel in the row
      for (int x = 0; x < width; x++) {
        final int idx = y * width + x;

        // Add new pixel to right edge of window
        final int inPixel = source[idx];
        final int a = (inPixel >> 24) & 0xFF;

        if (a > 0) {
          sumA += a;
          sumR += (inPixel >> 16) & 0xFF;
          sumG += (inPixel >> 8) & 0xFF;
          sumB += inPixel & 0xFF;
          count++;
        }

        // Remove pixel from left edge of window
        if (x >= radius * 2) {
          final int outIdx = y * width + (x - radius * 2);
          final int outPixel = source[outIdx];
          final int outA = (outPixel >> 24) & 0xFF;

          if (outA > 0) {
            sumA -= outA;
            sumR -= (outPixel >> 16) & 0xFF;
            sumG -= (outPixel >> 8) & 0xFF;
            sumB -= outPixel & 0xFF;
            count--;
          }
        }

        // Calculate output pixel
        if (count > 0) {
          final int avgA = (sumA / count).round().clamp(0, 255);
          final int avgR = (sumR / count).round().clamp(0, 255);
          final int avgG = (sumG / count).round().clamp(0, 255);
          final int avgB = (sumB / count).round().clamp(0, 255);

          temp[idx] = (avgA << 24) | (avgR << 16) | (avgG << 8) | avgB;
        } else {
          temp[idx] = 0; // Transparent
        }
      }
    }

    // Vertical pass
    for (int x = 0; x < width; x++) {
      // Initialize accumulators for RGBA channels
      int sumA = 0, sumR = 0, sumG = 0, sumB = 0;
      int count = 0;

      // Reset accumulators for each column
      sumA = sumR = sumG = sumB = count = 0;

      // Process each pixel in the column
      for (int y = 0; y < height; y++) {
        final int idx = y * width + x;

        // Add new pixel to bottom edge of window
        final int inPixel = temp[idx];
        final int a = (inPixel >> 24) & 0xFF;

        if (a > 0) {
          sumA += a;
          sumR += (inPixel >> 16) & 0xFF;
          sumG += (inPixel >> 8) & 0xFF;
          sumB += inPixel & 0xFF;
          count++;
        }

        // Remove pixel from top edge of window
        if (y >= radius * 2) {
          final int outIdx = (y - radius * 2) * width + x;
          final int outPixel = temp[outIdx];
          final int outA = (outPixel >> 24) & 0xFF;

          if (outA > 0) {
            sumA -= outA;
            sumR -= (outPixel >> 16) & 0xFF;
            sumG -= (outPixel >> 8) & 0xFF;
            sumB -= outPixel & 0xFF;
            count--;
          }
        }

        // Calculate output pixel
        if (count > 0) {
          final int avgA = (sumA / count).round().clamp(0, 255);
          final int avgR = (sumR / count).round().clamp(0, 255);
          final int avgG = (sumG / count).round().clamp(0, 255);
          final int avgB = (sumB / count).round().clamp(0, 255);

          result[idx] = (avgA << 24) | (avgR << 16) | (avgG << 8) | avgB;
        } else {
          result[idx] = 0; // Transparent
        }
      }
    }

    return result;
  }

  // Helper function for additive blending
  int _blendAdditive(int base, int add) {
    return min(base + add, 255);
  }
}
