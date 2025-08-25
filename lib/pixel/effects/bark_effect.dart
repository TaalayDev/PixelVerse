part of 'effects.dart';

/// Effect that transforms pixels to look like realistic tree bark textures
class TreeBarkEffect extends Effect {
  TreeBarkEffect([Map<String, dynamic>? parameters])
      : super(
          EffectType.treeBark,
          parameters ??
              const {
                'barkType': 0, // 0=Oak, 1=Birch, 2=Pine, 3=Redwood, 4=Willow, 5=Palm
                'roughness': 0.7, // Surface roughness (0-1)
                'grooving': 0.6, // Vertical groove depth (0-1)
                'colorVariation': 0.5, // Random color variation (0-1)
                'scale': 0.5, // Texture scale (0-1)
                'weathering': 0.4, // Age/weathering effects (0-1)
                'mossAmount': 0.1, // Amount of moss/lichen (0-1)
                'crackiness': 0.3, // Amount of cracks and fissures (0-1)
              },
        );

  @override
  Map<String, dynamic> getDefaultParameters() {
    return {
      'barkType': 0, // Bark species
      'roughness': 0.7, // Surface roughness
      'grooving': 0.6, // Vertical grooves
      'colorVariation': 0.5, // Color variation
      'scale': 0.5, // Texture scale
      'weathering': 0.4, // Weathering/aging
      'mossAmount': 0.1, // Moss/lichen
      'crackiness': 0.3, // Cracks and fissures
    };
  }

