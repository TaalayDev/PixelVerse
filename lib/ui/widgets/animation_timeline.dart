import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pixelverse/l10n/strings.dart';

import '../../data.dart';
import '../../pixel/animation_frame_controller.dart';
import '../../pixel/image_painter.dart';
import '../widgets.dart';

class AnimationTimeline extends ConsumerStatefulWidget {
  const AnimationTimeline({
    super.key,
    required this.height,
    required this.width,
    required this.itemsHeight,
    required this.onSelectFrame,
    required this.onAddFrame,
    required this.onDeleteFrame,
    required this.onDurationChanged,
    required this.onFrameReordered,
    required this.onPlayPause,
    required this.onStop,
    required this.onNextFrame,
    required this.onPreviousFrame,
    required this.frames,
    required this.selectedFrameIndex,
    required this.isPlaying,
    required this.settings,
    required this.onSettingsChanged,
    this.isExpanded = false,
    required this.onExpandChanged,
    required this.copyFrame,
  });

  final int width;
  final int height;
  final double itemsHeight;
  final Function(int) onSelectFrame;
  final VoidCallback onAddFrame;
  final Function(int) onDeleteFrame;
  final Function(int, int) onDurationChanged;
  final Function(int, int) onFrameReordered;
  final VoidCallback onPlayPause;
  final VoidCallback onStop;
  final VoidCallback onNextFrame;
  final VoidCallback onPreviousFrame;
  final List<AnimationFrame> frames;
  final int selectedFrameIndex;
  final bool isPlaying;
  final AnimationSettings settings;
  final Function(AnimationSettings) onSettingsChanged;
  final bool isExpanded;
  final VoidCallback onExpandChanged;
  final Function(int index) copyFrame;

  @override
  ConsumerState<AnimationTimeline> createState() => _AnimationTimelineState();
}

