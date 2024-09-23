import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pixelverse/ui/widgets/layers_panel.dart';

import '../../providers/pixel_controller_provider.dart';
import '../../core/tools.dart';
import '../widgets/pixel_grid_widget.dart';

class PixelDrawScreen extends HookConsumerWidget {
  const PixelDrawScreen({
    super.key,
    required this.id,
    required this.name,
    required this.width,
    required this.height,
  });

  final String id;
  final String name;
  final int width;
  final int height;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTool = useState<PixelTool>(PixelTool.pencil);
    final state = ref.watch(
      pixelDrawNotifierProvider(width: width, height: height),
    );
    final notifier = useMemoized(
      () => ref.read(
        pixelDrawNotifierProvider(width: width, height: height).notifier,
      ),
      [width, height],
    );

    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifier.currentTool = currentTool.value;
      });
    }, [currentTool.value]);

    final gridScale = useState(1.0);
    final gridOffset = useState(Offset.zero);
    final brushSize = useState(5);
    final sprayIntensity = useState(5);

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
                      onSave: () {
                        // Implement save functionality
                      },
                      currentColor: state.currentColor,
                      onColorPicker: () {
                        showColorPicker(context, notifier);
                      },
                    ),
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            child: Center(
                              child: AspectRatio(
                                aspectRatio: width / height,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Container(
                                    clipBehavior: Clip.hardEdge,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      border: Border.all(color: Colors.grey),
                                    ),
                                    child: PixelPainter(
                                      width: width,
                                      height: height,
                                      gridScale: gridScale,
                                      gridOffset: gridOffset,
                                      currentTool: currentTool,
                                      brushSize: brushSize,
                                      sprayIntensity: sprayIntensity,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          if (MediaQuery.of(context).size.width > 600)
                            Container(
                              color: Colors.grey[200],
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
                                  notifier.reorderLayers(newIndex, oldIndex);
                                },
                                onLayerOpacityChanged: (index, opacity) {},
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (MediaQuery.of(context).size.width <= 600)
                      BottomAppBar(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit,
                                  color: currentTool.value == PixelTool.pencil
                                      ? Colors.blue
                                      : null),
                              onPressed: () =>
                                  currentTool.value = PixelTool.pencil,
                            ),
                            IconButton(
                              icon: Icon(Icons.format_color_fill,
                                  color: currentTool.value == PixelTool.fill
                                      ? Colors.blue
                                      : null),
                              onPressed: () =>
                                  currentTool.value = PixelTool.fill,
                            ),
                            IconButton(
                              icon: Icon(Icons.cleaning_services,
                                  color: currentTool.value == PixelTool.eraser
                                      ? Colors.blue
                                      : null),
                              onPressed: () =>
                                  currentTool.value = PixelTool.eraser,
                            ),
                            IconButton(
                              icon: const Icon(Icons.color_lens),
                              onPressed: () {
                                showColorPicker(context, notifier);
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.grid_on),
                              onPressed: () {
                                // Implement grid size change
                              },
                            ),
                          ],
                        ),
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

class PixelPainter extends HookConsumerWidget {
  const PixelPainter({
    super.key,
    required this.width,
    required this.height,
    required this.gridScale,
    required this.gridOffset,
    required this.currentTool,
    required this.brushSize,
    required this.sprayIntensity,
  });

  final int width;
  final int height;
  final ValueNotifier<double> gridScale;
  final ValueNotifier<Offset> gridOffset;
  final ValueNotifier<PixelTool> currentTool;
  final ValueNotifier<int> brushSize;
  final ValueNotifier<int> sprayIntensity;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(
      pixelDrawNotifierProvider(width: width, height: height),
    );
    final notifier = useMemoized(
      () => ref.read(
        pixelDrawNotifierProvider(width: width, height: height).notifier,
      ),
      [width, height],
    );

    return CustomPaint(
      painter: GridPainter(
        width: width,
        height: height,
        scale: gridScale.value,
        offset: gridOffset.value,
      ),
      child: PixelGrid(
        width: width,
        height: height,
        layers: state.layers,
        onTapPixel: (x, y) {
          switch (currentTool.value) {
            case PixelTool.pencil:
            case PixelTool.brush:
            case PixelTool.pixelPerfectLine:
            case PixelTool.sprayPaint:
              notifier.setPixel(x, y);
              break;
            case PixelTool.mirror:
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
          notifier.fillPixels(points);
        },
        currentTool: currentTool.value,
        currentColor: state.currentColor,
        brushSize: brushSize.value,
        sprayIntensity: sprayIntensity.value,
        onDrawShape: (points) {
          notifier.fillPixels(points);
        },
        onStartDrawing: () {
          notifier.saveState();
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
                Icons.gradient,
                color: tool == PixelTool.gradient ? Colors.blue : null,
              ),
              onPressed: () => onSelectTool(PixelTool.gradient),
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
  final ValueNotifier<int> brushSize;
  final ValueNotifier<int> sprayIntensity;
  final Function(PixelTool) onSelectTool;
  final VoidCallback? onUndo;
  final VoidCallback? onRedo;
  final VoidCallback onSave;
  final Color currentColor;
  final Function() onColorPicker;

  const ToolBar({
    super.key,
    required this.currentTool,
    required this.brushSize,
    required this.sprayIntensity,
    required this.onSelectTool,
    required this.onUndo,
    required this.onRedo,
    required this.onSave,
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
                      IconButton(
                        icon: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: currentColor,
                              border: Border.all(color: Colors.black),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                        onPressed: () {
                          onColorPicker();
                        },
                      ),
                      IconButton(
                        icon: Icon(
                          MaterialCommunityIcons.eyedropper,
                          color:
                              tool == PixelTool.eyedropper ? Colors.blue : null,
                        ),
                        onPressed: () => onSelectTool(PixelTool.eyedropper),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: Icon(
                          MaterialIcons.border_horizontal,
                          color: tool == PixelTool.mirror ? Colors.blue : null,
                        ),
                        onPressed: () => onSelectTool(PixelTool.mirror),
                      ),

                      const SizedBox(width: 8),
                      // zoom in and out
                      IconButton(
                        icon: const Icon(Feather.zoom_in),
                        onPressed: () {},
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Feather.zoom_out),
                        onPressed: () {},
                      ),
                      const SizedBox(width: 8),
                      const SizedBox(
                        height: 30,
                        child: VerticalDivider(),
                      ),
                      const SizedBox(width: 16),
                      // brush size
                      Container(
                        height: 35,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          children: [
                            const SizedBox(width: 8),
                            const Icon(Icons.brush),
                            SizedBox(
                              width: 150,
                              child: Slider(
                                value: brushSize.value.toDouble(),
                                min: 1,
                                max: 50,
                                onChanged: (value) {
                                  brushSize.value = value.toInt();
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      // spray intensity
                      Container(
                        height: 35,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          children: [
                            const SizedBox(width: 8),
                            const Icon(MaterialCommunityIcons.spray),
                            SizedBox(
                              width: 150,
                              child: Slider(
                                value: sprayIntensity.value.toDouble(),
                                min: 1,
                                max: 50,
                                onChanged: (value) {
                                  sprayIntensity.value = value.toInt();
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
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
              IconButton(
                icon: const Icon(Feather.save),
                onPressed: onSave,
                tooltip: 'Save',
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
