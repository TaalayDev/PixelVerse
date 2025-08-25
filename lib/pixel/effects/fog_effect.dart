part of 'effects.dart';

/// Effect that creates rolling fog that obscures and reveals parts of the image
class FogEffect extends Effect {
  FogEffect([Map<String, dynamic>? parameters])
      : super(
          EffectType.fog,
          parameters ??
              const {
                'density': 0.6, // Overall fog density (0-1)
                'height': 0.7, // How high fog reaches (0-1)
                'speed': 0.4, // Fog movement speed (0-1)
                'direction': 0.3, // Wind direction (0-1 = 0-360°)
                'turbulence': 0.5, // Chaotic movement intensity (0-1)
                'fogColor': 0x80FFFFFF, // Fog color with alpha (white)
                'gradientStrength': 0.8, // Vertical gradient intensity (0-1)
                'visibility': 0.3, // How much the fog obscures (0-1)
                'noiseScale': 0.4, // Size of fog patterns (0-1)
                'layerCount': 3, // Number of fog layers (1-5)
                'rollingSpeed': 0.6, // Speed of rolling motion (0-1)
                'windVariation': 0.4, // Wind direction variation (0-1)
                'patchiness': 0.5, // How patchy/broken the fog is (0-1)
                'time': 0.0, // Animation time parameter (0-1)
              },
        );

  @override
  Map<String, dynamic> getDefaultParameters() {
    return {
      'density': 0.6,
      'height': 0.7,
      'speed': 0.4,
      'direction': 0.3,
      'turbulence': 0.5,
      'fogColor': 0x80FFFFFF,
      'gradientStrength': 0.8,
      'visibility': 0.3,
      'noiseScale': 0.4,
      'layerCount': 3,
      'rollingSpeed': 0.6,
      'windVariation': 0.4,
      'patchiness': 0.5,
      'time': 0.0,
    };
  }

