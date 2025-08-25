part of 'effects.dart';

/// Effect that transforms pixels to look like various types of stone and rock surfaces
class StoneEffect extends Effect {
  StoneEffect([Map<String, dynamic>? parameters])
      : super(
          EffectType.stone,
          parameters ??
              const {
                'stoneType': 0, // 0=marble, 1=granite, 2=sandstone, 3=slate, 4=limestone, 5=volcanic
                'roughness': 0.5, // Surface roughness/texture (0-1)
                'weathering': 0.3, // Amount of weathering/erosion (0-1)
                'crackIntensity': 0.2, // Intensity of cracks and fissures (0-1)
                'colorVariation': 0.4, // Natural color variation (0-1)
                'patternScale': 0.5, // Scale of stone patterns (0-1)
                'shininess': 0.3, // Surface reflectivity (0-1)
                'sedimentLayers': 0.4, // Sedimentary layering (0-1)
                'mineralSpots': 0.3, // Mineral deposits and spots (0-1)
                'randomSeed': 42, // Seed for pattern generation
              },
        );

  @override
  Map<String, dynamic> getDefaultParameters() {
    return {
      'stoneType': 0,
      'roughness': 0.5,
      'weathering': 0.3,
      'crackIntensity': 0.2,
      'colorVariation': 0.4,
      'patternScale': 0.5,
      'shininess': 0.3,
      'sedimentLayers': 0.4,
      'mineralSpots': 0.3,
      'randomSeed': 42,
    };
  }

