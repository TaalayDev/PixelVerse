part of 'effects.dart';

/// Effect that generates realistic ocean surfaces with animated waves, foam, and depth
class OceanWavesEffect extends Effect {
  OceanWavesEffect([Map<String, dynamic>? parameters])
      : super(
          EffectType.oceanWaves,
          parameters ??
              const {
                'waveHeight': 0.6, // Wave amplitude (0-1)
                'waveFrequency': 0.5, // Wave frequency/density (0-1)
                'waveSpeed': 0.5, // Animation speed (0-1)
                'windDirection': 0.3, // Wind direction (0-1 = 0-360°)
                'waterDepth': 0.7, // Overall water depth (0-1)
                'foamIntensity': 0.4, // Wave foam/whitecaps (0-1)
                'surfaceReflection': 0.6, // Light reflection strength (0-1)
                'waterClarity': 0.8, // Water transparency/clarity (0-1)
                'deepWaterColor': 0xFF003366, // Deep ocean blue
                'shallowWaterColor': 0xFF00AACC, // Shallow turquoise
                'foamColor': 0xFFFFFFFF, // White foam
                'skyReflectionColor': 0xFF87CEEB, // Sky blue reflection
                'waveComplexity': 0.6, // Multiple wave layer complexity (0-1)
                'surfaceRoughness': 0.3, // Small surface ripples (0-1)
                'sunAngle': 0.4, // Sun position for reflections (0-1)
                'time': 0.0, // Animation time parameter (0-1)
              },
        );

  @override
  Map<String, dynamic> getDefaultParameters() {
    return {
      'waveHeight': 0.6,
      'waveFrequency': 0.5,
      'waveSpeed': 0.5,
      'windDirection': 0.3,
      'waterDepth': 0.7,
      'foamIntensity': 0.4,
      'surfaceReflection': 0.6,
      'waterClarity': 0.8,
      'deepWaterColor': 0xFF003366,
      'shallowWaterColor': 0xFF00AACC,
      'foamColor': 0xFFFFFFFF,
      'skyReflectionColor': 0xFF87CEEB,
      'waveComplexity': 0.6,
      'surfaceRoughness': 0.3,
      'sunAngle': 0.4,
      'time': 0.0,
    };
  }

