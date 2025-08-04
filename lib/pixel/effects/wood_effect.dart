part of 'effects.dart';

/// Effect that transforms pixels to look like realistic wood grain
class WoodEffect extends Effect {
  WoodEffect([Map<String, dynamic>? parameters])
      : super(
          EffectType.wood,
          parameters ??
              const {
                'woodType': 0, // 0=Oak, 1=Pine, 2=Walnut, 3=Cherry, 4=Mahogany
                'grainDirection': 0.0, // 0-1 maps to 0-360°
                'grainIntensity': 0.7, // How pronounced the grain is
                'knotCount': 0, // Number of knots to add
                'ringSpacing': 8.0, // Distance between growth rings
                'colorVariation': 0.5, // Random color variation
              },
        );

  @override
  Map<String, dynamic> getDefaultParameters() {
    return {
      'woodType': 0, // Wood species (0-4)
      'grainDirection': 0.0, // Grain direction (0-1)
      'grainIntensity': 0.7, // Grain intensity (0-1)
      'knotCount': 0, // Number of knots (0-10)
      'ringSpacing': 8.0, // Growth ring spacing (2-20)
      'colorVariation': 0.5, // Color variation (0-1)
    };
  }

  @override
  Map<String, dynamic> getMetadata() {
    return {
      'woodType': {
        'label': 'Wood Type',
        'description': 'Select the type of wood grain pattern.',
        'type': 'select',
        'options': {
          0: 'Oak',
          1: 'Pine',
          2: 'Walnut',
          3: 'Cherry',
          4: 'Mahogany',
        },
      },
      'grainDirection': {
        'label': 'Grain Direction',
        'description': 'Controls the direction of the wood grain pattern.',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
      'grainIntensity': {
        'label': 'Grain Intensity',
        'description': 'Controls how pronounced the wood grain appears.',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
      'knotCount': {
        'label': 'Knot Count',
        'description': 'Number of wood knots to add to the texture.',
        'type': 'slider',
        'min': 0,
        'max': 10,
        'divisions': 10,
      },
      'ringSpacing': {
        'label': 'Ring Spacing',
        'description': 'Distance between growth rings in the wood.',
        'type': 'slider',
        'min': 2.0,
        'max': 20.0,
        'divisions': 18,
      },
      'colorVariation': {
        'label': 'Color Variation',
        'description': 'Amount of natural color variation in the wood.',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
    };
  }

  @override
  Uint32List apply(Uint32List pixels, int width, int height) {
    // Get parameters
    final woodType = (parameters['woodType'] as int).clamp(0, 4);
    final grainDirection = parameters['grainDirection'] as double;
    final grainIntensity = parameters['grainIntensity'] as double;
    final knotCount = (parameters['knotCount'] as int).clamp(0, 10);
    final ringSpacing = parameters['ringSpacing'] as double;
    final colorVariation = parameters['colorVariation'] as double;

    // Create result buffer
    final result = Uint32List(pixels.length);

    // Get wood colors based on type
    final woodColors = _getWoodColors(woodType);

    // Calculate grain angle in radians
    final grainAngle = grainDirection * 2 * pi;
    final sinAngle = sin(grainAngle);
    final cosAngle = cos(grainAngle);

    // Random generator with fixed seed for consistent results
    final random = Random(42);

    // Pre-generate knot positions
    final knots = <_WoodKnot>[];
    for (int i = 0; i < knotCount; i++) {
      knots.add(_WoodKnot(
        x: random.nextDouble() * width,
        y: random.nextDouble() * height,
        size: 3 + random.nextDouble() * 12, // 3-15 pixel radius
        intensity: 0.3 + random.nextDouble() * 0.5, // 0.3-0.8 intensity
      ));
    }

    // Process each pixel
    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final index = y * width + x;
        final originalPixel = pixels[index];

        // Skip transparent pixels
        final originalAlpha = (originalPixel >> 24) & 0xFF;
        if (originalAlpha == 0) {
          result[index] = 0;
          continue;
        }

        // Calculate wood grain pattern
        final woodColor = _calculateWoodColor(
          x.toDouble(),
          y.toDouble(),
          width,
          height,
          woodColors,
          grainAngle,
          sinAngle,
          cosAngle,
          grainIntensity,
          ringSpacing,
          colorVariation,
          knots,
          random,
        );

        // Preserve original alpha
        final finalColor = (originalAlpha << 24) | (woodColor & 0x00FFFFFF);
        result[index] = finalColor;
      }
    }

    return result;
  }

  // Get color palette for different wood types
  _WoodColors _getWoodColors(int woodType) {
    switch (woodType) {
      case 0: // Oak
        return _WoodColors(
          baseColor: const Color(0xFFD2B48C), // Tan
          darkColor: const Color(0xFF8B4513), // Saddle brown
          lightColor: const Color(0xFFF5DEB3), // Wheat
        );
      case 1: // Pine
        return _WoodColors(
          baseColor: const Color(0xFFFAEBD7), // Antique white
          darkColor: const Color(0xFFCD853F), // Peru
          lightColor: const Color(0xFFFFFAF0), // Floral white
        );
      case 2: // Walnut
        return _WoodColors(
          baseColor: const Color(0xFF8B4513), // Saddle brown
          darkColor: const Color(0xFF654321), // Dark brown
          lightColor: const Color(0xFFA0522D), // Sienna
        );
      case 3: // Cherry
        return _WoodColors(
          baseColor: const Color(0xFFDC143C), // Crimson
          darkColor: const Color(0xFF8B0000), // Dark red
          lightColor: const Color(0xFFFFB6C1), // Light pink
        );
      case 4: // Mahogany
        return _WoodColors(
          baseColor: const Color(0xFFC04000), // Mahogany
          darkColor: const Color(0xFF7B3F00), // Chocolate
          lightColor: const Color(0xFFD2691E), // Chocolate (lighter)
        );
      default:
        return _getWoodColors(0); // Default to oak
    }
  }

  // Calculate the wood color for a specific pixel
  int _calculateWoodColor(
    double x,
    double y,
    int width,
    int height,
    _WoodColors colors,
    double grainAngle,
    double sinAngle,
    double cosAngle,
    double grainIntensity,
    double ringSpacing,
    double colorVariation,
    List<_WoodKnot> knots,
    Random random,
  ) {
    // Transform coordinates based on grain direction
    final transformedX = x * cosAngle - y * sinAngle;
    final transformedY = x * sinAngle + y * cosAngle;

    // Calculate growth rings (concentric patterns)
    final centerX = width / 2;
    final centerY = height / 2;
    final distanceFromCenter = sqrt((x - centerX) * (x - centerX) + (y - centerY) * (y - centerY));
    final ringPosition = (distanceFromCenter / ringSpacing) % 1.0;
    final ringPattern = sin(ringPosition * 2 * pi) * 0.5 + 0.5;

    // Calculate wood grain pattern using Perlin-like noise
    final grainNoise1 = _perlinNoise(transformedX * 0.02, transformedY * 0.1, 0);
    final grainNoise2 = _perlinNoise(transformedX * 0.05, transformedY * 0.05, 1);
    final grainNoise3 = _perlinNoise(transformedX * 0.1, transformedY * 0.02, 2);

    // Combine noise layers for complex grain pattern
    final grainPattern = (grainNoise1 * 0.5 + grainNoise2 * 0.3 + grainNoise3 * 0.2);

    // Calculate knot influence
    double knotInfluence = 0.0;
    for (final knot in knots) {
      final distanceToKnot = sqrt((x - knot.x) * (x - knot.x) + (y - knot.y) * (y - knot.y));
      if (distanceToKnot < knot.size) {
        final knotStrength = (1.0 - distanceToKnot / knot.size) * knot.intensity;
        knotInfluence = max(knotInfluence, knotStrength);
      }
    }

    // Combine all patterns
    final combinedPattern = (ringPattern * 0.4 + grainPattern * 0.6) * grainIntensity;

    // Add color variation
    final variation = (_perlinNoise(x * 0.03, y * 0.03, 3) - 0.5) * colorVariation * 0.3;

    // Interpolate between colors based on pattern
    Color finalColor;
    if (knotInfluence > 0.1) {
      // Knot area - use darker color
      finalColor = Color.lerp(colors.darkColor, colors.baseColor, 1.0 - knotInfluence)!;
    } else {
      // Regular grain
      final t = (combinedPattern + variation).clamp(0.0, 1.0);
      if (t < 0.3) {
        finalColor = Color.lerp(colors.darkColor, colors.baseColor, t / 0.3)!;
      } else if (t < 0.7) {
        finalColor = colors.baseColor;
      } else {
        finalColor = Color.lerp(colors.baseColor, colors.lightColor, (t - 0.7) / 0.3)!;
      }
    }

    return finalColor.value;
  }

  // Simple Perlin-like noise function
  double _perlinNoise(double x, double y, int seed) {
    // Simple pseudo-random noise based on position and seed
    final n = (sin(x * 12.9898 + y * 78.233 + seed * 37.719) * 43758.5453);
    return (n - n.floor()) * 2 - 1; // Return value between -1 and 1
  }
}

// Helper classes for wood effect
class _WoodColors {
  final Color baseColor;
  final Color darkColor;
  final Color lightColor;

  _WoodColors({
    required this.baseColor,
    required this.darkColor,
    required this.lightColor,
  });
}

class _WoodKnot {
  final double x;
  final double y;
  final double size;
  final double intensity;

  _WoodKnot({
    required this.x,
    required this.y,
    required this.size,
    required this.intensity,
  });
}
