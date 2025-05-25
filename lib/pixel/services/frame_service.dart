import 'dart:math';
import 'dart:typed_data';
import 'package:uuid/uuid.dart';

import '../../data.dart';

class FrameService {
  final ProjectRepo _projectRepo;

  FrameService(this._projectRepo);

  Future<AnimationFrame> createFrame({
    required int projectId,
    required String name,
    required int stateId,
    required int width,
    required int height,
    AnimationFrame? copyFromFrame,
    int? order,
  }) async {
    final layers = copyFromFrame != null
        ? copyFromFrame.layers.indexed.map((indexed) {
            final (index, layer) = indexed;
            return layer.copyWith(
              id: const Uuid().v4(),
              layerId: 0,
              pixels: Uint32List.fromList(layer.pixels),
              order: index,
            );
          }).toList()
        : [
            Layer(
              layerId: 0,
              id: const Uuid().v4(),
              name: 'Layer 1',
              pixels: Uint32List(width * height),
              order: 0,
            )
          ];

    final newFrame = AnimationFrame(
      id: 0,
      name: name,
      stateId: stateId,
      createdAt: DateTime.now(),
      editedAt: DateTime.now(),
      duration: 100,
      layers: layers,
      order: order ?? 0,
    );

    return await _projectRepo.createFrame(projectId, newFrame);
  }

  Future<void> deleteFrame(int frameId) async {
    await _projectRepo.deleteFrame(frameId);
  }

  Future<void> updateFrame({
    required int projectId,
    required AnimationFrame frame,
  }) async {
    await _projectRepo.updateFrame(projectId, frame);
  }

  List<AnimationFrame> reorderFrames(
    List<AnimationFrame> frames,
    int oldIndex,
    int newIndex,
  ) {
    final reorderedFrames = List<AnimationFrame>.from(frames);
    final frame = reorderedFrames.removeAt(oldIndex);
    reorderedFrames.insert(newIndex, frame);

    return reorderedFrames.indexed.map((indexed) {
      final (index, frame) = indexed;
      return frame.copyWith(order: index);
    }).toList();
  }

  AnimationFrame updateFrameDuration(AnimationFrame frame, int duration) {
    return frame.copyWith(duration: duration);
  }

  AnimationFrame renameFrame(AnimationFrame frame, String newName) {
    return frame.copyWith(name: newName);
  }

  AnimationFrame updateFrameLayers(AnimationFrame frame, List<Layer> layers) {
    return frame.copyWith(layers: layers);
  }

  int calculateNextFrameOrder(List<AnimationFrame> frames) {
    if (frames.isEmpty) return 0;
    return frames.map((f) => f.order).reduce(max) + 1;
  }

  List<AnimationFrame> getFramesForState(
    List<AnimationFrame> allFrames,
    int stateId,
  ) {
    return allFrames.where((frame) => frame.stateId == stateId).toList();
  }

  int calculateSafeFrameIndex(
    List<AnimationFrame> frames,
    int currentIndex,
    int deletedIndex,
  ) {
    if (frames.length <= 1) return 0;

    if (deletedIndex == currentIndex) {
      // Deleting current frame, select previous or first
      return (deletedIndex > 0) ? deletedIndex - 1 : 0;
    } else if (deletedIndex < currentIndex) {
      // Deleting frame before current, adjust index
      return currentIndex - 1;
    } else {
      // Deleting frame after current, keep same index
      return currentIndex;
    }
  }
}
