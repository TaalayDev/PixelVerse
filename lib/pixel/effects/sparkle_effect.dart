part of 'effects.dart';

/// Effect that creates animated sparkles that twinkle across the image
class SparkleEffect extends Effect {
  SparkleEffect([Map<String, dynamic>? parameters])
      : super(
          EffectType.sparkle,
          parameters ??
              const {
                'density': 0.5, // Number of sparkles (0-1)
                'size': 0.3, // Size of sparkles (0-1)
                'speed': 0.5, // Animation speed (0-1)
                'color': 0xFFFFFFFF, // Sparkle color
                'fadeSpeed': 0.7, // How quickly sparkles fade (0-1)
                'randomness': 0.8, // Position randomness (0-1)
                'time': 0.0, // Animation time parameter (0-1)
              },
        );

  @override
  Map<String, dynamic> getDefaultParameters() {
    return {
      'density': 0.5,
      'size': 0.3,
      'speed': 0.5,
      'color': 0xFFFFFFFF,
      'fadeSpeed': 0.7,
      'randomness': 0.8,
      'time': 0.0,
    };
  }

  @override
  Map<String, dynamic> getMetadata() {
    return {
      'density': {
        'label': 'Sparkle Density',
        'description': 'Controls how many sparkles appear.',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
      'size': {
        'label': 'Sparkle Size',
        'description': 'Controls the size of individual sparkles.',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
      'speed': {
        'label': 'Animation Speed',
        'description': 'Controls how fast sparkles animate.',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
      'color': {
        'label': 'Sparkle Color',
        'description': 'Color of the sparkles.',
        'type': 'color',
      },
      'fadeSpeed': {
        'label': 'Fade Speed',
        'description': 'How quickly sparkles fade in and out.',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
      'randomness': {
        'label': 'Position Randomness',
        'description': 'How randomly sparkles are positioned.',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
    };
  }

  @override
  Uint32List apply(Uint32List pixels, int width, int height) {
    final density = parameters['density'] as double;
    final sparkleSize = parameters['size'] as double;
    final speed = parameters['speed'] as double;
    final sparkleColor = Color(parameters['color'] as int);
    final fadeSpeed = parameters['fadeSpeed'] as double;
    final randomness = parameters['randomness'] as double;
    final time = parameters['time'] as double;

    final result = Uint32List.fromList(pixels);

    // Calculate number of sparkles based on density
    final numSparkles = (density * width * height * 0.01).round();

    // Use deterministic random based on time for smooth animation
    final animTime = time * speed * 10;

    for (int i = 0; i < numSparkles; i++) {
      // Create pseudo-random but deterministic sparkle positions
      final sparkleId = i * 1337; // Unique seed per sparkle
      final baseX = (sin(sparkleId * 0.1) * 0.5 + 0.5) * width;
      final baseY = (cos(sparkleId * 0.1) * 0.5 + 0.5) * height;

      // Add time-based movement
      final moveX = sin(animTime + sparkleId * 0.01) * randomness * 20;
      final moveY = cos(animTime * 0.7 + sparkleId * 0.01) * randomness * 20;

      final x = (baseX + moveX).round().clamp(0, width - 1);
      final y = (baseY + moveY).round().clamp(0, height - 1);

      // Calculate sparkle brightness based on time (fade in/out)
      final fadePhase = (animTime * fadeSpeed + sparkleId * 0.1) % (2 * pi);
      final brightness = (sin(fadePhase) * 0.5 + 0.5).clamp(0.0, 1.0);

      if (brightness > 0.1) {
        _drawSparkle(result, width, height, x, y, sparkleSize, sparkleColor, brightness);
      }
    }

    return result;
  }

  void _drawSparkle(
      Uint32List pixels, int width, int height, int centerX, int centerY, double size, Color color, double brightness) {
    final radius = (size * 3 + 1).round();
    final alpha = (color.alpha * brightness).round().clamp(0, 255);

    // Draw sparkle with cross pattern
    for (int dy = -radius; dy <= radius; dy++) {
      for (int dx = -radius; dx <= radius; dx++) {
        final x = centerX + dx;
        final y = centerY + dy;

        if (x < 0 || x >= width || y < 0 || y >= height) continue;

        // Create cross pattern
        final isCross = (dx == 0 || dy == 0 || dx == dy || dx == -dy);
        if (!isCross) continue;

        final distance = sqrt(dx * dx + dy * dy);
        if (distance <= radius) {
          final intensity = (1.0 - distance / radius) * brightness;
          final pixelAlpha = (alpha * intensity).round().clamp(0, 255);

          if (pixelAlpha > 0) {
            final index = y * width + x;
            final sparklePixel = Color.fromARGB(
              pixelAlpha,
              color.red,
              color.green,
              color.blue,
            );

            // Blend with existing pixel
            pixels[index] = _blendAdditive(pixels[index], sparklePixel.value);
          }
        }
      }
    }
  }

  int _blendAdditive(int base, int overlay) {
    final baseColor = Color(base);
    final overlayColor = Color(overlay);

    final newR = min(255, baseColor.red + overlayColor.red);
    final newG = min(255, baseColor.green + overlayColor.green);
    final newB = min(255, baseColor.blue + overlayColor.blue);
    final newA = max(baseColor.alpha, overlayColor.alpha);

    return Color.fromARGB(newA, newR, newG, newB).value;
  }
}
