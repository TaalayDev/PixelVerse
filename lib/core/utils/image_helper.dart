import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

class ImageHelper {
  static Future<ui.Image> createImageFromPixels(
    Uint32List pixels,
    int width,
    int height,
  ) async {
    final Completer<ui.Image> completer = Completer();
    ui.decodeImageFromPixels(
      convertToBytes(pixels),
      width,
      height,
      ui.PixelFormat.rgba8888,
      (ui.Image img) {
        completer.complete(img);
      },
    );
    return completer.future;
  }

  static Future<ui.Image> createImageFrom(
    Uint8List pixels,
    int width,
    int height,
  ) async {
    final Completer<ui.Image> completer = Completer();
    ui.decodeImageFromPixels(
      pixels,
      width,
      height,
      ui.PixelFormat.rgba8888,
      (ui.Image img) {
        completer.complete(img);
      },
    );
    return completer.future;
  }

  static Uint8List convertToBytes(Uint32List pixels) {
    final fixedChannels = fixColorChannels(pixels);
    return Uint8List.view(fixedChannels.buffer);
  }

  static Uint32List fixColorChannels(Uint32List pixels) {
    for (int i = 0; i < pixels.length; i++) {
      int pixel = pixels[i];

      // Extract the color channels
      int a = (pixel >> 24) & 0xFF;
      int r = (pixel >> 16) & 0xFF;
      int g = (pixel >> 8) & 0xFF;
      int b = (pixel) & 0xFF;

      // Reassemble with swapped channels (if needed)
      pixels[i] = (a << 24) | (b << 16) | (g << 8) | r;
    }
    return pixels;
  }
}
