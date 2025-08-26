import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:universal_html/html.dart';

import '../../data/models/template.dart';
import '../pixel_point.dart';
import '../../data.dart';
import '../../providers/providers.dart';
import '../../providers/background_image_provider.dart';
import '../services/animation_service.dart';
import '../services/drawing_service.dart';
import '../services/frame_service.dart';
import '../services/import_export_service.dart';
import '../services/layer_service.dart';
import '../services/selection_service.dart';
import '../services/template_service.dart';
import '../services/undo_redo_service.dart';
import '../pixel_draw_state.dart';
import '../tools.dart';

part 'pixel_controller_provider.g.dart';

@riverpod
class PixelDrawController extends _$PixelDrawController {
  // Services
  late final LayerService _layerService;
  late final FrameService _frameService;
  late final AnimationService _animationService;
  late final DrawingService _drawingService;
  late final SelectionService _selectionService;
  late final UndoRedoService _undoRedoService;
  late final ImportExportService _importExportService;
  late final TemplateService _templateService;

  // Current project reference

  @override
  PixelDrawState build(Project project) {
    // Initialize services
    _layerService = LayerService(ref.read(projectRepo));
    _frameService = FrameService(ref.read(projectRepo));
    _animationService = AnimationService(ref.read(projectRepo));
    _drawingService = DrawingService();
    _selectionService = SelectionService(width: project.width, height: project.height);
    _undoRedoService = UndoRedoService();
    _importExportService = ImportExportService();
    _templateService = TemplateService();

    return PixelDrawState(
      width: project.width,
      height: project.height,
      animationStates: List<AnimationStateModel>.from(project.states),
      frames: project.frames.isNotEmpty ? List<AnimationFrame>.from(project.frames) : _createDefaultFrame(),
      currentColor: Colors.black,
      currentTool: PixelTool.pencil,
      mirrorAxis: MirrorAxis.vertical,
      selectionRect: null,
      canUndo: _undoRedoService.canUndo,
      canRedo: _undoRedoService.canRedo,
    );
  }

  List<AnimationFrame> _createDefaultFrame() {
    return [
      AnimationFrame(
        id: 0,
        stateId: 0,
        name: 'Frame 1',
        duration: 100,
        layers: [
          Layer(
            layerId: 0,
            id: 'default-layer',
            name: 'Layer 1',
            pixels: Uint32List(project.width * project.height),
            order: 0,
          ),
        ],
      ),
    ];
  }

  AnimationFrame get currentFrame => state.currentFrame;
  Layer get currentLayer => state.currentLayer;
  bool get canUndo => _undoRedoService.canUndo;
  bool get canRedo => _undoRedoService.canRedo;

  // State management
  void _saveState() {
    _undoRedoService.saveState(state);
    state = state.copyWith(canUndo: canUndo, canRedo: canRedo);
  }

  void _updateProject() {
    ref.read(projectRepo).updateProject(
          project.copyWith(
            frames: state.frames,
            states: state.animationStates,
            editedAt: DateTime.now(),
          ),
        );
  }

  // Drawing operations
  void setPixel(int x, int y) {
    _saveState();

    final modifier = _drawingService.createModifier(
      state.currentModifier,
      state.mirrorAxis,
    );

    final newPixels = _drawingService.setPixel(
      pixels: currentLayer.pixels,
      x: x,
      y: y,
      width: state.width,
      height: state.height,
      color: _getDrawingColor(),
      selection: state.selectionRect,
      modifier: modifier,
    );

    _updateCurrentLayerPixels(newPixels);
  }

  void fillPixels(List<PixelPoint<int>> points) {
    if (_selectionService.hasSelection && !_selectionService.isPointsInSelection(points)) {
      return;
    }
    _saveState();

    final newPixels = _drawingService.fillPixels(
      pixels: currentLayer.pixels,
      points: points,
      width: state.width,
      color: _getDrawingColor(),
      selection: state.selectionRect,
    );

    _updateCurrentLayerPixels(newPixels);
  }

  void floodFill(int x, int y) {
    _saveState();

    final newPixels = _drawingService.floodFill(
      pixels: currentLayer.pixels,
      x: x,
      y: y,
      width: state.width,
      height: state.height,
      fillColor: _getDrawingColor(),
      selection: state.selectionRect,
    );

    _updateCurrentLayerPixels(newPixels);
  }

  void clearCanvas() {
    _saveState();

    final newPixels = _drawingService.clearPixels(state.width, state.height);
    _updateCurrentLayerPixels(newPixels);
  }

