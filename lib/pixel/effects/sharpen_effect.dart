part of 'effects.dart';

/// Sharpens the image by enhancing edges
class SharpenEffect extends Effect {
  SharpenEffect([Map<String, dynamic>? params])
      : super(EffectType.sharpen, params ?? {'amount': 0.5});

  @override
  Uint32List apply(Uint32List pixels, int width, int height) {
    final amount = (parameters['amount'] as double).clamp(0.0, 1.0);
    final result = Uint32List(pixels.length);

    // Sharpen kernel
    final kernel = [
      [0, -amount, 0],
      [-amount, 1 + 4 * amount, -amount],
      [0, -amount, 0]
    ];

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        double totalR = 0, totalG = 0, totalB = 0;
        int centerA = 0;

        // Apply convolution
        for (int ky = -1; ky <= 1; ky++) {
          for (int kx = -1; kx <= 1; kx++) {
            final newY = y + ky;
            final newX = x + kx;

            if (newX >= 0 && newX < width && newY >= 0 && newY < height) {
              final pixelIndex = newY * width + newX;
              final pixel = pixels[pixelIndex];

              final a = (pixel >> 24) & 0xFF;
              final r = (pixel >> 16) & 0xFF;
              final g = (pixel >> 8) & 0xFF;
              final b = pixel & 0xFF;

              // Get kernel value
              final kernelValue = kernel[ky + 1][kx + 1];

              if (ky == 0 && kx == 0) {
                centerA = a; // Save center alpha
              }

              totalR += r * kernelValue;
              totalG += g * kernelValue;
              totalB += b * kernelValue;
            }
          }
        }

        final resultIndex = y * width + x;
        if (centerA > 0) {
          final newR = totalR.round().clamp(0, 255);
          final newG = totalG.round().clamp(0, 255);
          final newB = totalB.round().clamp(0, 255);

          result[resultIndex] =
              (centerA << 24) | (newR << 16) | (newG << 8) | newB;
        } else {
          result[resultIndex] = 0; // Transparent if center pixel is transparent
        }
      }
    }

    return result;
  }

  @override
  Map<String, dynamic> getDefaultParameters() {
    return {'amount': 0.5}; // Range: 0.0 to 1.0
  }
}
