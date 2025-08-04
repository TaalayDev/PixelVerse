part of 'effects.dart';

/// Adjusts contrast of pixels
class ContrastEffect extends Effect {
  ContrastEffect([Map<String, dynamic>? params]) : super(EffectType.contrast, params ?? {'value': 0.0});

  @override
  Uint32List apply(Uint32List pixels, int width, int height) {
    final value = (parameters['value'] as double) + 1.0; // Convert to range 0.0-2.0
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

      // Apply contrast formula: ((P - 128) * contrast) + 128
      final newR = (((r - 128) * value) + 128).clamp(0, 255).toInt();
      final newG = (((g - 128) * value) + 128).clamp(0, 255).toInt();
      final newB = (((b - 128) * value) + 128).clamp(0, 255).toInt();

      result[i] = (a << 24) | (newR << 16) | (newG << 8) | newB;
    }

    return result;
  }

  @override
  Map<String, dynamic> getDefaultParameters() {
    return {'value': 0.0}; // Range: -1.0 to 1.0
  }

  @override
  Map<String, dynamic> getMetadata() {
    return {
      'value': {
        'label': 'Contrast',
        'description': 'Adjusts the contrast between light and dark areas. '
            'Positive values increase contrast, negative values decrease it.',
        'type': 'slider',
        'min': -1.0,
        'max': 1.0,
        'divisions': 100,
      },
    };
  }
}
