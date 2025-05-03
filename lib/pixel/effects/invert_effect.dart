part of 'effects.dart';

/// Inverts the colors of pixels
class InvertEffect extends Effect {
  InvertEffect([Map<String, dynamic>? params])
      : super(EffectType.invert, params ?? {'intensity': 1.0});

  @override
  Uint32List apply(Uint32List pixels, int width, int height) {
    final intensity = parameters['intensity'] as double;
    final result = Uint32List(pixels.length);

    for (int i = 0; i < pixels.length; i++) {
      final a = (pixels[i] >> 24) & 0xFF;
      if (a == 0) {
        result[i] = 0; // Keep fully transparent pixels unchanged
        continue;
      }

      final r = (pixels[i] >> 16) & 0xFF;
      final g = (pixels[i] >> 8) & 0xFF;
      final b = pixels[i] & 0xFF;

      // Invert colors
      final invR = 255 - r;
      final invG = 255 - g;
      final invB = 255 - b;

      // Apply intensity (blend between original and inverted)
      final newR = (r * (1 - intensity) + invR * intensity).round();
      final newG = (g * (1 - intensity) + invG * intensity).round();
      final newB = (b * (1 - intensity) + invB * intensity).round();

      result[i] = (a << 24) | (newR << 16) | (newG << 8) | newB;
    }

    return result;
  }

  @override
  Map<String, dynamic> getDefaultParameters() {
    return {'intensity': 1.0}; // Range: 0.0 to 1.0
  }
}