class _AnimationTimelineState extends ConsumerState<AnimationTimeline> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 5),
          _buildControls(),
          const SizedBox(height: 2),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: SizeTransition(
                  sizeFactor: animation,
                  child: child,
                ),
              );
            },
            child: widget.isExpanded
                ? SizedBox(
                    key: const ValueKey('timeline'),
                    height: widget.itemsHeight,
                    child: _buildTimeline(),
                  )
                : const SizedBox(),
          ),
        ],
      ),
    );
  }

  Widget _buildControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            IconButton(
              icon: const Icon(Feather.skip_back, size: 15),
              onPressed: widget.onPreviousFrame,
              tooltip: 'Previous Frame',
              iconSize: 15,
            ),
            IconButton(
              icon: Icon(
                widget.isPlaying ? Feather.pause : Feather.play,
                size: 15,
              ),
              onPressed: widget.onPlayPause,
              tooltip: widget.isPlaying ? 'Pause' : 'Play',
              iconSize: 15,
            ),
            IconButton(
              icon: const Icon(Feather.square, size: 15),
              onPressed: widget.onStop,
              tooltip: 'Stop',
              iconSize: 15,
            ),
            IconButton(
              icon: const Icon(Feather.skip_forward, size: 15),
              onPressed: widget.onNextFrame,
              tooltip: 'Next Frame',
              iconSize: 15,
            ),
          ],
        ),
        Row(
          children: [
            IconButton(
              icon: const Icon(Feather.plus),
              onPressed: widget.onAddFrame,
              tooltip: 'Add Frame',
              iconSize: 15,
            ),
            IconButton(
              onPressed: () => widget.copyFrame(widget.selectedFrameIndex),
              icon: const Icon(Feather.copy),
              tooltip: 'Copy Frame',
              iconSize: 15,
            ),
            IconButton(
              icon: Icon(
                widget.isExpanded
                    ? Icons.keyboard_arrow_down
                    : Icons.keyboard_arrow_up,
              ),
              onPressed: widget.onExpandChanged,
              tooltip: 'Expand',
              iconSize: 15,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTimeline() {
    return Column(
      children: [
        Expanded(
          child: ReorderableListView(
            scrollDirection: Axis.horizontal,
            onReorder: widget.onFrameReordered,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            buildDefaultDragHandles: false,
            children: [
              for (int i = 0; i < widget.frames.length; i++)
                _buildFrameItem(i, widget.frames[i]),
            ],
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 20,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: widget.frames.length,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) => SizedBox(
              width: 50,
              child: TextFormField(
                initialValue: widget.frames[index].duration.toString(),
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  isDense: true,
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12),
                onChanged: (value) {
                  final duration = int.tryParse(value);
                  if (duration != null) {
                    widget.onDurationChanged(index, duration);
                  }
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFrameItem(int index, AnimationFrame frame) {
    final isSelected = index == widget.selectedFrameIndex;

    return KeyedSubtree(
      key: ValueKey(frame.id),
      child: Padding(
        padding: const EdgeInsets.only(right: 8),
        child: InkWell(
          onTap: () => widget.onSelectFrame(index),
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              border: Border.all(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey.shade300,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Stack(
              children: [
                if (frame.pixels.isNotEmpty)
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LayersPreview(
                        width: widget.width,
                        height: widget.height,
                        layers: frame.layers,
                        builder: (context, image) {
                          return image != null
                              ? CustomPaint(painter: ImagePainter(image))
                              : const ColoredBox(color: Colors.white);
                        },
                      ),
                    ),
                  ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: InkWell(
                    child: const Icon(
                      Feather.trash_2,
                      size: 10,
                      color: Colors.red,
                    ),
                    onTap: () => widget.onDeleteFrame(index),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsPanel() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Animation Settings',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('FPS'),
              SizedBox(
                width: 80,
                child: TextFormField(
                  initialValue: widget.settings.fps.toString(),
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    isDense: true,
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  onChanged: (value) {
                    final fps = int.tryParse(value);
                    if (fps != null) {
                      widget.onSettingsChanged(
                        widget.settings.copyWith(fps: fps),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SwitchListTile(
            title: const Text('Loop'),
            value: widget.settings.loop,
            onChanged: (value) {
              widget.onSettingsChanged(
                widget.settings.copyWith(loop: value),
              );
            },
          ),
          SwitchListTile(
            title: const Text('Ping-pong'),
            value: widget.settings.pingPong,
            onChanged: (value) {
              widget.onSettingsChanged(
                widget.settings.copyWith(pingPong: value),
              );
            },
          ),
          SwitchListTile(
            title: const Text('Auto-play'),
            value: widget.settings.autoPlay,
            onChanged: (value) {
              widget.onSettingsChanged(
                widget.settings.copyWith(autoPlay: value),
              );
            },
          ),
        ],
      ),
    );
  }
}

Future<void> showAnimationPreviewDialog(
  BuildContext context, {
  required List<AnimationFrame> frames,
  required int width,
  required int height,
}) {
  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(Strings.of(context).animationPreview),
        content: AnimationPreview(
          frames: frames,
          width: width,
          height: height,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(Strings.of(context).close),
          ),
        ],
      );
    },
  );
}

class AnimationPreview extends StatefulWidget {
  const AnimationPreview({
    super.key,
    required this.width,
    required this.height,
    required this.frames,
  });

  final List<AnimationFrame> frames;
  final int width;
  final int height;

  @override
  State<AnimationPreview> createState() => _AnimationPreviewState();
}

class _AnimationPreviewState extends State<AnimationPreview> {
  int _currentFrameIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _next();
  }

  void _next() {
    final frame = widget.frames[_currentFrameIndex];
    _timer?.cancel();
    _timer = Timer(
      Duration(milliseconds: frame.duration),
      () {
        setState(() {
          _currentFrameIndex = (_currentFrameIndex + 1) % widget.frames.length;
          _next();
        });
      },
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _timer = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IndexedStack(
      index: _currentFrameIndex,
      children: [
        for (var frame in widget.frames)
          Container(
            width: (widget.width * 10).clamp(0, 400).toDouble(),
            height: (widget.height * 10).clamp(0, 400).toDouble(),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white),
              color: Colors.white.withOpacity(0.8),
            ),
            child: LayersPreview(
              width: widget.width,
              height: widget.height,
              layers: frame.layers,
              builder: (context, image) {
                return image != null
                    ? CustomPaint(painter: ImagePainter(image))
                    : const ColoredBox(color: Colors.yellow);
              },
            ),
          ),
      ],
    );
  }
}