  Color getPixelColor(int x, int y) {
    return _drawingService.getPixelColor(
      pixels: currentLayer.pixels,
      x: x,
      y: y,
      width: state.width,
      height: state.height,
    );
  }

  void applyGradient(List<Color> gradientColors) {
    _saveState();

    final newPixels = _drawingService.applyGradient(
      pixels: currentLayer.pixels,
      gradientColors: gradientColors,
    );

    _updateCurrentLayerPixels(newPixels);
  }

  // Drag operations
  Offset? _dragStartOffset;
  Uint32List? _originalPixels;

  void startDrag() {
    _saveState();
    _dragStartOffset = null;
    _originalPixels = null;
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

    // Use the drawing service to drag pixels
    final newPixels = _drawingService.dragPixels(
      originalPixels: _originalPixels!,
      currentPixels: currentLayer.pixels,
      width: state.width,
      height: state.height,
      deltaOffset: delta,
    );

    _updateCurrentLayerPixels(newPixels);
  }

  void endDrag() {
    _dragStartOffset = null;
    _originalPixels = null;
  }

  // Layer operations
  Future<void> addLayer(String name) async {
    final order = _layerService.calculateNextLayerOrder(currentFrame.layers);

    final newLayer = await _layerService.createLayer(
      projectId: project.id,
      frameId: currentFrame.id,
      name: name,
      width: state.width,
      height: state.height,
      order: order,
    );

    final updatedLayers = [...currentFrame.layers, newLayer]..sort((a, b) => a.order.compareTo(b.order));

    final updatedFrame = currentFrame.copyWith(layers: updatedLayers);
    _updateCurrentFrame(updatedFrame);

    state = state.copyWith(currentLayerIndex: updatedLayers.length - 1);
  }

  Future<void> removeLayer(int index) async {
    if (currentFrame.layers.length <= 1) return;

    final layerToRemove = currentFrame.layers[index];
    await _layerService.deleteLayer(layerToRemove.layerId);

    final updatedLayers = List<Layer>.from(currentFrame.layers)..removeAt(index);

    // Reorder remaining layers
    final reorderedLayers = updatedLayers.indexed.map((indexed) {
      final (i, layer) = indexed;
      return layer.copyWith(order: i);
    }).toList();

    final updatedFrame = currentFrame.copyWith(layers: reorderedLayers);
    _updateCurrentFrame(updatedFrame);

    // Adjust current layer index
    final newLayerIndex = index >= reorderedLayers.length ? reorderedLayers.length - 1 : index;

    state = state.copyWith(currentLayerIndex: newLayerIndex);
  }

  Future<int> duplicateLayer(int index) async {
    _saveState();
    final layerToDuplicate = currentFrame.layers[index];
    final insertIndex = index + 1;

    final newLayerData = await _layerService.createLayer(
      projectId: project.id,
      frameId: currentFrame.id,
      name: 'Copy of ${layerToDuplicate.name}',
      width: state.width,
      height: state.height,
      order: _layerService.calculateNextLayerOrder(currentFrame.layers),
    );

    final newLayerWithContent = newLayerData.copyWith(
      pixels: Uint32List.fromList(layerToDuplicate.pixels),
      isVisible: layerToDuplicate.isVisible,
    );

    final tempLayers = [...currentFrame.layers, newLayerWithContent];

    final reorderedLayers = _layerService.reorderLayers(
      tempLayers,
      tempLayers.length - 1,
      insertIndex,
    );

    final updatedFrame = currentFrame.copyWith(layers: reorderedLayers);
    _updateCurrentFrame(updatedFrame);

    state = state.copyWith(currentLayerIndex: insertIndex);
    _updateProject();

    return insertIndex;
  }

  void selectLayer(int index) {
    if (index < 0 || index >= currentFrame.layers.length) return;
    state = state.copyWith(currentLayerIndex: index);
  }

  Future<void> toggleLayerVisibility(int index) async {
    final layer = currentFrame.layers[index];
    final updatedLayer = _layerService.toggleLayerVisibility(layer);

    await _updateLayerAndFrame(index, updatedLayer);
  }

  Future<void> reorderLayers(int oldIndex, int newIndex) async {
    final reorderedLayers = _layerService.reorderLayers(
      currentFrame.layers,
      oldIndex,
      newIndex,
    );

    final updatedFrame = currentFrame.copyWith(layers: reorderedLayers);
    _updateCurrentFrame(updatedFrame);

    final newCurrentIndex = oldIndex == state.currentLayerIndex ? newIndex : state.currentLayerIndex;

    state = state.copyWith(currentLayerIndex: newCurrentIndex);
    _updateProject();
  }

