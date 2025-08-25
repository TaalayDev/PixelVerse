part of 'effects.dart';

/// Effect that transforms pixels to look like various types of ice and frozen surfaces
class IceEffect extends Effect {
  IceEffect([Map<String, dynamic>? parameters])
      : super(
          EffectType.ice,
          parameters ??
              const {
                'iceType': 0, // 0=clear ice, 1=frosted ice, 2=crystal ice, 3=glacial ice, 4=black ice, 5=snow ice
                'transparency': 0.7, // Ice transparency (0-1)
                'thickness': 0.5, // Ice thickness affecting opacity (0-1)
                'frostiness': 0.3, // Amount of frost on surface (0-1)
                'crackIntensity': 0.2, // Intensity of cracks and fractures (0-1)
                'bubbleAmount': 0.3, // Air bubbles trapped in ice (0-1)
                'refractionStrength': 0.4, // Light refraction/distortion (0-1)
                'crystallization': 0.5, // Crystal formation patterns (0-1)
                'shininess': 0.8, // Surface reflectivity (0-1)
                'temperature': 0.2, // Visual temperature (0=very cold, 1=melting)
                'iceAge': 0.3, // How old/weathered the ice is (0-1)
                'randomSeed': 42, // Seed for pattern generation
              },
        );

  @override
  Map<String, dynamic> getDefaultParameters() {
    return {
      'iceType': 0,
      'transparency': 0.7,
      'thickness': 0.5,
      'frostiness': 0.3,
      'crackIntensity': 0.2,
      'bubbleAmount': 0.3,
      'refractionStrength': 0.4,
      'crystallization': 0.5,
      'shininess': 0.8,
      'temperature': 0.2,
      'iceAge': 0.3,
      'randomSeed': 42,
    };
  }

