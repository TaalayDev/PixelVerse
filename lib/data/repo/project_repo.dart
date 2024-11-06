import 'dart:async';
import 'dart:typed_data';

import '../../data.dart';
import '../../core/utils/image_helper.dart';
import '../../core/utils/queue_manager.dart';

abstract class ProjectRepo {
  Stream<List<Project>> fetchProjects();
  Future<Project?> fetchProject(int projectId);
  Future<Project> createProject(Project project);
  Future<void> updateProject(Project project);
  Future<void> renameProject(int projectId, String name);
  Future<void> deleteProject(Project project);
  Future<AnimationFrame> createFrame(int projectId, AnimationFrame frame);
  Future<void> updateFrame(int projectId, AnimationFrame frame);
  Future<void> deleteFrame(int frameId);
  Future<Layer> createLayer(int projectId, int frameId, Layer layer);
  Future<void> updateLayer(int projectId, int frameId, Layer layer);
  Future<void> deleteLayer(int layerId);
}

class ProjectLocalRepo extends ProjectRepo {
  final AppDatabase db;
  final QueueManager queueManager;

  ProjectLocalRepo(this.db, this.queueManager);

  @override
  Stream<List<Project>> fetchProjects() => db.getAllProjects();
  @override
  Future<Project?> fetchProject(int projectId) => db.getProject(projectId);
  @override
  Future<Project> createProject(Project project) => db.insertProject(project);
  @override
  Future<void> updateProject(Project project) async {
    final completer = Completer<void>();
    queueManager.add(() async {
      final pixels = Uint32List(project.width * project.height);
      for (final layer in project.frames.first.layers.where(
        (layer) => layer.isVisible,
      )) {
        for (int i = 0; i < pixels.length; i++) {
          pixels[i] = pixels[i] == 0 ? layer.pixels[i] : pixels[i];
        }
      }

      await db.updateProject(
        project.copyWith(thumbnail: ImageHelper.convertToBytes(pixels)),
      );
      completer.complete();
    });
    return completer.future;
  }

  @override
  Future<void> renameProject(int projectId, String name) async {
    final completer = Completer<void>();
    queueManager.add(() async {
      await db.renameProject(projectId, name);
      completer.complete();
    });
    return completer.future;
  }

  @override
  Future<void> deleteProject(Project project) async {
    final completer = Completer<void>();
    queueManager.add(() async {
      await db.deleteProject(project.id);
      completer.complete();
    });
    return completer.future;
  }

  @override
  Future<Layer> createLayer(int projectId, int frameId, Layer layer) async {
    final completer = Completer<Layer>();
    queueManager.add(() async {
      final newLayer = await db.insertLayer(projectId, frameId, layer);
      completer.complete(newLayer);
    });
    return completer.future;
  }

  @override
  Future<void> updateLayer(int projectId, int frameId, Layer layer) async {
    final completer = Completer<void>();
    queueManager.add(() async {
      await db.updateLayer(projectId, frameId, layer);
      completer.complete();
    });
    return completer.future;
  }

  @override
  Future<void> deleteLayer(int layerId) async {
    final completer = Completer<void>();
    queueManager.add(() async {
      await db.deleteLayer(layerId);
      completer.complete();
    });
    return completer.future;
  }

  @override
  Future<AnimationFrame> createFrame(int projectId, AnimationFrame frame) {
    final completer = Completer<AnimationFrame>();
    queueManager.add(() async {
      final newFrame = await db.insertFrame(projectId, frame);
      completer.complete(newFrame);
    });
    return completer.future;
  }

  @override
  Future<void> deleteFrame(int frameId) {
    final completer = Completer<void>();
    queueManager.add(() async {
      await db.deleteFrame(frameId);
      completer.complete();
    });
    return completer.future;
  }

  @override
  Future<void> updateFrame(int projectId, AnimationFrame frame) {
    final completer = Completer<void>();
    queueManager.add(() async {
      await db.updateFrame(projectId, frame);
      completer.complete();
    });
    return completer.future;
  }
}
