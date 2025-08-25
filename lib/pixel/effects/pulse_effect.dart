part of 'effects.dart';

/// Effect that creates animated pulsing/breathing
class PulseEffect extends Effect {
  PulseEffect([Map<String, dynamic>? parameters])
      : super(
          EffectType.pulse,
          parameters ??
              const {
                'intensity': 0.5, // Pulse intensity (0-1)
                'speed': 0.5, // Pulse speed (0-1)
                'minScale': 0.8, // Minimum scale (0-1)
                'maxScale': 1.2, // Maximum scale (0.5-2)
                'centerX': 0.5, // Pulse center X (0-1)
                'centerY': 0.5, // Pulse center Y (0-1)
                'colorPulse': 0.3, // Color intensity pulse (0-1)
                'time': 0.0, // Animation time parameter (0-1)
              },
        );

  @override
  Map<String, dynamic> getDefaultParameters() {
    return {
      'intensity': 0.5,
      'speed': 0.5,
      'minScale': 0.8,
      'maxScale': 1.2,
      'centerX': 0.5,
      'centerY': 0.5,
      'colorPulse': 0.3,
      'time': 0.0,
    };
  }

  @override
  Map<String, dynamic> getMetadata() {
    return {
      'intensity': {
        'label': 'Pulse Intensity',
        'description': 'How strong the pulsing effect is.',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
      'speed': {
        'label': 'Pulse Speed',
        'description': 'How fast the pulsing occurs.',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
      'minScale': {
        'label': 'Minimum Scale',
        'description': 'Smallest size during pulse.',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
      'maxScale': {
        'label': 'Maximum Scale',
        'description': 'Largest size during pulse.',
        'type': 'slider',
        'min': 0.5,
        'max': 2.0,
        'divisions': 100,
      },
      'centerX': {
        'label': 'Center X',
        'description': 'Horizontal center of pulse effect.',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
      'centerY': {
        'label': 'Center Y',
        'description': 'Vertical center of pulse effect.',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
      'colorPulse': {
        'label': 'Color Pulse',
        'description': 'How much colors pulse with the effect.',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
    };
  }

  @override
  Uint32List apply(Uint32List pixels, int width, int height) {
    final intensity = parameters['intensity'] as double;
    final speed = parameters['speed'] as double;
    final minScale = parameters['minScale'] as double;
    final maxScale = parameters['maxScale'] as double;
    final centerX = parameters['centerX'] as double;
    final centerY = parameters['centerY'] as double;
    final colorPulse = parameters['colorPulse'] as double;
    final time = parameters['time'] as double;

    final result = Uint32List(pixels.length);

    // Calculate current pulse value
    final animTime = time * speed * 8;
    final pulseValue = sin(animTime) * 0.5 + 0.5; // 0 to 1
    final currentScale = minScale + (maxScale - minScale) * pulseValue;

    // Calculate pulse center
    final pulseCenterX = centerX * width;
    final pulseCenterY = centerY * height;

    // Color pulse intensity
    final colorBoost = 1.0 + pulseValue * colorPulse;

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final destIndex = y * width + x;

        // Calculate source position (reverse scaling)
        final dx = x - pulseCenterX;
        final dy = y - pulseCenterY;

        final sourceX = pulseCenterX + dx / currentScale;
        final sourceY = pulseCenterY + dy / currentScale;

        // Sample from source position
        if (sourceX >= 0 && sourceX < width && sourceY >= 0 && sourceY < height) {
          final srcX = sourceX.round();
          final srcY = sourceY.round();
          final srcIndex = srcY * width + srcX;

          if (srcIndex < pixels.length) {
            final pixel = pixels[srcIndex];
            final a = (pixel >> 24) & 0xFF;

            if (a > 0) {
              // Apply color pulse
              final r = ((pixel >> 16) & 0xFF);
              final g = ((pixel >> 8) & 0xFF);
              final b = (pixel & 0xFF);

              final newR = (r * colorBoost).clamp(0, 255).toInt();
              final newG = (g * colorBoost).clamp(0, 255).toInt();
              final newB = (b * colorBoost).clamp(0, 255).toInt();

              result[destIndex] = (a << 24) | (newR << 16) | (newG << 8) | newB;
            } else {
              result[destIndex] = 0;
            }
          } else {
            result[destIndex] = 0;
          }
        } else {
          result[destIndex] = 0;
        }
      }
    }

    return result;
  }
}
