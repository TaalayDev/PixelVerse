part of 'effects.dart';

/// Effect that creates realistic cloud formations with multiple layers and atmospheric effects
class CloudFormationEffect extends Effect {
  CloudFormationEffect([Map<String, dynamic>? parameters])
      : super(
          EffectType.cloudFormation,
          parameters ??
              const {
                'layers': 3, // Number of cloud layers (1-5)
                'style': 0, // 0=fluffy, 1=wispy, 2=stormy, 3=layered, 4=scattered
                'density': 0.5, // Cloud density (0-1)
                'coverage': 0.5, // How much of the sky is covered (0-1)
                'baseHeight': 0.3, // Base cloud height position (0-1, from top)
                'colorScheme': 0, // 0=daytime, 1=sunset, 2=stormy, 3=night, 4=pastel
                'atmosphericHaze': 0.3, // Atmospheric depth effect (0-1)
                'skyGradient': true, // Add sky gradient background
                'sunPosition': 0.5, // Sun position for lighting (0-1, 0=left, 1=right)
                'mistIntensity': 0.2, // Low-lying mist effect (0-1)
                'randomSeed': 42, // Seed for consistent generation
                'detailLevel': 0.6, // Level of detail in clouds (0-1)
              },
        );

  @override
  Map<String, dynamic> getDefaultParameters() {
    return {
      'layers': 3,
      'style': 0,
      'density': 0.5,
      'coverage': 0.5,
      'baseHeight': 0.3,
      'colorScheme': 0,
      'atmosphericHaze': 0.3,
      'skyGradient': true,
      'sunPosition': 0.5,
      'mistIntensity': 0.2,
      'randomSeed': 42,
      'detailLevel': 0.6,
    };
  }

