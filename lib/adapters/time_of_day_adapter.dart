import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

// part 'time_of_day_adapter.g.dart'; // If you want to use HiveGenerator (optional)

class TimeOfDayAdapter extends TypeAdapter<TimeOfDay> {
  @override
  final int typeId = 55;

  @override
  TimeOfDay read(BinaryReader reader) {
    final hour = reader.readInt();
    final minute = reader.readInt();
    return TimeOfDay(hour: hour, minute: minute);
  }

  @override
  void write(BinaryWriter writer, TimeOfDay obj) {
    writer.writeInt(obj.hour);
    writer.writeInt(obj.minute);
  }
}
