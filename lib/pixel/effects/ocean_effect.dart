part of 'effects.dart';

/// Effect that generates a dynamic ocean scene with procedural waves.
class OceanEffect extends Effect {
  OceanEffect([Map<String, dynamic>? parameters])
      : super(
          EffectType.ocean,
          parameters ??
              const {
                'waveFrequency': 0.5, // How close the waves are (0-1)
                'waveAmplitude': 0.5, // How high the waves are (0-1)
                'foamIntensity': 0.6, // Amount of foam on wave crests (0-1)
                'colorScheme': 0, // 0=tropical, 1=deep_sea, 2=sunset, 3=stormy
                'sunPosition': 0.5, // Horizontal position of the sun (0-1)
                'sunGlare': 0.7, // Intensity of the sun's reflection (0-1)
                'skyGradient': true, // Add sky gradient background
                'horizonLevel': 0.5, // Where the horizon is (0-1, from top)
                'randomSeed': 42, // Seed for consistent generation
                'time': 0.0, // Time parameter for animation (0-100)
              },
        );

  @override
  Map<String, dynamic> getDefaultParameters() {
    return {
      'waveFrequency': 0.5,
      'waveAmplitude': 0.5,
      'foamIntensity': 0.6,
      'colorScheme': 0,
      'sunPosition': 0.5,
      'sunGlare': 0.7,
      'skyGradient': true,
      'horizonLevel': 0.5,
      'randomSeed': 42,
      'time': 0.0,
    };
  }

