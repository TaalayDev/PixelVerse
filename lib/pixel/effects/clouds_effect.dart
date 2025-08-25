part of 'effects.dart';

/// Effect that generates realistic clouds with various styles and formations
class CloudsEffect extends Effect {
  CloudsEffect([Map<String, dynamic>? parameters])
      : super(
          EffectType.clouds,
          parameters ??
              const {
                'density': 0.6, // Cloud coverage (0-1)
                'scale': 0.3, // Cloud size (0-1)
                'softness': 0.7, // Cloud edge softness (0-1)
                'height': 0.3, // Cloud height variation (0-1)
                'baseColor': 0xFFFFFFFF, // Base cloud color (white)
                'shadowColor': 0xFFCCCCCC, // Shadow color (light gray)
                'highlightColor': 0xFFFFFFFF, // Highlight color (bright white)
                'cloudType': 0, // 0=cumulus, 1=stratus, 2=cirrus, 3=storm
                'windDirection': 0.5, // Wind direction affecting shape (0-1)
                'randomSeed': 42, // Seed for cloud generation
                'time': 0.0, // Animation time for moving clouds (0-1)
                'animated': false, // Whether clouds move/change over time
              },
        );

  @override
  Map<String, dynamic> getDefaultParameters() {
    return {
      'density': 0.6,
      'scale': 0.5,
      'softness': 0.7,
      'height': 0.3,
      'baseColor': 0xFFFFFFFF,
      'shadowColor': 0xFFCCCCCC,
      'highlightColor': 0xFFFFFFFF,
      'cloudType': 0,
      'windDirection': 0.5,
      'randomSeed': 42,
      'time': 0.0,
      'animated': false,
    };
  }

