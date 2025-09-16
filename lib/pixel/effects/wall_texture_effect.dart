part of 'effects.dart';

/// Effect that generates various types of wall textures including stone, brick, concrete, and more
class WallTextureEffect extends Effect {
  WallTextureEffect([Map<String, dynamic>? parameters])
      : super(
          EffectType.wallTexture,
          parameters ??
              const {
                'wallType': 0, // 0=stone, 1=brick, 2=concrete, 3=cobblestone, 4=marble, 5=granite, 6=sandstone
                'textureScale': 0.5, // Scale of texture details (0-1)
                'colorVariation': 0.6, // Color variation across wall (0-1)
                'roughness': 0.7, // Surface roughness/bumpiness (0-1)
                'baseColor': 0xFF888888, // Base wall color
                'accentColor': 0xFFAAAAAA, // Accent/highlight color
                'shadowColor': 0xFF555555, // Shadow/depth color
                'mortarColor': 0xFF666666, // Mortar/joint color (for brick/stone)
                'weathering': 0.3, // Age/weather effects (0-1)
                'lighting': 0.5, // Directional lighting intensity (0-1)
                'lightAngle': 0.25, // Light direction (0-1, 0=left, 0.5=top, 1=right)
                'randomSeed': 42, // Seed for texture generation
                'blendAmount': 0.7, // How much to blend with the original layer
              },
        );

  @override
  Map<String, dynamic> getDefaultParameters() {
    return {
      'wallType': 0,
      'textureScale': 0.5,
      'colorVariation': 0.6,
      'roughness': 0.7,
      'baseColor': 0xFF888888,
      'accentColor': 0xFFAAAAAA,
      'shadowColor': 0xFF555555,
      'mortarColor': 0xFF666666,
      'weathering': 0.3,
      'lighting': 0.5,
      'lightAngle': 0.25,
      'randomSeed': 42,
      'blendAmount': 0.7,
    };
  }

