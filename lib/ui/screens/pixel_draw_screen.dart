import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../l10n/strings.dart';
import '../../pixel/image_painter.dart';
import '../../providers/pixel_controller_provider.dart';
import '../../pixel/animation_frame_controller.dart';
import '../../pixel/tools.dart';
import '../../data.dart';
import '../widgets/animation_timeline.dart';
import '../widgets/grid_painter.dart';
import '../widgets/pixel_canvas.dart';
import '../widgets/shortcuts_wrapper.dart';
import '../widgets/dialogs.dart';
import '../widgets.dart';
import '../widgets/tool_bar.dart';
import '../widgets/tool_menu.dart';
import '../widgets/tools_bottom_bar.dart';

class PixelDrawScreen extends StatefulHookConsumerWidget {
  const PixelDrawScreen({
    super.key,
    required this.project,
  });

  final Project project;

  @override
  ConsumerState<PixelDrawScreen> createState() => _PixelDrawScreenState();
}

class _PixelDrawScreenState extends ConsumerState<PixelDrawScreen> {
  late Project project = widget.project;
  late PixelDrawNotifierProvider provider = pixelDrawNotifierProvider(project);
  late PixelDrawNotifier notifier = ref.read(provider.notifier);

  @override
  void initState() {
    super.initState();
  }

