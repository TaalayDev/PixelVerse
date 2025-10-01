import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../pixel/pixel_canvas_state.dart';
import '../../../pixel/providers/pixel_canvas_provider.dart';
import '../../../pixel/tools.dart';
import '../../../providers/subscription_provider.dart';
import 'color_palette_panel.dart';
import '../dialogs/layer_template_dialog.dart';
import '../effects/effects_side_panel.dart';
import '../layers_panel.dart';

class DesktopSidePanel extends StatefulHookConsumerWidget {
  final int width;
  final int height;
  final PixelCanvasState state;
  final PixelCanvasNotifier notifier;
  final ValueNotifier<PixelTool> currentTool;

  const DesktopSidePanel({
    super.key,
    required this.width,
    required this.height,
    required this.state,
    required this.notifier,
    required this.currentTool,
  });

  @override
  ConsumerState<DesktopSidePanel> createState() => _DesktopSidePanelState();
}

class _DesktopSidePanelState extends ConsumerState<DesktopSidePanel> with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    final subscription = ref.watch(subscriptionStateProvider);

    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: SizedBox(
        width: 250,
        child: Column(
          children: [
            // Tab content
            Expanded(
              child: Column(
                children: [
                  Expanded(
                    child: LayersPanel(
                      width: widget.width,
                      height: widget.height,
                      layers: widget.state.currentFrame.layers,
                      activeLayerIndex: widget.state.currentLayerIndex,
                      onLayerUpdated: (layer) {
                        widget.notifier.updateLayer(layer);
                      },
                      onLayerAdded: (name) {
                        widget.notifier.addLayer(name);
                      },
                      onLayerVisibilityChanged: (index) {
                        widget.notifier.toggleLayerVisibility(index);
                      },
                      onLayerSelected: (index) {
                        widget.notifier.selectLayer(index);
                      },
                      onLayerDeleted: (index) {
                        widget.notifier.removeLayer(index);
                      },
                      onLayerLockedChanged: (index) {},
                      onLayerReordered: (oldIndex, newIndex) {
                        widget.notifier.reorderLayers(
                          newIndex,
                          oldIndex,
                        );
                      },
                      onLayerOpacityChanged: (index, opacity) {},
                      onLayerEffectsChanged: (updatedLayer) {
                        widget.notifier.updateLayer(updatedLayer);
                      },
                      onLayerDuplicated: (index) {
                        widget.notifier.duplicateLayer(index);
                      },
                      onLayerToTemplate: (layer) {
                        LayerToTemplateDialog.show(context, layer: layer, width: widget.width, height: widget.height);
                      },
                    ),
                  ),
                  Divider(height: 0, color: Colors.grey.withOpacity(0.5)),
                  Expanded(
                    child: EffectsSidePanel(
                      layer: widget.state.layers[widget.state.currentLayerIndex],
                      width: widget.width,
                      height: widget.height,
                      onLayerUpdated: (updatedLayer) {
                        widget.notifier.updateLayer(updatedLayer);
                      },
                    ),
                  ),
                  Divider(height: 0, color: Colors.grey.withOpacity(0.5)),
                  Expanded(
                    child: ColorPalettePanel(
                      currentColor: widget.state.currentColor,
                      isEyedropperSelected: widget.currentTool.value == PixelTool.eyedropper,
                      onSelectEyedropper: () {
                        widget.currentTool.value = PixelTool.eyedropper;
                      },
                      onColorSelected: (color) {
                        widget.notifier.currentColor = color;
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
