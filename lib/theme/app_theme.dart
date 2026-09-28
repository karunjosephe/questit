import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // AMOLED Dark Duo Palette
  static const background = Color(0xFF000000); // Pure Black for AMOLED
  static const surface = Color(0xFF121212);    // Dark Gray surface
  static const primaryGreen = Color(0xFF58CC02); // Duo Green
  static const secondaryBlue = Color(0xFF1CB0F6); // Duo Blue
  static const accentOrange = Color(0xFFFF9600); // Duo Orange
  static const errorRed = Color(0xFFFF4B4B);    // Duo Red
  static const textPrimary = Color(0xFFFFFFFF); // White
  static const textSecondary = Color(0xFFBDBDBD); // Light Gray
  static const border = Color(0xFF2F2F2F);      // Darker border

  // Flame Progression Colors
  static const flameYellow = Color(0xFFFFD700);
  static const flameOrange = Color(0xFFFF8C00);
  static const flameRed = Color(0xFFFF4500);
  static const flameBlue = Color(0xFF00BFFF);
  static const flameGold = Color(0xFFFFD700); // We can add a glow effect in UI
}

ThemeData buildAppTheme() {
  return ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primaryGreen,
      secondary: AppColors.secondaryBlue,
      surface: AppColors.surface,
      error: AppColors.errorRed,
      onSurface: AppColors.textPrimary,
    ),
    textTheme: GoogleFonts.nunitoTextTheme(ThemeData.dark().textTheme).copyWith(
      displayLarge: GoogleFonts.nunito(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w900,
      ),
      bodyLarge: GoogleFonts.nunito(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w700,
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.background,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: AppColors.textSecondary),
      titleTextStyle: TextStyle(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w900,
        fontSize: 18,
      ),
    ),
  );
}
