part of 'effects.dart';

/// Palette reduction effect for pixel art
class PaletteReductionEffect extends Effect {
  PaletteReductionEffect([Map<String, dynamic>? params])
      : super(
            EffectType.paletteReduction,
            params ??
                {
                  'colors': 8,
                  'dithering': 0.0,
                });

  @override
  Uint32List apply(Uint32List pixels, int width, int height) {
    final colors = (parameters['colors'] as int).clamp(2, 64);
    final dithering = (parameters['dithering'] as double).clamp(0.0, 1.0);
    final result = Uint32List(pixels.length);

    // Calculate how many levels per channel
    final levels = _calculateLevelsPerChannel(colors);

    // Error arrays for dithering
    final List<List<double>> errorR =
        List.generate(height, (_) => List.filled(width, 0.0));
    final List<List<double>> errorG =
        List.generate(height, (_) => List.filled(width, 0.0));
    final List<List<double>> errorB =
        List.generate(height, (_) => List.filled(width, 0.0));

    // Process each pixel
    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final index = y * width + x;
        final pixel = pixels[index];
        final a = (pixel >> 24) & 0xFF;

        if (a == 0) {
          result[index] = 0; // Keep fully transparent pixels unchanged
          continue;
        }

        // Get RGB values and add error if dithering is enabled
        num r = (pixel >> 16) & 0xFF;
        num g = (pixel >> 8) & 0xFF;
        num b = pixel & 0xFF;

        if (dithering > 0.0) {
          r += errorR[y][x];
          g += errorG[y][x];
          b += errorB[y][x];
        }

        // Quantize to the limited palette
        final rStep = 255 / (levels.r - 1);
        final gStep = 255 / (levels.g - 1);
        final bStep = 255 / (levels.b - 1);

        final newR = ((r / rStep).round() * rStep).clamp(0, 255).toInt();
        final newG = ((g / gStep).round() * gStep).clamp(0, 255).toInt();
        final newB = ((b / bStep).round() * bStep).clamp(0, 255).toInt();

        // Store the result
        result[index] = (a << 24) | (newR << 16) | (newG << 8) | newB;

        // Calculate errors for dithering
        if (dithering > 0.0) {
          final errR = (r - newR) * dithering;
          final errG = (g - newG) * dithering;
          final errB = (b - newB) * dithering;

          // Floyd-Steinberg dithering pattern
          _distributeError(errorR, errR, x, y, width, height);
          _distributeError(errorG, errG, x, y, width, height);
          _distributeError(errorB, errB, x, y, width, height);
        }
      }
    }

    return result;
  }

  void _distributeError(List<List<double>> errorArray, double error, int x,
      int y, int width, int height) {
    if (x + 1 < width) {
      errorArray[y][x + 1] += error * 7 / 16;
    }

    if (y + 1 < height) {
      if (x > 0) {
        errorArray[y + 1][x - 1] += error * 3 / 16;
      }

      errorArray[y + 1][x] += error * 5 / 16;

      if (x + 1 < width) {
        errorArray[y + 1][x + 1] += error * 1 / 16;
      }
    }
  }

  _RGBLevels _calculateLevelsPerChannel(int totalColors) {
    // Simple approach: try to distribute the levels evenly
    // For 8 colors, we could do 2 levels of R, 2 of G, and 2 of B (2*2*2=8)
    // For more colors, we need to find an appropriate distribution

    int r = 1, g = 1, b = 1;

    while (r * g * b < totalColors) {
      // Increase the channel with the smallest number of levels
      if (r <= g && r <= b) {
        r++;
      } else if (g <= r && g <= b) {
        g++;
      } else {
        b++;
      }
    }

    return _RGBLevels(r, g, b);
  }

  @override
  Map<String, dynamic> getDefaultParameters() {
    return {
      'colors': 8, // Range: 2 to 64
      'dithering': 0.0, // Range: 0.0 to 1.0
    };
  }
}

class _RGBLevels {
  final int r;
  final int g;
  final int b;

  _RGBLevels(this.r, this.g, this.b);
}
