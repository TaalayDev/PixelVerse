part of 'effects.dart';

/// Effect that creates realistic mountain ranges with multiple layers and atmospheric effects
class MountainRangeEffect extends Effect {
  MountainRangeEffect([Map<String, dynamic>? parameters])
      : super(
          EffectType.mountainRange,
          parameters ??
              const {
                'layers': 3, // Number of mountain layers (1-5)
                'style': 0, // 0=smooth, 1=jagged, 2=rolling_hills, 3=sharp_peaks
                'heightVariation': 0.7, // Height randomness (0-1)
                'baseHeight': 0.6, // Base mountain height (0-1)
                'colorScheme': 0, // 0=blue_gradient, 1=sunset, 2=monochrome, 3=forest, 4=desert
                'atmosphericHaze': 0.5, // Atmospheric depth effect (0-1)
                'skyGradient': true, // Add sky gradient background
                'sunPosition': 0.7, // Sun position for lighting (0-1, 0=left, 1=right)
                'mistIntensity': 0.3, // Low-lying mist effect (0-1)
                'randomSeed': 42, // Seed for consistent generation
                'snowCaps': 0.2, // Snow on peaks (0-1)
                'detailLevel': 0.6, // Level of detail in mountains (0-1)
              },
        );

  @override
  Map<String, dynamic> getDefaultParameters() {
    return {
      'layers': 3,
      'style': 0,
      'heightVariation': 0.7,
      'baseHeight': 0.6,
      'colorScheme': 0,
      'atmosphericHaze': 0.5,
      'skyGradient': true,
      'sunPosition': 0.7,
      'mistIntensity': 0.3,
      'randomSeed': 42,
      'snowCaps': 0.2,
      'detailLevel': 0.6,
    };
  }

