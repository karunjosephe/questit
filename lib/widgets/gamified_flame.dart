import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class GamifiedFlame extends StatelessWidget {
  final int streak;
  final double size;
  final bool isBroken;

  const GamifiedFlame({
    super.key,
    required this.streak,
    this.size = 24,
    this.isBroken = false,
  });

  Color _getFlameColor() {
    if (isBroken) return AppColors.textSecondary.withValues(alpha: 0.5);
    if (streak >= 100) return const Color(0xFFFFD700); // Gold
    if (streak >= 50) return const Color(0xFF00EEFF);  // Glowing Blue
    
    // Gradient from 1 to 50 (Yellow -> Orange -> Red)
    if (streak < 20) return Color.lerp(const Color(0xFFFFE082), const Color(0xFFFF9100), streak / 20)!;
    if (streak < 50) return Color.lerp(const Color(0xFFFF9100), const Color(0xFFFF3D00), (streak - 20) / 30)!;
    
    return const Color(0xFFFF3D00);
  }

  List<BoxShadow>? _getGlow() {
    if (isBroken) return null;
    Color color = _getFlameColor();
    
    if (streak >= 100) {
      return [
        BoxShadow(color: color.withValues(alpha: 0.6), blurRadius: 15, spreadRadius: 2),
        BoxShadow(color: Colors.white.withValues(alpha: 0.4), blurRadius: 5),
      ];
    }
    if (streak >= 50) {
      return [
        BoxShadow(color: color.withValues(alpha: 0.8), blurRadius: 12, spreadRadius: 1),
      ];
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    if (isBroken) {
      return Icon(Icons.heart_broken_rounded, color: _getFlameColor(), size: size);
    }

    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: _getGlow(),
      ),
      child: Icon(
        Icons.local_fire_department_rounded,
        color: _getFlameColor(),
        size: size,
      ),
    );
  }
}
