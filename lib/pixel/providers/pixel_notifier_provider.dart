import 'dart:collection';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:image/image.dart' as img;
import 'package:flutter/material.dart';
import 'package:pixelverse/core/extensions.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:share_plus/share_plus.dart';
import 'package:uuid/uuid.dart';

import '../../core/pixel_point.dart';
import '../../core/utils.dart';
import '../effects/effects.dart';
import '../tools.dart';
import '../../data.dart';
import '../../providers/background_image_provider.dart';
import '../../providers/providers.dart';

part 'pixel_notifier_provider.freezed.dart';
part 'pixel_notifier_provider.g.dart';

@freezed
class PixelDrawState with _$PixelDrawState {
  const PixelDrawState._();
  const factory PixelDrawState({
    required final int width,
    required final int height,
    required final List<AnimationStateModel> animationStates,
    required final List<AnimationFrame> frames,
    @Default(0) final int currentAnimationStateIndex,
    @Default(0) final int currentFrameIndex,
    @Default(0) final int currentLayerIndex,
    required final Color currentColor,
    required final PixelTool currentTool,
    required final MirrorAxis mirrorAxis,
    final SelectionModel? selectionRect,
    @Default(false) final bool canUndo,
    @Default(false) final bool canRedo,
  }) = _PixelDrawState;

  AnimationStateModel get currentAnimationState => animationStates[currentAnimationStateIndex];
  List<AnimationFrame> get currentFrames => frames.where((frame) => frame.stateId == currentAnimationState.id).toList();
  AnimationFrame get currentFrame => currentFrames[currentFrameIndex];
  Layer get currentLayer => currentFrame.layers[currentLayerIndex];
  List<Layer> get layers => currentFrame.layers;

  List<Uint32List> get pixels => currentFrame.layers.fold(
        [],
        (List<Uint32List> acc, layer) {
          acc.add(layer.processedPixels);
          return acc;
        },
      );
}

@riverpod
class PixelDrawNotifier extends _$PixelDrawNotifier {
  PixelTool get currentTool => state.currentTool;
  set currentTool(PixelTool tool) => state = state.copyWith(currentTool: tool);
  MirrorAxis get mirrorAxis => state.mirrorAxis;
  Color get currentColor => state.currentColor;
  set currentColor(Color color) => state = state.copyWith(currentColor: color);

  AnimationFrame get currentFrame => state.currentFrame;
  Layer get currentLayer => currentFrame.layers[state.currentLayerIndex];
  int get currentLayerIndex => state.currentLayerIndex;

  final List<PixelDrawState> _undoStack = [];
  final List<PixelDrawState> _redoStack = [];

  bool get canUndo => _undoStack.isNotEmpty;
  bool get canRedo => _redoStack.isNotEmpty;

  int get width => state.width;
  int get height => state.height;

  SelectionModel? _selectionRect;
  SelectionModel? _originalSelectionRect;
  List<MapEntry<Point<int>, int>> _selectedPixels = [];
  Uint32List _cachedPixels = Uint32List(0);

  Offset? _dragStartOffset;
  Uint32List? _originalPixels;

  @override
  PixelDrawState build(Project project) {
    return PixelDrawState(
      width: project.width,
      height: project.height,
      animationStates: List<AnimationStateModel>.from(project.states),
      frames: project.frames.isNotEmpty
          ? List<AnimationFrame>.from(project.frames)
          : [
              AnimationFrame(
                id: 0,
                stateId: 0,
                name: 'Frame 1',
                duration: 100,
                layers: [
                  Layer(
                    layerId: 0,
                    id: const Uuid().v4(),
                    name: 'Layer 1',
                    pixels: Uint32List(project.width * project.height),
                  ),
                ],
              ),
            ],
      currentColor: Colors.black,
      currentTool: PixelTool.pencil,
      mirrorAxis: MirrorAxis.vertical,
      selectionRect: null,
    );
  }

  int _getFrameIndex() {
    return state.frames.indexWhere((frame) => frame.id == currentFrame.id);
  }

  void addLayer(String name) async {
    final layerOrder = currentFrame.layers.isEmpty ? 0 : currentFrame.layers.map((l) => l.order).reduce(max) + 1;

    final newLayer = Layer(
      layerId: 0,
      id: const Uuid().v4(),
      name: name,
      pixels: Uint32List(width * height),
      order: layerOrder,
    );

    ref.read(analyticsProvider).logEvent(name: 'add_layer');

    final layer = await ref.watch(projectRepo).createLayer(project.id, state.currentFrame.id, newLayer);

    final frames = List<AnimationFrame>.from(state.frames);
    final layers = List<Layer>.from(currentFrame.layers)..add(layer);
    layers.sort((a, b) => a.order.compareTo(b.order));

    final updatedFrame = currentFrame.copyWith(layers: layers);

    frames[_getFrameIndex()] = updatedFrame;

    state = state.copyWith(
      frames: frames,
      currentLayerIndex: layers.length - 1,
    );

    _updateProject();
  }

