part of 'effects.dart';

/// Effect that transforms pixels to look like realistic fire with flames and embers
class FireEffect extends Effect {
  FireEffect([Map<String, dynamic>? parameters])
      : super(
          EffectType.fire,
          parameters ??
              const {
                'intensity': 0.7, // How intense the fire effect is (0-1)
                'flameHeight': 0.6, // How tall the flames appear (0-1)
                'turbulence': 0.5, // Amount of flame movement/distortion (0-1)
                'emberCount': 0.0, // Number of flying embers (0-1)
                'heatDistortion': 0.4, // Heat wave distortion effect (0-1)
                'baseTemperature': 0.5, // Base heat level - affects color (0-1)
                'windDirection': 0.5, // Wind direction affecting flame lean (0-1, 0=left, 1=right)
              },
        );

  @override
  Map<String, dynamic> getDefaultParameters() {
    return {
      'intensity': 0.7, // How intense the fire effect is
      'flameHeight': 0.6, // How tall flames appear
      'turbulence': 0.5, // Amount of flame movement
      'emberCount': 0.0, // Number of flying embers
      'heatDistortion': 0.4, // Heat wave distortion
      'baseTemperature': 0.5, // Base heat level
      'windDirection': 0.5, // Wind direction (0=left, 0.5=up, 1=right)
    };
  }

