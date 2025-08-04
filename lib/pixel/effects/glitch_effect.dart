part of 'effects.dart';

/// Effect that creates digital corruption/glitch artifacts
class GlitchEffect extends Effect {
  GlitchEffect([Map<String, dynamic>? parameters])
      : super(
          EffectType.glitch,
          parameters ??
              const {
                'intensity': 0.5, // How corrupted the image becomes (0-1)
                'blockSize': 0.3, // Size of glitched areas (0-1)
                'colorShift': 0.4, // RGB channel displacement (0-1)
                'randomSeed': 42, // For reproducible glitches
                'scanlines': 0.3, // Horizontal line distortion (0-1)
                'pixelation': 0.2, // Digital pixelation effect (0-1)
                'chromaShift': 0.5, // Color channel separation (0-1)
              },
        );

  @override
  Map<String, dynamic> getDefaultParameters() {
    return {
      'intensity': 0.5,
      'blockSize': 0.3,
      'colorShift': 0.4,
      'randomSeed': 42,
      'scanlines': 0.3,
      'pixelation': 0.2,
      'chromaShift': 0.5,
    };
  }

  @override
  Map<String, dynamic> getMetadata() {
    return {
      'intensity': {
        'label': 'Glitch Intensity',
        'description': 'Overall strength of the glitch effect.',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
      'blockSize': {
        'label': 'Block Size',
        'description': 'Size of corrupted pixel blocks.',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
      'colorShift': {
        'label': 'Color Shift',
        'description': 'RGB channel displacement amount.',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
      'randomSeed': {
        'label': 'Glitch Seed',
        'description': 'Changes the glitch pattern.',
        'type': 'slider',
        'min': 1,
        'max': 100,
        'divisions': 99,
      },
      'scanlines': {
        'label': 'Scanline Distortion',
        'description': 'Horizontal line corruption effect.',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
      'pixelation': {
        'label': 'Digital Pixelation',
        'description': 'Blocky digital corruption effect.',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
      'chromaShift': {
        'label': 'Chroma Shift',
        'description': 'Color channel separation effect.',
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
    final blockSize = parameters['blockSize'] as double;
    final colorShift = parameters['colorShift'] as double;
    final randomSeed = parameters['randomSeed'] as int;
    final scanlines = parameters['scanlines'] as double;
    final pixelation = parameters['pixelation'] as double;
    final chromaShift = parameters['chromaShift'] as double;

    if (intensity <= 0.0) return Uint32List.fromList(pixels);

    final result = Uint32List.fromList(pixels);
    final random = Random(randomSeed);

    // Apply pixel corruption blocks
    if (blockSize > 0.0) {
      _applyPixelCorruption(result, width, height, blockSize, intensity, random);
    }

    // Apply scanline distortion
    if (scanlines > 0.0) {
      _applyScanlineDistortion(result, width, height, scanlines, intensity, random);
    }

    // Apply color channel shift
    if (colorShift > 0.0) {
      _applyColorChannelShift(result, width, height, colorShift, intensity);
    }

    // Apply chroma shift (RGB separation)
    if (chromaShift > 0.0) {
      _applyChromaShift(pixels, result, width, height, chromaShift, intensity);
    }

    // Apply digital pixelation
    if (pixelation > 0.0) {
      _applyDigitalPixelation(result, width, height, pixelation, intensity, random);
    }

    return result;
  }

  void _applyPixelCorruption(
    Uint32List pixels,
    int width,
    int height,
    double blockSize,
    double intensity,
    Random random,
  ) {
    final maxBlockSize = (blockSize * min(width, height) * 0.2 + 2).round().clamp(2, 20);
    final corruptionChance = intensity * 0.3;

    for (int y = 0; y < height; y += random.nextInt(maxBlockSize) + 1) {
      for (int x = 0; x < width; x += random.nextInt(maxBlockSize) + 1) {
        if (random.nextDouble() < corruptionChance) {
          final blockWidth = random.nextInt(maxBlockSize) + 1;
          final blockHeight = random.nextInt(maxBlockSize) + 1;

          // Choose corruption type
          final corruptionType = random.nextInt(3);

          for (int by = 0; by < blockHeight && y + by < height; by++) {
            for (int bx = 0; bx < blockWidth && x + bx < width; bx++) {
              final index = (y + by) * width + (x + bx);

              switch (corruptionType) {
                case 0: // Random color
                  pixels[index] = _generateRandomPixel(random);
                  break;
                case 1: // Duplicate from random location
                  final sourceX = random.nextInt(width);
                  final sourceY = random.nextInt(height);
                  pixels[index] = pixels[sourceY * width + sourceX];
                  break;
                case 2: // Invert colors
                  pixels[index] = _invertPixel(pixels[index]);
                  break;
              }
            }
          }
        }
      }
    }
  }

  void _applyScanlineDistortion(
    Uint32List pixels,
    int width,
    int height,
    double scanlines,
    double intensity,
    Random random,
  ) {
    final distortionChance = scanlines * intensity * 0.5;

    for (int y = 0; y < height; y++) {
      if (random.nextDouble() < distortionChance) {
        final distortionType = random.nextInt(3);
        final lineStart = y * width;

        switch (distortionType) {
          case 0: // Shift line horizontally
            final shift = (random.nextDouble() * 2 - 1) * width * 0.1 * intensity;
            _shiftScanline(pixels, width, lineStart, shift.round());
            break;
          case 1: // Duplicate line
            if (y > 0) {
              final sourceLine = (y - 1) * width;
              for (int x = 0; x < width; x++) {
                pixels[lineStart + x] = pixels[sourceLine + x];
              }
            }
            break;
          case 2: // Add noise to line
            for (int x = 0; x < width; x++) {
              pixels[lineStart + x] = _addNoise(pixels[lineStart + x], intensity, random);
            }
            break;
        }
      }
    }
  }

  void _applyColorChannelShift(
    Uint32List pixels,
    int width,
    int height,
    double colorShift,
    double intensity,
  ) {
    final shiftAmount = (colorShift * intensity * 10).round().clamp(1, 10);
    final temp = Uint32List.fromList(pixels);

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final index = y * width + x;
        final pixel = temp[index];

        // Extract channels
        final a = (pixel >> 24) & 0xFF;
        var r = (pixel >> 16) & 0xFF;
        var g = (pixel >> 8) & 0xFF;
        var b = pixel & 0xFF;

        // Sample shifted red channel
        final redX = (x + shiftAmount).clamp(0, width - 1);
        final redPixel = temp[y * width + redX];
        r = (redPixel >> 16) & 0xFF;

        // Sample shifted blue channel
        final blueX = (x - shiftAmount).clamp(0, width - 1);
        final bluePixel = temp[y * width + blueX];
        b = bluePixel & 0xFF;

        pixels[index] = (a << 24) | (r << 16) | (g << 8) | b;
      }
    }
  }

  void _applyChromaShift(
    Uint32List sourcePixels,
    Uint32List resultPixels,
    int width,
    int height,
    double chromaShift,
    double intensity,
  ) {
    final shiftX = (chromaShift * intensity * 5).round();
    final shiftY = (chromaShift * intensity * 3).round();

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final index = y * width + x;
        final originalPixel = sourcePixels[index];

        // Get red channel from shifted position
        final redX = (x + shiftX).clamp(0, width - 1);
        final redY = (y + shiftY).clamp(0, height - 1);
        final redPixel = sourcePixels[redY * width + redX];
        final r = (redPixel >> 16) & 0xFF;

        // Get blue channel from opposite shift
        final blueX = (x - shiftX).clamp(0, width - 1);
        final blueY = (y - shiftY).clamp(0, height - 1);
        final bluePixel = sourcePixels[blueY * width + blueX];
        final b = bluePixel & 0xFF;

        // Keep original green and alpha
        final a = (originalPixel >> 24) & 0xFF;
        final g = (originalPixel >> 8) & 0xFF;

        resultPixels[index] = (a << 24) | (r << 16) | (g << 8) | b;
      }
    }
  }

  void _applyDigitalPixelation(
    Uint32List pixels,
    int width,
    int height,
    double pixelation,
    double intensity,
    Random random,
  ) {
    final pixelationChance = pixelation * intensity * 0.2;
    final pixelSize = (pixelation * 8 + 2).round();

    for (int y = 0; y < height; y += pixelSize) {
      for (int x = 0; x < width; x += pixelSize) {
        if (random.nextDouble() < pixelationChance) {
          // Sample color from block center
          final centerX = (x + pixelSize ~/ 2).clamp(0, width - 1);
          final centerY = (y + pixelSize ~/ 2).clamp(0, height - 1);
          final blockColor = pixels[centerY * width + centerX];

          // Fill block with sampled color
          for (int by = 0; by < pixelSize && y + by < height; by++) {
            for (int bx = 0; bx < pixelSize && x + bx < width; bx++) {
              pixels[(y + by) * width + (x + bx)] = blockColor;
            }
          }
        }
      }
    }
  }

  int _generateRandomPixel(Random random) {
    final r = random.nextInt(256);
    final g = random.nextInt(256);
    final b = random.nextInt(256);
    return (255 << 24) | (r << 16) | (g << 8) | b;
  }

  int _invertPixel(int pixel) {
    final a = (pixel >> 24) & 0xFF;
    final r = 255 - ((pixel >> 16) & 0xFF);
    final g = 255 - ((pixel >> 8) & 0xFF);
    final b = 255 - (pixel & 0xFF);
    return (a << 24) | (r << 16) | (g << 8) | b;
  }

  int _addNoise(int pixel, double intensity, Random random) {
    final a = (pixel >> 24) & 0xFF;
    final r = (pixel >> 16) & 0xFF;
    final g = (pixel >> 8) & 0xFF;
    final b = pixel & 0xFF;

    final noiseAmount = (intensity * 50).round();
    final newR = (r + (random.nextDouble() * 2 - 1) * noiseAmount).round().clamp(0, 255);
    final newG = (g + (random.nextDouble() * 2 - 1) * noiseAmount).round().clamp(0, 255);
    final newB = (b + (random.nextDouble() * 2 - 1) * noiseAmount).round().clamp(0, 255);

    return (a << 24) | (newR << 16) | (newG << 8) | newB;
  }

  void _shiftScanline(Uint32List pixels, int width, int lineStart, int shift) {
    if (shift == 0) return;

    final temp = List<int>.generate(width, (i) => pixels[lineStart + i]);

    for (int x = 0; x < width; x++) {
      final sourceX = (x - shift) % width;
      final adjustedSourceX = sourceX < 0 ? sourceX + width : sourceX;
      pixels[lineStart + x] = temp[adjustedSourceX];
    }
  }
}
