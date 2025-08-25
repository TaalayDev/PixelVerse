part of 'effects.dart';

/// Effect that creates a particle-based explosion with debris, fire, and shockwaves
class ExplosionEffect extends Effect {
  ExplosionEffect([Map<String, dynamic>? parameters])
      : super(
          EffectType.explosion,
          parameters ??
              const {
                'explosionX': 0.5, // Horizontal center of explosion (0-1)
                'explosionY': 0.5, // Vertical center of explosion (0-1)
                'force': 0.7, // Explosion force/speed (0-1)
                'particleCount': 0.6, // Number of debris particles (0-1)
                'particleSize': 0.4, // Size of debris particles (0-1)
                'gravity': 0.5, // Gravity affecting particles (0-1)
                'airResistance': 0.3, // Air drag on particles (0-1)
                'particleLifetime': 0.8, // How long particles live (0-1)
                'shockwave': 0.5, // Shockwave ring intensity (0-1)
                'fireEffect': 0.6, // Fire/heat effect intensity (0-1)
                'smokeEffect': 0.4, // Smoke trail intensity (0-1)
                'fragmentOriginal': 0.7, // Use original image as debris (0-1)
                'colorVariation': 0.8, // Color variation in particles (0-1)
                'randomSeed': 42, // Seed for deterministic randomness
                'time': 0.0, // Animation time parameter (0-1)
              },
        );

  @override
  Map<String, dynamic> getDefaultParameters() {
    return {
      'explosionX': 0.5,
      'explosionY': 0.5,
      'force': 0.7,
      'particleCount': 0.6,
      'particleSize': 0.4,
      'gravity': 0.5,
      'airResistance': 0.3,
      'particleLifetime': 0.8,
      'shockwave': 0.5,
      'fireEffect': 0.6,
      'smokeEffect': 0.4,
      'fragmentOriginal': 0.7,
      'colorVariation': 0.8,
      'randomSeed': 42,
      'time': 0.0,
    };
  }