  void removeLayer(int index) {
    if (currentFrame.layers.length <= 1) return;
    ref.read(analyticsProvider).logEvent(name: 'delete_layer');

    final layer = currentFrame.layers[index];
    final layers = List<Layer>.from(currentFrame.layers)..removeAt(index);

    int newLayerIndex = state.currentLayerIndex;
    if (newLayerIndex >= layers.length) {
      newLayerIndex = layers.length - 1;
    }

    final frames = List<AnimationFrame>.from(state.frames);
    final updatedFrame = currentFrame.copyWith(layers: layers.mapIndexed((i, layer) {
      return layer.copyWith(order: i);
    }));
    frames[_getFrameIndex()] = updatedFrame;

    state = state.copyWith(
      frames: frames,
      currentLayerIndex: newLayerIndex,
    );

    ref.read(projectRepo).deleteLayer(layer.layerId);
  }

  void selectLayer(int index) {
    if (index < 0 || index >= currentFrame.layers.length) return;
    state = state.copyWith(currentLayerIndex: index);
  }

  void toggleLayerVisibility(int index) {
    ref.read(analyticsProvider).logEvent(name: 'toggle_layer_visibility');

    final layers = List<Layer>.from(currentFrame.layers);
    final layer = layers[index];
    layers[index] = layer.copyWith(isVisible: !layer.isVisible);

    final updatedFrame = currentFrame.copyWith(layers: layers);
    final frames = List<AnimationFrame>.from(state.frames)..[_getFrameIndex()] = updatedFrame;

    state = state.copyWith(frames: frames);

    ref.watch(projectRepo).updateLayer(project.id, currentFrame.id, layers[index]);
  }

  void reorderLayers(int oldIndex, int newIndex) {
    ref.read(analyticsProvider).logEvent(name: 'reorder_layers');

    final layers = List<Layer>.from(currentFrame.layers);
    final layer = layers.removeAt(oldIndex);
    layers.insert(newIndex, layer);

    state = state.copyWith(
      frames: List<AnimationFrame>.from(state.frames)
        ..[_getFrameIndex()] = currentFrame.copyWith(layers: layers.mapIndexed((i, layer) {
          return layer.copyWith(order: i);
        })),
      currentLayerIndex: oldIndex == state.currentLayerIndex ? newIndex : state.currentLayerIndex,
    );

    _updateProject();
  }

  // Get current layer
  Layer getCurrentLayer() {
    return currentFrame.layers[state.currentLayerIndex];
  }

  void updateLayer(Layer updatedLayer) {
    final layers = List<Layer>.from(currentFrame.layers);
    layers[currentLayerIndex] = updatedLayer;

    // Update the frame with the modified layers
    final frames = List<AnimationFrame>.from(state.frames);
    final frameIndex = frames.indexWhere((frame) => frame.id == currentFrame.id);

    frames[frameIndex] = currentFrame.copyWith(layers: layers);
    state = state.copyWith(frames: frames);

    _updateProject();
  }

  void undo() {
    if (!canUndo) return;
    _redoStack.add(state.copyWith());
    final previousState = _undoStack.removeLast();
    state = previousState.copyWith(
      canUndo: _undoStack.isNotEmpty,
      canRedo: true,
    );

    if (previousState.selectionRect != null) {
      setSelection(previousState.selectionRect);
    }

    _updateProject();
  }

  void redo() {
    if (!canRedo) return;
    _undoStack.add(state.copyWith());
    final nextState = _redoStack.removeLast();
    state = nextState.copyWith(
      canUndo: true,
      canRedo: _redoStack.isNotEmpty,
    );

    if (nextState.selectionRect != null) {
      setSelection(nextState.selectionRect);
    }

    _updateProject();
  }

  void saveState() {
    _undoStack.add(state.copyWith());
    if (_undoStack.length > 50) {
      _undoStack.removeAt(0);
    }
    _redoStack.clear();
    state = state.copyWith(canUndo: true, canRedo: false);
  }

  bool _isWithinBounds(int x, int y) {
    return x >= 0 && x < width && y >= 0 && y < height;
  }

  bool _isInSelectionBounds(int x, int y) {
    if (_selectionRect != null && !_isPointInSelection(x, y)) return false;
    return true;
  }

  void setPixel(int x, int y) {
    if (!_isWithinBounds(x, y)) return;
    if (!_isInSelectionBounds(x, y)) return;

    final pixels = Uint32List.fromList(currentLayer.pixels);
    final index = y * width + x;
    pixels[index] = currentColor.value;

    // if (currentTool == PixelTool.mirror) {
    //   _applyMirror(pixels, x, y);
    // }

    if (_selectionRect != null) {
      _selectedPixels.add(MapEntry(Point(x, y), currentColor.value));
    }

    _updateCurrentLayer(pixels);
  }

