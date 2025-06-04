import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:pixelverse/ui/widgets/app_expandable.dart';

import '../../data/models/subscription_model.dart';
import '../../pixel/pixel_draw_state.dart';
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

    final showExtraTools = useState(false);

    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        drawState.value = state;
      });
      return null;
    }, [state]);

    const extraTools = {
      PixelTool.sprayPaint: (MaterialCommunityIcons.spray, 'Spray'),
      PixelTool.line: (Icons.show_chart, 'Line'),
      PixelTool.circle: (Icons.radio_button_unchecked, 'Circle'),
      PixelTool.rectangle: (Icons.crop_square, 'Rectangle'),
      PixelTool.pen: (CupertinoIcons.pencil, 'Pen'),
      PixelTool.select: (Icons.crop, 'Select'),
    };

    return BottomAppBar(
      height: showExtraTools.value ? 90 : 45,
      child: IconButtonTheme(
        data: IconButtonThemeData(
          style: IconButton.styleFrom(
            padding: const EdgeInsets.all(0),
            iconSize: 18,
          ),
        ),
        child: Column(
          children: [
            if (showExtraTools.value)
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: extraTools.entries.map((entry) {
                    final tool = entry.key;
                    final iconData = entry.value.$1;
                    final label = entry.value.$2;

                    return IconButton(
                      icon: Icon(iconData),
                      color: currentTool.value == tool ? Colors.blue : null,
                      onPressed: () {
                        currentTool.value = tool;
                        showExtraTools.value = false; // Close the extra tools
                      },
                      tooltip: label,
                    );
                  }).toList(),
                ).animate().fadeIn(duration: const Duration(milliseconds: 200)),
              ),
            if (showExtraTools.value) Divider(color: Colors.grey.withOpacity(0.5), thickness: 0.1),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    color: currentTool.value == PixelTool.pencil ? Colors.blue : null,
                    onPressed: () async {
                      currentTool.value = PixelTool.pencil;
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
                            builder: (context, state, _) => Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: LayersPanel(
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
                        ),
                      );
                    },
                  ),
                  IconButton(
                    color: extraTools.containsKey(currentTool.value) ? Colors.blue : null,
                    onPressed: () async {
                      showExtraTools.value = !showExtraTools.value;
                    },
                    icon: const Icon(Icons.style),
                  ),
                ],
              ),
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
