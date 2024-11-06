import 'dart:collection';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:image/image.dart' as img;
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:share_plus/share_plus.dart';
import 'package:uuid/uuid.dart';

import '../core/utils.dart';
import '../pixel/tools.dart';
import '../data.dart';
import 'providers.dart';

part 'pixel_controller_provider.freezed.dart';
part 'pixel_controller_provider.g.dart';

extension ListX<T> on List<T> {
  List<T> mapIndexed(T Function(int index, T item) f) {
    return asMap().entries.map((e) => f(e.key, e.value)).toList();
  }
}

@freezed
class PixelDrawState with _$PixelDrawState {
  const PixelDrawState._();
  const factory PixelDrawState({
    required final int width,
    required final int height,
    required final List<AnimationFrame> frames,
    @Default(0) final int currentFrameIndex,
    @Default(0) final int currentLayerIndex,
    required final Color currentColor,
    required final PixelTool currentTool,
    required final MirrorAxis mirrorAxis,
    final SelectionModel? selectionRect,
    @Default(false) final bool canUndo,
    @Default(false) final bool canRedo,
  }) = _PixelDrawState;

  AnimationFrame get currentFrame => frames[currentFrameIndex];
  Layer get currentLayer => currentFrame.layers[currentLayerIndex];
  List<Layer> get layers => currentFrame.layers;

