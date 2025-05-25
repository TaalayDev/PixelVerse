import 'dart:async';
import 'dart:ui' as ui;

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
    final pixels = PixelUtils.mergeLayersPixels(
      width: widget.width,
      height: widget.height,
      layers: widget.layers,
    );

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
    if (_image != null) {
      _image!.dispose();
      _image = null;
    }
    if (_future != null) {
      _future = null;
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _image);
  }
}
