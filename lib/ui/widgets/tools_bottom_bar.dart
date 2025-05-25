import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';

import '../../data/models/subscription_model.dart';
import '../../pixel/tools.dart';
import '../../pixel/providers/pixel_notifier_provider.dart';
import 'color_palette_panel.dart';
import 'layers_panel.dart';
import 'styled_tool_bottom_sheet.dart';

class ToolsBottomBar extends HookWidget {
  const ToolsBottomBar({
    super.key,
    required this.currentTool,
    required this.state,
    required this.notifier,
    required this.width,
    required this.height,
    required this.subscription,
  });

  final ValueNotifier<PixelTool> currentTool;
  final PixelDrawState state;
  final PixelDrawNotifier notifier;
  final UserSubscription subscription;
  final int width;
  final int height;

  @override
  Widget build(BuildContext context) {
    // Workaround for the issue with the bottom sheet not updating
    // when the state changes. This is a temporary solution
    final drawState = useState(state);

    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        drawState.value = state;
      });
      return null;
    }, [state]);

    return BottomAppBar(
      height: 45,
      child: IconButtonTheme(
        data: IconButtonThemeData(
          style: IconButton.styleFrom(
            padding: const EdgeInsets.all(0),
            iconSize: 18,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: Stack(
                clipBehavior: Clip.none,
                children: [
                  const Icon(Icons.edit),
                  Positioned(
                    right: -10,
                    top: -5,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.76),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Transform.rotate(
                        angle: 3.14,
                        child: const Icon(Entypo.chevron_down, size: 12),
                      ),
                    ),
                  ),
                ],
              ),
              color: currentTool.value == PixelTool.pencil ? Colors.blue : null,
              onPressed: () async {
                currentTool.value = PixelTool.pencil;
                final tool = await showStyledToolBottomSheet(
                  context,
                  currentTool,
                );
                if (tool != null) {
                  currentTool.value = tool;
                }
              },
            ),
            IconButton(
              icon: const Icon(Fontisto.eraser),
              color: currentTool.value == PixelTool.eraser ? Colors.blue : null,
              onPressed: () {
                currentTool.value = PixelTool.eraser;
              },
            ),
            IconButton(
              icon: const Icon(Icons.format_color_fill),
              color: currentTool.value == PixelTool.fill ? Colors.blue : null,
              onPressed: () {
                currentTool.value = PixelTool.fill;
              },
            ),
            IconButton(
              icon: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: state.currentColor,
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primary,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(40),
                ),
              ),
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  builder: (context) => DraggableScrollableSheet(
                    initialChildSize: 0.9,
                    maxChildSize: 0.9,
                    minChildSize: 0.6,
                    expand: false,
                    builder: (context, scrollController) => ColorPalettePanel(
                      scrollController: scrollController,
                      currentColor: state.currentColor,
                      isEyedropperSelected: currentTool.value == PixelTool.eyedropper,
                      onSelectEyedropper: () {
                        currentTool.value = PixelTool.eyedropper;
                        Navigator.of(context).pop();
                      },
                      onColorSelected: (color) {
                        notifier.currentColor = color;
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.layers),
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  builder: (context) => DraggableScrollableSheet(
                    initialChildSize: 0.6,
                    maxChildSize: 0.9,
                    minChildSize: 0.4,
                    expand: false,
                    builder: (context, scrollController) => ValueListenableBuilder(
                      valueListenable: drawState,
                      builder: (context, state, _) => LayersPanel(
                        width: width,
                        height: height,
                        layers: state.layers,
                        activeLayerIndex: state.currentLayerIndex,
                        onLayerAdded: (name) {
                          notifier.addLayer(name);
                        },
                        onLayerVisibilityChanged: (index) {
                          notifier.toggleLayerVisibility(index);
                        },
                        onLayerSelected: (index) {
                          notifier.selectLayer(index);
                        },
                        onLayerDeleted: (index) {
                          notifier.removeLayer(index);
                        },
                        onLayerLockedChanged: (index) {},
                        onLayerNameChanged: (index, name) {},
                        onLayerReordered: (oldIndex, newIndex) {
                          notifier.reorderLayers(
                            newIndex,
                            oldIndex,
                          );
                        },
                        onLayerOpacityChanged: (index, opacity) {},
                        onLayerEffectsChanged: (updatedLayer) {
                          notifier.updateLayer(updatedLayer);
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<PixelTool?> showStyledToolBottomSheet(
    BuildContext context,
    ValueNotifier<PixelTool> currentTool,
  ) {
    return showModalBottomSheet<PixelTool>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => StyledToolBottomSheet(currentTool: currentTool),
    );
  }
}
