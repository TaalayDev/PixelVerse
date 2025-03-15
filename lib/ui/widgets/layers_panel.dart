import 'dart:async';

import 'package:animated_reorderable_list/animated_reorderable_list.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../pixel/image_painter.dart';
import '../../l10n/strings.dart';
import '../../data.dart';
import 'layers_preview.dart';
import 'effects/effects_panel.dart';

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
  final Function(Layer)? onLayerEffectsChanged; // Added callback for effects

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
    this.onLayerEffectsChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        const SizedBox(height: 8),
        _buildLayersPanelHeader(context),
        Divider(color: Theme.of(context).dividerColor.withOpacity(0.2)),
        Expanded(
          child: AnimatedReorderableListView(
            items: layers,
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
            enterTransition: [FlipInX(), ScaleIn()],
            exitTransition: [SlideInLeft()],
            insertDuration: const Duration(milliseconds: 300),
            removeDuration: const Duration(milliseconds: 300),
            isSameItem: (a, b) => a.id == b.id,
          ),
        ),
      ],
    );
  }

  Widget _buildLayersPanelHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            Strings.of(context).layers,
            style: const TextStyle(fontWeight: FontWeight.bold),
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
      key: ValueKey(layer.id),
      color: index == activeLayerIndex ? Colors.blue.withOpacity(0.5) : null,
      child: ListTile(
        leading: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: _buildLayerPreview(layer, width, height),
            ),
            // Show indicator if the layer has effects
            if (layer.effects.isNotEmpty)
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.purple.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  padding: const EdgeInsets.all(2),
                  child: const Icon(
                    Icons.auto_fix_high,
                    color: Colors.white,
                    size: 12,
                  ),
                ),
              ),
          ],
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
            // Effects button
            if (onLayerEffectsChanged != null)
              InkWell(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(
                    Icons.auto_fix_high,
                    color: contentColor,
                    size: 15,
                  ),
                ),
                onTap: () => _showEffectsDialog(context, layer),
              ),
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
              ? CustomPaint(painter: ImagePainter(image))
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
          title: Text(Strings.of(context).deleteLayer),
          content: Text(Strings.of(context).areYouSureWantToDeleteLayer),
          actions: <Widget>[
            TextButton(
              child: Text(Strings.of(context).cancel),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(Strings.of(context).delete),
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

  // Show effects dialog for the selected layer
  void _showEffectsDialog(BuildContext context, Layer layer) {
    showDialog(
      context: context,
      builder: (context) => EffectsDialog(
        layer: layer,
        onLayerUpdated: (updatedLayer) {
          if (onLayerEffectsChanged != null) {
            onLayerEffectsChanged!(updatedLayer);
          }
        },
      ),
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