  void handleExport(
    BuildContext context,
    PixelDrawNotifier notifier,
    PixelDrawState state,
  ) {
    showSaveImageDialog(
      context,
      state: state,
      onSave: (options) async {
        final format = options['format'] as String;
        final transparent = options['transparent'] as bool;
        final width = options['exportWidth'] as double;
        final height = options['exportHeight'] as double;

        switch (format) {
          case 'png':
            notifier.exportImage(
              context,
              background: !transparent,
              exportWidth: width,
              exportHeight: height,
            );
            break;

          case 'gif':
            notifier.exportAnimation(
              context,
              background: !transparent,
              exportWidth: width,
              exportHeight: height,
            );
            break;

          case 'sprite-sheet':
            final spriteOptions =
                options['spriteSheetOptions'] as Map<String, dynamic>;
            await notifier.exportSpriteSheet(
              context,
              columns: spriteOptions['columns'] as int,
              spacing: spriteOptions['spacing'] as int,
              includeAllFrames: spriteOptions['includeAllFrames'] as bool,
              withBackground: !transparent,
              exportWidth: width,
              exportHeight: height,
            );
            break;
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentTool = useState(PixelTool.pencil);
    final currentModifier = useState(PixelModifier.none);
    final width = project.width;
    final height = project.height;

    final state = ref.watch(provider);

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

    final isPlaying = useState(false);
    final showPrevFrames = useState(false);
    final isAnimationTimelineExpanded = useState(false);

    return ShortcutsWrapper(
      onUndo: state.canUndo ? notifier.undo : () {},
      onRedo: state.canRedo ? notifier.redo : () {},
      onSave: () => notifier.exportAnimation(context),
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: SafeArea(
          child: Row(
            children: [
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
                        exportAsImage: () => handleExport(
                          context,
                          notifier,
                          state,
                        ),
                        export: () => notifier.exportJson(context),
                        currentColor: state.currentColor,
                        showPrevFrames: showPrevFrames.value,
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
                        showPrevFramesOpacity: () {
                          showPrevFrames.value = !showPrevFrames.value;
                        },
                      ),
                      Expanded(
                        child: Row(
                          children: [
                            if (MediaQuery.of(context).size.width > 600)
                              Container(
                                width: 45,
                                color: Theme.of(context).colorScheme.surface,
                                child: ToolMenu(
                                  currentTool: currentTool,
                                  onSelectTool: (tool) =>
                                      currentTool.value = tool,
                                  onColorPicker: () {
                                    showColorPicker(context, notifier);
                                  },
                                  currentColor: state.currentColor,
                                ),
                              ),
                            Expanded(
                              child: GestureDetector(
                                onScaleStart: (details) {
                                  final pointerCount = details.pointerCount;
                                  if (pointerCount == 2) {
                                    normalizedOffset.value = (gridOffset.value -
                                            details.focalPoint) /
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
                                        normalizedOffset.value *
                                            gridScale.value;
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
                                                state: state,
                                                notifier: notifier,
                                                gridScale: gridScale,
                                                gridOffset: gridOffset,
                                                currentTool: currentTool.value,
                                                currentModifier:
                                                    currentModifier.value,
                                                currentColor:
                                                    state.currentColor,
                                                brushSize: brushSize,
                                                sprayIntensity: sprayIntensity,
                                                showPrevFrames:
                                                    showPrevFrames.value,
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
                                                      offset:
                                                          const Offset(0, 2),
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
                                                      offset:
                                                          const Offset(0, 2),
                                                    ),
                                                  ],
                                                ),
                                                child: Row(
                                                  children: [
                                                    const SizedBox(width: 8),
                                                    const Icon(
                                                      MaterialCommunityIcons
                                                          .spray,
                                                    ),
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
                                color: Theme.of(context).colorScheme.surface,
                                child: SizedBox(
                                  width: 250,
                                  child: Column(
                                    children: [
                                      Expanded(
                                        child: LayersPanel(
                                          width: width,
                                          height: height,
                                          layers: state.currentFrame.layers,
                                          activeLayerIndex:
                                              state.currentLayerIndex,
                                          onLayerAdded: (name) {
                                            notifier.addLayer(name);
                                          },
                                          onLayerVisibilityChanged: (index) {
                                            notifier
                                                .toggleLayerVisibility(index);
                                          },
                                          onLayerSelected: (index) {
                                            notifier.selectLayer(index);
                                          },
                                          onLayerDeleted: (index) {
                                            notifier.removeLayer(index);
                                          },
                                          onLayerLockedChanged: (index) {},
                                          onLayerNameChanged: (index, name) {},
                                          onLayerReordered:
                                              (oldIndex, newIndex) {
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
                      AnimationTimeline(
                        width: width,
                        height: height,
                        // itemsHeight: 80,
                        onSelectFrame: notifier.selectFrame,
                        onAddFrame: () {
                          notifier.addFrame(
                            'Frame ${state.currentFrames.length + 1}',
                          );
                        },
                        copyFrame: (id) {
                          notifier.addFrame(
                            'Frame ${state.currentFrames.length + 1}',
                            copyFrame: id,
                          );
                        },
                        onDeleteFrame: notifier.removeFrame,
                        onDurationChanged: (index, duration) {
                          notifier.updateFrame(
                            index,
                            state.frames[index].copyWith(duration: duration),
                          );
                        },
                        onFrameReordered: (oldIndex, newIndex) {},
                        onPlayPause: () {
                          isPlaying.value = !isPlaying.value;
                          if (isPlaying.value) {
                            showAnimationPreviewDialog(
                              context,
                              frames: state.currentFrames,
                              width: width,
                              height: height,
                            ).then((_) {
                              isPlaying.value = false;
                            });
                          }
                        },
                        onStop: () {
                          isPlaying.value = false;
                          notifier.selectFrame(0);
                        },
                        onNextFrame: () {
                          notifier.nextFrame();
                        },
                        onPreviousFrame: () {
                          notifier.prevFrame();
                        },
                        frames: state.frames,
                        states: state.animationStates,
                        selectedStateId: state.currentAnimationState.id,
                        selectedFrameId: state.currentFrame.id,
                        isPlaying: isPlaying.value,
                        settings: const AnimationSettings(),
                        onSettingsChanged: (settings) {},
                        isExpanded: isAnimationTimelineExpanded.value,
                        onExpandChanged: () {
                          isAnimationTimelineExpanded.value =
                              !isAnimationTimelineExpanded.value;
                        },
                        onAddState: (name) {
                          notifier.addAnimationState(name, 24);
                        },
                        onDeleteState: notifier.removeAnimationState,
                        onRenameState: (id, name) {},
                        onSelectedStateChanged: notifier.selectAnimationState,
                        onDuplicateState: (id) {},
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
        title: Text(Strings.of(context).pickAColor),
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
            child: Text(Strings.of(context).gotIt),
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
    required this.project,
    required this.state,
    required this.notifier,
    required this.gridScale,
    required this.gridOffset,
    required this.currentTool,
    required this.currentModifier,
    required this.currentColor,
    required this.brushSize,
    required this.sprayIntensity,
    this.showPrevFrames = false,
  });

  final Project project;
  final PixelDrawState state;
  final PixelDrawNotifier notifier;
  final ValueNotifier<double> gridScale;
  final ValueNotifier<Offset> gridOffset;
  final PixelTool currentTool;
  final PixelModifier currentModifier;
  final Color currentColor;
  final ValueNotifier<int> brushSize;
  final ValueNotifier<int> sprayIntensity;
  final bool showPrevFrames;

  double calculateOnionSkinOpacity(int forIndex, int count) {
    if (count <= 0 || forIndex.abs() > count) {
      return 0.0;
    }

    const opacityRange = 0.5 - 0.01;
    final step = opacityRange / count;

    final opacity = (step * (forIndex.abs() - 1));

    return opacity.clamp(0.1, 0.5);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CustomPaint(
      painter: GridPainter(
        width: min(project.width, 64),
        height: min(project.height, 64),
        // scale: gridScale.value,
        // offset: gridOffset.value,
      ),
      child: Stack(
        children: [
          if (showPrevFrames)
            for (var i = 0; i < state.currentFrameIndex; i++)
              Positioned.fill(
                child: Opacity(
                  opacity: calculateOnionSkinOpacity(
                    i,
                    state.currentFrameIndex,
                  ),
                  child: LayersPreview(
                    width: project.width,
                    height: project.height,
                    layers: state.frames[i].layers,
                    builder: (context, image) {
                      return image != null
                          ? CustomPaint(painter: ImagePainter(image))
                          : const ColoredBox(color: Colors.transparent);
                    },
                  ),
                ),
              ),
          Positioned.fill(
            child: PixelCanvas(
              width: project.width,
              height: project.height,
              layers: state.layers,
              currentLayerIndex: state.currentLayerIndex,
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
              onStartDrag: (scale, offset) {
                if (currentTool == PixelTool.drag) {
                  return notifier.startDrag();
                }
              },
              onDrag: (scale, offset) {
                if (currentTool == PixelTool.drag) {
                  return notifier.dragPixels(scale, offset);
                }

                gridScale.value = scale;
                gridOffset.value = offset;
              },
              onDragEnd: (s, o) {
                if (currentTool == PixelTool.drag) {
                  return notifier.endDrag();
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
