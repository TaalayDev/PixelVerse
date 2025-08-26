part of 'effects.dart';

/// Effect that creates various dissolve/disintegration animations
class DissolveEffect extends Effect {
  DissolveEffect([Map<String, dynamic>? parameters])
      : super(
          EffectType.dissolve,
          parameters ??
              const {
                'progress': 0.0, // Dissolve progress (0-1)
                'dissolveType': 0, // 0=noise, 1=blocks, 2=circles, 3=digital, 4=burn
                'edgeWidth': 0.1, // Width of dissolve edge (0-1)
                'edgeColor': 0xFFFF6600, // Color of dissolve edge (orange)
                'noiseScale': 0.5, // Scale of noise pattern (0-1)
                'softness': 0.3, // Softness of dissolve edge (0-1)
                'direction': 0, // 0=random, 1=left-right, 2=top-bottom, 3=center-out
                'animated': true, // Whether dissolve pattern moves
                'randomSeed': 42, // Seed for noise pattern
                'time': 0.0, // Animation time parameter (0-1)
              },
        );

  @override
  Map<String, dynamic> getDefaultParameters() {
    return {
      'progress': 0.0,
      'dissolveType': 0,
      'edgeWidth': 0.1,
      'edgeColor': 0xFFFF6600,
      'noiseScale': 0.5,
      'softness': 0.3,
      'direction': 0,
      'animated': true,
      'randomSeed': 42,
      'time': 0.0,
    };
  }