  @override
  Map<String, dynamic> getMetadata() {
    return {
      'iceType': {
        'label': 'Ice Type',
        'description': 'Select the type of ice surface to simulate.',
        'type': 'select',
        'options': {
          0: 'Clear Ice',
          1: 'Frosted Ice',
          2: 'Crystal Ice',
          3: 'Glacial Ice',
          4: 'Black Ice',
          5: 'Snow Ice',
        },
      },
      'transparency': {
        'label': 'Ice Transparency',
        'description': 'How transparent the ice appears.',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
      'thickness': {
        'label': 'Ice Thickness',
        'description': 'Thickness of the ice layer affecting opacity.',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
      'frostiness': {
        'label': 'Frost Amount',
        'description': 'Amount of frost crystals on the ice surface.',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
      'crackIntensity': {
        'label': 'Crack Intensity',
        'description': 'Intensity of cracks and stress fractures in the ice.',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
      'bubbleAmount': {
        'label': 'Air Bubbles',
        'description': 'Amount of air bubbles trapped in the ice.',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
      'refractionStrength': {
        'label': 'Light Refraction',
        'description': 'Strength of light bending and distortion effects.',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
      'crystallization': {
        'label': 'Crystal Formation',
        'description': 'Amount of visible crystal structures in the ice.',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
      'shininess': {
        'label': 'Surface Shininess',
        'description': 'How reflective and glossy the ice surface is.',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
      'temperature': {
        'label': 'Temperature',
        'description': 'Visual temperature of ice (0=frozen solid, 1=near melting).',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
      'iceAge': {
        'label': 'Ice Age',
        'description': 'How old and weathered the ice appears.',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
      'randomSeed': {
        'label': 'Pattern Seed',
        'description': 'Changes the random ice pattern.',
        'type': 'slider',
        'min': 1,
        'max': 100,
        'divisions': 99,
      },
    };
  }

  @override
  Uint32List apply(Uint32List pixels, int width, int height) {
    final iceType = (parameters['iceType'] as int).clamp(0, 5);
    final transparency = parameters['transparency'] as double;
    final thickness = parameters['thickness'] as double;
    final frostiness = parameters['frostiness'] as double;
    final crackIntensity = parameters['crackIntensity'] as double;
    final bubbleAmount = parameters['bubbleAmount'] as double;
    final refractionStrength = parameters['refractionStrength'] as double;
    final crystallization = parameters['crystallization'] as double;
    final shininess = parameters['shininess'] as double;
    final temperature = parameters['temperature'] as double;
    final iceAge = parameters['iceAge'] as double;
    final randomSeed = parameters['randomSeed'] as int;

    final result = Uint32List(pixels.length);
    final random = Random(randomSeed);

    // Get base ice colors for the selected type
    final iceColors = _getIceColors(iceType, temperature);

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

        // Apply refraction displacement
        final (refractedX, refractedY) = _calculateRefraction(x, y, width, height, refractionStrength, random);

        // Sample original pixel with refraction
        final refractedPixel = _samplePixelWithBounds(pixels, width, height, refractedX, refractedY, originalPixel);

        // Calculate ice transformation
        final icePixel = _calculateIceTexture(
          x,
          y,
          width,
          height,
          iceType,
          iceColors,
          refractedPixel,
          transparency,
          thickness,
          frostiness,
          crackIntensity,
          bubbleAmount,
          crystallization,
          shininess,
          temperature,
          iceAge,
          random,
        );

        result[index] = icePixel;
      }
    }

    return result;
  }

  /// Get color palette for different ice types
  _IceColors _getIceColors(int iceType, double temperature) {
    // Temperature affects ice color - warmer ice is more blue/clear
    final tempFactor = temperature * 0.3;

    switch (iceType) {
      case 0: // Clear Ice
        return _IceColors(
          baseColor: Color.fromARGB(255, (240 + tempFactor * 15).round(), (248 + tempFactor * 7).round(), 255),
          highlightColor: const Color(0xFFFFFFFF), // Pure white
          shadowColor: Color.fromARGB(255, (200 - tempFactor * 20).round(), (230 - tempFactor * 10).round(), 255),
          bubbleColor: const Color(0xFFE6F3FF), // Very light blue
        );

      case 1: // Frosted Ice
        return _IceColors(
          baseColor: Color.fromARGB(
              255, (230 + tempFactor * 10).round(), (240 + tempFactor * 10).round(), (250 + tempFactor * 5).round()),
          highlightColor: const Color(0xFFF5F5F5), // Off white
          shadowColor: Color.fromARGB(
              255, (180 - tempFactor * 15).round(), (200 - tempFactor * 15).round(), (220 - tempFactor * 10).round()),
          bubbleColor: const Color(0xFFDDE7F0), // Light gray-blue
        );

      case 2: // Crystal Ice
        return _IceColors(
          baseColor: Color.fromARGB(255, (220 + tempFactor * 15).round(), (240 + tempFactor * 10).round(), 255),
          highlightColor: const Color(0xFFCCE7FF), // Light blue
          shadowColor: Color.fromARGB(
              255, (150 - tempFactor * 30).round(), (200 - tempFactor * 20).round(), (255 - tempFactor * 10).round()),
          bubbleColor: const Color(0xFFB3D9FF), // Medium light blue
        );

      case 3: // Glacial Ice
        return _IceColors(
          baseColor: Color.fromARGB(
              255, (180 + tempFactor * 20).round(), (220 + tempFactor * 15).round(), (255 - tempFactor * 5).round()),
          highlightColor: const Color(0xFFE0F0FF), // Very light blue
          shadowColor: Color.fromARGB(
              255, (120 - tempFactor * 20).round(), (180 - tempFactor * 20).round(), (240 - tempFactor * 15).round()),
          bubbleColor: const Color(0xFF99CCFF), // Medium blue
        );

      case 4: // Black Ice
        return _IceColors(
          baseColor: Color.fromARGB(
              255, (60 + tempFactor * 40).round(), (80 + tempFactor * 40).round(), (120 + tempFactor * 40).round()),
          highlightColor: Color.fromARGB(
              255, (180 + tempFactor * 20).round(), (200 + tempFactor * 20).round(), (230 + tempFactor * 15).round()),
          shadowColor: Color.fromARGB(
              255, (20 + tempFactor * 20).round(), (30 + tempFactor * 20).round(), (50 + tempFactor * 30).round()),
          bubbleColor: const Color(0xFF4D6B99), // Dark blue
        );

      case 5: // Snow Ice
        return _IceColors(
          baseColor: Color.fromARGB(255, (250 - tempFactor * 10).round(), (250 - tempFactor * 5).round(), 255),
          highlightColor: const Color(0xFFFFFFFF), // Pure white
          shadowColor: Color.fromARGB(
              255, (220 - tempFactor * 20).round(), (230 - tempFactor * 15).round(), (245 - tempFactor * 10).round()),
          bubbleColor: const Color(0xFFF0F8FF), // Alice blue
        );

      default:
        return _getIceColors(0, temperature);
    }
  }

  /// Calculate refraction displacement
  (double, double) _calculateRefraction(int x, int y, int width, int height, double strength, Random random) {
    if (strength <= 0) return (x.toDouble(), y.toDouble());

    // Create refraction pattern using noise
    final refractionX = _perlinNoise(x * 0.02, y * 0.02, 1000) * strength * 3;
    final refractionY = _perlinNoise(x * 0.02, y * 0.02, 2000) * strength * 3;

    return (x + refractionX, y + refractionY);
  }

  /// Sample pixel with bounds checking
  int _samplePixelWithBounds(Uint32List pixels, int width, int height, double x, double y, int fallback) {
    final intX = x.round().clamp(0, width - 1);
    final intY = y.round().clamp(0, height - 1);
    final index = intY * width + intX;

    return index < pixels.length ? pixels[index] : fallback;
  }

  /// Calculate complete ice texture for a pixel
  int _calculateIceTexture(
    int x,
    int y,
    int width,
    int height,
    int iceType,
    _IceColors colors,
    int originalPixel,
    double transparency,
    double thickness,
    double frostiness,
    double crackIntensity,
    double bubbleAmount,
    double crystallization,
    double shininess,
    double temperature,
    double iceAge,
    Random random,
  ) {
    // Start with base ice color
    Color iceColor = colors.baseColor;

    // Apply ice type-specific patterns
    iceColor = _applyIceTypePattern(iceColor, x, y, iceType, colors, crystallization);

    // Apply surface effects
    iceColor = _applyFrost(iceColor, x, y, frostiness, colors.highlightColor, random);
    iceColor = _applyCracks(iceColor, x, y, crackIntensity, colors.shadowColor, iceAge);
    iceColor = _applyBubbles(iceColor, x, y, bubbleAmount, colors.bubbleColor, random);
    iceColor = _applyShininess(iceColor, x, y, width, height, shininess, colors.highlightColor);

    // Calculate final transparency
    final baseTransparency = transparency * (1.0 - thickness * 0.3);
    final finalTransparency =
        _calculateFinalTransparency(x, y, baseTransparency, frostiness, bubbleAmount, crackIntensity);

    // Blend with original pixel
    return _blendIceWithOriginal(originalPixel, iceColor, finalTransparency);
  }

  /// Apply ice type-specific patterns
  Color _applyIceTypePattern(Color baseColor, int x, int y, int iceType, _IceColors colors, double crystallization) {
    switch (iceType) {
      case 0: // Clear Ice - minimal pattern
        final clearness = _perlinNoise(x * 0.01, y * 0.01, 3000) * 0.1;
        return _adjustBrightness(baseColor, clearness);

      case 1: // Frosted Ice - irregular frost patterns
        final frostPattern = _perlinNoise(x * 0.05, y * 0.05, 3100) * 0.3;
        if (frostPattern > 0.1) {
          return Color.lerp(baseColor, colors.highlightColor, frostPattern * 0.6)!;
        }
        return baseColor;

      case 2: // Crystal Ice - geometric crystal patterns
        final crystalPattern = _generateCrystalPattern(x, y, crystallization);
        return Color.lerp(baseColor, colors.highlightColor, crystalPattern * 0.8)!;

      case 3: // Glacial Ice - layered, compressed ice
        final layerPattern = sin(y * 0.02) * 0.2 + 0.8;
        final agePattern = _perlinNoise(x * 0.003, y * 0.003, 3300) * 0.3;
        final combined = layerPattern + agePattern;
        return Color.lerp(colors.shadowColor, baseColor, combined.clamp(0.0, 1.0))!;

      case 4: // Black Ice - very transparent with subtle patterns
        final blackIcePattern = _perlinNoise(x * 0.008, y * 0.008, 3400) * 0.4 + 0.6;
        return Color.lerp(colors.shadowColor, baseColor, blackIcePattern)!;

      case 5: // Snow Ice - rough, opaque with snow texture
        final snowPattern = _perlinNoise(x * 0.1, y * 0.1, 3500);
        if (snowPattern > 0.3) {
          return colors.highlightColor;
        }
        return Color.lerp(colors.shadowColor, baseColor, snowPattern + 0.7)!;

      default:
        return baseColor;
    }
  }

  /// Generate crystal formation patterns
  double _generateCrystalPattern(int x, int y, double intensity) {
    if (intensity <= 0) return 0.0;

    // Hexagonal crystal pattern
    final hexSize = 20;
    final hexX = (x / hexSize).floor();
    final hexY = (y / hexSize).floor();

    // Create hexagonal grid effect
    final centerX = hexX * hexSize + hexSize / 2;
    final centerY = hexY * hexSize + hexSize / 2;
    final distance = sqrt(pow(x - centerX, 2) + pow(y - centerY, 2));

    if (distance < hexSize / 3) {
      // Crystal center
      return intensity * 0.8;
    } else if (distance < hexSize / 2) {
      // Crystal edges
      return intensity * 0.4;
    }

    return 0.0;
  }

  /// Apply frost effect
  Color _applyFrost(Color baseColor, int x, int y, double intensity, Color frostColor, Random random) {
    if (intensity <= 0) return baseColor;

    final frostNoise = _perlinNoise(x * 0.08, y * 0.08, 4000);
    if (frostNoise > (1.0 - intensity)) {
      final frostStrength = (frostNoise - (1.0 - intensity)) / intensity;
      return Color.lerp(baseColor, frostColor, frostStrength * 0.7)!;
    }

    return baseColor;
  }

  /// Apply crack patterns
  Color _applyCracks(Color baseColor, int x, int y, double intensity, Color crackColor, double iceAge) {
    if (intensity <= 0) return baseColor;

    // Stress crack patterns
    final crackNoise1 = _perlinNoise(x * 0.01, y * 0.3, 5000);
    final crackNoise2 = _perlinNoise(x * 0.3, y * 0.01, 5100);
    final ageFactor = iceAge * 0.5 + 0.5; // More cracks in older ice

    final crackValue = max(crackNoise1.abs(), crackNoise2.abs()) * ageFactor;

    if (crackValue > (1.0 - intensity * 0.4)) {
      final crackStrength = (crackValue - (1.0 - intensity * 0.4)) / (intensity * 0.4);
      return Color.lerp(baseColor, crackColor, crackStrength * 0.6)!;
    }

    return baseColor;
  }

  /// Apply air bubbles
  Color _applyBubbles(Color baseColor, int x, int y, double intensity, Color bubbleColor, Random random) {
    if (intensity <= 0) return baseColor;

    final bubbleNoise = _perlinNoise(x * 0.12, y * 0.12, 6000);
    if (bubbleNoise > (1.0 - intensity * 0.3)) {
      // This is a bubble
      final bubbleStrength = (bubbleNoise - (1.0 - intensity * 0.3)) / (intensity * 0.3);
      return Color.lerp(baseColor, bubbleColor, bubbleStrength * 0.8)!;
    }

    return baseColor;
  }

  /// Apply surface shininess and reflections
  Color _applyShininess(Color baseColor, int x, int y, int width, int height, double intensity, Color highlightColor) {
    if (intensity <= 0) return baseColor;

    // Simple lighting calculation from top-left
    final lightX = width * 0.3;
    final lightY = height * 0.3;
    final distance = sqrt(pow(x - lightX, 2) + pow(y - lightY, 2));
    final maxDistance = sqrt(width * width + height * height);

    final lightFactor = (1.0 - distance / maxDistance) * intensity * 0.4;

    return Color.lerp(baseColor, highlightColor, lightFactor)!;
  }

  /// Calculate final transparency including all factors
  double _calculateFinalTransparency(
      int x, int y, double baseTransparency, double frostiness, double bubbleAmount, double crackIntensity) {
    // Frost reduces transparency
    final frostReduction = frostiness * 0.3;

    // Bubbles reduce transparency
    final bubbleReduction = bubbleAmount * 0.2;

    // Cracks slightly reduce transparency
    final crackReduction = crackIntensity * 0.1;

    final finalTransparency = (baseTransparency - frostReduction - bubbleReduction - crackReduction).clamp(0.0, 1.0);

    return finalTransparency;
  }

  /// Blend ice color with original pixel
  int _blendIceWithOriginal(int originalPixel, Color iceColor, double transparency) {
    final origA = (originalPixel >> 24) & 0xFF;
    final origR = (originalPixel >> 16) & 0xFF;
    final origG = (originalPixel >> 8) & 0xFF;
    final origB = originalPixel & 0xFF;

    // Blend original with ice color
    final blendFactor = 1.0 - transparency;
    final newR = (origR * transparency + iceColor.red * blendFactor).round().clamp(0, 255);
    final newG = (origG * transparency + iceColor.green * blendFactor).round().clamp(0, 255);
    final newB = (origB * transparency + iceColor.blue * blendFactor).round().clamp(0, 255);

    // Preserve original alpha
    return (origA << 24) | (newR << 16) | (newG << 8) | newB;
  }

  /// Adjust color brightness
  Color _adjustBrightness(Color color, double adjustment) {
    final hsv = HSVColor.fromColor(color);
    final newValue = (hsv.value + adjustment).clamp(0.0, 1.0);
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

/// Helper class for ice color palettes
class _IceColors {
  final Color baseColor;
  final Color highlightColor;
  final Color shadowColor;
  final Color bubbleColor;

  _IceColors({
    required this.baseColor,
    required this.highlightColor,
    required this.shadowColor,
    required this.bubbleColor,
  });
}
