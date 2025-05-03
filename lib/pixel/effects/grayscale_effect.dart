part of 'effects.dart';

/// Converts pixels to grayscale
class GrayscaleEffect extends Effect {
  GrayscaleEffect([Map<String, dynamic>? params])
      : super(EffectType.grayscale, params ?? {'intensity': 1.0});

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

      // Calculate grayscale value (ITU-R BT.709 luma formula)
      final gray = (0.2126 * r + 0.7152 * g + 0.0722 * b).round();

      // Apply intensity (blend between original and grayscale)
      final newR = (r * (1 - intensity) + gray * intensity).round();
      final newG = (g * (1 - intensity) + gray * intensity).round();
      final newB = (b * (1 - intensity) + gray * intensity).round();

      result[i] = (a << 24) | (newR << 16) | (newG << 8) | newB;
    }

    return result;
  }

  @override
  Map<String, dynamic> getDefaultParameters() {
    return {'intensity': 1.0}; // Range: 0.0 to 1.0
  }
}