  @override
  Map<String, dynamic> getMetadata() {
    return {
      'waveFrequency': {
        'label': 'Wave Frequency',
        'description': 'The density and scale of the waves.',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
      'waveAmplitude': {
        'label': 'Wave Amplitude',
        'description': 'The height and intensity of the waves.',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
      'foamIntensity': {
        'label': 'Foam Intensity',
        'description': 'The amount of foam on wave crests.',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
      'colorScheme': {
        'label': 'Color Scheme',
        'description': 'Color palette for the ocean and sky.',
        'type': 'select',
        'options': {0: 'Tropical', 1: 'Deep Sea', 2: 'Sunset', 3: 'Stormy'},
      },
      'sunPosition': {
        'label': 'Sun Position',
        'description': 'The horizontal position of the sun for reflections.',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
      'sunGlare': {
        'label': 'Sun Glare',
        'description': 'The brightness of the sun\'s reflection.',
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
      'horizonLevel': {
        'label': 'Horizon Level',
        'description': 'The vertical position of the horizon.',
        'type': 'slider',
        'min': 0.2,
        'max': 0.8,
        'divisions': 60,
      },
      'randomSeed': {
        'label': 'Random Seed',
        'description': 'Changes the wave patterns.',
        'type': 'slider',
        'min': 1,
        'max': 100,
        'divisions': 99,
      },
      'time': {
        'label': 'Time (Animation)',
        'description': 'Animates the waves over time.',
        'type': 'slider',
        'min': 0.0,
        'max': 100.0,
        'divisions': 1000,
      },
    };
  }

  @override
  Uint32List apply(Uint32List pixels, int width, int height) {
    // Extract parameters
    final waveFrequency = parameters['waveFrequency'] as double;
    final waveAmplitude = parameters['waveAmplitude'] as double;
    final foamIntensity = parameters['foamIntensity'] as double;
    final colorScheme = parameters['colorScheme'] as int;
    final sunPosition = parameters['sunPosition'] as double;
    final sunGlare = parameters['sunGlare'] as double;
    final skyGradient = parameters['skyGradient'] as bool;
    final horizonLevel = ((parameters['horizonLevel'] as double) * height).round();
    final randomSeed = parameters['randomSeed'] as int;
    final time = parameters['time'] as double;

    final result = Uint32List(pixels.length);
    final random = Random(randomSeed);
    final noise = _PerlinNoise(random);

    // Get color palette
    final colors = _getColorScheme(colorScheme);

    // Render the scene pixel by pixel
    _renderOceanScene(result, width, height, horizonLevel, skyGradient, colors, noise, waveFrequency, waveAmplitude,
        foamIntensity, sunPosition, sunGlare, time);

    return result;
  }

  /// Renders the entire ocean and sky scene.
  void _renderOceanScene(Uint32List pixels, int width, int height, int horizon, bool skyGradient, OceanColors colors,
      _PerlinNoise noise, double freq, double amp, double foam, double sunX, double glare, double time) {
    for (int y = 0; y < height; y++) {
      // Draw sky
      if (y < horizon) {
        final t = y / (horizon - 1);
        final skyColor = skyGradient ? Color.lerp(colors.skyTop, colors.skyBottom, t)! : colors.skyBottom;
        for (int x = 0; x < width; x++) {
          pixels[y * width + x] = skyColor.value;
        }
      }
      // Draw ocean
      else {
        for (int x = 0; x < width; x++) {
          // Perspective: waves are smaller and denser further away
          final perspective = (y - horizon) / (height - horizon);

          // Generate wave height using noise, incorporating time for animation
          final noiseVal = _fbm(noise, x / width * (5 + freq * 10), perspective * (2 + freq * 5) + time * 0.1, 4);
          final waveHeight = (noiseVal + 1) / 2; // Remap noise to 0-1

          // Base water color based on depth/perspective
          Color waterColor = Color.lerp(colors.waterFar, colors.waterNear, perspective)!;

          // Lighten crests and darken troughs
          final lightFactor = 0.5 + waveHeight * amp;
          waterColor = Color.lerp(Colors.black, waterColor, lightFactor.clamp(0.2, 1.0))!;

          // Add foam to wave crests
          final foamThreshold = 1.0 - (foam * 0.3);
          if (waveHeight > foamThreshold) {
            final foamAmount = (waveHeight - foamThreshold) / (1.0 - foamThreshold);
            waterColor = Color.lerp(waterColor, colors.foam, foamAmount)!;
          }

          // Add sun glare
          final sunDistance = (x / width - sunX).abs();
          if (sunDistance < 0.1) {
            final glareFactor = (1.0 - sunDistance / 0.1) * perspective * glare;
            if (waveHeight > 0.7) {
              waterColor = Color.lerp(waterColor, colors.sunGlare, (waveHeight - 0.7) * glareFactor * 3)!;
            }
          }

          pixels[y * width + x] = waterColor.value;
        }
      }
    }
  }

  /// Fractional Brownian Motion for realistic noise patterns.
  double _fbm(_PerlinNoise perlin, double x, double y, int octaves) {
    double total = 0.0;
    double frequency = 1.0;
    double amplitude = 1.0;
    double maxValue = 0.0;
    for (int i = 0; i < octaves; i++) {
      total += perlin.noise(x * frequency, y * frequency) * amplitude;
      maxValue += amplitude;
      amplitude *= 0.5; // Persistence
      frequency *= 2.0; // Lacunarity
    }
    return total / maxValue;
  }

  /// Defines color schemes for the ocean.
  OceanColors _getColorScheme(int scheme) {
    switch (scheme) {
      case 1: // Deep Sea
        return const OceanColors(
            skyTop: Color(0xFF607D8B),
            skyBottom: Color(0xFFB0BEC5),
            waterFar: Color(0xFF0D47A1),
            waterNear: Color(0xFF1976D2),
            foam: Color(0xFFE3F2FD),
            sunGlare: Color(0xFFFFFFFF));
      case 2: // Sunset
        return const OceanColors(
            skyTop: Color(0xFFF57C00),
            skyBottom: Color(0xFFFFE0B2),
            waterFar: Color(0xFF4A148C),
            waterNear: Color(0xFFE1306C),
            foam: Color(0xFFFCE4EC),
            sunGlare: Color(0xFFFFFDE7));
      case 3: // Stormy
        return const OceanColors(
            skyTop: Color(0xFF263238),
            skyBottom: Color(0xFF546E7A),
            waterFar: Color(0xFF37474F),
            waterNear: Color(0xFF455A64),
            foam: Color(0xFFCFD8DC),
            sunGlare: Color(0xFFB0BEC5));
      case 0: // Tropical
      default:
        return const OceanColors(
            skyTop: Color(0xFF00BFFF),
            skyBottom: Color(0xFFB2EBF2),
            waterFar: Color(0xFF00838F),
            waterNear: Color(0xFF00BCD4),
            foam: Color(0xFFFFFFFF),
            sunGlare: Color(0xFFFFFF00));
    }
  }
}

/// Holds the set of colors for an ocean scene.
class OceanColors {
  final Color skyTop, skyBottom, waterFar, waterNear, foam, sunGlare;
  const OceanColors({
    required this.skyTop,
    required this.skyBottom,
    required this.waterFar,
    required this.waterNear,
    required this.foam,
    required this.sunGlare,
  });
}

/// A 2D Perlin noise generator for realistic procedural patterns.
class _PerlinNoise {
  final List<int> _p = List<int>.filled(512, 0);

  _PerlinNoise(Random random) {
    final permutation = List<int>.generate(256, (i) => i)..shuffle(random);
    for (int i = 0; i < 256; i++) {
      _p[256 + i] = _p[i] = permutation[i];
    }
  }

  double _fade(double t) => t * t * t * (t * (t * 6 - 15) + 10);
  double _lerp(double t, double a, double b) => a + t * (b - a);
  double _grad(int hash, double x, double y) {
    final h = hash & 15;
    final u = h < 8 ? x : y;
    final v = h < 4 ? y : (h == 12 || h == 14 ? x : 0.0);
    return ((h & 1) == 0 ? u : -u) + ((h & 2) == 0 ? v : -v);
  }

  double noise(double x, double y) {
    final X = x.floor() & 255;
    final Y = y.floor() & 255;
    final xf = x - x.floor();
    final yf = y - y.floor();

    final u = _fade(xf);
    final v = _fade(yf);

    final p = _p;
    final A = p[X] + Y;
    final B = p[X + 1] + Y;

    final val = _lerp(v, _lerp(u, _grad(p[A], xf, yf), _grad(p[B], xf - 1, yf)),
        _lerp(u, _grad(p[A + 1], xf, yf - 1), _grad(p[B + 1], xf - 1, yf - 1)));
    return (val + 1) / 2 * 2 - 1;
  }
}