  @override
  Map<String, dynamic> getMetadata() {
    return {
      'density': {
        'label': 'Fog Density',
        'description': 'Overall thickness and opacity of the fog.',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
      'height': {
        'label': 'Fog Height',
        'description': 'How high up the fog reaches (0 = ground level only).',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
      'speed': {
        'label': 'Movement Speed',
        'description': 'How fast the fog moves and flows.',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
      'direction': {
        'label': 'Wind Direction',
        'description': 'Primary direction of fog movement (0 = right, 0.5 = down, etc.).',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
      'turbulence': {
        'label': 'Turbulence',
        'description': 'Chaotic, swirling motion within the fog.',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
      'fogColor': {
        'label': 'Fog Color',
        'description': 'Color and opacity of the fog.',
        'type': 'color',
      },
      'gradientStrength': {
        'label': 'Vertical Gradient',
        'description': 'How much fog density varies from bottom to top.',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
      'visibility': {
        'label': 'Visibility Reduction',
        'description': 'How much the fog obscures the underlying image.',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
      'noiseScale': {
        'label': 'Pattern Scale',
        'description': 'Size of fog wisps and patterns (smaller = more detail).',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
      'layerCount': {
        'label': 'Fog Layers',
        'description': 'Number of overlapping fog layers for depth.',
        'type': 'slider',
        'min': 1,
        'max': 5,
        'divisions': 4,
      },
      'rollingSpeed': {
        'label': 'Rolling Speed',
        'description': 'Speed of rolling, tumbling motion in the fog.',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
      'windVariation': {
        'label': 'Wind Variation',
        'description': 'How much the wind direction varies over time.',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
      'patchiness': {
        'label': 'Fog Patchiness',
        'description': 'How broken up and patchy the fog appears.',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
    };
  }

  @override
  Uint32List apply(Uint32List pixels, int width, int height) {
    final density = parameters['density'] as double;
    final fogHeight = parameters['height'] as double;
    final speed = parameters['speed'] as double;
    final direction = parameters['direction'] as double;
    final turbulence = parameters['turbulence'] as double;
    final fogColor = Color(parameters['fogColor'] as int);
    final gradientStrength = parameters['gradientStrength'] as double;
    final visibility = parameters['visibility'] as double;
    final noiseScale = parameters['noiseScale'] as double;
    final layerCount = (parameters['layerCount'] as int).clamp(1, 5);
    final rollingSpeed = parameters['rollingSpeed'] as double;
    final windVariation = parameters['windVariation'] as double;
    final patchiness = parameters['patchiness'] as double;
    final time = parameters['time'] as double;

    if (density <= 0.01) {
      return Uint32List.fromList(pixels);
    }

    final result = Uint32List.fromList(pixels);

    // Calculate wind direction and variation
    final baseWindAngle = direction * 2 * pi;
    final windVarAmount = windVariation * 0.5;

    // Process each pixel
    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final index = y * width + x;

        // Calculate fog density at this position
        final fogDensity = _calculateFogDensity(x, y, width, height, time, fogHeight, noiseScale, layerCount, speed,
            baseWindAngle, windVarAmount, turbulence, rollingSpeed, patchiness, gradientStrength);

        if (fogDensity > 0.01) {
          // Apply fog to the pixel
          result[index] = _applyFogToPixel(result[index], fogColor, fogDensity * density, visibility);
        }
      }
    }

    return result;
  }

  /// Calculate fog density at a specific position
  double _calculateFogDensity(
      int x,
      int y,
      int width,
      int height,
      double time,
      double fogHeight,
      double noiseScale,
      int layerCount,
      double speed,
      double baseWindAngle,
      double windVarAmount,
      double turbulence,
      double rollingSpeed,
      double patchiness,
      double gradientStrength) {
    // Normalize coordinates
    final normalizedY = y / height;

    // Base height gradient (fog is denser at bottom)
    final heightFactor = _calculateHeightGradient(normalizedY, fogHeight, gradientStrength);

    if (heightFactor <= 0.01) return 0.0; // No fog above fog height

    // Calculate base scale for noise
    final baseScale = noiseScale * 0.1 + 0.01;

    // Animate wind direction
    final currentWindAngle = baseWindAngle + sin(time * 2) * windVarAmount;
    final windX = cos(currentWindAngle) * speed * time * 100;
    final windY = sin(currentWindAngle) * speed * time * 50;

    double totalFogDensity = 0.0;
    double totalWeight = 0.0;

    // Generate multiple fog layers for depth
    for (int layer = 0; layer < layerCount; layer++) {
      final layerScale = baseScale * (1.0 + layer * 0.3);
      final layerSpeed = speed * (0.8 + layer * 0.4);
      final layerWeight = 1.0 / (layer + 1); // Deeper layers have less influence

      // Calculate layer offset based on movement
      final layerWindX = windX * layerSpeed * (1.0 + layer * 0.2);
      final layerWindY = windY * layerSpeed * (0.8 + layer * 0.3);

      // Add rolling motion
      final rollingOffset = _calculateRollingMotion(x, y, time, rollingSpeed, layer);

      final noiseX = x * layerScale + layerWindX + rollingOffset.x;
      final noiseY = y * layerScale + layerWindY + rollingOffset.y;

      // Generate multi-octave noise for realistic fog patterns
      double layerDensity = 0.0;

      // Primary fog pattern
      layerDensity += _perlinNoise(noiseX, noiseY, layer * 1000) * 0.6;

      // Secondary detail
      layerDensity += _perlinNoise(noiseX * 2, noiseY * 2, layer * 1000 + 500) * 0.3;

      // Fine detail
      layerDensity += _perlinNoise(noiseX * 4, noiseY * 4, layer * 1000 + 1000) * 0.1;

      // Add turbulence if enabled
      if (turbulence > 0) {
        final turbulentNoise = _calculateTurbulence(noiseX, noiseY, time, turbulence, layer);
        layerDensity += turbulentNoise * 0.2;
      }

      // Apply patchiness (creates gaps and holes in fog)
      if (patchiness > 0) {
        final patchNoise = _perlinNoise(noiseX * 0.5, noiseY * 0.5, layer * 1000 + 1500);
        final patchMask = 1.0 - patchiness * 0.8 * (1.0 - (patchNoise * 0.5 + 0.5));
        layerDensity *= patchMask.clamp(0.0, 1.0);
      }

      // Normalize and clamp layer density
      layerDensity = (layerDensity * 0.5 + 0.5).clamp(0.0, 1.0);

      totalFogDensity += layerDensity * layerWeight;
      totalWeight += layerWeight;
    }

    // Average the layers
    final avgDensity = totalFogDensity / totalWeight;

    // Apply height gradient
    return (avgDensity * heightFactor).clamp(0.0, 1.0);
  }

  /// Calculate height-based fog gradient
  double _calculateHeightGradient(double normalizedY, double fogHeight, double gradientStrength) {
    if (normalizedY > fogHeight) return 0.0;

    // Create smooth gradient from bottom to fog height
    final heightRatio = 1.0 - (normalizedY / fogHeight);

    // Apply gradient strength
    if (gradientStrength > 0.5) {
      // Stronger gradient = more concentrated at bottom
      return pow(heightRatio, (gradientStrength - 0.5) * 4 + 1).toDouble();
    } else {
      // Weaker gradient = more uniform distribution
      return heightRatio * (gradientStrength * 2);
    }
  }

  /// Calculate rolling motion for more realistic fog movement
  Point<double> _calculateRollingMotion(int x, int y, double time, double rollingSpeed, int layer) {
    if (rollingSpeed <= 0.01) return const Point(0.0, 0.0);

    final timeOffset = time * rollingSpeed * 3;
    final layerOffset = layer * 0.7;

    // Create rolling patterns using multiple sine waves
    final rollX = sin(timeOffset + x * 0.01 + layerOffset) * cos(timeOffset * 0.7 + y * 0.005) * 20 * rollingSpeed;
    final rollY =
        cos(timeOffset * 1.3 + x * 0.008 + layerOffset) * sin(timeOffset * 0.9 + y * 0.006) * 15 * rollingSpeed;

    return Point(rollX, rollY);
  }

  /// Calculate turbulence for chaotic fog motion
  double _calculateTurbulence(double x, double y, double time, double turbulence, int layer) {
    final turbulentTime = time * 4;
    final layerOffset = layer * 123.456;

    // Multiple turbulence scales
    final turb1 = _perlinNoise(x * 0.05, y * 0.05, (turbulentTime * 100 + layerOffset).round());
    final turb2 = _perlinNoise(x * 0.1, y * 0.1, (turbulentTime * 200 + layerOffset).round());
    final turb3 = _perlinNoise(x * 0.2, y * 0.2, (turbulentTime * 400 + layerOffset).round());

    return (turb1 * 0.5 + turb2 * 0.3 + turb3 * 0.2) * turbulence;
  }

  /// 2D Perlin-like noise function
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

  /// 2D hash function for noise
  double _hash2D(int x, int y, int seed) {
    var h = x * 73856093 ^ y * 19349663 ^ seed;
    h = ((h >> 16) ^ h) * 0x45d9f3b;
    h = ((h >> 16) ^ h) * 0x45d9f3b;
    h = (h >> 16) ^ h;
    return (h & 0xFFFFFF) / 0xFFFFFF; // 0 to 1
  }

  /// Apply fog to a pixel
  int _applyFogToPixel(int originalPixel, Color fogColor, double fogDensity, double visibility) {
    if (fogDensity <= 0.01) return originalPixel;

    final originalA = (originalPixel >> 24) & 0xFF;
    final originalR = (originalPixel >> 16) & 0xFF;
    final originalG = (originalPixel >> 8) & 0xFF;
    final originalB = originalPixel & 0xFF;

    // Skip transparent pixels
    if (originalA == 0) return originalPixel;

    // Calculate fog alpha based on density
    final fogAlpha = (fogColor.alpha * fogDensity).clamp(0.0, 255.0);

    // Apply visibility reduction (desaturate and darken the original)
    final visibilityFactor = 1.0 - (visibility * fogDensity);
    final reducedR = (originalR * visibilityFactor).round();
    final reducedG = (originalG * visibilityFactor).round();
    final reducedB = (originalB * visibilityFactor).round();

    // Blend fog color with the visibility-reduced original
    final blendFactor = fogAlpha / 255.0;
    final invBlendFactor = 1.0 - blendFactor;

    final finalR = (reducedR * invBlendFactor + fogColor.red * blendFactor).round().clamp(0, 255);
    final finalG = (reducedG * invBlendFactor + fogColor.green * blendFactor).round().clamp(0, 255);
    final finalB = (reducedB * invBlendFactor + fogColor.blue * blendFactor).round().clamp(0, 255);
    final finalA = max(originalA, fogAlpha.round());

    return (finalA << 24) | (finalR << 16) | (finalG << 8) | finalB;
  }
}
