import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:pixelverse/core/utils.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data.dart';
import 'providers.dart';

part 'projects_provider.g.dart';

@riverpod
class Projects extends _$Projects {
  @override
  Stream<List<Project>> build() {
    return ref.read(projectRepo).fetchProjects();
  }

  Future<Project> addProject(Project project) async {
    ref.read(analyticsProvider).logEvent(name: 'add_project', parameters: {
      'project_id': project.id,
      'project_name': project.name,
    });

    return ref.read(projectRepo).createProject(project);
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