  @override
  Map<String, dynamic> getMetadata() {
    return {
      'wallType': {
        'label': 'Wall Type',
        'description': 'Type of wall texture to generate.',
        'type': 'select',
        'options': {
          0: 'Stone Wall',
          1: 'Brick Wall',
          2: 'Concrete Wall',
          3: 'Cobblestone',
          4: 'Marble Wall',
          5: 'Granite Wall',
          6: 'Sandstone Wall',
          7: 'Modern Brick',
          8: 'Castle Stone',
        },
      },
      'textureScale': {
        'label': 'Texture Scale',
        'description': 'Controls the size of texture details and patterns.',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
      'colorVariation': {
        'label': 'Color Variation',
        'description': 'Amount of color variation across the wall surface.',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
      'roughness': {
        'label': 'Surface Roughness',
        'description': 'How rough and bumpy the wall surface appears.',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
      'baseColor': {
        'label': 'Base Color',
        'description': 'Primary color of the wall material.',
        'type': 'color',
      },
      'accentColor': {
        'label': 'Accent Color',
        'description': 'Secondary color for highlights and details.',
        'type': 'color',
      },
      'shadowColor': {
        'label': 'Shadow Color',
        'description': 'Color used for shadows and depth.',
        'type': 'color',
      },
      'mortarColor': {
        'label': 'Mortar Color',
        'description': 'Color of mortar joints between stones/bricks.',
        'type': 'color',
      },
      'weathering': {
        'label': 'Weathering',
        'description': 'Amount of age and weather damage on the wall.',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
      'lighting': {
        'label': 'Lighting Intensity',
        'description': 'Strength of directional lighting effects.',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
      'lightAngle': {
        'label': 'Light Direction',
        'description': 'Direction of lighting (0=left, 0.5=top, 1=right).',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
      'randomSeed': {
        'label': 'Texture Seed',
        'description': 'Changes the random texture pattern.',
        'type': 'slider',
        'min': 1,
        'max': 100,
        'divisions': 99,
      },
      'blendAmount': {
        'label': 'Blend Amount',
        'description': 'How much the texture blends with the original layer.',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
    };
  }

  @override
  Uint32List apply(Uint32List pixels, int width, int height) {
    final wallType = parameters['wallType'] as int;
    final textureScale = parameters['textureScale'] as double;
    final colorVariation = parameters['colorVariation'] as double;
    final roughness = parameters['roughness'] as double;
    final baseColor = Color(parameters['baseColor'] as int);
    final accentColor = Color(parameters['accentColor'] as int);
    final shadowColor = Color(parameters['shadowColor'] as int);
    final mortarColor = Color(parameters['mortarColor'] as int);
    final weathering = parameters['weathering'] as double;
    final lighting = parameters['lighting'] as double;
    final lightAngle = parameters['lightAngle'] as double;
    final randomSeed = parameters['randomSeed'] as int;
    final blendAmount = parameters['blendAmount'] as double;

    final result = Uint32List.fromList(pixels);
    final random = Random(randomSeed);

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final index = y * width + x;
        final originalPixel = Color(pixels[index]);

        if (originalPixel.alpha < 10) {
          continue;
        }

        // Generate wall texture based on type
        final wallColor = _generateWallTexture(x, y, width, height, wallType, textureScale, colorVariation, roughness,
            baseColor, accentColor, shadowColor, mortarColor, weathering, lighting, lightAngle, random);

        // Blend with original pixel
        final blendedColor = Color.lerp(originalPixel, wallColor, blendAmount)!;
        result[index] = blendedColor.value;
      }
    }

    return result;
  }

  /// Generate wall texture color for a specific pixel
  Color _generateWallTexture(
      int x,
      int y,
      int width,
      int height,
      int wallType,
      double textureScale,
      double colorVariation,
      double roughness,
      Color baseColor,
      Color accentColor,
      Color shadowColor,
      Color mortarColor,
      double weathering,
      double lighting,
      double lightAngle,
      Random random) {
    switch (wallType) {
      case 0: // Stone Wall
        return _generateStoneWall(x, y, textureScale, colorVariation, roughness, baseColor, accentColor, shadowColor,
            mortarColor, weathering, lighting, lightAngle, random);
      case 1: // Brick Wall
        return _generateBrickWall(x, y, textureScale, colorVariation, roughness, baseColor, accentColor, shadowColor,
            mortarColor, weathering, lighting, lightAngle, random);
      case 2: // Concrete Wall
        return _generateConcreteWall(x, y, textureScale, colorVariation, roughness, baseColor, accentColor, shadowColor,
            weathering, lighting, lightAngle, random);
      case 3: // Cobblestone
        return _generateCobblestone(x, y, textureScale, colorVariation, roughness, baseColor, accentColor, shadowColor,
            mortarColor, weathering, lighting, lightAngle, random);
      case 4: // Marble Wall
        return _generateMarbleWall(x, y, textureScale, colorVariation, roughness, baseColor, accentColor, shadowColor,
            weathering, lighting, lightAngle, random);
      case 5: // Granite Wall
        return _generateGraniteWall(x, y, textureScale, colorVariation, roughness, baseColor, accentColor, shadowColor,
            weathering, lighting, lightAngle, random);
      case 6: // Sandstone Wall
        return _generateSandstoneWall(x, y, textureScale, colorVariation, roughness, baseColor, accentColor,
            shadowColor, weathering, lighting, lightAngle, random);
      case 7: // Modern Brick
        return _generateModernBrick(x, y, textureScale, colorVariation, roughness, baseColor, accentColor, shadowColor,
            mortarColor, weathering, lighting, lightAngle, random);
      case 8: // Castle Stone
        return _generateCastleStone(x, y, textureScale, colorVariation, roughness, baseColor, accentColor, shadowColor,
            mortarColor, weathering, lighting, lightAngle, random);
      default:
        return _generateStoneWall(x, y, textureScale, colorVariation, roughness, baseColor, accentColor, shadowColor,
            mortarColor, weathering, lighting, lightAngle, random);
    }
  }

  /// Generate stone wall texture
  Color _generateStoneWall(int x, int y, double scale, double colorVar, double rough, Color base, Color accent,
      Color shadow, Color mortar, double weather, double lighting, double lightAngle, Random random) {
    final stoneScale = scale * 0.1 + 0.05;

    // Create stone block pattern
    final blockSize = (scale * 20 + 10).round();
    final blockX = x ~/ blockSize;
    final blockY = y ~/ (blockSize * 0.7).round(); // Rectangular stones

    // Check if we're on mortar lines
    final mortarThickness = max(1, (scale * 2).round());
    final isHorizontalMortar = y % (blockSize * 0.7).round() < mortarThickness;
    final isVerticalMortar = x % blockSize < mortarThickness;

    if (isHorizontalMortar || isVerticalMortar) {
      return _applyWeathering(mortar, weather, random);
    }

    // Generate stone texture within blocks
    final stoneNoise1 = _perlinNoise(x * stoneScale, y * stoneScale, blockX + blockY * 1000);
    final stoneNoise2 = _perlinNoise(x * stoneScale * 2, y * stoneScale * 2, blockX + blockY * 1000 + 500);
    final roughNoise = _perlinNoise(x * stoneScale * 4, y * stoneScale * 4, blockX + blockY * 1000 + 1000);

    // Combine noises for realistic stone texture
    final textureValue = (stoneNoise1 * 0.5 + stoneNoise2 * 0.3 + roughNoise * 0.2 * rough);

    // Apply color variation
    final colorShift = textureValue * colorVar;
    Color stoneColor = _interpolateColors(base, accent, 0.5 + colorShift);

    // Apply lighting
    stoneColor = _applyLighting(stoneColor, x, y, lighting, lightAngle, roughNoise * rough);

    // Apply weathering
    return _applyWeathering(stoneColor, weather, random);
  }

  /// Generate brick wall texture
  Color _generateBrickWall(int x, int y, double scale, double colorVar, double rough, Color base, Color accent,
      Color shadow, Color mortar, double weather, double lighting, double lightAngle, Random random) {
    final brickWidth = (scale * 15 + 8).round();
    final brickHeight = (scale * 8 + 4).round();
    final mortarThickness = max(1, (scale * 2 + 1).round());

    // Calculate brick position with offset pattern
    final row = y ~/ (brickHeight + mortarThickness);
    final offset = (row % 2 == 0) ? 0 : brickWidth ~/ 2;
    final col = (x + offset) ~/ (brickWidth + mortarThickness);

    // Check if we're in mortar
    final localX = (x + offset) % (brickWidth + mortarThickness);
    final localY = y % (brickHeight + mortarThickness);

    if (localX >= brickWidth || localY >= brickHeight) {
      return _applyWeathering(mortar, weather, random);
    }

    // Generate brick texture
    final brickSeed = col * 73 + row * 137;
    final brickNoise1 = _perlinNoise(x * 0.05, y * 0.05, brickSeed);
    final brickNoise2 = _perlinNoise(x * 0.1, y * 0.1, brickSeed + 500);

    final textureValue = (brickNoise1 * 0.7 + brickNoise2 * 0.3) * rough;

    // Each brick has slightly different color
    final brickColorVar = _hash(brickSeed) * colorVar * 0.3;
    Color brickColor = _interpolateColors(base, accent, 0.5 + brickColorVar);

    // Apply surface texture
    final surfaceShift = textureValue * 0.2;
    brickColor = _interpolateColors(brickColor, shadow, surfaceShift.abs());

    // Apply lighting
    brickColor = _applyLighting(brickColor, x, y, lighting, lightAngle, textureValue);

    return _applyWeathering(brickColor, weather, random);
  }

  /// Generate concrete wall texture
  Color _generateConcreteWall(int x, int y, double scale, double colorVar, double rough, Color base, Color accent,
      Color shadow, double weather, double lighting, double lightAngle, Random random) {
    final concreteScale = scale * 0.05 + 0.02;

    // Generate concrete texture with multiple noise octaves
    final noise1 = _perlinNoise(x * concreteScale, y * concreteScale, 0);
    final noise2 = _perlinNoise(x * concreteScale * 3, y * concreteScale * 3, 1000);
    final noise3 = _perlinNoise(x * concreteScale * 8, y * concreteScale * 8, 2000);

    final textureValue = (noise1 * 0.6 + noise2 * 0.3 + noise3 * 0.1) * rough;

    // Apply color variation
    final colorShift = textureValue * colorVar;
    Color concreteColor = _interpolateColors(base, accent, 0.5 + colorShift);

    // Add concrete-specific features (subtle streaks and imperfections)
    final streakNoise = _perlinNoise(x * 0.01, y * 0.03, 3000);
    if (streakNoise > 0.3) {
      concreteColor = _interpolateColors(concreteColor, shadow, streakNoise * 0.2);
    }

    // Apply lighting
    concreteColor = _applyLighting(concreteColor, x, y, lighting, lightAngle, textureValue);

    return _applyWeathering(concreteColor, weather, random);
  }

  /// Generate cobblestone texture
  Color _generateCobblestone(int x, int y, double scale, double colorVar, double rough, Color base, Color accent,
      Color shadow, Color mortar, double weather, double lighting, double lightAngle, Random random) {
    final cobbleSize = (scale * 12 + 6).round();

    // Create irregular cobblestone pattern
    final gridX = x ~/ cobbleSize;
    final gridY = y ~/ cobbleSize;
    final cobbleSeed = gridX * 73 + gridY * 137;

    // Add randomness to cobble positions
    final offsetX = (_hash(cobbleSeed) - 0.5) * cobbleSize * 0.3;
    final offsetY = (_hash(cobbleSeed + 1000) - 0.5) * cobbleSize * 0.3;

    final cobbleCenterX = gridX * cobbleSize + cobbleSize / 2 + offsetX;
    final cobbleCenterY = gridY * cobbleSize + cobbleSize / 2 + offsetY;

    final distanceToCenter = sqrt(pow(x - cobbleCenterX, 2) + pow(y - cobbleCenterY, 2));
    final cobbleRadius = cobbleSize * 0.4 * (0.8 + _hash(cobbleSeed + 2000) * 0.4);

    // Check if we're in mortar (between cobbles)
    if (distanceToCenter > cobbleRadius) {
      return _applyWeathering(mortar, weather, random);
    }

    // Generate cobble texture
    final cobbleNoise = _perlinNoise(x * 0.08, y * 0.08, cobbleSeed);
    final textureValue = cobbleNoise * rough;

    // Each cobble has unique color
    final cobbleColorVar = _hash(cobbleSeed + 3000) * colorVar;
    Color cobbleColor = _interpolateColors(base, accent, 0.5 + cobbleColorVar);

    // Add rounded cobble lighting
    final roundingEffect = 1.0 - (distanceToCenter / cobbleRadius);
    cobbleColor = _interpolateColors(cobbleColor, shadow, 1.0 - roundingEffect * 0.5);

    // Apply surface texture
    cobbleColor = _interpolateColors(cobbleColor, accent, textureValue.abs() * 0.3);

    // Apply lighting
    cobbleColor = _applyLighting(cobbleColor, x, y, lighting, lightAngle, textureValue);

    return _applyWeathering(cobbleColor, weather, random);
  }

  /// Generate marble wall texture
  Color _generateMarbleWall(int x, int y, double scale, double colorVar, double rough, Color base, Color accent,
      Color shadow, double weather, double lighting, double lightAngle, Random random) {
    final marbleScale = scale * 0.02 + 0.01;

    // Generate marble veining
    final vein1 = _perlinNoise(x * marbleScale * 2, y * marbleScale, 0);
    final vein2 = _perlinNoise(x * marbleScale, y * marbleScale * 3, 1000);
    final baseNoise = _perlinNoise(x * marbleScale * 4, y * marbleScale * 4, 2000);

    // Create marble veining pattern
    final veinPattern = sin(vein1 * 8) * sin(vein2 * 6) * 0.5 + 0.5;
    final isVein = veinPattern > 0.7;

    Color marbleColor = base;

    if (isVein) {
      // Vein color
      marbleColor = _interpolateColors(shadow, accent, veinPattern);
    } else {
      // Base marble color with subtle variation
      final colorShift = baseNoise * colorVar * 0.3;
      marbleColor = _interpolateColors(base, accent, 0.5 + colorShift);
    }

    // Add subtle texture
    final textureShift = baseNoise * rough * 0.2;
    marbleColor = _interpolateColors(marbleColor, shadow, textureShift.abs());

    // Apply lighting (marble is often polished)
    marbleColor = _applyLighting(marbleColor, x, y, lighting * 1.2, lightAngle, baseNoise * 0.5);

    return _applyWeathering(marbleColor, weather * 0.5, random); // Marble weathers less
  }

  /// Generate granite wall texture
  Color _generateGraniteWall(int x, int y, double scale, double colorVar, double rough, Color base, Color accent,
      Color shadow, double weather, double lighting, double lightAngle, Random random) {
    final graniteScale = scale * 0.3 + 0.1;

    // Generate granite speckled texture
    final speckle1 = _perlinNoise(x * graniteScale, y * graniteScale, 0);
    final speckle2 = _perlinNoise(x * graniteScale * 3, y * graniteScale * 3, 1000);
    final speckle3 = _perlinNoise(x * graniteScale * 8, y * graniteScale * 8, 2000);

    // Create granite speckled pattern
    final specklePattern = (speckle1 * 0.5 + speckle2 * 0.3 + speckle3 * 0.2);

    Color graniteColor = base;

    // Add speckled coloring
    if (speckle3 > 0.4) {
      graniteColor = accent; // Light speckles
    } else if (speckle3 < -0.4) {
      graniteColor = shadow; // Dark speckles
    } else {
      final colorShift = specklePattern * colorVar;
      graniteColor = _interpolateColors(base, accent, 0.5 + colorShift);
    }

    // Apply surface roughness
    final roughnessShift = specklePattern * rough * 0.3;
    graniteColor = _interpolateColors(graniteColor, shadow, roughnessShift.abs());

    // Apply lighting
    graniteColor = _applyLighting(graniteColor, x, y, lighting, lightAngle, specklePattern);

    return _applyWeathering(graniteColor, weather, random);
  }

  /// Generate sandstone wall texture
  Color _generateSandstoneWall(int x, int y, double scale, double colorVar, double rough, Color base, Color accent,
      Color shadow, double weather, double lighting, double lightAngle, Random random) {
    final sandScale = scale * 0.15 + 0.05;

    // Generate sandstone layered texture
    final layer1 = _perlinNoise(x * sandScale * 0.5, y * sandScale, 0);
    final layer2 = _perlinNoise(x * sandScale, y * sandScale * 2, 1000);
    final grainNoise = _perlinNoise(x * sandScale * 6, y * sandScale * 6, 2000);

    // Create layered sandstone effect
    final layerPattern = sin(y * sandScale * 20) * 0.3 + layer1 * 0.4 + layer2 * 0.3;
    final grainEffect = grainNoise * rough * 0.3;

    // Apply color variation based on layers
    final colorShift = (layerPattern + grainEffect) * colorVar;
    Color sandstoneColor = _interpolateColors(base, accent, 0.5 + colorShift);

    // Add sandy texture
    sandstoneColor = _interpolateColors(sandstoneColor, shadow, grainEffect.abs());

    // Apply lighting
    sandstoneColor = _applyLighting(sandstoneColor, x, y, lighting, lightAngle, layerPattern);

    return _applyWeathering(sandstoneColor, weather, random);
  }

  /// Generate modern brick texture (smoother, more uniform)
  Color _generateModernBrick(int x, int y, double scale, double colorVar, double rough, Color base, Color accent,
      Color shadow, Color mortar, double weather, double lighting, double lightAngle, Random random) {
    final brickWidth = (scale * 18 + 12).round();
    final brickHeight = (scale * 6 + 4).round();
    final mortarThickness = max(1, (scale * 1.5 + 1).round());

    // Modern brick layout (more precise)
    final row = y ~/ (brickHeight + mortarThickness);
    final offset = (row % 2 == 0) ? 0 : brickWidth ~/ 2;
    final col = (x + offset) ~/ (brickWidth + mortarThickness);

    final localX = (x + offset) % (brickWidth + mortarThickness);
    final localY = y % (brickHeight + mortarThickness);

    if (localX >= brickWidth || localY >= brickHeight) {
      return _applyWeathering(mortar, weather * 0.5, random); // Less weathering on modern mortar
    }

    // Modern brick texture (smoother)
    final brickSeed = col * 73 + row * 137;
    final brickNoise = _perlinNoise(x * 0.1, y * 0.1, brickSeed) * rough * 0.5;

    // Uniform color with slight variation
    final brickColorVar = _hash(brickSeed) * colorVar * 0.2;
    Color brickColor = _interpolateColors(base, accent, 0.5 + brickColorVar);

    // Subtle surface texture
    brickColor = _interpolateColors(brickColor, shadow, brickNoise.abs());

    // Apply lighting
    brickColor = _applyLighting(brickColor, x, y, lighting, lightAngle, brickNoise);

    return _applyWeathering(brickColor, weather * 0.3, random); // Modern brick weathers less
  }

  /// Generate castle stone texture (large, irregular blocks)
  Color _generateCastleStone(int x, int y, double scale, double colorVar, double rough, Color base, Color accent,
      Color shadow, Color mortar, double weather, double lighting, double lightAngle, Random random) {
    final stoneScale = scale * 0.05 + 0.02;

    // Large, irregular stone blocks
    final blockWidth = (scale * 30 + 20).round();
    final blockHeight = (scale * 25 + 15).round();
    final mortarThickness = max(2, (scale * 4 + 2).round());

    final row = y ~/ (blockHeight + mortarThickness);
    final col = x ~/ (blockWidth + mortarThickness);

    // Add irregularity to block sizes
    final blockSeed = col * 73 + row * 137;
    final widthVar = (_hash(blockSeed) - 0.5) * blockWidth * 0.3;
    final heightVar = (_hash(blockSeed + 1000) - 0.5) * blockHeight * 0.3;

    final adjustedBlockWidth = blockWidth + widthVar;
    final adjustedBlockHeight = blockHeight + heightVar;

    final localX = x % (blockWidth + mortarThickness);
    final localY = y % (blockHeight + mortarThickness);

    if (localX >= adjustedBlockWidth || localY >= adjustedBlockHeight) {
      return _applyWeathering(mortar, weather * 1.5, random); // Castle mortar weathers more
    }

    // Castle stone texture (rough and aged)
    final stoneNoise1 = _perlinNoise(x * stoneScale, y * stoneScale, blockSeed);
    final stoneNoise2 = _perlinNoise(x * stoneScale * 2, y * stoneScale * 2, blockSeed + 500);
    final ageNoise = _perlinNoise(x * stoneScale * 4, y * stoneScale * 4, blockSeed + 1000);

    final textureValue = (stoneNoise1 * 0.4 + stoneNoise2 * 0.4 + ageNoise * 0.2) * rough;

    // Each stone block has unique weathering
    final stoneColorVar = _hash(blockSeed + 2000) * colorVar * 0.4;
    Color stoneColor = _interpolateColors(base, shadow, 0.3 + stoneColorVar); // Darker base for castle stone

    // Apply age and texture
    stoneColor = _interpolateColors(stoneColor, accent, textureValue.abs() * 0.2);

    // Apply lighting with more dramatic shadows
    stoneColor = _applyLighting(stoneColor, x, y, lighting * 1.3, lightAngle, textureValue);

    return _applyWeathering(stoneColor, weather * 2.0, random); // Castle stone heavily weathered
  }

  /// Apply lighting effects to a color
  Color _applyLighting(Color baseColor, int x, int y, double lightIntensity, double lightAngle, double surfaceNormal) {
    if (lightIntensity <= 0.01) return baseColor;

    // Calculate light direction
    final lightDirX = cos(lightAngle * 2 * pi);
    final lightDirY = sin(lightAngle * 2 * pi);

    // Simple lighting calculation
    final lightEffect = (lightDirX * 0.5 + lightDirY * 0.3 + surfaceNormal * 0.2) * lightIntensity;

    if (lightEffect > 0) {
      // Highlight
      return Color.lerp(baseColor, Colors.white, lightEffect * 0.3)!;
    } else {
      // Shadow
      return Color.lerp(baseColor, Colors.black, (-lightEffect) * 0.4)!;
    }
  }

  /// Apply weathering effects to a color
  Color _applyWeathering(Color baseColor, double weatherLevel, Random random) {
    if (weatherLevel <= 0.01) return baseColor;

    // Weathering darkens and adds variation
    final weatheringEffect = random.nextDouble() * weatherLevel;

    // Darken slightly
    final darkenedColor = Color.lerp(baseColor, Colors.black, weatheringEffect * 0.2)!;

    // Add slight green tint for moss/age
    if (weatheringEffect > 0.5) {
      return Color.lerp(darkenedColor, const Color(0xFF4A5D23), weatheringEffect * 0.1)!;
    }

    return darkenedColor;
  }

  /// Interpolate between two colors
  Color _interpolateColors(Color color1, Color color2, double t) {
    return Color.lerp(color1, color2, t.clamp(0.0, 1.0))!;
  }

  /// 2D Perlin-like noise function
  double _perlinNoise(double x, double y, int seed) {
    final intX = x.floor();
    final intY = y.floor();
    final fracX = x - intX;
    final fracY = y - intY;

    final a = _hash2D(intX, intY, seed);
    final b = _hash2D(intX + 1, intY, seed);
    final c = _hash2D(intX, intY + 1, seed);
    final d = _hash2D(intX + 1, intY + 1, seed);

    final u = fracX * fracX * (3 - 2 * fracX);
    final v = fracY * fracY * (3 - 2 * fracY);

    final i1 = a * (1 - u) + b * u;
    final i2 = c * (1 - u) + d * u;

    return (i1 * (1 - v) + i2 * v) * 2 - 1; // -1 to 1
  }

  /// 2D hash function for noise
  double _hash2D(int x, int y, int seed) {
    var h = x * 73856093 ^ y * 19349663 ^ seed;
    h = ((h >> 16) ^ h) * 0x45d9f3b;
    h = ((h >> 16) ^ h) * 0x45d9f3b;
    h = (h >> 16) ^ h;
    return (h & 0xFFFFFF) / 0xFFFFFF; // 0 to 1
  }

  /// Simple hash function
  double _hash(int input) {
    var h = input;
    h = ((h >> 16) ^ h) * 0x45d9f3b;
    h = ((h >> 16) ^ h) * 0x45d9f3b;
    h = (h >> 16) ^ h;
    return (h & 0xFFFFFF) / 0xFFFFFF; // 0 to 1
  }
}
