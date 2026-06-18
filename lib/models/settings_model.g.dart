// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SettingsModelAdapter extends TypeAdapter<SettingsModel> {
  @override
  final int typeId = 1;

  @override
  SettingsModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SettingsModel(
      darkMode: fields[0] as bool,
      notifFrequency: fields[1] as double,
      incognito: fields[2] as bool,
      goalCalories: fields[3] as int,
      goalProtein: fields[4] as double,
      goalCarbs: fields[5] as double,
      goalFat: fields[6] as double,
    );
  }

  @override
  void write(BinaryWriter writer, SettingsModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.darkMode)
      ..writeByte(1)
      ..write(obj.notifFrequency)
      ..writeByte(2)
      ..write(obj.incognito)
      ..writeByte(3)
      ..write(obj.goalCalories)
      ..writeByte(4)
      ..write(obj.goalProtein)
      ..writeByte(5)
      ..write(obj.goalCarbs)
      ..writeByte(6)
      ..write(obj.goalFat);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SettingsModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
