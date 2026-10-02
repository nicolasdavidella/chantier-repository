import 'package:flutter/material.dart';

class AppColors {
  // Brand colors - Green Theme (NextGen Style)
  static const Color primary = Color(0xFF1A3C28); // Dark Forest Green
  static const Color primaryLight = Color(0xFF2C553C);
  static const Color primaryDark = Color(0xFF0F2618);
  
  static const Color secondary = Color(0xFF71B930); // Vibrant Leaf Green
  static const Color secondaryLight = Color(0xFF8CD44E);
  static const Color secondaryDark = Color(0xFF55961E);

  // Status colors
  static const Color error = Color(0xFFD32F2F); 
  static const Color errorLight = Color(0xFFFFEBEE);
  static const Color warning = Color(0xFFF57C00); 
  static const Color warningLight = Color(0xFFFFF3E0);
  static const Color warningDark = Color(0xFFE65100); 
  static const Color success = Color(0xFF388E3C); 
  static const Color successLight = Color(0xFFE8F5E9);
  static const Color successDark = Color(0xFF1B5E20); 
  static const Color info = Color(0xFF1976D2); 
  static const Color infoLight = Color(0xFFE3F2FD);
  
  static const Color statusEnAttente = warning;
  static const Color statusTermine = success;
  static const Color statusRejete = error;
  
  // Named shades used as single values
  static const Color grey100 = Color(0xFFF5F5F5);
  static const Color grey200 = Color(0xFFEEEEEE);
  static const Color grey300 = Color(0xFFE0E0E0);
  static const Color grey400 = Color(0xFFBDBDBD);
  static const Color grey500 = Color(0xFF9E9E9E);
  static const Color grey600 = Color(0xFF757575);
  static const Color grey700 = Color(0xFF616161);
  static const Color grey800 = Color(0xFF424242);
  static const Color successVariant = Color(0xFF4CAF50);
  
  // Neutrals - Minimalist
  static const Color backgroundLight = Color(0xFFF5F7F2); // Subtle cream/green tint
  static const Color surfaceLight = Color(0xFFFFFFFF); // White
  
  static const Color textPrimaryLight = Color(0xFF1A3C28); // Dark green text
  static const Color textSecondaryLight = Color(0xFF5C6E64); // Medium grey/green
  static const Color borderLight = Color(0xFFDDE6E0); // Light border
  
  // Dark mode
  static const Color backgroundDark = Color(0xFF121A16);
  static const Color surfaceDark = Color(0xFF1E2822);
  static const Color textPrimaryDark = Color(0xFFE8F0EA);
  static const Color textSecondaryDark = Color(0xFFA3B3A9);
  static const Color borderDark = Color(0xFF2C3E33);

  // Chart series colors (for fl_chart)
  static const List<Color> chartSeries = [
    primary,
    secondary,
    warning,
    textSecondaryLight,
  ];

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
    surface: surfaceLight,
    onSurface: textPrimaryLight,
    onSurfaceVariant: textSecondaryLight,
    outline: borderLight,
  );

  static ColorScheme get darkColorScheme => const ColorScheme(
    brightness: Brightness.dark,
    primary: secondary, // Use lighter green as primary in dark mode for visibility
    onPrimary: Colors.black,
    primaryContainer: secondaryDark,
    onPrimaryContainer: secondaryLight,
    secondary: primaryLight,
    onSecondary: Colors.white,
    secondaryContainer: primaryDark,
    onSecondaryContainer: primary,
    error: error,
    onError: Colors.white,
    surface: surfaceDark,
    onSurface: textPrimaryDark,
    onSurfaceVariant: textSecondaryDark,
    outline: borderDark,
  );
}
