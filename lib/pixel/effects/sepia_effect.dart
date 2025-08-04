part of 'effects.dart';

/// Applies a sepia tone to pixels
class SepiaEffect extends Effect {
  SepiaEffect([Map<String, dynamic>? params]) : super(EffectType.sepia, params ?? {'intensity': 1.0});

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

      // Sepia formula
      final sepiaR = (r * 0.393 + g * 0.769 + b * 0.189).round().clamp(0, 255);
      final sepiaG = (r * 0.349 + g * 0.686 + b * 0.168).round().clamp(0, 255);
      final sepiaB = (r * 0.272 + g * 0.534 + b * 0.131).round().clamp(0, 255);

      // Apply intensity (blend between original and sepia)
      final newR = (r * (1 - intensity) + sepiaR * intensity).round();
      final newG = (g * (1 - intensity) + sepiaG * intensity).round();
      final newB = (b * (1 - intensity) + sepiaB * intensity).round();

      result[i] = (a << 24) | (newR << 16) | (newG << 8) | newB;
    }

    return result;
  }

  @override
  Map<String, dynamic> getDefaultParameters() {
    return {'intensity': 1.0}; // Range: 0.0 to 1.0
  }

  @override
  Map<String, dynamic> getMetadata() {
    return {
      'intensity': {
        'label': 'Intensity',
        'description': 'Controls the strength of the sepia tone effect. 0 = no effect, 1 = full sepia.',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
    };
  }
}
