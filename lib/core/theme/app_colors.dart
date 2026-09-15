import 'package:flutter/material.dart';

class AppColors {
  // Brand colors - ChantierTrack Official Identity
  static const Color primary = Color(0xFF0F6E56); // Deep Green
  static const Color primaryLight = Color(0xFFE6F3F0);
  static const Color primaryDark = Color(0xFF0A4D3C);
  
  static const Color secondary = Color(0xFFD85A30); // Terracotta / Accent
  static const Color secondaryLight = Color(0xFFFDF2ED);
  static const Color secondaryDark = Color(0xFFB54520);

  // Status colors
  static const Color error = Color(0xFFE53E3E);
  static const Color errorDark = Color(0xFFC53030);
  static const Color warning = Color(0xFFDD6B20);
  static const Color warningDark = Color(0xFFC05621);
  static const Color success = Color(0xFF38A169);
  static const Color successDark = Color(0xFF276749);
  static const Color info = Color(0xFF3182CE);
  
  // Neutrals - Warm tones
  static const Color backgroundLight = Color(0xFFF9FAFB); // Very light grey
  static const Color surfaceLight = Color(0xFFFFFFFF);
  
  static const Color textPrimaryLight = Color(0xFF1F2937); // Dark gray, not pure black
  static const Color textSecondaryLight = Color(0xFF6B7280);
  static const Color borderLight = Color(0xFFE5E7EB);
  
  // Enforcing Light Mode to guarantee flat design consistency
  static const Color backgroundDark = Color(0xFFF9FAFB);
  static const Color surfaceDark = Color(0xFFFFFFFF);
  static const Color textPrimaryDark = Color(0xFF1F2937);
  static const Color textSecondaryDark = Color(0xFF6B7280);
  static const Color borderDark = Color(0xFFE5E7EB);

  static ColorScheme get lightColorScheme => const ColorScheme(
    brightness: Brightness.light,
    primary: primary,
    onPrimary: Colors.white,
    primaryContainer: primaryLight,
    onPrimaryContainer: primaryDark,
    secondary: secondary,
    onSecondary: Colors.white,
    secondaryContainer: secondaryLight,
    onSecondaryContainer: secondaryDark,
    error: error,
    onError: Colors.white,
    background: backgroundLight,
    onBackground: textPrimaryLight,
    surface: surfaceLight,
    onSurface: textPrimaryLight,
    outline: borderLight,
  );

  static ColorScheme get darkColorScheme => lightColorScheme; // Force light scheme
}