  List<Uint32List> get pixels => currentFrame.layers.fold(
        [],
        (List<Uint32List> acc, layer) {
          acc.add(layer.pixels);
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

  @override
  PixelDrawState build(Project project) {
    return PixelDrawState(
      width: project.width,
      height: project.height,
      frames: project.frames.isNotEmpty
          ? project.frames
          : [
              AnimationFrame(
                id: 0,
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

  void addLayer(String name) async {
    final newLayer = Layer(
      layerId: 0,
      id: const Uuid().v4(),
      name: name,
      pixels: Uint32List(width * height),
    );

    ref.read(analyticsProvider).logEvent(name: 'add_layer');

    final layer = await ref
        .watch(projectRepo)
        .createLayer(project.id, state.currentFrame.id, newLayer);

    final frames = List<AnimationFrame>.from(state.frames);
    final layers = List<Layer>.from(currentFrame.layers)..add(layer);
    final updatedFrame = currentFrame.copyWith(layers: layers);

    frames[state.currentFrameIndex] = updatedFrame;

    state = state.copyWith(
      frames: frames,
      currentLayerIndex: layers.length - 1,
    );
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
    final updatedFrame =
        currentFrame.copyWith(layers: layers.mapIndexed((i, layer) {
      return layer.copyWith(order: i);
    }));
    frames[state.currentFrameIndex] = updatedFrame;

    state = state.copyWith(
      frames: frames,
      currentLayerIndex: newLayerIndex,
    );

    ref.watch(projectRepo).deleteLayer(layer.layerId);
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

    final frames = List<AnimationFrame>.from(state.frames);
    final updatedFrame = currentFrame.copyWith(layers: layers);
    frames[state.currentFrameIndex] = updatedFrame;

    state = state.copyWith(frames: frames);

    ref
        .watch(projectRepo)
        .updateLayer(project.id, currentFrame.id, layers[index]);
  }

  void reorderLayers(int oldIndex, int newIndex) {
    ref.read(analyticsProvider).logEvent(name: 'reorder_layers');

    final layers = List<Layer>.from(currentFrame.layers);
    final layer = layers.removeAt(oldIndex);
    layers.insert(newIndex, layer);

    state = state.copyWith(
      frames: List<AnimationFrame>.from(state.frames)
        ..[state.currentFrameIndex] =
            currentFrame.copyWith(layers: layers.mapIndexed((i, layer) {
          return layer.copyWith(order: i);
        })),
      currentLayerIndex: oldIndex == state.currentLayerIndex
          ? newIndex
          : state.currentLayerIndex,
    );

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

  void _applyMirror(Uint32List pixels, int x, int y) {
    final color = currentTool == PixelTool.eraser
        ? Colors.transparent.value
        : currentColor.value;
    switch (mirrorAxis) {
      case MirrorAxis.horizontal:
        final mirroredY = height - 1 - y;
        if (_isWithinBounds(x, mirroredY)) {
          pixels[mirroredY * width + x] = color;
        }
        break;
      case MirrorAxis.vertical:
        final mirroredX = width - 1 - x;
        if (_isWithinBounds(mirroredX, y)) {
          pixels[y * width + mirroredX] = color;
        }
        break;
      case MirrorAxis.both:
        _applyMirror(pixels, x, y);
        _applyMirror(pixels, x, y);
        break;
    }
  }

  void fillPixels(List<Point<int>> pixels, PixelModifier modifier) {
    saveState();
    final newPixels = Uint32List.fromList(currentLayer.pixels);
    final color = currentTool == PixelTool.eraser
        ? Colors.transparent.value
        : currentColor.value;

    for (final point in pixels) {
      int index = point.y * state.width + point.x;
      if (index >= 0 && index < newPixels.length) {
        newPixels[index] = color;

        if (modifier == PixelModifier.mirror) {
          _applyMirror(newPixels, point.x, point.y);
        }
      }
    }

    _updateCurrentLayer(Uint32List.fromList(newPixels));
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

  void _updateCurrentLayer(Uint32List pixels) {
    final layers = List<Layer>.from(currentFrame.layers);
    layers[state.currentLayerIndex] = currentLayer.copyWith(pixels: pixels);

    state = state.copyWith(
      frames: List<AnimationFrame>.from(state.frames)
        ..[state.currentFrameIndex] = currentFrame.copyWith(layers: layers),
    );

    _updateProject();
  }

  void drawShape(List<Point<int>> points) {
    saveState();
    final pixels = Uint32List.fromList(currentLayer.pixels);
    final fillColor = currentTool == PixelTool.eraser
        ? Colors.transparent.value
        : currentColor.value;

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
    final pixels = currentLayer.pixels;

    // Clear the pixels at the old positions
    for (final entry in _selectedPixels) {
      final x = entry.key.x;
      final y = entry.key.y;
      if (x >= 0 && x < width && y >= 0 && y < height) {
        final p = y * width + x;
        pixels[p] =
            _originalSelectionRect != null && !_isPointInOriginalSelection(x, y)
                ? _cachedPixels[p]
                : Colors.transparent.value;
      }
    }

    // Update the positions of selected pixels and apply them to the canvas
    for (final entry in _selectedPixels) {
      final newX = entry.key.x + dx;
      final newY = entry.key.y + dy;
      if (newX >= 0 && newX < width && newY >= 0 && newY < height) {
        pixels[newY * width + newX] = entry.value == Colors.transparent.value
            ? pixels[newY * width + newX]
            : entry.value;
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

  void _updateProject() async {
    ref.watch(projectRepo).updateProject(
          project.copyWith(
            frames: state.frames,
            editedAt: DateTime.now(),
          ),
        );
  }

  void selectFrame(int index) {
    if (index < 0 || index >= state.frames.length) return;

    state = state.copyWith(
      currentFrameIndex: index,
    );
  }

  void nextFrame() {
    var index = state.currentFrameIndex + 1 % state.frames.length;
    state = state.copyWith(currentFrameIndex: index);
  }

  void prevFrame() {
    var index = state.currentFrameIndex - 1 % state.frames.length;
    state = state.copyWith(currentFrameIndex: index);
  }

  void addFrame(
    String name, {
    int? copyFrame,
  }) async {
    ref.read(analyticsProvider).logEvent(name: 'add_frame');

    final layers = copyFrame != null
        ? state.frames[copyFrame].layers.indexed.map((layer) {
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
      createdAt: DateTime.now(),
      editedAt: DateTime.now(),
      duration: 100,
      layers: layers,
      order: state.frames.map((frame) => frame.order).reduce(max) + 1,
    );

    final frame =
        await ref.watch(projectRepo).createFrame(project.id, newFrame);

    state = state.copyWith(
      frames: [...state.frames, frame],
      currentFrameIndex: state.frames.length,
      currentLayerIndex: 0,
    );
  }

  void reorderFrames(int oldIndex, int newIndex) {
    final frames = List<AnimationFrame>.from(state.frames);
    final frame = frames.removeAt(oldIndex);
    frames.insert(newIndex, frame);

    state = state.copyWith(
      frames: frames,
      currentFrameIndex: oldIndex == state.currentFrameIndex
          ? newIndex
          : state.currentFrameIndex,
    );

    _updateProject();
  }

  void updateFrame(int index, AnimationFrame frame) async {
    await ref.watch(projectRepo).updateFrame(project.id, frame);

    state = state.copyWith(
      frames: List<AnimationFrame>.from(state.frames)..[index] = frame,
    );
  }

  void removeFrame(int index) {
    if (state.frames.length <= 1) return;
    ref.read(analyticsProvider).logEvent(name: 'delete_frame');

    final frame = state.frames[index];
    final frames = List<AnimationFrame>.from(state.frames)..removeAt(index);

    int newFrameIndex = state.currentFrameIndex;
    if (newFrameIndex >= frames.length) {
      newFrameIndex = frames.length - 1;
    }

    state = state.copyWith(
      frames: frames.mapIndexed((i, frame) {
        return frame.copyWith(order: i);
      }),
      currentFrameIndex: newFrameIndex,
      currentLayerIndex: 0,
    );

    ref.watch(projectRepo).deleteFrame(frame.id);
  }

  void exportImage(
    BuildContext context, {
    bool background = false,
  }) async {
    ref.read(analyticsProvider).logEvent(name: 'export_image');

    final pixels = Uint32List(state.width * state.height);

    for (final layer in currentFrame.layers.where((layer) => layer.isVisible)) {
      for (int i = 0; i < pixels.length; i++) {
        pixels[i] = pixels[i] == 0 ? layer.pixels[i] : pixels[i];
      }
    }
    if (background) {
      for (int i = 0; i < pixels.length; i++) {
        if (pixels[i] == 0) {
          pixels[i] = Colors.white.value;
        }
      }
    }
    await FileUtils(context).save32Bit(pixels, state.width, state.height);
  }

  void exportJson(BuildContext context) {
    ref.read(analyticsProvider).logEvent(name: 'export_json');

    final json = project.toJson();
    final jsonString = jsonEncode(json);
    FileUtils(context).save('${project.name}.pxv', jsonString);
  }

  void importImage(BuildContext context) async {
    ref.read(analyticsProvider).logEvent(name: 'import_image');

    final image = await FileUtils(context).pickImageFile();
    if (image != null) {
      img.Image resizedImage;
      if (image.width != width || image.height != height) {
        resizedImage = img.copyResize(
          image,
          width: width,
          height: height,
          // You can use different interpolation methods for different effects
          interpolation: img.Interpolation.average,
        );
      } else {
        resizedImage = image;
      }

      // Optionally, reduce the color palette to create a pixel art effect
      img.Image pixelArtImage = resizedImage;

      // Convert the image pixels to Uint32List
      final pixels = Uint32List(width * height);
      for (int y = 0; y < height; y++) {
        for (int x = 0; x < width; x++) {
          final pixel = pixelArtImage.getPixel(x, y);

          // Convert the pixel to ARGB format expected by Flutter
          final a = pixel.a.toInt();
          final r = pixel.r.toInt();
          final g = pixel.g.toInt();
          final b = pixel.b.toInt();

          final colorValue = (a << 24) | (r << 16) | (g << 8) | b;
          pixels[y * width + x] = colorValue;
        }
      }

      // Create a new layer with the imported image pixels
      final newLayer = Layer(
        layerId: 0,
        id: const Uuid().v4(),
        name: 'Imported Image',
        pixels: pixels,
        isVisible: true,
      );

      final layer = await ref
          .watch(projectRepo)
          .createLayer(project.id, currentFrame.id, newLayer);

      state = state.copyWith(
        frames: state.frames.map((frame) {
          if (frame.id == currentFrame.id) {
            return frame.copyWith(layers: [...frame.layers, layer]);
          }
          return frame;
        }).toList(),
        currentLayerIndex: currentFrame.layers.length,
      );

      // Update the project repository
      _updateProject();
    }
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

  void exportAnimation(
    BuildContext context, {
    bool background = false,
  }) async {
    ref.read(analyticsProvider).logEvent(name: 'export_animation');

    final images = <img.Image>[];

    for (final frame in state.frames) {
      final pixels = Uint32List(state.width * state.height);
      for (final layer in frame.layers.where((layer) => layer.isVisible)) {
        for (int i = 0; i < pixels.length; i++) {
          pixels[i] = pixels[i] == 0 ? layer.pixels[i] : pixels[i];
        }
      }

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

      images.add(im);
    }
    final gifEncoder = img.GifEncoder(
      samplingFactor: 1,
      quantizerType: img.QuantizerType.octree,
      ditherSerpentine: true,
    );
    for (var i = 0; i < images.length; i++) {
      gifEncoder.addFrame(
        images[i],
        duration: state.frames[i].duration ~/ 10,
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
  }) async {
    ref.read(analyticsProvider).logEvent(name: 'export_sprite_sheet');

    // Calculate sprite sheet dimensions
    final frames = includeAllFrames ? state.frames : [state.currentFrame];
    final rows = (frames.length / columns).ceil();

    // Calculate total dimensions including spacing
    final totalWidth = (width * columns) + (spacing * (columns - 1));
    final totalHeight = (height * rows) + (spacing * (rows - 1));

    // Create sprite sheet image
    final spriteSheet = img.Image(
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
        for (int p = 0; p < framePixels.length; p++) {
          if (layer.pixels[p] != 0) {
            framePixels[p] = layer.pixels[p];
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
          ? Color.lerp(
              backgroundColor,
              backgroundColor.computeLuminance() > 0.5
                  ? Colors.black
                  : Colors.white,
              0.1)!
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
    final jsonData = jsonEncode(metadata);
    await FileUtils(context).save(
      '${project.name}_sprite_sheet.json',
      jsonData,
    );

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
    final frames = includeAllFrames ? state.frames : [state.currentFrame];
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
