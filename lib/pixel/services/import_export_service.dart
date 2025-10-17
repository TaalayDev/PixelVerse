import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:share_plus/share_plus.dart';
import 'package:uuid/uuid.dart';

import '../../core.dart';
import '../../data.dart';
import '../../gifencoder/gifencoder.dart' as gifencoder;

const _kGifFps = 10;

class ImportExportService {
  Future<void> exportProjectAsJson({
    required BuildContext context,
    required Project project,
  }) async {
    final json = project.toJson();
    final jsonString = jsonEncode(json);
    await FileUtils(context).save('${project.name}.pxv', jsonString);
  }

  Future<void> exportImage({
    required BuildContext context,
    required Project project,
    required List<Layer> layers,
    required bool withBackground,
    double? exportWidth,
    double? exportHeight,
  }) async {
    final pixels = PixelUtils.mergeLayersPixels(
      width: project.width,
      height: project.height,
      layers: layers,
    );

    if (withBackground) {
      for (int i = 0; i < pixels.length; i++) {
        if (pixels[i] == 0) {
          pixels[i] = Colors.white.value;
        }
      }
    }

    await FileUtils(context).save32Bit(
      pixels,
      project.width,
      project.height,
      exportWidth: exportWidth,
      exportHeight: exportHeight,
    );
  }

  Future<void> exportAnimation({
    required BuildContext context,
    required Project project,
    required List<AnimationFrame> frames,
    required bool withBackground,
    double? exportWidth,
    double? exportHeight,
  }) async {
    // If you want transparency, we must *not* flatten on any background.
    // So ensure withBackground==false here for a transparent export.
    final wantTransparent = !withBackground;

    // Prepare a GifBuffer (expects RGBA bytes per frame)
    final gb = gifencoder.GifBuffer(project.width, project.height);

    for (final frame in frames) {
      // Your existing compositor:
      final pixelsAARRGGBB = PixelUtils.mergeLayersPixels(
        width: project.width,
        height: project.height,
        layers: frame.layers,
      );

      Uint8List rgba;
      if (wantTransparent) {
        // Clean alpha for GIF
        rgba = PixelUtils.aarrggbbToRgbaForGif(pixelsAARRGGBB);
      } else {
        // If you want a solid matte export (no transparency), pre-flatten onto
        // a matte color in your compositor OR force A=255 here.
        final forced = Uint32List.fromList(pixelsAARRGGBB);
        for (int i = 0; i < forced.length; i++) {
          forced[i] = (0xFF << 24) | (forced[i] & 0x00FFFFFF); // A=255
        }
        rgba = PixelUtils.aarrggbbToRgbaForGif(forced);
      }

      // Feed raw RGBA to gifencoder
      gb.add(rgba);
    }

    // Build animated GIF bytes
    final data = Uint8List.fromList(gb.build(_kGifFps));

    await FileUtils(context).saveImage(data, '${project.name}.gif');
  }

  Future<void> shareProject({
    required BuildContext context,
    required Project project,
    required List<Layer> layers,
  }) async {
    final pixels = PixelUtils.mergeLayersPixels(
      width: project.width,
      height: project.height,
      layers: layers,
    );

    await Share.shareXFiles([
      XFile.fromData(
        ImageHelper.convertToBytes(pixels),
        name: '${project.name}.png',
        mimeType: 'image/png',
      ),
    ]);
  }

  Future<Uint8List> importImageBytes({
    required BuildContext context,
    required int width,
    required int height,
  }) async {
    final img.Image? pickedImage = await FileUtils(context).pickImageFile();
    if (pickedImage == null) return Uint8List(0);

    // Resize to canvas size if needed
    img.Image resized = pickedImage;
    if (pickedImage.width != width || pickedImage.height != height) {
      resized = img.copyResize(
        pickedImage,
        width: width,
        height: height,
        interpolation: img.Interpolation.cubic,
      );
    }

    return Uint8List.fromList(img.encodePng(resized));
  }