  @override
  Map<String, dynamic> getMetadata() {
    return {
      'density': {
        'label': 'Cloud Density',
        'description': 'How much of the sky is covered by clouds.',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
      'scale': {
        'label': 'Cloud Scale',
        'description': 'Size of individual cloud formations.',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
      'softness': {
        'label': 'Cloud Softness',
        'description': 'How soft and fluffy the cloud edges appear.',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
      'height': {
        'label': 'Height Variation',
        'description': 'Variation in cloud thickness and depth.',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
      'baseColor': {
        'label': 'Base Cloud Color',
        'description': 'Main color of the clouds.',
        'type': 'color',
      },
      'shadowColor': {
        'label': 'Shadow Color',
        'description': 'Color used for cloud shadows and depth.',
        'type': 'color',
      },
      'highlightColor': {
        'label': 'Highlight Color',
        'description': 'Color used for cloud highlights.',
        'type': 'color',
      },
      'cloudType': {
        'label': 'Cloud Type',
        'description': 'Different types of cloud formations.',
        'type': 'select',
        'options': {
          0: 'Cumulus (Fluffy)',
          1: 'Stratus (Layered)',
          2: 'Cirrus (Wispy)',
          3: 'Storm Clouds',
        },
      },
      'windDirection': {
        'label': 'Wind Direction',
        'description': 'Direction of wind affecting cloud shapes.',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
      'randomSeed': {
        'label': 'Cloud Pattern',
        'description': 'Changes the random cloud pattern.',
        'type': 'slider',
        'min': 1,
        'max': 100,
        'divisions': 99,
      },
      'animated': {
        'label': 'Animated Clouds',
        'description': 'Whether clouds move and change over time.',
        'type': 'bool',
      },
    };
  }

  @override
  Uint32List apply(Uint32List pixels, int width, int height) {
    final density = parameters['density'] as double;
    final scale = parameters['scale'] as double;
    final softness = parameters['softness'] as double;
    final heightVariation = parameters['height'] as double;
    final baseColor = Color(parameters['baseColor'] as int);
    final shadowColor = Color(parameters['shadowColor'] as int);
    final highlightColor = Color(parameters['highlightColor'] as int);
    final cloudType = parameters['cloudType'] as int;
    final windDirection = parameters['windDirection'] as double;
    final randomSeed = parameters['randomSeed'] as int;
    final time = parameters['time'] as double;
    final animated = parameters['animated'] as bool;

    final result = Uint32List.fromList(pixels);

    // Animation offset for moving clouds
    final animOffset = animated ? time * 2 : 0.0;

    // Generate clouds for each pixel
    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final index = y * width + x;
        final originalPixel = pixels[index];

        // Only apply clouds to transparent or very transparent pixels
        final originalAlpha = (originalPixel >> 24) & 0xFF;
        if (originalAlpha > 50) {
          continue; // Skip non-transparent pixels
        }

        // Calculate cloud density at this position
        final cloudDensityValue = _calculateCloudDensity(
            x, y, width, height, scale, density, cloudType, windDirection, randomSeed, animOffset);

        if (cloudDensityValue > 0.1) {
          // Generate cloud color based on density and height
          final cloudColor = _generateCloudColor(cloudDensityValue, x, y, width, height, baseColor, shadowColor,
              highlightColor, heightVariation, softness, randomSeed);

          // Blend with existing pixel (if any)
          result[index] = _blendCloudColor(originalPixel, cloudColor);
        }
      }
    }

    return result;
  }

  /// Calculate cloud density at a specific position
  double _calculateCloudDensity(int x, int y, int width, int height, double scale, double density, int cloudType,
      double windDirection, int seed, double animOffset) {
    // Normalize coordinates
    final normalizedX = x / width;
    final normalizedY = y / height;

    // Base noise scale - increased for smaller, more detailed clouds
    final noiseScale = (scale * 0.5 + 0.1);

    // Apply wind direction to create stretched clouds
    final windX = normalizedX + (windDirection - 0.5) * 0.3;
    final windY = normalizedY;

    double cloudValue = 0.0;

    switch (cloudType) {
      case 0: // Cumulus (Fluffy)
        cloudValue = _generateCumulusClouds(windX, windY, noiseScale, seed, animOffset);
        break;
      case 1: // Stratus (Layered)
        cloudValue = _generateStratusClouds(windX, windY, noiseScale, seed, animOffset);
        break;
      case 2: // Cirrus (Wispy)
        cloudValue = _generateCirrusClouds(windX, windY, noiseScale, seed, animOffset);
        break;
      case 3: // Storm Clouds
        cloudValue = _generateStormClouds(windX, windY, noiseScale, seed, animOffset);
        break;
    }

    // Apply density threshold
    final threshold = 1.0 - density;
    cloudValue = (cloudValue - threshold) / (1.0 - threshold);

    return cloudValue.clamp(0.0, 1.0);
  }

  /// Generate cumulus (fluffy) clouds
  double _generateCumulusClouds(double x, double y, double scale, int seed, double animOffset) {
    // Multi-octave noise for fluffy cloud texture - smaller scale for pixel art
    final noise1 = _perlinNoise(x * scale + animOffset * 0.1, y * scale, seed);
    final noise2 = _perlinNoise(x * scale * 3, y * scale * 3, seed + 1000) * 0.5;
    final noise3 = _perlinNoise(x * scale * 6, y * scale * 6, seed + 2000) * 0.25;
    final noise4 = _perlinNoise(x * scale * 12, y * scale * 12, seed + 3000) * 0.125;

    // Combine noises for fluffy appearance
    final combinedNoise = noise1 + noise2 + noise3 + noise4;

    // Apply threshold for cloud-like shapes
    final cloudValue = (combinedNoise * 0.5 + 0.5);

    // Create more defined cloud edges
    return pow(cloudValue, 1.5).toDouble();
  }

  /// Generate stratus (layered) clouds
  double _generateStratusClouds(double x, double y, double scale, int seed, double animOffset) {
    // Horizontal layers with some variation - smaller scale for pixel art
    final layerNoise = _perlinNoise(x * scale * 2 + animOffset * 0.05, y * scale * 4, seed);
    final detailNoise = _perlinNoise(x * scale * 8, y * scale * 8, seed + 1000) * 0.3;

    // Emphasize horizontal structure
    final horizontalBias = sin(y * scale * 30) * 0.2;

    return ((layerNoise + detailNoise + horizontalBias) * 0.5 + 0.5).clamp(0.0, 1.0);
  }

  /// Generate cirrus (wispy) clouds
  double _generateCirrusClouds(double x, double y, double scale, int seed, double animOffset) {
    // High frequency, stretched clouds - smaller scale for pixel art
    final stretchedX = x + sin(y * 40) * 0.05; // Reduced stretching amount

    final noise1 = _perlinNoise(stretchedX * scale * 4 + animOffset * 0.2, y * scale * 2, seed);
    final noise2 = _perlinNoise(stretchedX * scale * 12, y * scale * 6, seed + 1000) * 0.3;

    // Make wispy by applying power function
    final wispy = pow((noise1 + noise2) * 0.5 + 0.5, 2.5).toDouble();

    return wispy;
  }

  /// Generate storm clouds
  double _generateStormClouds(double x, double y, double scale, int seed, double animOffset) {
    // Dark, heavy clouds with more contrast - smaller scale for pixel art
    final noise1 = _perlinNoise(x * scale * 2 + animOffset * 0.05, y * scale * 2, seed);
    final noise2 = _perlinNoise(x * scale * 4, y * scale * 4, seed + 1000) * 0.7;
    final noise3 = _perlinNoise(x * scale * 8, y * scale * 8, seed + 2000) * 0.4;

    // Add some turbulence
    final turbulence = _perlinNoise(x * scale * 16, y * scale * 16, seed + 3000) * 0.2;

    final stormValue = noise1 + noise2 + noise3 + turbulence;

    // Create more dramatic contrast
    return pow((stormValue * 0.5 + 0.5).clamp(0.0, 1.0), 1.2).toDouble();
  }

  /// Generate cloud color based on density and position
  Color _generateCloudColor(double density, int x, int y, int width, int height_, Color baseColor, Color shadowColor,
      Color highlightColor, double heightVariation, double softness, int seed) {
    // Calculate lighting based on position (sun from top-left)
    final lightingX = x / width;
    final lightingY = y / height_;
    final lightFactor = (1.0 - lightingY * 0.5) * (1.0 - lightingX * 0.3);

    // Add some random height variation for 3D effect - higher frequency for pixel art
    final heightNoise = _perlinNoise(x * 0.1, y * 0.1, seed + 5000);
    final height = (heightNoise * 0.5 + 0.5) * heightVariation;

    // Determine if this is a highlight, base, or shadow area
    final effectiveLighting = (lightFactor + height) * density;

    Color resultColor;

    if (effectiveLighting > 0.7) {
      // Highlight areas
      resultColor = Color.lerp(baseColor, highlightColor, (effectiveLighting - 0.7) / 0.3)!;
    } else if (effectiveLighting > 0.3) {
      // Base cloud areas
      resultColor = baseColor;
    } else {
      // Shadow areas
      resultColor = Color.lerp(shadowColor, baseColor, effectiveLighting / 0.3)!;
    }

    // Apply softness to alpha based on cloud density
    final softAlpha = density * softness + (1.0 - softness);
    final finalAlpha = (resultColor.alpha * softAlpha).round().clamp(0, 255);

    return Color.fromARGB(finalAlpha, resultColor.red, resultColor.green, resultColor.blue);
  }

  /// Blend cloud color with existing pixel
  int _blendCloudColor(int existingPixel, Color cloudColor) {
    final existingAlpha = (existingPixel >> 24) & 0xFF;

    if (existingAlpha == 0) {
      // No existing pixel, use cloud color directly
      return cloudColor.value;
    }

    // Alpha blend cloud with existing pixel
    final existingColor = Color(existingPixel);
    final cloudAlpha = cloudColor.alpha / 255.0;
    final existingAlpha255 = existingAlpha / 255.0;

    final resultAlpha = cloudAlpha + existingAlpha255 * (1.0 - cloudAlpha);

    if (resultAlpha > 0) {
      final resultR =
          ((cloudColor.red * cloudAlpha + existingColor.red * existingAlpha255 * (1.0 - cloudAlpha)) / resultAlpha)
              .round();
      final resultG =
          ((cloudColor.green * cloudAlpha + existingColor.green * existingAlpha255 * (1.0 - cloudAlpha)) / resultAlpha)
              .round();
      final resultB =
          ((cloudColor.blue * cloudAlpha + existingColor.blue * existingAlpha255 * (1.0 - cloudAlpha)) / resultAlpha)
              .round();

      return Color.fromARGB((resultAlpha * 255).round().clamp(0, 255), resultR.clamp(0, 255), resultG.clamp(0, 255),
              resultB.clamp(0, 255))
          .value;
    }

    return existingPixel;
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

    // Smooth interpolation (smoothstep)
    final u = fracX * fracX * (3 - 2 * fracX);
    final v = fracY * fracY * (3 - 2 * fracY);

    // Bilinear interpolation
    final i1 = a * (1 - u) + b * u;
    final i2 = c * (1 - u) + d * u;
    final result = i1 * (1 - v) + i2 * v;

    return result * 2 - 1; // -1 to 1
  }

  /// 2D hash function for noise generation
  double _hash2D(int x, int y, int seed) {
    var h = x * 73856093 ^ y * 19349663 ^ seed;
    h = ((h >> 16) ^ h) * 0x45d9f3b;
    h = ((h >> 16) ^ h) * 0x45d9f3b;
    h = (h >> 16) ^ h;
    return (h & 0xFFFFFF) / 0xFFFFFF; // 0 to 1
  }
}