  void fillPixels(List<PixelPoint<int>> pixels, PixelModifier modifier) {
    saveState();
    final newPixels = Uint32List.fromList(currentLayer.pixels);

    for (final point in pixels) {
      int index = point.y * state.width + point.x;
      if (index >= 0 && index < newPixels.length) {
        newPixels[index] = currentTool == PixelTool.eraser ? Colors.transparent.value : point.color;
      }
    }

    _updateCurrentLayer(newPixels);
  }

  void fill(int x, int y) {
    if (!_isWithinBounds(x, y)) return;
    ref.read(analyticsProvider).logEvent(name: 'fill_area');

    final pixels = Uint32List.fromList(currentLayer.pixels);
    final targetColor = pixels[y * width + x];
    final fillColor = currentColor.value;

    if (targetColor == fillColor) return;

    saveState();

    final queue = Queue<Point<int>>();
    queue.add(Point(x, y));

    while (queue.isNotEmpty) {
      final point = queue.removeFirst();
      final px = point.x;
      final py = point.y;

      if (!_isWithinBounds(px, py)) continue;
      final index = py * width + px;
      if (pixels[index] != targetColor) continue;

      pixels[index] = fillColor;

      queue.add(Point(px + 1, py));
      queue.add(Point(px - 1, py));
      queue.add(Point(px, py + 1));
      queue.add(Point(px, py - 1));
    }

    _updateCurrentLayer(pixels);
  }

  void _updateCurrentLayer(Uint32List pixels) async {
    final layers = List<Layer>.from(currentFrame.layers);
    layers[state.currentLayerIndex] = currentLayer.copyWith(pixels: pixels);

    state = state.copyWith(
      frames: List<AnimationFrame>.from(state.frames)..[_getFrameIndex()] = currentFrame.copyWith(layers: layers),
    );

    await ref.watch(projectRepo).updateLayer(project.id, currentFrame.id, currentLayer);
    _updateProject();
  }

  void drawShape(List<Point<int>> points) {
    saveState();
    final pixels = Uint32List.fromList(currentLayer.pixels);
    final fillColor = currentTool == PixelTool.eraser ? Colors.transparent.value : currentColor.value;

    for (final point in points) {
      final x = point.x;
      final y = point.y;
      if (!_isWithinBounds(x, y)) continue;
      if (!_isInSelectionBounds(x, y)) continue;

      final index = y * width + x;
      pixels[index] = fillColor;
    }

    _updateCurrentLayer(pixels);
  }

  void clear() {
    saveState();
    final pixels = Uint32List(width * height);
    _updateCurrentLayer(pixels);
  }

  void resize(int newWidth, int newHeight) {
    saveState();

    final newPixels = Uint32List(newWidth * newHeight);
    final oldPixels = currentLayer.pixels;

    for (int y = 0; y < min(height, newHeight); y++) {
      for (int x = 0; x < min(width, newWidth); x++) {
        newPixels[y * newWidth + x] = oldPixels[y * width + x];
      }
    }

    state = state.copyWith(
      width: newWidth,
      height: newHeight,
    );
  }

  void applyGradient(List<Color> gradientColors) {
    final pixels = currentLayer.pixels;
    for (int i = 0; i < pixels.length; i++) {
      if (gradientColors[i] != Colors.transparent) {
        pixels[i] = Color.alphaBlend(gradientColors[i], Color(pixels[i])).value;
      }
    }
    _updateCurrentLayer(pixels);
  }

  void setSelection(SelectionModel? selection) {
    ref.read(analyticsProvider).logEvent(name: 'select_area');

    _selectionRect = selection;
    _originalSelectionRect = selection;
    if (selection != null) {
      _selectedPixels = _getSelectedPixels(selection);
      _cachedPixels = Uint32List.fromList(currentLayer.pixels);
    } else {
      _selectedPixels = [];
      _cachedPixels = Uint32List(0);
    }
    state = state.copyWith(selectionRect: selection);
  }

  void moveSelection(SelectionModel model) {
    if (_selectionRect == null) return;

    // Calculate the difference in positions
    final dx = model.x - _selectionRect!.x;
    final dy = model.y - _selectionRect!.y;

    // Create a new list for the updated selected pixels
    List<MapEntry<Point<int>, int>> newSelectedPixels = [];
    final pixels = Uint32List.fromList(currentLayer.pixels);

    // Clear the pixels at the old positions
    for (final entry in _selectedPixels) {
      final x = entry.key.x;
      final y = entry.key.y;
      if (x >= 0 && x < width && y >= 0 && y < height) {
        final p = y * width + x;
        pixels[p] = _originalSelectionRect != null && !_isPointInOriginalSelection(x, y)
            ? _cachedPixels[p]
            : Colors.transparent.value;
      }
    }

    // Update the positions of selected pixels and apply them to the canvas
    for (final entry in _selectedPixels) {
      final newX = entry.key.x + dx;
      final newY = entry.key.y + dy;
      if (newX >= 0 && newX < width && newY >= 0 && newY < height) {
        pixels[newY * width + newX] =
            entry.value == Colors.transparent.value ? pixels[newY * width + newX] : entry.value;
        newSelectedPixels.add(MapEntry(Point(newX, newY), entry.value));
      }
    }

    // Update the selected pixels list with new positions
    _selectedPixels = newSelectedPixels;

    // Update the selection rectangle
    _selectionRect = model;

    // Update the canvas with the new pixels
    _updateCurrentLayer(pixels);
  }

