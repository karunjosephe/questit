import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/task_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/gamified_flame.dart';
import '../services/tutorial/tutorial_service.dart';
import 'timer_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _showDebugButtons = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkFirstTime();
    });
  }

  Future<void> _checkFirstTime() async {
    if (await TutorialService.shouldShowTutorial()) {
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed('/tutorial');
    }
  }

  void _showTutorial(BuildContext context) {
    Navigator.of(context).pushNamed('/tutorial');
  }

  @override
  Widget build(BuildContext context) {
    // Watch taskProvider to trigger rebuilds when tasks are added
    ref.watch(taskProvider);
    final taskNotifier = ref.read(taskProvider.notifier);
    final tasks = taskNotifier.getAllTasks();

    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onLongPress: () {
            setState(() => _showDebugButtons = !_showDebugButtons);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(_showDebugButtons ? 'Debug mode enabled' : 'Debug mode disabled'),
                duration: const Duration(seconds: 1),
              ),
            );
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'Quest',
                      style: GoogleFonts.nunito(
                        color: Colors.white,
                        shadows: [Shadow(color: AppColors.primaryGreen.withValues(alpha: 0.5), blurRadius: 8)],
                      ),
                    ),
                    TextSpan(
                      text: 'it',
                      style: GoogleFonts.nunito(
                        color: AppColors.primaryGreen,
                        shadows: [Shadow(color: AppColors.primaryGreen.withValues(alpha: 0.5), blurRadius: 8)],
                      ),
                    ),
                  ],
                ),
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 2),
              ),
              Text('QUEST BOARD', style: GoogleFonts.nunito(fontWeight: FontWeight.w900, fontSize: 18)),
            ],
          ),
        ),
        centerTitle: true,
        actions: [
          if (_showDebugButtons) ...[
            IconButton(
              icon: const Icon(Icons.refresh, size: 20),
              onPressed: () {
                taskNotifier.resetAllData();
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('All data reset')));
              },
            ),
            IconButton(
              icon: const Icon(Icons.skip_next_rounded, size: 28),
              onPressed: () {
                taskNotifier.simulateNextDay();
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Simulated next day')));
              },
            ),
          ],
          IconButton(
            icon: const Icon(Icons.help_outline_rounded, color: AppColors.secondaryBlue),
            onPressed: () => _showTutorial(context),
            tooltip: 'How to play',
          ),
        ],
      ),
      body: tasks.isEmpty
          ? _buildEmptyState(context)
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];
                
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: InkWell(
                    onTap: () {
                      taskNotifier.selectTask(task.id);
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => _TimerViewWrapper(debugMode: _showDebugButtons),
                        ),
                      );
                    },
                    onLongPress: () => _showTaskOptions(context, ref, task),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          GamifiedFlame(
                            streak: task.currentStreak ?? 0,
                            isBroken: task.isPenalized,
                            size: 32,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  task.name,
                                  style: GoogleFonts.nunito(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                Row(
                                  children: [
                                    Text(
                                      'Goal: ${task.dailyGoalSeconds ~/ 60}m • Streak: ${task.currentStreak ?? 0}d',
                                      style: GoogleFonts.nunito(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    // Tiny visual progress bar
                                    Expanded(
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(4),
                                        child: LinearProgressIndicator(
                                          value: (task.todayElapsedSeconds / task.dailyGoalSeconds).clamp(0.0, 1.0),
                                          backgroundColor: AppColors.border,
                                          valueColor: AlwaysStoppedAnimation(
                                            task.todayElapsedSeconds >= task.dailyGoalSeconds 
                                                ? AppColors.accentOrange 
                                                : AppColors.primaryGreen,
                                          ),
                                          minHeight: 6,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateTaskDialog(context, ref),
        label: Text('NEW QUEST', style: GoogleFonts.nunito(fontWeight: FontWeight.w900)),
        icon: const Icon(Icons.add),
        backgroundColor: AppColors.primaryGreen,
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assignment_late_outlined, size: 80, color: AppColors.border),
          const SizedBox(height: 16),
          Text(
            'No Active Quests',
            style: GoogleFonts.nunito(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first daily challenge!',
            style: GoogleFonts.nunito(
              color: AppColors.textSecondary.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  void _showCreateTaskDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final minutesController = TextEditingController(text: '30');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('NEW DAILY QUEST', style: GoogleFonts.nunito(fontWeight: FontWeight.w900)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Quest Name',
                labelStyle: GoogleFonts.nunito(),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: minutesController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Daily Goal (Minutes)',
                labelStyle: GoogleFonts.nunito(),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('CANCEL', style: GoogleFonts.nunito(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              final name = nameController.text.trim();
              final mins = int.tryParse(minutesController.text) ?? 30;
              if (name.isNotEmpty) {
                ref.read(taskProvider.notifier).createTask(name, mins * 60);
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text('CREATE', style: GoogleFonts.nunito(fontWeight: FontWeight.w900, color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showTaskOptions(BuildContext context, WidgetRef ref, dynamic task) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 12),
          ListTile(
            leading: const Icon(Icons.edit_rounded, color: AppColors.secondaryBlue),
            title: Text('Edit Quest', style: GoogleFonts.nunito(fontWeight: FontWeight.w800)),
            onTap: () {
              Navigator.pop(context);
              _showEditTaskDialog(context, ref, task);
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline_rounded, color: AppColors.errorRed),
            title: Text('Delete Quest', style: GoogleFonts.nunito(fontWeight: FontWeight.w800, color: AppColors.errorRed)),
            onTap: () {
              Navigator.pop(context);
              _showDeleteConfirmation(context, ref, task);
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  void _showEditTaskDialog(BuildContext context, WidgetRef ref, dynamic task) {
    final nameController = TextEditingController(text: task.name);
    final minutesController = TextEditingController(text: (task.dailyGoalSeconds ~/ 60).toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('EDIT QUEST', style: GoogleFonts.nunito(fontWeight: FontWeight.w900)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Quest Name',
                labelStyle: GoogleFonts.nunito(),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: minutesController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Daily Goal (Minutes)',
                labelStyle: GoogleFonts.nunito(),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('CANCEL', style: GoogleFonts.nunito(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              final name = nameController.text.trim();
              final mins = int.tryParse(minutesController.text) ?? 30;
              final newGoalSeconds = mins * 60;

              if (task.creditBalanceSeconds < 0 && task.creditBalanceSeconds.abs() > newGoalSeconds) {
                Navigator.pop(context);
                _showDebtWarning(context, task.creditBalanceSeconds.abs() ~/ 60);
                return;
              }

              if (name.isNotEmpty) {
                ref.read(taskProvider.notifier).updateTask(task.id, name, newGoalSeconds);
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text('SAVE', style: GoogleFonts.nunito(fontWeight: FontWeight.w900, color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showDebtWarning(BuildContext context, int currentDebtMins) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: AppColors.errorRed),
            const SizedBox(width: 8),
            Text('RESTRICTION', style: GoogleFonts.nunito(fontWeight: FontWeight.w900, color: AppColors.errorRed)),
          ],
        ),
        content: Text(
          'You currently have ${currentDebtMins}m of debt. You cannot reduce your goal below your current debt. Please settle your debt first!',
          style: GoogleFonts.nunito(fontWeight: FontWeight.w700),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.errorRed,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text('UNDERSTOOD', style: GoogleFonts.nunito(fontWeight: FontWeight.w900, color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref, dynamic task) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('DELETE QUEST?', style: GoogleFonts.nunito(fontWeight: FontWeight.w900)),
        content: Text(
          'Are you sure you want to delete "${task.name}"? This will permanently erase your streak and banked progress.',
          style: GoogleFonts.nunito(fontWeight: FontWeight.w700),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('CANCEL', style: GoogleFonts.nunito(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(taskProvider.notifier).deleteTask(task.id);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.errorRed,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text('DELETE', style: GoogleFonts.nunito(fontWeight: FontWeight.w900, color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _TutorialDialog extends StatefulWidget {
  const _TutorialDialog();

  @override
  State<_TutorialDialog> createState() => _TutorialDialogState();
}

class _TutorialDialogState extends State<_TutorialDialog> {
  int _currentPage = 0;
  final PageController _pageController = PageController();

  final List<Map<String, String>> _pages = [
    {
      'title': 'Welcome to Questit! 🦉',
      'content': 'Gamify your daily focus and build lasting habits with a unique credit-banking system.',
    },
    {
      'title': 'The Quest System ⚔️',
      'content': 'Create quests with daily time goals. Each quest tracks its own streak and banking status.',
    },
    {
      'title': 'Banking & Debt 📊',
      'content': 'Work extra to "bank" credit for future days. Fall short, and you\'ll accumulate "debt" that increases tomorrow\'s goal!',
    },
    {
      'title': 'System Penalty 💔',
      'content': 'Don\'t let your debt reach the limit! If you hit the debt cap, your streak will break and you\'ll get a penalty.',
    },
    {
      'title': 'Evolution 💎',
      'content': 'Watch your streak flame evolve from yellow to orange, red, and finally glowing blue or gold!',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 200,
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (idx) => setState(() => _currentPage = idx),
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _pages[index]['title']!,
                        style: GoogleFonts.nunito(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: AppColors.primaryGreen,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _pages[index]['content']!,
                        style: GoogleFonts.nunito(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentPage == index
                        ? AppColors.primaryGreen
                        : AppColors.border,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        if (_currentPage < _pages.length - 1)
          ElevatedButton(
            onPressed: () => _pageController.nextPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text('NEXT', style: GoogleFonts.nunito(fontWeight: FontWeight.w900, color: Colors.white)),
          )
        else
          ElevatedButton(
            onPressed: () {
              TutorialService.markTutorialAsSeen();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text('START QUESTING!', style: GoogleFonts.nunito(fontWeight: FontWeight.w900, color: Colors.white)),
          ),
      ],
    );
  }
}

class _TimerViewWrapper extends ConsumerWidget {
  final bool debugMode;
  const _TimerViewWrapper({required this.debugMode});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final taskState = ref.watch(taskProvider);
    final task = taskState.task;
    final taskNotifier = ref.read(taskProvider.notifier);

    if (task == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return TimerScreen(
      questName: task.name,
      elapsed: Duration(seconds: task.todayElapsedSeconds),
      goal: Duration(seconds: task.dailyGoalSeconds),
      creditSeconds: task.creditBalanceSeconds,
      streak: task.currentStreak ?? 0,
      isRunning: taskState.isRunning,
      onStartPause: () => taskNotifier.toggleTimer(),
      onReset: () => taskNotifier.resetAllData(), // Reset current only
      onNextDay: () => taskNotifier.simulateNextDay(),
      debugMode: debugMode,
    );
  }
}
