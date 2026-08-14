import 'package:flutter/material.dart';

class AppColors {
  // Brand colors - Luxurious & Modern Real Estate Style
  static const Color primary = Color(0xFF1E1E1E); // Almost black for high contrast
  static const Color primaryLight = Color(0xFF333333);
  static const Color primaryDark = Color(0xFF000000);
  
  static const Color secondary = Color(0xFFEFE8DE); // Soft beige/sand for accents
  static const Color secondaryLight = Color(0xFFF9F6F0);
  static const Color secondaryDark = Color(0xFFD4C8BA);

  // Status colors
  static const Color error = Color(0xFFE57373);
  static const Color errorDark = Color(0xFFD32F2F);
  static const Color warning = Color(0xFFFFB74D);
  static const Color warningDark = Color(0xFFF57C00);
  static const Color success = Color(0xFF81C784);
  static const Color successDark = Color(0xFF388E3C);
  static const Color info = Color(0xFF64B5F6);
  
  // Neutrals
  static const Color backgroundLight = Color(0xFFF8F9FA); // Very light grey/white
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color textPrimaryLight = Color(0xFF121212);
  static const Color textSecondaryLight = Color(0xFF8A8A8E);
  static const Color borderLight = Color(0xFFEAEAEA);
  
  // Enforcing Light Mode for now to match the pure, clean aesthetic requested
  static const Color backgroundDark = Color(0xFFF8F9FA);
  static const Color surfaceDark = Color(0xFFFFFFFF);
  static const Color textPrimaryDark = Color(0xFF121212);
  static const Color textSecondaryDark = Color(0xFF8A8A8E);
  static const Color borderDark = Color(0xFFEAEAEA);

  static ColorScheme get lightColorScheme => const ColorScheme(
    brightness: Brightness.light,
    primary: primary,
    onPrimary: Colors.white,
    primaryContainer: primaryLight,
    onPrimaryContainer: Colors.white,
    secondary: secondary,
    onSecondary: textPrimaryLight, // Dark text on light beige
    secondaryContainer: secondaryLight,
    onSecondaryContainer: textPrimaryLight,
    error: error,
    onError: Colors.white,
    background: backgroundLight,
    onBackground: textPrimaryLight,
    surface: surfaceLight,
    onSurface: textPrimaryLight,
    outline: borderLight,
  );

  static ColorScheme get darkColorScheme => lightColorScheme; // Force light scheme look for consistent elegant aesthetic
}
