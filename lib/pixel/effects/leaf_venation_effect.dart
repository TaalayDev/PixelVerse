part of 'effects.dart';

/// Effect that creates realistic leaf venation patterns
class LeafVenationEffect extends Effect {
  LeafVenationEffect([Map<String, dynamic>? parameters])
      : super(
          EffectType.leafVenation,
          parameters ??
              const {
                'venationType': 0, // 0=Branched, 1=Parallel, 2=Palmate, 3=Pinnate, 4=Reticulate
                'veinDensity': 0.5, // Density of vein network (0-1)
                'veinThickness': 0.3, // Thickness of veins (0-1)
                'branchingAngle': 0.5, // Angle of vein branches (0-1)
                'leafColor': 0xFF4CAF50, // Base leaf color (green)
                'veinColor': 0xFF2E7D32, // Vein color (dark green)
                'transparency': 0.7, // Vein transparency (0-1)
                'complexity': 0.6, // Pattern complexity (0-1)
                'asymmetry': 0.2, // Natural asymmetry (0-1)
                'fadingEdges': 0.5, // Vein fading at edges (0-1)
                'randomSeed': 42, // Seed for pattern generation
              },
        );

  @override
  Map<String, dynamic> getDefaultParameters() {
    return {
      'venationType': 0,
      'veinDensity': 0.5,
      'veinThickness': 0.3,
      'branchingAngle': 0.5,
      'leafColor': 0xFF4CAF50,
      'veinColor': 0xFF2E7D32,
      'transparency': 0.7,
      'complexity': 0.6,
      'asymmetry': 0.2,
      'fadingEdges': 0.5,
      'randomSeed': 42,
    };
  }

