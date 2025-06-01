import 'dart:async';
import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pixelverse/ui/widgets/animated_background.dart';

import '../../l10n/strings.dart';
import '../../pixel/canvas/pixel_canvas.dart';
import '../../pixel/image_painter.dart';
import '../../pixel/pixel_draw_state.dart';
import '../../providers/background_image_provider.dart';
import '../../pixel/providers/pixel_notifier_provider.dart';
import '../../pixel/animation_frame_controller.dart' hide AnimationController;
import '../../pixel/tools.dart';
import '../../data.dart';
import '../../providers/subscription_provider.dart';
import '../widgets/animation_preview_dialog.dart';
import '../widgets/animation_timeline.dart';
import '../widgets/effects/effects_panel.dart';
import '../widgets/grid_painter.dart';
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

class _PixelDrawScreenState extends ConsumerState<PixelDrawScreen> with TickerProviderStateMixin {
  late Project project = widget.project;
  late PixelDrawNotifierProvider provider = pixelDrawNotifierProvider(project);
  late PixelDrawNotifier notifier = ref.read(provider.notifier);

  final _focusNode = FocusNode();
  bool _showUI = true;
  bool _isPanMode = false;
  Color _backgroundColor = Colors.white;

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
      subscription: ref.read(subscriptionStateProvider),
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
            final spriteOptions = options['spriteSheetOptions'] as Map<String, dynamic>;
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

