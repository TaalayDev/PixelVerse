part of 'effects.dart';

/// Effect that simulates halftone printing with patterns of dots
class HalftoneEffect extends Effect {
  HalftoneEffect([Map<String, dynamic>? parameters])
      : super(
          EffectType.halftone,
          parameters ??
              const {
                'dotSize': 0.5,
                'spacing': 0.5,
                'angle': 0.0,
                'style': 0, // 0 = circle, 1 = square, 2 = line, 3 = cross
              },
        );

  @override
  Map<String, dynamic> getDefaultParameters() {
    return {
      'dotSize': 0.5, // Size of dots relative to spacing (0-1)
      'spacing': 0.5, // Space between dots (0-1)
      'angle': 0.0, // Rotation angle for the dot pattern (0-1, representing 0-360°)
      'style': 0, // Dot style (0 = circle, 1 = square, 2 = line, 3 = cross)
    };
  }

  @override
  Uint32List apply(Uint32List pixels, int width, int height) {
    // Get parameters
    final dotSizeFactor = parameters['dotSize'] as double;
    final spacingFactor = parameters['spacing'] as double;
    final angleFactor = parameters['angle'] as double;
    final style = (parameters['style'] as int).clamp(0, 3);

    // Calculate actual spacing in pixels (minimum 2, maximum 8)
    final spacing = (2 + (spacingFactor * 6)).round().clamp(2, 8);

    // Calculate angle in radians (0-360 degrees)
    final angle = angleFactor * 2 * pi;

    // Create result buffer (filled with transparent initially)
    final result = Uint32List(pixels.length);

    // Calculate how many dots we'll have in x and y directions
    final dotsX = (width / spacing).ceil();
    final dotsY = (height / spacing).ceil();

    // Create a transformation matrix for rotation

    // Process each dot in the grid
    for (int dy = 0; dy < dotsY; dy++) {
      for (int dx = 0; dx < dotsX; dx++) {
        // Calculate center point of this dot
        final dotCenterX = dx * spacing + spacing ~/ 2;
        final dotCenterY = dy * spacing + spacing ~/ 2;

        // Skip if the dot center is outside the image
        if (dotCenterX < 0 || dotCenterX >= width || dotCenterY < 0 || dotCenterY >= height) {
          continue;
        }

        // Sample the original pixels in the area of this dot to get average color
        int totalR = 0, totalG = 0, totalB = 0, totalA = 0;
        int samples = 0;

        for (int y = dy * spacing; y < (dy + 1) * spacing; y++) {
          if (y < 0 || y >= height) continue;

          for (int x = dx * spacing; x < (dx + 1) * spacing; x++) {
            if (x < 0 || x >= width) continue;

            final idx = y * width + x;
            final pixel = pixels[idx];

            // Extract color components
            final a = (pixel >> 24) & 0xFF;
            if (a == 0) continue; // Skip transparent pixels

            final r = (pixel >> 16) & 0xFF;
            final g = (pixel >> 8) & 0xFF;
            final b = pixel & 0xFF;

            totalR += r;
            totalG += g;
            totalB += b;
            totalA += a;
            samples++;
          }
        }

        // If no samples (all transparent), skip this dot
        if (samples == 0) continue;

        // Calculate average color
        final avgR = (totalR / samples).round().clamp(0, 255);
        final avgG = (totalG / samples).round().clamp(0, 255);
        final avgB = (totalB / samples).round().clamp(0, 255);
        final avgA = (totalA / samples).round().clamp(0, 255);

        // Convert to grayscale intensity (0-1)
        final intensity = (0.299 * avgR + 0.587 * avgG + 0.114 * avgB) / 255;

        // Calculate dot size based on intensity and dotSize parameter
        // Larger dots for darker areas (inverted intensity)
        final dotRadius = ((1 - intensity) * dotSizeFactor * spacing / 2).round();

        // Skip if dot radius is 0
        if (dotRadius <= 0) continue;

        // Create the actual dot
        switch (style) {
          case 0: // Circle
            _drawCircle(result, width, height, dotCenterX, dotCenterY, dotRadius, avgR, avgG, avgB, avgA);
            break;
          case 1: // Square
            _drawSquare(result, width, height, dotCenterX, dotCenterY, dotRadius, avgR, avgG, avgB, avgA);
            break;
          case 2: // Line
            _drawLine(result, width, height, dotCenterX, dotCenterY, dotRadius, angle, avgR, avgG, avgB, avgA);
            break;
          case 3: // Cross
            _drawCross(result, width, height, dotCenterX, dotCenterY, dotRadius, angle, avgR, avgG, avgB, avgA);
            break;
        }
      }
    }

    return result;
  }

  // Helper method to draw a circle
  void _drawCircle(
      Uint32List pixels, int width, int height, int centerX, int centerY, int radius, int r, int g, int b, int a) {
    final radiusSquared = radius * radius;

    for (int y = centerY - radius; y <= centerY + radius; y++) {
      if (y < 0 || y >= height) continue;

      for (int x = centerX - radius; x <= centerX + radius; x++) {
        if (x < 0 || x >= width) continue;

        final distanceSquared = (x - centerX) * (x - centerX) + (y - centerY) * (y - centerY);
        if (distanceSquared <= radiusSquared) {
          final idx = y * width + x;
          pixels[idx] = (a << 24) | (r << 16) | (g << 8) | b;
        }
      }
    }
  }

  // Helper method to draw a square
  void _drawSquare(
      Uint32List pixels, int width, int height, int centerX, int centerY, int radius, int r, int g, int b, int a) {
    for (int y = centerY - radius; y <= centerY + radius; y++) {
      if (y < 0 || y >= height) continue;

      for (int x = centerX - radius; x <= centerX + radius; x++) {
        if (x < 0 || x >= width) continue;

        final idx = y * width + x;
        pixels[idx] = (a << 24) | (r << 16) | (g << 8) | b;
      }
    }
  }

  // Helper method to draw a line
  void _drawLine(Uint32List pixels, int width, int height, int centerX, int centerY, int length, double angle, int r,
      int g, int b, int a) {
    final sinA = sin(angle);
    final cosA = cos(angle);

    for (int i = -length; i <= length; i++) {
      final x = (centerX + i * cosA).round();
      final y = (centerY + i * sinA).round();

      if (x < 0 || x >= width || y < 0 || y >= height) continue;

      final idx = y * width + x;
      pixels[idx] = (a << 24) | (r << 16) | (g << 8) | b;
    }
  }

  // Helper method to draw a cross
  void _drawCross(Uint32List pixels, int width, int height, int centerX, int centerY, int length, double angle, int r,
      int g, int b, int a) {
    // Draw first line
    _drawLine(pixels, width, height, centerX, centerY, length, angle, r, g, b, a);

    // Draw second line (perpendicular)
    _drawLine(pixels, width, height, centerX, centerY, length, angle + pi / 2, r, g, b, a);
  }
}
