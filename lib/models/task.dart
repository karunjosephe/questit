import 'package:hive/hive.dart';

part 'task.g.dart';

@HiveType(typeId: 0)
class Task extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  int dailyGoalSeconds; // e.g., 3600 for 1 hour

  @HiveField(3)
  int creditBalanceSeconds; // positive = banked credit, negative = debt

  @HiveField(4)
  int todayElapsedSeconds; // resets each day

  @HiveField(5)
  DateTime lastActiveDate;

  @HiveField(6)
  bool isPenalized; // true if debt cap was hit

  @HiveField(7)
  int? currentStreak; // Made nullable for safe migration

  Task({
    required this.id,
    required this.name,
    required this.dailyGoalSeconds,
    this.creditBalanceSeconds = 0,
    this.todayElapsedSeconds = 0,
    required this.lastActiveDate,
    this.isPenalized = false,
    this.currentStreak = 0,
  });
}
