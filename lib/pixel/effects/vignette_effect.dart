part of 'effects.dart';

/// Creates a vignette (darkened edges) effect
class VignetteEffect extends Effect {
  VignetteEffect([Map<String, dynamic>? params])
      : super(EffectType.vignette, params ?? {'intensity': 0.5, 'size': 0.5});

  @override
  Uint32List apply(Uint32List pixels, int width, int height) {
    final intensity = (parameters['intensity'] as double).clamp(0.0, 1.0);
    final size = (parameters['size'] as double).clamp(0.0, 1.0);
    final result = Uint32List(pixels.length);

    final centerX = width / 2;
    final centerY = height / 2;
    final maxDistance = sqrt(centerX * centerX + centerY * centerY) * size;

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

        // Calculate distance from center
        final distanceX = (x - centerX).abs();
        final distanceY = (y - centerY).abs();
        final distance = sqrt(distanceX * distanceX + distanceY * distanceY);

        // Calculate vignette factor (1.0 at center, decreasing toward edges)
        final factor = 1.0 - (distance / maxDistance).clamp(0.0, 1.0) * intensity;

        // Apply vignette
        final newR = (r * factor).round().clamp(0, 255);
        final newG = (g * factor).round().clamp(0, 255);
        final newB = (b * factor).round().clamp(0, 255);

        result[pixelIndex] = (a << 24) | (newR << 16) | (newG << 8) | newB;
      }
    }

    return result;
  }

  @override
  Map<String, dynamic> getDefaultParameters() {
    return {'intensity': 0.5, 'size': 0.5}; // Range: 0.0 to 1.0
  }

  @override
  Map<String, dynamic> getMetadata() {
    return {
      'intensity': {
        'label': 'Intensity',
        'description': 'How dark the vignette becomes at the edges.',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
      'size': {
        'label': 'Size',
        'description': 'How far the vignette extends from the edges. Lower values create a larger bright center.',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
    };
  }
}