  @override
  Map<String, dynamic> getMetadata() {
    return {
      'stoneType': {
        'label': 'Stone Type',
        'description': 'Select the type of stone texture to simulate.',
        'type': 'select',
        'options': {
          0: 'Marble',
          1: 'Granite',
          2: 'Sandstone',
          3: 'Slate',
          4: 'Limestone',
          5: 'Volcanic Rock',
        },
      },
      'roughness': {
        'label': 'Surface Roughness',
        'description': 'Controls the texture and bumpiness of the stone surface.',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
      'weathering': {
        'label': 'Weathering',
        'description': 'Amount of erosion and aging effects on the stone.',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
      'crackIntensity': {
        'label': 'Crack Intensity',
        'description': 'Intensity of cracks, fissures, and fractures in the stone.',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
      'colorVariation': {
        'label': 'Color Variation',
        'description': 'Natural color variations and mineral streaks.',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
      'patternScale': {
        'label': 'Pattern Scale',
        'description': 'Scale of stone patterns and formations.',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
      'shininess': {
        'label': 'Surface Shininess',
        'description': 'How polished and reflective the stone surface appears.',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
      'sedimentLayers': {
        'label': 'Sediment Layers',
        'description': 'Visible sedimentary layering in the stone.',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
      'mineralSpots': {
        'label': 'Mineral Spots',
        'description': 'Mineral deposits, crystals, and inclusion spots.',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
      'randomSeed': {
        'label': 'Pattern Seed',
        'description': 'Changes the random stone pattern.',
        'type': 'slider',
        'min': 1,
        'max': 100,
        'divisions': 99,
      },
    };
  }

  @override
  Uint32List apply(Uint32List pixels, int width, int height) {
    final stoneType = (parameters['stoneType'] as int).clamp(0, 5);
    final roughness = parameters['roughness'] as double;
    final weathering = parameters['weathering'] as double;
    final crackIntensity = parameters['crackIntensity'] as double;
    final colorVariation = parameters['colorVariation'] as double;
    final patternScale = parameters['patternScale'] as double;
    final shininess = parameters['shininess'] as double;
    final sedimentLayers = parameters['sedimentLayers'] as double;
    final mineralSpots = parameters['mineralSpots'] as double;
    final randomSeed = parameters['randomSeed'] as int;

    final result = Uint32List(pixels.length);
    final random = Random(randomSeed);

    // Get base stone colors for the selected type
    final stoneColors = _getStoneColors(stoneType);

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

        // Calculate base stone pattern
        final stonePixel = _calculateStoneTexture(
          x,
          y,
          width,
          height,
          stoneType,
          stoneColors,
          roughness,
          weathering,
          crackIntensity,
          colorVariation,
          patternScale,
          shininess,
          sedimentLayers,
          mineralSpots,
          random,
        );

        // Preserve original alpha
        final finalColor = (originalAlpha << 24) | (stonePixel & 0x00FFFFFF);
        result[index] = finalColor;
      }
    }

    return result;
  }

  /// Get color palette for different stone types
  _StoneColors _getStoneColors(int stoneType) {
    switch (stoneType) {
      case 0: // Marble
        return _StoneColors(
          baseColor: const Color(0xFFF5F5F0), // Cream white
          darkColor: const Color(0xFF8B8680), // Gray veins
          lightColor: const Color(0xFFFFFFF8), // Pure white
          accentColor: const Color(0xFFD4AF37), // Gold veins
        );
      case 1: // Granite
        return _StoneColors(
          baseColor: const Color(0xFF696969), // Dark gray
          darkColor: const Color(0xFF2F2F2F), // Charcoal
          lightColor: const Color(0xFFC0C0C0), // Silver
          accentColor: const Color(0xFFCD853F), // Sandy brown
        );
      case 2: // Sandstone
        return _StoneColors(
          baseColor: const Color(0xFFDEB887), // Burlywood
          darkColor: const Color(0xFF8B7355), // Dark khaki
          lightColor: const Color(0xFFF5DEB3), // Wheat
          accentColor: const Color(0xFFD2691E), // Chocolate
        );
      case 3: // Slate
        return _StoneColors(
          baseColor: const Color(0xFF2F4F4F), // Dark slate gray
          darkColor: const Color(0xFF191970), // Midnight blue
          lightColor: const Color(0xFF708090), // Slate gray
          accentColor: const Color(0xFF4682B4), // Steel blue
        );
      case 4: // Limestone
        return _StoneColors(
          baseColor: const Color(0xFFF0E68C), // Khaki
          darkColor: const Color(0xFFBDB76B), // Dark khaki
          lightColor: const Color(0xFFFFFACD), // Lemon chiffon
          accentColor: const Color(0xFFDAA520), // Goldenrod
        );
      case 5: // Volcanic
        return _StoneColors(
          baseColor: const Color(0xFF36454F), // Charcoal
          darkColor: const Color(0xFF000000), // Black
          lightColor: const Color(0xFF696969), // Dim gray
          accentColor: const Color(0xFF8B0000), // Dark red
        );
      default:
        return _getStoneColors(0);
    }
  }

  /// Calculate stone texture for a specific pixel
  int _calculateStoneTexture(
    int x,
    int y,
    int width,
    int height,
    int stoneType,
    _StoneColors colors,
    double roughness,
    double weathering,
    double crackIntensity,
    double colorVariation,
    double patternScale,
    double shininess,
    double sedimentLayers,
    double mineralSpots,
    Random random,
  ) {
    // Base pattern scale
    final scale = 0.01 + patternScale * 0.05;

    // Generate base stone pattern based on type
    Color baseStoneColor;

    switch (stoneType) {
      case 0: // Marble
        baseStoneColor = _generateMarblePattern(x, y, colors, scale, colorVariation);
        break;
      case 1: // Granite
        baseStoneColor = _generateGranitePattern(x, y, colors, scale, colorVariation, random);
        break;
      case 2: // Sandstone
        baseStoneColor = _generateSandstonePattern(x, y, colors, scale, colorVariation, sedimentLayers);
        break;
      case 3: // Slate
        baseStoneColor = _generateSlatePattern(x, y, colors, scale, colorVariation, sedimentLayers);
        break;
      case 4: // Limestone
        baseStoneColor = _generateLimestonePattern(x, y, colors, scale, colorVariation);
        break;
      case 5: // Volcanic
        baseStoneColor = _generateVolcanicPattern(x, y, colors, scale, colorVariation, random);
        break;
      default:
        baseStoneColor = colors.baseColor;
    }

    // Apply surface effects
    baseStoneColor = _applySurfaceRoughness(baseStoneColor, x, y, roughness, random);
    baseStoneColor = _applyWeathering(baseStoneColor, x, y, weathering, random);
    baseStoneColor = _applyCracks(baseStoneColor, x, y, crackIntensity, colors.darkColor, random);
    baseStoneColor = _applyMineralSpots(baseStoneColor, x, y, mineralSpots, colors.accentColor, random);
    baseStoneColor = _applyShininess(baseStoneColor, x, y, width, height, shininess);

    return baseStoneColor.value;
  }

  /// Generate marble veining pattern
  Color _generateMarblePattern(int x, int y, _StoneColors colors, double scale, double variation) {
    // Primary veining
    final vein1 = _perlinNoise(x * scale * 0.5, y * scale * 2, 100);
    final vein2 = _perlinNoise(x * scale * 2, y * scale * 0.5, 200);

    // Secondary veining
    final subVein = _perlinNoise(x * scale * 5, y * scale * 5, 300) * 0.3;

    final veinPattern = (vein1 + vein2 + subVein) * 0.5 + 0.5;

    // Create marble color based on vein pattern
    if (veinPattern < 0.3) {
      return Color.lerp(colors.darkColor, colors.baseColor, veinPattern / 0.3)!;
    } else if (veinPattern < 0.7) {
      return colors.baseColor;
    } else {
      return Color.lerp(colors.baseColor, colors.lightColor, (veinPattern - 0.7) / 0.3)!;
    }
  }

  /// Generate granite speckled pattern
  Color _generateGranitePattern(int x, int y, _StoneColors colors, double scale, double variation, Random random) {
    // Base granite color
    final baseNoise = _perlinNoise(x * scale, y * scale, 400) * 0.5 + 0.5;
    Color graniteColor = Color.lerp(colors.darkColor, colors.baseColor, baseNoise)!;

    // Add mineral speckles
    final speckleNoise = _perlinNoise(x * scale * 10, y * scale * 10, 500);
    if (speckleNoise > 0.6) {
      graniteColor = Color.lerp(graniteColor, colors.lightColor, 0.7)!;
    } else if (speckleNoise < -0.6) {
      graniteColor = Color.lerp(graniteColor, colors.accentColor, 0.5)!;
    }

    return graniteColor;
  }

  /// Generate sandstone layered pattern
  Color _generateSandstonePattern(int x, int y, _StoneColors colors, double scale, double variation, double layers) {
    // Horizontal layering
    final layerPattern = sin(y * scale * 20 * layers) * 0.3 + 0.7;

    // Sand grain texture
    final grainNoise = _perlinNoise(x * scale * 15, y * scale * 15, 600) * 0.2;

    final combinedPattern = (layerPattern + grainNoise).clamp(0.0, 1.0);

    return Color.lerp(colors.darkColor, colors.lightColor, combinedPattern)!;
  }

  /// Generate slate layered pattern
  Color _generateSlatePattern(int x, int y, _StoneColors colors, double scale, double variation, double layers) {
    // Diagonal layering typical of slate
    final layerAngle = (x + y * 0.3) * scale * 30 * layers;
    final layerPattern = sin(layerAngle) * 0.4 + 0.6;

    // Fine texture
    final fineTexture = _perlinNoise(x * scale * 8, y * scale * 8, 700) * 0.3;

    final combinedPattern = (layerPattern + fineTexture).clamp(0.0, 1.0);

    return Color.lerp(colors.darkColor, colors.lightColor, combinedPattern)!;
  }

  /// Generate limestone pattern
  Color _generateLimestonePattern(int x, int y, _StoneColors colors, double scale, double variation) {
    // Irregular limestone texture
    final texture1 = _perlinNoise(x * scale * 2, y * scale * 2, 800);
    final texture2 = _perlinNoise(x * scale * 6, y * scale * 6, 900) * 0.5;

    final combinedTexture = (texture1 + texture2) * 0.5 + 0.5;

    return Color.lerp(colors.darkColor, colors.lightColor, combinedTexture)!;
  }

  /// Generate volcanic rock pattern
  Color _generateVolcanicPattern(int x, int y, _StoneColors colors, double scale, double variation, Random random) {
    // Rough volcanic texture
    final roughTexture = _perlinNoise(x * scale * 8, y * scale * 8, 1000);

    // Add vesicles (air bubbles)
    final vesicleNoise = _perlinNoise(x * scale * 20, y * scale * 20, 1100);
    if (vesicleNoise > 0.7) {
      return colors.darkColor; // Dark vesicle
    }

    // Lava flow patterns
    final flowPattern = _perlinNoise(x * scale * 0.5, y * scale * 4, 1200) * 0.5 + 0.5;

    return Color.lerp(colors.darkColor, colors.lightColor, flowPattern)!;
  }

  /// Apply surface roughness effect
  Color _applySurfaceRoughness(Color baseColor, int x, int y, double roughness, Random random) {
    if (roughness <= 0) return baseColor;

    final roughnessNoise = _perlinNoise(x * 0.1, y * 0.1, 1300) * roughness * 0.3;

    final hsv = HSVColor.fromColor(baseColor);
    final newValue = (hsv.value + roughnessNoise).clamp(0.0, 1.0);

    return hsv.withValue(newValue).toColor();
  }

  /// Apply weathering effects
  Color _applyWeathering(Color baseColor, int x, int y, double weathering, Random random) {
    if (weathering <= 0) return baseColor;

    final weatheringNoise = _perlinNoise(x * 0.05, y * 0.05, 1400);
    if (weatheringNoise > (1.0 - weathering)) {
      // Weathered areas are lighter and more desaturated
      final hsv = HSVColor.fromColor(baseColor);
      final newSaturation = (hsv.saturation * (1.0 - weathering * 0.5)).clamp(0.0, 1.0);
      final newValue = (hsv.value + weathering * 0.2).clamp(0.0, 1.0);

      return hsv.withSaturation(newSaturation).withValue(newValue).toColor();
    }

    return baseColor;
  }

  /// Apply crack patterns
  Color _applyCracks(Color baseColor, int x, int y, double intensity, Color crackColor, Random random) {
    if (intensity <= 0) return baseColor;

    // Generate crack patterns using noise
    final crackNoise1 = _perlinNoise(x * 0.02, y * 0.5, 1500);
    final crackNoise2 = _perlinNoise(x * 0.5, y * 0.02, 1600);

    final crackValue = max(crackNoise1.abs(), crackNoise2.abs());

    if (crackValue > (1.0 - intensity * 0.3)) {
      // This pixel is part of a crack
      final crackStrength = (crackValue - (1.0 - intensity * 0.3)) / (intensity * 0.3);
      return Color.lerp(baseColor, crackColor, crackStrength * 0.8)!;
    }

    return baseColor;
  }

  /// Apply mineral spots and inclusions
  Color _applyMineralSpots(Color baseColor, int x, int y, double intensity, Color mineralColor, Random random) {
    if (intensity <= 0) return baseColor;

    final spotNoise = _perlinNoise(x * 0.08, y * 0.08, 1700);

    if (spotNoise > (1.0 - intensity * 0.2)) {
      // Mineral spot
      final spotStrength = (spotNoise - (1.0 - intensity * 0.2)) / (intensity * 0.2);
      return Color.lerp(baseColor, mineralColor, spotStrength * 0.6)!;
    }

    return baseColor;
  }

  /// Apply surface shininess/polish
  Color _applyShininess(Color baseColor, int x, int y, int width, int height, double shininess) {
    if (shininess <= 0) return baseColor;

    // Simple lighting calculation
    final centerX = width / 2;
    final centerY = height / 2;
    final distance = sqrt(pow(x - centerX, 2) + pow(y - centerY, 2));
    final maxDistance = sqrt(centerX * centerX + centerY * centerY);

    final lightFactor = (1.0 - distance / maxDistance) * shininess * 0.3;

    final hsv = HSVColor.fromColor(baseColor);
    final newValue = (hsv.value + lightFactor).clamp(0.0, 1.0);

    return hsv.withValue(newValue).toColor();
  }

  /// Perlin-like noise function
  double _perlinNoise(double x, double y, int seed) {
    final intX = x.floor();
    final intY = y.floor();
    final fracX = x - intX;
    final fracY = y - intY;

    // Sample corners
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
}

/// Helper class for stone color palettes
class _StoneColors {
  final Color baseColor;
  final Color darkColor;
  final Color lightColor;
  final Color accentColor;

  _StoneColors({
    required this.baseColor,
    required this.darkColor,
    required this.lightColor,
    required this.accentColor,
  });
}
