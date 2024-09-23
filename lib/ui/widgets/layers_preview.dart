import 'dart:async';
import 'dart:ui' as ui;
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../data.dart';

class LayersPreview extends StatefulWidget {
  const LayersPreview({
    super.key,
    required this.width,
    required this.height,
    required this.layers,
    required this.builder,
  });

  final int width;
  final int height;
  final List<Layer> layers;
  final Widget Function(BuildContext, ui.Image?) builder;

  @override
  State<LayersPreview> createState() => _LayersPreviewState();
}

class _LayersPreviewState extends State<LayersPreview> {
  ui.Image? _image;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _updateLayersPreview();
  }

  @override
  void didUpdateWidget(covariant LayersPreview oldWidget) {
    if (!listEquals(oldWidget.layers, widget.layers)) {
      _scheduleUpdateLayersPreview();
    }
    super.didUpdateWidget(oldWidget);
  }

  Future<void> _scheduleUpdateLayersPreview() async {
    if (_debounceTimer != null && _debounceTimer!.isActive) {
      _debounceTimer!.cancel();
    }
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _updateLayersPreview();
    });
  }

  Future<void> _updateLayersPreview() async {
    final pixels = Uint32List(widget.width * widget.height);
    for (final layer in widget.layers) {
      for (int i = 0; i < pixels.length; i++) {
        pixels[i] = pixels[i] == 0 ? layer.pixels[i] : pixels[i];
      }
    }

    final image = await _createImageFromPixels(
      pixels,
      widget.width,
      widget.height,
    );
    _image = image;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _image);
  }

  Future<ui.Image> _createImageFromPixels(
    Uint32List pixels,
    int width,
    int height,
  ) async {
    final Completer<ui.Image> completer = Completer();
    Uint32List fixedPixels = _fixColorChannels(pixels);
    ui.decodeImageFromPixels(
      Uint8List.view(fixedPixels.buffer),
      width,
      height,
      ui.PixelFormat.rgba8888,
      (ui.Image img) {
        completer.complete(img);
      },
    );
    return completer.future;
  }

  Uint32List _fixColorChannels(Uint32List pixels) {
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