  @override
  Map<String, dynamic> getMetadata() {
    return {
      'layers': {
        'label': 'Cloud Layers',
        'description': 'Number of cloud layers for depth effect.',
        'type': 'slider',
        'min': 1,
        'max': 5,
        'divisions': 4,
      },
      'style': {
        'label': 'Cloud Style',
        'description': 'Style of cloud formations.',
        'type': 'select',
        'options': {
          0: 'Fluffy Cumulus',
          1: 'Wispy Cirrus',
          2: 'Stormy Nimbus',
          3: 'Layered Stratus',
          4: 'Scattered',
        },
      },
      'density': {
        'label': 'Cloud Density',
        'description': 'How dense the individual clouds are.',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
      'coverage': {
        'label': 'Sky Coverage',
        'description': 'How much of the sky is covered by clouds.',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
      'baseHeight': {
        'label': 'Base Height',
        'description': 'Position of clouds from the top.',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
      'colorScheme': {
        'label': 'Color Scheme',
        'description': 'Color palette for the clouds.',
        'type': 'select',
        'options': {
          0: 'Daytime Blue',
          1: 'Sunset Orange',
          2: 'Stormy Gray',
          3: 'Night Dark',
          4: 'Pastel',
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
        'description': 'Changes the cloud pattern and layout.',
        'type': 'slider',
        'min': 1,
        'max': 100,
        'divisions': 99,
      },
      'detailLevel': {
        'label': 'Detail Level',
        'description': 'Level of detail in cloud features.',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
    };
  }

  @override
  Uint32List apply(Uint32List pixels, int width, int height) {
    // Extract parameters
    final layers = (parameters['layers'] as num).toInt().clamp(1, 5);
    final style = (parameters['style'] as num).toInt();
    final density = (parameters['density'] as num).toDouble();
    final coverage = (parameters['coverage'] as num).toDouble();
    final baseHeight = (parameters['baseHeight'] as num).toDouble();
    final colorScheme = (parameters['colorScheme'] as num).toInt();
    final atmosphericHaze = (parameters['atmosphericHaze'] as num).toDouble();
    final skyGradient = parameters['skyGradient'] as bool;
    final sunPosition = (parameters['sunPosition'] as num).toDouble();
    final mistIntensity = (parameters['mistIntensity'] as num).toDouble();
    final randomSeed = (parameters['randomSeed'] as num).toInt();
    final detailLevel = (parameters['detailLevel'] as num).toDouble();

    final result = Uint32List(pixels.length);
    final random = Random(randomSeed);

    // Generate color schemes
    final colors = _getColorScheme(colorScheme, sunPosition);

    // Step 1: Fill with sky gradient if enabled
    if (skyGradient) {
      _fillSkyGradient(result, width, height, colors.skyTop, colors.skyBottom);
    } else {
      for (int i = 0; i < result.length; i++) {
        result[i] = colors.skyBottom.value;
      }
    }

    // Step 2: Generate and render cloud layers from back to front
    for (int layer = layers - 1; layer >= 0; layer--) {
      // Generate a 2D density map for the current layer
      final cloudDensityMap = _generateCloudDensityMap(
        width,
        height,
        layer,
        layers,
        style,
        density,
        coverage,
        detailLevel,
        random,
      );

      final layerDepth = layer / (layers - 1).toDouble(); // 0 = front, 1 = back
      final layerColor = _getLayerColor(colors, layerDepth, atmosphericHaze);
      final highlightColor = _getHighlightColor(colors);

      // Render the layer using the 2D map
      _renderCloudLayer(
        result,
        width,
        height,
        cloudDensityMap,
        layerColor,
        highlightColor,
        sunPosition,
        baseHeight,
        layerDepth,
      );
    }

    // Step 3: Add atmospheric effects
    if (mistIntensity > 0) {
      _addMistEffect(result, width, height, mistIntensity, colors.mist, random);
    }

    return result;
  }

  /// Generates a 2D density map for a cloud layer using Fractional Brownian Motion (fBm).
  Float32List _generateCloudDensityMap(
    int width,
    int height,
    int layer,
    int totalLayers,
    int style,
    double density,
    double coverage,
    double detailLevel,
    Random random,
  ) {
    final densityMap = Float32List(width * height);
    final layerOffset =
        Point<double>(layer * 256.0 + random.nextDouble() * 100, layer * 256.0 + random.nextDouble() * 100);

    // Adjust noise scale based on style and detail
    double baseFrequency, lacunarity, persistence;
    int octaves;

    switch (style) {
      case 1: // Wispy Cirrus
        baseFrequency = 0.01;
        octaves = 3 + (detailLevel * 3).toInt();
        lacunarity = 2.5;
        persistence = 0.3;
        break;
      case 2: // Stormy Nimbus
        baseFrequency = 0.003;
        octaves = 6 + (detailLevel * 4).toInt();
        lacunarity = 2.0;
        persistence = 0.6;
        break;
      case 3: // Layered Stratus
        baseFrequency = 0.005;
        octaves = 4 + (detailLevel * 2).toInt();
        lacunarity = 2.0;
        persistence = 0.4;
        break;
      default: // Fluffy Cumulus & Scattered
        baseFrequency = 0.005;
        octaves = 5 + (detailLevel * 3).toInt();
        lacunarity = 2.0;
        persistence = 0.5;
        break;
    }

    // Scale frequency based on layer depth (background layers are larger/less detailed)
    final layerScale = 1.0 - (layer / totalLayers * 0.5);
    baseFrequency *= layerScale;

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        double noiseVal;

        // Apply different noise shaping for different styles
        if (style == 1) {
          // Wispy Cirrus - stretch the noise horizontally
          noiseVal = _fbm(x * 2.5, y * 0.5, octaves, baseFrequency, lacunarity, persistence, layerOffset);
        } else if (style == 3) {
          // Layered Stratus - flatten the noise vertically
          noiseVal = _fbm(x.toDouble(), y * 0.2, octaves, baseFrequency, lacunarity, persistence, layerOffset);
        } else {
          noiseVal = _fbm(x.toDouble(), y.toDouble(), octaves, baseFrequency, lacunarity, persistence, layerOffset);
        }

        // Remap noise from [-1, 1] to [0, 1]
        noiseVal = (noiseVal + 1.0) / 2.0;

        // Apply a shaping function to create more defined cloud edges
        noiseVal = pow(noiseVal, 1.0 + (1.0 - density) * 2.0).toDouble();

        // Use a second noise layer to control cloud coverage
        final coverageNoise = (_perlinNoise(x * 0.001, y * 0.001, layerOffset) + 1.0) / 2.0;
        final coverageThreshold = 1.0 - coverage;

        if (coverageNoise < coverageThreshold) {
          noiseVal = 0;
        } else {
          // Smooth the transition at the coverage edge
          final transitionWidth = 0.1;
          if (coverageNoise < coverageThreshold + transitionWidth) {
            noiseVal *= (coverageNoise - coverageThreshold) / transitionWidth;
          }
        }

        densityMap[y * width + x] = noiseVal.clamp(0.0, 1.0).toDouble();
      }
    }
    return densityMap;
  }

  /// Renders a cloud layer based on its 2D density map.
  void _renderCloudLayer(
    Uint32List pixels,
    int width,
    int height,
    Float32List densityMap,
    Color baseColor,
    Color highlightColor,
    double sunPosition,
    double baseHeight,
    double layerDepth,
  ) {
    final cloudHeight = height * 0.3; // Max height of cloud shapes
    final layerYOffset = height * baseHeight + layerDepth * height * 0.1;

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final index = y * width + x;
        final density = densityMap[index];

        if (density > 0.01) {
          // Map density to a vertical position within the cloud's allowed height
          final cloudShapeY = cloudHeight * (1.0 - density);
          final currentPixelY = y - layerYOffset;

          // Check if the current pixel is inside the cloud shape
          if (currentPixelY > cloudShapeY) {
            // The alpha is determined by the density
            final alpha = (density * 255).toInt().clamp(0, 255);

            // Calculate lighting
            final litColor = _calculate2DLighting(density, baseColor, highlightColor, x / width, sunPosition);

            final cloudPixel = litColor.withAlpha(alpha);
            pixels[index] = _blendColors(pixels[index], cloudPixel.value);
          }
        }
      }
    }
  }

  /// Calculates lighting for a cloud pixel based on density and sun position.
  Color _calculate2DLighting(
      double density, Color baseColor, Color highlightColor, double xNormal, double sunPosition) {
    // Base lighting on density (denser parts are brighter)
    final densityLight = 0.8 + density * 0.2;

    // Add a highlight based on proximity to the sun
    final sunHighlight = 1.0 - (xNormal - sunPosition).abs();
    final highlightIntensity = pow(sunHighlight, 16).toDouble() * density * 0.5;

    // Combine base color with highlight color
    final r = baseColor.red * densityLight + highlightColor.red * highlightIntensity;
    final g = baseColor.green * densityLight + highlightColor.green * highlightIntensity;
    final b = baseColor.blue * densityLight + highlightColor.blue * highlightIntensity;

    return Color.fromARGB(255, r.round().clamp(0, 255), g.round().clamp(0, 255), b.round().clamp(0, 255));
  }

  /// Fill background with sky gradient
  void _fillSkyGradient(Uint32List pixels, int width, int height, Color topColor, Color bottomColor) {
    for (int y = 0; y < height; y++) {
      final t = y / height.toDouble();
      final skyColor = Color.lerp(topColor, bottomColor, t)!;
      for (int x = 0; x < width; x++) {
        pixels[y * width + x] = skyColor.value;
      }
    }
  }

  /// Add mist/fog effect in lower areas
  void _addMistEffect(Uint32List pixels, int width, int height, double intensity, Color mistColor, Random random) {
    final mistHeight = height * 0.4 * intensity;
    final startY = height - mistHeight;
    final offset = Point<double>(random.nextDouble() * 100, random.nextDouble() * 100);

    for (int y = startY.toInt(); y < height; y++) {
      for (int x = 0; x < width; x++) {
        final index = y * width + x;
        final mistNoise = (_perlinNoise(x * 0.02, y * 0.02, offset) + 1.0) / 2.0;
        final yFactor = (y - startY) / mistHeight;
        final alpha = (mistNoise * yFactor * intensity * 255).clamp(0, 255).toInt();

        if (alpha > 0) {
          final mistPixel = mistColor.withAlpha(alpha);
          pixels[index] = _blendColors(pixels[index], mistPixel.value);
        }
      }
    }
  }

  /// Get layer color with atmospheric haze
  Color _getLayerColor(CloudColors colors, double depth, double hazeIntensity) {
    final baseColor = colors.cloudBase;
    final hazeColor = colors.atmosphericHaze;
    final haze = depth * hazeIntensity;
    return Color.lerp(baseColor, hazeColor, haze)!;
  }

  /// Get highlight color based on scheme
  Color _getHighlightColor(CloudColors colors) => colors.cloudHighlight;

  /// Blend two colors using alpha compositing
  int _blendColors(int base, int overlay) {
    final overlayColor = Color(overlay);
    if (overlayColor.alpha == 0) return base;
    if (overlayColor.alpha == 255) return overlay;

    final baseColor = Color(base);
    final alpha = overlayColor.alpha / 255.0;
    final invAlpha = 1.0 - alpha;

    final r = (baseColor.red * invAlpha + overlayColor.red * alpha).round();
    final g = (baseColor.green * invAlpha + overlayColor.green * alpha).round();
    final b = (baseColor.blue * invAlpha + overlayColor.blue * alpha).round();

    return Color.fromARGB(baseColor.alpha, r, g, b).value;
  }

  /// Get color scheme for clouds
  CloudColors _getColorScheme(int scheme, double sunPosition) {
    switch (scheme) {
      case 1: // Sunset Orange
        return CloudColors(
          skyTop: const Color(0xFF4A466D),
          skyBottom: const Color(0xFFF07E6E),
          cloudBase: const Color(0xFFC0B9DD),
          cloudHighlight: const Color(0xFFFFD6B3),
          atmosphericHaze: const Color(0xFFD49A8D),
          mist: const Color(0xFFF0C3A2),
        );
      case 2: // Stormy Gray
        return CloudColors(
          skyTop: const Color(0xFF465162),
          skyBottom: const Color(0xFF8696A7),
          cloudBase: const Color(0xFF6C7A8B),
          cloudHighlight: const Color(0xFFBCC8D5),
          atmosphericHaze: const Color(0xFF778899),
          mist: const Color(0xFFB0B8C0),
        );
      case 3: // Night Dark
        return CloudColors(
          skyTop: const Color(0xFF0D1A2F),
          skyBottom: const Color(0xFF26345A),
          cloudBase: const Color(0xFF3A4C7A),
          cloudHighlight: const Color(0xFF8A9BC8),
          atmosphericHaze: const Color(0xFF5A6C9A),
          mist: const Color(0xFF4A5C8A),
        );
      case 4: // Pastel
        return CloudColors(
          skyTop: const Color(0xFFA1CCE8),
          skyBottom: const Color(0xFFE6E6FA),
          cloudBase: const Color(0xFFFFF0F5),
          cloudHighlight: const Color(0xFFFFFFFF),
          atmosphericHaze: const Color(0xFFDDA0DD),
          mist: const Color(0xFFF0FFF0),
        );
      default: // Daytime Blue
        return CloudColors(
          skyTop: const Color(0xFF87CEEB),
          skyBottom: const Color(0xFFB4E6FF),
          cloudBase: const Color(0xFFF0F8FF),
          cloudHighlight: const Color(0xFFFFFFFF),
          atmosphericHaze: const Color(0xFFC0D8E8),
          mist: const Color(0xFFF0F8FF),
        );
    }
  }

  /// Fractional Brownian Motion for detailed noise.
  double _fbm(
      double x, double y, int octaves, double frequency, double lacunarity, double persistence, Point<double> offset) {
    double total = 0;
    double amplitude = 1.0;
    double freq = frequency;

    for (int i = 0; i < octaves; i++) {
      total += _perlinNoise(x * freq + offset.x, y * freq + offset.y, Point(0, 0)) * amplitude;
      freq *= lacunarity;
      amplitude *= persistence;
    }
    return total;
  }

  /// 2D Perlin-like noise function.
  double _perlinNoise(double x, double y, Point<double> offset) {
    final intX = x.floor();
    final intY = y.floor();
    final fracX = x - intX;
    final fracY = y - intY;

    final u = fracX * fracX * (3 - 2 * fracX);
    final v = fracY * fracY * (3 - 2 * fracY);

    final p00 = _hash2D(intX, intY, offset);
    final p10 = _hash2D(intX + 1, intY, offset);
    final p01 = _hash2D(intX, intY + 1, offset);
    final p11 = _hash2D(intX + 1, intY + 1, offset);

    final i1 = p00 * (1 - u) + p10 * u;
    final i2 = p01 * (1 - u) + p11 * u;

    return (i1 * (1 - v) + i2 * v) * 2.0 - 1.0; // Output in range [-1, 1]
  }

  /// Simple pseudo-random hash function for noise generation.
  double _hash2D(int x, int y, Point<double> offset) {
    // A common hashing technique for procedural generation
    var h = x * 73856093 ^ y * 19349663;
    h = ((h >> 13) ^ h) * 127412617;
    return (h & 0x7fffffff) / 0x7fffffff; // Output in range [0, 1]
  }
}

/// Defines the color palette for the cloud and sky.
class CloudColors {
  final Color skyTop;
  final Color skyBottom;
  final Color cloudBase;
  final Color cloudHighlight;
  final Color atmosphericHaze;
  final Color mist;

  const CloudColors({
    required this.skyTop,
    required this.skyBottom,
    required this.cloudBase,
    required this.cloudHighlight,
    required this.atmosphericHaze,
    required this.mist,
  });
}
