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
    return ref.read(projectRepo).createProject(project);
  }

  Future<Project?> getProject(int projectId) async {
    return ref.read(projectRepo).fetchProject(projectId);
  }

  Future<void> renameProject(int projectId, String name) async {
    return ref.read(projectRepo).renameProject(projectId, name);
  }

  Future<void> deleteProject(Project project) async {
    return ref.read(projectRepo).deleteProject(project);
  }
}
