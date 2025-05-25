part of 'effects.dart';

/// A pixel art style gradient effect that applies distinct color bands
/// with no opacity blending, creating a classic retro pixel art look.
///
/// The gradient uses a limited number of color steps between start and end colors,
/// creating distinct bands characteristic of retro pixel art.
class GradientEffect extends Effect {
  GradientEffect([Map<String, dynamic>? parameters])
      : super(
            EffectType.gradient,
            parameters ??
                const {
                  'startColor': 0xFFFF0000,
                  'endColor': 0xFF0000FF,
                  'direction': 0,
                  'colorSteps': 5,
                });

  @override
  Map<String, dynamic> getDefaultParameters() {
    return {
      'startColor': 0xFFFF0000, // Red
      'endColor': 0xFF0000FF, // Blue
      'direction': 0, // 0: horizontal, 1: vertical, 2: diagonal, 3: radial
      'colorSteps': 5, // Number of distinct color bands (2-16)
    };
  }

  @override
  Uint32List apply(Uint32List pixels, int width, int height) {
    final result = Uint32List.fromList(pixels);
    final startColor = Color(parameters['startColor'] as int);
    final endColor = Color(parameters['endColor'] as int);
    final direction = parameters['direction'] as int;
    final colorSteps = (parameters['colorSteps'] as int).clamp(2, 16);

    // Pre-compute all color steps
    final colorBands = <Color>[];
    for (int i = 0; i < colorSteps; i++) {
      final ratio = i / (colorSteps - 1);
      final r = (startColor.red + (endColor.red - startColor.red) * ratio).round();
      final g = (startColor.green + (endColor.green - startColor.green) * ratio).round();
      final b = (startColor.blue + (endColor.blue - startColor.blue) * ratio).round();
      final a = 255; // Full alpha

      colorBands.add(Color.fromARGB(a, r, g, b));
    }

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final index = y * width + x;

        // Skip if the index is out of bounds
        if (index >= result.length) continue;

        // Get original pixel color
        final originalColor = Color(result[index]);

        // Skip transparent pixels
        if (originalColor.alpha == 0) continue;

        // Calculate the gradient ratio (0.0 to 1.0) based on direction
        double ratio;
        switch (direction) {
          case 0: // Horizontal
            ratio = width > 1 ? x / (width - 1) : 0;
            break;
          case 1: // Vertical
            ratio = height > 1 ? y / (height - 1) : 0;
            break;
          case 2: // Diagonal
            ratio = (width + height > 2) ? (x + y) / (width + height - 2) : 0;
            break;
          case 3: // Radial
            final centerX = width / 2;
            final centerY = height / 2;
            final maxDistance = sqrt(centerX * centerX + centerY * centerY);
            final distance = sqrt(pow(x - centerX, 2) + pow(y - centerY, 2));
            ratio = maxDistance > 0 ? distance / maxDistance : 0;
            break;
          default:
            ratio = width > 1 ? x / (width - 1) : 0;
        }

        // Determine which color band to use
        final bandIndex = (ratio * (colorSteps - 1)).round();
        final pixelColor = colorBands[bandIndex];

        // Replace the pixel color completely (no opacity blending)
        result[index] = (pixelColor.value & 0x00FFFFFF) | (originalColor.alpha << 24);
      }
    }

    return result;
  }
}
