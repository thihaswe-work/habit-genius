import 'package:hive_ce/hive_ce.dart';

import '../../models/habit.dart';

class HabitProgressTypeAdapter extends TypeAdapter<HabitProgressType> {
  @override
  final int typeId = 0;

  @override
  HabitProgressType read(BinaryReader reader) {
    final value = reader.readByte();
    return HabitProgressType.values[value];
  }

  @override
  void write(BinaryWriter writer, HabitProgressType obj) {
    writer.writeByte(obj.index);
  }
}

class HabitAdapter extends TypeAdapter<Habit> {
  @override
  final int typeId = 1;

  @override
  Habit read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Habit(
      id: fields[0] as String,
      name: fields[1] as String,
      emoji: fields[2] as String?,
      progressType: fields[3] as HabitProgressType,
      target: fields[4] as int,
      unit: fields[5] as String?,
      createdAt: fields[6] as DateTime,
      progressByDate: (fields[7] as Map).cast<String, int>(),
      isArchived: fields[8] as bool? ?? false,
    );
  }

  @override
  void write(BinaryWriter writer, Habit obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.emoji)
      ..writeByte(3)
      ..write(obj.progressType)
      ..writeByte(4)
      ..write(obj.target)
      ..writeByte(5)
      ..write(obj.unit)
      ..writeByte(6)
      ..write(obj.createdAt)
      ..writeByte(7)
      ..write(obj.progressByDate)
      ..writeByte(8)
      ..write(obj.isArchived);
  }
}
