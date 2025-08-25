part of 'effects.dart';

/// Effect that simulates melting where pixels droop and flow downward under gravity
class MeltEffect extends Effect {
  MeltEffect([Map<String, dynamic>? parameters])
      : super(
          EffectType.melt,
          parameters ??
              const {
                'intensity': 0.5, // How much melting occurs (0-1)
                'temperature': 0.6, // Heat level affecting melt rate (0-1)
                'viscosity': 0.4, // Thickness of melted material (0-1)
                'gravity': 0.7, // Downward force strength (0-1)
                'heatSourceX': 0.5, // Horizontal position of heat source (0-1)
                'heatSourceY': 0.2, // Vertical position of heat source (0-1)
                'heatRadius': 0.6, // Radius of heat influence (0-1)
                'surfaceTension': 0.3, // How much melted pixels stick together (0-1)
                'meltThreshold': 0.4, // Temperature threshold for melting (0-1)
                'time': 0.0, // Animation time parameter (0-1)
              },
        );

  @override
  Map<String, dynamic> getDefaultParameters() {
    return {
      'intensity': 0.5,
      'temperature': 0.6,
      'viscosity': 0.4,
      'gravity': 0.7,
      'heatSourceX': 0.5,
      'heatSourceY': 0.2,
      'heatRadius': 0.6,
      'surfaceTension': 0.3,
      'meltThreshold': 0.4,
      'time': 0.0,
    };
  }

