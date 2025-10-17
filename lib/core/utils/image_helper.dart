import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:image/image.dart' as img;

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

  static Future<img.Image> convertFlutterUiToImage(
    int width,
    int height,
    ui.Image uiImage,
  ) async {
    final uiBytes = await uiImage.toByteData();

    final image = img.Image.fromBytes(
      width: width,
      height: height,
      bytes: uiBytes!.buffer,
      numChannels: 4,
    );

    return image;
  }

  static Future<ui.Image> convertImageToFlutterUi(
    img.Image image,
  ) async {
    final uiImage = await createImageFrom(
      image.getBytes(),
      image.width,
      image.height,
    );
    return uiImage;
  }

  static Uint8List convertImageToBytes(
    img.Image image,
  ) {
    final bytes = Uint8List.fromList(img.encodePng(image));
    return bytes;
  }

  static Future<ui.Image> scaleUiImageSync(
    ui.Image image,
    double scale,
  ) async {
    final int newWidth = (image.width * scale).toInt();
    final int newHeight = (image.height * scale).toInt();

    final img.Image dartImage = await convertFlutterUiToImage(
      image.width,
      image.height,
      image,
    );

    final img.Image resizedImage = img.copyResize(
      dartImage,
      width: newWidth,
      height: newHeight,
      interpolation: img.Interpolation.nearest,
    );

    final ui.Image scaledUiImage = await convertImageToFlutterUi(
      resizedImage,
    );

    return scaledUiImage;
  }
}
