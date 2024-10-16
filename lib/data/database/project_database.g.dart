// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'project_database.dart';

// ignore_for_file: type=lint
class $ProjectsTableTable extends ProjectsTable
    with TableInfo<$ProjectsTableTable, ProjectsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProjectsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 100),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _widthMeta = const VerificationMeta('width');
  @override
  late final GeneratedColumn<int> width = GeneratedColumn<int>(
      'width', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _heightMeta = const VerificationMeta('height');
  @override
  late final GeneratedColumn<int> height = GeneratedColumn<int>(
      'height', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _thumbnailMeta =
      const VerificationMeta('thumbnail');
  @override
  late final GeneratedColumn<Uint8List> thumbnail = GeneratedColumn<Uint8List>(
      'thumbnail', aliasedName, true,
      type: DriftSqlType.blob, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _editedAtMeta =
      const VerificationMeta('editedAt');
  @override
  late final GeneratedColumn<DateTime> editedAt = GeneratedColumn<DateTime>(
      'edited_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, name, width, height, thumbnail, createdAt, editedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'projects_table';
  @override
  VerificationContext validateIntegrity(Insertable<ProjectsTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('width')) {
      context.handle(
          _widthMeta, width.isAcceptableOrUnknown(data['width']!, _widthMeta));
    } else if (isInserting) {
      context.missing(_widthMeta);
    }
    if (data.containsKey('height')) {
      context.handle(_heightMeta,
          height.isAcceptableOrUnknown(data['height']!, _heightMeta));
    } else if (isInserting) {
      context.missing(_heightMeta);
    }
    if (data.containsKey('thumbnail')) {
      context.handle(_thumbnailMeta,
          thumbnail.isAcceptableOrUnknown(data['thumbnail']!, _thumbnailMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('edited_at')) {
      context.handle(_editedAtMeta,
          editedAt.isAcceptableOrUnknown(data['edited_at']!, _editedAtMeta));
    } else if (isInserting) {
      context.missing(_editedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ProjectsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProjectsTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      width: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}width'])!,
      height: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}height'])!,
      thumbnail: attachedDatabase.typeMapping
          .read(DriftSqlType.blob, data['${effectivePrefix}thumbnail']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      editedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}edited_at'])!,
    );
  }

  @override
  $ProjectsTableTable createAlias(String alias) {
    return $ProjectsTableTable(attachedDatabase, alias);
  }
}

class ProjectsTableData extends DataClass
    implements Insertable<ProjectsTableData> {
  final int id;
  final String name;
  final int width;
  final int height;
  final Uint8List? thumbnail;
  final DateTime createdAt;
  final DateTime editedAt;
  const ProjectsTableData(
      {required this.id,
      required this.name,
      required this.width,
      required this.height,
      this.thumbnail,
      required this.createdAt,
      required this.editedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['width'] = Variable<int>(width);
    map['height'] = Variable<int>(height);
    if (!nullToAbsent || thumbnail != null) {
      map['thumbnail'] = Variable<Uint8List>(thumbnail);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['edited_at'] = Variable<DateTime>(editedAt);
    return map;
  }

  ProjectsTableCompanion toCompanion(bool nullToAbsent) {
    return ProjectsTableCompanion(
      id: Value(id),
      name: Value(name),
      width: Value(width),
      height: Value(height),
      thumbnail: thumbnail == null && nullToAbsent
          ? const Value.absent()
          : Value(thumbnail),
      createdAt: Value(createdAt),
      editedAt: Value(editedAt),
    );
  }

  factory ProjectsTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProjectsTableData(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      width: serializer.fromJson<int>(json['width']),
      height: serializer.fromJson<int>(json['height']),
      thumbnail: serializer.fromJson<Uint8List?>(json['thumbnail']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      editedAt: serializer.fromJson<DateTime>(json['editedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'width': serializer.toJson<int>(width),
      'height': serializer.toJson<int>(height),
      'thumbnail': serializer.toJson<Uint8List?>(thumbnail),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'editedAt': serializer.toJson<DateTime>(editedAt),
    };
  }

  ProjectsTableData copyWith(
          {int? id,
          String? name,
          int? width,
          int? height,
          Value<Uint8List?> thumbnail = const Value.absent(),
          DateTime? createdAt,
          DateTime? editedAt}) =>
      ProjectsTableData(
        id: id ?? this.id,
        name: name ?? this.name,
        width: width ?? this.width,
        height: height ?? this.height,
        thumbnail: thumbnail.present ? thumbnail.value : this.thumbnail,
        createdAt: createdAt ?? this.createdAt,
        editedAt: editedAt ?? this.editedAt,
      );
  ProjectsTableData copyWithCompanion(ProjectsTableCompanion data) {
    return ProjectsTableData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      width: data.width.present ? data.width.value : this.width,
      height: data.height.present ? data.height.value : this.height,
      thumbnail: data.thumbnail.present ? data.thumbnail.value : this.thumbnail,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      editedAt: data.editedAt.present ? data.editedAt.value : this.editedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProjectsTableData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('width: $width, ')
          ..write('height: $height, ')
          ..write('thumbnail: $thumbnail, ')
          ..write('createdAt: $createdAt, ')
          ..write('editedAt: $editedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, width, height,
      $driftBlobEquality.hash(thumbnail), createdAt, editedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProjectsTableData &&
          other.id == this.id &&
          other.name == this.name &&
          other.width == this.width &&
          other.height == this.height &&
          $driftBlobEquality.equals(other.thumbnail, this.thumbnail) &&
          other.createdAt == this.createdAt &&
          other.editedAt == this.editedAt);
}

class ProjectsTableCompanion extends UpdateCompanion<ProjectsTableData> {
  final Value<int> id;
  final Value<String> name;
  final Value<int> width;
  final Value<int> height;
  final Value<Uint8List?> thumbnail;
  final Value<DateTime> createdAt;
  final Value<DateTime> editedAt;
  const ProjectsTableCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.width = const Value.absent(),
    this.height = const Value.absent(),
    this.thumbnail = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.editedAt = const Value.absent(),
  });
  ProjectsTableCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required int width,
    required int height,
    this.thumbnail = const Value.absent(),
    required DateTime createdAt,
    required DateTime editedAt,
  })  : name = Value(name),
        width = Value(width),
        height = Value(height),
        createdAt = Value(createdAt),
        editedAt = Value(editedAt);
  static Insertable<ProjectsTableData> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<int>? width,
    Expression<int>? height,
    Expression<Uint8List>? thumbnail,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? editedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (width != null) 'width': width,
      if (height != null) 'height': height,
      if (thumbnail != null) 'thumbnail': thumbnail,
      if (createdAt != null) 'created_at': createdAt,
      if (editedAt != null) 'edited_at': editedAt,
    });
  }

  ProjectsTableCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<int>? width,
      Value<int>? height,
      Value<Uint8List?>? thumbnail,
      Value<DateTime>? createdAt,
      Value<DateTime>? editedAt}) {
    return ProjectsTableCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      width: width ?? this.width,
      height: height ?? this.height,
      thumbnail: thumbnail ?? this.thumbnail,
      createdAt: createdAt ?? this.createdAt,
      editedAt: editedAt ?? this.editedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (width.present) {
      map['width'] = Variable<int>(width.value);
    }
    if (height.present) {
      map['height'] = Variable<int>(height.value);
    }
    if (thumbnail.present) {
      map['thumbnail'] = Variable<Uint8List>(thumbnail.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (editedAt.present) {
      map['edited_at'] = Variable<DateTime>(editedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProjectsTableCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('width: $width, ')
          ..write('height: $height, ')
          ..write('thumbnail: $thumbnail, ')
          ..write('createdAt: $createdAt, ')
          ..write('editedAt: $editedAt')
          ..write(')'))
        .toString();
  }
}

class $LayersTableTable extends LayersTable
    with TableInfo<$LayersTableTable, LayersTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LayersTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _projectIdMeta =
      const VerificationMeta('projectId');
  @override
  late final GeneratedColumn<int> projectId = GeneratedColumn<int>(
      'project_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES projects_table (id)'));
  static const VerificationMeta _layerIdMeta =
      const VerificationMeta('layerId');
  @override
  late final GeneratedColumn<String> layerId = GeneratedColumn<String>(
      'layer_id', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 100),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 100),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _pixelsMeta = const VerificationMeta('pixels');
  @override
  late final GeneratedColumn<Uint8List> pixels = GeneratedColumn<Uint8List>(
      'pixels', aliasedName, false,
      type: DriftSqlType.blob, requiredDuringInsert: true);
  static const VerificationMeta _isVisibleMeta =
      const VerificationMeta('isVisible');
  @override
  late final GeneratedColumn<bool> isVisible = GeneratedColumn<bool>(
      'is_visible', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_visible" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _isLockedMeta =
      const VerificationMeta('isLocked');
  @override
  late final GeneratedColumn<bool> isLocked = GeneratedColumn<bool>(
      'is_locked', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_locked" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _opacityMeta =
      const VerificationMeta('opacity');
  @override
  late final GeneratedColumn<double> opacity = GeneratedColumn<double>(
      'opacity', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(1.0));
  @override
  List<GeneratedColumn> get $columns =>
      [id, projectId, layerId, name, pixels, isVisible, isLocked, opacity];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'layers_table';
  @override
  VerificationContext validateIntegrity(Insertable<LayersTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('project_id')) {
      context.handle(_projectIdMeta,
          projectId.isAcceptableOrUnknown(data['project_id']!, _projectIdMeta));
    } else if (isInserting) {
      context.missing(_projectIdMeta);
    }
    if (data.containsKey('layer_id')) {
      context.handle(_layerIdMeta,
          layerId.isAcceptableOrUnknown(data['layer_id']!, _layerIdMeta));
    } else if (isInserting) {
      context.missing(_layerIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('pixels')) {
      context.handle(_pixelsMeta,
          pixels.isAcceptableOrUnknown(data['pixels']!, _pixelsMeta));
    } else if (isInserting) {
      context.missing(_pixelsMeta);
    }
    if (data.containsKey('is_visible')) {
      context.handle(_isVisibleMeta,
          isVisible.isAcceptableOrUnknown(data['is_visible']!, _isVisibleMeta));
    }
    if (data.containsKey('is_locked')) {
      context.handle(_isLockedMeta,
          isLocked.isAcceptableOrUnknown(data['is_locked']!, _isLockedMeta));
    }
    if (data.containsKey('opacity')) {
      context.handle(_opacityMeta,
          opacity.isAcceptableOrUnknown(data['opacity']!, _opacityMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LayersTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LayersTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      projectId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}project_id'])!,
      layerId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}layer_id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      pixels: attachedDatabase.typeMapping
          .read(DriftSqlType.blob, data['${effectivePrefix}pixels'])!,
      isVisible: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_visible'])!,
      isLocked: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_locked'])!,
      opacity: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}opacity'])!,
    );
  }

  @override
  $LayersTableTable createAlias(String alias) {
    return $LayersTableTable(attachedDatabase, alias);
  }
}