  Future<Layer?> importImageAsLayer({
    required BuildContext context,
    required int width,
    required int height,
    String? layerName,
  }) async {
    final img.Image? pickedImage = await FileUtils(context).pickImageFile();
    if (pickedImage == null) return null;

    // Resize to canvas size if needed
    img.Image resized = pickedImage;
    if (pickedImage.width != width || pickedImage.height != height) {
      resized = img.copyResize(
        pickedImage,
        width: width,
        height: height,
        interpolation: img.Interpolation.cubic,
      );
    }

    // Convert to pixel art layer
    final pixels = Uint32List(width * height);
    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final pixel = resized.getPixel(x, y);
        final a = pixel.a.toInt();
        final r = pixel.r.toInt();
        final g = pixel.g.toInt();
        final b = pixel.b.toInt();
        final colorVal = (a << 24) | (r << 16) | (g << 8) | b;

        // Treat non-opaque pixels as transparent
        pixels[y * width + x] = (a == 255) ? colorVal : Colors.transparent.value;
      }
    }

    return Layer(
      layerId: 0,
      id: const Uuid().v4(),
      name: layerName ?? 'Imported Image',
      pixels: pixels,
      isVisible: true,
      order: 0,
    );
  }

  Future<Uint8List?> importImageAsBackground({
    required BuildContext context,
  }) async {
    final img.Image? pickedImage = await FileUtils(context).pickImageFile();
    if (pickedImage == null) return null;

    return Uint8List.fromList(img.encodePng(pickedImage));
  }

  Future<Project?> importProject({
    required BuildContext context,
  }) async {
    try {
      final contents = await FileUtils(context).readProjectFileContents();
      if (contents == null) return null;

      final projectData = jsonDecode(contents);
      return Project.fromJson(projectData);
    } catch (e) {
      debugPrint('Error importing project: $e');
      return null;
    }
  }

  Map<String, dynamic> createSpriteSheetMetadata({
    required List<AnimationFrame> frames,
    required int columns,
    required int frameWidth,
    required int frameHeight,
    required int spacing,
  }) {
    return {
      'version': '1.0',
      'frames': frames.length,
      'columns': columns,
      'frameWidth': frameWidth,
      'frameHeight': frameHeight,
      'spacing': spacing,
      'frameData': frames
          .map((frame) => {
                'name': frame.name,
                'duration': frame.duration,
              })
          .toList(),
    };
  }

  Future<void> exportSpriteSheet({
    required BuildContext context,
    required Project project,
    required List<AnimationFrame> frames,
    required int columns,
    required int spacing,
    required bool includeAllFrames,
    bool withBackground = false,
    Color backgroundColor = Colors.white,
    double? exportWidth,
    double? exportHeight,
  }) async {
    // Calculate sprite sheet dimensions
    final framesToUse = includeAllFrames ? frames : [frames.first];
    final rows = (framesToUse.length / columns).ceil();

    // Calculate total dimensions including spacing
    final totalWidth = (project.width * columns) + (spacing * (columns - 1));
    final totalHeight = (project.height * rows) + (spacing * (rows - 1));

    // Create sprite sheet image
    var spriteSheet = img.Image(
      width: totalWidth,
      height: totalHeight,
      numChannels: 4,
    );

    // Fill background if needed
    if (withBackground) {
      for (int y = 0; y < totalHeight; y++) {
        for (int x = 0; x < totalWidth; x++) {
          spriteSheet.setPixelRgba(
            x,
            y,
            backgroundColor.red,
            backgroundColor.green,
            backgroundColor.blue,
            backgroundColor.alpha,
          );
        }
      }
    }

    // Draw each frame onto the sprite sheet
    for (int i = 0; i < framesToUse.length; i++) {
      final frame = framesToUse[i];
      final row = i ~/ columns;
      final col = i % columns;

      // Calculate position for this frame
      final xOffset = col * (project.width + spacing);
      final yOffset = row * (project.height + spacing);

      // Merge layers for this frame
      final framePixels = PixelUtils.mergeLayersPixels(
        width: project.width,
        height: project.height,
        layers: frame.layers,
      );

      // Draw frame pixels onto sprite sheet
      for (int y = 0; y < project.height; y++) {
        for (int x = 0; x < project.width; x++) {
          final pixel = framePixels[y * project.width + x];

          // Skip transparent pixels if we're using a background
          if (pixel == 0 && withBackground) continue;

          // Extract ARGB channels
          final a = (pixel >> 24) & 0xFF;
          final r = (pixel >> 16) & 0xFF;
          final g = (pixel >> 8) & 0xFF;
          final b = pixel & 0xFF;

          // Set pixel in sprite sheet
          if (a > 0) {
            spriteSheet.setPixelRgba(
              x + xOffset,
              y + yOffset,
              r,
              g,
              b,
              a,
            );
          }
        }
      }
    }

    if (exportWidth != null && exportHeight != null) {
      final resizedTotalWidth = (exportWidth * columns) + (spacing * (columns - 1));
      final resizedTotalHeight = (exportHeight * rows) + (spacing * (rows - 1));

      spriteSheet = img.copyResize(
        spriteSheet,
        width: resizedTotalWidth.toInt(),
        height: resizedTotalHeight.toInt(),
      );
    }

    // Save sprite sheet image
    final pngData = img.encodePng(spriteSheet);
    await FileUtils(context).saveImage(
      pngData,
      '${project.name}_sprite_sheet.png',
    );
  }

  /// Export a single-frame GIF.
  /// [pixels] are 0xAARRGGBB, size [w]x[h].
  /// If [withBackground] is true, the frame is flattened onto [matteColor] (0xFFRRGGBB).
  Uint8List exportGifSingleFrame({
    required Uint32List pixels,
    required int w,
    required int h,
    bool withBackground = false,
    int? matteColor, // 0xFFRRGGBB (alpha ignored)
    bool hardAlphaForGif = true, // snap alpha to 0/255 for cleaner GIF transparency
    int samplingFactor = 1,
    img.QuantizerType quantizerType = img.QuantizerType.octree,
    img.DitherKernel dither = img.DitherKernel.none,
    bool ditherSerpentine = false,
  }) {
    img.Image frame = PixelUtils.imageFromAarrggbb(
      pixels,
      w,
      h,
      hardAlphaForGif: !withBackground && hardAlphaForGif,
    );

    if (withBackground) {
      final matte = matteColor ?? 0xFF1A0F2E; // default dark purple
      final rgb = PixelUtils.rgbFromInt(matte);
      frame = PixelUtils.compositeOnMatte(frame, r: rgb.r, g: rgb.g, b: rgb.b);
    }

    final encoder = img.GifEncoder(
      samplingFactor: samplingFactor,
      quantizerType: quantizerType,
      dither: dither,
      ditherSerpentine: ditherSerpentine,
    );

    // Encode single frame
    return encoder.encode(frame, singleFrame: true);
  }

  /// Export an animated GIF.
  /// - [frames] list of 0xAARRGGBB pixel buffers (all w x h)
  /// - [durationsMs] per-frame duration (ms), length matches frames or falls back to [defaultDurationMs]
  Uint8List exportGifAnimation({
    required List<Uint32List> frames,
    required int w,
    required int h,
    List<int>? durationsMs, // per-frame duration in ms
    int defaultDurationMs = 100, // fallback duration
    bool withBackground = false,
    int? matteColor, // 0xFFRRGGBB
    bool hardAlphaForGif = true,
    int samplingFactor = 1,
    img.QuantizerType quantizerType = img.QuantizerType.octree,
    img.DitherKernel dither = img.DitherKernel.none,
    bool ditherSerpentine = false,
    // Some versions expose `repeat` (loop count) on the encoder ctor.
    // If your version supports it, you can add `repeat: 0` (infinite).
  }) {
    final enc = img.GifEncoder(
      samplingFactor: samplingFactor,
      quantizerType: quantizerType,
      dither: dither,
      ditherSerpentine: ditherSerpentine,
      // repeat: 0, // uncomment if your image package exposes this
    );

    final matte = matteColor ?? 0xFF1A0F2E;
    final matteRgb = PixelUtils.rgbFromInt(matte);

    for (int i = 0; i < frames.length; i++) {
      img.Image f = PixelUtils.imageFromAarrggbb(
        frames[i],
        w,
        h,
        hardAlphaForGif: !withBackground && hardAlphaForGif,
      );

      if (withBackground) {
        f = PixelUtils.compositeOnMatte(f, r: matteRgb.r, g: matteRgb.g, b: matteRgb.b);
      }

      final dur = (durationsMs != null && i < durationsMs.length) ? durationsMs[i] : defaultDurationMs;

      enc.addFrame(f, duration: dur);
    }

    final bytes = enc.finish(); // List<int>?
    return Uint8List.fromList(bytes ?? const <int>[]);
  }
}
