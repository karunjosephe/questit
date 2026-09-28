import 'package:hive_flutter/hive_flutter.dart';
import '../models/task.dart';
import '../models/daily_log.dart';

class StorageService {
  static const String taskBoxName = 'tasks';
  static const String logBoxName = 'daily_logs';

  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(TaskAdapter());
    Hive.registerAdapter(DailyLogAdapter());
    await Hive.openBox<Task>(taskBoxName);
    await Hive.openBox<DailyLog>(logBoxName);
  }

  Box<Task> get taskBox => Hive.box<Task>(taskBoxName);
  Box<DailyLog> get logBox => Hive.box<DailyLog>(logBoxName);

  Future<void> saveTask(Task task) async {
    if (task.isInBox) {
      await task.save();
    } else {
      await taskBox.put(task.id, task);
    }
  }

  Task? getTask(String id) => taskBox.get(id);

  List<Task> getAllTasks() => taskBox.values.toList();

  Future<void> saveLog(DailyLog log) async {
    await logBox.add(log);
  }
}
