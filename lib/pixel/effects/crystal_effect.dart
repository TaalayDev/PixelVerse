part of 'effects.dart';

/// Effect that creates crystalline/gem-like surfaces with facets and refraction
class CrystalEffect extends Effect {
  CrystalEffect([Map<String, dynamic>? parameters])
      : super(
          EffectType.crystal,
          parameters ??
              const {
                'facets': 6, // Number of crystal faces (3-12)
                'refraction': 0.5, // Light bending effect (0-1)
                'clarity': 0.7, // Crystal transparency (0-1)
                'color': 0xFF88DDFF, // Crystal tint (light blue)
                'innerGlow': 0.3, // Internal light glow (0-1)
                'surfaceReflection': 0.6, // Surface shininess (0-1)
                'prismEffect': 0.4, // Rainbow dispersion (0-1)
              },
        );

  @override
  Map<String, dynamic> getDefaultParameters() {
    return {
      'facets': 6, // Number of crystal faces
      'refraction': 0.5, // Refraction intensity
      'clarity': 0.7, // Transparency level
      'color': 0xFF88DDFF, // Crystal base color
      'innerGlow': 0.3, // Internal glow
      'surfaceReflection': 0.6, // Surface reflections
      'prismEffect': 0.4, // Rainbow dispersion
    };
  }

