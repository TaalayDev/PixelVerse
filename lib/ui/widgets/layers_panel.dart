import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../data.dart';
import 'layers_preview.dart';

class LayersPanel extends HookConsumerWidget {
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                onLayerReordered(newIndex, oldIndex);
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
              onLayerAdded('Layer ${layers.length + 1}');
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
          child: _buildLayerPreview(layer, width, height),
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
                onLayerVisibilityChanged(index);
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
          onLayerSelected(index);
        },
        selected: index == activeLayerIndex,
      ),
    );
  }

  Widget _buildLayerPreview(Layer layer, int width, int height) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white),
        color: Colors.white.withOpacity(0.8),
      ),
      child: LayersPreview(
        width: width,
        height: height,
        layers: [layer],
        builder: (context, image) {
          return image != null
              ? RawImage(
                  image: image,
                  fit: BoxFit.cover,
                )
              : const ColoredBox(color: Colors.white);
        },
      ),
    );
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
                onLayerDeleted(index);
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