import 'dart:async';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:image/image.dart' as img;

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../data.dart';

class LayersPanel extends StatefulHookConsumerWidget {
  final int width;
  final int height;
  final List<Layer> layers;
  final int activeLayerIndex;
  final Function(String name) onLayerAdded;
  final Function(int) onLayerSelected;
  final Function(int) onLayerDeleted;
  final Function(int) onLayerVisibilityChanged;
  final Function(int) onLayerLockedChanged;
  final Function(int, String) onLayerNameChanged;
  final Function(int oldIndex, int newIndex) onLayerReordered;
  final Function(int, double) onLayerOpacityChanged;

  const LayersPanel({
    super.key,
    required this.width,
    required this.height,
    required this.layers,
    required this.onLayerAdded,
    required this.activeLayerIndex,
    required this.onLayerSelected,
    required this.onLayerDeleted,
    required this.onLayerVisibilityChanged,
    required this.onLayerLockedChanged,
    required this.onLayerNameChanged,
    required this.onLayerReordered,
    required this.onLayerOpacityChanged,
  });

  ConsumerState<LayersPanel> createState() => _LayersPanelState();
}

class _LayersPanelState extends ConsumerState<LayersPanel> {
  late List<Layer> layers = widget.layers;
  late int activeLayerIndex = widget.activeLayerIndex;
  final Map<int, ui.Image> _cachedPreviews = {};
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _updateLayerPreviews();
  }

  @override
  void didUpdateWidget(covariant LayersPanel oldWidget) {
    if (oldWidget.layers != widget.layers) {
      layers = widget.layers;
      _scheduleUpdateLayerPreviews();
    }
    if (oldWidget.activeLayerIndex != widget.activeLayerIndex) {
      activeLayerIndex = widget.activeLayerIndex;
    }
    super.didUpdateWidget(oldWidget);
  }

  Future<void> _scheduleUpdateLayerPreviews() async {
    if (_debounceTimer != null && _debounceTimer!.isActive) {
      _debounceTimer!.cancel();
    }
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _updateLayerPreviews();
    });
  }

  Future<void> _updateLayerPreviews() async {
    for (final layer in layers) {
      final image = await _createImageFromPixels(
        Uint32List.fromList(layer.pixels),
        widget.width,
        widget.height,
      );
      _cachedPreviews[layer.id] = image;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 250,
      child: Column(
        children: [
          const Divider(),
          _buildLayersPanelHeader(),
          Expanded(
            child: ReorderableListView.builder(
              itemCount: layers.length,
              onReorder: (oldIndex, newIndex) {
                widget.onLayerReordered(newIndex, oldIndex);
              },
              itemBuilder: (context, index) {
                final layer = layers[index];
                return _buildLayerTile(
                  context,
                  layer,
                  index,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLayersPanelHeader() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Layers',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              widget.onLayerAdded('Layer ${layers.length + 1}');
            },
            tooltip: 'Add new layer',
          ),
        ],
      ),
    );
  }

  Widget _buildLayerTile(BuildContext context, Layer layer, int index) {
    final contentColor =
        index == activeLayerIndex ? Colors.white : Colors.black;
    return Card(
      key: ValueKey(layer.name),
      color: index == activeLayerIndex ? Colors.blue.withOpacity(0.5) : null,
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: _buildLayerPreview(layer, widget.width, widget.height),
        ),
        title: Text(
          layer.name,
          style: TextStyle(
            color: contentColor,
            fontSize: 12,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(
                  layer.isVisible ? Icons.visibility : Icons.visibility_off,
                  color: contentColor,
                  size: 15,
                ),
              ),
              onTap: () {
                widget.onLayerVisibilityChanged(index);
              },
            ),
            InkWell(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(
                  Icons.delete,
                  color: contentColor,
                  size: 15,
                ),
              ),
              onTap: () => _showDeleteConfirmation(context, index),
            ),
            const SizedBox(width: 8),
          ],
        ),
        onTap: () {
          widget.onLayerSelected(index);
        },
        selected: index == activeLayerIndex,
      ),
    );
  }

  Widget _buildLayerPreview(Layer layer, int width, int height) {
    final image = _cachedPreviews[layer.id];
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white),
        color: Colors.white.withOpacity(0.8),
      ),
      child: image != null
          ? RawImage(
              image: image,
              fit: BoxFit.cover,
            )
          : const ColoredBox(color: Colors.white),
    );
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

  void _showDeleteConfirmation(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Layer'),
          content: const Text('Are you sure you want to delete this layer?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () {
                Navigator.of(context).pop();
                widget.onLayerDeleted(index);
              },
            ),
          ],
        );
      },
    );
  }

  Future<String?> _showRenameDialog(BuildContext context, String? name) async {
    final TextEditingController controller = TextEditingController(text: name);
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(name == null ? 'Create New Layer' : 'Rename Layer'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Layer Name',
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: name == null ? const Text('Create') : const Text('Rename'),
              onPressed: () {
                Navigator.of(context).pop(controller.text);
              },
            ),
          ],
        );
      },
    );
  }
}
