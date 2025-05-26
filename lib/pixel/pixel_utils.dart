import 'dart:typed_data';

import '../data/models/layer.dart';

class PixelUtils {
  const PixelUtils._();

  static Uint32List mergeLayersPixels({
    required int width,
    required int height,
    required List<Layer> layers,
  }) {
    final pixels = Uint32List(width * height);
    final layersPixels = layers.reversed
        .where((l) => l.isVisible)
        .map(
          (l) => l.processedPixels,
        )
        .toList();

    for (final processedPixels in layersPixels) {
      for (int i = 0; i < pixels.length; i++) {
        pixels[i] = pixels[i] == 0 ? processedPixels[i] : pixels[i];
      }
    }
    return pixels;
  }
}
