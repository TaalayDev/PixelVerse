import 'dart:typed_data';

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../../data.dart';

part 'project_database.g.dart';

class ProjectsTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  IntColumn get width => integer()();
  IntColumn get height => integer()();
  BlobColumn get thumbnail => blob().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get editedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class LayersTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get projectId => integer().references(ProjectsTable, #id)();
  TextColumn get layerId => text().withLength(min: 1, max: 100)();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  BlobColumn get pixels => blob()();
  BoolColumn get isVisible => boolean().withDefault(const Constant(true))();
  BoolColumn get isLocked => boolean().withDefault(const Constant(false))();
  RealColumn get opacity => real().withDefault(const Constant(1.0))();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [ProjectsTable, LayersTable])
class AppDatabase extends _$AppDatabase {
  AppDatabase._() : super(_openConnection());
  static final AppDatabase instance = AppDatabase._();

  factory AppDatabase() => instance;

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'db_1.db');
  }

  Stream<List<Project>> getAllProjects() async* {
    final query = select(projectsTable).join([
      leftOuterJoin(
        layersTable,
        layersTable.id.equalsExp(projectsTable.id),
      ),
    ]);

    yield* query.watch().map((rows) {
      final projects = <Project>[];
      final projectMap = <int, Project>{};

      for (final row in rows) {
        final project = row.readTable(projectsTable);

        if (!projectMap.containsKey(project.id)) {
          projectMap[project.id] = Project(
            id: project.id,
            name: project.name,
            width: project.width,
            height: project.height,
            thumbnail: project.thumbnail,
            createdAt: project.createdAt,
            editedAt: project.editedAt,
            layers: [],
          );
        }
      }

      for (final project in projectMap.values) {
        projects.add(project);
      }

      return projects;
    });
  }

  Future<Project?> getProject(int projectId) async {
    final query = select(projectsTable).join([
      leftOuterJoin(
        layersTable,
        layersTable.projectId.equalsExp(projectsTable.id),
      ),
    ])
      ..where(projectsTable.id.equals(projectId));

    final rows = await query.get();

    if (rows.isEmpty) {
      return null;
    }

    final projectMap = <int, Project>{};

    for (final row in rows) {
      final project = row.readTable(projectsTable);
      final layer = row.readTableOrNull(layersTable);

      if (!projectMap.containsKey(project.id)) {
        projectMap[project.id] = Project(
          id: project.id,
          name: project.name,
          width: project.width,
          height: project.height,
          thumbnail: project.thumbnail,
          createdAt: project.createdAt,
          editedAt: project.editedAt,
          layers: [],
        );
      }

      if (layer != null) {
        projectMap[project.id]!.layers.add(Layer(
              layerId: layer.id,
              id: layer.layerId,
              name: layer.name,
              pixels: layer.pixels.buffer.asUint32List(),
              isVisible: layer.isVisible,
              isLocked: layer.isLocked,
              opacity: layer.opacity,
            ));
      }
    }

    return projectMap[projectId];
  }

  Future<Project> insertProject(Project project) async {
    final projectId = await into(projectsTable).insert(ProjectsTableCompanion(
      name: Value(project.name),
      width: Value(project.width),
      height: Value(project.height),
      thumbnail: Value(project.thumbnail),
      createdAt: Value(project.createdAt),
      editedAt: Value(project.editedAt),
    ));

    final layers = <Layer>[];
    for (final layer in project.layers) {
      final layerId = await into(layersTable).insert(LayersTableCompanion(
        layerId: Value(layer.id),
        projectId: Value(projectId),
        name: Value(layer.name),
        pixels: Value(layer.pixels.buffer.asUint8List()),
        isVisible: Value(layer.isVisible),
        isLocked: Value(layer.isLocked),
        opacity: Value(layer.opacity),
      ));
      layers.add(layer.copyWith(layerId: layerId));
    }

    return project.copyWith(id: projectId, layers: layers);
  }

  Future<void> updateProject(Project project) async {
    await update(projectsTable).replace(ProjectsTableCompanion(
      id: Value(project.id),
      name: Value(project.name),
      width: Value(project.width),
      height: Value(project.height),
      thumbnail: Value(project.thumbnail),
      createdAt: Value(project.createdAt),
      editedAt: Value(project.editedAt),
    ));

    final query = select(projectsTable).join([
      leftOuterJoin(
        layersTable,
        layersTable.projectId.equalsExp(projectsTable.id),
      ),
    ])
      ..where(projectsTable.id.equals(project.id));

    final rows = await query.get();

    final layerIds = <int>{};
    for (final row in rows) {
      final layer = row.readTableOrNull(layersTable);
      if (layer != null) {
        layerIds.add(layer.id);
      }
    }

    for (final layer in project.layers) {
      if (layer.layerId == 0) {
        await into(layersTable).insert(LayersTableCompanion(
          layerId: Value(layer.id),
          projectId: Value(project.id),
          name: Value(layer.name),
          pixels: Value(layer.pixels.buffer.asUint8List()),
          isVisible: Value(layer.isVisible),
          isLocked: Value(layer.isLocked),
          opacity: Value(layer.opacity),
        ));
      } else {
        await update(layersTable).replace(LayersTableCompanion(
          id: Value(layer.layerId),
          layerId: Value(layer.id),
          projectId: Value(project.id),
          name: Value(layer.name),
          pixels: Value(layer.pixels.buffer.asUint8List()),
          isVisible: Value(layer.isVisible),
          isLocked: Value(layer.isLocked),
          opacity: Value(layer.opacity),
        ));
        layerIds.remove(layer.layerId);
      }
    }
  }

  Future<Layer> insertLayer(int projectId, Layer layer) async {
    final layerId = await into(layersTable).insert(LayersTableCompanion(
      layerId: Value(layer.id),
      projectId: Value(projectId),
      name: Value(layer.name),
      pixels: Value(layer.pixels.buffer.asUint8List()),
      isVisible: Value(layer.isVisible),
      isLocked: Value(layer.isLocked),
      opacity: Value(layer.opacity),
    ));

    return layer.copyWith(layerId: layerId);
  }

  Future<void> updateLayer(int projectId, Layer layer) async {
    await update(layersTable).replace(LayersTableCompanion(
      id: Value(layer.layerId),
      layerId: Value(layer.id),
      projectId: Value(projectId),
      name: Value(layer.name),
      pixels: Value(layer.pixels.buffer.asUint8List()),
      isVisible: Value(layer.isVisible),
      isLocked: Value(layer.isLocked),
      opacity: Value(layer.opacity),
    ));
  }

  Future<void> deleteLayer(int layerId) async {
    await (delete(layersTable)..where((tbl) => tbl.id.equals(layerId))).go();
  }
}
