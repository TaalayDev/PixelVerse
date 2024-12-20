import 'dart:async';
import 'dart:ui' as ui;
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../core.dart';
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
  Future? _future;

  @override
  void initState() {
    super.initState();
    _updateLayersPreview();
  }

  @override
  void didUpdateWidget(covariant LayersPreview oldWidget) {
    if (!listEquals(oldWidget.layers, widget.layers)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scheduleUpdateLayersPreview();
      });
    }
    super.didUpdateWidget(oldWidget);
  }

  Future<void> _scheduleUpdateLayersPreview() async {
    if (_debounceTimer != null && _debounceTimer!.isActive) {
      _debounceTimer!.cancel();
    }
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _future = _updateLayersPreview();
    });
  }

  Future<void> _updateLayersPreview() async {
    final pixels = Uint32List(widget.width * widget.height);
    for (final layer in widget.layers.where((l) => l.isVisible)) {
      for (int i = 0; i < pixels.length; i++) {
        pixels[i] = pixels[i] == 0 ? layer.pixels[i] : pixels[i];
      }
    }

    final image = await ImageHelper.createImageFromPixels(
      pixels,
      widget.width,
      widget.height,
    );
    if (context.mounted) {
      setState(() {
        _image = image;
      });
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _debounceTimer = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _image);
  }
}
