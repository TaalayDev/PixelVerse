part of 'effects.dart';

/// Effect that creates wobbly, gelatinous motion where parts lag behind movement
class JelloEffect extends Effect {
  JelloEffect([Map<String, dynamic>? parameters])
      : super(
          EffectType.jello,
          parameters ??
              const {
                'wobbleIntensity': 0.5, // Overall wobble strength (0-1)
                'elasticity': 0.6, // How springy the material is (0-1)
                'damping': 0.4, // How quickly wobbles settle (0-1)
                'viscosity': 0.3, // Internal friction/resistance (0-1)
                'gridResolution': 0.5, // Simulation grid density (0-1)
                'forceX': 0.0, // External horizontal force (-1 to 1)
                'forceY': 0.0, // External vertical force (-1 to 1)
                'gravity': 0.2, // Downward force affecting wobble (0-1)
                'surfaceTension': 0.4, // How much the surface tries to stay smooth (0-1)
                'attachmentPoints': 0.3, // How many points are fixed (0-1)
                'waveSpeed': 0.7, // Speed of wave propagation (0-1)
                'turbulence': 0.2, // Random motion for more natural wobble (0-1)
                'time': 0.0, // Animation time parameter (0-1)
              },
        );

  @override
  Map<String, dynamic> getDefaultParameters() {
    return {
      'wobbleIntensity': 0.5,
      'elasticity': 0.6,
      'damping': 0.4,
      'viscosity': 0.3,
      'gridResolution': 0.5,
      'forceX': 0.0,
      'forceY': 0.0,
      'gravity': 0.2,
      'surfaceTension': 0.4,
      'attachmentPoints': 0.3,
      'waveSpeed': 0.7,
      'turbulence': 0.2,
      'time': 0.0,
    };
  }

