import 'dart:collection';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import '../core/utils.dart';
import '../core/tools.dart';
import '../data.dart';
import 'providers.dart';

part 'pixel_controller_provider.g.dart';

class PixelDrawState extends Equatable {
  final int width;
  final int height;
  final List<Layer> layers;
  final int currentLayerIndex;
  final Color currentColor;
  final PixelTool currentTool;
  final MirrorAxis mirrorAxis;
  final SelectionModel? selectionRect;
  final bool canUndo;
  final bool canRedo;

  const PixelDrawState({
    required this.width,
    required this.height,
    required this.layers,
    this.currentLayerIndex = 0,
    required this.currentColor,
    required this.currentTool,
    required this.mirrorAxis,
    required this.selectionRect,
    this.canUndo = false,
    this.canRedo = false,
  });

  List<Uint32List> get pixels => layers.fold(
        [],
        (List<Uint32List> acc, layer) {
          acc.add(layer.pixels);
          return acc;
        },
      );

  PixelDrawState copyWith({
    int? width,
    int? height,
    List<Layer>? layers,
    int? currentLayerIndex,
    Color? currentColor,
    PixelTool? currentTool,
    MirrorAxis? mirrorAxis,
    bool? canUndo,
    bool? canRedo,
    SelectionModel? selectionRect,
    List<List<Color>>? undoStack,
    List<List<Color>>? redoStack,
  }) {
    return PixelDrawState(
      width: width ?? this.width,
      height: height ?? this.height,
      layers: layers ?? this.layers,
      currentLayerIndex: currentLayerIndex ?? this.currentLayerIndex,
      currentColor: currentColor ?? this.currentColor,
      currentTool: currentTool ?? this.currentTool,
      mirrorAxis: mirrorAxis ?? this.mirrorAxis,
      selectionRect: selectionRect ?? this.selectionRect,
      canUndo: canUndo ?? this.canUndo,
      canRedo: canRedo ?? this.canRedo,
    );
  }

  @override
  List<Object?> get props => [
        width,
        height,
        layers,
        currentColor,
        currentTool,
        mirrorAxis,
        selectionRect,
        canUndo,
        canRedo,
        currentLayerIndex,
      ];
}

@riverpod
class PixelDrawNotifier extends _$PixelDrawNotifier {
  PixelTool get currentTool => state.currentTool;
  set currentTool(PixelTool tool) => state = state.copyWith(currentTool: tool);
  MirrorAxis get mirrorAxis => state.mirrorAxis;
  Color get currentColor => state.currentColor;
  set currentColor(Color color) => state = state.copyWith(currentColor: color);

  Layer get currentLayer => state.layers[state.currentLayerIndex];
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
      layers: project.layers.isNotEmpty
          ? project.layers
          : [
              Layer(
                layerId: 0,
                id: const Uuid().v4(),
                name: 'Layer 1',
                pixels: Uint32List(project.width * project.height),
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

    final layer =
        await ref.watch(projectRepo).createLayer(project.id, newLayer);

    state = state.copyWith(
      layers: [...state.layers, layer],
      currentLayerIndex: state.layers.length,
    );
  }

  void removeLayer(int index) {
    if (state.layers.length <= 1) return;
    final layer = state.layers[index];
    final layers = List<Layer>.from(state.layers)..removeAt(index);
    int newIndex = state.currentLayerIndex;
    if (newIndex >= layers.length) {
      newIndex = layers.length - 1;
    }
    state = state.copyWith(
      layers: layers,
      currentLayerIndex: newIndex,
    );

    ref.watch(projectRepo).deleteLayer(layer.layerId);
  }

  void selectLayer(int index) {
    if (index < 0 || index >= state.layers.length) return;
    state = state.copyWith(currentLayerIndex: index);
  }

  void toggleLayerVisibility(int index) {
    final layers = List<Layer>.from(state.layers);
    final layer = layers[index];
    layers[index] = layer.copyWith(isVisible: !layer.isVisible);
    state = state.copyWith(layers: layers);

    ref.watch(projectRepo).updateLayer(project.id, layers[index]);
  }

  void reorderLayers(int oldIndex, int newIndex) {
    final layers = List<Layer>.from(state.layers);
    final layer = layers.removeAt(oldIndex);
    layers.insert(newIndex, layer);
    state = state.copyWith(layers: layers);

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

    if (currentTool == PixelTool.mirror) {
      _applyMirror(pixels, x, y);
    }

    if (_selectionRect != null) {
      _selectedPixels.add(MapEntry(Point(x, y), currentColor.value));
    }

    _updateCurrentLayer(pixels);
  }

  void _applyMirror(Uint32List pixels, int x, int y) {
    switch (mirrorAxis) {
      case MirrorAxis.horizontal:
        final mirroredY = height - 1 - y;
        if (_isWithinBounds(x, mirroredY)) {
          pixels[mirroredY * width + x] = currentColor.value;
        }
        break;
      case MirrorAxis.vertical:
        final mirroredX = width - 1 - x;
        if (_isWithinBounds(mirroredX, y)) {
          pixels[y * width + mirroredX] = currentColor.value;
        }
        break;
      case MirrorAxis.both:
        _applyMirror(pixels, x, y);
        _applyMirror(pixels, x, y);
        break;
    }
  }

  void fillPixels(List<Point<int>> pixels) {
    saveState();
    final newPixels = Uint32List.fromList(currentLayer.pixels);
    final color = currentTool == PixelTool.eraser
        ? Colors.transparent.value
        : currentColor.value;

    for (final point in pixels) {
      int index = point.y * state.width + point.x;
      if (index >= 0 && index < newPixels.length) {
        newPixels[index] = color;
      }
    }

    _updateCurrentLayer(Uint32List.fromList(newPixels));
  }

  void fill(int x, int y) {
    if (!_isWithinBounds(x, y)) return;

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
    final layers = List<Layer>.from(state.layers);
    layers[state.currentLayerIndex] = currentLayer.copyWith(pixels: pixels);
    state = state.copyWith(layers: layers);

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
      layers: [
        ...state.layers.sublist(0, state.currentLayerIndex),
        currentLayer.copyWith(pixels: newPixels),
        ...state.layers.sublist(state.currentLayerIndex + 1),
      ],
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
    _selectionRect = selection;
    _originalSelectionRect = selection;
    if (selection != null) {
      _selectedPixels = _getSelectedPixels(selection);
      _cachedPixels = currentLayer.pixels;
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
        pixels[newY * width + newX] = entry.value == Colors.transparent
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
            layers: state.layers,
            editedAt: DateTime.now(),
          ),
        );
  }

  void exportImage(BuildContext context) async {
    final pixels = Uint32List(project.width * project.height);
    for (final layer in project.layers.where((layer) => layer.isVisible)) {
      for (int i = 0; i < pixels.length; i++) {
        pixels[i] = pixels[i] == 0 ? layer.pixels[i] : pixels[i];
      }
    }
    await FileUtils(context).save32Bit(pixels, project.width, project.height);
  }

  void exportJson(BuildContext context) {
    final json = project.toJson();
    final jsonString = jsonEncode(json);
    FileUtils(context).save('${project.name}.pv', jsonString);
  }
}