  @override
  Map<String, dynamic> getMetadata() {
    return {
      'layers': {
        'label': 'Mountain Layers',
        'description': 'Number of mountain layers for depth effect.',
        'type': 'slider',
        'min': 1,
        'max': 5,
        'divisions': 4,
      },
      'style': {
        'label': 'Mountain Style',
        'description': 'Style of mountain peaks and ridges.',
        'type': 'select',
        'options': {
          0: 'Smooth Ridges',
          1: 'Jagged Peaks',
          2: 'Rolling Hills',
          3: 'Sharp Alpine',
          4: 'Volcanic',
        },
      },
      'heightVariation': {
        'label': 'Height Variation',
        'description': 'How much mountain heights vary across the range.',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
      'baseHeight': {
        'label': 'Mountain Height',
        'description': 'Overall height of the mountain range.',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
      'colorScheme': {
        'label': 'Color Scheme',
        'description': 'Color palette for the mountain range.',
        'type': 'select',
        'options': {
          0: 'Blue Gradient',
          1: 'Sunset',
          2: 'Monochrome',
          3: 'Forest Green',
          4: 'Desert',
          5: 'Arctic',
        },
      },
      'atmosphericHaze': {
        'label': 'Atmospheric Haze',
        'description': 'Creates depth with atmospheric perspective.',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
      'skyGradient': {
        'label': 'Sky Gradient',
        'description': 'Adds a gradient sky background.',
        'type': 'bool',
      },
      'sunPosition': {
        'label': 'Sun Position',
        'description': 'Position of the sun for lighting effects (0=left, 1=right).',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
      'mistIntensity': {
        'label': 'Mist Intensity',
        'description': 'Amount of low-lying mist or fog.',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
      'randomSeed': {
        'label': 'Random Seed',
        'description': 'Changes the mountain pattern and layout.',
        'type': 'slider',
        'min': 1,
        'max': 100,
        'divisions': 99,
      },
      'snowCaps': {
        'label': 'Snow Caps',
        'description': 'Amount of snow on mountain peaks.',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
      'detailLevel': {
        'label': 'Detail Level',
        'description': 'Level of detail in mountain features.',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
    };
  }

  @override
  Uint32List apply(Uint32List pixels, int width, int height) {
    final layers = (parameters['layers'] as int).clamp(1, 5);
    final style = parameters['style'] as int;
    final heightVariation = parameters['heightVariation'] as double;
    final baseHeight = parameters['baseHeight'] as double;
    final colorScheme = parameters['colorScheme'] as int;
    final atmosphericHaze = parameters['atmosphericHaze'] as double;
    final skyGradient = parameters['skyGradient'] as bool;
    final sunPosition = parameters['sunPosition'] as double;
    final mistIntensity = parameters['mistIntensity'] as double;
    final randomSeed = parameters['randomSeed'] as int;
    final snowCaps = parameters['snowCaps'] as double;
    final detailLevel = parameters['detailLevel'] as double;

    final result = Uint32List(pixels.length);
    final random = Random(randomSeed);

    // Generate color schemes
    final colors = _getColorScheme(colorScheme, sunPosition);

    // Step 1: Fill with sky gradient if enabled
    if (skyGradient) {
      _fillSkyGradient(result, width, height, colors.skyTop, colors.skyBottom);
    }

    // Step 2: Generate mountain height profiles for each layer
    final heightProfiles = <List<double>>[];
    for (int layer = 0; layer < layers; layer++) {
      heightProfiles.add(_generateHeightProfile(
        width,
        layer,
        layers,
        style,
        heightVariation,
        baseHeight,
        detailLevel,
        random,
      ));
    }

    // Step 3: Render mountain layers from back to front
    for (int layer = layers - 1; layer >= 0; layer--) {
      final layerDepth = layer / (layers - 1); // 0 = front, 1 = back
      final layerColor = _getLayerColor(colors, layerDepth, atmosphericHaze);

      _renderMountainLayer(
        result,
        width,
        height,
        heightProfiles[layer],
        layerColor,
        sunPosition,
        snowCaps,
        layerDepth,
      );
    }

    // Step 4: Add atmospheric effects
    if (mistIntensity > 0) {
      _addMistEffect(result, width, height, mistIntensity, colors.mist, random);
    }

    return result;
  }

  /// Generate height profile for a mountain layer
  List<double> _generateHeightProfile(
    int width,
    int layer,
    int totalLayers,
    int style,
    double heightVariation,
    double baseHeight,
    double detailLevel,
    Random random,
  ) {
    final profile = List<double>.filled(width, 0.0);
    final layerOffset = layer * 1000; // Offset seed for each layer

    // Base parameters for this layer
    final layerHeight = baseHeight * (1.0 - layer * 0.2); // Further layers are shorter
    final noiseScale = 0.01 + detailLevel * 0.02;

    for (int x = 0; x < width; x++) {
      double height = 0.0;

      switch (style) {
        case 0: // Smooth ridges
          height = _smoothRidges(x, width, layerHeight, heightVariation, noiseScale, layerOffset);
          break;
        case 1: // Jagged peaks
          height = _jaggedPeaks(x, width, layerHeight, heightVariation, noiseScale, layerOffset);
          break;
        case 2: // Rolling hills
          height = _rollingHills(x, width, layerHeight, heightVariation, noiseScale, layerOffset);
          break;
        case 3: // Sharp alpine
          height = _sharpAlpine(x, width, layerHeight, heightVariation, noiseScale, layerOffset);
          break;
        case 4: // Volcanic
          height = _volcanicPeaks(x, width, layerHeight, heightVariation, noiseScale, layerOffset);
          break;
        default:
          height = _smoothRidges(x, width, layerHeight, heightVariation, noiseScale, layerOffset);
      }

      profile[x] = height;
    }

    // Normalize profile to fit within [0, 1] without clipping individual points
    double minH = double.infinity;
    double maxH = double.negativeInfinity;
    for (double h in profile) {
      if (h < minH) minH = h;
      if (h > maxH) maxH = h;
    }

    double shift = minH < 0 ? -minH : 0;
    double newMax = maxH + shift;
    double scale = newMax > 1 ? 1 / newMax : 1;

    for (int i = 0; i < width; i++) {
      profile[i] = (profile[i] + shift) * scale;
    }

    return profile;
  }

  /// Smooth ridges mountain style
  double _smoothRidges(int x, int width, double baseHeight, double variation, double scale, int offset) {
    final pos = x * scale;

    // Multiple octaves of noise for natural variation
    final noise1 = _perlinNoise(pos + offset, 0) * 0.5;
    final noise2 = _perlinNoise(pos * 2 + offset, 100) * 0.3;
    final noise3 = _perlinNoise(pos * 4 + offset, 200) * 0.2;

    final combinedNoise = (noise1 + noise2 + noise3) * variation;
    return baseHeight + combinedNoise;
  }

  /// Jagged peaks mountain style
  double _jaggedPeaks(int x, int width, double baseHeight, double variation, double scale, int offset) {
    final pos = x * scale;

    // Use absolute value of noise for sharp peaks
    final noise1 = _perlinNoise(pos + offset, 0).abs() * 0.6;
    final noise2 = _perlinNoise(pos * 3 + offset, 150) * 0.4;

    // Add some sharp spikes
    final spikes = sin(pos * 20 + offset) > 0.95 ? 0.3 : 0.0;

    return baseHeight + (noise1 + noise2 + spikes) * variation;
  }

  /// Rolling hills mountain style
  double _rollingHills(int x, int width, double baseHeight, double variation, double scale, int offset) {
    final pos = x * scale;

    // Smoother, more gradual variations
    final wave1 = sin(pos * 2 + offset) * 0.3;
    final wave2 = sin(pos * 0.5 + offset) * 0.4;
    final noise = _perlinNoise(pos + offset, 50) * 0.3;

    return baseHeight + (wave1 + wave2 + noise) * variation;
  }

  /// Sharp alpine mountain style
  double _sharpAlpine(int x, int width, double baseHeight, double variation, double scale, int offset) {
    final pos = x * scale;

    // Sharp peaks with steep sides
    final noise1 = _perlinNoise(pos + offset, 0);
    final sharpened = noise1 > 0 ? pow(noise1, 0.3) : -pow(-noise1, 0.3);
    final detail = _perlinNoise(pos * 6 + offset, 300) * 0.1;

    return baseHeight + (sharpened + detail) * variation;
  }

  /// Volcanic peaks mountain style
  double _volcanicPeaks(int x, int width, double baseHeight, double variation, double scale, int offset) {
    final pos = x * scale;

    // Create volcanic cone shapes
    final coneSpacing = 20.0;
    final conePos = (pos * coneSpacing) % (2 * pi);
    final coneHeight = max(0, cos(conePos)) * 0.6;

    final noise = _perlinNoise(pos + offset, 0) * 0.4;

    return baseHeight + (coneHeight + noise) * variation;
  }

  /// Render a single mountain layer
  void _renderMountainLayer(
    Uint32List pixels,
    int width,
    int height,
    List<double> heightProfile,
    Color layerColor,
    double sunPosition,
    double snowCaps,
    double layerDepth,
  ) {
    for (int x = 0; x < width; x++) {
      final mountainHeight = heightProfile[x];
      final pixelHeight = (mountainHeight * height).round();
      final startY = height - pixelHeight;

      for (int y = startY; y < height; y++) {
        final index = y * width + x;

        // Calculate lighting based on slope and sun position
        final lighting = _calculateLighting(x, heightProfile, sunPosition, width);

        // Calculate if this pixel should have snow
        final relativeHeight = (y - startY) / pixelHeight;
        final hasSnow = snowCaps > 0 && (1.0 - relativeHeight) > (1.0 - snowCaps);

        Color finalColor;
        if (hasSnow) {
          // Snow color with slight blue tint
          finalColor = Color.lerp(
            const Color(0xFFF0F8FF), // Snow white
            const Color(0xFFE6F3FF), // Slight blue
            layerDepth * 0.3,
          )!;
        } else {
          finalColor = layerColor;
        }

        // Apply lighting
        finalColor = _applyLighting(finalColor, lighting);

        // Always overwrite with the mountain pixel (since drawing back to front)
        pixels[index] = finalColor.value;
      }
    }
  }

  /// Calculate lighting based on mountain slope and sun position
  double _calculateLighting(int x, List<double> heightProfile, double sunPosition, int width) {
    // Calculate slope by comparing neighboring heights
    final leftHeight = x > 0 ? heightProfile[x - 1] : heightProfile[x];
    final rightHeight = x < width - 1 ? heightProfile[x + 1] : heightProfile[x];
    final slope = rightHeight - leftHeight;

    // Sun direction (-1 = left, 1 = right)
    final sunDirection = (sunPosition - 0.5) * 2;

    // Calculate lighting (facing sun = brighter)
    final lightingFactor = 0.7 + slope * sunDirection * 0.3;
    return lightingFactor.clamp(0.4, 1.2);
  }

  /// Apply lighting to a color
  Color _applyLighting(Color color, double lighting) {
    final r = (color.red * lighting).round().clamp(0, 255);
    final g = (color.green * lighting).round().clamp(0, 255);
    final b = (color.blue * lighting).round().clamp(0, 255);

    return Color.fromARGB(color.alpha, r, g, b);
  }

  /// Fill background with sky gradient
  void _fillSkyGradient(Uint32List pixels, int width, int height, Color topColor, Color bottomColor) {
    for (int y = 0; y < height; y++) {
      final t = y / height;
      final skyColor = Color.lerp(topColor, bottomColor, t)!;

      for (int x = 0; x < width; x++) {
        final index = y * width + x;
        pixels[index] = skyColor.value;
      }
    }
  }

  /// Add mist/fog effect in valleys
  void _addMistEffect(Uint32List pixels, int width, int height, double intensity, Color mistColor, Random random) {
    for (int y = height - (height * 0.3).round(); y < height; y++) {
      for (int x = 0; x < width; x++) {
        final index = y * width + x;

        // Use noise to create realistic mist patterns
        final mistNoise = _perlinNoise(x * 0.02, y * 0.01);
        final mistAlpha = (mistNoise * intensity * 100).clamp(0, 100);

        if (mistAlpha > 10) {
          final mistPixel = mistColor.withAlpha(mistAlpha.round());
          pixels[index] = _blendColors(pixels[index], mistPixel.value);
        }
      }
    }
  }

  /// Get layer color with atmospheric haze
  Color _getLayerColor(MountainColors colors, double depth, double hazeIntensity) {
    // Interpolate between base mountain color and haze color based on depth
    final baseColor = colors.mountainBase;
    final hazeColor = colors.atmosphericHaze;

    final haze = depth * hazeIntensity;
    return Color.lerp(baseColor, hazeColor, haze)!;
  }

  /// Blend two colors
  int _blendColors(int base, int overlay) {
    final baseColor = Color(base);
    final overlayColor = Color(overlay);
    final alpha = overlayColor.alpha / 255.0;

    final r = (baseColor.red * (1 - alpha) + overlayColor.red * alpha).round();
    final g = (baseColor.green * (1 - alpha) + overlayColor.green * alpha).round();
    final b = (baseColor.blue * (1 - alpha) + overlayColor.blue * alpha).round();

    return Color.fromARGB(baseColor.alpha, r, g, b).value;
  }

  /// Get color scheme for mountains
  MountainColors _getColorScheme(int scheme, double sunPosition) {
    switch (scheme) {
      case 0: // Blue gradient
        return MountainColors(
          skyTop: const Color(0xFF87CEEB),
          skyBottom: const Color(0xFFE0F6FF),
          mountainBase: const Color(0xFF4682B4),
          atmosphericHaze: const Color(0xFFB0C4DE),
          mist: const Color(0xFFF0F8FF),
        );

      case 1: // Sunset
        return MountainColors(
          skyTop: const Color(0xFF1e3c72),
          skyBottom: const Color(0xFFffeaa7),
          mountainBase: const Color(0xFF2d3436),
          atmosphericHaze: const Color(0xFFfdcb6e),
          mist: const Color(0xFFf39c12),
        );

      case 2: // Monochrome
        return MountainColors(
          skyTop: const Color(0xFF2c3e50),
          skyBottom: const Color(0xFFbdc3c7),
          mountainBase: const Color(0xFF34495e),
          atmosphericHaze: const Color(0xFF95a5a6),
          mist: const Color(0xFFecf0f1),
        );

      case 3: // Forest
        return MountainColors(
          skyTop: const Color(0xFF74b9ff),
          skyBottom: const Color(0xFFddd8d8),
          mountainBase: const Color(0xFF00b894),
          atmosphericHaze: const Color(0xFF55a3ff),
          mist: const Color(0xFFd1f2eb),
        );

      case 4: // Desert
        return MountainColors(
          skyTop: const Color(0xFFe17055),
          skyBottom: const Color(0xFFffeaa7),
          mountainBase: const Color(0xFFd63031),
          atmosphericHaze: const Color(0xFFfdcb6e),
          mist: const Color(0xFFfab1a0),
        );

      case 5: // Arctic
        return MountainColors(
          skyTop: const Color(0xFF74b9ff),
          skyBottom: const Color(0xFFffffff),
          mountainBase: const Color(0xFFddd8d8),
          atmosphericHaze: const Color(0xFFffffff),
          mist: const Color(0xFFffffff),
        );

      default:
        return _getColorScheme(0, sunPosition);
    }
  }

  /// Simple Perlin-like noise function
  double _perlinNoise(double x, double y) {
    final intX = x.floor();
    final intY = y.floor();
    final fracX = x - intX;
    final fracY = y - intY;

    final a = _hash2D(intX, intY);
    final b = _hash2D(intX + 1, intY);
    final c = _hash2D(intX, intY + 1);
    final d = _hash2D(intX + 1, intY + 1);

    final u = fracX * fracX * (3 - 2 * fracX);
    final v = fracY * fracY * (3 - 2 * fracY);

    final i1 = a * (1 - u) + b * u;
    final i2 = c * (1 - u) + d * u;

    return (i1 * (1 - v) + i2 * v) * 2 - 1; // -1 to 1
  }

  /// 2D hash function for noise
  double _hash2D(int x, int y) {
    var h = x * 73856093 ^ y * 19349663;
    h = ((h >> 16) ^ h) * 0x45d9f3b;
    h = ((h >> 16) ^ h) * 0x45d9f3b;
    h = (h >> 16) ^ h;
    return (h & 0xFFFFFF) / 0xFFFFFF; // 0 to 1
  }
}

/// Color scheme for mountain ranges
class MountainColors {
  final Color skyTop;
  final Color skyBottom;
  final Color mountainBase;
  final Color atmosphericHaze;
  final Color mist;

  const MountainColors({
    required this.skyTop,
    required this.skyBottom,
    required this.mountainBase,
    required this.atmosphericHaze,
    required this.mist,
  });
}