  @override
  Map<String, dynamic> getMetadata() {
    return {
      'intensity': {
        'label': 'Fire Intensity',
        'description': 'Controls how intense and bright the fire appears.',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
      'flameHeight': {
        'label': 'Flame Height',
        'description': 'Controls how tall the flames appear.',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
      'turbulence': {
        'label': 'Turbulence',
        'description': 'Controls the amount of flame movement and distortion.',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
      'emberCount': {
        'label': 'Ember Count',
        'description': 'Controls the number of flying embers.',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
      'heatDistortion': {
        'label': 'Heat Distortion',
        'description': 'Controls heat wave distortion effects.',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
      'baseTemperature': {
        'label': 'Base Temperature',
        'description': 'Controls the base heat level, affecting fire color.',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
      'windDirection': {
        'label': 'Wind Direction',
        'description': 'Controls wind direction affecting flame lean.',
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
    final intensity = parameters['intensity'] as double;
    final flameHeight = parameters['flameHeight'] as double;
    final turbulence = parameters['turbulence'] as double;
    final emberCount = parameters['emberCount'] as double;
    final heatDistortion = parameters['heatDistortion'] as double;
    final baseTemperature = parameters['baseTemperature'] as double;
    final windDirection = parameters['windDirection'] as double;

    // Create result buffer
    final result = Uint32List(pixels.length);

    // Initialize random with fixed seed for consistent results
    final random = Random(42);

    // Create fire heightmap based on original pixel brightness
    final fireMap = _createFireHeightMap(pixels, width, height, baseTemperature);

    // Apply turbulence to create flame distortion
    final distortedFireMap = _applyTurbulence(fireMap, width, height, turbulence, random);

    // Generate fire colors based on height and temperature
    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final index = y * width + x;
        final originalPixel = pixels[index];
        final originalAlpha = (originalPixel >> 24) & 0xFF;

        // Skip completely transparent pixels
        if (originalAlpha == 0) {
          result[index] = 0;
          continue;
        }

        // Get fire height at this position
        final fireHeight = distortedFireMap[index];

        // Calculate flame position (0 = bottom, 1 = top)
        final normalizedY = y / height;
        final flamePosition = 1.0 - (normalizedY / flameHeight).clamp(0.0, 1.0);

        // Apply wind direction to flame position
        final windInfluence = _calculateWindInfluence(x, y, width, height, windDirection);
        final adjustedFlamePos = (flamePosition + windInfluence * 0.3).clamp(0.0, 1.0);

        // Calculate fire intensity at this position
        final fireIntensity = _calculateFireIntensity(
          adjustedFlamePos,
          fireHeight,
          baseTemperature,
          intensity,
        );

        // Generate fire color
        final fireColor = _generateFireColor(fireIntensity, baseTemperature);

        // Apply heat distortion if enabled
        Color finalColor = fireColor;
        if (heatDistortion > 0) {
          finalColor = _applyHeatDistortion(
            fireColor,
            x,
            y,
            width,
            height,
            heatDistortion,
            random,
          );
        }

        // Blend with original alpha
        final blendedAlpha = (originalAlpha * fireIntensity).round().clamp(0, 255);
        result[index] = (blendedAlpha << 24) | (finalColor.value & 0x00FFFFFF);
      }
    }

    // Add flying embers
    if (emberCount > 0) {
      _addEmbers(result, width, height, emberCount, intensity, random);
    }

    return result;
  }

  /// Create a height map for fire based on original pixel brightness
  List<double> _createFireHeightMap(Uint32List pixels, int width, int height, double baseTemp) {
    final fireMap = List<double>.filled(pixels.length, 0.0);

    for (int i = 0; i < pixels.length; i++) {
      final pixel = pixels[i];
      final alpha = ((pixel >> 24) & 0xFF) / 255.0;

      if (alpha > 0) {
        // Calculate brightness
        final r = (pixel >> 16) & 0xFF;
        final g = (pixel >> 8) & 0xFF;
        final b = pixel & 0xFF;
        final brightness = (0.299 * r + 0.587 * g + 0.114 * b) / 255.0;

        // Fire height based on brightness and base temperature
        fireMap[i] = (brightness * alpha + baseTemp * 0.3).clamp(0.0, 1.0);
      }
    }

    return fireMap;
  }

  /// Apply turbulence to create realistic flame movement
  List<double> _applyTurbulence(
    List<double> fireMap,
    int width,
    int height,
    double turbulence,
    Random random,
  ) {
    if (turbulence <= 0) return fireMap;

    final result = List<double>.from(fireMap);
    final turbulenceStrength = turbulence * 0.3;

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final index = y * width + x;

        if (fireMap[index] > 0) {
          // Generate multi-octave noise for more realistic turbulence
          final noise1 = _perlinNoise(x * 0.1, y * 0.1, random) * turbulenceStrength;
          final noise2 = _perlinNoise(x * 0.05, y * 0.05, random) * turbulenceStrength * 0.5;
          final noise3 = _perlinNoise(x * 0.2, y * 0.2, random) * turbulenceStrength * 0.25;

          final totalNoise = noise1 + noise2 + noise3;

          // Apply turbulence - higher flames are more affected by wind
          final turbulenceMultiplier = fireMap[index] * 0.7 + 0.3;
          result[index] = (fireMap[index] + totalNoise * turbulenceMultiplier).clamp(0.0, 1.0);
        }
      }
    }

    return result;
  }

  /// Calculate wind influence on flame position
  double _calculateWindInfluence(int x, int y, int width, int height, double windDirection) {
    // Convert wind direction to influence (-1 to 1, where -1 is left wind, 1 is right wind)
    final windForce = (windDirection - 0.5) * 2;

    // Wind affects flames more at the top
    final heightFactor = 1.0 - (y / height);

    // Create horizontal wind influence
    final horizontalInfluence = windForce * heightFactor * 0.3;

    return horizontalInfluence;
  }

  /// Calculate fire intensity based on position and parameters
  double _calculateFireIntensity(
    double flamePosition,
    double fireHeight,
    double baseTemperature,
    double intensity,
  ) {
    if (fireHeight <= 0) return 0.0;

    // Fire is hottest at the base and cools towards the top
    final temperatureGradient = 1.0 - pow(flamePosition, 1.5);

    // Combine with base temperature and intensity
    final finalIntensity = (temperatureGradient * fireHeight * intensity + baseTemperature * 0.2).clamp(0.0, 1.0);

    return finalIntensity;
  }

  /// Generate realistic fire colors based on temperature
  Color _generateFireColor(double intensity, double baseTemperature) {
    if (intensity <= 0) return Colors.transparent;

    // Fire color temperature scale
    // Cool fire: deep red/orange
    // Hot fire: bright yellow/white
    final temperature = (intensity + baseTemperature * 0.3).clamp(0.0, 1.0);

    int r, g, b;

    if (temperature < 0.2) {
      // Very cool - dark red/black
      r = (100 * temperature / 0.2).round();
      g = 0;
      b = 0;
    } else if (temperature < 0.4) {
      // Cool - red
      r = (100 + 155 * (temperature - 0.2) / 0.2).round();
      g = (30 * (temperature - 0.2) / 0.2).round();
      b = 0;
    } else if (temperature < 0.6) {
      // Medium - red-orange
      r = 255;
      g = (30 + 125 * (temperature - 0.4) / 0.2).round();
      b = (10 * (temperature - 0.4) / 0.2).round();
    } else if (temperature < 0.8) {
      // Hot - orange-yellow
      r = 255;
      g = (155 + 100 * (temperature - 0.6) / 0.2).round();
      b = (10 + 40 * (temperature - 0.6) / 0.2).round();
    } else {
      // Very hot - yellow-white
      r = 255;
      g = 255;
      b = (50 + 205 * (temperature - 0.8) / 0.2).round();
    }

    // Apply intensity to alpha
    final alpha = (intensity * 255).round().clamp(0, 255);

    return Color.fromARGB(alpha, r.clamp(0, 255), g.clamp(0, 255), b.clamp(0, 255));
  }

  /// Apply heat distortion effects
  Color _applyHeatDistortion(
    Color baseColor,
    int x,
    int y,
    int width,
    int height,
    double distortionAmount,
    Random random,
  ) {
    if (distortionAmount <= 0) return baseColor;

    // Create heat shimmer effect by slightly varying the color
    final shimmer = (random.nextDouble() - 0.5) * distortionAmount * 0.2;

    // Adjust brightness for shimmer
    final hsv = HSVColor.fromColor(baseColor);
    final newValue = (hsv.value + shimmer).clamp(0.0, 1.0);
    final newSaturation = (hsv.saturation + shimmer * 0.1).clamp(0.0, 1.0);

    return hsv.withValue(newValue).withSaturation(newSaturation).toColor();
  }

  /// Add flying embers to the fire effect
  void _addEmbers(
    Uint32List pixels,
    int width,
    int height,
    double emberCount,
    double intensity,
    Random random,
  ) {
    final numEmbers = (emberCount * width * height * 0.001).round();

    for (int i = 0; i < numEmbers; i++) {
      final x = random.nextInt(width);
      final y = random.nextInt(height);
      final index = y * width + x;

      // Embers are more likely to appear in upper areas
      final emberProbability = 1.0 - (y / height) * 0.7;
      if (random.nextDouble() > emberProbability) continue;

      // Create ember color (bright orange/yellow)
      final emberIntensity = (0.7 + random.nextDouble() * 0.3) * intensity;
      final emberSize = random.nextInt(2) + 1; // 1-2 pixel embers

      final emberColor = Color.fromARGB(
        (emberIntensity * 255).round(),
        255,
        (200 + random.nextInt(55)).clamp(0, 255), // Orange to yellow
        (50 + random.nextInt(100)).clamp(0, 255),
      );

      // Draw ember with small size
      for (int ey = -emberSize; ey <= emberSize; ey++) {
        for (int ex = -emberSize; ex <= emberSize; ex++) {
          final emberX = x + ex;
          final emberY = y + ey;

          if (emberX >= 0 && emberX < width && emberY >= 0 && emberY < height) {
            final emberIndex = emberY * width + emberX;
            final distance = sqrt(ex * ex + ey * ey);

            if (distance <= emberSize) {
              // Blend ember with existing pixel
              final existingPixel = pixels[emberIndex];
              final existingAlpha = (existingPixel >> 24) & 0xFF;

              if (existingAlpha < emberColor.alpha) {
                pixels[emberIndex] = emberColor.value;
              }
            }
          }
        }
      }
    }
  }

  /// Simple Perlin-like noise function for turbulence
  double _perlinNoise(double x, double y, Random random) {
    // Simple pseudo-random noise based on position
    final seed = ((x * 12.9898 + y * 78.233) * 43758.5453).floor();
    final seededRandom = Random(seed);
    return seededRandom.nextDouble() * 2.0 - 1.0; // -1 to 1
  }
}
