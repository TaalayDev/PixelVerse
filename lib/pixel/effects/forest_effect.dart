part of 'effects.dart';

/// Effect that generates a multi-layered forest with procedural trees.
class ForestEffect extends Effect {
  ForestEffect([Map<String, dynamic>? parameters])
      : super(
          EffectType.forest,
          parameters ??
              const {
                'layers': 4, // Number of forest layers (1-5)
                'treeDensity': 0.6, // How dense the forest is (0-1)
                'treeType': 0, // 0=pine, 1=deciduous, 2=mixed
                'sizeVariation': 0.5, // Tree size randomness (0-1)
                'baseHeight': 0.4, // Base tree height (0-1)
                'colorScheme': 0, // 0=spring_green, 1=autumn, 2=winter, 3=night
                'atmosphericHaze': 0.6, // Atmospheric depth effect (0-1)
                'skyGradient': true, // Add sky gradient background
                'groundLevel': 0.85, // Where the ground starts (0-1, from top)
                'randomSeed': 42, // Seed for consistent generation
              },
        );

  @override
  Map<String, dynamic> getDefaultParameters() {
    return {
      'layers': 4,
      'treeDensity': 0.6,
      'treeType': 0,
      'sizeVariation': 0.5,
      'baseHeight': 0.4,
      'colorScheme': 0,
      'atmosphericHaze': 0.6,
      'skyGradient': true,
      'groundLevel': 0.85,
      'randomSeed': 42,
    };
  }

