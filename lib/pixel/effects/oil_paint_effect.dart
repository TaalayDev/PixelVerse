part of 'effects.dart';

/// Effect that simulates an oil painting style with textured brush strokes
class OilPaintEffect extends Effect {
  OilPaintEffect([Map<String, dynamic>? parameters])
      : super(
          EffectType.oilPaint,
          parameters ??
              const {
                'brushSize': 0.5, // Size of brush strokes
                'detail': 0.6, // Amount of detail preserved
                'textureAmount': 0.7, // Intensity of brush texture
                'colorBlending': 0.5, // How much colors mix
                'strokeDirection': 0.5, // Direction of brush strokes (0-1 maps to 0-360°)
              },
        );

  @override
  Map<String, dynamic> getDefaultParameters() {
    return {
      'brushSize': 0.5, // Size of brush strokes (0-1)
      'detail': 0.6, // Amount of detail preserved (0-1)
      'textureAmount': 0.7, // Intensity of brush texture (0-1)
      'colorBlending': 0.5, // How much colors mix (0-1)
      'strokeDirection': 0.5, // Direction of brush strokes (0-1 maps to 0-360°)
    };
  }

  @override
  Uint32List apply(Uint32List pixels, int width, int height) {
    // Get parameters
    final brushSizeFactor = parameters['brushSize'] as double;
    final detailLevel = parameters['detail'] as double;
    final textureAmount = parameters['textureAmount'] as double;
    final colorBlending = parameters['colorBlending'] as double;
    final strokeDirection = parameters['strokeDirection'] as double;

    // Calculate brush size (1-5 pixels, scaled to image size)
    final maxDimension = max(width, height);
    final brushSize = (1 + brushSizeFactor * 4 * maxDimension / 100.0).round().clamp(1, 5);

    // Create result buffer
    final source = Uint32List.fromList(pixels);
    final result = Uint32List(pixels.length);

    // Calculate stroke angle in radians
    final angle = strokeDirection * 2 * pi;
    final sinAngle = sin(angle);
    final cosAngle = cos(angle);

    // Step 1: Regional color averaging with edge preservation
    _regionalColorAveraging(source, result, width, height, brushSize, detailLevel);

    // Step 2: Apply brush stroke texture
    _applyBrushTexture(result, width, height, textureAmount, brushSize, sinAngle, cosAngle);

    // Step 3: Edge enhancement to define color regions
    _enhanceEdges(result, width, height);

    // Step 4: Color blending for paint-like mixing
    _blendColors(result, width, height, colorBlending);

    return result;
  }