  Future<bool?> showImportDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.file_upload, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 12),
            Text(
              'Import Image',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ],
        ),
        content: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Select how you want to import your image:',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),

              // Option 1: Import as new layer
              _buildImportOption(
                context,
                icon: Icons.layers,
                title: 'Convert to Pixel Art',
                description: 'Import and automatically convert the image to pixel art style on a new layer.',
                onTap: () => Navigator.of(context).pop(false),
              ),

              const SizedBox(height: 16),

              // Option 2: Import as background
              _buildImportOption(
                context,
                icon: Icons.image,
                title: 'Import as Background',
                description: 'Import the image as-is and use it as a reference background layer.',
                onTap: () => Navigator.of(context).pop(true),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(null),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Widget _buildImportOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).dividerColor),
          borderRadius: BorderRadius.circular(8),
          color: Theme.of(context).colorScheme.surface,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                size: 28,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                        ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Theme.of(context).colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }

  void _toggleUI() {
    setState(() {
      _showUI = !_showUI;
    });
  }

  void _setZoomFit(ValueNotifier<double> gridScale, ValueNotifier<Offset> gridOffset) {
    // Calculate zoom to fit canvas in view
    final screenSize = MediaQuery.of(context).size;
    final canvasAspectRatio = project.width / project.height;
    final screenAspectRatio = screenSize.width / screenSize.height;

    double newScale;
    if (canvasAspectRatio > screenAspectRatio) {
      newScale = (screenSize.width * 0.8) / project.width;
    } else {
      newScale = (screenSize.height * 0.8) / project.height;
    }

    gridScale.value = newScale.clamp(0.5, 5.0);
    gridOffset.value = Offset.zero;
  }

  void _setZoom100(ValueNotifier<double> gridScale, ValueNotifier<Offset> gridOffset) {
    gridScale.value = 1.0;
    gridOffset.value = Offset.zero;
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

    final subscription = ref.watch(subscriptionStateProvider);

    return ShortcutsWrapper(
      onUndo: state.canUndo ? notifier.undo : () {},
      onRedo: state.canRedo ? notifier.redo : () {},
      onSave: () => notifier.exportAnimation(context),
      onExport: () => handleExport(context, notifier, state),
      onImport: () async {
        final result = await showImportDialog(context);
        if (result != null) {
          notifier.importImage(context, background: result);
        }
      },
      onToolChanged: (tool) {
        currentTool.value = tool;
        if (_isPanMode && tool != PixelTool.drag) {
          _isPanMode = false;
        } else if (tool == PixelTool.drag) {
          _isPanMode = true;
        }
      },
      onBrushSizeChanged: (size) {
        brushSize.value = size;
      },
      onZoomIn: () {
        gridScale.value = (gridScale.value * 1.1).clamp(0.5, 5.0);
      },
      onZoomOut: () {
        gridScale.value = (gridScale.value / 1.1).clamp(0.5, 5.0);
      },
      onZoomFit: () => _setZoomFit(gridScale, gridOffset),
      onZoom100: () => _setZoom100(gridScale, gridOffset),
      onSwapColors: () {},
      onDefaultColors: () {},
      onToggleUI: _toggleUI,
      onPanStart: () {
        if (!_isPanMode) {
          currentTool.value = PixelTool.drag;
          _isPanMode = true;
        }
      },
      onPanEnd: () {
        if (_isPanMode) {
          currentTool.value = PixelTool.pencil;
          _isPanMode = false;
        }
      },
      onLayerChanged: (layerIndex) {
        if (layerIndex < state.layers.length) {
          notifier.selectLayer(layerIndex);
        }
      },
      onColorPicker: () {
        showColorPicker(context, notifier);
      },
      onNewLayer: () {
        notifier.addLayer('Layer ${state.layers.length + 1}');
      },
      onDeleteLayer: () {
        if (state.layers.length > 1) {
          notifier.removeLayer(state.currentLayerIndex);
        }
      },
      onSelectAll: () {},
      onDeselectAll: () {
        notifier.setSelection(null);
      },
      onCopy: () {
        // TODO: Implement copy functionality
      },
      onPaste: () {
        // TODO: Implement paste functionality
      },
      onCut: () {
        // TODO: Implement cut functionality
      },
      onDuplicate: () {
        // Duplicate current layer
        final currentLayer = state.layers[state.currentLayerIndex];
        notifier.addLayer('${currentLayer.name} Copy');
        // TODO: Copy pixels from current layer to new layer
      },
      onCtrlEnter: () {
        if (currentTool.value == PixelTool.pen) {
          notifier.pushEvent(const ClosePenPathEvent());
        }
      },
      currentBrushSize: brushSize.value,
      maxBrushSize: 10,
      maxLayers: state.layers.length,
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: SafeArea(
          child: AnimatedBackground(
            enableAnimation: false,
            child: Column(
              children: [
                ToolBar(
                  currentTool: currentTool,
                  brushSize: brushSize,
                  sprayIntensity: sprayIntensity,
                  subscription: subscription,
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
                  import: () async {
                    final result = await showImportDialog(context);
                    if (result != null) {
                      notifier.importImage(context, background: result);
                    }
                  },
                  currentModifier: currentModifier,
                  onSelectModifier: (modifier) {
                    currentModifier.value = modifier;
                    notifier.setCurrentModifier(modifier);
                  },
                  onZoomIn: () {
                    gridScale.value = (gridScale.value * 1.1).clamp(0.5, 5.0);
                  },
                  onZoomOut: () {
                    gridScale.value = (gridScale.value / 1.1).clamp(0.5, 5.0);
                  },
                  onShare: () => notifier.share(context),
                  showPrevFramesOpacity: () {
                    showPrevFrames.value = !showPrevFrames.value;
                  },
                  // Add these properties for effects support
                  onEffects: () => handleEffects(context, notifier),
                  currentLayerHasEffects: notifier.getCurrentLayer().effects.isNotEmpty,
                ),
                Expanded(
                  child: Row(
                    children: [
                      if (MediaQuery.of(context).size.width > 1050)
                        Container(
                          width: 45,
                          color: Theme.of(context).colorScheme.surface,
                          child: ToolMenu(
                            currentTool: currentTool,
                            onSelectTool: (tool) => currentTool.value = tool,
                            onColorPicker: () {
                              showColorPicker(context, notifier);
                            },
                            currentColor: state.currentColor,
                            subscription: subscription,
                          ),
                        ),
                      Expanded(
                        child: GestureDetector(
                          onScaleStart: (details) {
                            final pointerCount = details.pointerCount;
                            if (pointerCount == 2) {
                              normalizedOffset.value = (gridOffset.value - details.focalPoint) / gridScale.value;
                            }
                          },
                          onScaleUpdate: (details) {
                            final pointerCount = details.pointerCount;
                            if (pointerCount == 2) {
                              const sensitivity = 0.5;
                              final initialScale = gridScale.value;
                              final newScale = initialScale * (1 + (details.scale - 1) * sensitivity);
                              gridScale.value = newScale.clamp(0.5, 5.0);
                              gridOffset.value = details.focalPoint + normalizedOffset.value * gridScale.value;
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
                                          border: Border.all(color: Colors.grey),
                                        ),
                                        child: PixelPainter(
                                          project: project,
                                          state: state,
                                          notifier: notifier,
                                          gridScale: gridScale,
                                          gridOffset: gridOffset,
                                          currentTool: currentTool.value,
                                          currentModifier: currentModifier.value,
                                          currentColor: state.currentColor,
                                          brushSize: brushSize,
                                          sprayIntensity: sprayIntensity,
                                          showPrevFrames: showPrevFrames.value,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              if (MediaQuery.sizeOf(context).width < 1000)
                                Positioned(
                                  left: 16,
                                  right: 16,
                                  top: 16,
                                  child: _ToolElements(
                                    currentTool: currentTool,
                                    brushSize: brushSize,
                                    sprayIntensity: sprayIntensity,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      if (MediaQuery.sizeOf(context).width > 1050)
                        _DesktopSidePanel(
                          width: width,
                          height: height,
                          state: state,
                          notifier: notifier,
                          currentTool: currentTool,
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
                    isAnimationTimelineExpanded.value = !isAnimationTimelineExpanded.value;
                  },
                  onAddState: (name) {
                    notifier.addAnimationState(name, 24);
                  },
                  onDeleteState: notifier.removeAnimationState,
                  onRenameState: (id, name) {},
                  onSelectedStateChanged: notifier.selectAnimationState,
                  onDuplicateState: (id) {},
                ),
                if (MediaQuery.sizeOf(context).width <= 1050)
                  ToolsBottomBar(
                    currentTool: currentTool,
                    state: state,
                    notifier: notifier,
                    subscription: subscription,
                    width: width,
                    height: height,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void handleEffects(
    BuildContext context,
    PixelDrawNotifier notifier,
  ) {
    final currentLayer = notifier.getCurrentLayer();

    context.showEffectsPanel(
      layer: currentLayer,
      width: project.width,
      height: project.height,
      onLayerUpdated: (updatedLayer) {
        notifier.updateLayer(updatedLayer);
      },
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

class _ToolElements extends StatelessWidget {
  const _ToolElements({
    super.key,
    required this.currentTool,
    required this.brushSize,
    required this.sprayIntensity,
  });

  final ValueNotifier<PixelTool> currentTool;
  final ValueNotifier<int> brushSize;
  final ValueNotifier<int> sprayIntensity;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (currentTool.value == PixelTool.brush ||
            currentTool.value == PixelTool.eraser ||
            currentTool.value == PixelTool.sprayPaint) ...[
          Container(
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
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
                    value: brushSize.value.toDouble(),
                    min: 1,
                    max: 10,
                    onChanged: (value) {
                      brushSize.value = value.toInt();
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
        ],
        if (currentTool.value == PixelTool.sprayPaint) ...[
          Container(
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                const SizedBox(width: 8),
                const Icon(
                  MaterialCommunityIcons.spray,
                ),
                SizedBox(
                  width: 150,
                  child: Slider(
                    value: sprayIntensity.value.toDouble(),
                    min: 1,
                    max: 10,
                    onChanged: (value) {
                      sprayIntensity.value = value.toInt();
                    },
                  ),
                ),
              ],
            ),
          ),
        ]
      ],
    );
  }
}

class _DesktopSidePanel extends StatefulWidget {
  final int width;
  final int height;
  final PixelDrawState state;
  final PixelDrawNotifier notifier;
  final ValueNotifier<PixelTool> currentTool;

  const _DesktopSidePanel({
    super.key,
    required this.width,
    required this.height,
    required this.state,
    required this.notifier,
    required this.currentTool,
  });

  @override
  State<_DesktopSidePanel> createState() => _DesktopSidePanelState();
}

class _DesktopSidePanelState extends State<_DesktopSidePanel> with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
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
                      onLayerNameChanged: (index, name) {},
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
                    ),
                  ),
                  const Divider(height: 0, color: Colors.grey),

                  // Color palette
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
    final backgroundImage = ref.watch(backgroundImageProvider);

    return CustomPaint(
      painter: GridPainter(
        width: min(project.width, 64),
        height: min(project.height, 64),
        // scale: gridScale.value,
        // offset: gridOffset.value,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (backgroundImage.image != null)
            Positioned.fill(
              child: LayoutBuilder(builder: (context, constraints) {
                final maXWidth = constraints.maxWidth;
                final maXHeight = constraints.maxHeight;

                return Opacity(
                  opacity: backgroundImage.opacity,
                  child: Transform(
                    transform: Matrix4.identity()
                      ..scale(backgroundImage.scale)
                      ..translate(
                        backgroundImage.offset.dx * maXWidth,
                        backgroundImage.offset.dy * maXHeight,
                      ),
                    child: Image.memory(
                      backgroundImage.image!,
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              }),
            ),
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
              zoomLevel: gridScale.value,
              currentOffset: gridOffset.value,
              eventStream: notifier.eventStream,
              onDrawShape: (points) {
                ref.read(pixelDrawNotifierProvider(project).notifier).fillPixels(points);
              },
              onStartDrawing: () {
                // notifier.saveState();
              },
              onFinishDrawing: () {},
              onSelectionChanged: (rect) {
                ref.read(pixelDrawNotifierProvider(project).notifier).setSelection(rect);
              },
              onMoveSelection: (rect) {
                ref.read(pixelDrawNotifierProvider(project).notifier).moveSelection(rect);
              },
              onColorPicked: (color) {
                ref.read(pixelDrawNotifierProvider(project).notifier).currentColor =
                    color == Colors.transparent ? Colors.white : color;
              },
              onGradientApplied: (gradientColors) {
                ref.read(pixelDrawNotifierProvider(project).notifier).applyGradient(gradientColors);
              },
              onStartDrag: (scale, offset) {
                if (currentTool == PixelTool.drag) {
                  return ref.read(pixelDrawNotifierProvider(project).notifier).startDrag();
                }
              },
              onDrag: (scale, offset) {
                if (currentTool == PixelTool.drag) {
                  return ref.read(pixelDrawNotifierProvider(project).notifier).dragPixels(scale, offset);
                }

                gridScale.value = scale;
                gridOffset.value = offset;
              },
              onDragEnd: (s, o) {
                if (currentTool == PixelTool.drag) {
                  return ref.read(pixelDrawNotifierProvider(project).notifier).endDrag();
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
