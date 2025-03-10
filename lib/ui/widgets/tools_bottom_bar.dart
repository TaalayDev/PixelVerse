import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';

import '../../pixel/tools.dart';
import '../../providers/pixel_controller_provider.dart';
import 'color_palette_panel.dart';
import 'layers_panel.dart';
import 'styled_tool_bottom_sheet.dart';

class ToolsBottomBar extends StatelessWidget {
  const ToolsBottomBar({
    super.key,
    required this.currentTool,
    required this.state,
    required this.notifier,
    required this.width,
    required this.height,
  });

  final ValueNotifier<PixelTool> currentTool;
  final PixelDrawState state;
  final PixelDrawNotifier notifier;
  final int width;
  final int height;

  @override
  Widget build(BuildContext context) {
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
              icon: const Icon(Icons.edit),
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
              color: currentTool.value == PixelTool.eraser ? Colors.blue : null,
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
                  builder: (context) => ColorPalettePanel(
                    currentColor: state.currentColor,
                    isEyedropperSelected:
                        currentTool.value == PixelTool.eyedropper,
                    onSelectEyedropper: () {
                      currentTool.value = PixelTool.eyedropper;
                      Navigator.of(context).pop();
                    },
                    onColorSelected: (color) {
                      notifier.currentColor = color;
                      Navigator.of(context).pop();
                    },
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.layers),
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  builder: (context) => LayersPanel(
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