  void _regionalColorAveraging(
    Uint32List source,
    Uint32List destination,
    int width,
    int height,
    int brushSize,
    double detailLevel,
  ) {
    // Using a modified mean-shift algorithm for regional color averaging
    final radiusSquared = brushSize * brushSize;
    final detailThreshold = (1.0 - detailLevel) * 100; // Higher detail level = lower threshold

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final centerIdx = y * width + x;
        final centerPixel = source[centerIdx];

        // Skip transparent pixels
        if (((centerPixel >> 24) & 0xFF) == 0) {
          destination[centerIdx] = 0;
          continue;
        }

        // Extract center pixel components
        final centerR = (centerPixel >> 16) & 0xFF;
        final centerG = (centerPixel >> 8) & 0xFF;
        final centerB = centerPixel & 0xFF;
        final centerA = (centerPixel >> 24) & 0xFF;

        int totalR = 0, totalG = 0, totalB = 0;
        int count = 0;

        // Sample region within brush radius
        for (int ky = -brushSize; ky <= brushSize; ky++) {
          for (int kx = -brushSize; kx <= brushSize; kx++) {
            // Skip pixels outside brush circle
            final distSquared = kx * kx + ky * ky;
            if (distSquared > radiusSquared) continue;

            final sampleX = x + kx;
            final sampleY = y + ky;

            // Skip out of bounds pixels
            if (sampleX < 0 || sampleX >= width || sampleY < 0 || sampleY >= height) continue;

            final sampleIdx = sampleY * width + sampleX;
            final samplePixel = source[sampleIdx];

            // Skip transparent pixels
            final sampleA = (samplePixel >> 24) & 0xFF;
            if (sampleA == 0) continue;

            final sampleR = (samplePixel >> 16) & 0xFF;
            final sampleG = (samplePixel >> 8) & 0xFF;
            final sampleB = samplePixel & 0xFF;

            // Calculate color difference for detail preservation
            final colorDiff = _calculateColorDistance(
              centerR,
              centerG,
              centerB,
              sampleR,
              sampleG,
              sampleB,
            );

            // Only include pixels that are similar enough (within threshold)
            if (colorDiff <= detailThreshold) {
              totalR += sampleR;
              totalG += sampleG;
              totalB += sampleB;
              count++;
            }
          }
        }

        // Calculate average color for this region
        if (count > 0) {
          final avgR = (totalR / count).round().clamp(0, 255);
          final avgG = (totalG / count).round().clamp(0, 255);
          final avgB = (totalB / count).round().clamp(0, 255);

          destination[centerIdx] = (centerA << 24) | (avgR << 16) | (avgG << 8) | avgB;
        } else {
          destination[centerIdx] = centerPixel;
        }
      }
    }
  }

  void _applyBrushTexture(
    Uint32List pixels,
    int width,
    int height,
    double textureAmount,
    int brushSize,
    double sinAngle,
    double cosAngle,
  ) {
    final temp = Uint32List.fromList(pixels);
    final random = Random(42); // Fixed seed for consistent texture

    final textureIntensity = textureAmount * 30; // Scale to reasonable range
    final strokeLength = brushSize * 2;

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final idx = y * width + x;
        final pixel = temp[idx];

        // Skip transparent pixels
        final a = (pixel >> 24) & 0xFF;
        if (a == 0) continue;

        // Extract color components
        final r = (pixel >> 16) & 0xFF;
        final g = (pixel >> 8) & 0xFF;
        final b = pixel & 0xFF;

        // Apply directional texture using value noise
        double noise = 0;

        // Sample along brush stroke direction
        for (int i = -strokeLength; i <= strokeLength; i++) {
          // Calculate position along brush stroke
          final noiseX = (x + i * cosAngle).round();
          final noiseY = (y + i * sinAngle).round();

          // Skip if out of bounds
          if (noiseX < 0 || noiseX >= width || noiseY < 0 || noiseY >= height) continue;

          // Add weighted noise contribution
          final weight = 1.0 - min(1.0, i.abs() / strokeLength);
          noise += (random.nextDouble() * 2 - 1) * weight;
        }

        // Normalize and apply intensity
        noise = (noise / (strokeLength * 2)) * textureIntensity;

        // Adjust color based on noise
        int newR = (r + noise).round().clamp(0, 255);
        int newG = (g + noise).round().clamp(0, 255);
        int newB = (b + noise).round().clamp(0, 255);

        // Store result
        pixels[idx] = (a << 24) | (newR << 16) | (newG << 8) | newB;
      }
    }
  }

  void _enhanceEdges(
    Uint32List pixels,
    int width,
    int height,
  ) {
    final temp = Uint32List.fromList(pixels);

    for (int y = 1; y < height - 1; y++) {
      for (int x = 1; x < width - 1; x++) {
        final centerIdx = y * width + x;
        final centerPixel = temp[centerIdx];

        // Skip transparent pixels
        final a = (centerPixel >> 24) & 0xFF;
        if (a == 0) continue;

        // Calculate gradient (simple Sobel-like operation)
        int gradientX = 0, gradientY = 0;

        // Sample neighboring pixels
        final leftIdx = y * width + (x - 1);
        final rightIdx = y * width + (x + 1);
        final topIdx = (y - 1) * width + x;
        final bottomIdx = (y + 1) * width + x;

        final leftPixel = temp[leftIdx];
        final rightPixel = temp[rightIdx];
        final topPixel = temp[topIdx];
        final bottomPixel = temp[bottomIdx];

        // Calculate intensity gradient (simplified)
        final int leftIntensity = _getIntensity(leftPixel);
        final int rightIntensity = _getIntensity(rightPixel);
        final int topIntensity = _getIntensity(topPixel);
        final int bottomIntensity = _getIntensity(bottomPixel);

        gradientX = rightIntensity - leftIntensity;
        gradientY = bottomIntensity - topIntensity;

        final gradientMagnitude = sqrt(gradientX * gradientX + gradientY * gradientY);

        // Apply edge enhancement proportional to gradient magnitude
        if (gradientMagnitude > 10) {
          // Threshold to only enhance strong edges
          final edgeFactor = min(1.0, gradientMagnitude / 50.0) * 0.6; // Scale factor

          final r = (centerPixel >> 16) & 0xFF;
          final g = (centerPixel >> 8) & 0xFF;
          final b = centerPixel & 0xFF;

          // Darken edges slightly to create definition
          final newR = (r * (1.0 - edgeFactor)).round().clamp(0, 255);
          final newG = (g * (1.0 - edgeFactor)).round().clamp(0, 255);
          final newB = (b * (1.0 - edgeFactor)).round().clamp(0, 255);

          pixels[centerIdx] = (a << 24) | (newR << 16) | (newG << 8) | newB;
        }
      }
    }
  }

  void _blendColors(
    Uint32List pixels,
    int width,
    int height,
    double blendAmount,
  ) {
    final temp = Uint32List.fromList(pixels);
    final blendRadius = (blendAmount * 2).round().clamp(1, 2);
    final blendIntensity = blendAmount * 0.5; // Scale down for subtlety

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final centerIdx = y * width + x;
        final centerPixel = temp[centerIdx];

        // Skip transparent pixels
        final a = (centerPixel >> 24) & 0xFF;
        if (a == 0) continue;

        // Extract center pixel components
        final centerR = (centerPixel >> 16) & 0xFF;
        final centerG = (centerPixel >> 8) & 0xFF;
        final centerB = centerPixel & 0xFF;

        int totalR = centerR, totalG = centerG, totalB = centerB;
        int count = 1;

        // Sample neighborhood for color blending
        for (int ky = -blendRadius; ky <= blendRadius; ky++) {
          for (int kx = -blendRadius; kx <= blendRadius; kx++) {
            // Skip center pixel
            if (kx == 0 && ky == 0) continue;

            final sampleX = x + kx;
            final sampleY = y + ky;

            // Skip out of bounds pixels
            if (sampleX < 0 || sampleX >= width || sampleY < 0 || sampleY >= height) continue;

            final sampleIdx = sampleY * width + sampleX;
            final samplePixel = temp[sampleIdx];

            // Skip transparent pixels
            final sampleA = (samplePixel >> 24) & 0xFF;
            if (sampleA == 0) continue;

            // Weight samples by distance (closer pixels have more influence)
            final distance = sqrt(kx * kx + ky * ky);
            final weight = 1.0 - min(1.0, distance / blendRadius);

            totalR += (((samplePixel >> 16) & 0xFF) * weight).round();
            totalG += (((samplePixel >> 8) & 0xFF) * weight).round();
            totalB += ((samplePixel & 0xFF) * weight).round();
            count += weight.round();
          }
        }

        // Calculate blended color
        final avgR = (totalR / count).round().clamp(0, 255);
        final avgG = (totalG / count).round().clamp(0, 255);
        final avgB = (totalB / count).round().clamp(0, 255);

        // Blend between original and averaged color
        final newR = _interpolate(centerR, avgR, blendIntensity);
        final newG = _interpolate(centerG, avgG, blendIntensity);
        final newB = _interpolate(centerB, avgB, blendIntensity);

        // Store result
        pixels[centerIdx] = (a << 24) | (newR << 16) | (newG << 8) | newB;
      }
    }
  }

  // Helper method to calculate color distance
  double _calculateColorDistance(int r1, int g1, int b1, int r2, int g2, int b2) {
    final diffR = r1 - r2;
    final diffG = g1 - g2;
    final diffB = b1 - b2;

    return sqrt(diffR * diffR + diffG * diffG + diffB * diffB);
  }

  // Helper method to get pixel intensity (brightness)
  int _getIntensity(int pixel) {
    final r = (pixel >> 16) & 0xFF;
    final g = (pixel >> 8) & 0xFF;
    final b = pixel & 0xFF;

    return ((0.299 * r) + (0.587 * g) + (0.114 * b)).round();
  }

  // Helper method for linear interpolation
  int _interpolate(int a, int b, double t) {
    return (a * (1 - t) + b * t).round().clamp(0, 255);
  }
}
