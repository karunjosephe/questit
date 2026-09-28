import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/task.dart';
import '../services/storage_service.dart';
import '../services/credit_engine.dart';

import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:vibration/vibration.dart';
import '../services/foreground/foreground_timer_service.dart';

class TaskState {
  final Task? task;
  final bool isRunning;
  final int tick;

  TaskState({
    this.task,
    this.isRunning = false,
    this.tick = 0,
  });

  TaskState copyWith({
    Task? task,
    bool? isRunning,
    int? tick,
  }) {
    return TaskState(
      task: task ?? this.task,
      isRunning: isRunning ?? this.isRunning,
      tick: tick ?? this.tick,
    );
  }
}

final storageServiceProvider = Provider((ref) => StorageService());

final taskProvider = StateNotifierProvider<TaskNotifier, TaskState>((ref) {
  return TaskNotifier(ref.read(storageServiceProvider));
});

class TaskNotifier extends StateNotifier<TaskState> {
  final StorageService _storageService;
  Timer? _timer;

  TaskNotifier(this._storageService) : super(TaskState()) {
    _loadInitialTask();
  }

  void _loadInitialTask() {
    final tasks = _storageService.getAllTasks();
    if (tasks.isNotEmpty) {
      state = state.copyWith(task: tasks.first);
      _checkAndSettleIfNewDay();
    }
  }

  List<Task> getAllTasks() => _storageService.getAllTasks();

  void selectTask(String id) {
    _timer?.cancel();
    final task = _storageService.getTask(id);
    if (task != null) {
      state = TaskState(task: task, isRunning: false, tick: state.tick + 1);
      _checkAndSettleIfNewDay();
    }
  }

  void createTask(String name, int dailyGoalSeconds) {
    final newTask = Task(
      id: const Uuid().v4(),
      name: name,
      dailyGoalSeconds: dailyGoalSeconds,
      lastActiveDate: DateTime.now(),
    );
    _storageService.saveTask(newTask);
    state = state.copyWith(tick: state.tick + 1); // Refresh UI list
  }

  void updateTask(String id, String newName, int newGoalSeconds) {
    final task = _storageService.getTask(id);
    if (task != null) {
      task.name = newName;
      task.dailyGoalSeconds = newGoalSeconds;
      task.save();
      state = state.copyWith(tick: state.tick + 1);
    }
  }

  void deleteTask(String id) {
    final task = _storageService.getTask(id);
    if (task != null) {
      task.delete();
      state = state.copyWith(tick: state.tick + 1);
    }
  }

  Future<void> resetAllData() async {
    _timer?.cancel();
    final task = state.task;
    if (task != null) {
      task.todayElapsedSeconds = 0;
      task.creditBalanceSeconds = 0;
      task.currentStreak = 0;
      task.lastActiveDate = DateTime.now();
      await task.save();
      state = state.copyWith(task: task, isRunning: false, tick: state.tick + 1);
    }
  }

  Future<void> simulateNextDay() async {
    final task = state.task;
    if (task == null) return;

    if (_timer?.isActive ?? false) {
      _timer?.cancel();
    }

    final result = CreditEngine.settleDay(
      dailyGoalSeconds: task.dailyGoalSeconds,
      elapsedSeconds: task.todayElapsedSeconds,
      currentCreditBalance: task.creditBalanceSeconds,
    );

    task.creditBalanceSeconds = result.newCreditBalance;
    task.isPenalized = result.penaltyTriggered;
    if (result.streakBroken) {
      task.currentStreak = 0;
    } else if (result.streakIncremented) {
      task.currentStreak = (task.currentStreak ?? 0) + 1;
    }
    task.todayElapsedSeconds = 0;
    task.lastActiveDate = DateTime.now();
    
    await task.save();
    state = state.copyWith(task: task, isRunning: false, tick: state.tick + 1);
  }

  void _checkAndSettleIfNewDay() {
    final task = state.task;
    if (task == null) return;

    final now = DateTime.now();
    final last = task.lastActiveDate;
    final today = DateTime(now.year, now.month, now.day);
    final lastActiveDay = DateTime(last.year, last.month, last.day);
    
    final daysPassed = today.difference(lastActiveDay).inDays;

    if (daysPassed > 0) {
      for (int i = 0; i < daysPassed; i++) {
        final int dailyElapsed = (i == 0) ? task.todayElapsedSeconds : 0;
        final result = CreditEngine.settleDay(
          dailyGoalSeconds: task.dailyGoalSeconds,
          elapsedSeconds: dailyElapsed,
          currentCreditBalance: task.creditBalanceSeconds,
        );
        task.creditBalanceSeconds = result.newCreditBalance;
        task.isPenalized = result.penaltyTriggered;
        if (result.streakBroken) {
          task.currentStreak = 0;
        } else if (result.streakIncremented) {
          task.currentStreak = (task.currentStreak ?? 0) + 1;
        }
      }
      task.todayElapsedSeconds = 0;
      task.lastActiveDate = now;
      task.save();
      state = state.copyWith(task: task, tick: state.tick + 1);
    }
  }

  void toggleTimer() {
    if (_timer?.isActive ?? false) {
      _timer?.cancel();
      WakelockPlus.disable();
      Vibration.vibrate(duration: 50); // Short tap feedback
      ForegroundTimerService.stop();
      state = state.copyWith(isRunning: false);
    } else {
      if (state.task == null) return;
      _checkAndSettleIfNewDay();
      
      WakelockPlus.enable();
      Vibration.vibrate(duration: 80); // Distinct start feedback
      
      state = state.copyWith(isRunning: true);
      
      ForegroundTimerService.start(
        state.task!.name, 
        Duration(seconds: state.task!.todayElapsedSeconds)
      );

      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        final currentTask = state.task;
        if (currentTask != null) {
          final now = DateTime.now();
          if (now.day != currentTask.lastActiveDate.day) {
            _checkAndSettleIfNewDay();
            return;
          }

          currentTask.todayElapsedSeconds++;
          
          // Satisfying vibration when goal is hit
          if (currentTask.todayElapsedSeconds == currentTask.dailyGoalSeconds) {
            Vibration.vibrate(pattern: [0, 200, 100, 200, 100, 400]); 
          }

          // Apply credit cap in real-time
          if (currentTask.todayElapsedSeconds > currentTask.dailyGoalSeconds) {
             if (currentTask.creditBalanceSeconds < currentTask.dailyGoalSeconds) {
                currentTask.creditBalanceSeconds++;
             }
          }

          currentTask.save();
          state = state.copyWith(
            task: currentTask, 
            tick: state.tick + 1,
            isRunning: true,
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