  void updateLayer(Layer updatedLayer) {
    final layerIndex = currentFrame.layers.indexWhere(
      (layer) => layer.layerId == updatedLayer.layerId,
    );

    if (layerIndex != -1) {
      final updatedLayers = List<Layer>.from(currentFrame.layers);
      updatedLayers[layerIndex] = updatedLayer;

      final updatedFrame = currentFrame.copyWith(layers: updatedLayers);
      _updateCurrentFrame(updatedFrame);
      _updateProject();
    }
  }

  // Frame operations
  Future<void> addFrame(String name, {int? copyFrameId, int? stateId}) async {
    final copyFrame = copyFrameId != null ? state.frames.firstWhere((f) => f.id == copyFrameId) : null;

    final order = _frameService.calculateNextFrameOrder(state.frames);

    final newFrame = await _frameService.createFrame(
      projectId: project.id,
      name: name,
      stateId: stateId ?? state.currentAnimationState.id,
      width: state.width,
      height: state.height,
      copyFromFrame: copyFrame,
      order: order,
    );

    final updatedFrames = [...state.frames, newFrame];
    state = state.copyWith(
      frames: updatedFrames,
      currentFrameIndex: state.currentFrames.length,
      currentLayerIndex: 0,
    );
  }

  Future<void> removeFrame(int index) async {
    if (state.frames.length <= 1) return;

    final frameToRemove = state.frames[index];
    await _frameService.deleteFrame(frameToRemove.id);

    final updatedFrames = List<AnimationFrame>.from(state.frames)..removeAt(index);

    final newFrameIndex = _frameService.calculateSafeFrameIndex(
      updatedFrames,
      state.currentFrameIndex,
      index,
    );

    // Filter frames for current state
    final currentStateFrames = _animationService.removeFramesForState(
      updatedFrames,
      state.currentAnimationState.id,
    );

    final adjustedFrameIndex =
        newFrameIndex >= currentStateFrames.length ? currentStateFrames.length - 1 : newFrameIndex;

    state = state.copyWith(
      frames: updatedFrames,
      currentFrameIndex: adjustedFrameIndex.clamp(0, currentStateFrames.length - 1),
      currentLayerIndex: 0,
    );
  }

  void selectFrame(int frameId) {
    final index = state.currentFrames.indexWhere((frame) => frame.id == frameId);
    if (index >= 0) {
      state = state.copyWith(
        currentFrameIndex: index,
        currentLayerIndex: 0,
      );
    }
  }

  void nextFrame() {
    final nextIndex = (state.currentFrameIndex + 1) % state.currentFrames.length;
    state = state.copyWith(
      currentFrameIndex: nextIndex,
      currentLayerIndex: 0,
    );
  }

  void previousFrame() {
    final prevIndex = (state.currentFrameIndex - 1 + state.currentFrames.length) % state.currentFrames.length;
    state = state.copyWith(
      currentFrameIndex: prevIndex,
      currentLayerIndex: 0,
    );
  }

  // Animation state operations
  Future<void> addAnimationState(String name, int frameRate) async {
    final newState = await _animationService.createAnimationState(
      projectId: project.id,
      name: name,
      frameRate: frameRate,
    );

    state = state.copyWith(
      animationStates: [...state.animationStates, newState],
      currentAnimationStateIndex: state.animationStates.length,
      currentFrameIndex: 0,
      currentLayerIndex: 0,
    );
  }

  Future<void> removeAnimationState(int stateId) async {
    if (!_animationService.canDeleteState(state.animationStates)) return;

    final stateIndex = _animationService.findStateIndex(state.animationStates, stateId);
    if (stateIndex < 0) return;

    await _animationService.deleteAnimationState(stateId);

    final updatedStates = List<AnimationStateModel>.from(state.animationStates)..removeAt(stateIndex);

    final updatedFrames = _animationService.removeFramesForState(
      state.frames,
      stateId,
    );

    final newStateIndex = _animationService.calculateSafeStateIndex(
      updatedStates,
      state.currentAnimationStateIndex,
      stateIndex,
    );

    state = state.copyWith(
      animationStates: updatedStates,
      frames: updatedFrames,
      currentAnimationStateIndex: newStateIndex,
      currentFrameIndex: 0,
      currentLayerIndex: 0,
    );
  }

