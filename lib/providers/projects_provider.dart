import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data.dart';

part 'projects_provider.g.dart';

@riverpod
class Projects extends _$Projects {
  @override
  List<Project> build() {
    return DatabaseService.getAllProjects();
  }

  Future<void> addProject(Project project) async {
    await DatabaseService.addProject(project);
    refresh();
  }

  Future<void> refresh() async {
    state = DatabaseService.getAllProjects();
  }
}
