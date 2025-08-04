part of 'effects.dart';

/// Applies threshold to create high-contrast black and white
class ThresholdEffect extends Effect {
  ThresholdEffect([Map<String, dynamic>? params]) : super(EffectType.threshold, params ?? {'threshold': 0.5});

  @override
  Uint32List apply(Uint32List pixels, int width, int height) {
    final threshold = (parameters['threshold'] as double) * 255;
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

      // Calculate average intensity
      final avg = (r + g + b) / 3;

      // Apply threshold
      final value = avg >= threshold ? 255 : 0;

      result[i] = (a << 24) | (value << 16) | (value << 8) | value;
    }

    return result;
  }

  @override
  Map<String, dynamic> getDefaultParameters() {
    return {'threshold': 0.5}; // Range: 0.0 to 1.0
  }

  @override
  Map<String, dynamic> getMetadata() {
    return {
      'threshold': {
        'label': 'Threshold',
        'description': 'The brightness level where pixels become white. '
            'Pixels darker than this become black, brighter pixels become white.',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
    };
  }
}
