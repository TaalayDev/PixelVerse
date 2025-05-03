part of 'effects.dart';

/// Creates an embossed effect (3D-like relief)
class EmbossEffect extends Effect {
  EmbossEffect([Map<String, dynamic>? params])
      : super(EffectType.emboss, params ?? {'strength': 1.0, 'direction': 0});

  @override
  Uint32List apply(Uint32List pixels, int width, int height) {
    final strength = (parameters['strength'] as double).clamp(0.0, 5.0);
    final direction =
        (parameters['direction'] as int).clamp(0, 7); // 0-7 for 8 directions
    final result = Uint32List(pixels.length);

    // Direction vectors for embossing
    final directions = [
      [-1, -1], [0, -1], [1, -1], // NW, N, NE
      [-1, 0], [1, 0], // W, E
      [-1, 1], [0, 1], [1, 1] // SW, S, SE
    ];

    final dx = directions[direction][0];
    final dy = directions[direction][1];

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final pixelIndex = y * width + x;
        final pixel = pixels[pixelIndex];

        final a = (pixel >> 24) & 0xFF;
        if (a == 0) {
          result[pixelIndex] = 0; // Keep fully transparent pixels unchanged
          continue;
        }

        final r = (pixel >> 16) & 0xFF;
        final g = (pixel >> 8) & 0xFF;
        final b = pixel & 0xFF;

        // Get the pixel in the emboss direction
        final newX = x + dx;
        final newY = y + dy;

        if (newX >= 0 && newX < width && newY >= 0 && newY < height) {
          final otherPixelIndex = newY * width + newX;
          final otherPixel = pixels[otherPixelIndex];

          final otherA = (otherPixel >> 24) & 0xFF;
          if (otherA > 0) {
            final otherR = (otherPixel >> 16) & 0xFF;
            final otherG = (otherPixel >> 8) & 0xFF;
            final otherB = otherPixel & 0xFF;

            // Calculate difference and apply strength
            final diffR = ((r - otherR) * strength + 128).round().clamp(0, 255);
            final diffG = ((g - otherG) * strength + 128).round().clamp(0, 255);
            final diffB = ((b - otherB) * strength + 128).round().clamp(0, 255);

            // Average for grayscale emboss
            final gray = (diffR + diffG + diffB) ~/ 3;

            result[pixelIndex] = (a << 24) | (gray << 16) | (gray << 8) | gray;
          } else {
            // If other pixel is transparent, use neutral gray
            result[pixelIndex] = (a << 24) | (128 << 16) | (128 << 8) | 128;
          }
        } else {
          // If outside image bounds, use neutral gray
          result[pixelIndex] = (a << 24) | (128 << 16) | (128 << 8) | 128;
        }
      }
    }

    return result;
  }

  @override
  Map<String, dynamic> getDefaultParameters() {
    return {
      'strength': 1.0,
      'direction': 0
    }; // strength: 0.0-5.0, direction: 0-7
  }
}
