import 'dart:typed_data';

import 'package:hive/hive.dart';
import 'package:equatable/equatable.dart';

class Layer extends HiveObject with EquatableMixin {
  final int id;
  final String name;
  final Uint32List pixels;
  final bool isVisible;
  final bool isLocked;
  final double opacity;

  Layer(
    this.id,
    this.name,
    this.pixels, {
    this.isVisible = true,
    this.isLocked = false,
    this.opacity = 1.0,
  });

  Layer copyWith({
    String? name,
    Uint32List? pixels,
    bool? isVisible,
    bool? isLocked,
    double? opacity,
  }) {
    return Layer(
      id,
      name ?? this.name,
      pixels ?? this.pixels,
      isVisible: isVisible ?? this.isVisible,
      isLocked: isLocked ?? this.isLocked,
      opacity: opacity ?? this.opacity,
    );
  }

  @override
  List<Object?> get props => [name, pixels, isVisible, isLocked, opacity];
}

class LayerAdapter extends TypeAdapter<Layer> {
  @override
  final int typeId = 1;

  @override
  Layer read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Layer(
      fields[0] as int,
      fields[1] as String,
      Uint32List.fromList(fields[2] as List<int>),
      isVisible: fields[3] as bool,
      isLocked: fields[4] as bool,
      opacity: fields[5] as double,
    );
  }

  @override
  void write(BinaryWriter writer, Layer obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.pixels)
      ..writeByte(3)
      ..write(obj.isVisible)
      ..writeByte(4)
      ..write(obj.isLocked)
      ..writeByte(5)
      ..write(obj.opacity);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LayerAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
