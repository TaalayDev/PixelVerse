part of 'effects.dart';

/// Applies blur to pixels
class BlurEffect extends Effect {
  BlurEffect([Map<String, dynamic>? params])
      : super(EffectType.blur, params ?? {'radius': 1});

  @override
  Uint32List apply(Uint32List pixels, int width, int height) {
    final radius = (parameters['radius'] as int).clamp(1, 10);
    final result = Uint32List(pixels.length);

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        int totalR = 0, totalG = 0, totalB = 0, totalA = 0;
        int count = 0;

        // Simple box blur
        for (int ky = -radius; ky <= radius; ky++) {
          for (int kx = -radius; kx <= radius; kx++) {
            final newY = y + ky;
            final newX = x + kx;

            if (newX >= 0 && newX < width && newY >= 0 && newY < height) {
              final pixelIndex = newY * width + newX;
              final pixel = pixels[pixelIndex];

              final a = (pixel >> 24) & 0xFF;
              if (a > 0) {
                // Only consider non-transparent pixels
                totalA += a;
                totalR += (pixel >> 16) & 0xFF;
                totalG += (pixel >> 8) & 0xFF;
                totalB += pixel & 0xFF;
                count++;
              }
            }
          }
        }

        final resultIndex = y * width + x;
        if (count > 0) {
          final avgA = (totalA / count).round();
          final avgR = (totalR / count).round();
          final avgG = (totalG / count).round();
          final avgB = (totalB / count).round();

          result[resultIndex] =
              (avgA << 24) | (avgR << 16) | (avgG << 8) | avgB;
        } else {
          result[resultIndex] = 0; // Transparent if no valid pixels
        }
      }
    }

    return result;
  }

  @override
  Map<String, dynamic> getDefaultParameters() {
    return {'radius': 1}; // Range: 1 to 10
  }
}