  void addTemplate(Template template) async {
    final order = _layerService.calculateNextLayerOrder(currentFrame.layers);

    var newLayer = await _layerService.createLayer(
      projectId: project.id,
      frameId: currentFrame.id,
      name: template.name,
      width: state.width,
      height: state.height,
      order: order,
    );

    final pixels = _templateService.applyTemplateToLayer(
      template: template,
      layerPixels: newLayer.pixels,
      layerWidth: state.width,
      layerHeight: state.height,
    );

    newLayer = newLayer.copyWith(pixels: pixels);

    final updatedLayers = [...currentFrame.layers, newLayer]..sort((a, b) => a.order.compareTo(b.order));

    final updatedFrame = currentFrame.copyWith(layers: updatedLayers);
    _updateCurrentFrame(updatedFrame);

    state = state.copyWith(currentLayerIndex: updatedLayers.length - 1);
  }

  void selectAnimationState(int stateId) {
    final index = _animationService.findStateIndex(state.animationStates, stateId);
    if (index >= 0) {
      state = state.copyWith(
        currentAnimationStateIndex: index,
        currentFrameIndex: 0,
        currentLayerIndex: 0,
      );
    }
  }

  Future<void> updateFrame(int index, AnimationFrame frame) async {
    await _frameService.updateFrame(
      projectId: project.id,
      frame: frame,
    );

    final updatedFrames = List<AnimationFrame>.from(state.frames);
    updatedFrames[index] = frame;

    state = state.copyWith(frames: updatedFrames);
    _updateProject();
  }

  Future<void> reorderFrames(int oldIndex, int newIndex) async {
    final reorderedFrames = _frameService.reorderFrames(
      state.frames,
      oldIndex,
      newIndex,
    );

    state = state.copyWith(
      frames: reorderedFrames,
      currentFrameIndex: oldIndex == state.currentFrameIndex ? newIndex : state.currentFrameIndex,
    );

    _updateProject();
  }

  // Selection operations
  void setSelection(List<PixelPoint<int>>? selection) {
    _selectionService.setSelection(selection, currentLayer.pixels);
    state = state.copyWith(selectionRect: selection);
  }

  void prepareToMoveSelection(List<PixelPoint<int>> initialSelection) {
    if (state.currentLayerIndex < 0 || state.currentLayerIndex >= currentFrame.layers.length) {
      debugPrint("prepareToMoveSelection: Invalid currentLayerIndex");
      return;
    }
    final layer = currentFrame.layers[state.currentLayerIndex];
    _selectionService.setSelection(initialSelection, layer.pixels);
    state = state.copyWith(selectionRect: initialSelection);
  }

  void moveSelection(List<PixelPoint<int>> newSelection, Point delta) {
    if (state.selectionRect == null) {
      debugPrint('No selection to move');
      return;
    }

    if (_selectionService.currentSelection == null || !_selectionService.hasSelection) {
      debugPrint('PixelDrawController.moveSelection: SelectionService not primed or has no selection.');

      if (state.selectionRect != null) {
        prepareToMoveSelection(state.selectionRect!);
      } else {
        return;
      }
    }

    if (_selectionService.currentSelection != null && listEquals(_selectionService.currentSelection!, newSelection)) {
      if (state.selectionRect != newSelection) {
        state = state.copyWith(selectionRect: newSelection);
      }
      return;
    }

    _saveState();

    final newPixels = _selectionService.moveSelection(
      newTargetSelection: newSelection,
      delta: delta,
      currentLayerPixels: Uint32List.fromList(currentLayer.pixels),
    );

    _updateCurrentLayerPixels(newPixels);
    state = state.copyWith(selectionRect: newSelection);
  }

  void clearSelection() {
    _selectionService.clearSelection();
    state = state.copyWith(selectionRect: null);
  }

  // Undo/Redo operations
  void undo() {
    final previousState = _undoRedoService.undo(state);
    if (previousState != null) {
      state = previousState;
      if (previousState.selectionRect != null) {
        _selectionService.setSelection(
          previousState.selectionRect,
          currentLayer.pixels,
        );
      }
      _updateProject();
    }
  }

  void redo() {
    final nextState = _undoRedoService.redo(state);
    if (nextState != null) {
      state = nextState;
      if (nextState.selectionRect != null) {
        _selectionService.setSelection(
          nextState.selectionRect,
          currentLayer.pixels,
        );
      }
      _updateProject();
    }
  }

  // Tool and color operations
  void setCurrentTool(PixelTool tool) {
    state = state.copyWith(currentTool: tool);
  }

  void setCurrentColor(Color color) {
    state = state.copyWith(currentColor: color);
  }

  void setCurrentModifier(PixelModifier modifier) {
    state = state.copyWith(currentModifier: modifier);
  }