  @override
  Map<String, dynamic> getMetadata() {
    return {
      'wobbleIntensity': {
        'label': 'Wobble Intensity',
        'description': 'Overall strength of the jello wobbling effect.',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
      'elasticity': {
        'label': 'Elasticity',
        'description': 'How springy and bouncy the jello material is.',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
      'damping': {
        'label': 'Damping',
        'description': 'How quickly the wobbles settle down over time.',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
      'viscosity': {
        'label': 'Viscosity',
        'description': 'Internal friction that resists movement.',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
      'gridResolution': {
        'label': 'Grid Resolution',
        'description': 'Simulation detail level (higher = more detailed wobbles).',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
      'forceX': {
        'label': 'Horizontal Force',
        'description': 'External force pushing the jello left/right.',
        'type': 'slider',
        'min': -1.0,
        'max': 1.0,
        'divisions': 100,
      },
      'forceY': {
        'label': 'Vertical Force',
        'description': 'External force pushing the jello up/down.',
        'type': 'slider',
        'min': -1.0,
        'max': 1.0,
        'divisions': 100,
      },
      'gravity': {
        'label': 'Gravity',
        'description': 'Downward gravitational force affecting the wobble.',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
      'surfaceTension': {
        'label': 'Surface Tension',
        'description': 'How much the surface tries to stay smooth.',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
      'attachmentPoints': {
        'label': 'Attachment Points',
        'description': 'How many points are fixed in place (creates anchoring).',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
      'waveSpeed': {
        'label': 'Wave Speed',
        'description': 'Speed at which wobbles propagate through the material.',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
      'turbulence': {
        'label': 'Turbulence',
        'description': 'Random motion for more chaotic, natural wobbling.',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
    };
  }

  @override
  Uint32List apply(Uint32List pixels, int width, int height) {
    final wobbleIntensity = parameters['wobbleIntensity'] as double;
    final elasticity = parameters['elasticity'] as double;
    final damping = parameters['damping'] as double;
    final viscosity = parameters['viscosity'] as double;
    final gridResolution = parameters['gridResolution'] as double;
    final forceX = parameters['forceX'] as double;
    final forceY = parameters['forceY'] as double;
    final gravity = parameters['gravity'] as double;
    final surfaceTension = parameters['surfaceTension'] as double;
    final attachmentPoints = parameters['attachmentPoints'] as double;
    final waveSpeed = parameters['waveSpeed'] as double;
    final turbulence = parameters['turbulence'] as double;
    final time = parameters['time'] as double;

    if (wobbleIntensity <= 0.01) {
      return Uint32List.fromList(pixels);
    }

    final result = Uint32List(pixels.length);

    // Calculate grid size based on resolution
    final gridSize = (gridResolution * 15 + 5).round().clamp(3, 20);
    final gridWidth = (width / gridSize).ceil() + 1;
    final gridHeight = (height / gridSize).ceil() + 1;

    // Create and simulate the jello grid
    final grid = _createJelloGrid(gridWidth, gridHeight, width, height);
    _simulateJelloPhysics(grid, gridWidth, gridHeight, elasticity, damping, viscosity, forceX, forceY, gravity,
        surfaceTension, attachmentPoints, waveSpeed, turbulence, time);

    // Apply the jello deformation to the image
    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final destIndex = y * width + x;

        // Find source position by reverse-mapping through deformed grid
        final sourcePos =
            _mapThroughJelloGrid(x, y, grid, gridWidth, gridHeight, gridSize, width, height, wobbleIntensity);

        // Sample from source position
        result[destIndex] = _samplePixel(pixels, width, height, sourcePos.x, sourcePos.y);
      }
    }

    return result;
  }

  /// Create initial jello simulation grid
  List<List<_JelloPoint>> _createJelloGrid(int gridWidth, int gridHeight, int imgWidth, int imgHeight) {
    final grid = <List<_JelloPoint>>[];

    for (int y = 0; y < gridHeight; y++) {
      final row = <_JelloPoint>[];
      for (int x = 0; x < gridWidth; x++) {
        final worldX = (x / (gridWidth - 1)) * imgWidth;
        final worldY = (y / (gridHeight - 1)) * imgHeight;

        row.add(_JelloPoint(
          restX: worldX,
          restY: worldY,
          currentX: worldX,
          currentY: worldY,
          velocityX: 0.0,
          velocityY: 0.0,
          mass: 1.0,
          isFixed: false,
        ));
      }
      grid.add(row);
    }

    return grid;
  }

  /// Simulate jello physics on the grid
  void _simulateJelloPhysics(
      List<List<_JelloPoint>> grid,
      int gridWidth,
      int gridHeight,
      double elasticity,
      double damping,
      double viscosity,
      double forceX,
      double forceY,
      double gravity,
      double surfaceTension,
      double attachmentPoints,
      double waveSpeed,
      double turbulence,
      double time) {
    final timeStep = 0.016; // ~60fps simulation
    final maxForce = 50.0; // Limit force magnitude

    // Mark some points as fixed (attachment points)
    _setAttachmentPoints(grid, gridWidth, gridHeight, attachmentPoints);

    // Apply forces to each grid point
    for (int y = 0; y < gridHeight; y++) {
      for (int x = 0; x < gridWidth; x++) {
        final point = grid[y][x];
        if (point.isFixed) continue;

        double totalForceX = 0.0;
        double totalForceY = 0.0;

        // Spring forces to neighbors (elasticity)
        totalForceX += _calculateSpringForces(grid, x, y, gridWidth, gridHeight, true, elasticity);
        totalForceY += _calculateSpringForces(grid, x, y, gridWidth, gridHeight, false, elasticity);

        // External forces
        totalForceX += forceX * 30;
        totalForceY += forceY * 30;

        // Gravity
        totalForceY += gravity * 20;

        // Surface tension (smoothing force)
        if (surfaceTension > 0) {
          final smoothingForce = _calculateSmoothingForce(grid, x, y, gridWidth, gridHeight, surfaceTension);
          totalForceX += smoothingForce.x;
          totalForceY += smoothingForce.y;
        }

        // Turbulence (random forces)
        if (turbulence > 0) {
          final turbulentForce = _calculateTurbulenceForce(x, y, time, turbulence);
          totalForceX += turbulentForce.x;
          totalForceY += turbulentForce.y;
        }

        // Wave propagation force
        if (waveSpeed > 0) {
          final waveForce = _calculateWaveForce(x, y, gridWidth, gridHeight, time, waveSpeed);
          totalForceX += waveForce.x;
          totalForceY += waveForce.y;
        }

        // Limit force magnitude
        final forceMagnitude = sqrt(totalForceX * totalForceX + totalForceY * totalForceY);
        if (forceMagnitude > maxForce) {
          totalForceX = (totalForceX / forceMagnitude) * maxForce;
          totalForceY = (totalForceY / forceMagnitude) * maxForce;
        }

        // Apply forces using Verlet integration
        final acceleration = 1.0 / point.mass;

        // Apply viscosity (internal friction)
        point.velocityX *= (1.0 - viscosity * timeStep);
        point.velocityY *= (1.0 - viscosity * timeStep);

        // Update velocity
        point.velocityX += totalForceX * acceleration * timeStep;
        point.velocityY += totalForceY * acceleration * timeStep;

        // Apply damping
        point.velocityX *= (1.0 - damping * timeStep);
        point.velocityY *= (1.0 - damping * timeStep);

        // Update position
        point.currentX += point.velocityX * timeStep;
        point.currentY += point.velocityY * timeStep;
      }
    }
  }

  /// Set attachment points that remain fixed
  void _setAttachmentPoints(List<List<_JelloPoint>> grid, int gridWidth, int gridHeight, double attachmentStrength) {
    if (attachmentStrength <= 0) return;

    // Fix border points and some interior points based on attachment strength
    for (int y = 0; y < gridHeight; y++) {
      for (int x = 0; x < gridWidth; x++) {
        final isBorder = (x == 0 || x == gridWidth - 1 || y == 0 || y == gridHeight - 1);
        final isInteriorAttachment = _hash(x * 73 + y * 37) < attachmentStrength * 0.3;

        if (isBorder && attachmentStrength > 0.3) {
          grid[y][x].isFixed = true;
        } else if (isInteriorAttachment) {
          grid[y][x].isFixed = true;
        }
      }
    }
  }

  /// Calculate spring forces to neighboring points
  double _calculateSpringForces(
      List<List<_JelloPoint>> grid, int x, int y, int gridWidth, int gridHeight, bool isX, double elasticity) {
    final point = grid[y][x];
    double totalForce = 0.0;

    // Check all 8 neighbors
    for (int dy = -1; dy <= 1; dy++) {
      for (int dx = -1; dx <= 1; dx++) {
        if (dx == 0 && dy == 0) continue;

        final nx = x + dx;
        final ny = y + dy;

        if (nx >= 0 && nx < gridWidth && ny >= 0 && ny < gridHeight) {
          final neighbor = grid[ny][nx];

          // Calculate rest distance
          final restDistX = neighbor.restX - point.restX;
          final restDistY = neighbor.restY - point.restY;
          final restDistance = sqrt(restDistX * restDistX + restDistY * restDistY);

          if (restDistance > 0) {
            // Calculate current distance
            final currentDistX = neighbor.currentX - point.currentX;
            final currentDistY = neighbor.currentY - point.currentY;
            final currentDistance = sqrt(currentDistX * currentDistX + currentDistY * currentDistY);

            // Spring force proportional to displacement
            final displacement = currentDistance - restDistance;
            final springForce = displacement * elasticity * 10;

            // Apply force in direction of neighbor
            final forceDirection = isX ? (currentDistX / currentDistance) : (currentDistY / currentDistance);
            totalForce += springForce * forceDirection;
          }
        }
      }
    }

    return totalForce;
  }

  /// Calculate smoothing force for surface tension
  Point<double> _calculateSmoothingForce(
      List<List<_JelloPoint>> grid, int x, int y, int gridWidth, int gridHeight, double surfaceTension) {
    final point = grid[y][x];
    double avgX = 0.0;
    double avgY = 0.0;
    int count = 0;

    // Average position of neighbors
    for (int dy = -1; dy <= 1; dy++) {
      for (int dx = -1; dx <= 1; dx++) {
        if (dx == 0 && dy == 0) continue;

        final nx = x + dx;
        final ny = y + dy;

        if (nx >= 0 && nx < gridWidth && ny >= 0 && ny < gridHeight) {
          final neighbor = grid[ny][nx];
          avgX += neighbor.currentX;
          avgY += neighbor.currentY;
          count++;
        }
      }
    }

    if (count > 0) {
      avgX /= count;
      avgY /= count;

      // Force toward average position (smoothing)
      final forceX = (avgX - point.currentX) * surfaceTension * 5;
      final forceY = (avgY - point.currentY) * surfaceTension * 5;

      return Point(forceX, forceY);
    }

    return const Point(0.0, 0.0);
  }

  /// Calculate turbulence force for natural motion
  Point<double> _calculateTurbulenceForce(int x, int y, double time, double turbulence) {
    final noiseX = sin(time * 3 + x * 0.1 + y * 0.07) * cos(time * 2 + x * 0.05);
    final noiseY = cos(time * 3.7 + y * 0.1 + x * 0.08) * sin(time * 1.8 + y * 0.06);

    return Point(noiseX * turbulence * 8, noiseY * turbulence * 8);
  }

  /// Calculate wave propagation force
  Point<double> _calculateWaveForce(int x, int y, int gridWidth, int gridHeight, double time, double waveSpeed) {
    final centerX = gridWidth / 2;
    final centerY = gridHeight / 2;

    final distance = sqrt(pow(x - centerX, 2) + pow(y - centerY, 2));
    final wavePhase = distance * 0.5 - time * waveSpeed * 10;

    final waveAmplitude = sin(wavePhase) * exp(-distance * 0.1) * 3;

    // Wave propagates outward from center
    final dirX = x - centerX;
    final dirY = y - centerY;
    final dirLength = sqrt(dirX * dirX + dirY * dirY);

    if (dirLength > 0) {
      return Point((dirX / dirLength) * waveAmplitude, (dirY / dirLength) * waveAmplitude);
    }

    return const Point(0.0, 0.0);
  }

  /// Map pixel position through deformed jello grid
  Point<double> _mapThroughJelloGrid(int x, int y, List<List<_JelloPoint>> grid, int gridWidth, int gridHeight,
      int gridSize, int imgWidth, int imgHeight, double intensity) {
    // Find grid cell
    final gridX = (x / gridSize).clamp(0.0, gridWidth - 2);
    final gridY = (y / gridSize).clamp(0.0, gridHeight - 2);

    final gx0 = gridX.floor();
    final gy0 = gridY.floor();
    final gx1 = (gx0 + 1).clamp(0, gridWidth - 1);
    final gy1 = (gy0 + 1).clamp(0, gridHeight - 1);

    // Interpolation weights
    final wx = gridX - gx0;
    final wy = gridY - gy0;

    // Get grid points
    final p00 = grid[gy0][gx0];
    final p10 = grid[gy0][gx1];
    final p01 = grid[gy1][gx0];
    final p11 = grid[gy1][gx1];

    // Bilinear interpolation of deformed positions
    final deformedX = p00.currentX * (1 - wx) * (1 - wy) +
        p10.currentX * wx * (1 - wy) +
        p01.currentX * (1 - wx) * wy +
        p11.currentX * wx * wy;

    final deformedY = p00.currentY * (1 - wx) * (1 - wy) +
        p10.currentY * wx * (1 - wy) +
        p01.currentY * (1 - wx) * wy +
        p11.currentY * wx * wy;

    // Calculate rest position for this pixel
    final restX =
        p00.restX * (1 - wx) * (1 - wy) + p10.restX * wx * (1 - wy) + p01.restX * (1 - wx) * wy + p11.restX * wx * wy;

    final restY =
        p00.restY * (1 - wx) * (1 - wy) + p10.restY * wx * (1 - wy) + p01.restY * (1 - wx) * wy + p11.restY * wx * wy;

    // Apply deformation with intensity
    final offsetX = (deformedX - restX) * intensity;
    final offsetY = (deformedY - restY) * intensity;

    // Return source position (reverse mapping)
    return Point(x - offsetX, y - offsetY);
  }

  /// Sample pixel with bounds checking and interpolation
  int _samplePixel(Uint32List pixels, int width, int height, double x, double y) {
    if (x < 0 || x >= width - 1 || y < 0 || y >= height - 1) {
      return 0; // Transparent for out-of-bounds
    }

    // Bilinear interpolation
    final x0 = x.floor();
    final y0 = y.floor();
    final x1 = x0 + 1;
    final y1 = y0 + 1;

    final wx = x - x0;
    final wy = y - y0;

    final p00 = pixels[y0 * width + x0];
    final p10 = pixels[y0 * width + x1];
    final p01 = pixels[y1 * width + x0];
    final p11 = pixels[y1 * width + x1];

    return _interpolatePixels(p00, p10, p01, p11, wx, wy);
  }

  /// Bilinear interpolation of pixel colors
  int _interpolatePixels(int p00, int p10, int p01, int p11, double wx, double wy) {
    final a =
        _interpolateChannel((p00 >> 24) & 0xFF, (p10 >> 24) & 0xFF, (p01 >> 24) & 0xFF, (p11 >> 24) & 0xFF, wx, wy);
    final r =
        _interpolateChannel((p00 >> 16) & 0xFF, (p10 >> 16) & 0xFF, (p01 >> 16) & 0xFF, (p11 >> 16) & 0xFF, wx, wy);
    final g = _interpolateChannel((p00 >> 8) & 0xFF, (p10 >> 8) & 0xFF, (p01 >> 8) & 0xFF, (p11 >> 8) & 0xFF, wx, wy);
    final b = _interpolateChannel(p00 & 0xFF, p10 & 0xFF, p01 & 0xFF, p11 & 0xFF, wx, wy);

    return (a << 24) | (r << 16) | (g << 8) | b;
  }

  /// Interpolate single color channel
  int _interpolateChannel(int c00, int c10, int c01, int c11, double wx, double wy) {
    final top = c00 * (1 - wx) + c10 * wx;
    final bottom = c01 * (1 - wx) + c11 * wx;
    return (top * (1 - wy) + bottom * wy).round().clamp(0, 255);
  }

  /// Simple hash function
  double _hash(int input) {
    var h = input;
    h = ((h >> 16) ^ h) * 0x45d9f3b;
    h = ((h >> 16) ^ h) * 0x45d9f3b;
    h = (h >> 16) ^ h;
    return (h & 0xFFFFFF) / 0xFFFFFF;
  }
}

/// Represents a point in the jello simulation grid
class _JelloPoint {
  double restX, restY; // Rest/original position
  double currentX, currentY; // Current position
  double velocityX, velocityY; // Current velocity
  double mass; // Mass for physics simulation
  bool isFixed; // Whether this point is anchored

  _JelloPoint({
    required this.restX,
    required this.restY,
    required this.currentX,
    required this.currentY,
    required this.velocityX,
    required this.velocityY,
    required this.mass,
    required this.isFixed,
  });
}
