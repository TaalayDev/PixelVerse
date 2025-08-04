part of 'effects.dart';

class WoodEffect extends Effect {
  WoodEffect([Map<String, dynamic>? parameters])
      : super(
            EffectType.wood,
            parameters ??
                {
                  'woodType': 0, // 0=Oak, 1=Pine, 2=Cherry, 3=Walnut
                  'grainDirection': 0.0, // 0=horizontal, 0.5=diagonal, 1=vertical
                  'grainIntensity': 0.6,
                  'ringSpacing': 8.0,
                  'irregularity': 0.3,
                  'knotCount': 2,
                  'brightness': 0.0,
                });

  @override
  Map<String, dynamic> getDefaultParameters() => {
        'woodType': 0,
        'grainDirection': 0.0,
        'grainIntensity': 0.6,
        'ringSpacing': 8.0,
        'irregularity': 0.3,
        'knotCount': 2,
        'brightness': 0.0,
      };

  @override
  Map<String, dynamic> getMetadata() {
    return {
      'woodType': {
        'label': 'Wood Type',
        'description': 'Select the type of wood grain to apply.',
        'type': 'select',
        'options': {
          0: 'Oak',
          1: 'Pine',
          2: 'Cherry',
          3: 'Walnut',
        },
      },
      'grainDirection': {
        'label': 'Grain Direction',
        'description': 'Controls the direction of the wood grain.',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
      },
      'grainIntensity': {
        'label': 'Grain Intensity',
        'description': 'Adjusts the visibility of the wood grain.',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
      },
      'ringSpacing': {
        'label': 'Ring Spacing',
        'description': 'Determines the spacing between growth rings in the wood grain.',
        'type': 'slider',
        'min': 1.0,
        'max': 20.0,
        'divisions': 1,
      },
      'irregularity': {
        'label': 'Irregularity',
        'description': 'Adds random variations to the wood grain for a more natural look.',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
      },
      'knotCount': {
        'label': 'Knot Count',
        'description': "Number of knots in the wood grain, affecting its realism.",
        'type': 'slider',
        'min': 0,
        'max': 10,
        'divisions': 1,
      },
      'brightness': {
        'label': 'Brightness',
        'description': 'Adjusts the overall brightness of the wood effect.',
        'type': 'slider',
        'min': -1.0,
        'max': 1.0,
      },
    };
  }

  @override
  Uint32List apply(Uint32List pixels, int width, int height) {
    final result = Uint32List(width * height);
    final woodType = parameters['woodType'] as int;
    final grainDirection = parameters['grainDirection'] as double;
    final grainIntensity = parameters['grainIntensity'] as double;
    final ringSpacing = parameters['ringSpacing'] as double;
    final irregularity = parameters['irregularity'] as double;
    final knotCount = parameters['knotCount'] as int;
    final brightness = parameters['brightness'] as double;

    final random = Random(42); // Fixed seed for consistent wood patterns

    // Get wood color palette
    final woodColors = _getWoodColorPalette(woodType);

    // Generate knot positions
    final knots = <Point<double>>[];
    for (int i = 0; i < knotCount; i++) {
      knots.add(Point(
        random.nextDouble() * width,
        random.nextDouble() * height,
      ));
    }

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final index = y * width + x;

        // Calculate grain direction
        final grainAngle = grainDirection * pi;
        final rotatedX = x * cos(grainAngle) + y * sin(grainAngle);
        final rotatedY = -x * sin(grainAngle) + y * cos(grainAngle);

        // Create wood rings (growth rings)
        var ringDistance = _calculateRingDistance(rotatedX, rotatedY, ringSpacing);

        // Add irregularity to rings
        final noise1 = _woodNoise(x * 0.1, y * 0.1) * irregularity;
        final noise2 = _woodNoise(x * 0.05, y * 0.05) * irregularity * 0.5;
        ringDistance += noise1 + noise2;

        // Calculate grain pattern
        var grainValue = sin(ringDistance) * 0.5 + 0.5;

        // Add fine grain texture
        final fineGrain = _woodNoise(x * 0.3, y * 0.3) * 0.1;
        grainValue += fineGrain;

        // Apply grain intensity
        grainValue = 0.5 + (grainValue - 0.5) * grainIntensity;

        // Add knots
        var knotInfluence = 0.0;
        for (final knot in knots) {
          final distance = sqrt(pow(x - knot.x, 2) + pow(y - knot.y, 2));
          final knotSize = 8.0;

          if (distance < knotSize) {
            final knotStrength = 1.0 - (distance / knotSize);
            final knotPattern = sin(distance * 0.5) * knotStrength;
            knotInfluence += knotPattern * 0.3;
          }
        }

        grainValue += knotInfluence;
        grainValue = grainValue.clamp(0.0, 1.0);

        // Convert grain value to wood color
        final woodColor = _interpolateWoodColor(woodColors, grainValue);

        // Apply brightness adjustment
        final adjustedColor = _adjustBrightness(woodColor, brightness);

        result[index] = adjustedColor.value;
      }
    }

    return result;
  }

  List<Color> _getWoodColorPalette(int woodType) {
    switch (woodType) {
      case 0: // Oak
        return [
          const Color(0xFF8B4513), // Saddle brown
          const Color(0xFFCD853F), // Peru
          const Color(0xFFDEB887), // Burlywood
          const Color(0xFFF5DEB3), // Wheat
        ];
      case 1: // Pine
        return [
          const Color(0xFF8FBC8F), // Dark sea green
          const Color(0xFFDAA520), // Goldenrod
          const Color(0xFFFFE4B5), // Moccasin
          const Color(0xFFFFFACD), // Lemon chiffon
        ];
      case 2: // Cherry
        return [
          const Color(0xFF8B2635), // Dark red
          const Color(0xFFB22222), // Fire brick
          const Color(0xFFCD5C5C), // Indian red
          const Color(0xFFF08080), // Light coral
        ];
      case 3: // Walnut
        return [
          const Color(0xFF2F1B14), // Very dark brown
          const Color(0xFF654321), // Dark goldenrod
          const Color(0xFF8B4513), // Saddle brown
          const Color(0xFFA0522D), // Sienna
        ];
      default:
        return [
          const Color(0xFF8B4513),
          const Color(0xFFCD853F),
          const Color(0xFFDEB887),
          const Color(0xFFF5DEB3),
        ];
    }
  }

  double _calculateRingDistance(double x, double y, double spacing) {
    // Create concentric rings with some variation
    final centerX = 0.0; // Can be randomized for different effect
    final centerY = 0.0;

    final distance = sqrt(pow(x - centerX, 2) + pow(y - centerY, 2));
    return distance * 2.0 * pi / spacing;
  }

  double _woodNoise(double x, double y) {
    // Simple noise function for wood grain
    final seed = ((x * 12.9898 + y * 78.233) * 43758.5453).floor();
    final random = Random(seed);
    return random.nextDouble() * 2.0 - 1.0;
  }

  Color _interpolateWoodColor(List<Color> palette, double value) {
    if (palette.isEmpty) return Colors.brown;

    final scaledValue = value * (palette.length - 1);
    final index = scaledValue.floor();
    final fraction = scaledValue - index;

    if (index >= palette.length - 1) {
      return palette.last;
    }

    return Color.lerp(palette[index], palette[index + 1], fraction)!;
  }

  Color _adjustBrightness(Color color, double adjustment) {
    if (adjustment == 0) return color;

    final hsv = HSVColor.fromColor(color);
    final newValue = (hsv.value + adjustment).clamp(0.0, 1.0);

    return hsv.withValue(newValue).toColor();
  }
}