  List<MapEntry<Point<int>, int>> _getSelectedPixels(
    SelectionModel selection,
  ) {
    List<MapEntry<Point<int>, int>> selectedPixels = [];
    final pixels = currentLayer.pixels;
    for (int y = selection.y; y < selection.y + selection.height; y++) {
      for (int x = selection.x; x < selection.x + selection.width; x++) {
        if (x >= 0 && x < width && y >= 0 && y < height) {
          final color = pixels[y * width + x];
          selectedPixels.add(MapEntry(Point(x, y), color));
        }
      }
    }
    return selectedPixels;
  }

  bool _isPointInOriginalSelection(int x, int y) {
    if (_originalSelectionRect == null) return false;

    final rect = _originalSelectionRect!.rect;
    return x >= rect.left && x < rect.right && y >= rect.top && y < rect.bottom;
  }

  bool _isPointInSelection(int x, int y) {
    if (_selectionRect == null) return false;

    final rect = _selectionRect!.rect;
    return x >= rect.left && x < rect.right && y >= rect.top && y < rect.bottom;
  }

  void dragPixels(double scale, Offset offset) {
    if (_dragStartOffset == null) {
      // First time, store the starting offset and original pixels
      _dragStartOffset = offset;
      _originalPixels = Uint32List.fromList(currentLayer.pixels);
      return;
    }

    // Calculate the delta offset from the starting offset
    final delta = offset - _dragStartOffset!;

    // Convert delta to integer pixel offsets
    int dx = delta.dx.round();
    int dy = delta.dy.round();

    // If there's no movement, no need to update
    if (dx == 0 && dy == 0) {
      return;
    }

    // Use the original pixels to prevent accumulation of errors
    final pixels = Uint32List.fromList(_originalPixels!);
    final newPixels = Uint32List(width * height);

    // Loop through the pixels and move them by the delta offset
    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final index = y * width + x;
        final color = pixels[index];

        if (color == 0) {
          // Skip transparent pixels
          continue;
        }

        final newX = x + dx;
        final newY = y + dy;

        // Check if the new position is within bounds
        if (newX >= 0 && newX < width && newY >= 0 && newY < height) {
          final newIndex = newY * width + newX;
          newPixels[newIndex] = color;
        }
      }
    }

    // Update the current layer's pixels with the new positions
    _updateCurrentLayer(newPixels);
  }

  void startDrag() {
    saveState();
    _dragStartOffset = null;
    _originalPixels = null;
  }

  void endDrag() {
    _dragStartOffset = null;
    _originalPixels = null;
  }

  void _updateProject() async {
    ref.read(projectRepo).updateProject(
          project.copyWith(
            frames: state.frames,
            states: state.animationStates,
            editedAt: DateTime.now(),
          ),
        );
  }

  void addAnimationState(String name, int frameRate) async {
    ref.read(analyticsProvider).logEvent(
      name: 'add_animation_state',
      parameters: {'name': name},
    );

    final newState = AnimationStateModel(
      id: 0,
      name: name,
      frameRate: frameRate,
    );

    final animationState = await ref.read(projectRepo).createState(project.id, newState);

    state = state.copyWith(
      animationStates: [...state.animationStates, animationState],
      currentAnimationStateIndex: state.animationStates.length,
      currentFrameIndex: 0,
      currentLayerIndex: 0,
    );
  }

  void removeAnimationState(int id) {
    if (state.animationStates.length <= 1) return;
    final index = state.animationStates.indexWhere((state) => state.id == id);
    if (index < 0 || index >= state.animationStates.length) return;
    ref.read(analyticsProvider).logEvent(
      name: 'delete_animation_state',
      parameters: {'name': state.animationStates[index].name},
    );

    final animationState = state.animationStates[index];
    final states = List<AnimationStateModel>.from(state.animationStates)..removeAt(index);
    final frames = state.frames.where((frame) => frame.stateId != id).toList();

    // Set a safe value for currentAnimationStateIndex
    int newStateIndex = 0; // Default to the first state
    if (index == state.currentAnimationStateIndex && states.isNotEmpty) {
      // If we're deleting the current state, select another state
      newStateIndex = index > 0 ? index - 1 : 0;
    } else if (index < state.currentAnimationStateIndex) {
      // If we're deleting a state before the current one, adjust the index
      newStateIndex = state.currentAnimationStateIndex - 1;
    } else {
      // We're deleting a state after the current one, keep the same index
      newStateIndex = state.currentAnimationStateIndex;
    }

    // Make sure we have a valid frame index
    final currentFrames = frames.where((frame) => frame.stateId == states[newStateIndex].id).toList();

    int newFrameIndex = 0;
    if (currentFrames.isNotEmpty) {
      newFrameIndex = min(state.currentFrameIndex, currentFrames.length - 1);
    }

    state = state.copyWith(
      animationStates: states,
      frames: List<AnimationFrame>.from(frames),
      currentAnimationStateIndex: newStateIndex,
      currentFrameIndex: newFrameIndex,
      currentLayerIndex: 0,
    );

    ref.read(projectRepo).deleteState(animationState.id);
  }

  void selectAnimationState(int id) {
    final index = state.animationStates.indexWhere((state) => state.id == id);
    if (index < 0 || index >= state.animationStates.length) return;

    state = state.copyWith(
      currentAnimationStateIndex: index,
      currentFrameIndex: 0,
      currentLayerIndex: 0,
    );
  }

  void selectFrame(int id) {
    final index = state.currentFrames.indexWhere((frame) => frame.id == id);
    if (index < 0) return;

    state = state.copyWith(
      currentFrameIndex: index,
      currentLayerIndex: 0,
    );
  }

  void nextFrame() {
    var index = (state.currentFrameIndex + 1) % state.frames.length;
    state = state.copyWith(currentFrameIndex: index, currentLayerIndex: 0);
  }

  void prevFrame() {
    var index = (state.currentFrameIndex - 1 + state.frames.length) % state.frames.length;
    state = state.copyWith(currentFrameIndex: index, currentLayerIndex: 0);
  }

  void addFrame(
    String name, {
    int? copyFrame,
    int? stateId,
  }) async {
    ref.read(analyticsProvider).logEvent(name: 'add_frame');

    final layers = copyFrame != null
        ? state.frames.firstWhere((frame) => frame.id == copyFrame).layers.indexed.map((layer) {
            return layer.$2.copyWith(
              id: const Uuid().v4(),
              layerId: 0,
              pixels: Uint32List.fromList(layer.$2.pixels),
              order: layer.$1,
            );
          }).toList()
        : [
            Layer(
              layerId: 0,
              id: const Uuid().v4(),
              name: name,
              pixels: Uint32List(width * height),
            )
          ];

    final newFrame = AnimationFrame(
      id: 0,
      name: name,
      stateId: stateId ?? state.currentAnimationState.id,
      createdAt: DateTime.now(),
      editedAt: DateTime.now(),
      duration: 100,
      layers: layers,
      order: state.frames.map((frame) => frame.order).reduce(max) + 1,
    );

    final frame = await ref.read(projectRepo).createFrame(project.id, newFrame);

    state = state.copyWith(
      frames: [...state.frames, frame],
      currentFrameIndex: state.currentFrames.length,
      currentLayerIndex: 0,
    );
  }

  void reorderFrames(int oldIndex, int newIndex) {
    final frames = List<AnimationFrame>.from(state.frames);
    final frame = frames.removeAt(oldIndex);
    frames.insert(newIndex, frame);

    state = state.copyWith(
      frames: frames,
      currentFrameIndex: oldIndex == state.currentFrameIndex ? newIndex : state.currentFrameIndex,
    );

    _updateProject();
  }

  void updateFrame(int index, AnimationFrame frame) async {
    await ref.read(projectRepo).updateFrame(project.id, frame);

    state = state.copyWith(
      frames: List<AnimationFrame>.from(state.frames)..[index] = frame,
    );
  }

  void removeFrame(int index) {
    if (state.frames.length <= 1) return;
    ref.read(analyticsProvider).logEvent(name: 'delete_frame');

    final frame = state.frames[index];
    final frames = List<AnimationFrame>.from(state.frames)..removeAt(index);

    // Calculate the new frame index
    int newFrameIndex;
    if (index == state.currentFrameIndex) {
      // We're deleting the current frame, select the previous frame or the first one
      newFrameIndex = (index > 0) ? index - 1 : 0;
    } else if (index < state.currentFrameIndex) {
      // We're deleting a frame before the current one, adjust the index
      newFrameIndex = state.currentFrameIndex - 1;
    } else {
      // We're deleting a frame after the current one, keep the same index
      newFrameIndex = state.currentFrameIndex;
    }

    // Get the frames for the current animation state
    final currentStateFrames = frames.where((f) => f.stateId == state.currentAnimationState.id).toList();

    // Make sure the new frame index is valid
    if (currentStateFrames.isEmpty) {
      // No frames left for this state
      newFrameIndex = 0;
    } else if (newFrameIndex >= currentStateFrames.length) {
      // Index out of bounds, use the last frame
      newFrameIndex = currentStateFrames.length - 1;
    }

    state = state.copyWith(
      frames: frames.mapIndexed((i, frame) {
        return frame.copyWith(order: i);
      }).toList(),
      currentFrameIndex: newFrameIndex,
      currentLayerIndex: 0,
    );

    ref.read(projectRepo).deleteFrame(frame.id);
  }

  // --- Layer Effects ---

  // Add a layer effect
  void addLayerEffect(Effect effect) async {
    saveState();

    final layers = List<Layer>.from(currentFrame.layers);
    final currentLayer = layers[state.currentLayerIndex];

    // Add the effect to the layer
    final updatedEffects = List<Effect>.from(currentLayer.effects)..add(effect);
    layers[state.currentLayerIndex] = currentLayer.copyWith(effects: updatedEffects);

    // Update frame layers
    final frames = List<AnimationFrame>.from(state.frames);
    final updatedFrame = currentFrame.copyWith(layers: layers);
    frames[_getFrameIndex()] = updatedFrame;

    state = state.copyWith(frames: frames);

    _updateCurrentLayer(currentLayer.pixels);
    _updateProject();
  }

  // Update a layer effect
  void updateLayerEffect(int effectIndex, Effect updatedEffect) async {
    saveState();

    final layers = List<Layer>.from(currentFrame.layers);
    final currentLayer = layers[state.currentLayerIndex];

    // Replace the effect at the specified index
    final updatedEffects = List<Effect>.from(currentLayer.effects);
    updatedEffects[effectIndex] = updatedEffect;

    layers[state.currentLayerIndex] = currentLayer.copyWith(effects: updatedEffects);

    // Update frame layers
    final frames = List<AnimationFrame>.from(state.frames);
    final updatedFrame = currentFrame.copyWith(layers: layers);
    frames[_getFrameIndex()] = updatedFrame;

    state = state.copyWith(frames: frames);

    _updateCurrentLayer(currentLayer.pixels);
    _updateProject();
  }

  // Remove a layer effect
  void removeLayerEffect(int effectIndex) async {
    saveState();

    final layers = List<Layer>.from(currentFrame.layers);
    final currentLayer = layers[state.currentLayerIndex];

    // Remove the effect at the specified index
    final updatedEffects = List<Effect>.from(currentLayer.effects);
    updatedEffects.removeAt(effectIndex);

    layers[state.currentLayerIndex] = currentLayer.copyWith(effects: updatedEffects);

    // Update frame layers
    final frames = List<AnimationFrame>.from(state.frames);
    final updatedFrame = currentFrame.copyWith(layers: layers);
    frames[_getFrameIndex()] = updatedFrame;

    state = state.copyWith(frames: frames);

    _updateCurrentLayer(currentLayer.pixels);
    _updateProject();
  }

  // Clear all effects from the current layer
  void clearLayerEffects() async {
    saveState();

    final layers = List<Layer>.from(currentFrame.layers);
    final currentLayer = layers[state.currentLayerIndex];

    // Clear all effects
    layers[state.currentLayerIndex] = currentLayer.copyWith(effects: []);

    // Update frame layers
    final frames = List<AnimationFrame>.from(state.frames);
    final updatedFrame = currentFrame.copyWith(layers: layers);
    frames[_getFrameIndex()] = updatedFrame;

    state = state.copyWith(frames: frames);

    _updateCurrentLayer(currentLayer.pixels);
    _updateProject();
  }

  // --- End Layer Effects ---

  void exportJson(BuildContext context) {
    ref.read(analyticsProvider).logEvent(name: 'export_json');

    final json = project.toJson();
    final jsonString = jsonEncode(json);
    FileUtils(context).save('${project.name}.pxv', jsonString);
  }

  void importImage(BuildContext context, {bool background = false}) async {
    ref.read(analyticsProvider).logEvent(name: 'import_image');

    // Let user pick an image file and decode it to img.Image
    final img.Image? picked = await FileUtils(context).pickImageFile();
    if (picked == null) return;

    if (background) {
      ref.read(backgroundImageProvider.notifier).update((state) {
        return state.copyWith(
          image: Uint8List.fromList(img.encodePng(picked)),
        );
      });
      return;
    }

    // Resize to canvas size if needed
    img.Image resized = picked;
    if (picked.width != width || picked.height != height) {
      resized = img.copyResize(
        picked,
        width: width,
        height: height,
        interpolation: img.Interpolation.cubic,
      );
    }

    // Convert to pixel art layer
    final pixels = Uint32List(width * height);
    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final p = resized.getPixel(x, y);

        final a = p.a.toInt();
        final r = p.r.toInt();
        final g = p.g.toInt();
        final b = p.b.toInt();
        final colorVal = (a << 24) | (r << 16) | (g << 8) | b;
        // Treat non-opaque pixels as transparent
        pixels[y * width + x] = (a == 255) ? colorVal : Colors.transparent.value;
      }
    }

    // Create a new layer with imported pixels
    final newLayer = Layer(
      layerId: 0,
      id: const Uuid().v4(),
      name: 'Imported Image',
      pixels: pixels,
      isVisible: true,
    );
    final layer = await ref.watch(projectRepo).createLayer(project.id, currentFrame.id, newLayer);

    // Add layer to state and select it
    state = state.copyWith(
      frames: state.frames.map((frame) {
        if (frame.id == currentFrame.id) {
          return frame.copyWith(layers: [...frame.layers, layer]);
        }
        return frame;
      }).toList(),
      currentLayerIndex: currentFrame.layers.length,
    );

    // Persist project update
    _updateProject();
  }

  Future<void> share(BuildContext context) async {
    ref.read(analyticsProvider).logEvent(name: 'share_project');

    final pixels = Uint32List(project.width * project.height);
    for (final layer in state.currentFrame.layers.where(
      (layer) => layer.isVisible,
    )) {
      for (int i = 0; i < pixels.length; i++) {
        pixels[i] = pixels[i] == 0 ? layer.pixels[i] : pixels[i];
      }
    }

    Share.shareXFiles(
      [
        XFile.fromData(
          ImageHelper.convertToBytes(pixels),
          name: '${project.name}.png',
          mimeType: 'image/png',
        ),
      ],
    );
  }

  void exportImage(
    BuildContext context, {
    bool background = false,
    double? exportWidth,
    double? exportHeight,
  }) async {
    ref.read(analyticsProvider).logEvent(name: 'export_image');

    final pixels = PixelUtils.mergeLayersPixels(
      width: state.width,
      height: state.height,
      layers: state.currentFrame.layers,
    );

    if (background) {
      for (int i = 0; i < pixels.length; i++) {
        if (pixels[i] == 0) {
          pixels[i] = Colors.white.value;
        }
      }
    }
    await FileUtils(context).save32Bit(
      pixels,
      state.width,
      state.height,
      exportWidth: exportWidth,
      exportHeight: exportHeight,
    );
  }

  void exportAnimation(
    BuildContext context, {
    bool background = false,
    double? exportWidth,
    double? exportHeight,
  }) async {
    ref.read(analyticsProvider).logEvent(name: 'export_animation');

    final images = <img.Image>[];

    for (final frame in state.currentFrames) {
      final pixels = PixelUtils.mergeLayersPixels(
        width: state.width,
        height: state.height,
        layers: frame.layers,
      );

      // Uint32List(state.width * state.height);
      // for (final layer in frame.layers.where((layer) => layer.isVisible)) {
      //   for (int i = 0; i < pixels.length; i++) {
      //     pixels[i] = pixels[i] == 0 ? layer.pixels[i] : pixels[i];
      //   }
      // }

      final im = img.Image(
        width: width,
        height: height,
        numChannels: 4,
      );

      for (int y = 0; y < height; y++) {
        for (int x = 0; x < width; x++) {
          final pixel = pixels[y * width + x];

          // Extract ARGB channels from 32-bit color
          final a = (pixel >> 24) & 0xFF;
          final r = (pixel >> 16) & 0xFF;
          final g = (pixel >> 8) & 0xFF;
          final b = pixel & 0xFF;

          if (a == 0 && background) {
            im.setPixelRgba(x, y, 255, 255, 255, 0);
          } else {
            im.setPixelRgba(x, y, r, g, b, a);
          }
        }
      }

      if (exportWidth != null && exportHeight != null) {
        images.add(img.copyResize(
          im,
          width: exportWidth.toInt(),
          height: exportHeight.toInt(),
        ));
      } else {
        images.add(im);
      }
    }
    final gifEncoder = img.GifEncoder(
      samplingFactor: 1,
      quantizerType: img.QuantizerType.octree,
      ditherSerpentine: true,
    );
    for (var i = 0; i < images.length; i++) {
      gifEncoder.addFrame(
        images[i],
        duration: state.currentFrames[i].duration ~/ 10,
      );
    }

    final gifData = gifEncoder.finish();

    await FileUtils(context).saveImage(gifData!, '${project.name}.gif');
  }

  Future<void> exportSpriteSheet(
    BuildContext context, {
    required int columns,
    required int spacing,
    required bool includeAllFrames,
    bool withBackground = false,
    Color backgroundColor = Colors.white,
    double? exportWidth,
    double? exportHeight,
  }) async {
    ref.read(analyticsProvider).logEvent(name: 'export_sprite_sheet');

    // Calculate sprite sheet dimensions
    final frames = includeAllFrames ? state.currentFrames : [state.currentFrame];
    final rows = (frames.length / columns).ceil();

    // Calculate total dimensions including spacing
    final totalWidth = (width * columns) + (spacing * (columns - 1));
    final totalHeight = (height * rows) + (spacing * (rows - 1));

    // Create sprite sheet image
    var spriteSheet = img.Image(
      width: totalWidth,
      height: totalHeight,
      numChannels: 4,
    );

    // Fill background if needed
    if (withBackground) {
      for (int y = 0; y < totalHeight; y++) {
        for (int x = 0; x < totalWidth; x++) {
          spriteSheet.setPixelRgba(
            x,
            y,
            backgroundColor.red,
            backgroundColor.green,
            backgroundColor.blue,
            backgroundColor.alpha,
          );
        }
      }
    }

    // Draw each frame onto the sprite sheet
    for (int i = 0; i < frames.length; i++) {
      final frame = frames[i];
      final row = i ~/ columns;
      final col = i % columns;

      // Calculate position for this frame
      final xOffset = col * (width + spacing);
      final yOffset = row * (height + spacing);

      // Merge layers for this frame
      final framePixels = Uint32List(width * height);
      for (final layer in frame.layers.where((layer) => layer.isVisible)) {
        final layerPixels = layer.processedPixels;
        for (int p = 0; p < framePixels.length; p++) {
          if (layerPixels[p] != 0) {
            framePixels[p] = layerPixels[p];
          }
        }
      }

      // Draw frame pixels onto sprite sheet
      for (int y = 0; y < height; y++) {
        for (int x = 0; x < width; x++) {
          final pixel = framePixels[y * width + x];

          // Skip transparent pixels if we're using a background
          if (pixel == 0 && withBackground) continue;

          // Extract ARGB channels
          final a = (pixel >> 24) & 0xFF;
          final r = (pixel >> 16) & 0xFF;
          final g = (pixel >> 8) & 0xFF;
          final b = pixel & 0xFF;

          // Set pixel in sprite sheet
          if (a > 0) {
            spriteSheet.setPixelRgba(
              x + xOffset,
              y + yOffset,
              r,
              g,
              b,
              a,
            );
          }
        }
      }
    }

    // Draw grid lines if spacing > 0
    if (spacing > 0) {
      final gridColor = withBackground
          ? Color.lerp(backgroundColor, backgroundColor.computeLuminance() > 0.5 ? Colors.black : Colors.white, 0.1)!
          : Colors.black.withOpacity(0.1);

      // Draw vertical grid lines
      for (int col = 1; col < columns; col++) {
        final x = (col * width) + ((col - 1) * spacing);
        for (int s = 0; s < spacing; s++) {
          for (int y = 0; y < totalHeight; y++) {
            spriteSheet.setPixelRgba(
              x + s,
              y,
              gridColor.red,
              gridColor.green,
              gridColor.blue,
              gridColor.alpha,
            );
          }
        }
      }

      // Draw horizontal grid lines
      for (int row = 1; row < rows; row++) {
        final y = (row * height) + ((row - 1) * spacing);
        for (int s = 0; s < spacing; s++) {
          for (int x = 0; x < totalWidth; x++) {
            spriteSheet.setPixelRgba(
              x,
              y + s,
              gridColor.red,
              gridColor.green,
              gridColor.blue,
              gridColor.alpha,
            );
          }
        }
      }
    }

    if (exportWidth != null && exportHeight != null) {
      final resizedTotalWidth = (exportWidth * columns) + (spacing * (columns - 1));
      final resizedTotalHeight = (exportHeight * rows) + (spacing * (rows - 1));

      spriteSheet = img.copyResize(
        spriteSheet,
        width: resizedTotalWidth.toInt(),
        height: resizedTotalHeight.toInt(),
      );
    }

    // Generate metadata for the sprite sheet
    final metadata = {
      'version': '1.0',
      'frames': frames.length,
      'columns': columns,
      'frameWidth': width,
      'frameHeight': height,
      'spacing': spacing,
      'frameData': frames
          .map((frame) => {
                'name': frame.name,
                'duration': frame.duration,
              })
          .toList(),
    };

    // Save sprite sheet image
    final pngData = img.encodePng(spriteSheet);
    await FileUtils(context).saveImage(
      pngData,
      '${project.name}_sprite_sheet.png',
    );

    // Save metadata
    // final jsonData = jsonEncode(metadata);
    // await FileUtils(context).save(
    //   '${project.name}_sprite_sheet.json',
    //   jsonData,
    // );

    // Show success message
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sprite sheet exported successfully'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

// Optional: Helper method to create preview image of sprite sheet
  Future<ui.Image?> createSpriteSheetPreview({
    required int columns,
    required int spacing,
    required bool includeAllFrames,
    bool withBackground = false,
    Color backgroundColor = Colors.white,
  }) async {
    final frames = includeAllFrames ? state.currentFrames : [state.currentFrame];
    final rows = (frames.length / columns).ceil();

    final totalWidth = (width * columns) + (spacing * (columns - 1));
    final totalHeight = (height * rows) + (spacing * (rows - 1));

    // Create image data
    final pixels = Uint32List(totalWidth * totalHeight);

    // Fill background
    if (withBackground) {
      pixels.fillRange(0, pixels.length, backgroundColor.value);
    }

    // Add each frame
    for (int i = 0; i < frames.length; i++) {
      final frame = frames[i];
      final row = i ~/ columns;
      final col = i % columns;

      final xOffset = col * (width + spacing);
      final yOffset = row * (height + spacing);

      // Merge frame layers
      final framePixels = frame.pixels;

      // Copy frame pixels to sprite sheet
      for (int y = 0; y < height; y++) {
        for (int x = 0; x < width; x++) {
          final sourceIndex = y * width + x;
          final targetIndex = (y + yOffset) * totalWidth + (x + xOffset);

          if (framePixels[sourceIndex] != 0) {
            pixels[targetIndex] = framePixels[sourceIndex];
          }
        }
      }
    }

    // Create image from pixels
    return ImageHelper.createImageFromPixels(
      pixels,
      totalWidth,
      totalHeight,
    );
  }
}
