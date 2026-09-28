# Flutter ProGuard Rules
# This file is used to shrink the app size and optimize performance.

# Keep Hive related classes to prevent issues with binary reading/writing
-keep class io.hive.** { *; }
-keep class com.pravera.flutter_foreground_task.** { *; }

# Standard Flutter rules are usually included automatically by the Flutter Gradle Plugin,
# but adding explicit shrinking for production.
-dontwarn io.flutter.embedding.**