  @override
  Map<String, dynamic> getMetadata() {
    return {
      'explosionX': {
        'label': 'Explosion Center X',
        'description': 'Horizontal position of the explosion center.',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
      'explosionY': {
        'label': 'Explosion Center Y',
        'description': 'Vertical position of the explosion center.',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
      'force': {
        'label': 'Explosion Force',
        'description': 'How powerful the explosion is (affects particle speed).',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
      'particleCount': {
        'label': 'Particle Count',
        'description': 'Number of debris particles created by the explosion.',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
      'particleSize': {
        'label': 'Particle Size',
        'description': 'Size of individual debris particles.',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
      'gravity': {
        'label': 'Gravity',
        'description': 'Downward force affecting particles after explosion.',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
      'airResistance': {
        'label': 'Air Resistance',
        'description': 'Drag force that slows down particles over time.',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
      'particleLifetime': {
        'label': 'Particle Lifetime',
        'description': 'How long particles remain visible.',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
      'shockwave': {
        'label': 'Shockwave Intensity',
        'description': 'Strength of the expanding shockwave ring.',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
      'fireEffect': {
        'label': 'Fire Effect',
        'description': 'Intensity of fire and heat effects.',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
      'smokeEffect': {
        'label': 'Smoke Effect',
        'description': 'Intensity of smoke trails from particles.',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
      'fragmentOriginal': {
        'label': 'Fragment Original',
        'description': 'How much original image appears in debris particles.',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
      'colorVariation': {
        'label': 'Color Variation',
        'description': 'Amount of color variation in explosion particles.',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
      'randomSeed': {
        'label': 'Random Seed',
        'description': 'Changes the random explosion pattern.',
        'type': 'slider',
        'min': 1,
        'max': 100,
        'divisions': 99,
      },
    };
  }

  @override
  Uint32List apply(Uint32List pixels, int width, int height) {
    final explosionX = parameters['explosionX'] as double;
    final explosionY = parameters['explosionY'] as double;
    final force = parameters['force'] as double;
    final particleCount = parameters['particleCount'] as double;
    final particleSize = parameters['particleSize'] as double;
    final gravity = parameters['gravity'] as double;
    final airResistance = parameters['airResistance'] as double;
    final particleLifetime = parameters['particleLifetime'] as double;
    final shockwave = parameters['shockwave'] as double;
    final fireEffect = parameters['fireEffect'] as double;
    final smokeEffect = parameters['smokeEffect'] as double;
    final fragmentOriginal = parameters['fragmentOriginal'] as double;
    final colorVariation = parameters['colorVariation'] as double;
    final randomSeed = parameters['randomSeed'] as int;
    final time = parameters['time'] as double;

    // Start with transparent background for explosion effect
    final result = Uint32List(pixels.length);

    // Calculate explosion center in pixels
    final centerX = explosionX * width;
    final centerY = explosionY * height;

    // Calculate explosion progress (0 to 1)
    final explosionProgress = (time * 2).clamp(0.0, 1.0);

    // Early explosion phase - show original image fragmenting
    if (explosionProgress < 0.3 && fragmentOriginal > 0) {
      _renderFragmentedOriginal(
          result, pixels, width, height, centerX, centerY, explosionProgress, fragmentOriginal, force);
    }

    // Draw shockwave ring
    if (shockwave > 0 && explosionProgress < 0.5) {
      _drawShockwave(result, width, height, centerX, centerY, explosionProgress, shockwave);
    }

    // Draw fire effect at explosion center
    if (fireEffect > 0 && explosionProgress < 0.6) {
      _drawFireEffect(result, width, height, centerX, centerY, explosionProgress, fireEffect);
    }

    // Calculate and draw debris particles
    final numParticles = (particleCount * 100 * min(width, height) / 50).round();

    for (int i = 0; i < numParticles; i++) {
      _drawDebrisParticle(result, pixels, width, height, centerX, centerY, i, explosionProgress, force, particleSize,
          gravity, airResistance, particleLifetime, smokeEffect, colorVariation, randomSeed);
    }

    return result;
  }

  /// Render the original image fragmenting in early explosion phase
  void _renderFragmentedOriginal(Uint32List result, Uint32List original, int width, int height, double centerX,
      double centerY, double progress, double fragmentIntensity, double force) {
    final fragmentTime = progress / 0.3; // Normalize to 0-1 for fragment phase
    final maxDisplacement = force * progress * min(width, height) * 0.2;

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final index = y * width + x;
        final pixel = original[index];

        if (((pixel >> 24) & 0xFF) == 0) continue;

        // Calculate fragment displacement from explosion center
        final dx = x - centerX;
        final dy = y - centerY;
        final distance = sqrt(dx * dx + dy * dy);

        if (distance < 1) continue; // Skip center point

        // Displacement based on direction from center
        final angle = atan2(dy, dx);
        final displacementFactor = fragmentTime * (1.0 + _hash(x * 73 + y * 37) * 0.5);

        final displaceX = cos(angle) * maxDisplacement * displacementFactor;
        final displaceY = sin(angle) * maxDisplacement * displacementFactor;

        final newX = (x + displaceX).round();
        final newY = (y + displaceY).round();

        if (newX >= 0 && newX < width && newY >= 0 && newY < height) {
          final newIndex = newY * width + newX;

          // Apply fragmentation alpha based on progress
          final alpha = ((pixel >> 24) & 0xFF) * (1.0 - fragmentTime * 0.7);
          if (alpha > 10) {
            result[newIndex] = ((alpha.round() << 24) | (pixel & 0x00FFFFFF));
          }
        }
      }
    }
  }

  /// Draw expanding shockwave ring
  void _drawShockwave(
      Uint32List pixels, int width, int height, double centerX, double centerY, double progress, double intensity) {
    final shockRadius = progress * sqrt(width * width + height * height) * 0.8;
    final shockThickness = intensity * 8 + 2;
    final shockAlpha = (intensity * 255 * (1.0 - progress * 2)).round().clamp(0, 255);

    if (shockAlpha < 10) return;

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final distance = sqrt(pow(x - centerX, 2) + pow(y - centerY, 2));

        if ((distance - shockRadius).abs() < shockThickness) {
          final index = y * width + x;
          final distanceFromRing = (distance - shockRadius).abs();
          final ringIntensity = 1.0 - distanceFromRing / shockThickness;

          final alpha = (shockAlpha * ringIntensity).round().clamp(0, 255);
          if (alpha > 0) {
            // White/blue shockwave color
            final color = Color.fromARGB(alpha, 200, 220, 255);
            pixels[index] = _blendAdditive(pixels[index], color.value);
          }
        }
      }
    }
  }

  /// Draw fire effect at explosion center
  void _drawFireEffect(
      Uint32List pixels, int width, int height, double centerX, double centerY, double progress, double intensity) {
    final fireRadius = intensity * min(width, height) * 0.3 * (1.0 - progress);
    final fireAlpha = (intensity * 255 * (1.0 - progress * 1.5)).round().clamp(0, 255);

    if (fireAlpha < 10) return;

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final distance = sqrt(pow(x - centerX, 2) + pow(y - centerY, 2));

        if (distance < fireRadius) {
          final index = y * width + x;
          final fireIntensity = 1.0 - distance / fireRadius;

          // Create fire colors (red to yellow to white)
          Color fireColor;
          if (fireIntensity > 0.7) {
            fireColor = Color.fromARGB(fireAlpha, 255, 255, 200); // White hot center
          } else if (fireIntensity > 0.4) {
            fireColor = Color.fromARGB(fireAlpha, 255, 200, 0); // Yellow flames
          } else {
            fireColor = Color.fromARGB(fireAlpha, 255, 100, 0); // Orange/red flames
          }

          final alpha = (fireColor.alpha * fireIntensity).round().clamp(0, 255);
          if (alpha > 0) {
            final adjustedColor = Color.fromARGB(alpha, fireColor.red, fireColor.green, fireColor.blue);
            pixels[index] = _blendAdditive(pixels[index], adjustedColor.value);
          }
        }
      }
    }
  }

  /// Draw individual debris particle
  void _drawDebrisParticle(
      Uint32List result,
      Uint32List original,
      int width,
      int height,
      double centerX,
      double centerY,
      int particleId,
      double progress,
      double force,
      double particleSize,
      double gravity,
      double airResistance,
      double lifetime,
      double smokeEffect,
      double colorVariation,
      int seed) {
    // Generate deterministic random values for this particle
    final particleSeed = seed + particleId * 1337;
    final startAngle = _hash(particleSeed) * 2 * pi;
    final startSpeed = force * (0.5 + _hash(particleSeed + 1000) * 0.5);
    final particleLifespan = lifetime * (0.7 + _hash(particleSeed + 2000) * 0.6);

    // Calculate particle age (0 to 1, where 1 means particle is dead)
    final particleAge = progress / particleLifespan;
    if (particleAge > 1.0) return; // Particle is dead

    // Calculate position with physics
    final timeStep = progress * 10; // Scale time for visible movement
    final initialVelocityX = cos(startAngle) * startSpeed * min(width, height) * 0.1;
    final initialVelocityY = sin(startAngle) * startSpeed * min(width, height) * 0.1;

    // Apply air resistance (exponential decay)
    final dragFactor = exp(-airResistance * timeStep);
    final currentVelocityX = initialVelocityX * dragFactor;
    final currentVelocityY = initialVelocityY * dragFactor + gravity * timeStep * timeStep * min(width, height) * 0.05;

    // Calculate current position
    final currentX = centerX + currentVelocityX * timeStep;
    final currentY = centerY + currentVelocityY * timeStep;

    // Skip if particle is out of bounds
    if (currentX < 0 || currentX >= width || currentY < 0 || currentY >= height) return;

    // Calculate particle properties
    final size = particleSize * (3 + _hash(particleSeed + 3000) * 3); // 3-6 pixel radius
    final alpha = (255 * (1.0 - particleAge)).round().clamp(0, 255);

    if (alpha < 10) return;

    // Sample original image color for this particle (from starting position near center)
    final sampleX = (centerX + cos(startAngle) * 10).round().clamp(0, width - 1);
    final sampleY = (centerY + sin(startAngle) * 10).round().clamp(0, height - 1);
    final sampleIndex = sampleY * width + sampleX;
    final originalColor = original[sampleIndex];

    // Create particle color with variation
    Color particleColor = _applyColorVariation(Color(originalColor), colorVariation, particleSeed);
    particleColor = Color.fromARGB(alpha, particleColor.red, particleColor.green, particleColor.blue);

    // Draw particle
    _drawParticle(result, width, height, currentX.round(), currentY.round(), size.round(), particleColor);

    // Draw smoke trail if enabled
    if (smokeEffect > 0 && particleAge > 0.2) {
      _drawSmokeTrail(result, width, height, centerX, centerY, currentX, currentY, particleAge, smokeEffect, alpha);
    }
  }

  /// Apply color variation to particles
  Color _applyColorVariation(Color baseColor, double variation, int seed) {
    if (variation <= 0) return baseColor;

    final hueShift = (_hash(seed) - 0.5) * variation * 60; // ±30 degree hue shift
    final satShift = (_hash(seed + 1000) - 0.5) * variation * 0.3;
    final valShift = (_hash(seed + 2000) - 0.5) * variation * 0.2;

    final hsv = HSVColor.fromColor(baseColor);
    return hsv
        .withHue((hsv.hue + hueShift) % 360)
        .withSaturation((hsv.saturation + satShift).clamp(0.0, 1.0))
        .withValue((hsv.value + valShift).clamp(0.0, 1.0))
        .toColor();
  }

  /// Draw a single particle
  void _drawParticle(Uint32List pixels, int width, int height, int centerX, int centerY, int radius, Color color) {
    for (int dy = -radius; dy <= radius; dy++) {
      for (int dx = -radius; dx <= radius; dx++) {
        final distance = sqrt(dx * dx + dy * dy);
        if (distance <= radius) {
          final x = centerX + dx;
          final y = centerY + dy;

          if (x >= 0 && x < width && y >= 0 && y < height) {
            final index = y * width + x;
            final intensity = 1.0 - distance / radius;
            final particleAlpha = (color.alpha * intensity).round().clamp(0, 255);

            if (particleAlpha > 0) {
              final particleColor = Color.fromARGB(particleAlpha, color.red, color.green, color.blue);
              pixels[index] = _blendAdditive(pixels[index], particleColor.value);
            }
          }
        }
      }
    }
  }

  /// Draw smoke trail behind particle
  void _drawSmokeTrail(Uint32List pixels, int width, int height, double startX, double startY, double currentX,
      double currentY, double particleAge, double smokeIntensity, int baseAlpha) {
    final trailLength = 10;
    final smokeAlpha = (baseAlpha * smokeIntensity * (1.0 - particleAge)).round().clamp(0, 255);

    if (smokeAlpha < 5) return;

    for (int i = 0; i < trailLength; i++) {
      final t = i / trailLength;
      final trailX = (currentX + (startX - currentX) * t * 0.3).round();
      final trailY = (currentY + (startY - currentY) * t * 0.3).round();

      if (trailX >= 0 && trailX < width && trailY >= 0 && trailY < height) {
        final index = trailY * width + trailX;
        final trailAlpha = (smokeAlpha * (1.0 - t)).round().clamp(0, 255);

        if (trailAlpha > 0) {
          // Gray smoke color
          final smokeColor = Color.fromARGB(trailAlpha, 80, 80, 80);
          pixels[index] = _blendAlpha(pixels[index], smokeColor.value);
        }
      }
    }
  }

  /// Additive blending for bright effects
  int _blendAdditive(int base, int overlay) {
    final baseColor = Color(base);
    final overlayColor = Color(overlay);

    final newR = min(255, baseColor.red + overlayColor.red);
    final newG = min(255, baseColor.green + overlayColor.green);
    final newB = min(255, baseColor.blue + overlayColor.blue);
    final newA = max(baseColor.alpha, overlayColor.alpha);

    return Color.fromARGB(newA, newR, newG, newB).value;
  }

  /// Alpha blending for smoke effects
  int _blendAlpha(int base, int overlay) {
    final baseColor = Color(base);
    final overlayColor = Color(overlay);
    final alpha = overlayColor.alpha / 255.0;

    final newR = (baseColor.red * (1 - alpha) + overlayColor.red * alpha).round();
    final newG = (baseColor.green * (1 - alpha) + overlayColor.green * alpha).round();
    final newB = (baseColor.blue * (1 - alpha) + overlayColor.blue * alpha).round();
    final newA = max(baseColor.alpha, overlayColor.alpha);

    return Color.fromARGB(newA, newR, newG, newB).value;
  }

  /// Simple hash function for deterministic randomness
  double _hash(int input) {
    var h = input;
    h = ((h >> 16) ^ h) * 0x45d9f3b;
    h = ((h >> 16) ^ h) * 0x45d9f3b;
    h = (h >> 16) ^ h;
    return (h & 0xFFFFFF) / 0xFFFFFF; // 0 to 1
  }
}
