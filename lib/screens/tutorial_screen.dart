import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../services/tutorial/tutorial_service.dart';
import '../widgets/gamified_flame.dart';

class TutorialScreen extends StatefulWidget {
  const TutorialScreen({super.key});

  @override
  State<TutorialScreen> createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;
  double _demoCredit = 0.0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          PageView(
            controller: _controller,
            onPageChanged: (idx) => setState(() => _currentPage = idx),
            physics: const BouncingScrollPhysics(),
            children: [
              _buildWelcome(),
              _buildLendBorrow(),
              _buildLimits(),
              _buildEvolution(),
            ],
          ),
          Positioned(
            bottom: 40,
            left: 24,
            right: 24,
            child: _buildNavigation(),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcome() {
    return _buildPage(
      title: 'Questit',
      subtitle: 'MASTER YOUR FOCUS',
      content: 'A system built for time accountability.\nEvery second is an asset to be managed.',
      child: Container(
        height: 140,
        width: 140,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.primaryGreen, width: 2),
          boxShadow: [
            BoxShadow(color: AppColors.primaryGreen.withValues(alpha: 0.2), blurRadius: 30),
          ],
        ),
        child: const Center(
          child: Icon(Icons.timer_outlined, size: 70, color: AppColors.primaryGreen),
        ),
      ),
    );
  }

  Widget _buildLendBorrow() {
    return _buildPage(
      title: 'Accountable',
      subtitle: 'LEND OR BORROW',
      content: 'Bank surplus time for future days.\nBorrow time today and repay it tomorrow.',
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildActionBox('LEND', 'BANK SURPLUS', AppColors.secondaryBlue),
          const SizedBox(width: 16),
          _buildActionBox('BORROW', 'REPAY LATER', AppColors.errorRed),
        ],
      ),
    );
  }

  Widget _buildLimits() {
    return _buildPage(
      title: 'The Limit',
      subtitle: 'ONE DAY BOUNDARY',
      content: 'You can only bank or owe up to 24 hours.\nExceeding this debt triggers a penalty.',
      child: Column(
        children: [
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: _demoCredit >= 0 ? AppColors.secondaryBlue : AppColors.errorRed,
              inactiveTrackColor: AppColors.surface,
              thumbColor: Colors.white,
              trackHeight: 8,
            ),
            child: Slider(
              value: _demoCredit,
              min: -1.0,
              max: 1.0,
              onChanged: (v) => setState(() => _demoCredit = v),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('DEBT CAP', style: GoogleFonts.nunito(fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.errorRed)),
                Text('CREDIT CAP', style: GoogleFonts.nunito(fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.secondaryBlue)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEvolution() {
    return _buildPage(
      title: 'Evolution',
      subtitle: 'STREAK MASTERY',
      content: 'Maintain your consistency.\nYour focus flame evolves as you progress.',
      child: const _AnimatedEvolutionPreview(),
    );
  }

  Widget _buildPage({required String title, required String subtitle, required String content, required Widget child}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title.toUpperCase(), 
            textAlign: TextAlign.center,
            style: GoogleFonts.nunito(fontSize: 28, fontWeight: FontWeight.w900, color: AppColors.textPrimary, letterSpacing: 4)),
          const SizedBox(height: 4),
          Text(subtitle, 
            textAlign: TextAlign.center,
            style: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.primaryGreen, letterSpacing: 2)),
          const SizedBox(height: 80),
          child,
          const SizedBox(height: 80),
          Text(content, 
            textAlign: TextAlign.center,
            style: GoogleFonts.nunito(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.textSecondary, height: 1.4)),
        ],
      ),
    );
  }

  Widget _buildActionBox(String label, String sub, Color color) {
    return Container(
      width: 130,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color, width: 2),
      ),
      child: Column(
        children: [
          Text(label, style: GoogleFonts.nunito(fontWeight: FontWeight.w900, color: color, fontSize: 16)),
          const SizedBox(height: 4),
          Text(sub, style: GoogleFonts.nunito(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.textSecondary, letterSpacing: 1)),
        ],
      ),
    );
  }

  Widget _buildNavigation() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: List.generate(4, (index) => AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.only(right: 8),
            width: _currentPage == index ? 20 : 8,
            height: 8,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: _currentPage == index ? AppColors.primaryGreen : AppColors.border,
            ),
          )),
        ),
        SizedBox(
          width: 140,
          height: 56,
          child: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(color: const Color(0xFF46A302), offset: const Offset(0, 4)),
              ],
              borderRadius: BorderRadius.circular(16),
            ),
            child: ElevatedButton(
              onPressed: () async {
                if (_currentPage < 3) {
                  _controller.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                } else {
                  await TutorialService.markTutorialAsSeen();
                  if (!mounted) return;
                  Navigator.of(context).pushReplacementNamed('/');
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: Text(_currentPage == 3 ? 'START' : 'NEXT', 
                style: GoogleFonts.nunito(fontWeight: FontWeight.w900, fontSize: 16)),
            ),
          ),
        ),
      ],
    );
  }
}

class _AnimatedEvolutionPreview extends StatefulWidget {
  const _AnimatedEvolutionPreview();

  @override
  State<_AnimatedEvolutionPreview> createState() => _AnimatedEvolutionPreviewState();
}

class _AnimatedEvolutionPreviewState extends State<_AnimatedEvolutionPreview> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  int _displayStreak = 0;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..addListener(() {
        setState(() {
          _displayStreak = (_animController.value * 110).toInt();
        });
      });
    
    // Start animation only once
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GamifiedFlame(streak: _displayStreak, size: 100),
        const SizedBox(height: 24),
        Text(
          'DAY $_displayStreak',
          style: GoogleFonts.nunito(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: AppColors.textSecondary,
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }
}
