import 'package:hive/hive.dart';

part 'daily_log.g.dart';

@HiveType(typeId: 1)
class DailyLog extends HiveObject {
  @HiveField(0)
  String taskId;

  @HiveField(1)
  DateTime date;

  @HiveField(2)
  int elapsedSeconds;

  @HiveField(3)
  int goalSeconds;

  DailyLog({
    required this.taskId,
    required this.date,
    required this.elapsedSeconds,
    required this.goalSeconds,
  });
}
