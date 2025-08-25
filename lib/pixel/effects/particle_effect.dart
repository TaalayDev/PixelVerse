part of 'effects.dart';

/// Effect that creates animated floating particles
class ParticleEffect extends Effect {
  ParticleEffect([Map<String, dynamic>? parameters])
      : super(
          EffectType.particle,
          parameters ??
              const {
                'count': 0.5, // Number of particles (0-1)
                'size': 0.3, // Particle size (0-1)
                'speed': 0.5, // Movement speed (0-1)
                'direction': 0.5, // Movement direction (0-1 = 0-360°)
                'spread': 0.5, // Direction spread (0-1)
                'lifetime': 0.7, // How long particles live (0-1)
                'color': 0xFFFFFF00, // Particle color (yellow)
                'gravity': 0.2, // Gravity effect (0-1)
                'time': 0.0, // Animation time parameter (0-1)
              },
        );

  @override
  Map<String, dynamic> getDefaultParameters() {
    return {
      'count': 0.5,
      'size': 0.3,
      'speed': 0.5,
      'direction': 0.5,
      'spread': 0.5,
      'lifetime': 0.7,
      'color': 0xFFFFFF00,
      'gravity': 0.2,
      'time': 0.0,
    };
  }

  @override
  Map<String, dynamic> getMetadata() {
    return {
      'count': {
        'label': 'Particle Count',
        'description': 'Number of particles to generate.',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
      'size': {
        'label': 'Particle Size',
        'description': 'Size of individual particles.',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
      'speed': {
        'label': 'Movement Speed',
        'description': 'How fast particles move.',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
      'direction': {
        'label': 'Base Direction',
        'description': 'Primary direction of particle movement.',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
      'spread': {
        'label': 'Direction Spread',
        'description': 'How much particles deviate from base direction.',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
      'lifetime': {
        'label': 'Particle Lifetime',
        'description': 'How long particles remain visible.',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
      'color': {
        'label': 'Particle Color',
        'description': 'Color of the particles.',
        'type': 'color',
      },
      'gravity': {
        'label': 'Gravity Effect',
        'description': 'Downward force affecting particles.',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
    };
  }

  @override
  Uint32List apply(Uint32List pixels, int width, int height) {
    final count = parameters['count'] as double;
    final particleSize = parameters['size'] as double;
    final speed = parameters['speed'] as double;
    final baseDirection = parameters['direction'] as double;
    final spread = parameters['spread'] as double;
    final lifetime = parameters['lifetime'] as double;
    final particleColor = Color(parameters['color'] as int);
    final gravity = parameters['gravity'] as double;
    final time = parameters['time'] as double;

    final result = Uint32List.fromList(pixels);

    // Calculate number of particles
    final numParticles = (count * 50).round();
    final animTime = time * 10;

    for (int i = 0; i < numParticles; i++) {
      final particleId = i * 2654435761; // Large prime for good distribution

      // Calculate particle lifecycle
      final particleTime = (animTime + particleId * 0.001) % (lifetime * 10);
      final normalizedLife = particleTime / (lifetime * 10);

      if (normalizedLife > 1.0) continue; // Particle is dead

      // Starting position
      final startX = ((particleId * 0.1) % 1.0) * width;
      final startY = ((particleId * 0.2) % 1.0) * height;

      // Movement direction
      final particleDirection = baseDirection * 2 * pi + (((particleId * 0.3) % 1.0) - 0.5) * spread * pi;

      // Current position
      final moveDistance = normalizedLife * speed * min(width, height) * 0.5;
      final gravityOffset = normalizedLife * normalizedLife * gravity * height * 0.3;

      final x = (startX + cos(particleDirection) * moveDistance).round();
      final y = (startY + sin(particleDirection) * moveDistance + gravityOffset).round();

      if (x < 0 || x >= width || y < 0 || y >= height) continue;

      // Calculate particle alpha based on lifetime
      final alpha = (1.0 - normalizedLife) * particleColor.alpha;

      if (alpha > 10) {
        _drawParticle(result, width, height, x, y, particleSize, particleColor, alpha / 255.0);
      }
    }

    return result;
  }

  void _drawParticle(
      Uint32List pixels, int width, int height, int centerX, int centerY, double size, Color color, double alpha) {
    final radius = (size * 2 + 1).round();
    final particleAlpha = (alpha * 255).round().clamp(0, 255);

    for (int dy = -radius; dy <= radius; dy++) {
      for (int dx = -radius; dx <= radius; dx++) {
        final x = centerX + dx;
        final y = centerY + dy;

        if (x < 0 || x >= width || y < 0 || y >= height) continue;

        final distance = sqrt(dx * dx + dy * dy);
        if (distance <= radius) {
          final intensity = 1.0 - distance / radius;
          final pixelAlpha = (particleAlpha * intensity).round().clamp(0, 255);

          if (pixelAlpha > 0) {
            final index = y * width + x;
            final particlePixel = Color.fromARGB(
              pixelAlpha,
              color.red,
              color.green,
              color.blue,
            );

            pixels[index] = _blendAdditive(pixels[index], particlePixel.value);
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
