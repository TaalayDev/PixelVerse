part of 'effects.dart';

class FireEffect extends Effect {
  FireEffect([Map<String, dynamic>? parameters])
      : super(
            EffectType.fire,
            parameters ??
                {
                  'intensity': 0.8,
                  'flameHeight': 0.7,
                  'animationSeed': 0,
                  'colorVariation': 0.3,
                  'sparkles': true,
                  'baseTemperature': 0.6,
                });

  @override
  Map<String, dynamic> getDefaultParameters() => {
        'intensity': 0.8,
        'flameHeight': 0.7,
        'animationSeed': 0,
        'colorVariation': 0.3,
        'sparkles': true,
        'baseTemperature': 0.6,
      };

  @override
  Map<String, dynamic> getMetadata() {
    return {
      'intensity': {
        'label': 'Intensity',
        'description': 'Controls the overall strength of the fire effect.',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
      },
      'flameHeight': {
        'label': 'Flame Height',
        'description': 'Determines how tall the flames appear.',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
      },
      'animationSeed': {
        'label': 'Animation Seed',
        'description': 'Seed for randomizing the fire animation.',
        'type': 'slider',
        'min': 0,
        'max': 0x7FFFFFFFFFFFFFFF,
        'divisions': 100,
      },
      'colorVariation': {
        'label': 'Color Variation',
        'description': 'Adds random color variations to the fire.',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
      },
      'sparkles': {
        'label': 'Sparkles',
        'description': 'Enables sparkles or embers in the fire effect.',
        'type': 'bool',
      },
      'baseTemperature': {
        'label': 'Base Temperature',
        'description': 'Sets the base temperature for the fire, affecting color.',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
      },
    };
  }

