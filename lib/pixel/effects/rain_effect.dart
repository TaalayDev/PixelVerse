part of 'effects.dart';

/// Effect that adds animated rain drops and streaks to the image
class RainEffect extends Effect {
  RainEffect([Map<String, dynamic>? parameters])
      : super(
          EffectType.rain,
          parameters ??
              const {
                'intensity': 0.5, // Rain density (0-1)
                'angle': 0.0, // Rain direction (-45° to 45°, normalized to 0-1)
                'dropSize': 0.5, // Individual drop size (0-1)
                'speed': 0.5, // Animation frame offset (0-1)
                'windVariation': 0.3, // Wind effect variation (0-1)
                'opacity': 0.7, // Rain drop opacity (0-1)
              },
        );

  @override
  Map<String, dynamic> getDefaultParameters() {
    return {
      'intensity': 0.5, // Rain density
      'angle': 0.0, // Rain direction (0 = vertical, 0.5 = 22.5°, 1 = 45°)
      'dropSize': 0.5, // Drop size
      'speed': 0.5, // Animation offset
      'windVariation': 0.3, // Wind turbulence
      'opacity': 0.7, // Drop opacity
    };
  }

  @override
  Map<String, dynamic> getMetadata() {
    return {
      'intensity': {
        'label': 'Rain Intensity',
        'description': 'Controls the density of rain drops.',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
      'angle': {
        'label': 'Rain Angle',
        'description': 'Controls the direction of rainfall. 0 = vertical, 1 = 45° slant.',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
      'dropSize': {
        'label': 'Drop Size',
        'description': 'Controls the size of individual rain drops.',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
      'speed': {
        'label': 'Animation Phase',
        'description': 'Controls the animation frame of the rain (for creating movement).',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
      'windVariation': {
        'label': 'Wind Variation',
        'description': 'Adds random wind effects to make rain look more natural.',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
      'opacity': {
        'label': 'Rain Opacity',
        'description': 'Controls how transparent the rain drops are.',
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
    final angleParam = parameters['angle'] as double;
    final dropSizeParam = parameters['dropSize'] as double;
    final speed = parameters['speed'] as double;
    final windVariation = parameters['windVariation'] as double;
    final opacity = parameters['opacity'] as double;

    // Copy original pixels
    final result = Uint32List.fromList(pixels);

    // Skip if no rain
    if (intensity <= 0.0 || opacity <= 0.0) return result;

    // Convert angle parameter to actual angle in radians
    // 0.0 = vertical (0°), 1.0 = 45° slant
    final angleRadians = angleParam * pi / 4; // 0 to π/4 (45°)
    final rainSlope = tan(angleRadians);

    // Calculate drop parameters
    final maxDropLength = (5 + dropSizeParam * 10).round().clamp(1, 15);
    final dropDensity = (intensity * 200).round().clamp(1, 200);
    final rainOpacity = (opacity * 255).round().clamp(1, 255);

    // Use deterministic random based on speed for animation
    final animationSeed = (speed * 1000).round();
    final random = Random(42 + animationSeed);

    // Generate rain drops
    for (int i = 0; i < dropDensity; i++) {
      // Generate drop starting position with animation offset
      var dropX = random.nextDouble() * width;
      var dropY = random.nextDouble() * height;

      // Apply animation by shifting drop positions
      dropY = (dropY + speed * height * 2) % height;

      // Apply wind variation
      if (windVariation > 0) {
        final windOffset = (random.nextDouble() * 2 - 1) * windVariation * 5;
        dropX += windOffset;
      }

      // Calculate drop length based on size parameter
      final currentDropLength = (maxDropLength * (0.5 + random.nextDouble() * 0.5)).round();

      // Draw rain drop
      _drawRainDrop(
        result,
        width,
        height,
        dropX,
        dropY,
        currentDropLength,
        rainSlope,
        rainOpacity,
        random,
      );
    }

    return result;
  }

  void _drawRainDrop(
    Uint32List pixels,
    int width,
    int height,
    double startX,
    double startY,
    int dropLength,
    double slope,
    int opacity,
    Random random,
  ) {
    // Rain drop color (slightly blue-tinted white)
    final baseR = 200 + (random.nextDouble() * 55).round();
    final baseG = 220 + (random.nextDouble() * 35).round();
    final baseB = 255;

    for (int i = 0; i < dropLength; i++) {
      // Calculate position along the drop
      final progress = i / (dropLength - 1);

      // Position of this drop segment
      final x = (startX + i * slope).round();
      final y = (startY + i).round();

      // Skip if out of bounds
      if (x < 0 || x >= width || y < 0 || y >= height) continue;

      final pixelIndex = y * width + x;
      if (pixelIndex >= pixels.length) continue;

      // Calculate drop opacity (tapered at ends)
      var dropOpacity = opacity;
      if (progress < 0.3) {
        dropOpacity = (dropOpacity * (progress / 0.3)).round();
      } else if (progress > 0.7) {
        dropOpacity = (dropOpacity * ((1.0 - progress) / 0.3)).round();
      }

      // Get existing pixel
      final existingPixel = pixels[pixelIndex];
      final existingA = (existingPixel >> 24) & 0xFF;
      final existingR = (existingPixel >> 16) & 0xFF;
      final existingG = (existingPixel >> 8) & 0xFF;
      final existingB = existingPixel & 0xFF;

      // Blend rain drop with existing pixel
      final blendFactor = dropOpacity / 255.0;
      final invBlendFactor = 1.0 - blendFactor;

      final newR = (existingR * invBlendFactor + baseR * blendFactor).round().clamp(0, 255);
      final newG = (existingG * invBlendFactor + baseG * blendFactor).round().clamp(0, 255);
      final newB = (existingB * invBlendFactor + baseB * blendFactor).round().clamp(0, 255);
      final newA = max(existingA, dropOpacity);

      pixels[pixelIndex] = (newA << 24) | (newR << 16) | (newG << 8) | newB;
    }
  }
}
