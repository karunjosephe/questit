import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _controller.forward().then((_) {
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/');
        }
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: FadeTransition(
          opacity: _opacity,
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
                        shadows: [
                          Shadow(color: AppColors.primaryGreen.withValues(alpha: 0.8), blurRadius: 20),
                          Shadow(color: AppColors.primaryGreen.withValues(alpha: 0.5), blurRadius: 40),
                        ],
                      ),
                    ),
                    TextSpan(
                      text: 'it',
                      style: GoogleFonts.nunito(
                        color: AppColors.primaryGreen,
                        shadows: [
                          Shadow(color: AppColors.primaryGreen.withValues(alpha: 0.8), blurRadius: 20),
                          Shadow(color: AppColors.primaryGreen.withValues(alpha: 0.5), blurRadius: 40),
                        ],
                      ),
                    ),
                  ],
                ),
                style: const TextStyle(
                  fontSize: 64,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
