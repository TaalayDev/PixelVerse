import 'package:hive_flutter/hive_flutter.dart';

import '../../data.dart';

class DatabaseService {
  static const String _projectsBoxName = 'projects';

  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(ProjectAdapter());
    Hive.registerAdapter(LayerAdapter());
    await Hive.openBox<Project>(_projectsBoxName);
  }

  static Box<Project> _getProjectsBox() {
    return Hive.box<Project>(_projectsBoxName);
  }

  static Future<void> addProject(Project project) async {
    final box = _getProjectsBox();
    await box.put(project.id, project);
  }

  static Future<void> updateProject(Project project) async {
    final box = _getProjectsBox();
    await box.put(project.id, project);
  }

  static Future<void> deleteProject(String id) async {
    final box = _getProjectsBox();
    await box.delete(id);
  }

  static Project? getProject(String id) {
    final box = _getProjectsBox();
    return box.get(id);
  }

  static List<Project> getAllProjects() {
    final box = _getProjectsBox();
    return box.values.toList();
  }
}