  @override
  Map<String, dynamic> getMetadata() {
    return {
      'venationType': {
        'label': 'Venation Type',
        'description': 'Type of leaf vein pattern.',
        'type': 'select',
        'options': {
          0: 'Branched (Dicot)',
          1: 'Parallel (Monocot)',
          2: 'Palmate (Hand-like)',
          3: 'Pinnate (Feather-like)',
          4: 'Reticulate (Net-like)',
        },
      },
      'veinDensity': {
        'label': 'Vein Density',
        'description': 'Controls how dense the vein network is.',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
      'veinThickness': {
        'label': 'Vein Thickness',
        'description': 'Controls the thickness of the vein lines.',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
      'branchingAngle': {
        'label': 'Branching Angle',
        'description': 'Controls the angle at which veins branch.',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
      'leafColor': {
        'label': 'Leaf Color',
        'description': 'Base color of the leaf tissue.',
        'type': 'color',
      },
      'veinColor': {
        'label': 'Vein Color',
        'description': 'Color of the leaf veins.',
        'type': 'color',
      },
      'transparency': {
        'label': 'Vein Transparency',
        'description': 'How transparent the veins appear.',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
      'complexity': {
        'label': 'Pattern Complexity',
        'description': 'How complex and detailed the vein pattern is.',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
      'asymmetry': {
        'label': 'Natural Asymmetry',
        'description': 'Adds natural irregularity to the pattern.',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
      'fadingEdges': {
        'label': 'Edge Fading',
        'description': 'How much veins fade near the edges.',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
      'randomSeed': {
        'label': 'Pattern Seed',
        'description': 'Changes the random venation pattern.',
        'type': 'slider',
        'min': 1,
        'max': 100,
        'divisions': 99,
      },
    };
  }

  @override
  Uint32List apply(Uint32List pixels, int width, int height) {
    final venationType = parameters['venationType'] as int;
    final veinDensity = parameters['veinDensity'] as double;
    final veinThickness = parameters['veinThickness'] as double;
    final branchingAngle = parameters['branchingAngle'] as double;
    final leafColor = Color(parameters['leafColor'] as int);
    final veinColor = Color(parameters['veinColor'] as int);
    final transparency = parameters['transparency'] as double;
    final complexity = parameters['complexity'] as double;
    final asymmetry = parameters['asymmetry'] as double;
    final fadingEdges = parameters['fadingEdges'] as double;
    final randomSeed = parameters['randomSeed'] as int;

    final result = Uint32List(pixels.length);
    final random = Random(randomSeed);

    // Generate vein network based on type
    final veinNetwork = _generateVeinNetwork(
      width,
      height,
      venationType,
      veinDensity,
      complexity,
      branchingAngle,
      asymmetry,
      random,
    );

    // Apply venation pattern
    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final index = y * width + x;
        final originalPixel = pixels[index];

        // Skip transparent pixels
        if (((originalPixel >> 24) & 0xFF) == 0) {
          result[index] = 0;
          continue;
        }

        // Calculate distance to nearest vein
        final veinInfo = _getVeinInfo(x, y, veinNetwork, veinThickness, width, height);

        // Apply edge fading
        final edgeFade = _calculateEdgeFade(x, y, width, height, fadingEdges);

        // Determine final color
        final finalColor = _calculatePixelColor(
          originalPixel,
          leafColor,
          veinColor,
          veinInfo,
          transparency,
          edgeFade,
        );

        result[index] = finalColor;
      }
    }

    return result;
  }

  /// Generate vein network based on venation type
  List<_Vein> _generateVeinNetwork(
    int width,
    int height,
    int venationType,
    double density,
    double complexity,
    double branchingAngle,
    double asymmetry,
    Random random,
  ) {
    final veins = <_Vein>[];

    switch (venationType) {
      case 0: // Branched (Dicot)
        _generateBranchedVeins(veins, width, height, density, complexity, branchingAngle, asymmetry, random);
        break;
      case 1: // Parallel (Monocot)
        _generateParallelVeins(veins, width, height, density, complexity, asymmetry, random);
        break;
      case 2: // Palmate (Hand-like)
        _generatePalmateVeins(veins, width, height, density, complexity, branchingAngle, asymmetry, random);
        break;
      case 3: // Pinnate (Feather-like)
        _generatePinnateVeins(veins, width, height, density, complexity, branchingAngle, asymmetry, random);
        break;
      case 4: // Reticulate (Net-like)
        _generateReticulateVeins(veins, width, height, density, complexity, branchingAngle, asymmetry, random);
        break;
    }

    return veins;
  }

  /// Generate branched venation (typical dicot pattern)
  void _generateBranchedVeins(
    List<_Vein> veins,
    int width,
    int height,
    double density,
    double complexity,
    double branchingAngle,
    double asymmetry,
    Random random,
  ) {
    // Main central vein (midrib)
    final midrib = _Vein(
      start: Point(width * 0.5, height * 0.95),
      end: Point(width * 0.5 + random.nextDouble() * asymmetry * 20 - 10, height * 0.05),
      thickness: 0.8,
      order: 1,
    );
    veins.add(midrib);

    // Secondary veins branching from midrib
    final numSecondary = (density * complexity * 8 + 3).round();
    for (int i = 0; i < numSecondary; i++) {
      final t = (i + 1) / (numSecondary + 1);
      final branchPoint = Point(
        midrib.start.x + (midrib.end.x - midrib.start.x) * t,
        midrib.start.y + (midrib.end.y - midrib.start.y) * t,
      );

      // Left branch
      final leftAngle = pi * 0.25 + (branchingAngle - 0.5) * pi * 0.3;
      final leftEnd = _calculateBranchEnd(branchPoint, leftAngle, width * 0.3, asymmetry, random);
      veins.add(_Vein(
        start: branchPoint,
        end: leftEnd,
        thickness: 0.6,
        order: 2,
      ));

      // Right branch
      final rightAngle = -pi * 0.25 - (branchingAngle - 0.5) * pi * 0.3;
      final rightEnd = _calculateBranchEnd(branchPoint, rightAngle, width * 0.3, asymmetry, random);
      veins.add(_Vein(
        start: branchPoint,
        end: rightEnd,
        thickness: 0.6,
        order: 2,
      ));

      // Tertiary veins if complexity is high enough
      if (complexity > 0.5) {
        _generateTertiaryVeins(veins, branchPoint, leftEnd, rightEnd, density, asymmetry, random);
      }
    }
  }

  /// Generate parallel venation (typical monocot pattern)
  void _generateParallelVeins(
    List<_Vein> veins,
    int width,
    int height,
    double density,
    double complexity,
    double asymmetry,
    Random random,
  ) {
    final numVeins = (density * 12 + 3).round();

    for (int i = 0; i < numVeins; i++) {
      final x = width * (i + 1) / (numVeins + 1);
      final curvature = (random.nextDouble() - 0.5) * asymmetry * 40;

      final start = Point(x + random.nextDouble() * asymmetry * 10 - 5, height * 0.95);
      final end = Point(x + curvature, height * 0.05);

      veins.add(_Vein(
        start: start,
        end: end,
        thickness: i == numVeins ~/ 2 ? 0.8 : 0.4, // Central vein is thicker
        order: i == numVeins ~/ 2 ? 1 : 2,
      ));

      // Add connecting veins for reticulation
      if (complexity > 0.6 && i < numVeins - 1) {
        final connectY = height * (0.2 + random.nextDouble() * 0.6);
        final connectStart = Point(x, connectY);
        final connectEnd =
            Point(width * (i + 2) / (numVeins + 1), connectY + random.nextDouble() * asymmetry * 20 - 10);

        veins.add(_Vein(
          start: connectStart,
          end: connectEnd,
          thickness: 0.2,
          order: 3,
        ));
      }
    }
  }

  /// Generate palmate venation (hand-like pattern)
  void _generatePalmateVeins(
    List<_Vein> veins,
    int width,
    int height,
    double density,
    double complexity,
    double branchingAngle,
    double asymmetry,
    Random random,
  ) {
    final origin = Point(width * 0.5, height * 0.9);
    final numMainVeins = (density * 3 + 3).round().clamp(3, 7);

    for (int i = 0; i < numMainVeins; i++) {
      final angleRange = pi * 0.6; // 108 degrees spread
      final angle = -angleRange / 2 + (i * angleRange / (numMainVeins - 1));
      final adjustedAngle = angle + (random.nextDouble() - 0.5) * asymmetry * 0.3;

      final length = height * 0.7 + random.nextDouble() * asymmetry * 50;
      final end = Point(
        origin.x + cos(adjustedAngle) * length,
        origin.y + sin(adjustedAngle) * length,
      );

      veins.add(_Vein(
        start: origin,
        end: end,
        thickness: i == numMainVeins ~/ 2 ? 0.8 : 0.6,
        order: 1,
      ));

      // Secondary branches
      if (complexity > 0.4) {
        _generateSecondaryBranches(veins, origin, end, branchingAngle, asymmetry, random);
      }
    }
  }

  /// Generate pinnate venation (feather-like pattern)
  void _generatePinnateVeins(
    List<_Vein> veins,
    int width,
    int height,
    double density,
    double complexity,
    double branchingAngle,
    double asymmetry,
    Random random,
  ) {
    // Central rachis
    final rachis = _Vein(
      start: Point(width * 0.5, height * 0.95),
      end: Point(width * 0.5, height * 0.05),
      thickness: 0.8,
      order: 1,
    );
    veins.add(rachis);

    // Paired leaflets
    final numPairs = (density * complexity * 6 + 2).round();
    for (int i = 0; i < numPairs; i++) {
      final t = (i + 1) / (numPairs + 1);
      final attachPoint = Point(
        rachis.start.x,
        rachis.start.y + (rachis.end.y - rachis.start.y) * t,
      );

      final leafletLength = width * 0.25 * (1 - t * 0.3); // Smaller towards tip
      final baseAngle = pi * 0.4 + (branchingAngle - 0.5) * pi * 0.2;

      // Left leaflet
      final leftAngle = baseAngle + (random.nextDouble() - 0.5) * asymmetry * 0.3;
      final leftEnd = Point(
        attachPoint.x - cos(leftAngle) * leafletLength,
        attachPoint.y - sin(leftAngle) * leafletLength,
      );
      veins.add(_Vein(
        start: attachPoint,
        end: leftEnd,
        thickness: 0.5,
        order: 2,
      ));

      // Right leaflet
      final rightAngle = -baseAngle + (random.nextDouble() - 0.5) * asymmetry * 0.3;
      final rightEnd = Point(
        attachPoint.x - cos(rightAngle) * leafletLength,
        attachPoint.y - sin(rightAngle) * leafletLength,
      );
      veins.add(_Vein(
        start: attachPoint,
        end: rightEnd,
        thickness: 0.5,
        order: 2,
      ));
    }
  }

  /// Generate reticulate venation (net-like pattern)
  void _generateReticulateVeins(
    List<_Vein> veins,
    int width,
    int height,
    double density,
    double complexity,
    double branchingAngle,
    double asymmetry,
    Random random,
  ) {
    // Start with branched pattern
    _generateBranchedVeins(veins, width, height, density, complexity, branchingAngle, asymmetry, random);

    // Add cross-connections for net effect
    if (complexity > 0.3) {
      final numConnections = (density * complexity * 20).round();

      for (int i = 0; i < numConnections; i++) {
        final startX = random.nextDouble() * width;
        final startY = random.nextDouble() * height;
        final angle = random.nextDouble() * 2 * pi;
        final length = 30 + random.nextDouble() * 50;

        final endX = startX + cos(angle) * length;
        final endY = startY + sin(angle) * length;

        if (endX >= 0 && endX < width && endY >= 0 && endY < height) {
          veins.add(_Vein(
            start: Point(startX, startY),
            end: Point(endX, endY),
            thickness: 0.2,
            order: 3,
          ));
        }
      }
    }
  }

  /// Generate tertiary veins for added complexity
  void _generateTertiaryVeins(
    List<_Vein> veins,
    Point<double> origin,
    Point<double> leftEnd,
    Point<double> rightEnd,
    double density,
    double asymmetry,
    Random random,
  ) {
    final numTertiary = (density * 3).round();

    for (int i = 0; i < numTertiary; i++) {
      final t = (i + 1) / (numTertiary + 1);

      // Left side tertiary
      final leftBranchPoint = Point(
        origin.x + (leftEnd.x - origin.x) * t,
        origin.y + (leftEnd.y - origin.y) * t,
      );
      final leftTertiaryEnd = Point(
        leftBranchPoint.x + (random.nextDouble() - 0.5) * 40,
        leftBranchPoint.y + (random.nextDouble() - 0.5) * 40,
      );
      veins.add(_Vein(
        start: leftBranchPoint,
        end: leftTertiaryEnd,
        thickness: 0.3,
        order: 3,
      ));

      // Right side tertiary
      final rightBranchPoint = Point(
        origin.x + (rightEnd.x - origin.x) * t,
        origin.y + (rightEnd.y - origin.y) * t,
      );
      final rightTertiaryEnd = Point(
        rightBranchPoint.x + (random.nextDouble() - 0.5) * 40,
        rightBranchPoint.y + (random.nextDouble() - 0.5) * 40,
      );
      veins.add(_Vein(
        start: rightBranchPoint,
        end: rightTertiaryEnd,
        thickness: 0.3,
        order: 3,
      ));
    }
  }

  /// Generate secondary branches for palmate veins
  void _generateSecondaryBranches(
    List<_Vein> veins,
    Point<double> start,
    Point<double> end,
    double branchingAngle,
    double asymmetry,
    Random random,
  ) {
    final numBranches = 2 + random.nextInt(3);

    for (int i = 0; i < numBranches; i++) {
      final t = 0.3 + (i * 0.4 / numBranches);
      final branchPoint = Point(
        start.x + (end.x - start.x) * t,
        start.y + (end.y - start.y) * t,
      );

      final mainAngle = atan2(end.y - start.y, end.x - start.x);
      final branchAngle = mainAngle + (random.nextDouble() - 0.5) * pi * 0.5;
      final branchLength = 40 + random.nextDouble() * 30;

      final branchEnd = Point(
        branchPoint.x + cos(branchAngle) * branchLength,
        branchPoint.y + sin(branchAngle) * branchLength,
      );

      veins.add(_Vein(
        start: branchPoint,
        end: branchEnd,
        thickness: 0.4,
        order: 2,
      ));
    }
  }

  /// Calculate branch end point with natural variation
  Point<double> _calculateBranchEnd(
    Point<double> start,
    double angle,
    double length,
    double asymmetry,
    Random random,
  ) {
    final adjustedAngle = angle + (random.nextDouble() - 0.5) * asymmetry * 0.5;
    final adjustedLength = length * (0.8 + random.nextDouble() * 0.4);

    return Point(
      start.x + cos(adjustedAngle) * adjustedLength,
      start.y + sin(adjustedAngle) * adjustedLength,
    );
  }

  /// Get vein information for a pixel position
  _VeinInfo _getVeinInfo(int x, int y, List<_Vein> veins, double thickness, int width, int height) {
    double minDistance = double.infinity;
    double veinThickness = 0.0;
    int veinOrder = 0;

    for (final vein in veins) {
      final distance = _distanceToLineSegment(Point(x.toDouble(), y.toDouble()), vein.start, vein.end);
      final adjustedThickness = thickness * vein.thickness * min(width, height) * 0.02;

      if (distance <= adjustedThickness && distance < minDistance) {
        minDistance = distance;
        veinThickness = adjustedThickness;
        veinOrder = vein.order;
      }
    }

    final isVein = minDistance != double.infinity;
    final intensity = isVein ? 1.0 - (minDistance / veinThickness) : 0.0;

    return _VeinInfo(
      isVein: isVein,
      intensity: intensity.clamp(0.0, 1.0),
      order: veinOrder,
    );
  }

  /// Calculate distance from point to line segment
  double _distanceToLineSegment(Point<double> point, Point<double> lineStart, Point<double> lineEnd) {
    final A = point.x - lineStart.x;
    final B = point.y - lineStart.y;
    final C = lineEnd.x - lineStart.x;
    final D = lineEnd.y - lineStart.y;

    final dot = A * C + B * D;
    final lenSq = C * C + D * D;

    if (lenSq == 0) {
      return sqrt(A * A + B * B);
    }

    final param = dot / lenSq;

    final double xx, yy;
    if (param < 0) {
      xx = lineStart.x;
      yy = lineStart.y;
    } else if (param > 1) {
      xx = lineEnd.x;
      yy = lineEnd.y;
    } else {
      xx = lineStart.x + param * C;
      yy = lineStart.y + param * D;
    }

    final dx = point.x - xx;
    final dy = point.y - yy;
    return sqrt(dx * dx + dy * dy);
  }

  /// Calculate edge fading factor
  double _calculateEdgeFade(int x, int y, int width, int height, double fadingAmount) {
    if (fadingAmount <= 0) return 1.0;

    final distanceFromEdge = min(
      min(x, width - x),
      min(y, height - y),
    ).toDouble();

    final fadeDistance = min(width, height) * 0.1 * fadingAmount;

    if (distanceFromEdge >= fadeDistance) return 1.0;

    return (distanceFromEdge / fadeDistance).clamp(0.0, 1.0);
  }

  /// Calculate final pixel color based on vein information
  int _calculatePixelColor(
    int originalPixel,
    Color leafColor,
    Color veinColor,
    _VeinInfo veinInfo,
    double transparency,
    double edgeFade,
  ) {
    final originalAlpha = (originalPixel >> 24) & 0xFF;

    if (veinInfo.isVein && veinInfo.intensity > 0.1) {
      // This pixel is part of a vein
      final blendFactor = veinInfo.intensity * transparency * edgeFade;

      final blendedColor = Color.lerp(leafColor, veinColor, blendFactor)!;
      return (originalAlpha << 24) | (blendedColor.value & 0x00FFFFFF);
    } else {
      // This pixel is leaf tissue
      return (originalAlpha << 24) | (leafColor.value & 0x00FFFFFF);
    }
  }
}

/// Represents a single vein in the leaf
class _Vein {
  final Point<double> start;
  final Point<double> end;
  final double thickness;
  final int order; // 1=primary, 2=secondary, 3=tertiary

  _Vein({
    required this.start,
    required this.end,
    required this.thickness,
    required this.order,
  });
}

/// Information about vein at a specific pixel
class _VeinInfo {
  final bool isVein;
  final double intensity; // 0-1, how strong the vein is at this point
  final int order;

  _VeinInfo({
    required this.isVein,
    required this.intensity,
    required this.order,
  });
}
