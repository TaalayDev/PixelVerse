part of 'effects.dart';

/// Creates a pixelated look by reducing detail
class PixelateEffect extends Effect {
  PixelateEffect([Map<String, dynamic>? params]) : super(EffectType.pixelate, params ?? {'blockSize': 2});

  @override
  Uint32List apply(Uint32List pixels, int width, int height) {
    final blockSize = (parameters['blockSize'] as int).clamp(1, min(width, height) ~/ 2);
    final result = Uint32List(pixels.length);

    for (int y = 0; y < height; y += blockSize) {
      for (int x = 0; x < width; x += blockSize) {
        // Calculate average color for block
        int totalR = 0, totalG = 0, totalB = 0, totalA = 0;
        int count = 0;

        for (int by = 0; by < blockSize && y + by < height; by++) {
          for (int bx = 0; bx < blockSize && x + bx < width; bx++) {
            final pixelIndex = (y + by) * width + (x + bx);
            if (pixelIndex < pixels.length) {
              final pixel = pixels[pixelIndex];
              totalA += (pixel >> 24) & 0xFF;
              totalR += (pixel >> 16) & 0xFF;
              totalG += (pixel >> 8) & 0xFF;
              totalB += pixel & 0xFF;
              count++;
            }
          }
        }

        if (count > 0) {
          final avgA = (totalA / count).round();
          final avgR = (totalR / count).round();
          final avgG = (totalG / count).round();
          final avgB = (totalB / count).round();

          final blockColor = (avgA << 24) | (avgR << 16) | (avgG << 8) | avgB;

          // Fill the block with the average color
          for (int by = 0; by < blockSize && y + by < height; by++) {
            for (int bx = 0; bx < blockSize && x + bx < width; bx++) {
              final pixelIndex = (y + by) * width + (x + bx);
              if (pixelIndex < result.length) {
                result[pixelIndex] = blockColor;
              }
            }
          }
        }
      }
    }

    return result;
  }

  @override
  Map<String, dynamic> getDefaultParameters() {
    return {'blockSize': 2}; // Range: 1 to image size/2
  }

  @override
  Map<String, dynamic> getMetadata() {
    return {
      'blockSize': {
        'label': 'Block Size',
        'description': 'Size of the pixel blocks. Larger values create more pixelated look.',
        'type': 'slider',
        'min': 1,
        'max': 10,
        'divisions': 9,
      },
    };
  }
}