class LayersTableData extends DataClass implements Insertable<LayersTableData> {
  final int id;
  final int projectId;
  final String layerId;
  final String name;
  final Uint8List pixels;
  final bool isVisible;
  final bool isLocked;
  final double opacity;
  const LayersTableData(
      {required this.id,
      required this.projectId,
      required this.layerId,
      required this.name,
      required this.pixels,
      required this.isVisible,
      required this.isLocked,
      required this.opacity});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['project_id'] = Variable<int>(projectId);
    map['layer_id'] = Variable<String>(layerId);
    map['name'] = Variable<String>(name);
    map['pixels'] = Variable<Uint8List>(pixels);
    map['is_visible'] = Variable<bool>(isVisible);
    map['is_locked'] = Variable<bool>(isLocked);
    map['opacity'] = Variable<double>(opacity);
    return map;
  }

  LayersTableCompanion toCompanion(bool nullToAbsent) {
    return LayersTableCompanion(
      id: Value(id),
      projectId: Value(projectId),
      layerId: Value(layerId),
      name: Value(name),
      pixels: Value(pixels),
      isVisible: Value(isVisible),
      isLocked: Value(isLocked),
      opacity: Value(opacity),
    );
  }

  factory LayersTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LayersTableData(
      id: serializer.fromJson<int>(json['id']),
      projectId: serializer.fromJson<int>(json['projectId']),
      layerId: serializer.fromJson<String>(json['layerId']),
      name: serializer.fromJson<String>(json['name']),
      pixels: serializer.fromJson<Uint8List>(json['pixels']),
      isVisible: serializer.fromJson<bool>(json['isVisible']),
      isLocked: serializer.fromJson<bool>(json['isLocked']),
      opacity: serializer.fromJson<double>(json['opacity']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'projectId': serializer.toJson<int>(projectId),
      'layerId': serializer.toJson<String>(layerId),
      'name': serializer.toJson<String>(name),
      'pixels': serializer.toJson<Uint8List>(pixels),
      'isVisible': serializer.toJson<bool>(isVisible),
      'isLocked': serializer.toJson<bool>(isLocked),
      'opacity': serializer.toJson<double>(opacity),
    };
  }

  LayersTableData copyWith(
          {int? id,
          int? projectId,
          String? layerId,
          String? name,
          Uint8List? pixels,
          bool? isVisible,
          bool? isLocked,
          double? opacity}) =>
      LayersTableData(
        id: id ?? this.id,
        projectId: projectId ?? this.projectId,
        layerId: layerId ?? this.layerId,
        name: name ?? this.name,
        pixels: pixels ?? this.pixels,
        isVisible: isVisible ?? this.isVisible,
        isLocked: isLocked ?? this.isLocked,
        opacity: opacity ?? this.opacity,
      );
  LayersTableData copyWithCompanion(LayersTableCompanion data) {
    return LayersTableData(
      id: data.id.present ? data.id.value : this.id,
      projectId: data.projectId.present ? data.projectId.value : this.projectId,
      layerId: data.layerId.present ? data.layerId.value : this.layerId,
      name: data.name.present ? data.name.value : this.name,
      pixels: data.pixels.present ? data.pixels.value : this.pixels,
      isVisible: data.isVisible.present ? data.isVisible.value : this.isVisible,
      isLocked: data.isLocked.present ? data.isLocked.value : this.isLocked,
      opacity: data.opacity.present ? data.opacity.value : this.opacity,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LayersTableData(')
          ..write('id: $id, ')
          ..write('projectId: $projectId, ')
          ..write('layerId: $layerId, ')
          ..write('name: $name, ')
          ..write('pixels: $pixels, ')
          ..write('isVisible: $isVisible, ')
          ..write('isLocked: $isLocked, ')
          ..write('opacity: $opacity')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, projectId, layerId, name,
      $driftBlobEquality.hash(pixels), isVisible, isLocked, opacity);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LayersTableData &&
          other.id == this.id &&
          other.projectId == this.projectId &&
          other.layerId == this.layerId &&
          other.name == this.name &&
          $driftBlobEquality.equals(other.pixels, this.pixels) &&
          other.isVisible == this.isVisible &&
          other.isLocked == this.isLocked &&
          other.opacity == this.opacity);
}

