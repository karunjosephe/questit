import 'package:flutter_foreground_task/flutter_foreground_task.dart';

class ForegroundTimerService {
  static void init() {
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'questit_timer_channel',
        channelName: 'Active Quest Timer',
        channelDescription: 'Shows your current quest progress.',
        channelImportance: NotificationChannelImportance.MAX,
        priority: NotificationPriority.MAX,
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: true,
        playSound: false,
      ),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.repeat(1000),
        autoRunOnBoot: false,
        allowWakeLock: true,
        allowWifiLock: false,
      ),
    );
  }

  static Future<void> start(String questName, Duration initialElapsed) async {
    if (await FlutterForegroundTask.isRunningService) {
      await FlutterForegroundTask.updateService(
        notificationTitle: 'Questit: $questName',
        notificationText: 'Quest in progress...',
      );
      return;
    }

    await FlutterForegroundTask.startService(
      notificationTitle: 'Questit: $questName',
      notificationText: 'Quest in progress...',
      notificationIcon: null,
    );
  }

  static Future<void> stop() async {
    await FlutterForegroundTask.stopService();
  }
}