  @override
  Map<String, dynamic> getMetadata() {
    return {
      'layers': {
        'label': 'Forest Layers',
        'description': 'Number of forest layers for depth.',
        'type': 'slider',
        'min': 1,
        'max': 5,
        'divisions': 4,
      },
      'treeDensity': {
        'label': 'Tree Density',
        'description': 'How many trees are in the forest.',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
      'treeType': {
        'label': 'Tree Type',
        'description': 'The style of trees in the forest.',
        'type': 'select',
        'options': {0: 'Pine', 1: 'Deciduous', 2: 'Mixed'},
      },
      'sizeVariation': {
        'label': 'Size Variation',
        'description': 'How much tree sizes vary.',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
      'baseHeight': {
        'label': 'Tree Height',
        'description': 'Overall height of the trees.',
        'type': 'slider',
        'min': 0.1,
        'max': 0.8,
        'divisions': 70,
      },
      'colorScheme': {
        'label': 'Color Scheme',
        'description': 'Color palette for the forest.',
        'type': 'select',
        'options': {
          0: 'Spring Green',
          1: 'Autumn',
          2: 'Winter',
          3: 'Night',
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
      'groundLevel': {
        'label': 'Ground Level',
        'description': 'The position of the ground.',
        'type': 'slider',
        'min': 0.5,
        'max': 1.0,
        'divisions': 50,
      },
      'randomSeed': {
        'label': 'Random Seed',
        'description': 'Changes the forest layout.',
        'type': 'slider',
        'min': 1,
        'max': 100,
        'divisions': 99,
      },
    };
  }

  @override
  Uint32List apply(Uint32List pixels, int width, int height) {
    // Extract parameters
    final layers = (parameters['layers'] as int).clamp(1, 5);
    final treeDensity = parameters['treeDensity'] as double;
    final treeType = parameters['treeType'] as int;
    final sizeVariation = parameters['sizeVariation'] as double;
    final baseHeight = parameters['baseHeight'] as double;
    final colorScheme = parameters['colorScheme'] as int;
    final atmosphericHaze = parameters['atmosphericHaze'] as double;
    final skyGradient = parameters['skyGradient'] as bool;
    final groundLevel = ((parameters['groundLevel'] as double) * height).round();
    final randomSeed = parameters['randomSeed'] as int;

    final result = Uint32List(pixels.length);
    final random = Random(randomSeed);

    // Get color palette
    final colors = _getColorScheme(colorScheme);

    // Step 1: Fill background
    _fillBackground(result, width, height, skyGradient, groundLevel, colors);

    // Step 2: Render forest layers from back to front
    for (int layer = layers - 1; layer >= 0; layer--) {
      final layerDepth = layers > 1 ? layer / (layers - 1) : 0.0; // 0=front, 1=back
      _renderForestLayer(
        result,
        width,
        height,
        layer,
        layers,
        treeDensity,
        treeType,
        sizeVariation,
        baseHeight,
        groundLevel,
        colors,
        atmosphericHaze,
        layerDepth,
        random,
      );
    }

    return result;
  }

  /// Fills the background with sky and ground colors.
  void _fillBackground(
      Uint32List pixels, int width, int height, bool skyGradient, int groundLevel, ForestColors colors) {
    for (int y = 0; y < height; y++) {
      Color color;
      if (y < groundLevel) {
        // Sky
        if (skyGradient) {
          final t = y / (groundLevel - 1);
          color = Color.lerp(colors.skyTop, colors.skyBottom, t)!;
        } else {
          color = colors.skyBottom;
        }
      } else {
        // Ground
        color = colors.ground;
      }
      for (int x = 0; x < width; x++) {
        pixels[y * width + x] = color.value;
      }
    }
  }

  /// Renders a single layer of the forest.
  void _renderForestLayer(
    Uint32List pixels,
    int width,
    int height,
    int layer,
    int totalLayers,
    double density,
    int treeType,
    double sizeVariation,
    double baseHeight,
    int groundLevel,
    ForestColors colors,
    double haze,
    double depth,
    Random random,
  ) {
    final treeCount = (width * density * (0.5 + (1.0 - depth) * 0.5)).round();
    final layerColor = _getLayerColors(colors, depth, haze);

    for (int i = 0; i < treeCount; i++) {
      // Determine tree properties based on layer and randomness
      final x = random.nextInt(width);
      final sizeMod = (1.0 - depth) * 0.7 + 0.3; // Closer trees are larger
      final treeH = (height * baseHeight * sizeMod) * (1.0 - sizeVariation * random.nextDouble());
      final treeW = treeH * (0.4 + random.nextDouble() * 0.3);

      // FIX: Place tree on the ground, with slight vertical variation to embed them in the soil.
      final y = groundLevel + random.nextInt(5);

      // Determine the type of tree to draw
      final currentTreeType = treeType == 2 ? random.nextInt(2) : treeType;

      if (currentTreeType == 0) {
        _drawPineTree(pixels, width, height, x, y, treeW.round(), treeH.round(), layerColor);
      } else {
        _drawDeciduousTree(pixels, width, height, x, y, treeW.round(), treeH.round(), layerColor);
      }
    }
  }

  /// Draws a simple triangular pine tree.
  void _drawPineTree(
      Uint32List pixels, int width, int height, int x, int y, int treeW, int treeH, _LayerColors colors) {
    final trunkWidth = max(1, (treeW * 0.2).round());
    final trunkHeight = (treeH * 0.3).round();

    // Draw trunk
    for (int j = 0; j < trunkHeight; j++) {
      for (int i = -trunkWidth ~/ 2; i < trunkWidth ~/ 2; i++) {
        final px = x + i;
        final py = y - j;
        if (px >= 0 && px < width && py >= 0 && py < height) {
          pixels[py * width + px] = colors.trunk.value;
        }
      }
    }

    // Draw leaves (triangle)
    final leavesHeight = treeH - trunkHeight;
    for (int j = 0; j < leavesHeight; j++) {
      final currentWidth = (treeW * (1.0 - j / leavesHeight)).round();
      for (int i = -currentWidth ~/ 2; i < currentWidth ~/ 2; i++) {
        final px = x + i;
        final py = y - trunkHeight - j;
        if (px >= 0 && px < width && py >= 0 && py < height) {
          pixels[py * width + px] = colors.leaves.value;
        }
      }
    }
  }

  /// Draws a simple deciduous tree (trunk + circle).
  void _drawDeciduousTree(
      Uint32List pixels, int width, int height, int x, int y, int treeW, int treeH, _LayerColors colors) {
    final trunkWidth = max(1, (treeW * 0.25).round());
    final trunkHeight = (treeH * 0.4).round();

    // Draw trunk
    for (int j = 0; j < trunkHeight; j++) {
      for (int i = -trunkWidth ~/ 2; i < trunkWidth ~/ 2; i++) {
        final px = x + i;
        final py = y - j;
        if (px >= 0 && px < width && py >= 0 && py < height) {
          pixels[py * width + px] = colors.trunk.value;
        }
      }
    }

    // Draw leaves (circle)
    final leavesRadius = treeW / 2;
    final leavesCenterY = y - trunkHeight - leavesRadius.round();
    for (int j = -leavesRadius.round(); j <= leavesRadius.round(); j++) {
      for (int i = -leavesRadius.round(); i <= leavesRadius.round(); i++) {
        if (i * i + j * j <= leavesRadius * leavesRadius) {
          final px = x + i;
          final py = leavesCenterY + j;
          if (px >= 0 && px < width && py >= 0 && py < height) {
            pixels[py * width + px] = colors.leaves.value;
          }
        }
      }
    }
  }

  /// Gets layer colors with atmospheric haze and darkening applied.
  _LayerColors _getLayerColors(ForestColors colors, double depth, double hazeIntensity) {
    final hazeColor = colors.haze;
    final hazeAmount = depth * hazeIntensity;

    // Apply atmospheric haze
    final hazedLeaves = Color.lerp(colors.leaves, hazeColor, hazeAmount)!;
    final hazedTrunk = Color.lerp(colors.trunk, hazeColor, hazeAmount)!;

    // FIX: Apply darkening for distant layers
    final darkenFactor = depth * 0.4;
    final finalLeaves = Color.lerp(hazedLeaves, Colors.black, darkenFactor)!;
    final finalTrunk = Color.lerp(hazedTrunk, Colors.black, darkenFactor)!;

    return _LayerColors(
      leaves: finalLeaves,
      trunk: finalTrunk,
    );
  }

  /// Defines color schemes for the forest.
  ForestColors _getColorScheme(int scheme) {
    switch (scheme) {
      case 1: // Autumn
        return const ForestColors(
            skyTop: Color(0xFFF3A683),
            skyBottom: Color(0xFFF7D794),
            ground: Color(0xFFB33939),
            leaves: Color(0xFFD35400),
            trunk: Color(0xFF4D2A0C),
            haze: Color(0xFFF5CBA7));
      case 2: // Winter
        return const ForestColors(
            skyTop: Color(0xFFCAD3C8),
            skyBottom: Color(0xFFF0F3F4),
            ground: Color(0xFFFFFFFF),
            leaves: Color(0xFFE2E8F0),
            trunk: Color(0xFF5A626B),
            haze: Color(0xFFD4DADC));
      case 3: // Night
        return const ForestColors(
            skyTop: Color(0xFF0C2461),
            skyBottom: Color(0xFF1E3799),
            ground: Color(0xFF030D26),
            leaves: Color(0xFF072B53),
            trunk: Color(0xFF02162B),
            haze: Color(0xFF122A69));
      case 0: // Spring Green
      default:
        return const ForestColors(
            skyTop: Color(0xFF82CCDD),
            skyBottom: Color(0xFFC8D6E5),
            ground: Color(0xFF3B5B1D),
            leaves: Color(0xFF218F76),
            trunk: Color(0xFF4C3A2B),
            haze: Color(0xFFA4B0BE));
    }
  }
}

/// Holds the set of colors for a forest scene.
class ForestColors {
  final Color skyTop, skyBottom, ground, leaves, trunk, haze;
  const ForestColors({
    required this.skyTop,
    required this.skyBottom,
    required this.ground,
    required this.leaves,
    required this.trunk,
    required this.haze,
  });
}

/// Holds the specific colors for a single layer's trees.
class _LayerColors {
  final Color leaves, trunk;
  const _LayerColors({required this.leaves, required this.trunk});
}