  @override
  Map<String, dynamic> getMetadata() {
    return {
      'barkType': {
        'label': 'Bark Type',
        'description': 'Select the type of tree bark texture.',
        'type': 'select',
        'options': {
          0: 'Oak (Rough)',
          1: 'Birch (Smooth)',
          2: 'Pine (Plated)',
          3: 'Redwood (Fibrous)',
          4: 'Willow (Furrowed)',
          5: 'Palm (Fibrous)',
        },
      },
      'roughness': {
        'label': 'Surface Roughness',
        'description': 'Controls how rough and bumpy the bark surface appears.',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
      'grooving': {
        'label': 'Vertical Grooves',
        'description': 'Controls the depth and prominence of vertical bark grooves.',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
      'colorVariation': {
        'label': 'Color Variation',
        'description': 'Amount of natural color variation in the bark.',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
      'scale': {
        'label': 'Texture Scale',
        'description': 'Size of bark texture features. Smaller values create finer detail.',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
      'weathering': {
        'label': 'Weathering',
        'description': 'Age and weathering effects on the bark surface.',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
      'mossAmount': {
        'label': 'Moss & Lichen',
        'description': 'Amount of moss and lichen growth on the bark.',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
      'crackiness': {
        'label': 'Cracks & Fissures',
        'description': 'Amount of cracks and deep fissures in the bark.',
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
    final barkType = (parameters['barkType'] as int).clamp(0, 5);
    final roughness = parameters['roughness'] as double;
    final grooving = parameters['grooving'] as double;
    final colorVariation = parameters['colorVariation'] as double;
    final scale = parameters['scale'] as double;
    final weathering = parameters['weathering'] as double;
    final mossAmount = parameters['mossAmount'] as double;
    final crackiness = parameters['crackiness'] as double;

    // Create result buffer
    final result = Uint32List(pixels.length);

    // Get bark colors based on type
    final barkColors = _getBarkColors(barkType);

    // Random generator with fixed seed for consistent results
    final random = Random(42);

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

        // Calculate bark texture for this pixel
        final barkColor = _calculateBarkTexture(
          x.toDouble(),
          y.toDouble(),
          width,
          height,
          barkColors,
          barkType,
          roughness,
          grooving,
          colorVariation,
          scale,
          weathering,
          mossAmount,
          crackiness,
          random,
        );

        // Preserve original alpha
        final finalColor = (originalAlpha << 24) | (barkColor & 0x00FFFFFF);
        result[index] = finalColor;
      }
    }

    return result;
  }

  // Get color palette for different bark types
  _BarkColors _getBarkColors(int barkType) {
    switch (barkType) {
      case 0: // Oak - Dark, rough bark
        return _BarkColors(
          baseColor: const Color(0xFF5D4037), // Dark brown
          darkColor: const Color(0xFF3E2723), // Very dark brown
          lightColor: const Color(0xFF8D6E63), // Light brown
          accentColor: const Color(0xFF6D4C41), // Medium brown
        );
      case 1: // Birch - Light, smooth bark with dark horizontal lines
        return _BarkColors(
          baseColor: const Color(0xFFF5F5DC), // Beige/cream
          darkColor: const Color(0xFF2E2E2E), // Dark gray for lines
          lightColor: const Color(0xFFFFFFFF), // White
          accentColor: const Color(0xFFE0E0E0), // Light gray
        );
      case 2: // Pine - Orange-brown plated bark
        return _BarkColors(
          baseColor: const Color(0xFFD4A574), // Orange-brown
          darkColor: const Color(0xFF8B4513), // Saddle brown
          lightColor: const Color(0xFFF4E4BC), // Light tan
          accentColor: const Color(0xFFCD853F), // Peru
        );
      case 3: // Redwood - Reddish fibrous bark
        return _BarkColors(
          baseColor: const Color(0xFFA0522D), // Sienna
          darkColor: const Color(0xFF8B0000), // Dark red
          lightColor: const Color(0xFFDEB887), // Burlywood
          accentColor: const Color(0xFFB22222), // Fire brick
        );
      case 4: // Willow - Gray-brown furrowed bark
        return _BarkColors(
          baseColor: const Color(0xFF696969), // Dim gray
          darkColor: const Color(0xFF2F4F4F), // Dark slate gray
          lightColor: const Color(0xFFA9A9A9), // Dark gray
          accentColor: const Color(0xFF708090), // Slate gray
        );
      case 5: // Palm - Fibrous, textured bark
        return _BarkColors(
          baseColor: const Color(0xFF8B7355), // Brown
          darkColor: const Color(0xFF654321), // Dark brown
          lightColor: const Color(0xFFDEB887), // Burlywood
          accentColor: const Color(0xFFBC9A6A), // Tan
        );
      default:
        return _getBarkColors(0); // Default to oak
    }
  }

  // Calculate the bark texture for a specific pixel
  int _calculateBarkTexture(
    double x,
    double y,
    int width,
    int height,
    _BarkColors colors,
    int barkType,
    double roughness,
    double grooving,
    double colorVariation,
    double scale,
    double weathering,
    double mossAmount,
    double crackiness,
    Random random,
  ) {
    final textureScale = 0.1 / (scale + 0.1);

    // Base bark pattern using multiple noise layers
    final barkNoise = _generateBarkNoise(x, y, textureScale, barkType);

    // Vertical grooves (common to most bark types)
    final groovePattern = _calculateGrooves(x, y, grooving, textureScale);

    // Surface roughness
    final roughnessPattern = _calculateRoughness(x, y, roughness, textureScale);

    // Weathering effects
    final weatheringPattern = _calculateWeathering(x, y, weathering, textureScale);

    // Cracks and fissures
    final crackPattern = _calculateCracks(x, y, crackiness, textureScale);

    // Moss and lichen
    final mossPattern = _calculateMoss(x, y, mossAmount, textureScale);

    // Combine all patterns
    var pattern = barkNoise * 0.4 + groovePattern * 0.3 + roughnessPattern * 0.2 + weatheringPattern * 0.1;
    pattern = pattern.clamp(0.0, 1.0);

    // Apply cracks (darkening effect)
    if (crackPattern > 0.7) {
      pattern *= 0.3; // Darken cracks significantly
    }

    // Select base color based on pattern
    Color baseColor;
    if (pattern < 0.2) {
      baseColor = colors.darkColor;
    } else if (pattern < 0.5) {
      baseColor = Color.lerp(colors.darkColor, colors.baseColor, (pattern - 0.2) / 0.3)!;
    } else if (pattern < 0.8) {
      baseColor = Color.lerp(colors.baseColor, colors.accentColor, (pattern - 0.5) / 0.3)!;
    } else {
      baseColor = Color.lerp(colors.accentColor, colors.lightColor, (pattern - 0.8) / 0.2)!;
    }

    // Apply bark-type specific modifications
    baseColor = _applyBarkTypeEffects(baseColor, x, y, barkType, textureScale);

    // Apply color variation
    if (colorVariation > 0) {
      final variation = (_perlinNoise(x * 0.02, y * 0.02, 5) - 0.5) * colorVariation * 0.3;
      final hsv = HSVColor.fromColor(baseColor);
      final newValue = (hsv.value + variation).clamp(0.0, 1.0);
      final newSaturation = (hsv.saturation + variation * 0.1).clamp(0.0, 1.0);
      baseColor = hsv.withValue(newValue).withSaturation(newSaturation).toColor();
    }

    // Apply moss effect
    if (mossPattern > 0.8 && mossAmount > 0) {
      final mossColor = Color.fromARGB(255, 85, 107, 47); // Dark olive green
      final mossIntensity = (mossPattern - 0.8) * 5 * mossAmount;
      baseColor = Color.lerp(baseColor, mossColor, mossIntensity.clamp(0.0, 0.7))!;
    }

    return baseColor.value;
  }

  // Generate base bark noise pattern
  double _generateBarkNoise(double x, double y, double scale, int barkType) {
    // Different noise patterns for different bark types
    switch (barkType) {
      case 0: // Oak - Rough, irregular
        final noise1 = _perlinNoise(x * scale * 2, y * scale * 0.5, 0);
        final noise2 = _perlinNoise(x * scale * 4, y * scale * 1, 1);
        final noise3 = _perlinNoise(x * scale * 8, y * scale * 2, 2);
        return (noise1 * 0.5 + noise2 * 0.3 + noise3 * 0.2 + 1) * 0.5;

      case 1: // Birch - Smooth with horizontal features
        final horizontal = sin(y * scale * 20) * 0.3;
        final noise = _perlinNoise(x * scale * 0.5, y * scale * 2, 0);
        return (noise * 0.7 + horizontal + 1) * 0.5;

      case 2: // Pine - Plated, scaly pattern
        final plateNoise1 = _perlinNoise(x * scale * 3, y * scale * 1.5, 0);
        final plateNoise2 = _perlinNoise(x * scale * 6, y * scale * 3, 1);
        return (plateNoise1 * 0.6 + plateNoise2 * 0.4 + 1) * 0.5;

      case 3: // Redwood - Fibrous, vertical emphasis
        final vertical = _perlinNoise(x * scale * 0.3, y * scale * 8, 0);
        final fiber = _perlinNoise(x * scale * 2, y * scale * 4, 1);
        return (vertical * 0.4 + fiber * 0.6 + 1) * 0.5;

      case 4: // Willow - Deep furrows
        final furrow = sin(x * scale * 15) * cos(x * scale * 8);
        final noise = _perlinNoise(x * scale * 1, y * scale * 2, 0);
        return (furrow * 0.5 + noise * 0.5 + 1) * 0.5;

      case 5: // Palm - Fibrous texture
        final fiber1 = _perlinNoise(x * scale * 1, y * scale * 8, 0);
        final fiber2 = _perlinNoise(x * scale * 2, y * scale * 16, 1);
        return (fiber1 * 0.6 + fiber2 * 0.4 + 1) * 0.5;

      default:
        return (_perlinNoise(x * scale, y * scale, 0) + 1) * 0.5;
    }
  }

  // Calculate vertical groove patterns
  double _calculateGrooves(double x, double y, double intensity, double scale) {
    if (intensity <= 0) return 0;

    // Vertical groove pattern with some irregularity
    final grooveSpacing = 20 / scale;
    final grooveNoise = _perlinNoise(x * scale * 0.1, y * scale * 0.05, 3);
    final adjustedX = x + grooveNoise * 10;

    final groove = sin(adjustedX * pi / grooveSpacing);
    return pow(groove.abs(), 2) * intensity;
  }

  // Calculate surface roughness
  double _calculateRoughness(double x, double y, double intensity, double scale) {
    if (intensity <= 0) return 0;

    final roughness1 = _perlinNoise(x * scale * 8, y * scale * 8, 4);
    final roughness2 = _perlinNoise(x * scale * 16, y * scale * 16, 5);

    return (roughness1 * 0.7 + roughness2 * 0.3) * intensity;
  }

  // Calculate weathering patterns
  double _calculateWeathering(double x, double y, double intensity, double scale) {
    if (intensity <= 0) return 0;

    // Weathering creates worn, smooth patches
    final weatherNoise = _perlinNoise(x * scale * 0.5, y * scale * 0.3, 6);
    final weatherPatches = _perlinNoise(x * scale * 0.2, y * scale * 0.2, 7);

    // Weathering reduces texture variation
    return (weatherNoise * 0.6 + weatherPatches * 0.4) * intensity;
  }

  // Calculate crack and fissure patterns
  double _calculateCracks(double x, double y, double intensity, double scale) {
    if (intensity <= 0) return 0;

    // Create irregular crack patterns
    final crackNoise1 = _perlinNoise(x * scale * 0.5, y * scale * 2, 8);
    final crackNoise2 = _perlinNoise(x * scale * 1, y * scale * 4, 9);

    // Cracks are thin, dark lines
    final crackValue = (crackNoise1 * 0.6 + crackNoise2 * 0.4 + 1) * 0.5;

    return crackValue * intensity;
  }

  // Calculate moss and lichen patterns
  double _calculateMoss(double x, double y, double amount, double scale) {
    if (amount <= 0) return 0;

    // Moss grows in patches, often in grooves
    final mossNoise = _perlinNoise(x * scale * 0.3, y * scale * 0.3, 10);
    final mossPatches = _perlinNoise(x * scale * 0.1, y * scale * 0.1, 11);

    // Moss is more likely in certain areas
    return (mossNoise * 0.7 + mossPatches * 0.3 + 1) * 0.5 * amount;
  }

  // Apply bark-type specific visual effects
  Color _applyBarkTypeEffects(Color baseColor, double x, double y, int barkType, double scale) {
    switch (barkType) {
      case 1: // Birch - Add characteristic dark horizontal marks
        final horizontalLines = sin(y * scale * 25);
        if (horizontalLines > 0.8) {
          return Color.lerp(baseColor, const Color(0xFF2E2E2E), 0.8)!;
        }
        break;

      case 2: // Pine - Add reddish tint to plates
        final plateEffect = _perlinNoise(x * scale * 5, y * scale * 2, 12);
        if (plateEffect > 0.3) {
          final hsv = HSVColor.fromColor(baseColor);
          final newHue = (hsv.hue + 10).clamp(0.0, 360.0); // Shift toward red
          return hsv.withHue(newHue).toColor();
        }
        break;

      case 3: // Redwood - Enhance reddish fibers
        final fiberEffect = _perlinNoise(x * scale * 0.5, y * scale * 6, 13);
        if (fiberEffect > 0.4) {
          return Color.lerp(baseColor, const Color(0xFFB22222), 0.3)!;
        }
        break;

      case 5: // Palm - Add fibrous texture
        final fiberNoise = _perlinNoise(x * scale * 3, y * scale * 12, 14);
        if (fiberNoise > 0.5) {
          return Color.lerp(baseColor, const Color(0xFFDEB887), 0.2)!;
        }
        break;
    }

    return baseColor;
  }

  // Simple Perlin-like noise function
  double _perlinNoise(double x, double y, int seed) {
    // Simple pseudo-random noise based on position and seed
    final n = (sin(x * 12.9898 + y * 78.233 + seed * 37.719) * 43758.5453);
    return (n - n.floor()) * 2 - 1; // Return value between -1 and 1
  }
}

// Helper classes for bark effect
class _BarkColors {
  final Color baseColor;
  final Color darkColor;
  final Color lightColor;
  final Color accentColor;

  _BarkColors({
    required this.baseColor,
    required this.darkColor,
    required this.lightColor,
    required this.accentColor,
  });
}
