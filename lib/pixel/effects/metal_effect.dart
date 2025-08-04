part of 'effects.dart';

/// Effect that creates metallic surfaces with reflections
class MetalEffect extends Effect {
  MetalEffect([Map<String, dynamic>? parameters])
      : super(
          EffectType.metal,
          parameters ??
              const {
                'metalType': 0, // 0=brushed, 1=polished, 2=rusty, 3=patina
                'reflectivity': 0.6, // Surface shininess (0-1)
                'scratchIntensity': 0.3, // Surface wear (0-1)
                'color': 0xFFC0C0C0, // Base metal color (silver)
                'roughness': 0.4, // Surface roughness (0-1)
                'oxidation': 0.2, // Rust/patina amount (0-1)
                'anisotropy': 0.5, // Directional reflection (0-1)
                'lightDirection': 0.25, // Light angle (0-1)
              },
        );

  @override
  Map<String, dynamic> getDefaultParameters() {
    return {
      'metalType': 0,
      'reflectivity': 0.6,
      'scratchIntensity': 0.3,
      'color': 0xFFC0C0C0,
      'roughness': 0.4,
      'oxidation': 0.2,
      'anisotropy': 0.5,
      'lightDirection': 0.25,
    };
  }

  @override
  Map<String, dynamic> getMetadata() {
    return {
      'metalType': {
        'label': 'Metal Type',
        'description': 'Type of metal surface finish.',
        'type': 'select',
        'options': {
          0: 'Brushed Metal',
          1: 'Polished Metal',
          2: 'Rusty Metal',
          3: 'Patina Metal',
        },
      },
      'reflectivity': {
        'label': 'Reflectivity',
        'description': 'How shiny and reflective the metal surface is.',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
      'scratchIntensity': {
        'label': 'Scratch Intensity',
        'description': 'Amount of surface scratches and wear.',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
      'color': {
        'label': 'Metal Color',
        'description': 'Base color of the metal.',
        'type': 'color',
      },
      'roughness': {
        'label': 'Surface Roughness',
        'description': 'Micro-surface texture roughness.',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
      'oxidation': {
        'label': 'Oxidation Level',
        'description': 'Amount of rust or patina on the surface.',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
      'anisotropy': {
        'label': 'Directional Reflection',
        'description': 'Directional light reflection (brushed metal effect).',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
      'lightDirection': {
        'label': 'Light Direction',
        'description': 'Direction of the primary light source.',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
    };
  }

  @override
  Uint32List apply(Uint32List pixels, int width, int height) {
    final metalType = parameters['metalType'] as int;
    final reflectivity = parameters['reflectivity'] as double;
    final scratchIntensity = parameters['scratchIntensity'] as double;
    final metalColor = Color(parameters['color'] as int);
    final roughness = parameters['roughness'] as double;
    final oxidation = parameters['oxidation'] as double;
    final anisotropy = parameters['anisotropy'] as double;
    final lightDirection = parameters['lightDirection'] as double;

    final result = Uint32List(pixels.length);
    final lightAngle = lightDirection * 2 * pi;
    final random = Random(42); // Fixed seed for consistent patterns

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final index = y * width + x;
        final originalPixel = pixels[index];

        // Skip transparent pixels
        if (((originalPixel >> 24) & 0xFF) == 0) {
          result[index] = 0;
          continue;
        }

        // Calculate base metal color
        var metalPixel = _calculateBaseMetalColor(originalPixel, metalColor, metalType);

        // Apply surface effects based on metal type
        switch (metalType) {
          case 0: // Brushed metal
            metalPixel = _applyBrushedEffect(metalPixel, x, y, anisotropy, scratchIntensity, random);
            break;
          case 1: // Polished metal
            metalPixel = _applyPolishedEffect(metalPixel, x, y, width, height, reflectivity, roughness);
            break;
          case 2: // Rusty metal
            metalPixel = _applyRustEffect(metalPixel, x, y, oxidation, random);
            break;
          case 3: // Patina metal
            metalPixel = _applyPatinaEffect(metalPixel, x, y, oxidation, random);
            break;
        }

        // Apply lighting
        metalPixel = _applyMetalLighting(metalPixel, x, y, width, height, lightAngle, reflectivity);

        result[index] = metalPixel;
      }
    }

    return result;
  }

  int _calculateBaseMetalColor(int originalPixel, Color metalColor, int metalType) {
    final origA = (originalPixel >> 24) & 0xFF;
    final origR = (originalPixel >> 16) & 0xFF;
    final origG = (originalPixel >> 8) & 0xFF;
    final origB = originalPixel & 0xFF;

    // Calculate luminance of original pixel
    final luminance = (0.299 * origR + 0.587 * origG + 0.114 * origB) / 255;

    // Blend with metal color based on luminance
    final metalR = (metalColor.red * luminance).round().clamp(0, 255);
    final metalG = (metalColor.green * luminance).round().clamp(0, 255);
    final metalB = (metalColor.blue * luminance).round().clamp(0, 255);

    return (origA << 24) | (metalR << 16) | (metalG << 8) | metalB;
  }

  int _applyBrushedEffect(int pixel, int x, int y, double anisotropy, double scratchIntensity, Random random) {
    final a = (pixel >> 24) & 0xFF;
    final r = (pixel >> 16) & 0xFF;
    final g = (pixel >> 8) & 0xFF;
    final b = pixel & 0xFF;

    // Create brushed texture pattern
    final brushPattern = sin(x * 0.3) * anisotropy;
    final scratchNoise = (random.nextDouble() * 2 - 1) * scratchIntensity * 20;

    final adjustment = (brushPattern * 15 + scratchNoise).round();

    final newR = (r + adjustment).clamp(0, 255);
    final newG = (g + adjustment).clamp(0, 255);
    final newB = (b + adjustment).clamp(0, 255);

    return (a << 24) | (newR << 16) | (newG << 8) | newB;
  }

  int _applyPolishedEffect(int pixel, int x, int y, int width, int height, double reflectivity, double roughness) {
    final a = (pixel >> 24) & 0xFF;
    final r = (pixel >> 16) & 0xFF;
    final g = (pixel >> 8) & 0xFF;
    final b = pixel & 0xFF;

    // Create polished reflection pattern
    final centerX = width / 2;
    final centerY = height / 2;
    final distance = sqrt(pow(x - centerX, 2) + pow(y - centerY, 2));
    final maxDistance = sqrt(centerX * centerX + centerY * centerY);

    final reflectionFactor = (1.0 - distance / maxDistance) * reflectivity;
    final roughnessNoise = (sin(x * 0.1) * cos(y * 0.1)) * roughness * 10;

    final brightness = (reflectionFactor * 50 + roughnessNoise).round();

    final newR = (r + brightness).clamp(0, 255);
    final newG = (g + brightness).clamp(0, 255);
    final newB = (b + brightness).clamp(0, 255);

    return (a << 24) | (newR << 16) | (newG << 8) | newB;
  }

  int _applyRustEffect(int pixel, int x, int y, double oxidation, Random random) {
    final a = (pixel >> 24) & 0xFF;
    final r = (pixel >> 16) & 0xFF;
    final g = (pixel >> 8) & 0xFF;
    final b = pixel & 0xFF;

    // Create rust patterns
    final rustNoise = sin(x * 0.1) * cos(y * 0.1) * sin(x * 0.05 + y * 0.05);
    final rustIntensity = (rustNoise + 1) * 0.5 * oxidation;

    // Rust colors (orange-brown)
    final rustR = (200 * rustIntensity).round();
    final rustG = (100 * rustIntensity).round();
    final rustB = (50 * rustIntensity).round();

    final newR = ((r * (1 - rustIntensity) + rustR * rustIntensity)).round().clamp(0, 255);
    final newG = ((g * (1 - rustIntensity) + rustG * rustIntensity)).round().clamp(0, 255);
    final newB = ((b * (1 - rustIntensity) + rustB * rustIntensity)).round().clamp(0, 255);

    return (a << 24) | (newR << 16) | (newG << 8) | newB;
  }

  int _applyPatinaEffect(int pixel, int x, int y, double oxidation, Random random) {
    final a = (pixel >> 24) & 0xFF;
    final r = (pixel >> 16) & 0xFF;
    final g = (pixel >> 8) & 0xFF;
    final b = pixel & 0xFF;

    // Create patina patterns (green-blue oxidation)
    final patinaNoise = sin(x * 0.08) * cos(y * 0.12) * sin((x + y) * 0.03);
    final patinaIntensity = (patinaNoise + 1) * 0.5 * oxidation;

    // Patina colors (green-blue)
    final patinaR = (100 * patinaIntensity).round();
    final patinaG = (150 * patinaIntensity).round();
    final patinaB = (120 * patinaIntensity).round();

    final newR = ((r * (1 - patinaIntensity) + patinaR * patinaIntensity)).round().clamp(0, 255);
    final newG = ((g * (1 - patinaIntensity) + patinaG * patinaIntensity)).round().clamp(0, 255);
    final newB = ((b * (1 - patinaIntensity) + patinaB * patinaIntensity)).round().clamp(0, 255);

    return (a << 24) | (newR << 16) | (newG << 8) | newB;
  }

  int _applyMetalLighting(int pixel, int x, int y, int width, int height, double lightAngle, double reflectivity) {
    final a = (pixel >> 24) & 0xFF;
    final r = (pixel >> 16) & 0xFF;
    final g = (pixel >> 8) & 0xFF;
    final b = pixel & 0xFF;

    // Calculate lighting based on position and light direction
    final centerX = width / 2;
    final centerY = height / 2;
    final pixelAngle = atan2(y - centerY, x - centerX);

    final lightDifference = (pixelAngle - lightAngle).abs();
    final lightFactor = cos(lightDifference) * reflectivity;

    final lightAdjustment = (lightFactor * 40).round();

    final newR = (r + lightAdjustment).clamp(0, 255);
    final newG = (g + lightAdjustment).clamp(0, 255);
    final newB = (b + lightAdjustment).clamp(0, 255);

    return (a << 24) | (newR << 16) | (newG << 8) | newB;
  }
}
