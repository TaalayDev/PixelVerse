part of 'effects.dart';

class StainedGlassEffect extends Effect {
  StainedGlassEffect([Map<String, dynamic>? parameters])
      : super(
          EffectType.stainedGlass,
          parameters ??
              const {
                'segmentSize': 0.5, // Size of glass pieces (0-1)
                'leadWidth': 0.3, // Black line thickness (0-1)
                'colorIntensity': 0.7, // Color saturation boost (0-2)
                'randomSeed': 42, // For consistent patterns
                'glassOpacity': 0.8, // Glass transparency (0-1)
                'leadColor': 0xFF000000, // Lead line color
                'variation': 0.5, // Segment shape variation (0-1)
              },
        );

  @override
  Map<String, dynamic> getDefaultParameters() {
    return {
      'segmentSize': 0.5,
      'leadWidth': 0.3,
      'colorIntensity': 0.7,
      'randomSeed': 42,
      'glassOpacity': 0.8,
      'leadColor': 0xFF000000,
      'variation': 0.5,
    };
  }

  @override
  Map<String, dynamic> getMetadata() {
    return {
      'segmentSize': {
        'label': 'Glass Segment Size',
        'description': 'Controls the size of individual glass pieces.',
        'type': 'slider',
        'min': 0.1,
        'max': 1.0,
        'divisions': 100,
      },
      'leadWidth': {
        'label': 'Lead Line Width',
        'description': 'Thickness of the dark lines between glass pieces.',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
      'colorIntensity': {
        'label': 'Color Intensity',
        'description': 'Boosts color saturation for vibrant stained glass look.',
        'type': 'slider',
        'min': 0.0,
        'max': 2.0,
        'divisions': 100,
      },
      'randomSeed': {
        'label': 'Pattern Seed',
        'description': 'Changes the random pattern of glass segments.',
        'type': 'slider',
        'min': 1,
        'max': 100,
        'divisions': 99,
      },
      'glassOpacity': {
        'label': 'Glass Opacity',
        'description': 'Transparency of the glass segments.',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
      'leadColor': {
        'label': 'Lead Line Color',
        'description': 'Color of the lines between glass segments.',
        'type': 'color',
      },
      'variation': {
        'label': 'Shape Variation',
        'description': 'How irregular the glass segment shapes are.',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
    };
  }

  @override
  Uint32List apply(Uint32List pixels, int width, int height) {
    final segmentSize = parameters['segmentSize'] as double;
    final leadWidth = parameters['leadWidth'] as double;
    final colorIntensity = parameters['colorIntensity'] as double;
    final randomSeed = parameters['randomSeed'] as int;
    final glassOpacity = parameters['glassOpacity'] as double;
    final leadColor = Color(parameters['leadColor'] as int);
    final variation = parameters['variation'] as double;

    final result = Uint32List.fromList(pixels);
    final random = Random(randomSeed);

    // Calculate segment grid size
    final baseSegmentSize = (segmentSize * min(width, height) * 0.2 + 5).round().clamp(5, min(width, height) ~/ 3);
    final leadPixelWidth = (leadWidth * 5 + 1).round().clamp(1, 5);

    // Create segment map
    final segmentMap = <Point<int>, Color>{};
    final leadMap = List.generate(height, (_) => List.filled(width, false));

    // Generate glass segments
    _generateGlassSegments(
      width,
      height,
      baseSegmentSize,
      variation,
      random,
      segmentMap,
      pixels,
      colorIntensity,
    );

    // Apply lead lines
    _generateLeadLines(width, height, baseSegmentSize, leadPixelWidth, leadMap);

    // Apply stained glass effect
    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final index = y * width + x;

        if (leadMap[y][x]) {
          // Apply lead line
          result[index] = _blendPixel(result[index], leadColor.value, 0.8);
        } else {
          // Apply glass segment effect
          final segmentKey = Point(x ~/ baseSegmentSize, y ~/ baseSegmentSize);
          final segmentColor = segmentMap[segmentKey];

          if (segmentColor != null) {
            result[index] = _applyGlassEffect(
              result[index],
              segmentColor.value,
              glassOpacity,
            );
          }
        }
      }
    }

    return result;
  }

  void _generateGlassSegments(
    int width,
    int height,
    int segmentSize,
    double variation,
    Random random,
    Map<Point<int>, Color> segmentMap,
    Uint32List pixels,
    double colorIntensity,
  ) {
    final segmentsX = (width / segmentSize).ceil();
    final segmentsY = (height / segmentSize).ceil();

    for (int sy = 0; sy < segmentsY; sy++) {
      for (int sx = 0; sx < segmentsX; sx++) {
        // Sample average color from this segment
        final segmentColor = _sampleSegmentColor(
          pixels,
          width,
          height,
          sx * segmentSize,
          sy * segmentSize,
          segmentSize,
          colorIntensity,
        );

        segmentMap[Point(sx, sy)] = segmentColor;
      }
    }
  }

  Color _sampleSegmentColor(
    Uint32List pixels,
    int width,
    int height,
    int startX,
    int startY,
    int segmentSize,
    double colorIntensity,
  ) {
    int totalR = 0, totalG = 0, totalB = 0, totalA = 0;
    int count = 0;

    for (int y = startY; y < startY + segmentSize && y < height; y++) {
      for (int x = startX; x < startX + segmentSize && x < width; x++) {
        final pixel = pixels[y * width + x];
        final a = (pixel >> 24) & 0xFF;
        if (a > 0) {
          totalA += a;
          totalR += (pixel >> 16) & 0xFF;
          totalG += (pixel >> 8) & 0xFF;
          totalB += pixel & 0xFF;
          count++;
        }
      }
    }

    if (count == 0) return Colors.transparent;

    var avgR = (totalR / count).round();
    var avgG = (totalG / count).round();
    var avgB = (totalB / count).round();
    final avgA = (totalA / count).round();

    // Apply color intensity boost
    if (colorIntensity > 1.0) {
      final hsv = HSVColor.fromColor(Color.fromARGB(avgA, avgR, avgG, avgB));
      final boostedColor = hsv
          .withSaturation(
            (hsv.saturation * colorIntensity).clamp(0.0, 1.0),
          )
          .toColor();

      avgR = boostedColor.red;
      avgG = boostedColor.green;
      avgB = boostedColor.blue;
    }

    return Color.fromARGB(avgA, avgR, avgG, avgB);
  }

  void _generateLeadLines(
    int width,
    int height,
    int segmentSize,
    int leadWidth,
    List<List<bool>> leadMap,
  ) {
    // Draw vertical lead lines
    for (int x = segmentSize; x < width; x += segmentSize) {
      for (int y = 0; y < height; y++) {
        for (int lx = x - leadWidth ~/ 2; lx <= x + leadWidth ~/ 2; lx++) {
          if (lx >= 0 && lx < width) {
            leadMap[y][lx] = true;
          }
        }
      }
    }

    // Draw horizontal lead lines
    for (int y = segmentSize; y < height; y += segmentSize) {
      for (int x = 0; x < width; x++) {
        for (int ly = y - leadWidth ~/ 2; ly <= y + leadWidth ~/ 2; ly++) {
          if (ly >= 0 && ly < height) {
            leadMap[ly][x] = true;
          }
        }
      }
    }
  }

  int _blendPixel(int basePixel, int overlayPixel, double opacity) {
    final baseA = (basePixel >> 24) & 0xFF;
    final baseR = (basePixel >> 16) & 0xFF;
    final baseG = (basePixel >> 8) & 0xFF;
    final baseB = basePixel & 0xFF;

    final overlayR = (overlayPixel >> 16) & 0xFF;
    final overlayG = (overlayPixel >> 8) & 0xFF;
    final overlayB = overlayPixel & 0xFF;

    final newR = (baseR * (1 - opacity) + overlayR * opacity).round();
    final newG = (baseG * (1 - opacity) + overlayG * opacity).round();
    final newB = (baseB * (1 - opacity) + overlayB * opacity).round();

    return (baseA << 24) | (newR << 16) | (newG << 8) | newB;
  }

  int _applyGlassEffect(int basePixel, int glassColor, double opacity) {
    return _blendPixel(basePixel, glassColor, opacity * 0.3);
  }
}