  @override
  Map<String, dynamic> getMetadata() {
    return {
      'intensity': {
        'label': 'Melt Intensity',
        'description': 'Controls how much melting occurs overall.',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
      'temperature': {
        'label': 'Temperature',
        'description': 'Heat level affecting the rate of melting.',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
      'viscosity': {
        'label': 'Viscosity',
        'description': 'Thickness of melted material (higher = slower flow).',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
      'gravity': {
        'label': 'Gravity Strength',
        'description': 'Downward force affecting melt flow.',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
      'heatSourceX': {
        'label': 'Heat Source X',
        'description': 'Horizontal position of the heat source.',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
      'heatSourceY': {
        'label': 'Heat Source Y',
        'description': 'Vertical position of the heat source.',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
      'heatRadius': {
        'label': 'Heat Radius',
        'description': 'Radius of heat influence from the source.',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
      'surfaceTension': {
        'label': 'Surface Tension',
        'description': 'How much melted pixels stick together.',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
      'meltThreshold': {
        'label': 'Melt Threshold',
        'description': 'Temperature threshold required for melting to begin.',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
    };
  }

  @override
  Uint32List apply(Uint32List pixels, int width, int height) {
    final intensity = parameters['intensity'] as double;
    final temperature = parameters['temperature'] as double;
    final viscosity = parameters['viscosity'] as double;
    final gravity = parameters['gravity'] as double;
    final heatSourceX = parameters['heatSourceX'] as double;
    final heatSourceY = parameters['heatSourceY'] as double;
    final heatRadius = parameters['heatRadius'] as double;
    final surfaceTension = parameters['surfaceTension'] as double;
    final meltThreshold = parameters['meltThreshold'] as double;
    final time = parameters['time'] as double;

    final result = Uint32List(pixels.length);

    // Calculate heat source position in pixels
    final heatX = heatSourceX * width;
    final heatY = heatSourceY * height;
    final maxHeatDistance = heatRadius * sqrt(width * width + height * height);

    // Create melt map to track melting progress
    final meltMap = List.generate(height, (_) => List.filled(width, 0.0));

    // Calculate heat distribution and melting
    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final distance = sqrt(pow(x - heatX, 2) + pow(y - heatY, 2));
        final heatIntensity = max(0.0, 1.0 - distance / maxHeatDistance);

        // Apply temperature and time to determine melt progress
        final effectiveHeat = heatIntensity * temperature + time * 0.3;
        meltMap[y][x] = effectiveHeat > meltThreshold ? effectiveHeat - meltThreshold : 0.0;
      }
    }

    // Apply melting transformation
    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final destIndex = y * width + x;
        final originalPixel = pixels[destIndex];

        // Skip transparent pixels
        if (((originalPixel >> 24) & 0xFF) == 0) {
          result[destIndex] = 0;
          continue;
        }

        final meltLevel = meltMap[y][x] * intensity;

        if (meltLevel > 0.01) {
          // Pixel is melting - calculate where it flows from
          final sourcePos =
              _calculateMeltSource(x, y, width, height, meltLevel, gravity, viscosity, surfaceTension, time);
          result[destIndex] = _sampleMeltedPixel(pixels, width, height, sourcePos.x, sourcePos.y, meltLevel);
        } else {
          // Pixel is not melting
          result[destIndex] = originalPixel;
        }
      }
    }

    return result;
  }

  /// Calculate where a melted pixel flows from based on physics
  Point<double> _calculateMeltSource(int x, int y, int width, int height, double meltLevel, double gravity,
      double viscosity, double surfaceTension, double time) {
    // Base physics: melted pixels flow downward
    final gravityStrength = gravity * meltLevel;
    final viscousResistance = 1.0 - viscosity;

    // Calculate flow displacement over time
    final timeEffect = time * 5; // Scale time for visible effect
    final flowDistance = gravityStrength * viscousResistance * timeEffect * height * 0.3;

    // Add some horizontal spread for more realistic melting
    final horizontalSpread = sin(x * 0.1 + time * 2) * meltLevel * 2;

    // Apply surface tension (reduces spread, makes drops more cohesive)
    final tensionFactor = 1.0 - surfaceTension * 0.5;

    // Calculate source position (where this pixel came from)
    var sourceX = x + horizontalSpread * tensionFactor;
    var sourceY = y - flowDistance; // Flow came from above

    // Add dripping behavior - create droplet formation
    final dropletFormation = _calculateDropletFormation(x, y, meltLevel, time);
    sourceY -= dropletFormation;

    // Ensure source position is within reasonable bounds
    sourceX = sourceX.clamp(-width * 0.1, width * 1.1);
    sourceY = sourceY.clamp(-height * 0.2, height.toDouble());

    return Point(sourceX, sourceY);
  }

  /// Calculate droplet formation for more realistic dripping
  double _calculateDropletFormation(int x, int y, double meltLevel, double time) {
    // Create periodic droplet formation
    final dropletCycle = sin(time * 3 + x * 0.05) * 0.5 + 0.5;
    final dropletSize = meltLevel * dropletCycle * 5;

    // Droplets form and release periodically
    final releasePhase = (time * 2 + x * 0.1) % (2 * pi);
    final isDropletForming = sin(releasePhase) > 0.5;

    return isDropletForming ? dropletSize : 0.0;
  }

  /// Sample pixel from melted position with blending
  int _sampleMeltedPixel(Uint32List pixels, int width, int height, double sourceX, double sourceY, double meltLevel) {
    final intX = sourceX.round();
    final intY = sourceY.round();

    // Sample from source position if within bounds
    if (intX >= 0 && intX < width && intY >= 0 && intY < height) {
      final sourceIndex = intY * width + intX;
      if (sourceIndex < pixels.length) {
        final sourcePixel = pixels[sourceIndex];

        // Apply melting color effects (slight color bleeding and heating)
        return _applyMeltingEffects(sourcePixel, meltLevel);
      }
    }

    // If source is out of bounds, try to sample from nearby pixels for stretching effect
    final clampedX = intX.clamp(0, width - 1);
    final clampedY = intY.clamp(0, height - 1);
    final fallbackIndex = clampedY * width + clampedX;

    if (fallbackIndex < pixels.length) {
      return _applyMeltingEffects(pixels[fallbackIndex], meltLevel * 0.5);
    }

    return 0; // Transparent if no valid source
  }

  /// Apply visual effects to melted pixels
  int _applyMeltingEffects(int pixel, double meltLevel) {
    final a = (pixel >> 24) & 0xFF;
    final r = (pixel >> 16) & 0xFF;
    final g = (pixel >> 8) & 0xFF;
    final b = pixel & 0xFF;

    // Melting causes slight color changes (heating effect)
    final heatEffect = meltLevel * 0.3;

    // Slight reddish tint from heating
    final newR = (r + heatEffect * 30).clamp(0, 255).toInt();
    final newG = (g + heatEffect * 10).clamp(0, 255).toInt();
    final newB = (b - heatEffect * 5).clamp(0, 255).toInt();

    // Slight transparency increase for melted areas
    final meltTransparency = meltLevel * 0.1;
    final newA = (a * (1.0 - meltTransparency)).round().clamp(0, 255);

    return (newA << 24) | (newR << 16) | (newG << 8) | newB;
  }
}
