part of 'effects.dart';

/// Effect that simulates a watercolor painting look
class WatercolorEffect extends Effect {
  WatercolorEffect([Map<String, dynamic>? parameters])
      : super(
          EffectType.watercolor,
          parameters ?? const {'intensity': 0.5, 'spread': 0.3, 'texture': 0.2},
        );

  @override
  Map<String, dynamic> getDefaultParameters() {
    return {
      'intensity': 0.5, // How strong the watercolor effect is (0-1)
      'spread': 0.3, // How much the colors spread/bleed (0-1)
      'texture': 0.2, // Amount of paper texture simulation (0-1)
    };
  }

  @override
  Map<String, dynamic> getMetadata() {
    return {
      'intensity': {
        'label': 'Intensity',
        'description': 'Controls how strong the watercolor effect is.',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
      'spread': {
        'label': 'Color Spread',
        'description': 'Controls how much colors bleed into each other.',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
      'texture': {
        'label': 'Paper Texture',
        'description': 'Controls the amount of paper texture simulation.',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
    };
  }

  @override
  Uint32List apply(Uint32List pixels, int width, int height) {
    // Get parameters
    final intensity = parameters['intensity'] as double;
    final spread = parameters['spread'] as double;
    final texture = parameters['texture'] as double;

    // Create result buffer
    final result = Uint32List(pixels.length);

    // First pass - apply a soft blur for the base watercolor effect
    _applyWatercolorBlur(pixels, result, width, height, spread);

    // Second pass - create color bleeding/diffusion
    _applyColorDiffusion(result, width, height, intensity);

    // Third pass - add subtle paper texture
    _applyPaperTexture(result, width, height, texture);

    return result;
  }

  void _applyWatercolorBlur(
    Uint32List source,
    Uint32List destination,
    int width,
    int height,
    double spread,
  ) {
    // Determine the radius based on spread (1-3 pixels)
    final radius = (spread * 3).round().clamp(1, 3);

    // For each pixel
    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        // Blur variables
        int r = 0, g = 0, b = 0, a = 0;
        int count = 0;

        // Sample the neighborhood with variable radius
        for (int ky = -radius; ky <= radius; ky++) {
          for (int kx = -radius; kx <= radius; kx++) {
            final int posX = x + kx;
            final int posY = y + ky;

            // Skip if outside bounds
            if (posX < 0 || posX >= width || posY < 0 || posY >= height) {
              continue;
            }

            // Weight closer pixels more (simple gaussian-like)
            final double weight = 1.0 - (sqrt(kx * kx + ky * ky) / (radius + 1));
            if (weight <= 0) continue;

            // Get the color at this position
            final int idx = posY * width + posX;
            final int pixel = source[idx];

            // Extract color components
            final int pixelA = (pixel >> 24) & 0xFF;
            if (pixelA == 0) continue; // Skip transparent pixels

            final int pixelR = (pixel >> 16) & 0xFF;
            final int pixelG = (pixel >> 8) & 0xFF;
            final int pixelB = pixel & 0xFF;

            // Add weighted components
            r += (pixelR * weight).round();
            g += (pixelG * weight).round();
            b += (pixelB * weight).round();
            a += (pixelA * weight).round();
            count += weight.round();
          }
        }

        // Average the components
        if (count > 0) {
          r = (r / count).round().clamp(0, 255);
          g = (g / count).round().clamp(0, 255);
          b = (b / count).round().clamp(0, 255);
          a = (a / count).round().clamp(0, 255);
        } else {
          // If no contribution, use the original pixel
          final int originalPixel = source[y * width + x];
          a = (originalPixel >> 24) & 0xFF;
          r = (originalPixel >> 16) & 0xFF;
          g = (originalPixel >> 8) & 0xFF;
          b = originalPixel & 0xFF;
        }

        // Put the resulting pixel in the destination
        destination[y * width + x] = (a << 24) | (r << 16) | (g << 8) | b;
      }
    }
  }

  void _applyColorDiffusion(
    Uint32List pixels,
    int width,
    int height,
    double intensity,
  ) {
    // Create a temporary buffer
    final temp = Uint32List.fromList(pixels);

    // Simple diffusion with edge preservation
    for (int y = 1; y < height - 1; y++) {
      for (int x = 1; x < width - 1; x++) {
        final int idx = y * width + x;
        final int pixel = pixels[idx];

        // Skip transparent pixels
        if (((pixel >> 24) & 0xFF) == 0) continue;

        // Find the neighboring pixels
        final int top = pixels[(y - 1) * width + x];
        final int bottom = pixels[(y + 1) * width + x];
        final int left = pixels[y * width + (x - 1)];
        final int right = pixels[y * width + (x + 1)];

        // Compute color differences
        final double diffThreshold = 40 * (1 - intensity); // Lower threshold means more diffusion

        // Extract color components for current pixel
        final int pixelA = (pixel >> 24) & 0xFF;
        final int pixelR = (pixel >> 16) & 0xFF;
        final int pixelG = (pixel >> 8) & 0xFF;
        final int pixelB = pixel & 0xFF;

        int newR = pixelR, newG = pixelG, newB = pixelB, newA = pixelA;
        int count = 1;

        // Only blend with similar colors (based on threshold)
        void considerPixel(int otherPixel) {
          final int otherA = (otherPixel >> 24) & 0xFF;
          if (otherA == 0) return; // Skip transparent

          final int otherR = (otherPixel >> 16) & 0xFF;
          final int otherG = (otherPixel >> 8) & 0xFF;
          final int otherB = otherPixel & 0xFF;

          // Calculate color difference (simple Euclidean distance)
          final double diff = sqrt(pow(pixelR - otherR, 2) + pow(pixelG - otherG, 2) + pow(pixelB - otherB, 2));

          // Only blend if the colors are similar enough
          if (diff < diffThreshold) {
            newR += otherR;
            newG += otherG;
            newB += otherB;
            newA += otherA;
            count++;
          }
        }

        // Consider the neighboring pixels
        considerPixel(top);
        considerPixel(bottom);
        considerPixel(left);
        considerPixel(right);

        // Average the components
        if (count > 1) {
          newR = (newR / count).round().clamp(0, 255);
          newG = (newG / count).round().clamp(0, 255);
          newB = (newB / count).round().clamp(0, 255);
          newA = (newA / count).round().clamp(0, 255);

          // Apply the diffusion intensity
          newR = (pixelR * (1 - intensity) + newR * intensity).round().clamp(0, 255);
          newG = (pixelG * (1 - intensity) + newG * intensity).round().clamp(0, 255);
          newB = (pixelB * (1 - intensity) + newB * intensity).round().clamp(0, 255);

          // Set the new color
          temp[idx] = (newA << 24) | (newR << 16) | (newG << 8) | newB;
        }
      }
    }

    // Copy the temp buffer back to the result
    for (int i = 0; i < pixels.length; i++) {
      pixels[i] = temp[i];
    }
  }

  void _applyPaperTexture(Uint32List pixels, int width, int height, double textureAmount) {
    if (textureAmount <= 0) return; // Skip if no texture

    // Use a random generator with a fixed seed for deterministic results
    final random = Random(42);

    // Apply a subtle noise pattern that simulates paper texture
    for (int i = 0; i < pixels.length; i++) {
      final int pixel = pixels[i];

      // Skip transparent pixels
      final int a = (pixel >> 24) & 0xFF;
      if (a == 0) continue;

      // Extract color components
      int r = (pixel >> 16) & 0xFF;
      int g = (pixel >> 8) & 0xFF;
      int b = pixel & 0xFF;

      // Calculate texture influence based on position
      // This creates a subtle paper-like pattern
      final int x = i % width;
      final int y = i ~/ width;

      // Simple noise pattern
      final double noise = random.nextDouble() * 2 - 1; // -1 to 1

      // Paper has a slight yellow/beige tint in watercolor paintings
      final double warmth = (x % 3 + y % 2) / 5 * textureAmount * 0.2;

      // Apply the texture effect
      final double textureFactor = textureAmount * 0.15; // Scale down for subtlety
      r = (r + noise * textureFactor * 10 + warmth * 5).round().clamp(0, 255);
      g = (g + noise * textureFactor * 8 + warmth * 3).round().clamp(0, 255);
      b = (b + noise * textureFactor * 6).round().clamp(0, 255);

      // Update the pixel
      pixels[i] = (a << 24) | (r << 16) | (g << 8) | b;
    }
  }
}
