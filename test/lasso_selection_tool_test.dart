import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:picell/data/models/layer.dart';
import 'package:picell/pixel/canvas/canvas_controller.dart';
import 'package:picell/pixel/canvas/canvas_gesture_handler.dart';
import 'package:picell/pixel/canvas/layer_cache_manager.dart';
import 'package:picell/pixel/canvas/pixel_viewport_controller.dart';
import 'package:picell/pixel/canvas/tool_drawing_manager.dart';
import 'package:picell/pixel/services/selection_service.dart';
import 'package:picell/pixel/tools.dart';
import 'package:picell/pixel/tools/selection_tools.dart';

void main() {
  group('LassoSelectionTool cancellation', () {
    late Layer layer;
    late List<(List<Offset>, bool)> updates;
    late List<Object?> confirmations;
    late LassoSelectionTool tool;

    setUp(() {
      layer = Layer(
        layerId: 1,
        id: 'layer-1',
        name: 'Layer 1',
        pixels: Uint32List(100),
      );
      updates = [];
      confirmations = [];
      tool = LassoSelectionTool(
        selectionService: SelectionService(width: 10, height: 10),
        onLassoUpdate: (points, isDrawing) {
          updates.add((List<Offset>.from(points), isDrawing));
        },
        onConfirm: confirmations.add,
      );
    });

    PixelDrawDetails detailsAt(Offset position) {
      return PixelDrawDetails(
        position: position,
        size: const Size(100, 100),
        width: 10,
        height: 10,
        currentLayer: layer,
        color: Colors.black,
        modifier: null,
        onPixelsUpdated: (_) {},
      );
    }

    test('clears a one-point preview without confirming a selection', () {
      tool.onStart(detailsAt(const Offset(10, 10)));

      expect(tool.isDrawing, isTrue);
      expect(tool.previewPoints, [const Offset(10, 10)]);

      tool.cancel();

      expect(tool.isDrawing, isFalse);
      expect(tool.previewPoints, isEmpty);
      expect(updates.last.$1, isEmpty);
      expect(updates.last.$2, isFalse);
      expect(confirmations, isEmpty);
    });

    test('allows a fresh lasso immediately after cancellation', () {
      tool.onStart(detailsAt(const Offset(10, 10)));
      tool.cancel();

      tool.onStart(detailsAt(const Offset(30, 30)));
      tool.onMove(detailsAt(const Offset(50, 30)));

      expect(tool.isDrawing, isTrue);
      expect(tool.previewPoints, const [Offset(30, 30), Offset(50, 30)]);
    });

    test('is idempotent when no lasso is active', () {
      tool.cancel();

      expect(updates, isEmpty);
      expect(confirmations, isEmpty);
    });

    test('does not auto-close during small initial finger movements', () {
      tool.onStart(detailsAt(const Offset(20, 20)));
      tool.onMove(detailsAt(const Offset(21, 20)));
      tool.onMove(detailsAt(const Offset(22, 20)));
      tool.onMove(detailsAt(const Offset(23, 20)));
      tool.onMove(detailsAt(const Offset(24, 20)));

      expect(tool.isDrawing, isTrue);
      expect(tool.previewPoints, hasLength(5));
      expect(confirmations, isEmpty);
    });

    test('auto-closes after leaving and returning to the close radius', () {
      tool.onStart(detailsAt(const Offset(20, 20)));
      tool.onMove(detailsAt(const Offset(40, 20)));
      tool.onMove(detailsAt(const Offset(40, 40)));
      tool.onMove(detailsAt(const Offset(20, 40)));
      tool.onMove(detailsAt(const Offset(21, 21)));

      expect(tool.isDrawing, isFalse);
      expect(tool.previewPoints, isEmpty);
      expect(confirmations, hasLength(1));
      expect(confirmations.single, isNotNull);
    });
  });

  group('CanvasGestureHandler lasso interruption', () {
    late Layer layer;
    late PixelCanvasController controller;
    late ToolDrawingManager toolManager;
    late CanvasGestureHandler gestureHandler;

    setUp(() {
      layer = Layer(
        layerId: 1,
        id: 'layer-1',
        name: 'Layer 1',
        pixels: Uint32List(100),
      );
      controller = PixelCanvasController(
        width: 10,
        height: 10,
        layers: [layer],
        currentLayerIndex: 0,
        cacheManager: LayerCacheManager(width: 10, height: 10),
      );
      toolManager = ToolDrawingManager(
        width: 10,
        height: 10,
        onLassoUpdate: controller.updateLassoPreview,
      );
      gestureHandler = CanvasGestureHandler(
        controller: controller,
        toolManager: toolManager,
        viewportController: PixelViewportController(),
        onStartDrawing: () {},
        onFinishDrawing: () {},
        onDrawShape: (_) {},
      );
    });

    PixelDrawDetails detailsAt(Offset position) {
      return PixelDrawDetails(
        position: position,
        size: const Size(100, 100),
        width: 10,
        height: 10,
        currentLayer: layer,
        color: Colors.black,
        modifier: null,
        onPixelsUpdated: (_) {},
      );
    }

    test('second touch clears the active one-point lasso preview', () {
      const firstPosition = Offset(10, 10);
      gestureHandler.handlePointerDown(
        const PointerDownEvent(pointer: 1, position: firstPosition),
        PixelTool.lasso,
        detailsAt(firstPosition),
      );

      expect(controller.isDrawingLasso, isTrue);
      expect(controller.lassoPreviewPoints, [firstPosition]);

      const secondPosition = Offset(30, 30);
      gestureHandler.handlePointerDown(
        const PointerDownEvent(pointer: 2, position: secondPosition),
        PixelTool.lasso,
        detailsAt(secondPosition),
      );

      expect(controller.isDrawingLasso, isFalse);
      expect(controller.lassoPreviewPoints, isEmpty);
      expect(toolManager.isDrawingLasso, isFalse);
    });

    test('pointer cancel clears the active one-point lasso preview', () {
      const position = Offset(10, 10);
      gestureHandler.handlePointerDown(
        const PointerDownEvent(pointer: 1, position: position),
        PixelTool.lasso,
        detailsAt(position),
      );

      gestureHandler.handlePointerCancel(
        const PointerCancelEvent(pointer: 1, position: position),
        PixelTool.lasso,
        detailsAt(position),
      );

      expect(gestureHandler.hasActivePointers, isFalse);
      expect(controller.isDrawingLasso, isFalse);
      expect(controller.lassoPreviewPoints, isEmpty);
      expect(toolManager.isDrawingLasso, isFalse);
    });
  });
}
