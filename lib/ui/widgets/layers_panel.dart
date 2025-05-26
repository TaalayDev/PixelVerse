import 'dart:ui' as ui;
import 'dart:async';

import 'package:animated_reorderable_list/animated_reorderable_list.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pixelverse/data/models/subscription_model.dart';
import 'package:pixelverse/providers/subscription_provider.dart';
import 'package:pixelverse/ui/widgets/subscription/feature_gate.dart';

import '../../pixel/image_painter.dart';
import '../../l10n/strings.dart';
import '../../data.dart';
import '../../pixel/pixel_draw_state.dart';
import '../../providers/background_image_provider.dart';
import '../../pixel/providers/pixel_notifier_provider.dart';
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
  final Function(Layer)? onLayerEffectsChanged;
  final ScrollController? scrollController;

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
    this.scrollController,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscription = ref.watch(subscriptionStateProvider);
    final backgroundImage = ref.watch(backgroundImageProvider);

    return Column(
      children: [
        const SizedBox(height: 8),
        _buildLayersPanelHeader(context),
        Divider(color: Theme.of(context).dividerColor.withOpacity(0.2), height: 0),
        Expanded(
          child: AnimatedReorderableListView(
            items: layers,
            controller: scrollController,
            onReorder: (oldIndex, newIndex) {
              onLayerReordered(newIndex, oldIndex);
            },
            itemBuilder: (context, index) {
              final layer = layers[index];
              return _buildLayerTile(
                context,
                layer,
                index,
                subscription,
              );
            },
            enterTransition: [FlipInX(), ScaleIn()],
            exitTransition: [SlideInLeft()],
            insertDuration: const Duration(milliseconds: 300),
            removeDuration: const Duration(milliseconds: 300),
            isSameItem: (a, b) => a.id == b.id,
          ),
        ),
        if (backgroundImage.image != null) _buildBackgroundImageTile(context, ref, backgroundImage),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildBackgroundImageTile(BuildContext context, WidgetRef ref, BackgroundImageState backgroundImage) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: Colors.amber.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Background preview
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      color: Colors.white,
                    ),
                    child: Image.memory(
                      backgroundImage.image!,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Title and badge
                Expanded(
                  child: Row(
                    children: [
                      const Text(
                        'BG',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Reference',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.amber.shade800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Delete button
                IconButton(
                  icon: Icon(Icons.delete_outline, size: 15, color: Colors.red.shade400),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () => _showBackgroundDeleteConfirmation(context, ref),
                  tooltip: 'Remove background image',
                ),
              ],
            ),

            // Opacity slider
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.opacity, size: 14, color: Colors.grey.shade600),
                const SizedBox(width: 8),
                Expanded(
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 4,
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                      overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
                      activeTrackColor: Colors.amber.shade300,
                      inactiveTrackColor: Colors.grey.shade300,
                      thumbColor: Colors.amber.shade500,
                    ),
                    child: Slider(
                      value: backgroundImage.opacity,
                      min: 0.0,
                      max: 1.0,
                      divisions: 10,
                      onChanged: (value) {
                        ref.read(backgroundImageProvider.notifier).update((state) => state.copyWith(opacity: value));
                      },
                    ),
                  ),
                ),
                SizedBox(
                  width: 32,
                  child: Text(
                    '${(backgroundImage.opacity * 100).toInt()}%',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showBackgroundDeleteConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Remove Background Image'),
          content: const Text('Are you sure you want to remove the background image?'),
          actions: <Widget>[
            TextButton(
              child: Text(Strings.of(context).cancel),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Remove'),
              onPressed: () {
                Navigator.of(context).pop();
                // Call function to remove background
                ref.read(backgroundImageProvider.notifier).update((state) => state.copyWith(image: null));
              },
            ),
          ],
        );
      },
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

  Widget _buildLayerTile(
    BuildContext context,
    Layer layer,
    int index,
    UserSubscription subscription,
  ) {
    final contentColor = index == activeLayerIndex ? Colors.white : Theme.of(context).colorScheme.onSurface;

    return Card(
      key: ValueKey(layer.id),
      color: index == activeLayerIndex ? Colors.blue.withOpacity(0.5) : null,
      child: ListTile(
        contentPadding: const EdgeInsets.only(left: 8, right: 8),
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
              ProBadge(
                show: !subscription.isPro,
                padding: const EdgeInsets.all(4),
                child: InkWell(
                  onTap: !subscription.isPro ? null : () => _showEffectsDialog(context, layer),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(
                      Icons.auto_fix_high,
                      color: contentColor,
                      size: 15,
                    ),
                  ),
                ),
              ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                InkWell(
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
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
                    padding: const EdgeInsets.all(4.0),
                    child: Icon(
                      Icons.delete,
                      color: contentColor,
                      size: 15,
                    ),
                  ),
                  onTap: () => _showDeleteConfirmation(context, index),
                ),
              ],
            ),
            const SizedBox(width: 30),
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
          return image != null ? CustomPaint(painter: ImagePainter(image)) : const ColoredBox(color: Colors.white);
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
    context.showEffectsPanel(
      layer: layer,
      width: width,
      height: height,
      onLayerUpdated: (updatedLayer) {
        if (onLayerEffectsChanged != null) {
          onLayerEffectsChanged!(updatedLayer);
        }
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