  @override
  Uint32List apply(Uint32List pixels, int width, int height) {
    final result = Uint32List(width * height);
    final intensity = parameters['intensity'] as double;
    final flameHeight = parameters['flameHeight'] as double;
    final animationSeed = parameters['animationSeed'] as int;
    final colorVariation = parameters['colorVariation'] as double;
    final sparkles = parameters['sparkles'] as bool;
    final baseTemperature = parameters['baseTemperature'] as double;

    final random = Random(animationSeed);

    // Create noise maps for fire simulation
    final noise1 = _generateNoise(width, height, random, 4.0);
    final noise2 = _generateNoise(width, height, random, 8.0);
    final noise3 = _generateNoise(width, height, random, 16.0);

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final index = y * width + x;
        final originalPixel = pixels[index];

        // Skip transparent pixels unless we're generating pure fire
        if (originalPixel == 0 && intensity < 1.0) {
          result[index] = 0;
          continue;
        }

        // Normalize coordinates
        final nx = x / width.toDouble();
        final ny = y / height.toDouble();

        // Create flame shape - stronger at bottom, weaker at top
        final flameStrength = _calculateFlameStrength(nx, ny, flameHeight);

        if (flameStrength <= 0) {
          result[index] = originalPixel;
          continue;
        }

        // Combine noise layers for complex fire patterns
        final noiseValue = (noise1[index] * 0.5 + noise2[index] * 0.3 + noise3[index] * 0.2);

        // Calculate fire temperature based on position and noise
        var temperature = _calculateTemperature(nx, ny, noiseValue, flameStrength, baseTemperature);

        // Add sparkles/embers
        if (sparkles && random.nextDouble() < 0.05 * intensity) {
          temperature = min(1.0, temperature + 0.3);
        }

        // Apply intensity
        temperature *= intensity;

        // Convert temperature to fire color
        final fireColor = _temperatureToColor(temperature, colorVariation, random);

        // Blend with original pixel if not pure fire effect
        Color finalColor;
        if (intensity >= 1.0 || originalPixel == 0) {
          finalColor = fireColor;
        } else {
          final originalColor = Color(originalPixel);
          finalColor = Color.lerp(originalColor, fireColor, temperature * intensity)!;
        }

        result[index] = finalColor.value;
      }
    }

    return result;
  }

  List<double> _generateNoise(int width, int height, Random random, double frequency) {
    final noise = List<double>.filled(width * height, 0.0);

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final index = y * width + x;

        // Simple noise generation
        final nx = x * frequency / width;
        final ny = y * frequency / height;

        // Create turbulent noise
        var value = 0.0;
        var amplitude = 1.0;
        var freq = 1.0;

        for (int octave = 0; octave < 4; octave++) {
          value += _noise(nx * freq, ny * freq, random) * amplitude;
          amplitude *= 0.5;
          freq *= 2.0;
        }

        noise[index] = (value + 1.0) * 0.5; // Normalize to 0-1
      }
    }

    return noise;
  }

  double _noise(double x, double y, Random random) {
    // Simple pseudo-noise function
    final seed = ((x * 12.9898 + y * 78.233) * 43758.5453).floor();
    final localRandom = Random(seed);
    return localRandom.nextDouble() * 2.0 - 1.0;
  }

  double _calculateFlameStrength(double nx, double ny, double flameHeight) {
    // Create flame shape - wide at bottom, narrow at top
    final heightFactor = 1.0 - ny;
    if (heightFactor <= 0) return 0.0;

    // Create flame silhouette
    final centerDistance = (nx - 0.5).abs();
    final maxWidth = 0.4 * heightFactor; // Flame gets narrower towards top

    if (centerDistance > maxWidth) return 0.0;

    // Smooth falloff towards edges
    final widthFactor = 1.0 - (centerDistance / maxWidth);

    // Overall flame height limit
    if (ny > flameHeight) {
      final fadeZone = 0.2;
      if (ny > flameHeight + fadeZone) return 0.0;
      final fadeFactor = 1.0 - ((ny - flameHeight) / fadeZone);
      return heightFactor * widthFactor * fadeFactor;
    }

    return heightFactor * widthFactor;
  }

  double _calculateTemperature(double nx, double ny, double noise, double flameStrength, double baseTemp) {
    // Fire is hotter at the base and center
    final heightFactor = 1.0 - ny;
    final centerFactor = 1.0 - (nx - 0.5).abs() * 2.0;

    var temperature = baseTemp;
    temperature += heightFactor * 0.3;
    temperature += centerFactor * 0.2;
    temperature += noise * 0.3;
    temperature *= flameStrength;

    return temperature.clamp(0.0, 1.0);
  }

  Color _temperatureToColor(double temperature, double variation, Random random) {
    if (temperature <= 0) return Colors.transparent;

    // Fire color palette based on temperature
    Color baseColor;

    if (temperature < 0.2) {
      // Dark red/black (cool fire)
      baseColor = Color.lerp(Colors.black, const Color(0xFF8B0000), temperature * 5)!;
    } else if (temperature < 0.4) {
      // Red to orange
      baseColor = Color.lerp(const Color(0xFF8B0000), const Color(0xFFFF4500), (temperature - 0.2) * 5)!;
    } else if (temperature < 0.6) {
      // Orange to yellow
      baseColor = Color.lerp(const Color(0xFFFF4500), const Color(0xFFFFD700), (temperature - 0.4) * 5)!;
    } else if (temperature < 0.8) {
      // Yellow to white
      baseColor = Color.lerp(const Color(0xFFFFD700), const Color(0xFFFFFFAA), (temperature - 0.6) * 5)!;
    } else {
      // Hot white/blue
      baseColor = Color.lerp(const Color(0xFFFFFFAA), const Color(0xFFAAFFFF), (temperature - 0.8) * 5)!;
    }

    // Add color variation
    if (variation > 0 && random.nextDouble() < 0.3) {
      final hue = HSVColor.fromColor(baseColor).hue;
      final newHue = (hue + (random.nextDouble() - 0.5) * variation * 60).clamp(0.0, 360.0);
      baseColor = HSVColor.fromAHSV(
        baseColor.alpha / 255.0,
        newHue,
        HSVColor.fromColor(baseColor).saturation,
        HSVColor.fromColor(baseColor).value,
      ).toColor();
    }

    return baseColor;
  }
}