  @override
  Map<String, dynamic> getMetadata() {
    return {
      'waveHeight': {
        'label': 'Wave Height',
        'description': 'Controls the amplitude/height of the waves.',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
      'waveFrequency': {
        'label': 'Wave Frequency',
        'description': 'Controls wave density and wavelength.',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
      'waveSpeed': {
        'label': 'Wave Speed',
        'description': 'Controls how fast the waves move.',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
      'windDirection': {
        'label': 'Wind Direction',
        'description': 'Direction of wind affecting wave patterns.',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
      'waterDepth': {
        'label': 'Water Depth',
        'description': 'Overall depth of the water body.',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
      'foamIntensity': {
        'label': 'Foam Intensity',
        'description': 'Amount of foam and whitecaps on wave crests.',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
      'surfaceReflection': {
        'label': 'Surface Reflection',
        'description': 'Strength of light reflections on water surface.',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
      'waterClarity': {
        'label': 'Water Clarity',
        'description': 'How clear and transparent the water is.',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
      'deepWaterColor': {
        'label': 'Deep Water Color',
        'description': 'Color of deep ocean water.',
        'type': 'color',
      },
      'shallowWaterColor': {
        'label': 'Shallow Water Color',
        'description': 'Color of shallow water areas.',
        'type': 'color',
      },
      'foamColor': {
        'label': 'Foam Color',
        'description': 'Color of wave foam and whitecaps.',
        'type': 'color',
      },
      'skyReflectionColor': {
        'label': 'Sky Reflection Color',
        'description': 'Color of sky reflections on water.',
        'type': 'color',
      },
      'waveComplexity': {
        'label': 'Wave Complexity',
        'description': 'Complexity of wave patterns (multiple wave layers).',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
      'surfaceRoughness': {
        'label': 'Surface Roughness',
        'description': 'Small surface ripples and texture details.',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
      'sunAngle': {
        'label': 'Sun Angle',
        'description': 'Position of sun for surface reflections.',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
    };
  }

  @override
  Uint32List apply(Uint32List pixels, int width, int height) {
    final waveHeight = parameters['waveHeight'] as double;
    final waveFrequency = parameters['waveFrequency'] as double;
    final waveSpeed = parameters['waveSpeed'] as double;
    final windDirection = parameters['windDirection'] as double;
    final waterDepth = parameters['waterDepth'] as double;
    final foamIntensity = parameters['foamIntensity'] as double;
    final surfaceReflection = parameters['surfaceReflection'] as double;
    final waterClarity = parameters['waterClarity'] as double;
    final deepWaterColor = Color(parameters['deepWaterColor'] as int);
    final shallowWaterColor = Color(parameters['shallowWaterColor'] as int);
    final foamColor = Color(parameters['foamColor'] as int);
    final skyReflectionColor = Color(parameters['skyReflectionColor'] as int);
    final waveComplexity = parameters['waveComplexity'] as double;
    final surfaceRoughness = parameters['surfaceRoughness'] as double;
    final sunAngle = parameters['sunAngle'] as double;
    final time = parameters['time'] as double;

    final result = Uint32List(width * height);

    // Calculate animation time
    final animTime = time * waveSpeed * 5;
    final windAngle = windDirection * 2 * pi;

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final index = y * width + x;

        // Calculate wave displacement at this position
        final waveData = _calculateWaveDisplacement(
          x,
          y,
          width,
          height,
          waveHeight,
          waveFrequency,
          waveComplexity,
          windAngle,
          animTime,
        );

        // Calculate water depth at this position
        final localDepth = _calculateWaterDepth(
          x,
          y,
          width,
          height,
          waterDepth,
          waveData.displacement,
        );

        // Calculate base water color based on depth
        final baseWaterColor = _calculateWaterColor(
          localDepth,
          waterClarity,
          deepWaterColor,
          shallowWaterColor,
        );

        // Calculate foam amount based on wave steepness
        final foamAmount = _calculateFoamAmount(
          waveData.steepness,
          foamIntensity,
          localDepth,
        );

        // Calculate surface reflection
        final reflectionAmount = _calculateSurfaceReflection(
          x,
          y,
          width,
          height,
          waveData.normal,
          surfaceReflection,
          sunAngle,
        );

        // Add surface roughness/ripples
        final roughnessEffect = _calculateSurfaceRoughness(
          x,
          y,
          surfaceRoughness,
          animTime,
        );

        // Combine all effects to get final water color
        final finalColor = _combineWaterEffects(
          baseWaterColor,
          foamColor,
          skyReflectionColor,
          foamAmount,
          reflectionAmount,
          roughnessEffect,
        );

        result[index] = finalColor.value;
      }
    }

    return result;
  }

  /// Calculate wave displacement and surface normal at a position
  _WaveData _calculateWaveDisplacement(
    int x,
    int y,
    int width,
    int height,
    double waveHeight,
    double waveFrequency,
    double complexity,
    double windAngle,
    double time,
  ) {
    // Normalize coordinates
    final normalizedX = x / width;
    final normalizedY = y / height;

    double totalDisplacement = 0.0;
    double totalSteepness = 0.0;
    Vector2 totalNormal = Vector2(0, 0);

    // Primary wave system (main ocean swells)
    final primaryWave = _generateWave(
      normalizedX,
      normalizedY,
      waveFrequency * 0.5,
      waveHeight,
      windAngle,
      time * 0.8,
    );
    totalDisplacement += primaryWave.displacement;
    totalSteepness += primaryWave.steepness;
    totalNormal = totalNormal.add(primaryWave.normal);

    // Secondary wave system (wind waves)
    if (complexity > 0.3) {
      final secondaryWave = _generateWave(
        normalizedX,
        normalizedY,
        waveFrequency * 1.5,
        waveHeight * 0.6,
        windAngle + pi / 6, // Slightly different direction
        time * 1.2,
      );
      totalDisplacement += secondaryWave.displacement * complexity;
      totalSteepness += secondaryWave.steepness * complexity;
      totalNormal = totalNormal.add(secondaryWave.normal.scale(complexity));
    }

    // Tertiary wave system (small ripples)
    if (complexity > 0.6) {
      final tertiaryWave = _generateWave(
        normalizedX,
        normalizedY,
        waveFrequency * 3.0,
        waveHeight * 0.3,
        windAngle - pi / 8,
        time * 1.8,
      );
      totalDisplacement += tertiaryWave.displacement * (complexity - 0.3);
      totalSteepness += tertiaryWave.steepness * (complexity - 0.3);
      totalNormal = totalNormal.add(tertiaryWave.normal.scale(complexity - 0.3));
    }

    return _WaveData(
      displacement: totalDisplacement,
      steepness: totalSteepness,
      normal: totalNormal.normalized(),
    );
  }

  /// Generate a single wave system
  _WaveData _generateWave(
    double x,
    double y,
    double frequency,
    double amplitude,
    double direction,
    double time,
  ) {
    // Wave direction components
    final dirX = cos(direction);
    final dirY = sin(direction);

    // Calculate wave position along direction
    final wavePos = x * dirX + y * dirY;
    final k = frequency * 10; // Wave number
    final phase = k * wavePos - time * 2;

    // Gerstner wave calculation for realistic ocean waves
    final displacement = amplitude * sin(phase);
    final steepness = amplitude * k * cos(phase);

    // Calculate surface normal (simplified)
    final normalX = -steepness * dirX;
    final normalY = -steepness * dirY;
    final normal = Vector2(normalX, normalY);

    return _WaveData(
      displacement: displacement,
      steepness: steepness.abs(),
      normal: normal,
    );
  }

  /// Calculate water depth considering waves
  double _calculateWaterDepth(
    int x,
    int y,
    int width,
    int height,
    double baseDepth,
    double waveDisplacement,
  ) {
    // Base depth varies slightly across the surface
    final normalizedY = y / height;
    final depthVariation = baseDepth + (normalizedY * 0.3); // Deeper towards bottom

    // Add wave displacement to depth
    final finalDepth = depthVariation + waveDisplacement * 0.2;

    return finalDepth.clamp(0.0, 1.0);
  }

  /// Calculate water color based on depth and clarity
  Color _calculateWaterColor(
    double depth,
    double clarity,
    Color deepColor,
    Color shallowColor,
  ) {
    // Interpolate between shallow and deep water colors
    final depthFactor = depth.clamp(0.0, 1.0);
    final baseColor = Color.lerp(shallowColor, deepColor, depthFactor)!;

    // Apply water clarity (more opaque = more color)
    final hsv = HSVColor.fromColor(baseColor);
    final adjustedSaturation = (hsv.saturation * clarity).clamp(0.0, 1.0);

    return hsv.withSaturation(adjustedSaturation).toColor();
  }

  /// Calculate foam amount based on wave steepness
  double _calculateFoamAmount(
    double steepness,
    double foamIntensity,
    double depth,
  ) {
    if (foamIntensity <= 0) return 0.0;

    // Foam appears on steep wave crests
    final foamThreshold = 1.0 - foamIntensity;
    final foamAmount = max(0.0, steepness - foamThreshold) / foamThreshold;

    // Less foam in very deep water
    final depthFactor = 1.0 - (depth * 0.3).clamp(0.0, 0.8);

    return (foamAmount * depthFactor).clamp(0.0, 1.0);
  }

  /// Calculate surface reflection based on viewing angle and sun position
  double _calculateSurfaceReflection(
    int x,
    int y,
    int width,
    int height,
    Vector2 surfaceNormal,
    double reflectionStrength,
    double sunAngle,
  ) {
    if (reflectionStrength <= 0) return 0.0;

    // Sun direction
    final sunDirection = Vector2(cos(sunAngle * 2 * pi), sin(sunAngle * 2 * pi));

    // Calculate reflection using simplified Fresnel
    final normalDotSun = surfaceNormal.dot(sunDirection).abs();
    final reflection = pow(normalDotSun, 2.0) * reflectionStrength;

    return reflection.clamp(0.0, 1.0);
  }

  /// Calculate small surface roughness effects
  double _calculateSurfaceRoughness(
    int x,
    int y,
    double roughness,
    double time,
  ) {
    if (roughness <= 0) return 0.0;

    // High-frequency surface ripples
    final ripple1 = sin(x * 0.3 + time * 3) * 0.5 + 0.5;
    final ripple2 = sin(y * 0.4 + time * 2.3) * 0.5 + 0.5;
    final ripple3 = sin((x + y) * 0.2 + time * 1.7) * 0.5 + 0.5;

    final combinedRipples = (ripple1 + ripple2 + ripple3) / 3;

    return combinedRipples * roughness * 0.3;
  }

  /// Combine all water effects into final color
  Color _combineWaterEffects(
    Color baseWaterColor,
    Color foamColor,
    Color reflectionColor,
    double foamAmount,
    double reflectionAmount,
    double roughnessEffect,
  ) {
    var finalColor = baseWaterColor;

    // Add foam
    if (foamAmount > 0) {
      finalColor = Color.lerp(finalColor, foamColor, foamAmount)!;
    }

    // Add surface reflection
    if (reflectionAmount > 0) {
      final reflectedColor = Color.lerp(finalColor, reflectionColor, reflectionAmount * 0.6)!;
      finalColor = Color.lerp(finalColor, reflectedColor, reflectionAmount)!;
    }

    // Add surface roughness (subtle brightness variation)
    if (roughnessEffect > 0) {
      final hsv = HSVColor.fromColor(finalColor);
      final adjustedValue = (hsv.value + roughnessEffect * 0.1).clamp(0.0, 1.0);
      finalColor = hsv.withValue(adjustedValue).toColor();
    }

    return finalColor;
  }
}

/// Helper class for wave calculation data
class _WaveData {
  final double displacement;
  final double steepness;
  final Vector2 normal;

  _WaveData({
    required this.displacement,
    required this.steepness,
    required this.normal,
  });
}

/// Simple 2D vector class for wave calculations
class Vector2 {
  final double x;
  final double y;

  Vector2(this.x, this.y);

  Vector2 add(Vector2 other) => Vector2(x + other.x, y + other.y);
  Vector2 scale(double factor) => Vector2(x * factor, y * factor);
  double dot(Vector2 other) => x * other.x + y * other.y;
  double get length => sqrt(x * x + y * y);
  Vector2 normalized() {
    final len = length;
    return len > 0 ? Vector2(x / len, y / len) : Vector2(0, 1);
  }
}