  @override
  Map<String, dynamic> getMetadata() {
    return {
      'progress': {
        'label': 'Dissolve Progress',
        'description': 'How much of the image has dissolved (0 = none, 1 = complete).',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
      'dissolveType': {
        'label': 'Dissolve Type',
        'description': 'Different dissolve patterns and styles.',
        'type': 'select',
        'options': {
          0: 'Noise Dissolve',
          1: 'Block Dissolve',
          2: 'Circle Dissolve',
          3: 'Digital Dissolve',
          4: 'Burn Dissolve',
        },
      },
      'edgeWidth': {
        'label': 'Edge Width',
        'description': 'Width of the glowing edge during dissolve.',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
      'edgeColor': {
        'label': 'Edge Color',
        'description': 'Color of the dissolve edge effect.',
        'type': 'color',
      },
      'noiseScale': {
        'label': 'Pattern Scale',
        'description': 'Scale of the dissolve pattern (smaller = more detailed).',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
      'softness': {
        'label': 'Edge Softness',
        'description': 'How soft/blurred the dissolve edges are.',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
      'direction': {
        'label': 'Dissolve Direction',
        'description': 'Direction of the dissolve progression.',
        'type': 'select',
        'options': {
          0: 'Random Pattern',
          1: 'Left to Right',
          2: 'Top to Bottom',
          3: 'Center Outward',
          4: 'Bottom to Top',
          5: 'Right to Left',
        },
      },
      'animated': {
        'label': 'Animated Pattern',
        'description': 'Whether the dissolve pattern moves over time.',
        'type': 'bool',
      },
      'randomSeed': {
        'label': 'Pattern Seed',
        'description': 'Changes the random dissolve pattern.',
        'type': 'slider',
        'min': 1,
        'max': 100,
        'divisions': 99,
      },
    };
  }

  @override
  Uint32List apply(Uint32List pixels, int width, int height) {
    final progress = (parameters['progress'] as double).clamp(0.0, 1.0);
    final dissolveType = parameters['dissolveType'] as int;
    final edgeWidth = parameters['edgeWidth'] as double;
    final edgeColor = Color(parameters['edgeColor'] as int);
    final noiseScale = parameters['noiseScale'] as double;
    final softness = parameters['softness'] as double;
    final direction = parameters['direction'] as int;
    final animated = parameters['animated'] as bool;
    final randomSeed = parameters['randomSeed'] as int;
    final time = parameters['time'] as double;

    final result = Uint32List(pixels.length);

    // Animation offset
    final animOffset = animated ? time * 2 : 0.0;

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final index = y * width + x;
        final originalPixel = pixels[index];

        // Skip transparent pixels
        if (((originalPixel >> 24) & 0xFF) == 0) {
          result[index] = 0;
          continue;
        }

        // Calculate dissolve value based on type
        final dissolveValue =
            _calculateDissolveValue(x, y, width, height, dissolveType, direction, noiseScale, randomSeed, animOffset);

        // Apply dissolve logic
        final dissolveResult = _applyDissolve(originalPixel, dissolveValue, progress, edgeWidth, edgeColor, softness);

        result[index] = dissolveResult;
      }
    }

    return result;
  }

  /// Calculate dissolve value (0-1) for a pixel based on dissolve type
  double _calculateDissolveValue(int x, int y, int width, int height, int dissolveType, int direction,
      double noiseScale, int randomSeed, double animOffset) {
    final normalizedX = x / width;
    final normalizedY = y / height;

    switch (dissolveType) {
      case 0: // Noise dissolve
        return _noiseDissolve(x, y, noiseScale, randomSeed, animOffset);

      case 1: // Block dissolve
        return _blockDissolve(x, y, width, height, noiseScale, randomSeed);

      case 2: // Circle dissolve
        return _circleDissolve(x, y, width, height, noiseScale, randomSeed);

      case 3: // Digital dissolve
        return _digitalDissolve(x, y, width, height, randomSeed, animOffset);

      case 4: // Burn dissolve
        return _burnDissolve(x, y, width, height, noiseScale, randomSeed, animOffset);

      default:
        return _noiseDissolve(x, y, noiseScale, randomSeed, animOffset);
    }
  }

  /// Noise-based dissolve using Perlin-like noise
  double _noiseDissolve(int x, int y, double scale, int seed, double animOffset) {
    final noiseX = x * (scale * 0.1 + 0.01) + animOffset;
    final noiseY = y * (scale * 0.1 + 0.01) + animOffset * 0.7;

    // Multi-octave noise for more complex patterns
    final noise1 = _perlinNoise(noiseX, noiseY, seed);
    final noise2 = _perlinNoise(noiseX * 2, noiseY * 2, seed + 1000) * 0.5;
    final noise3 = _perlinNoise(noiseX * 4, noiseY * 4, seed + 2000) * 0.25;

    return ((noise1 + noise2 + noise3) * 0.5 + 0.5).clamp(0.0, 1.0);
  }

  /// Block-based dissolve with rectangular chunks
  double _blockDissolve(int x, int y, int width, int height, double scale, int seed) {
    final blockSize = (scale * 20 + 4).round().clamp(2, 30);
    final blockX = x ~/ blockSize;
    final blockY = y ~/ blockSize;

    // Hash the block coordinates for randomness
    final blockHash = _hash(blockX * 73856093 ^ blockY * 19349663 ^ seed);
    return blockHash;
  }

  /// Circle-based dissolve with varying circle sizes
  double _circleDissolve(int x, int y, int width, int height, double scale, int seed) {
    final circleSize = (scale * 15 + 3).round().clamp(2, 20);
    final gridX = x ~/ circleSize;
    final gridY = y ~/ circleSize;

    // Center of the circle in this grid cell
    final centerX = gridX * circleSize + circleSize / 2;
    final centerY = gridY * circleSize + circleSize / 2;

    // Distance from circle center
    final distance = sqrt(pow(x - centerX, 2) + pow(y - centerY, 2));
    final maxDistance = circleSize / 2;

    // Random radius for this circle
    final circleHash = _hash(gridX * 73856093 ^ gridY * 19349663 ^ seed);
    final circleRadius = maxDistance * (0.3 + circleHash * 0.7);

    // Return inverse distance (closer to center = higher value)
    return (1.0 - (distance / circleRadius).clamp(0.0, 1.0));
  }

  /// Digital/glitch-style dissolve
  double _digitalDissolve(int x, int y, int width, int height, int seed, double animOffset) {
    // Create horizontal scanlines with glitch effect
    final scanlineHeight = 3;
    final scanlineY = y ~/ scanlineHeight;

    // Random value per scanline
    final scanlineHash = _hash(scanlineY * 19349663 ^ seed);

    // Add some horizontal displacement
    final glitchX = x + (sin(scanlineY * 0.3 + animOffset * 5) * 10).round();
    final pixelHash = _hash(glitchX * 73856093 ^ y * 19349663 ^ seed);

    // Combine scanline and pixel randomness
    return (scanlineHash * 0.7 + pixelHash * 0.3);
  }

  /// Burn-style dissolve with organic patterns
  double _burnDissolve(int x, int y, int width, int height, double scale, int seed, double animOffset) {
    // Multiple layers of noise for organic burning effect
    final baseScale = scale * 0.05 + 0.01;

    final burnNoise1 = _perlinNoise(x * baseScale + animOffset, y * baseScale, seed);
    final burnNoise2 = _perlinNoise(x * baseScale * 2, y * baseScale * 2 + animOffset, seed + 500);
    final burnNoise3 = _perlinNoise(x * baseScale * 4 + animOffset * 0.5, y * baseScale * 4, seed + 1000);

    // Combine noises with different weights for organic feel
    final combinedNoise = burnNoise1 * 0.5 + burnNoise2 * 0.3 + burnNoise3 * 0.2;

    // Add some directional bias (burning upward)
    final heightBias = (height - y) / height * 0.2;

    return (combinedNoise * 0.5 + 0.5 + heightBias).clamp(0.0, 1.0);
  }

  /// Apply dissolve effect to a pixel
  int _applyDissolve(
      int originalPixel, double dissolveValue, double progress, double edgeWidth, Color edgeColor, double softness) {
    // Adjust dissolve value based on direction
    final adjustedDissolveValue = dissolveValue;

    // Calculate dissolve threshold
    final threshold = progress;
    final edgeStart = threshold - edgeWidth;
    final edgeEnd = threshold;

    if (adjustedDissolveValue < edgeStart - softness) {
      // Pixel is fully dissolved
      return 0;
    } else if (adjustedDissolveValue > edgeEnd + softness) {
      // Pixel is fully visible
      return originalPixel;
    } else if (adjustedDissolveValue >= edgeStart && adjustedDissolveValue <= edgeEnd) {
      // Pixel is in the edge zone - apply edge color
      final edgeProgress = (adjustedDissolveValue - edgeStart) / edgeWidth;
      return _blendWithEdge(originalPixel, edgeColor, edgeProgress, softness);
    } else {
      // Pixel is in transition zone - apply alpha fade
      double alpha;
      if (adjustedDissolveValue < edgeStart) {
        // Fading out
        alpha = (adjustedDissolveValue - (edgeStart - softness)) / softness;
      } else {
        // Fading in
        alpha = 1.0 - (adjustedDissolveValue - edgeEnd) / softness;
      }

      alpha = alpha.clamp(0.0, 1.0);
      return _applyAlpha(originalPixel, alpha);
    }
  }

  /// Blend pixel with edge color
  int _blendWithEdge(int originalPixel, Color edgeColor, double edgeProgress, double softness) {
    final origA = (originalPixel >> 24) & 0xFF;
    final origR = (originalPixel >> 16) & 0xFF;
    final origG = (originalPixel >> 8) & 0xFF;
    final origB = originalPixel & 0xFF;

    // Edge intensity based on progress through edge
    final edgeIntensity = sin(edgeProgress * pi) * (1.0 - softness * 0.5);

    // Brighten the original color and blend with edge color
    final brightR = min(255, (origR * (1.5 + edgeIntensity)).round());
    final brightG = min(255, (origG * (1.5 + edgeIntensity)).round());
    final brightB = min(255, (origB * (1.5 + edgeIntensity)).round());

    // Blend with edge color
    final blendFactor = edgeIntensity * 0.6;
    final finalR = (brightR * (1 - blendFactor) + edgeColor.red * blendFactor).round();
    final finalG = (brightG * (1 - blendFactor) + edgeColor.green * blendFactor).round();
    final finalB = (brightB * (1 - blendFactor) + edgeColor.blue * blendFactor).round();

    return (origA << 24) | (finalR << 16) | (finalG << 8) | finalB;
  }

  /// Apply alpha transparency to pixel
  int _applyAlpha(int pixel, double alpha) {
    final originalAlpha = (pixel >> 24) & 0xFF;
    final newAlpha = (originalAlpha * alpha).round().clamp(0, 255);
    return (newAlpha << 24) | (pixel & 0x00FFFFFF);
  }

  /// 2D Perlin-like noise
  double _perlinNoise(double x, double y, int seed) {
    final intX = x.floor();
    final intY = y.floor();
    final fracX = x - intX;
    final fracY = y - intY;

    // Get corner values
    final a = _hash2D(intX, intY, seed);
    final b = _hash2D(intX + 1, intY, seed);
    final c = _hash2D(intX, intY + 1, seed);
    final d = _hash2D(intX + 1, intY + 1, seed);

    // Smooth interpolation
    final u = fracX * fracX * (3 - 2 * fracX);
    final v = fracY * fracY * (3 - 2 * fracY);

    // Bilinear interpolation
    final i1 = a * (1 - u) + b * u;
    final i2 = c * (1 - u) + d * u;
    final result = i1 * (1 - v) + i2 * v;

    return result * 2 - 1; // -1 to 1
  }

  /// 2D hash function
  double _hash2D(int x, int y, int seed) {
    var h = x * 73856093 ^ y * 19349663 ^ seed;
    h = ((h >> 16) ^ h) * 0x45d9f3b;
    h = ((h >> 16) ^ h) * 0x45d9f3b;
    h = (h >> 16) ^ h;
    return (h & 0xFFFFFF) / 0xFFFFFF; // 0 to 1
  }

  /// Simple hash function
  double _hash(int input) {
    var h = input;
    h = ((h >> 16) ^ h) * 0x45d9f3b;
    h = ((h >> 16) ^ h) * 0x45d9f3b;
    h = (h >> 16) ^ h;
    return (h & 0xFFFFFF) / 0xFFFFFF; // 0 to 1
  }
}

/// Simple dissolve effect for basic fade-out animations
class FadeDissolveEffect extends Effect {
  FadeDissolveEffect([Map<String, dynamic>? parameters])
      : super(
          EffectType.fadeDissolve,
          parameters ??
              const {
                'progress': 0.0, // Fade progress (0-1)
                'fadeType': 0, // 0=uniform, 1=radial, 2=linear
                'direction': 0.0, // Direction for linear fade (0-1 = 0-360°)
                'centerX': 0.5, // Center X for radial fade (0-1)
                'centerY': 0.5, // Center Y for radial fade (0-1)
                'softness': 0.3, // Edge softness (0-1)
              },
        );

  @override
  Map<String, dynamic> getDefaultParameters() {
    return {
      'progress': 0.0,
      'fadeType': 0,
      'direction': 0.0,
      'centerX': 0.5,
      'centerY': 0.5,
      'softness': 0.3,
    };
  }

  @override
  Map<String, dynamic> getMetadata() {
    return {
      'progress': {
        'label': 'Fade Progress',
        'description': 'How much the image has faded (0 = visible, 1 = invisible).',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
      'fadeType': {
        'label': 'Fade Type',
        'description': 'Type of fade pattern.',
        'type': 'select',
        'options': {
          0: 'Uniform Fade',
          1: 'Radial Fade',
          2: 'Linear Fade',
        },
      },
      'direction': {
        'label': 'Fade Direction',
        'description': 'Direction for linear fade (0 = right, 0.25 = down, 0.5 = left, 0.75 = up).',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
      'centerX': {
        'label': 'Center X',
        'description': 'Horizontal center for radial fade.',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
      'centerY': {
        'label': 'Center Y',
        'description': 'Vertical center for radial fade.',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
      'softness': {
        'label': 'Edge Softness',
        'description': 'How soft the fade edges are.',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
    };
  }

  @override
  Uint32List apply(Uint32List pixels, int width, int height) {
    final progress = (parameters['progress'] as double).clamp(0.0, 1.0);
    final fadeType = parameters['fadeType'] as int;
    final direction = parameters['direction'] as double;
    final centerX = parameters['centerX'] as double;
    final centerY = parameters['centerY'] as double;
    final softness = parameters['softness'] as double;

    final result = Uint32List(pixels.length);

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final index = y * width + x;
        final pixel = pixels[index];

        if (((pixel >> 24) & 0xFF) == 0) {
          result[index] = 0;
          continue;
        }

        // Calculate fade factor based on type
        double fadeFactor;

        switch (fadeType) {
          case 0: // Uniform fade
            fadeFactor = progress;
            break;

          case 1: // Radial fade
            final dx = (x / width) - centerX;
            final dy = (y / height) - centerY;
            final distance = sqrt(dx * dx + dy * dy);
            final maxDistance = sqrt(0.5 * 0.5 + 0.5 * 0.5); // Corner distance

            final normalizedDistance = (distance / maxDistance).clamp(0.0, 1.0);
            fadeFactor = (progress - normalizedDistance + softness).clamp(0.0, 1.0);
            if (softness > 0) {
              fadeFactor = fadeFactor / (softness + 0.001);
            }
            fadeFactor = (1.0 - fadeFactor).clamp(0.0, 1.0);
            break;

          case 2: // Linear fade
            final angle = direction * 2 * pi;
            final projX = cos(angle);
            final projY = sin(angle);

            // Project pixel position onto direction vector
            final normalizedX = (x / width) - 0.5;
            final normalizedY = (y / height) - 0.5;
            final projection = normalizedX * projX + normalizedY * projY;

            // Convert projection to 0-1 range
            final normalizedProjection = (projection + 0.707) / 1.414; // sqrt(2)/2

            fadeFactor = (progress - normalizedProjection + softness).clamp(0.0, 1.0);
            if (softness > 0) {
              fadeFactor = fadeFactor / (softness + 0.001);
            }
            fadeFactor = (1.0 - fadeFactor).clamp(0.0, 1.0);
            break;

          default:
            fadeFactor = progress;
        }

        // Apply fade
        final alpha = 1.0 - fadeFactor;
        final originalAlpha = (pixel >> 24) & 0xFF;
        final newAlpha = (originalAlpha * alpha).round().clamp(0, 255);

        result[index] = (newAlpha << 24) | (pixel & 0x00FFFFFF);
      }
    }

    return result;
  }
}
