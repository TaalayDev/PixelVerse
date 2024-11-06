import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter/foundation.dart';

import '../../data.dart';

part 'project_database.g.dart';

extension ListIntX on List<int> {
  int max() {
    return reduce((value, element) => value > element ? value : element);
  }
}

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
  IntColumn get frameId => integer().references(FramesTable, #id)();
  TextColumn get layerId => text().withLength(min: 1, max: 100)();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  BlobColumn get pixels => blob()();
  BoolColumn get isVisible => boolean().withDefault(const Constant(true))();
  BoolColumn get isLocked => boolean().withDefault(const Constant(false))();
  RealColumn get opacity => real().withDefault(const Constant(1.0))();
  IntColumn get order => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

class FramesTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get projectId => integer().references(ProjectsTable, #id)();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  IntColumn get duration => integer()();
  IntColumn get order => integer()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get editedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [ProjectsTable, FramesTable, LayersTable])
class AppDatabase extends _$AppDatabase {
  AppDatabase._() : super(_openConnection());
  static final AppDatabase instance = AppDatabase._();

  factory AppDatabase() => instance;

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onUpgrade: (migrator, from, to) async {
        if (from < 2) {
          await migrator.createTable(framesTable);
          await migrator.alterTable(TableMigration(
            layersTable,
            newColumns: [layersTable.frameId],
          ));
          await migrator.alterTable(TableMigration(
            layersTable,
            newColumns: [layersTable.order],
          ));
        }
      },
    );
  }

  static QueryExecutor _openConnection() {
    return driftDatabase(
      name: 'pixelve.db',
      web: DriftWebOptions(
        sqlite3Wasm: Uri.parse('sqlite3.wasm'),
        driftWorker: Uri.parse('drift_worker.js'),
        onResult: (result) {
          if (result.missingFeatures.isNotEmpty) {
            debugPrint(
              'Using ${result.chosenImplementation} due to unsupported '
              'browser features: ${result.missingFeatures}',
            );
          }
        },
      ),
    );
  }

  Stream<List<Project>> getAllProjects() async* {
    final query = select(projectsTable).join([
      leftOuterJoin(
        framesTable,
        framesTable.projectId.equalsExp(projectsTable.id),
      ),
      leftOuterJoin(
        layersTable,
        layersTable.frameId.equalsExp(framesTable.id),
      ),
    ])
      ..orderBy([
        OrderingTerm(
          expression: projectsTable.editedAt,
          mode: OrderingMode.desc,
        ),
        OrderingTerm(expression: framesTable.order, mode: OrderingMode.asc),
        OrderingTerm(expression: layersTable.order, mode: OrderingMode.asc),
      ]);

    yield* query.watch().map((rows) {
      final projects = <int, Project>{};
      final frames = <int, AnimationFrame>{};

      for (final row in rows) {
        final projectRow = row.readTable(projectsTable);
        final frameRow = row.readTableOrNull(framesTable);
        final layerRow = row.readTableOrNull(layersTable);

        var project = projects[projectRow.id];
        if (project == null) {
          project = Project(
            id: projectRow.id,
            name: projectRow.name,
            width: projectRow.width,
            height: projectRow.height,
            thumbnail: projectRow.thumbnail,
            createdAt: projectRow.createdAt,
            editedAt: projectRow.editedAt,
            frames: [],
          );
          projects[projectRow.id] = project;
        }

        if (frameRow != null) {
          var frame = frames[frameRow.id];
          if (frame == null) {
            frame = AnimationFrame(
              id: frameRow.id,
              name: frameRow.name,
              duration: frameRow.duration,
              createdAt: frameRow.createdAt,
              editedAt: frameRow.editedAt,
              layers: [],
            );
            frames[frameRow.id] = frame;
            project.frames.add(frame);
          }

          if (layerRow != null) {
            final layer = Layer(
              layerId: layerRow.id,
              id: layerRow.layerId,
              name: layerRow.name,
              pixels: layerRow.pixels.buffer.asUint32List(),
              isVisible: layerRow.isVisible,
              isLocked: layerRow.isLocked,
              opacity: layerRow.opacity,
            );
            frame.layers.add(layer);
          }
        }
      }

      return projects.values.toList();
    });
  }

  Future<Project?> getProject(int projectId) async {
    final query = select(projectsTable).join([
      leftOuterJoin(
        framesTable,
        framesTable.projectId.equalsExp(projectsTable.id),
      ),
      leftOuterJoin(
        layersTable,
        layersTable.projectId.equalsExp(projectsTable.id),
      ),
    ])
      ..orderBy([
        OrderingTerm(expression: framesTable.order, mode: OrderingMode.asc),
        OrderingTerm(expression: layersTable.order, mode: OrderingMode.asc),
      ])
      ..where(projectsTable.id.equals(projectId));

    final rows = await query.get();

    if (rows.isEmpty) {
      return null;
    }

    final projectMap = <int, Project>{};
    final frameMap = <int, AnimationFrame>{};

    for (final row in rows) {
      final project = row.readTable(projectsTable);
      final frame = row.readTableOrNull(framesTable);
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
          frames: [],
        );
      }

      if (frame != null) {
        if (!frameMap.containsKey(frame.id)) {
          frameMap[frame.id] = AnimationFrame(
            id: frame.id,
            name: frame.name,
            duration: frame.duration,
            createdAt: frame.createdAt,
            editedAt: frame.editedAt,
            layers: [],
          );
          projectMap[project.id]!.frames.add(frameMap[frame.id]!);
        }

        if (layer != null && layer.frameId == frame.id) {
          frameMap[frame.id]!.layers.add(Layer(
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

    final frames = <AnimationFrame>[];
    for (final frame in project.frames) {
      final frameId = await into(framesTable).insert(FramesTableCompanion(
        projectId: Value(projectId),
        name: Value(frame.name),
        duration: Value(frame.duration),
        createdAt: Value(frame.createdAt),
        editedAt: Value(frame.editedAt),
        order: Value(frame.order),
      ));

      final layers = <Layer>[];
      for (final layer in frame.layers) {
        final layerId = await into(layersTable).insert(LayersTableCompanion(
          projectId: Value(projectId),
          layerId: Value(layer.id),
          frameId: Value(frameId),
          name: Value(layer.name),
          pixels: Value(layer.pixels.buffer.asUint8List()),
          isVisible: Value(layer.isVisible),
          isLocked: Value(layer.isLocked),
          opacity: Value(layer.opacity),
          order: Value(layer.order),
        ));
        layers.add(layer.copyWith(layerId: layerId));
      }

      frames.add(frame.copyWith(id: frameId, layers: layers));
    }

    return project.copyWith(id: projectId, frames: frames);
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

    for (final frame in project.frames) {
      if (frame.id == 0) {
        final frameId = await into(framesTable).insert(FramesTableCompanion(
          projectId: Value(project.id),
          name: Value(frame.name),
          duration: Value(frame.duration),
          createdAt: Value(frame.createdAt),
          editedAt: Value(frame.editedAt),
        ));

        for (final layer in frame.layers) {
          await into(layersTable).insert(LayersTableCompanion(
            projectId: Value(project.id),
            frameId: Value(frameId),
            layerId: Value(layer.id),
            name: Value(layer.name),
            pixels: Value(layer.pixels.buffer.asUint8List()),
            isVisible: Value(layer.isVisible),
            isLocked: Value(layer.isLocked),
            opacity: Value(layer.opacity),
          ));
        }
      } else {
        await update(framesTable).replace(FramesTableCompanion(
          id: Value(frame.id),
          projectId: Value(project.id),
          name: Value(frame.name),
          duration: Value(frame.duration),
          createdAt: Value(frame.createdAt),
          editedAt: Value(frame.editedAt),
          order: Value(frame.order),
        ));

        for (final layer in frame.layers) {
          if (layer.layerId == 0) {
            await into(layersTable).insert(LayersTableCompanion(
              projectId: Value(project.id),
              frameId: Value(frame.id),
              layerId: Value(layer.id),
              name: Value(layer.name),
              pixels: Value(layer.pixels.buffer.asUint8List()),
              isVisible: Value(layer.isVisible),
              isLocked: Value(layer.isLocked),
              opacity: Value(layer.opacity),
              order: Value(layer.order),
            ));
          } else {
            await update(layersTable).replace(LayersTableCompanion(
              id: Value(layer.layerId),
              projectId: Value(project.id),
              frameId: Value(frame.id),
              layerId: Value(layer.id),
              name: Value(layer.name),
              pixels: Value(layer.pixels.buffer.asUint8List()),
              isVisible: Value(layer.isVisible),
              isLocked: Value(layer.isLocked),
              opacity: Value(layer.opacity),
              order: Value(layer.order),
            ));
          }
        }
      }
    }
  }

  Future<void> deleteProject(int projectId) async {
    await (delete(projectsTable)..where((tbl) => tbl.id.equals(projectId)))
        .go();
    await (delete(framesTable)..where((tbl) => tbl.projectId.equals(projectId)))
        .go();
    await (delete(layersTable)..where((tbl) => tbl.projectId.equals(projectId)))
        .go();
  }

  Future<void> renameProject(int projectId, String name) async {
    (update(projectsTable)
      ..where((tbl) => tbl.id.equals(projectId))
      ..write(ProjectsTableCompanion(name: Value(name))));
  }

  Future<AnimationFrame> insertFrame(
    int projectId,
    AnimationFrame frame,
  ) async {
    final frameId = await into(framesTable).insert(FramesTableCompanion(
      projectId: Value(projectId),
      name: Value(frame.name),
      duration: Value(frame.duration),
      createdAt: Value(frame.createdAt),
      editedAt: Value(frame.editedAt),
      order: Value(frame.order),
    ));

    final layers = <Layer>[];
    for (final (index, layer) in frame.layers.indexed) {
      final layerId = await into(layersTable).insert(LayersTableCompanion(
        projectId: Value(projectId),
        layerId: Value(layer.id),
        frameId: Value(frameId),
        name: Value(layer.name),
        pixels: Value(layer.pixels.buffer.asUint8List()),
        isVisible: Value(layer.isVisible),
        isLocked: Value(layer.isLocked),
        opacity: Value(layer.opacity),
        order: Value(layer.order),
      ));
      layers.add(layer.copyWith(layerId: layerId));
    }

    return frame.copyWith(id: frameId, layers: layers);
  }

  Future<void> updateFrame(int projectId, AnimationFrame frame) async {
    await update(framesTable).replace(FramesTableCompanion(
      id: Value(frame.id),
      projectId: Value(projectId),
      name: Value(frame.name),
      duration: Value(frame.duration),
      createdAt: Value(frame.createdAt),
      editedAt: Value(frame.editedAt),
      order: Value(frame.order),
    ));

    for (final layer in frame.layers) {
      if (layer.layerId == 0) {
        await into(layersTable).insert(LayersTableCompanion(
          projectId: Value(projectId),
          frameId: Value(frame.id),
          layerId: Value(layer.id),
          name: Value(layer.name),
          pixels: Value(layer.pixels.buffer.asUint8List()),
          isVisible: Value(layer.isVisible),
          isLocked: Value(layer.isLocked),
          opacity: Value(layer.opacity),
          order: Value(layer.order),
        ));
      } else {
        await update(layersTable).replace(LayersTableCompanion(
          id: Value(layer.layerId),
          projectId: Value(projectId),
          frameId: Value(frame.id),
          layerId: Value(layer.id),
          name: Value(layer.name),
          pixels: Value(layer.pixels.buffer.asUint8List()),
          isVisible: Value(layer.isVisible),
          isLocked: Value(layer.isLocked),
          opacity: Value(layer.opacity),
          order: Value(layer.order),
        ));
      }
    }
  }

  Future<void> deleteFrame(int frameId) async {
    await (delete(framesTable)..where((tbl) => tbl.id.equals(frameId))).go();
    await (delete(layersTable)..where((tbl) => tbl.frameId.equals(frameId)))
        .go();
  }

  Future<Layer> insertLayer(int projectId, int frameId, Layer layer) async {
    final layerId = await into(layersTable).insert(LayersTableCompanion(
      layerId: Value(layer.id),
      projectId: Value(projectId),
      frameId: Value(frameId),
      name: Value(layer.name),
      pixels: Value(layer.pixels.buffer.asUint8List()),
      isVisible: Value(layer.isVisible),
      isLocked: Value(layer.isLocked),
      opacity: Value(layer.opacity),
      order: Value(layer.order),
    ));

    return layer.copyWith(layerId: layerId);
  }

  Future<void> updateLayer(int projectId, int frameId, Layer layer) async {
    await update(layersTable).replace(LayersTableCompanion(
      id: Value(layer.layerId),
      layerId: Value(layer.id),
      projectId: Value(projectId),
      frameId: Value(frameId),
      name: Value(layer.name),
      pixels: Value(layer.pixels.buffer.asUint8List()),
      isVisible: Value(layer.isVisible),
      isLocked: Value(layer.isLocked),
      opacity: Value(layer.opacity),
      order: Value(layer.order),
    ));
  }

  Future<void> deleteLayer(int layerId) async {
    await (delete(layersTable)..where((tbl) => tbl.id.equals(layerId))).go();
  }
}
