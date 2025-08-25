part of 'effects.dart';

/// Effect that creates animated waves across the image
class WaveEffect extends Effect {
  WaveEffect([Map<String, dynamic>? parameters])
      : super(
          EffectType.wave,
          parameters ??
              const {
                'amplitude': 0.3, // Wave height (0-1)
                'frequency': 0.5, // Wave frequency (0-1)
                'speed': 0.5, // Animation speed (0-1)
                'direction': 0, // 0=horizontal, 1=vertical, 2=diagonal
                'waveType': 0, // 0=sine, 1=square, 2=triangle
                'colorShift': 0.2, // Color shifting intensity (0-1)
                'time': 0.0, // Animation time parameter (0-1)
              },
        );

  @override
  Map<String, dynamic> getDefaultParameters() {
    return {
      'amplitude': 0.3,
      'frequency': 0.5,
      'speed': 0.5,
      'direction': 0,
      'waveType': 0,
      'colorShift': 0.2,
      'time': 0.0,
    };
  }

  @override
  Map<String, dynamic> getMetadata() {
    return {
      'amplitude': {
        'label': 'Wave Amplitude',
        'description': 'Controls the height/strength of the waves.',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
      'frequency': {
        'label': 'Wave Frequency',
        'description': 'Controls how many waves appear across the image.',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
      'speed': {
        'label': 'Animation Speed',
        'description': 'Controls how fast the waves move.',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
      'direction': {
        'label': 'Wave Direction',
        'description': 'Direction of wave movement.',
        'type': 'select',
        'options': {
          0: 'Horizontal',
          1: 'Vertical',
          2: 'Diagonal',
        },
      },
      'waveType': {
        'label': 'Wave Type',
        'description': 'Shape of the wave pattern.',
        'type': 'select',
        'options': {
          0: 'Sine Wave',
          1: 'Square Wave',
          2: 'Triangle Wave',
        },
      },
      'colorShift': {
        'label': 'Color Shift',
        'description': 'How much colors shift with the wave.',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
    };
  }

  @override
  Uint32List apply(Uint32List pixels, int width, int height) {
    final amplitude = parameters['amplitude'] as double;
    final frequency = parameters['frequency'] as double;
    final speed = parameters['speed'] as double;
    final direction = parameters['direction'] as int;
    final waveType = parameters['waveType'] as int;
    final colorShift = parameters['colorShift'] as double;
    final time = parameters['time'] as double;

    final result = Uint32List.fromList(pixels);
    final animTime = time * speed * 20;

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final index = y * width + x;
        final pixel = pixels[index];

        if (((pixel >> 24) & 0xFF) == 0) continue; // Skip transparent

        // Calculate wave position based on direction
        double wavePos;
        switch (direction) {
          case 0: // Horizontal
            wavePos = x / width;
            break;
          case 1: // Vertical
            wavePos = y / height;
            break;
          case 2: // Diagonal
            wavePos = (x + y) / (width + height);
            break;
          default:
            wavePos = x / width;
        }

        // Calculate wave value based on type
        final waveInput = wavePos * frequency * 10 + animTime;
        double waveValue;

        switch (waveType) {
          case 0: // Sine
            waveValue = sin(waveInput);
            break;
          case 1: // Square
            waveValue = sin(waveInput) > 0 ? 1.0 : -1.0;
            break;
          case 2: // Triangle
            waveValue = 2 * (waveInput / (2 * pi) - (waveInput / (2 * pi)).floor()) - 1;
            if (waveValue > 0.5) waveValue = 1 - waveValue;
            waveValue *= 2;
            break;
          default:
            waveValue = sin(waveInput);
        }

        // Apply wave effect
        final intensity = waveValue * amplitude;

        // Extract color components
        final r = (pixel >> 16) & 0xFF;
        final g = (pixel >> 8) & 0xFF;
        final b = pixel & 0xFF;
        final a = (pixel >> 24) & 0xFF;

        // Apply color shift based on wave
        final shiftAmount = intensity * colorShift * 100;

        final newR = (r + shiftAmount).clamp(0, 255).toInt();
        final newG = (g + shiftAmount * 0.7).clamp(0, 255).toInt();
        final newB = (b + shiftAmount * 0.5).clamp(0, 255).toInt();

        result[index] = (a << 24) | (newR << 16) | (newG << 8) | newB;
      }
    }

    return result;
  }
}
