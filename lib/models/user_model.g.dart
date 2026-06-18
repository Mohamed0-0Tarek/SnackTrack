// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserModelAdapter extends TypeAdapter<UserModel> {
  @override
  final int typeId = 0;

  @override
  UserModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserModel(
      id: fields[0] as String,
      name: fields[1] as String,
      email: fields[2] as String,
      avatarUrl: fields[3] as String,
      token: fields[4] as String,
      activeStreak: fields[5] as int,
      entries: fields[6] as int,
      bio: fields[7] as String,
      age: fields[8] as int?,
      weight: fields[9] as double?,
      height: fields[10] as double?,
      objective: fields[11] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, UserModel obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.email)
      ..writeByte(3)
      ..write(obj.avatarUrl)
      ..writeByte(4)
      ..write(obj.token)
      ..writeByte(5)
      ..write(obj.activeStreak)
      ..writeByte(6)
      ..write(obj.entries)
      ..writeByte(7)
      ..write(obj.bio)
      ..writeByte(8)
      ..write(obj.age)
      ..writeByte(9)
      ..write(obj.weight)
      ..writeByte(10)
      ..write(obj.height)
      ..writeByte(11)
      ..write(obj.objective);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
