part of 'effects.dart';

/// Color balance effect
class ColorBalanceEffect extends Effect {
  ColorBalanceEffect([Map<String, dynamic>? params])
      : super(
          EffectType.colorBalance,
          params ??
              {
                'red': 0.0,
                'green': 0.0,
                'blue': 0.0,
              },
        );

  @override
  Uint32List apply(Uint32List pixels, int width, int height) {
    final redBalance = parameters['red'] as double;
    final greenBalance = parameters['green'] as double;
    final blueBalance = parameters['blue'] as double;
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

      // Apply color balance
      final newR = (r + redBalance * 255).clamp(0, 255).toInt();
      final newG = (g + greenBalance * 255).clamp(0, 255).toInt();
      final newB = (b + blueBalance * 255).clamp(0, 255).toInt();

      result[i] = (a << 24) | (newR << 16) | (newG << 8) | newB;
    }

    return result;
  }

  @override
  Map<String, dynamic> getDefaultParameters() {
    return {
      'red': 0.0, // Range: -1.0 to 1.0
      'green': 0.0, // Range: -1.0 to 1.0
      'blue': 0.0, // Range: -1.0 to 1.0
    };
  }

  @override
  Map<String, dynamic> getMetadata() {
    return {
      'red': {
        'label': 'Red Balance',
        'description': 'Adjusts the red channel. Negative values decrease red, positive values increase red.',
        'type': 'slider',
        'min': -1.0,
        'max': 1.0,
        'divisions': 100,
      },
      'green': {
        'label': 'Green Balance',
        'description': 'Adjusts the green channel. Negative values decrease green, positive values increase green.',
        'type': 'slider',
        'min': -1.0,
        'max': 1.0,
        'divisions': 100,
      },
      'blue': {
        'label': 'Blue Balance',
        'description': 'Adjusts the blue channel. Negative values decrease blue, positive values increase blue.',
        'type': 'slider',
        'min': -1.0,
        'max': 1.0,
        'divisions': 100,
      },
    };
  }
}