  // Import/Export operations
  Future<void> exportProjectAsJson(BuildContext context) async {
    await _importExportService.exportProjectAsJson(
      context: context,
      project: project,
    );
  }

  Future<void> exportImage({
    required BuildContext context,
    bool withBackground = false,
    double? exportWidth,
    double? exportHeight,
  }) async {
    await _importExportService.exportImage(
      context: context,
      project: project,
      layers: currentFrame.layers,
      withBackground: withBackground,
      exportWidth: exportWidth,
      exportHeight: exportHeight,
    );
  }

  Future<void> shareProject(BuildContext context) async {
    await _importExportService.shareProject(
      context: context,
      project: project,
      layers: currentFrame.layers,
    );
  }

  Future<void> exportAnimation({
    required BuildContext context,
    required List<AnimationFrame> frames,
    bool withBackground = false,
    double? exportWidth,
    double? exportHeight,
  }) async {
    await _importExportService.exportAnimation(
      context: context,
      project: project,
      frames: frames,
      withBackground: withBackground,
      exportWidth: exportWidth,
      exportHeight: exportHeight,
    );
  }

  Future<void> exportSpriteSheet({
    required BuildContext context,
    required int columns,
    required int spacing,
    required bool includeAllFrames,
    bool withBackground = false,
    Color backgroundColor = Colors.white,
    double? exportWidth,
    double? exportHeight,
  }) async {
    final frames = includeAllFrames ? state.currentFrames : [state.currentFrame];

    await _importExportService.exportSpriteSheet(
      context: context,
      project: project,
      frames: frames,
      columns: columns,
      spacing: spacing,
      includeAllFrames: includeAllFrames,
      withBackground: withBackground,
      backgroundColor: backgroundColor,
      exportWidth: exportWidth,
      exportHeight: exportHeight,
    );
  }

  Future<void> importImageAsBackground(BuildContext context) async {
    final imageBytes = await _importExportService.importImageAsBackground(context: context);
    if (imageBytes != null) {
      ref.read(backgroundImageProvider.notifier).update((state) => state.copyWith(image: imageBytes));
    }
  }

  Future<void> importImageAsLayer(BuildContext context) async {
    final newLayer = await _importExportService.importImageAsLayer(
      context: context,
      width: state.width,
      height: state.height,
      layerName: 'Imported Image',
    );

    if (newLayer != null) {
      final createdLayer = await _layerService.createLayer(
        projectId: project.id,
        frameId: currentFrame.id,
        name: newLayer.name,
        width: state.width,
        height: state.height,
        order: _layerService.calculateNextLayerOrder(currentFrame.layers),
      );

      final layerWithPixels = createdLayer.copyWith(pixels: newLayer.pixels);

      final updatedLayers = [...currentFrame.layers, layerWithPixels];
      final updatedFrame = currentFrame.copyWith(layers: updatedLayers);
      _updateCurrentFrame(updatedFrame);

      state = state.copyWith(currentLayerIndex: updatedLayers.length - 1);
      _updateProject();
    }
  }

  // Helper methods
  Color _getDrawingColor() {
    return state.currentTool == PixelTool.eraser ? Colors.transparent : state.currentColor;
  }

  void _updateCurrentLayerPixels(Uint32List newPixels) {
    final updatedLayer = currentLayer.copyWith(pixels: newPixels);
    final updatedLayers = List<Layer>.from(currentFrame.layers);
    updatedLayers[state.currentLayerIndex] = updatedLayer;

    final updatedFrame = currentFrame.copyWith(layers: updatedLayers);
    _updateCurrentFrame(updatedFrame);

    _layerService.updateLayer(
      projectId: project.id,
      frameId: currentFrame.id,
      layer: updatedLayer,
    );
    _updateProject();
  }

  Future<void> _updateLayerAndFrame(int layerIndex, Layer updatedLayer) async {
    final updatedLayers = List<Layer>.from(currentFrame.layers);
    updatedLayers[layerIndex] = updatedLayer;

    final updatedFrame = currentFrame.copyWith(layers: updatedLayers);
    _updateCurrentFrame(updatedFrame);

    await _layerService.updateLayer(
      projectId: project.id,
      frameId: currentFrame.id,
      layer: updatedLayer,
    );
  }

  void _updateCurrentFrame(AnimationFrame updatedFrame) {
    final frameIndex = state.frames.indexWhere(
      (frame) => frame.id == currentFrame.id,
    );

    if (frameIndex != -1) {
      final updatedFrames = List<AnimationFrame>.from(state.frames);
      updatedFrames[frameIndex] = updatedFrame;
      state = state.copyWith(frames: updatedFrames);
    }
  }
}