  @override
  Map<String, dynamic> getMetadata() {
    return {
      'facets': {
        'label': 'Crystal Facets',
        'description': 'Number of crystal faces. More facets create more complex reflections.',
        'type': 'slider',
        'min': 3,
        'max': 12,
        'divisions': 9,
      },
      'refraction': {
        'label': 'Refraction',
        'description': 'Controls light bending through the crystal.',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
      'clarity': {
        'label': 'Crystal Clarity',
        'description': 'Controls how transparent the crystal appears.',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
      'color': {
        'label': 'Crystal Color',
        'description': 'Base tint color of the crystal.',
        'type': 'color',
      },
      'innerGlow': {
        'label': 'Inner Glow',
        'description': 'Internal light glow effect within the crystal.',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
      'surfaceReflection': {
        'label': 'Surface Reflection',
        'description': 'Shininess and reflectivity of crystal surfaces.',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
      'prismEffect': {
        'label': 'Prism Effect',
        'description': 'Rainbow light dispersion through the crystal.',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
    };
  }

  @override
  Uint32List apply(Uint32List pixels, int width, int height) {
    final facets = (parameters['facets'] as int).clamp(3, 12);
    final refraction = parameters['refraction'] as double;
    final clarity = parameters['clarity'] as double;
    final crystalColor = Color(parameters['color'] as int);
    final innerGlow = parameters['innerGlow'] as double;
    final surfaceReflection = parameters['surfaceReflection'] as double;
    final prismEffect = parameters['prismEffect'] as double;

    final result = Uint32List.fromList(pixels);
    final centerX = width / 2;
    final centerY = height / 2;
    final maxRadius = min(width, height) / 2;

    // Pre-calculate facet angles
    final facetAngles = <double>[];
    for (int i = 0; i < facets; i++) {
      facetAngles.add(i * 2 * pi / facets);
    }

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final pixelIndex = y * width + x;
        final originalPixel = pixels[pixelIndex];

        // Skip transparent pixels
        if (((originalPixel >> 24) & 0xFF) == 0) continue;

        // Calculate position relative to crystal center
        final dx = x - centerX;
        final dy = y - centerY;
        final distance = sqrt(dx * dx + dy * dy);
        final angle = atan2(dy, dx);

        // Only apply effect within reasonable bounds
        if (distance > maxRadius) continue;

        // Calculate which facet this pixel belongs to
        final facetIndex = _getFacetIndex(angle, facetAngles);
        final facetAngle = facetAngles[facetIndex];

        // Calculate crystal effects
        final refractionOffset = _calculateRefraction(dx, dy, distance, facetAngle, refraction, width, height);
        final glowIntensity = _calculateInnerGlow(distance, maxRadius, innerGlow);
        final reflectionIntensity = _calculateSurfaceReflection(dx, dy, facetAngle, surfaceReflection);
        final prismColor = _calculatePrismEffect(angle, distance, maxRadius, prismEffect);

        // Sample refracted pixel
        final refractedPixel = _sampleRefractedPixel(
          pixels,
          width,
          height,
          x + refractionOffset.x,
          y + refractionOffset.y,
          originalPixel,
        );

        // Apply crystal transformation
        final crystalPixel = _applyCrystalTransformation(
          refractedPixel,
          crystalColor,
          clarity,
          glowIntensity,
          reflectionIntensity,
          prismColor,
        );

        result[pixelIndex] = crystalPixel;
      }
    }

    return result;
  }

  int _getFacetIndex(double angle, List<double> facetAngles) {
    // Normalize angle to 0-2π
    var normalizedAngle = angle;
    while (normalizedAngle < 0) normalizedAngle += 2 * pi;
    while (normalizedAngle >= 2 * pi) normalizedAngle -= 2 * pi;

    // Find closest facet
    var closestIndex = 0;
    var minDifference = double.infinity;

    for (int i = 0; i < facetAngles.length; i++) {
      final difference = (normalizedAngle - facetAngles[i]).abs();
      if (difference < minDifference) {
        minDifference = difference;
        closestIndex = i;
      }
    }

    return closestIndex;
  }

  Point<double> _calculateRefraction(
      double dx, double dy, double distance, double facetAngle, double refraction, int width, int height) {
    if (refraction <= 0) return const Point(0, 0);

    // Calculate refraction based on facet normal
    final normalX = cos(facetAngle);
    final normalY = sin(facetAngle);

    // Simple refraction calculation
    final refractionStrength = refraction * 5; // Scale for visible effect
    final refractionX = normalX * refractionStrength * (distance / (width / 4));
    final refractionY = normalY * refractionStrength * (distance / (height / 4));

    return Point(refractionX, refractionY);
  }

  double _calculateInnerGlow(double distance, double maxRadius, double innerGlow) {
    if (innerGlow <= 0) return 0;

    // Glow is stronger towards the center and edges
    final normalizedDistance = distance / maxRadius;
    final glowIntensity = innerGlow * (sin(normalizedDistance * pi) * 0.5 + 0.5);

    return glowIntensity.clamp(0.0, 1.0);
  }

  double _calculateSurfaceReflection(double dx, double dy, double facetAngle, double surfaceReflection) {
    if (surfaceReflection <= 0) return 0;

    // Calculate angle between pixel direction and facet normal
    final pixelAngle = atan2(dy, dx);
    final angleDifference = (pixelAngle - facetAngle).abs();

    // Reflection is strongest when viewing angle is perpendicular to facet
    final reflectionStrength = surfaceReflection * sin(angleDifference * 2);

    return reflectionStrength.clamp(0.0, 1.0);
  }

  Color _calculatePrismEffect(double angle, double distance, double maxRadius, double prismEffect) {
    if (prismEffect <= 0) return Colors.transparent;

    // Create rainbow dispersion based on angle and distance
    final normalizedDistance = (distance / maxRadius).clamp(0.0, 1.0);
    final hue = (angle / (2 * pi) + normalizedDistance * 0.3) % 1.0;

    // Convert HSV to RGB for prism color
    final prismColor = HSVColor.fromAHSV(
      prismEffect * normalizedDistance,
      hue * 360,
      0.8,
      1.0,
    ).toColor();

    return prismColor;
  }

  int _sampleRefractedPixel(Uint32List pixels, int width, int height, double x, double y, int fallback) {
    final sampleX = x.round().clamp(0, width - 1);
    final sampleY = y.round().clamp(0, height - 1);
    final sampleIndex = sampleY * width + sampleX;

    if (sampleIndex >= 0 && sampleIndex < pixels.length) {
      return pixels[sampleIndex];
    }

    return fallback;
  }

  int _applyCrystalTransformation(
    int pixel,
    Color crystalColor,
    double clarity,
    double glowIntensity,
    double reflectionIntensity,
    Color prismColor,
  ) {
    // Extract original components
    final origA = (pixel >> 24) & 0xFF;
    final origR = (pixel >> 16) & 0xFF;
    final origG = (pixel >> 8) & 0xFF;
    final origB = pixel & 0xFF;

    // Apply clarity (transparency effect)
    final clarityFactor = clarity;
    var newR = (origR * clarityFactor).round();
    var newG = (origG * clarityFactor).round();
    var newB = (origB * clarityFactor).round();

    // Blend with crystal color
    final crystalBlend = 0.3;
    newR = (newR * (1 - crystalBlend) + crystalColor.red * crystalBlend).round();
    newG = (newG * (1 - crystalBlend) + crystalColor.green * crystalBlend).round();
    newB = (newB * (1 - crystalBlend) + crystalColor.blue * crystalBlend).round();

    // Add inner glow
    if (glowIntensity > 0) {
      final glowBoost = (glowIntensity * 100).round();
      newR = (newR + glowBoost).clamp(0, 255);
      newG = (newG + glowBoost).clamp(0, 255);
      newB = (newB + glowBoost).clamp(0, 255);
    }

    // Add surface reflection (brighten)
    if (reflectionIntensity > 0) {
      final reflectionBoost = (reflectionIntensity * 150).round();
      newR = (newR + reflectionBoost).clamp(0, 255);
      newG = (newG + reflectionBoost).clamp(0, 255);
      newB = (newB + reflectionBoost).clamp(0, 255);
    }

    // Add prism effect
    if (prismColor.alpha > 0) {
      final prismBlend = prismColor.alpha / 255.0;
      newR = (newR * (1 - prismBlend) + prismColor.red * prismBlend).round();
      newG = (newG * (1 - prismBlend) + prismColor.green * prismBlend).round();
      newB = (newB * (1 - prismBlend) + prismColor.blue * prismBlend).round();
    }

    // Ensure values are in valid range
    newR = newR.clamp(0, 255);
    newG = newG.clamp(0, 255);
    newB = newB.clamp(0, 255);

    return (origA << 24) | (newR << 16) | (newG << 8) | newB;
  }
}