class LayersTableCompanion extends UpdateCompanion<LayersTableData> {
  final Value<int> id;
  final Value<int> projectId;
  final Value<String> layerId;
  final Value<String> name;
  final Value<Uint8List> pixels;
  final Value<bool> isVisible;
  final Value<bool> isLocked;
  final Value<double> opacity;
  const LayersTableCompanion({
    this.id = const Value.absent(),
    this.projectId = const Value.absent(),
    this.layerId = const Value.absent(),
    this.name = const Value.absent(),
    this.pixels = const Value.absent(),
    this.isVisible = const Value.absent(),
    this.isLocked = const Value.absent(),
    this.opacity = const Value.absent(),
  });
  LayersTableCompanion.insert({
    this.id = const Value.absent(),
    required int projectId,
    required String layerId,
    required String name,
    required Uint8List pixels,
    this.isVisible = const Value.absent(),
    this.isLocked = const Value.absent(),
    this.opacity = const Value.absent(),
  })  : projectId = Value(projectId),
        layerId = Value(layerId),
        name = Value(name),
        pixels = Value(pixels);
  static Insertable<LayersTableData> custom({
    Expression<int>? id,
    Expression<int>? projectId,
    Expression<String>? layerId,
    Expression<String>? name,
    Expression<Uint8List>? pixels,
    Expression<bool>? isVisible,
    Expression<bool>? isLocked,
    Expression<double>? opacity,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (projectId != null) 'project_id': projectId,
      if (layerId != null) 'layer_id': layerId,
      if (name != null) 'name': name,
      if (pixels != null) 'pixels': pixels,
      if (isVisible != null) 'is_visible': isVisible,
      if (isLocked != null) 'is_locked': isLocked,
      if (opacity != null) 'opacity': opacity,
    });
  }

  LayersTableCompanion copyWith(
      {Value<int>? id,
      Value<int>? projectId,
      Value<String>? layerId,
      Value<String>? name,
      Value<Uint8List>? pixels,
      Value<bool>? isVisible,
      Value<bool>? isLocked,
      Value<double>? opacity}) {
    return LayersTableCompanion(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      layerId: layerId ?? this.layerId,
      name: name ?? this.name,
      pixels: pixels ?? this.pixels,
      isVisible: isVisible ?? this.isVisible,
      isLocked: isLocked ?? this.isLocked,
      opacity: opacity ?? this.opacity,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (projectId.present) {
      map['project_id'] = Variable<int>(projectId.value);
    }
    if (layerId.present) {
      map['layer_id'] = Variable<String>(layerId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (pixels.present) {
      map['pixels'] = Variable<Uint8List>(pixels.value);
    }
    if (isVisible.present) {
      map['is_visible'] = Variable<bool>(isVisible.value);
    }
    if (isLocked.present) {
      map['is_locked'] = Variable<bool>(isLocked.value);
    }
    if (opacity.present) {
      map['opacity'] = Variable<double>(opacity.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LayersTableCompanion(')
          ..write('id: $id, ')
          ..write('projectId: $projectId, ')
          ..write('layerId: $layerId, ')
          ..write('name: $name, ')
          ..write('pixels: $pixels, ')
          ..write('isVisible: $isVisible, ')
          ..write('isLocked: $isLocked, ')
          ..write('opacity: $opacity')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ProjectsTableTable projectsTable = $ProjectsTableTable(this);
  late final $LayersTableTable layersTable = $LayersTableTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [projectsTable, layersTable];
}

typedef $$ProjectsTableTableCreateCompanionBuilder = ProjectsTableCompanion
    Function({
  Value<int> id,
  required String name,
  required int width,
  required int height,
  Value<Uint8List?> thumbnail,
  required DateTime createdAt,
  required DateTime editedAt,
});
typedef $$ProjectsTableTableUpdateCompanionBuilder = ProjectsTableCompanion
    Function({
  Value<int> id,
  Value<String> name,
  Value<int> width,
  Value<int> height,
  Value<Uint8List?> thumbnail,
  Value<DateTime> createdAt,
  Value<DateTime> editedAt,
});

final class $$ProjectsTableTableReferences extends BaseReferences<_$AppDatabase,
    $ProjectsTableTable, ProjectsTableData> {
  $$ProjectsTableTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$LayersTableTable, List<LayersTableData>>
      _layersTableRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.layersTable,
              aliasName: $_aliasNameGenerator(
                  db.projectsTable.id, db.layersTable.projectId));

  $$LayersTableTableProcessedTableManager get layersTableRefs {
    final manager = $$LayersTableTableTableManager($_db, $_db.layersTable)
        .filter((f) => f.projectId.id($_item.id));

    final cache = $_typedResult.readTableOrNull(_layersTableRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$ProjectsTableTableFilterComposer
    extends FilterComposer<_$AppDatabase, $ProjectsTableTable> {
  $$ProjectsTableTableFilterComposer(super.$state);
  ColumnFilters<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get name => $state.composableBuilder(
      column: $state.table.name,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get width => $state.composableBuilder(
      column: $state.table.width,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get height => $state.composableBuilder(
      column: $state.table.height,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<Uint8List> get thumbnail => $state.composableBuilder(
      column: $state.table.thumbnail,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get editedAt => $state.composableBuilder(
      column: $state.table.editedAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ComposableFilter layersTableRefs(
      ComposableFilter Function($$LayersTableTableFilterComposer f) f) {
    final $$LayersTableTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $state.db.layersTable,
        getReferencedColumn: (t) => t.projectId,
        builder: (joinBuilder, parentComposers) =>
            $$LayersTableTableFilterComposer(ComposerState($state.db,
                $state.db.layersTable, joinBuilder, parentComposers)));
    return f(composer);
  }
}

class $$ProjectsTableTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $ProjectsTableTable> {
  $$ProjectsTableTableOrderingComposer(super.$state);
  ColumnOrderings<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get name => $state.composableBuilder(
      column: $state.table.name,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get width => $state.composableBuilder(
      column: $state.table.width,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get height => $state.composableBuilder(
      column: $state.table.height,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<Uint8List> get thumbnail => $state.composableBuilder(
      column: $state.table.thumbnail,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get editedAt => $state.composableBuilder(
      column: $state.table.editedAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

class $$ProjectsTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ProjectsTableTable,
    ProjectsTableData,
    $$ProjectsTableTableFilterComposer,
    $$ProjectsTableTableOrderingComposer,
    $$ProjectsTableTableCreateCompanionBuilder,
    $$ProjectsTableTableUpdateCompanionBuilder,
    (ProjectsTableData, $$ProjectsTableTableReferences),
    ProjectsTableData,
    PrefetchHooks Function({bool layersTableRefs})> {
  $$ProjectsTableTableTableManager(_$AppDatabase db, $ProjectsTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$ProjectsTableTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$ProjectsTableTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<int> width = const Value.absent(),
            Value<int> height = const Value.absent(),
            Value<Uint8List?> thumbnail = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> editedAt = const Value.absent(),
          }) =>
              ProjectsTableCompanion(
            id: id,
            name: name,
            width: width,
            height: height,
            thumbnail: thumbnail,
            createdAt: createdAt,
            editedAt: editedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
            required int width,
            required int height,
            Value<Uint8List?> thumbnail = const Value.absent(),
            required DateTime createdAt,
            required DateTime editedAt,
          }) =>
              ProjectsTableCompanion.insert(
            id: id,
            name: name,
            width: width,
            height: height,
            thumbnail: thumbnail,
            createdAt: createdAt,
            editedAt: editedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$ProjectsTableTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({layersTableRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (layersTableRefs) db.layersTable],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (layersTableRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable: $$ProjectsTableTableReferences
                            ._layersTableRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ProjectsTableTableReferences(db, table, p0)
                                .layersTableRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.projectId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$ProjectsTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ProjectsTableTable,
    ProjectsTableData,
    $$ProjectsTableTableFilterComposer,
    $$ProjectsTableTableOrderingComposer,
    $$ProjectsTableTableCreateCompanionBuilder,
    $$ProjectsTableTableUpdateCompanionBuilder,
    (ProjectsTableData, $$ProjectsTableTableReferences),
    ProjectsTableData,
    PrefetchHooks Function({bool layersTableRefs})>;
typedef $$LayersTableTableCreateCompanionBuilder = LayersTableCompanion
    Function({
  Value<int> id,
  required int projectId,
  required String layerId,
  required String name,
  required Uint8List pixels,
  Value<bool> isVisible,
  Value<bool> isLocked,
  Value<double> opacity,
});
typedef $$LayersTableTableUpdateCompanionBuilder = LayersTableCompanion
    Function({
  Value<int> id,
  Value<int> projectId,
  Value<String> layerId,
  Value<String> name,
  Value<Uint8List> pixels,
  Value<bool> isVisible,
  Value<bool> isLocked,
  Value<double> opacity,
});

final class $$LayersTableTableReferences
    extends BaseReferences<_$AppDatabase, $LayersTableTable, LayersTableData> {
  $$LayersTableTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ProjectsTableTable _projectIdTable(_$AppDatabase db) =>
      db.projectsTable.createAlias(
          $_aliasNameGenerator(db.layersTable.projectId, db.projectsTable.id));

  $$ProjectsTableTableProcessedTableManager? get projectId {
    if ($_item.projectId == null) return null;
    final manager = $$ProjectsTableTableTableManager($_db, $_db.projectsTable)
        .filter((f) => f.id($_item.projectId!));
    final item = $_typedResult.readTableOrNull(_projectIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$LayersTableTableFilterComposer
    extends FilterComposer<_$AppDatabase, $LayersTableTable> {
  $$LayersTableTableFilterComposer(super.$state);
  ColumnFilters<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get layerId => $state.composableBuilder(
      column: $state.table.layerId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get name => $state.composableBuilder(
      column: $state.table.name,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<Uint8List> get pixels => $state.composableBuilder(
      column: $state.table.pixels,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<bool> get isVisible => $state.composableBuilder(
      column: $state.table.isVisible,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<bool> get isLocked => $state.composableBuilder(
      column: $state.table.isLocked,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get opacity => $state.composableBuilder(
      column: $state.table.opacity,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  $$ProjectsTableTableFilterComposer get projectId {
    final $$ProjectsTableTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.projectId,
        referencedTable: $state.db.projectsTable,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) =>
            $$ProjectsTableTableFilterComposer(ComposerState($state.db,
                $state.db.projectsTable, joinBuilder, parentComposers)));
    return composer;
  }
}

class $$LayersTableTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $LayersTableTable> {
  $$LayersTableTableOrderingComposer(super.$state);
  ColumnOrderings<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get layerId => $state.composableBuilder(
      column: $state.table.layerId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get name => $state.composableBuilder(
      column: $state.table.name,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<Uint8List> get pixels => $state.composableBuilder(
      column: $state.table.pixels,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<bool> get isVisible => $state.composableBuilder(
      column: $state.table.isVisible,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<bool> get isLocked => $state.composableBuilder(
      column: $state.table.isLocked,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get opacity => $state.composableBuilder(
      column: $state.table.opacity,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  $$ProjectsTableTableOrderingComposer get projectId {
    final $$ProjectsTableTableOrderingComposer composer =
        $state.composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.projectId,
            referencedTable: $state.db.projectsTable,
            getReferencedColumn: (t) => t.id,
            builder: (joinBuilder, parentComposers) =>
                $$ProjectsTableTableOrderingComposer(ComposerState($state.db,
                    $state.db.projectsTable, joinBuilder, parentComposers)));
    return composer;
  }
}

class $$LayersTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $LayersTableTable,
    LayersTableData,
    $$LayersTableTableFilterComposer,
    $$LayersTableTableOrderingComposer,
    $$LayersTableTableCreateCompanionBuilder,
    $$LayersTableTableUpdateCompanionBuilder,
    (LayersTableData, $$LayersTableTableReferences),
    LayersTableData,
    PrefetchHooks Function({bool projectId})> {
  $$LayersTableTableTableManager(_$AppDatabase db, $LayersTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$LayersTableTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$LayersTableTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> projectId = const Value.absent(),
            Value<String> layerId = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<Uint8List> pixels = const Value.absent(),
            Value<bool> isVisible = const Value.absent(),
            Value<bool> isLocked = const Value.absent(),
            Value<double> opacity = const Value.absent(),
          }) =>
              LayersTableCompanion(
            id: id,
            projectId: projectId,
            layerId: layerId,
            name: name,
            pixels: pixels,
            isVisible: isVisible,
            isLocked: isLocked,
            opacity: opacity,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int projectId,
            required String layerId,
            required String name,
            required Uint8List pixels,
            Value<bool> isVisible = const Value.absent(),
            Value<bool> isLocked = const Value.absent(),
            Value<double> opacity = const Value.absent(),
          }) =>
              LayersTableCompanion.insert(
            id: id,
            projectId: projectId,
            layerId: layerId,
            name: name,
            pixels: pixels,
            isVisible: isVisible,
            isLocked: isLocked,
            opacity: opacity,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$LayersTableTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({projectId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (projectId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.projectId,
                    referencedTable:
                        $$LayersTableTableReferences._projectIdTable(db),
                    referencedColumn:
                        $$LayersTableTableReferences._projectIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$LayersTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $LayersTableTable,
    LayersTableData,
    $$LayersTableTableFilterComposer,
    $$LayersTableTableOrderingComposer,
    $$LayersTableTableCreateCompanionBuilder,
    $$LayersTableTableUpdateCompanionBuilder,
    (LayersTableData, $$LayersTableTableReferences),
    LayersTableData,
    PrefetchHooks Function({bool projectId})>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ProjectsTableTableTableManager get projectsTable =>
      $$ProjectsTableTableTableManager(_db, _db.projectsTable);
  $$LayersTableTableTableManager get layersTable =>
      $$LayersTableTableTableManager(_db, _db.layersTable);
}
