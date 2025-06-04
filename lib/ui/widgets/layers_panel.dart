import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:animated_reorderable_list/animated_reorderable_list.dart';

import '../../data.dart';
import '../../l10n/strings.dart';
import '../../pixel/image_painter.dart';
import '../../pixel/pixel_draw_state.dart';
import '../../data/models/subscription_model.dart';
import '../../providers/subscription_provider.dart';
import '../../providers/background_image_provider.dart';
import 'subscription/feature_gate.dart';
import 'effects/effects_panel.dart';
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
        Divider(color: Theme.of(context).dividerColor.withOpacity(0.2), height: 0),
        const SizedBox(height: 4),
        _buildActionButtonsBar(context, subscription),
        const SizedBox(height: 4),
        Divider(color: Theme.of(context).dividerColor.withOpacity(0.2), height: 0),
        const SizedBox(height: 4),
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

  Widget _buildActionButtonsBar(BuildContext context, UserSubscription subscription) {
    final hasSelectedLayer = activeLayerIndex >= 0 && activeLayerIndex < layers.length;
    final selectedLayer = hasSelectedLayer ? layers[activeLayerIndex] : null;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Add Layer Button
          _buildActionButton(
            context: context,
            icon: Icons.add,
            color: Colors.green,
            onPressed: () async {
              onLayerAdded('Layer ${layers.length + 1}');
            },
          ),
          const SizedBox(width: 8),

          // Effects Button
          ProBadge(
            show: !subscription.isPro,
            padding: const EdgeInsets.all(2),
            child: _buildActionButton(
              context: context,
              icon: Icons.auto_fix_high,
              color: Colors.purple,
              onPressed: hasSelectedLayer && subscription.isPro && onLayerEffectsChanged != null
                  ? () {
                      _showEffectsDialog(context, selectedLayer!);
                    }
                  : null,
              badge: selectedLayer?.effects.isNotEmpty == true,
            ),
          ),
          const SizedBox(width: 8),

          // Delete Button
          _buildActionButton(
            context: context,
            icon: Icons.delete_outline,
            color: Colors.red,
            onPressed: hasSelectedLayer && layers.length > 1
                ? () {
                    _showDeleteConfirmation(context, activeLayerIndex);
                  }
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required IconData icon,
    required Color color,
    required VoidCallback? onPressed,
    bool badge = false,
  }) {
    final isEnabled = onPressed != null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isEnabled ? color.withOpacity(0.3) : Colors.grey.withOpacity(0.2),
              width: 1,
            ),
            color: isEnabled ? color.withOpacity(0.1) : Colors.grey.withOpacity(0.05),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(
                icon,
                size: 12,
                color: isEnabled ? color : Colors.grey.shade400,
              ),
              if (badge)
                Positioned(
                  right: -4,
                  top: -4,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
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

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
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
                      const SizedBox(height: 4),
                      // Transform controls
                      Row(
                        children: [
                          // Reset button
                          InkWell(
                            onTap: () => ref.read(backgroundImageProvider.notifier).resetTransform(),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.grey.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'Reset',
                                style: TextStyle(
                                  fontSize: 9,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Fit button
                          InkWell(
                            onTap: () => ref
                                .read(backgroundImageProvider.notifier)
                                .fitToCanvas(width.toDouble(), height.toDouble()),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.grey.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'Fit',
                                style: TextStyle(
                                  fontSize: 9,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ),
                          ),
                        ],
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

            Row(
              children: [
                Icon(Icons.zoom_in, size: 14, color: Colors.grey.shade600),
                const SizedBox(width: 8),
                Expanded(
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 4,
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                      overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
                      activeTrackColor: Colors.blue.shade300,
                      inactiveTrackColor: Colors.grey.shade300,
                      thumbColor: Colors.blue.shade500,
                    ),
                    child: Slider(
                      value: backgroundImage.scale,
                      min: 0.1,
                      max: 1,
                      onChanged: (value) {
                        ref.read(backgroundImageProvider.notifier).setScale(value);
                      },
                    ),
                  ),
                ),
                SizedBox(
                  width: 32,
                  child: Text(
                    '${(backgroundImage.scale * 100).toInt()}%',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
              ],
            ),

            Row(
              children: [
                Icon(Feather.move, size: 14, color: Colors.grey.shade600),
                const SizedBox(width: 8),
                Expanded(
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 4,
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                      overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
                      activeTrackColor: Colors.green.shade300,
                      inactiveTrackColor: Colors.grey.shade300,
                      thumbColor: Colors.green.shade500,
                    ),
                    child: Slider(
                      value: backgroundImage.offset.dx,
                      min: 0,
                      max: 1,
                      onChanged: (value) {
                        ref.read(backgroundImageProvider.notifier).setOffset(Offset(value, backgroundImage.offset.dy));
                      },
                    ),
                  ),
                ),
                Expanded(
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 4,
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                      overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
                      activeTrackColor: Colors.green.shade300,
                      inactiveTrackColor: Colors.grey.shade300,
                      thumbColor: Colors.green.shade500,
                    ),
                    child: Slider(
                      value: backgroundImage.offset.dy,
                      min: 0,
                      max: 1,
                      onChanged: (value) {
                        ref.read(backgroundImageProvider.notifier).setOffset(Offset(backgroundImage.offset.dx, value));
                      },
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            Strings.of(context).layers,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          Text(
            '${layers.length} layers',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
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
    final isSelected = index == activeLayerIndex;
    final contentColor = isSelected ? Colors.white : Theme.of(context).colorScheme.onSurface;

    return SizedBox(
      key: ValueKey(layer.id),
      height: 40,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        elevation: isSelected ? 3 : 1,
        color: isSelected ? Colors.blue.withOpacity(0.7) : null,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: isSelected ? BorderSide(color: Colors.blue.shade300, width: 2) : BorderSide.none,
        ),
        child: Padding(
          padding: const EdgeInsets.only(right: 8),
          child: InkWell(
            child: Row(
              children: [
                IconButton(
                  onPressed: () {
                    onLayerVisibilityChanged(index);
                  },
                  icon: Icon(
                    layer.isVisible ? Icons.visibility : Icons.visibility_off,
                    size: 14,
                    color: contentColor,
                  ),
                ),
                Text(
                  layer.name,
                  style: TextStyle(
                    color: contentColor,
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ],
            ),
            onTap: () {
              onLayerSelected(index);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildLayerPreview(Layer layer, int width, int height) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(6),
      ),
      child: LayersPreview(
        width: width,
        height: height,
        layers: [layer],
        builder: (context, image) {
          return image != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: CustomPaint(painter: ImagePainter(image)),
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
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
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
