import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pixelverse/ui/widgets/customized_popup_menu.dart';

import '../../data.dart';
import '../../providers/pixel_controller_provider.dart';
import '../../pixel/tools.dart';
import '../widgets.dart';
import '../widgets/menu_value_field.dart';

class PixelDrawScreen extends HookConsumerWidget {
  const PixelDrawScreen({
    super.key,
    required this.project,
  });

  final Project project;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTool = useState(PixelTool.pencil);
    final currentModifier = useState(PixelModifier.none);
    final width = project.width;
    final height = project.height;

    final state = ref.watch(
      pixelDrawNotifierProvider(project),
    );
    final notifier = useMemoized(
      () => ref.read(
        pixelDrawNotifierProvider(project).notifier,
      ),
      [project.id],
    );

    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifier.currentTool = currentTool.value;
      });
    }, [currentTool.value]);

    final gridScale = useState(1.0);
    final gridOffset = useState(Offset.zero);
    final brushSize = useState(1);
    final sprayIntensity = useState(5);
    final normalizedOffset = useState(Offset(
      gridOffset.value.dx / gridScale.value,
      gridOffset.value.dy / gridScale.value,
    ));

    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: SafeArea(
        child: Row(
          children: [
            if (MediaQuery.of(context).size.width > 600)
              Container(
                width: 60,
                color: Colors.grey[200],
                child: ToolMenu(
                  currentTool: currentTool,
                  onSelectTool: (tool) => currentTool.value = tool,
                  onColorPicker: () {
                    showColorPicker(context, notifier);
                  },
                  currentColor: state.currentColor,
                ),
              ),
            Expanded(
              child: ColoredBox(
                color: Theme.of(context).scaffoldBackgroundColor,
                child: Column(
                  children: [
                    ToolBar(
                      currentTool: currentTool,
                      brushSize: brushSize,
                      sprayIntensity: sprayIntensity,
                      onSelectTool: (tool) => currentTool.value = tool,
                      onUndo: state.canUndo ? notifier.undo : null,
                      onRedo: state.canRedo ? notifier.redo : null,
                      exportAsImage: () => notifier.exportImage(context),
                      export: () => notifier.exportJson(context),
                      currentColor: state.currentColor,
                      onColorPicker: () {
                        showColorPicker(context, notifier);
                      },
                      import: () => notifier.importImage(context),
                      currentModifier: currentModifier,
                      onSelectModifier: (modifier) {
                        currentModifier.value = modifier;
                      },
                      onZoomIn: () {
                        gridScale.value =
                            (gridScale.value * 1.1).clamp(0.5, 5.0);
                      },
                      onZoomOut: () {
                        gridScale.value =
                            (gridScale.value / 1.1).clamp(0.5, 5.0);
                      },
                      onShare: () => notifier.share(context),
                    ),
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onScaleStart: (details) {
                                final pointerCount = details.pointerCount;
                                if (pointerCount == 2) {
                                  normalizedOffset.value =
                                      (gridOffset.value - details.focalPoint) /
                                          gridScale.value;
                                }
                              },
                              onScaleUpdate: (details) {
                                final pointerCount = details.pointerCount;
                                if (pointerCount == 2) {
                                  gridScale.value =
                                      (details.scale * gridScale.value)
                                          .clamp(0.5, 5.0);
                                  gridOffset.value = details.focalPoint +
                                      normalizedOffset.value * gridScale.value;
                                }
                              },
                              onScaleEnd: (details) {},
                              child: Stack(
                                clipBehavior: Clip.hardEdge,
                                children: [
                                  Container(
                                    alignment: Alignment.center,
                                    decoration: const BoxDecoration(),
                                    clipBehavior: Clip.hardEdge,
                                    child: AspectRatio(
                                      aspectRatio: width / height,
                                      child: Transform(
                                        transform: Matrix4.identity()
                                          ..translate(
                                            gridOffset.value.dx,
                                            gridOffset.value.dy,
                                          )
                                          ..scale(gridScale.value),
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Container(
                                            clipBehavior: Clip.hardEdge,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              border: Border.all(
                                                color: Colors.grey,
                                              ),
                                            ),
                                            child: PixelPainter(
                                              project: project,
                                              gridScale: gridScale,
                                              gridOffset: gridOffset,
                                              currentTool: currentTool.value,
                                              currentModifier:
                                                  currentModifier.value,
                                              currentColor: state.currentColor,
                                              brushSize: brushSize,
                                              sprayIntensity: sprayIntensity,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  if (MediaQuery.sizeOf(context).width < 600)
                                    Positioned(
                                      left: 16,
                                      right: 16,
                                      top: 16,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          if (currentTool.value ==
                                                  PixelTool.brush ||
                                              currentTool.value ==
                                                  PixelTool.eraser ||
                                              currentTool.value ==
                                                  PixelTool.sprayPaint) ...[
                                            Container(
                                              height: 40,
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black
                                                        .withOpacity(0.1),
                                                    blurRadius: 4,
                                                    offset: const Offset(0, 2),
                                                  ),
                                                ],
                                              ),
                                              child: Row(
                                                children: [
                                                  const SizedBox(width: 8),
                                                  const Icon(Icons.brush),
                                                  SizedBox(
                                                    width: 150,
                                                    child: Slider(
                                                      value: brushSize.value
                                                          .toDouble(),
                                                      min: 1,
                                                      max: 10,
                                                      onChanged: (value) {
                                                        brushSize.value =
                                                            value.toInt();
                                                      },
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                          ],
                                          if (currentTool.value ==
                                              PixelTool.sprayPaint) ...[
                                            Container(
                                              height: 40,
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black
                                                        .withOpacity(0.1),
                                                    blurRadius: 4,
                                                    offset: const Offset(0, 2),
                                                  ),
                                                ],
                                              ),
                                              child: Row(
                                                children: [
                                                  const SizedBox(width: 8),
                                                  const Icon(
                                                      MaterialCommunityIcons
                                                          .spray),
                                                  SizedBox(
                                                    width: 150,
                                                    child: Slider(
                                                      value: sprayIntensity
                                                          .value
                                                          .toDouble(),
                                                      min: 1,
                                                      max: 10,
                                                      onChanged: (value) {
                                                        sprayIntensity.value =
                                                            value.toInt();
                                                      },
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ]
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                          if (MediaQuery.sizeOf(context).width > 600)
                            Container(
                              color: Colors.grey[200],
                              child: SizedBox(
                                width: 250,
                                child: Column(
                                  children: [
                                    Expanded(
                                      child: LayersPanel(
                                        width: width,
                                        height: height,
                                        layers: state.layers,
                                        activeLayerIndex:
                                            state.currentLayerIndex,
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
                                        onLayerOpacityChanged:
                                            (index, opacity) {},
                                      ),
                                    ),
                                    const Divider(),
                                    Expanded(
                                      child: ColorPalettePanel(
                                        currentColor: state.currentColor,
                                        isEyedropperSelected:
                                            currentTool.value ==
                                                PixelTool.eyedropper,
                                        onSelectEyedropper: () {
                                          currentTool.value =
                                              PixelTool.eyedropper;
                                        },
                                        onColorSelected: (color) {
                                          notifier.currentColor = color;
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (MediaQuery.sizeOf(context).width <= 600)
                      ToolsBottomBar(
                        currentTool: currentTool,
                        state: state,
                        notifier: notifier,
                        width: width,
                        height: height,
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showColorPicker(
    BuildContext context,
    PixelDrawNotifier controller,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pick a color!'),
        content: SingleChildScrollView(
          child: MaterialPicker(
            pickerColor: controller.currentColor,
            onColorChanged: (color) {
              controller.currentColor = color;
            },
            enableLabel: true,
            portraitOnly: true,
          ),
        ),
        actions: <Widget>[
          ElevatedButton(
            child: const Text('Got it'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}

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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              currentTool.value = PixelTool.pencil;
              final tool = await showModalBottomSheet<PixelTool>(
                context: context,
                builder: (context) => Container(
                  height: 60,
                  color: Colors.grey[200],
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.edit,
                          color: currentTool.value == PixelTool.pencil
                              ? Colors.blue
                              : null,
                        ),
                        onPressed: () {
                          Navigator.of(context).pop(PixelTool.pencil);
                        },
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.brush,
                          color: currentTool.value == PixelTool.brush
                              ? Colors.blue
                              : null,
                        ),
                        onPressed: () {
                          Navigator.of(context).pop(PixelTool.brush);
                        },
                      ),
                      IconButton(
                        icon: Icon(
                          MaterialCommunityIcons.spray,
                          color: currentTool.value == PixelTool.sprayPaint
                              ? Colors.blue
                              : null,
                        ),
                        onPressed: () {
                          Navigator.of(context).pop(PixelTool.sprayPaint);
                        },
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.crop_square,
                          color: currentTool.value == PixelTool.rectangle
                              ? Colors.blue
                              : null,
                        ),
                        onPressed: () {
                          Navigator.of(context).pop(PixelTool.rectangle);
                        },
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.show_chart,
                          color: currentTool.value == PixelTool.line
                              ? Colors.blue
                              : null,
                        ),
                        onPressed: () {
                          Navigator.of(context).pop(PixelTool.line);
                        },
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.radio_button_unchecked,
                          color: currentTool.value == PixelTool.circle
                              ? Colors.blue
                              : null,
                        ),
                        onPressed: () {
                          currentTool.value = PixelTool.circle;
                          Navigator.of(context).pop(PixelTool.circle);
                        },
                      ),
                      IconButton(
                        icon: Icon(
                          CupertinoIcons.pencil,
                          color: currentTool.value == PixelTool.pen
                              ? Colors.blue
                              : null,
                        ),
                        onPressed: () {
                          currentTool.value = PixelTool.pen;
                          Navigator.of(context).pop(PixelTool.pen);
                        },
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.crop,
                          color: currentTool.value == PixelTool.select
                              ? Colors.blue
                              : null,
                        ),
                        onPressed: () {
                          Navigator.of(context).pop(PixelTool.select);
                        },
                      ),
                    ],
                  ),
                ),
              );
              if (tool != null) {
                currentTool.value = tool;
              }
            },
          ),
          IconButton(
            icon: const Icon(Fontisto.eraser),
            onPressed: () {
              currentTool.value = PixelTool.eraser;
            },
          ),
          IconButton(
            icon: const Icon(Icons.format_color_fill),
            onPressed: () {
              currentTool.value = PixelTool.fill;
            },
          ),
          IconButton(
            icon: Icon(
              Icons.palette,
              color: state.currentColor,
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
    );
  }
}

class PixelPainter extends HookConsumerWidget {
  const PixelPainter({
    super.key,
    required this.project,
    required this.gridScale,
    required this.gridOffset,
    required this.currentTool,
    required this.currentModifier,
    required this.currentColor,
    required this.brushSize,
    required this.sprayIntensity,
  });

  final Project project;
  final ValueNotifier<double> gridScale;
  final ValueNotifier<Offset> gridOffset;
  final PixelTool currentTool;
  final PixelModifier currentModifier;
  final Color currentColor;
  final ValueNotifier<int> brushSize;
  final ValueNotifier<int> sprayIntensity;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final layers = ref.watch(
      pixelDrawNotifierProvider(project).select((state) => state.layers),
    );
    final notifier = useMemoized(
      () => ref.read(
        pixelDrawNotifierProvider(project).notifier,
      ),
      [project.id],
    );

    return CustomPaint(
      painter: GridPainter(
        width: min(project.width, 64),
        height: min(project.height, 64),
        // scale: gridScale.value,
        // offset: gridOffset.value,
      ),
      child: PixelGrid(
        width: project.width,
        height: project.height,
        layers: layers,
        currentLayerIndex: notifier.currentLayerIndex,
        onTapPixel: (x, y) {
          switch (currentTool) {
            case PixelTool.pencil:
            case PixelTool.brush:
            case PixelTool.pixelPerfectLine:
            case PixelTool.sprayPaint:
              notifier.setPixel(x, y);
              break;
            case PixelTool.fill:
              notifier.fill(x, y);
              break;
            case PixelTool.eraser:
              final originalColor = notifier.currentColor;
              notifier.currentColor = Colors.transparent;
              notifier.setPixel(x, y);
              notifier.currentColor = originalColor;
              break;
            default:
              break;
          }
        },
        onBrushStroke: (points) {
          notifier.fillPixels(points, currentModifier);
        },
        currentTool: currentTool,
        currentColor: currentColor,
        modifier: currentModifier,
        brushSize: brushSize.value,
        sprayIntensity: sprayIntensity.value,
        onDrawShape: (points) {
          notifier.fillPixels(points, currentModifier);
        },
        onStartDrawing: () {
          // notifier.saveState();
        },
        onFinishDrawing: () {},
        onSelectionChanged: (rect) {
          notifier.setSelection(rect);
        },
        onMoveSelection: (rect) {
          notifier.moveSelection(rect);
        },
        onColorPicked: (color) {
          notifier.currentColor =
              color == Colors.transparent ? Colors.white : color;
        },
        onGradientApplied: (gradientColors) {
          notifier.applyGradient(gradientColors);
        },
        onZoom: (scale, offset) {
          gridScale.value = scale;
          gridOffset.value = offset;
        },
      ),
    );
  }
}

class ToolMenu extends StatelessWidget {
  final ValueNotifier<PixelTool> currentTool;
  final Function(PixelTool) onSelectTool;
  final Function() onColorPicker;
  final Color currentColor;

  const ToolMenu({
    super.key,
    required this.currentTool,
    required this.onSelectTool,
    required this.onColorPicker,
    required this.currentColor,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<PixelTool>(
      valueListenable: currentTool,
      builder: (context, tool, child) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              icon: Icon(
                Icons.edit,
                color: tool == PixelTool.pencil ? Colors.blue : null,
              ),
              onPressed: () => onSelectTool(PixelTool.pencil),
            ),
            IconButton(
              icon: Icon(
                Icons.brush,
                color: tool == PixelTool.brush ? Colors.blue : null,
              ),
              onPressed: () => onSelectTool(PixelTool.brush),
            ),
            IconButton(
              icon: Icon(
                Icons.format_color_fill,
                color: tool == PixelTool.fill ? Colors.blue : null,
              ),
              onPressed: () => onSelectTool(PixelTool.fill),
            ),
            IconButton(
              icon: Icon(
                Fontisto.eraser,
                color: tool == PixelTool.eraser ? Colors.blue : null,
              ),
              onPressed: () => onSelectTool(PixelTool.eraser),
            ),
            // selection tool
            IconButton(
              icon: Icon(
                Icons.crop,
                color: tool == PixelTool.select ? Colors.blue : null,
              ),
              onPressed: () => onSelectTool(PixelTool.select),
            ),
            ShapesMenuButton(
              currentTool: currentTool,
              onSelectTool: onSelectTool,
            ),
            IconButton(
              icon: Icon(
                CupertinoIcons.pencil,
                color: tool == PixelTool.pen ? Colors.blue : null,
              ),
              onPressed: () => onSelectTool(PixelTool.pen),
            ),
            IconButton(
              icon: Icon(
                Feather.move,
                color: tool == PixelTool.drag ? Colors.blue : null,
              ),
              onPressed: () => onSelectTool(PixelTool.drag),
            ),
            IconButton(
              icon: Icon(
                MaterialCommunityIcons.spray,
                color: tool == PixelTool.sprayPaint ? Colors.blue : null,
              ),
              onPressed: () => onSelectTool(PixelTool.sprayPaint),
            ),
          ],
        );
      },
    );
  }
}

class ToolBar extends StatelessWidget {
  final ValueNotifier<PixelTool> currentTool;
  final ValueNotifier<PixelModifier> currentModifier;
  final ValueNotifier<int> brushSize;
  final ValueNotifier<int> sprayIntensity;
  final Function(PixelTool) onSelectTool;
  final Function(PixelModifier) onSelectModifier;
  final VoidCallback? onZoomIn;
  final VoidCallback? onZoomOut;
  final VoidCallback? onUndo;
  final VoidCallback? onRedo;
  final VoidCallback? import;
  final VoidCallback? export;
  final VoidCallback? exportAsImage;
  final VoidCallback? onShare;
  final Color currentColor;
  final Function() onColorPicker;

  const ToolBar({
    super.key,
    required this.currentTool,
    required this.currentModifier,
    required this.brushSize,
    required this.sprayIntensity,
    required this.onSelectTool,
    required this.onSelectModifier,
    required this.onUndo,
    required this.onRedo,
    this.onZoomIn,
    this.onZoomOut,
    this.import,
    this.export,
    this.exportAsImage,
    this.onShare,
    required this.currentColor,
    required this.onColorPicker,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      width: double.infinity,
      color: Colors.grey[200],
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ValueListenableBuilder<PixelTool>(
                valueListenable: currentTool,
                builder: (context, tool, child) {
                  return Row(
                    children: [
                      const VerticalDivider(),
                      const SizedBox(width: 16),
                      ValueListenableBuilder(
                        valueListenable: currentModifier,
                        builder: (context, modifier, child) {
                          return IconButton(
                            icon: Icon(
                              MaterialIcons.border_horizontal,
                              color: modifier == PixelModifier.mirror
                                  ? Colors.blue
                                  : null,
                            ),
                            onPressed: () {
                              onSelectModifier(
                                modifier == PixelModifier.mirror
                                    ? PixelModifier.none
                                    : PixelModifier.mirror,
                              );
                            },
                          );
                        },
                      ),
                      const SizedBox(width: 8),
                      // zoom in and out
                      IconButton(
                        icon: const Icon(Feather.zoom_in),
                        onPressed: onZoomIn,
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Feather.zoom_out),
                        onPressed: onZoomOut,
                      ),
                      const SizedBox(width: 8),
                      if (MediaQuery.of(context).size.width > 600) ...[
                        const SizedBox(
                          height: 30,
                          child: VerticalDivider(),
                        ),
                        const SizedBox(width: 16),
                        if (tool == PixelTool.brush ||
                            tool == PixelTool.eraser ||
                            tool == PixelTool.sprayPaint) ...[
                          MenuToolValueField(
                            value: brushSize.value,
                            min: 1,
                            max: 10,
                            icon: const Icon(Icons.brush),
                            child: Text('${brushSize.value}px'),
                            onChanged: (value) {
                              brushSize.value = value;
                            },
                          ),
                          const SizedBox(width: 8),
                        ],
                        if (tool == PixelTool.sprayPaint) ...[
                          MenuToolValueField(
                            value: sprayIntensity.value,
                            min: 1,
                            max: 10,
                            icon: const Icon(MaterialCommunityIcons.spray),
                            child: Text('${sprayIntensity.value}'),
                            onChanged: (value) {
                              sprayIntensity.value = value;
                            },
                          ),
                          const SizedBox(width: 8),
                        ],
                      ],
                    ],
                  );
                },
              ),
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.undo,
                    color: onUndo != null ? null : Colors.grey),
                onPressed: onUndo,
                tooltip: 'Undo',
              ),
              IconButton(
                icon: Icon(Icons.redo,
                    color: onRedo != null ? null : Colors.grey),
                onPressed: onRedo,
                tooltip: 'Redo',
              ),
              PopupMenuButton(
                icon: const Icon(Feather.save, size: 18),
                tooltip: 'Save',
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'import',
                    child: ListTile(
                      leading: Icon(Feather.upload),
                      title: Text('Open'),
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'projects',
                    child: ListTile(
                      leading: Icon(Feather.list),
                      title: Text('Projects'),
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'export',
                    child: ListTile(
                      leading: Icon(Feather.save),
                      title: Text('Export'),
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'exportAsImage',
                    child: ListTile(
                      leading: Icon(Feather.image),
                      title: Text('Export as Image'),
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'share',
                    child: ListTile(
                      leading: Icon(Feather.share),
                      title: Text('Share'),
                    ),
                  ),
                ],
                onSelected: (value) {
                  switch (value) {
                    case 'import':
                      import?.call();
                      break;
                    case 'export':
                      export?.call();
                      break;
                    case 'exportAsImage':
                      exportAsImage?.call();
                      break;
                    case 'projects':
                      Navigator.of(context).pop();
                      break;
                    case 'share':
                      onShare?.call();
                      break;
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ShapesMenuButton extends StatelessWidget {
  final ValueNotifier<PixelTool> currentTool;
  final Function(PixelTool) onSelectTool;

  const ShapesMenuButton({
    super.key,
    required this.currentTool,
    required this.onSelectTool,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<PixelTool>(
      icon: Icon(
        currentTool.value == PixelTool.line
            ? Icons.show_chart
            : currentTool.value == PixelTool.rectangle
                ? Icons.crop_square
                : Icons.radio_button_unchecked,
        color: _isShapeTool(currentTool.value) ? Colors.blue : null,
      ),
      onSelected: (PixelTool result) {
        onSelectTool(result);
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<PixelTool>>[
        const PopupMenuItem<PixelTool>(
          value: PixelTool.line,
          child: ListTile(
            leading: Icon(Icons.show_chart),
            title: Text('Line'),
          ),
        ),
        const PopupMenuItem<PixelTool>(
          value: PixelTool.rectangle,
          child: ListTile(
            leading: Icon(Icons.crop_square),
            title: Text('Rectangle'),
          ),
        ),
        const PopupMenuItem<PixelTool>(
          value: PixelTool.circle,
          child: ListTile(
            leading: Icon(Icons.radio_button_unchecked),
            title: Text('Circle'),
          ),
        ),
      ],
    );
  }

  bool _isShapeTool(PixelTool tool) {
    return tool == PixelTool.line ||
        tool == PixelTool.rectangle ||
        tool == PixelTool.circle;
  }
}

class GridPainter extends CustomPainter {
  final int width;
  final int height;
  final double scale;
  final Offset offset;

  GridPainter({
    required this.width,
    required this.height,
    this.scale = 1.0,
    this.offset = Offset.zero,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(offset.dx, offset.dy);
    canvas.scale(scale);

    final paint = Paint()
      ..color = Colors.grey.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    final cellWidth = size.width / width;
    final cellHeight = size.height / height;

    for (int i = 0; i <= width; i++) {
      final x = i * cellWidth;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    for (int i = 0; i <= height; i++) {
      final y = i * cellHeight;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is GridPainter &&
        (oldDelegate.width != width ||
            oldDelegate.height != height ||
            oldDelegate.scale != scale ||
            oldDelegate.offset != offset);
  }
}
