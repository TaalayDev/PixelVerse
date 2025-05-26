import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:share_plus/share_plus.dart';
import 'package:uuid/uuid.dart';

import '../../core.dart';
import '../../data.dart';

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
    final images = <img.Image>[];

    for (final frame in frames) {
      final pixels = PixelUtils.mergeLayersPixels(
        width: project.width,
        height: project.height,
        layers: frame.layers,
      );

      final image = img.Image(
        width: project.width,
        height: project.height,
        numChannels: 4,
      );

      for (int y = 0; y < project.height; y++) {
        for (int x = 0; x < project.width; x++) {
          final pixel = pixels[y * project.width + x];
          final a = (pixel >> 24) & 0xFF;
          final r = (pixel >> 16) & 0xFF;
          final g = (pixel >> 8) & 0xFF;
          final b = pixel & 0xFF;

          if (a == 0 && withBackground) {
            image.setPixelRgba(x, y, 255, 255, 255, 255);
          } else {
            image.setPixelRgba(x, y, r, g, b, a);
          }
        }
      }

      if (exportWidth != null && exportHeight != null) {
        images.add(img.copyResize(
          image,
          width: exportWidth.toInt(),
          height: exportHeight.toInt(),
        ));
      } else {
        images.add(image);
      }
    }

    final gifEncoder = img.GifEncoder(
      samplingFactor: 1,
      quantizerType: img.QuantizerType.octree,
      ditherSerpentine: true,
    );

    for (var i = 0; i < images.length; i++) {
      gifEncoder.addFrame(
        images[i],
        duration: frames[i].duration ~/ 10,
      );
    }

    final gifData = gifEncoder.finish();
    if (gifData != null) {
      await FileUtils(context).saveImage(gifData, '${project.name}.gif');
    }
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
}
