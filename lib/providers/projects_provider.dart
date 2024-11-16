import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import '../core/utils.dart';
import '../data.dart';
import 'providers.dart';

part 'projects_provider.g.dart';

@riverpod
class Projects extends _$Projects {
  @override
  Stream<List<Project>> build() {
    return ref.read(projectRepo).fetchProjects();
  }

  Future<Project> addProject(Project newProject) async {
    ref.read(analyticsProvider).logEvent(name: 'add_project', parameters: {
      'project_id': newProject.id,
      'project_name': newProject.name,
    });

    final project = await ref.read(projectRepo).createProject(newProject);
    final state = await ref.read(projectRepo).createState(
          project.id,
          const AnimationStateModel(
            id: 0,
            name: 'Animation',
            frameRate: 24,
          ),
        );
    final frame = await ref.read(projectRepo).createFrame(
          project.id,
          AnimationFrame(
            id: 0,
            stateId: state.id,
            name: 'Frame 1',
            duration: 100,
            layers: [
              Layer(
                layerId: 0,
                id: const Uuid().v4(),
                name: 'Layer 1',
                pixels: Uint32List(project.width * project.height),
                order: 0,
              ),
            ],
          ),
        );
    return project.copyWith(
      states: [state],
      frames: [frame],
    );
  }

  Future<Project?> getProject(int projectId) async {
    return ref.read(projectRepo).fetchProject(projectId);
  }

  Future<void> renameProject(int projectId, String name) async {
    ref.read(analyticsProvider).logEvent(name: 'rename_project', parameters: {
      'project_id': projectId,
      'project_name': name,
    });

    return ref.read(projectRepo).renameProject(projectId, name);
  }

  Future<void> deleteProject(Project project) async {
    ref.read(analyticsProvider).logEvent(name: 'delete_project', parameters: {
      'project_id': project.id,
      'project_name': project.name,
    });

    return ref.read(projectRepo).deleteProject(project);
  }

  Future<String?> importProject(BuildContext context) async {
    try {
      final contents = await FileUtils(context).readProjectFileContents();
      if (contents == null) return null;
      final project = Project.fromJson(jsonDecode(contents));

      addProject(project);
    } catch (e, s) {
      debugPrint(e.toString());
      debugPrint(s.toString());
      return e.toString();
    }
  }
}
