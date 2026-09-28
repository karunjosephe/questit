# Questit - Personal Focus & Time Accountability System

Questit is a Flutter-based mobile application designed to gamify daily productivity and focus using a disciplined "time-banking" philosophy. Instead of acting as a passive stopwatch, Questit introduces consequence to time management by allowing users to lend, borrow, and track focus time across custom daily quests.

---

## Core Mechanics

### 1. The Time Bank (Lend & Borrow)
Questit is built around a dynamic balance system for focus time:
*   **Lending (Credit)**: Working beyond a quest's daily goal adds the surplus time to your **Banked Credit**. This credit can be used to cushion future days where you might fall short.
*   **Borrowing (Debt)**: Falling short of a daily goal generates **Debt**. Debt must be repaid in subsequent sessions to maintain your standing.
*   **Real-Time Settlement**: Surplus time worked is added to the bank in real-time, allowing users to watch their credit balance grow during an active session.

### 2. The One-Day Boundary
To enforce discipline and prevent system abuse, both Credit and Debt are strictly capped at **one full daily quota** for each quest.
*   **Credit Cap**: You cannot bank more than 24 hours (or one daily goal) of surplus time.
*   **Debt Cap**: You cannot owe more than one daily goal's worth of time. 

### 3. System Penalty & Streak Evolution
*   **System Penalty**: If a quest's debt reaches the maximum limit (1 full goal duration), the System Penalty triggers upon the next daily settlement, permanently resetting the streak to 0.
*   **Streak Evolution**: Active streaks increase daily as goals are met. The streak indicator evolves through distinct visual states as milestone counts are reached, ending in a high-tier status for long-term consistency.

---

## Technical Architecture & Features

### Architecture & State Management
*   **State Management**: Built using `flutter_riverpod` with `StateNotifier` to maintain decoupled business logic and real-time state synchronization across screens.
*   **Storage Engine**: Uses `hive` and `hive_flutter` for lightweight, low-latency local persistence of task models and settlement logs.
*   **Credit Engine**: A pure Dart, framework-agnostic logic layer (`CreditEngine`) responsible for settlement calculations, debt-capping, and streak evaluation, ensuring complete unit-test coverage.

### Android Foreground Service
*   **Background Timing**: Integrates `flutter_foreground_task` to run an ongoing, high-priority Android Foreground Service (`specialUse` type).
*   **System Bar Integration**: Triggers the ongoing status bar indicator (active task pill on Samsung/Pixel devices) while a quest is running.
*   **Battery Optimization**: Uses passive timing mechanisms and state-driven updates to minimize background battery consumption.

### AMOLED Dark & Standby UX
*   **AMOLED Dark Theme**: Designed with a `#000000` background to conserve battery on OLED screens and eliminate workspace distractions.
*   **Burn-in Protection (Zen Mode)**: Features an optional Zen Mode that dims the interface to 40% opacity and applies a subtle, randomized **pixel-shifting matrix** every 60 seconds to prevent static image retention.
*   **Standby Landscape Mode**: Rotating the device horizontally enters an edge-to-edge split view. The left side houses a large, centered progress ring, while the right side displays quest metrics and controls.
*   **Screen Wake Lock**: Automatically prevents screen timeout during active timing sessions using `wakelock_plus`.
*   **Haptic Engine**: Provides tactile feedback for control actions and a victory vibration pattern upon daily goal completion via `vibration`.

---

## Project Structure

```
lib/
├── main.dart                 # Application entry point & route definitions
├── models/
│   ├── task.dart             # Hive task model (goal, balance, streak)
│   └── daily_log.dart        # Settlement logs
├── services/
│   ├── credit_engine.dart    # Pure Dart banking & debt-cap logic
│   ├── storage_service.dart   # Hive persistence wrapper
│   ├── tutorial_service.dart  # Onboarding state management
│   └── foreground/           # Android foreground service lifecycle
├── providers/
│   └── task_provider.dart    # Riverpod state notifier for active quests
├── screens/
│   ├── splash_screen.dart    # Animated branding entry
│   ├── tutorial_screen.dart  # Interactive onboarding & system guide
│   ├── home_screen.dart      # Quest Board (multi-task management)
│   └── timer_screen.dart     # Active quest timer (Portrait & Standby)
├── widgets/
│   └── gamified_flame.dart   # Evolving streak flame component
└── theme/
    └── app_theme.dart        # AMOLED dark theme & color palette
```

---

## Getting Started

### Prerequisites
*   Flutter SDK (3.x or higher)
*   Android SDK (API level 26 or higher recommended)

### Installation
1. Clone the repository:
   ```bash
   git clone https://github.com/YOUR_USERNAME/questit.git
   cd questit
   ```
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Run code generation (for Hive adapters):
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```
4. Launch application:
   ```bash
   flutter run
   ```

---

## Production Build & Shrinking
To build an optimized, obfuscated production Android App Bundle:
```bash
flutter build appbundle --release --obfuscate --split-debug-info=build/debug-info
```
*Note: Resource shrinking and ProGuard minification are configured in `android/app/build.gradle.kts` to minimize application binary size.*
