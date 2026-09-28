import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/gamified_flame.dart';

class TimerScreen extends StatefulWidget {
  final String questName;
  final Duration elapsed;
  final Duration goal;
  final int creditSeconds;
  final int streak;
  final bool isRunning;
  final VoidCallback onStartPause;
  final VoidCallback onReset;
  final VoidCallback onNextDay;
  final bool debugMode;

  const TimerScreen({
    super.key,
    required this.questName,
    required this.elapsed,
    required this.goal,
    required this.creditSeconds,
    required this.streak,
    required this.isRunning,
    required this.onStartPause,
    required this.onReset,
    required this.onNextDay,
    this.debugMode = false,
  });

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  bool _zenMode = false;
  double _offsetX = 0.0;
  double _offsetY = 0.0;
  Timer? _shiftTimer;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _startShiftTimer();
  }

  @override
  void dispose() {
    _shiftTimer?.cancel();
    // Restore system UI on exit
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _updateSystemUI(Orientation orientation) {
    if (orientation == Orientation.landscape) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    } else {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
  }

  void _startShiftTimer() {
    _shiftTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (mounted && _zenMode) {
        setState(() {
          _offsetX = (_random.nextDouble() * 20) - 10;
          _offsetY = (_random.nextDouble() * 20) - 10;
        });
      }
    });
  }

  String _fmt(Duration d) {
    final h = d.inHours.toString().padLeft(2, '0');
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  Widget _buildBranding(double fontSize) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: 'Quest',
            style: GoogleFonts.nunito(
              color: Colors.white,
              shadows: [
                Shadow(color: AppColors.primaryGreen.withValues(alpha: 0.5), blurRadius: 8)
              ],
            ),
          ),
          TextSpan(
            text: 'it',
            style: GoogleFonts.nunito(
              color: AppColors.primaryGreen,
              shadows: [
                Shadow(color: AppColors.primaryGreen.withValues(alpha: 0.5), blurRadius: 8)
              ],
            ),
          ),
        ],
      ),
      style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w900, letterSpacing: 1),
    );
  }

  @override
  Widget build(BuildContext context) {
    final progress = widget.goal.inSeconds > 0
        ? (widget.elapsed.inSeconds / widget.goal.inSeconds).clamp(0.0, 1.0)
        : 0.0;
    final isDebt = widget.creditSeconds < 0;
    final isPenalized = isDebt && widget.creditSeconds.abs() >= widget.goal.inSeconds;

    return Scaffold(
      appBar: MediaQuery.of(context).orientation == Orientation.portrait
          ? AppBar(
              title: Opacity(
                opacity: _zenMode ? 0.3 : 1.0,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildBranding(12),
                    Text(
                      'QUEST PROGRESS',
                      style: GoogleFonts.nunito(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
              leading: Opacity(
                opacity: _zenMode ? 0.3 : 1.0,
                child: widget.debugMode
                    ? IconButton(
                        icon: const Icon(Icons.refresh, size: 20),
                        onPressed: widget.onReset,
                      )
                    : const BackButton(),
              ),
              actions: [
                if (widget.debugMode)
                  Opacity(
                    opacity: _zenMode ? 0.3 : 1.0,
                    child: IconButton(
                      icon: const Icon(Icons.skip_next_rounded, size: 28),
                      onPressed: widget.onNextDay,
                    ),
                  ),
                IconButton(
                  icon: Icon(
                    _zenMode ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                    color: _zenMode
                        ? AppColors.primaryGreen.withValues(alpha: 0.8)
                        : AppColors.textSecondary,
                  ),
                  onPressed: () {
                    setState(() {
                      _zenMode = !_zenMode;
                      if (!_zenMode) {
                        _offsetX = 0.0;
                        _offsetY = 0.0;
                      }
                    });
                  },
                  tooltip: 'Toggle Zen Mode',
                ),
              ],
            )
          : null,
      body: OrientationBuilder(
        builder: (context, orientation) {
          _updateSystemUI(orientation);
          if (orientation == Orientation.landscape) {
            return _buildLandscape(progress, isDebt, isPenalized);
          } else {
            return _buildPortrait(progress, isDebt, isPenalized);
          }
        },
      ),
    );
  }

  Widget _buildPortrait(double progress, bool isDebt, bool isPenalized) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return AnimatedContainer(
          duration: const Duration(seconds: 1),
          transform: Matrix4.translationValues(_offsetX, _offsetY, 0),
          padding: const EdgeInsets.fromLTRB(24, 10, 24, 24), // Added bottom padding
          child: Opacity(
            opacity: _zenMode ? 0.4 : 1.0,
            child: SafeArea( // Added SafeArea
              child: Column(
                children: [
                  _buildHeader(isPenalized),
                  const Spacer(flex: 1),
                  _buildProgressRing(constraints.maxWidth * 0.85, progress),
                  const Spacer(flex: 1),
                  _buildStatusBar(isDebt, isPenalized, constraints.maxWidth),
                  const SizedBox(height: 32), // Fixed gap instead of aggressive spacer
                  _buildActionButton(constraints.maxWidth),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLandscape(double progress, bool isDebt, bool isPenalized) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            AnimatedContainer(
              duration: const Duration(seconds: 1),
              transform: Matrix4.translationValues(_offsetX, _offsetY, 0),
              child: Opacity(
                opacity: _zenMode ? 0.4 : 1.0,
                child: Row(
                  children: [
                    Expanded(
                      child: Center(
                        child: _buildProgressRing(constraints.maxHeight * 0.75, progress),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildBranding(16),
                            const SizedBox(height: 8),
                            _buildHeader(isPenalized),
                            const Spacer(),
                            _buildStatusBar(isDebt, isPenalized, constraints.maxWidth * 0.5),
                            const Spacer(),
                            _buildActionButton(constraints.maxWidth * 0.4),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 16,
              left: 16,
              child: Opacity(
                opacity: _zenMode ? 0.3 : 1.0,
                child: widget.debugMode
                    ? IconButton(
                        icon: const Icon(Icons.refresh, color: AppColors.textSecondary),
                        onPressed: widget.onReset,
                      )
                    : IconButton(
                        icon: const Icon(Icons.arrow_back, color: AppColors.textSecondary),
                        onPressed: () => Navigator.pop(context),
                      ),
              ),
            ),
            Positioned(
              top: 16,
              right: 16,
              child: Row(
                children: [
                  if (widget.debugMode)
                    Opacity(
                      opacity: _zenMode ? 0.3 : 1.0,
                      child: IconButton(
                        icon: const Icon(Icons.skip_next_rounded, color: AppColors.textSecondary, size: 28),
                        onPressed: widget.onNextDay,
                      ),
                    ),
                  IconButton(
                    icon: Icon(
                      _zenMode ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                      color: _zenMode
                          ? AppColors.primaryGreen.withValues(alpha: 0.8)
                          : AppColors.textSecondary,
                    ),
                    onPressed: () {
                      setState(() {
                        _zenMode = !_zenMode;
                        if (!_zenMode) {
                          _offsetX = 0.0;
                          _offsetY = 0.0;
                        }
                      });
                    },
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHeader(bool isPenalized) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            widget.questName,
            textAlign: TextAlign.center,
            style: GoogleFonts.nunito(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              GamifiedFlame(
                streak: widget.streak,
                isBroken: isPenalized,
                size: 20,
              ),
              const SizedBox(width: 4),
              Text(
                isPenalized ? 'BROKEN' : '${widget.streak}',
                style: GoogleFonts.nunito(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: isPenalized ? AppColors.errorRed.withValues(alpha: 0.5) : null,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProgressRing(double size, double progress) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: CircularProgressIndicator(
            value: progress,
            strokeWidth: size * 0.08,
            backgroundColor: AppColors.surface,
            valueColor: AlwaysStoppedAnimation(
              progress >= 1.0 ? AppColors.accentOrange : AppColors.primaryGreen,
            ),
            strokeCap: StrokeCap.round,
          ),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _fmt(widget.elapsed),
              style: GoogleFonts.nunito(
                fontSize: size * 0.2,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              'GOAL ${_fmt(widget.goal)}',
              style: GoogleFonts.nunito(
                fontSize: size * 0.05,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusBar(bool isDebt, bool isPenalized, double maxWidth) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              isDebt ? 'DEBT STATUS' : 'BANKED CREDIT',
              style: GoogleFonts.nunito(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: isDebt ? AppColors.errorRed : AppColors.secondaryBlue,
                letterSpacing: 1,
              ),
            ),
            Text(
              _fmt(Duration(seconds: widget.creditSeconds.abs())),
              style: GoogleFonts.nunito(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: isDebt ? AppColors.errorRed : AppColors.secondaryBlue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              Container(
                height: 16,
                width: double.infinity,
                color: AppColors.surface,
              ),
              LayoutBuilder(
                builder: (context, barConstraints) {
                  final double ratio =
                      (widget.creditSeconds.abs() / widget.goal.inSeconds)
                          .clamp(0.0, 1.0);
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: 16,
                    width: barConstraints.maxWidth * ratio,
                    decoration: BoxDecoration(
                      color: isDebt ? AppColors.errorRed : AppColors.secondaryBlue,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        if (isPenalized)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.warning_amber_rounded,
                        color: AppColors.errorRed, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      'SYSTEM PENALTY ACTIVE',
                      style: GoogleFonts.nunito(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: AppColors.errorRed,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'YOUR STREAK WILL BE RESET ON NEXT SETTLEMENT',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.nunito(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: AppColors.errorRed.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildActionButton(double width) {
    return SizedBox(
      width: width,
      height: 64,
      child: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: widget.isRunning
                  ? const Color(0xFFC42C2C).withValues(alpha: _zenMode ? 0.2 : 1.0)
                  : const Color(0xFF46A302).withValues(alpha: _zenMode ? 0.2 : 1.0),
              offset: const Offset(0, 4),
            ),
          ],
          borderRadius: BorderRadius.circular(20),
        ),
        child: ElevatedButton(
          onPressed: widget.onStartPause,
          style: ElevatedButton.styleFrom(
            backgroundColor: widget.isRunning ? AppColors.errorRed : AppColors.primaryGreen,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            textStyle: GoogleFonts.nunito(
              fontWeight: FontWeight.w900,
              fontSize: 20,
              letterSpacing: 1.5,
            ),
          ),
          child: Text(widget.isRunning ? 'PAUSE' : 'CONTINUE'),
        ),
      ),
    );
  }
}
