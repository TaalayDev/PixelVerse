part of 'effects.dart';

/// Effect that procedurally generates a city skyline with buildings
class CityEffect extends Effect {
  CityEffect([Map<String, dynamic>? parameters])
      : super(
          EffectType.city,
          parameters ??
              const {
                'buildingDensity': 0.7, // How packed the buildings are (0-1)
                'heightVariation': 0.8, // Variation in building heights (0-1)
                'minHeight': 0.2, // Minimum building height (0-1)
                'maxHeight': 0.9, // Maximum building height (0-1)
                'buildingStyle': 0, // 0=modern, 1=classic, 2=futuristic, 3=mixed
                'windowDensity': 0.6, // How many windows buildings have (0-1)
                'colorScheme': 0, // 0=realistic, 1=neon, 2=monochrome, 3=sunset
                'perspective': 0.3, // 3D perspective effect (0-1)
                'weatherEffect': 0, // 0=clear, 1=fog, 2=rain, 3=night
                'randomSeed': 42, // Seed for procedural generation
                'backgroundMode': 0, // 0=transparent, 1=sky, 2=gradient
                'antennasAndDetails': 0.4, // Rooftop details density (0-1)
                'buildingWidth': 0.5, // Average building width (0-1)
              },
        );

  @override
  Map<String, dynamic> getDefaultParameters() {
    return {
      'buildingDensity': 0.7,
      'heightVariation': 0.8,
      'minHeight': 0.2,
      'maxHeight': 0.9,
      'buildingStyle': 0,
      'windowDensity': 0.6,
      'colorScheme': 0,
      'perspective': 0.3,
      'weatherEffect': 0,
      'randomSeed': 42,
      'backgroundMode': 0,
      'antennasAndDetails': 0.4,
      'buildingWidth': 0.5,
    };
  }

  @override
  Map<String, dynamic> getMetadata() {
    return {
      'buildingDensity': {
        'label': 'Building Density',
        'description': 'How densely packed the buildings are in the city.',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
      'heightVariation': {
        'label': 'Height Variation',
        'description': 'How much building heights vary across the skyline.',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
      'minHeight': {
        'label': 'Minimum Height',
        'description': 'Minimum height of buildings relative to image height.',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
      'maxHeight': {
        'label': 'Maximum Height',
        'description': 'Maximum height of buildings relative to image height.',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
      'buildingStyle': {
        'label': 'Building Style',
        'description': 'Architectural style of the buildings.',
        'type': 'select',
        'options': {
          0: 'Modern',
          1: 'Classic',
          2: 'Futuristic',
          3: 'Mixed Styles',
        },
      },
      'windowDensity': {
        'label': 'Window Density',
        'description': 'How many windows appear on building facades.',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
      'colorScheme': {
        'label': 'Color Scheme',
        'description': 'Color palette for the city.',
        'type': 'select',
        'options': {
          0: 'Realistic',
          1: 'Neon/Cyberpunk',
          2: 'Monochrome',
          3: 'Sunset',
        },
      },
      'perspective': {
        'label': 'Perspective Effect',
        'description': 'Adds 3D perspective depth to buildings.',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
      'weatherEffect': {
        'label': 'Weather Effect',
        'description': 'Atmospheric effects on the city.',
        'type': 'select',
        'options': {
          0: 'Clear',
          1: 'Foggy',
          2: 'Rainy',
          3: 'Night',
        },
      },
      'randomSeed': {
        'label': 'Random Seed',
        'description': 'Changes the procedural city layout.',
        'type': 'slider',
        'min': 1,
        'max': 100,
        'divisions': 99,
      },
      'backgroundMode': {
        'label': 'Background',
        'description': 'Background behind the city.',
        'type': 'select',
        'options': {
          0: 'Transparent',
          1: 'Sky',
          2: 'Gradient',
        },
      },
      'antennasAndDetails': {
        'label': 'Rooftop Details',
        'description': 'Density of antennas and rooftop details.',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
      'buildingWidth': {
        'label': 'Building Width',
        'description': 'Average width of buildings.',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
    };
  }

  @override
  Uint32List apply(Uint32List pixels, int width, int height) {
    final buildingDensity = parameters['buildingDensity'] as double;
    final heightVariation = parameters['heightVariation'] as double;
    final minHeight = parameters['minHeight'] as double;
    final maxHeight = parameters['maxHeight'] as double;
    final buildingStyle = parameters['buildingStyle'] as int;
    final windowDensity = parameters['windowDensity'] as double;
    final colorScheme = parameters['colorScheme'] as int;
    final perspective = parameters['perspective'] as double;
    final weatherEffect = parameters['weatherEffect'] as int;
    final randomSeed = parameters['randomSeed'] as int;
    final backgroundMode = parameters['backgroundMode'] as int;
    final antennasAndDetails = parameters['antennasAndDetails'] as double;
    final buildingWidth = parameters['buildingWidth'] as double;

    final result = Uint32List(pixels.length);
    final random = Random(randomSeed);

    // Step 1: Create background if needed
    _createBackground(result, width, height, backgroundMode, colorScheme);

    // Step 2: Generate building layout
    final buildings = _generateBuildings(
        width, height, buildingDensity, heightVariation, minHeight, maxHeight, buildingWidth, random);

    // Step 3: Draw buildings
    for (final building in buildings) {
      _drawBuilding(result, width, height, building, buildingStyle, windowDensity, colorScheme, perspective, random);
    }

    // Step 4: Add rooftop details
    _addRooftopDetails(result, width, height, buildings, antennasAndDetails, colorScheme, random);

    // Step 5: Apply weather effects
    _applyWeatherEffect(result, width, height, weatherEffect, colorScheme);

    return result;
  }

  /// Create background based on background mode
  void _createBackground(Uint32List pixels, int width, int height, int backgroundMode, int colorScheme) {
    if (backgroundMode == 0) return; // Transparent

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final index = y * width + x;
        Color bgColor;

        switch (backgroundMode) {
          case 1: // Sky
            final skyProgress = y / height;
            bgColor = _getSkyColor(skyProgress, colorScheme);
            break;
          case 2: // Gradient
            final gradientProgress = y / height;
            bgColor = _getGradientColor(gradientProgress, colorScheme);
            break;
          default:
            continue;
        }

        pixels[index] = bgColor.value;
      }
    }
  }

  /// Get sky color based on height and color scheme
  Color _getSkyColor(double progress, int colorScheme) {
    switch (colorScheme) {
      case 0: // Realistic
        return Color.lerp(
          const Color(0xFF87CEEB), // Sky blue
          const Color(0xFFE0F6FF), // Light blue
          1.0 - progress,
        )!;
      case 1: // Neon
        return Color.lerp(
          const Color(0xFF000011), // Dark blue
          const Color(0xFF330055), // Purple
          1.0 - progress,
        )!;
      case 2: // Monochrome
        final gray = (200 - progress * 50).round();
        return Color.fromARGB(255, gray, gray, gray);
      case 3: // Sunset
        return Color.lerp(
          const Color(0xFFFF6B35), // Orange
          const Color(0xFFFFD23F), // Yellow
          1.0 - progress,
        )!;
      default:
        return const Color(0xFF87CEEB);
    }
  }

  /// Get gradient background color
  Color _getGradientColor(double progress, int colorScheme) {
    switch (colorScheme) {
      case 0: // Realistic
        return Color.lerp(Colors.grey.shade300, Colors.grey.shade100, 1.0 - progress)!;
      case 1: // Neon
        return Color.lerp(const Color(0xFF001122), const Color(0xFF004488), 1.0 - progress)!;
      case 2: // Monochrome
        final value = (150 + progress * 100).round();
        return Color.fromARGB(255, value, value, value);
      case 3: // Sunset
        return Color.lerp(const Color(0xFFFF8C42), const Color(0xFFFFF3A0), 1.0 - progress)!;
      default:
        return Colors.grey.shade200;
    }
  }

  /// Generate building layout
  List<_Building> _generateBuildings(int width, int height, double density, double heightVariation, double minHeight,
      double maxHeight, double avgWidth, Random random) {
    final buildings = <_Building>[];
    final numBuildings = (width * density * 0.1).round().clamp(3, width ~/ 2);

    var currentX = 0;

    for (int i = 0; i < numBuildings && currentX < width; i++) {
      // Calculate building width
      final widthVariation = 0.5 + random.nextDouble() * 1.0;
      final buildingWidthValue = (avgWidth * 20 * widthVariation + 8).round().clamp(1, width ~/ 3);

      if (currentX + buildingWidthValue > width) break;

      // Calculate building height
      final heightRange = maxHeight - minHeight;
      final randomHeight = minHeight + random.nextDouble() * heightRange * heightVariation;
      final buildingHeight = (randomHeight * height).round().clamp(10, height - 5);

      final building = _Building(
        x: currentX,
        y: height - buildingHeight,
        width: buildingWidthValue,
        height: buildingHeight,
        style: random.nextInt(4),
      );

      buildings.add(building);
      currentX += buildingWidthValue + random.nextInt(3); // Small gap between buildings
    }

    return buildings;
  }

  /// Draw a single building
  void _drawBuilding(Uint32List pixels, int width, int height, _Building building, int buildingStyle,
      double windowDensity, int colorScheme, double perspective, Random random) {
    // Get building colors
    final colors = _getBuildingColors(colorScheme, random);

    // Draw main building structure
    _drawBuildingStructure(pixels, width, height, building, colors.main, perspective);

    // Draw windows
    if (windowDensity > 0.1) {
      _drawWindows(pixels, width, height, building, windowDensity, colors.window, random);
    }

    // Draw architectural details based on style
    _drawArchitecturalDetails(pixels, width, height, building, buildingStyle, colors, random);
  }

  /// Draw main building structure
  void _drawBuildingStructure(
      Uint32List pixels, int width, int height, _Building building, Color mainColor, double perspective) {
    for (int y = building.y; y < building.y + building.height; y++) {
      for (int x = building.x; x < building.x + building.width; x++) {
        if (x >= 0 && x < width && y >= 0 && y < height) {
          final index = y * width + x;

          // Apply perspective shading
          var color = mainColor;
          if (perspective > 0.1) {
            final depthFactor = 1.0 - (x - building.x) / building.width * perspective * 0.3;
            color = Color.lerp(color, Colors.black, 1.0 - depthFactor)!;
          }

          pixels[index] = color.value;
        }
      }
    }
  }

  /// Draw windows on building
  void _drawWindows(
      Uint32List pixels, int width, int height, _Building building, double density, Color windowColor, Random random) {
    final windowWidth = 2;
    final windowHeight = 3;
    final spacingX = 6;
    final spacingY = 8;

    for (int y = building.y + 4; y < building.y + building.height - 4; y += spacingY) {
      for (int x = building.x + 3; x < building.x + building.width - 3; x += spacingX) {
        if (random.nextDouble() < density) {
          // Draw window
          for (int wy = 0; wy < windowHeight; wy++) {
            for (int wx = 0; wx < windowWidth; wx++) {
              final pixelX = x + wx;
              final pixelY = y + wy;

              if (pixelX >= 0 && pixelX < width && pixelY >= 0 && pixelY < height) {
                final index = pixelY * width + pixelX;

                // Add some window variation
                var color = windowColor;
                if (random.nextDouble() < 0.3) {
                  color = Color.lerp(color, Colors.yellow, 0.4)!; // Some lit windows
                }

                pixels[index] = color.value;
              }
            }
          }
        }
      }
    }
  }

  /// Draw architectural details based on building style
  void _drawArchitecturalDetails(
      Uint32List pixels, int width, int height, _Building building, int style, _BuildingColors colors, Random random) {
    switch (style) {
      case 0: // Modern - clean lines
        _drawModernDetails(pixels, width, height, building, colors);
        break;
      case 1: // Classic - decorative elements
        _drawClassicDetails(pixels, width, height, building, colors, random);
        break;
      case 2: // Futuristic - sleek design
        _drawFuturisticDetails(pixels, width, height, building, colors);
        break;
      case 3: // Mixed - combination
        if (random.nextBool()) {
          _drawModernDetails(pixels, width, height, building, colors);
        } else {
          _drawClassicDetails(pixels, width, height, building, colors, random);
        }
        break;
    }
  }

  /// Draw modern architectural details
  void _drawModernDetails(Uint32List pixels, int width, int height, _Building building, _BuildingColors colors) {
    // Draw roof line
    final roofY = building.y;
    for (int x = building.x; x < building.x + building.width; x++) {
      if (x >= 0 && x < width && roofY >= 0 && roofY < height) {
        pixels[roofY * width + x] = colors.accent.value;
      }
    }

    // Draw vertical accent lines
    for (int i = 1; i < 3; i++) {
      final lineX = building.x + (building.width * i ~/ 3);
      for (int y = building.y; y < building.y + building.height; y++) {
        if (lineX >= 0 && lineX < width && y >= 0 && y < height) {
          pixels[y * width + lineX] = colors.accent.value;
        }
      }
    }
  }

  /// Draw classic architectural details
  void _drawClassicDetails(
      Uint32List pixels, int width, int height, _Building building, _BuildingColors colors, Random random) {
    // Draw decorative top
    final decorHeight = 3;
    for (int y = building.y; y < building.y + decorHeight; y++) {
      for (int x = building.x; x < building.x + building.width; x++) {
        if (x >= 0 && x < width && y >= 0 && y < height) {
          pixels[y * width + x] = colors.accent.value;
        }
      }
    }

    // Draw columns or pilasters
    final numColumns = random.nextInt(3) + 2;
    for (int i = 0; i < numColumns; i++) {
      final columnX =
          building.x + (building.width * i ~/ (numColumns - 1)).clamp(building.x, building.x + building.width - 1);
      for (int y = building.y + decorHeight; y < building.y + building.height; y++) {
        if (columnX >= 0 && columnX < width && y >= 0 && y < height) {
          pixels[y * width + columnX] = colors.accent.value;
        }
      }
    }
  }

  /// Draw futuristic architectural details
  void _drawFuturisticDetails(Uint32List pixels, int width, int height, _Building building, _BuildingColors colors) {
    // Draw sleek horizontal lines
    final numLines = 3;
    for (int i = 0; i < numLines; i++) {
      final lineY = building.y + (building.height * (i + 1) ~/ (numLines + 1));
      for (int x = building.x + 2; x < building.x + building.width - 2; x++) {
        if (x >= 0 && x < width && lineY >= 0 && lineY < height) {
          pixels[lineY * width + x] = colors.accent.value;
        }
      }
    }

    // Draw corner accents
    final cornerSize = 2;
    final corners = [
      [building.x, building.y], // Top-left
      [building.x + building.width - cornerSize, building.y], // Top-right
    ];

    for (final corner in corners) {
      for (int y = corner[1]; y < corner[1] + cornerSize; y++) {
        for (int x = corner[0]; x < corner[0] + cornerSize; x++) {
          if (x >= 0 && x < width && y >= 0 && y < height) {
            pixels[y * width + x] = colors.accent.value;
          }
        }
      }
    }
  }

  /// Add rooftop details like antennas
  void _addRooftopDetails(Uint32List pixels, int width, int height, List<_Building> buildings, double density,
      int colorScheme, Random random) {
    for (final building in buildings) {
      if (random.nextDouble() < density) {
        final detailType = random.nextInt(3);
        final detailX = building.x + building.width ~/ 2;
        final detailColor = _getDetailColor(colorScheme);

        switch (detailType) {
          case 0: // Antenna
            _drawAntenna(pixels, width, height, detailX, building.y, detailColor);
            break;
          case 1: // Satellite dish
            _drawSatelliteDish(pixels, width, height, detailX, building.y, detailColor);
            break;
          case 2: // Small structure
            _drawRooftopStructure(pixels, width, height, detailX, building.y, detailColor, random);
            break;
        }
      }
    }
  }

  /// Draw antenna detail
  void _drawAntenna(Uint32List pixels, int width, int height, int x, int y, Color color) {
    final antennaHeight = 8;
    for (int i = 0; i < antennaHeight; i++) {
      final pixelY = y - i - 1;
      if (x >= 0 && x < width && pixelY >= 0 && pixelY < height) {
        pixels[pixelY * width + x] = color.value;
      }
    }
  }

  /// Draw satellite dish
  void _drawSatelliteDish(Uint32List pixels, int width, int height, int x, int y, Color color) {
    final dishSize = 3;
    for (int dy = -1; dy <= 1; dy++) {
      for (int dx = -dishSize; dx <= dishSize; dx++) {
        final pixelX = x + dx;
        final pixelY = y - 2 + dy;
        if (pixelX >= 0 && pixelX < width && pixelY >= 0 && pixelY < height) {
          pixels[pixelY * width + pixelX] = color.value;
        }
      }
    }
  }

  /// Draw small rooftop structure
  void _drawRooftopStructure(Uint32List pixels, int width, int height, int x, int y, Color color, Random random) {
    final structWidth = 2 + random.nextInt(3);
    final structHeight = 2 + random.nextInt(4);

    for (int dy = 0; dy < structHeight; dy++) {
      for (int dx = -structWidth ~/ 2; dx <= structWidth ~/ 2; dx++) {
        final pixelX = x + dx;
        final pixelY = y - dy - 1;
        if (pixelX >= 0 && pixelX < width && pixelY >= 0 && pixelY < height) {
          pixels[pixelY * width + pixelX] = color.value;
        }
      }
    }
  }

  /// Apply weather effects
  void _applyWeatherEffect(Uint32List pixels, int width, int height, int weatherEffect, int colorScheme) {
    switch (weatherEffect) {
      case 1: // Fog
        _applyFogEffect(pixels, width, height);
        break;
      case 2: // Rain
        _applyRainEffect(pixels, width, height);
        break;
      case 3: // Night
        _applyNightEffect(pixels, width, height, colorScheme);
        break;
      case 0: // Clear
      default:
        break;
    }
  }

  /// Apply fog effect
  void _applyFogEffect(Uint32List pixels, int width, int height) {
    final fogColor = const Color(0x40CCCCCC); // Semi-transparent gray

    for (int y = 0; y < height; y++) {
      final fogIntensity = (y / height * 0.3).clamp(0.0, 0.3);

      for (int x = 0; x < width; x++) {
        final index = y * width + x;
        final pixel = Color(pixels[index]);

        final blended = Color.lerp(pixel, fogColor, fogIntensity)!;
        pixels[index] = blended.value;
      }
    }
  }

  /// Apply rain effect
  void _applyRainEffect(Uint32List pixels, int width, int height) {
    final random = Random(12345); // Fixed seed for consistent rain
    final rainDrops = width ~/ 8;

    for (int i = 0; i < rainDrops; i++) {
      final x = random.nextInt(width);
      final rainHeight = 3 + random.nextInt(5);

      for (int j = 0; j < rainHeight; j++) {
        final y = random.nextInt(height - rainHeight) + j;
        if (x < width && y < height) {
          final index = y * width + x;
          pixels[index] = const Color(0x80AABBCC).value; // Semi-transparent blue-gray
        }
      }
    }
  }

  /// Apply night effect
  void _applyNightEffect(Uint32List pixels, int width, int height, int colorScheme) {
    final nightTint = colorScheme == 1
        ? const Color(0x60000044) // Purple tint for neon
        : const Color(0x40000022); // Blue tint for realistic

    for (int i = 0; i < pixels.length; i++) {
      final pixel = Color(pixels[i]);
      final darkened = Color.lerp(pixel, Colors.black, 0.4)!;
      final tinted = Color.lerp(darkened, nightTint, 0.3)!;
      pixels[i] = tinted.value;
    }
  }

  /// Get building colors based on color scheme
  _BuildingColors _getBuildingColors(int colorScheme, Random random) {
    switch (colorScheme) {
      case 0: // Realistic
        final baseHue = 30 + random.nextInt(60); // Brown to gray range
        final main = HSVColor.fromAHSV(1.0, baseHue.toDouble(), 0.2, 0.6 + random.nextDouble() * 0.3).toColor();
        final window = const Color(0xFF4488CC);
        final accent = Color.lerp(main, Colors.white, 0.3)!;
        return _BuildingColors(main, window, accent);

      case 1: // Neon
        final neonColors = [0xFF00FFFF, 0xFFFF00FF, 0xFFFFFF00, 0xFF00FF00];
        final main = const Color(0xFF1A1A2E);
        final window = Color(neonColors[random.nextInt(neonColors.length)]);
        final accent = Color.lerp(window, Colors.white, 0.3)!;
        return _BuildingColors(main, window, accent);

      case 2: // Monochrome
        final grayValue = 100 + random.nextInt(100);
        final main = Color.fromARGB(255, grayValue, grayValue, grayValue);
        final window = Color.fromARGB(255, grayValue + 50, grayValue + 50, grayValue + 50);
        final accent = Colors.white;
        return _BuildingColors(main, window, accent);

      case 3: // Sunset
        final warmColors = [0xFFFF6B35, 0xFFF7931E, 0xFFFFD23F, 0xFFFF8C42];
        final main = Color(warmColors[random.nextInt(warmColors.length)]);
        final window = const Color(0xFFFFE135);
        final accent = Color.lerp(main, Colors.white, 0.4)!;
        return _BuildingColors(main, window, accent);

      default:
        return _getBuildingColors(0, random);
    }
  }

  /// Get color for details based on color scheme
  Color _getDetailColor(int colorScheme) {
    switch (colorScheme) {
      case 0:
        return Colors.grey.shade400;
      case 1:
        return const Color(0xFF00FFFF);
      case 2:
        return Colors.grey.shade600;
      case 3:
        return const Color(0xFFFF8C42);
      default:
        return Colors.grey.shade400;
    }
  }
}

/// Helper class to represent a building
class _Building {
  final int x, y, width, height, style;

  _Building({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    required this.style,
  });
}

/// Helper class for building colors
class _BuildingColors {
  final Color main, window, accent;

  _BuildingColors(this.main, this.window, this.accent);
}
