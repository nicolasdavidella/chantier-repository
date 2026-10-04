import 'package:flutter/material.dart';

class AppColors {
  // ── Palette NextGen Construction / ChantierTrack ──
  static const Color primary = Color(0xFF143D2B); // Deep Forest Green
  static const Color primaryLight = Color(0xFF1F5C41);
  static const Color primaryDark = Color(0xFF0D281C);

  static const Color secondary = Color(0xFF10B981); // Vibrant Emerald Green
  static const Color secondaryLight = Color(0xFF34D399);
  static const Color secondaryDark = Color(0xFF059669);

  static const Color accentGreen = Color(0xFF22C55E); // Leaf Green
  static const Color accentLime = Color(0xFF86EFAC);  // Mint Lime
  static const Color accentGold = Color(0xFFEAB308);  // 100% Quality Gold Accent

  // ── Statuts & Alertes ──
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFFEE2E2);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color warningDark = Color(0xFFD97706);
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFFDCFCE7);
  static const Color successDark = Color(0xFF15803D);
  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFFDBEAFE);

  static const Color statusEnAttente = warning;
  static const Color statusTermine = success;
  static const Color statusRejete = error;

  // ── Nuances de Gris ──
  static const Color grey50 = Color(0xFFF8FAFC);
  static const Color grey100 = Color(0xFFF1F5F9);
  static const Color grey200 = Color(0xFFE2E8F0);
  static const Color grey300 = Color(0xFFCBD5E1);
  static const Color grey400 = Color(0xFF94A3B8);
  static const Color grey500 = Color(0xFF64748B);
  static const Color grey600 = Color(0xFF475569);
  static const Color grey700 = Color(0xFF334155);
  static const Color grey800 = Color(0xFF1E293B);
  static const Color grey900 = Color(0xFF0F172A);

  static const Color successVariant = Color(0xFF10B981);

  // ── Fonds & Surfaces Minimalistes Lumineux ──
  static const Color backgroundLight = Color(0xFFFAF8F5); // Fond beige doux architectural
  static const Color surfaceLight = Color(0xFFFFFFFF);    // Blanc pur
  static const Color cardBorder = Color(0xFFC8E6C9);      // Bordure vert pastel raffinée

  static const Color textPrimaryLight = Color(0xFF0F172A);   // Anthracite profond
  static const Color textSecondaryLight = Color(0xFF64748B); // Gris ardoise élégant
  static const Color borderLight = Color(0xFFE2E8F0);        // Ligne claire

  // ── Thème Sombre ──
  static const Color backgroundDark = Color(0xFF0A130E);
  static const Color surfaceDark = Color(0xFF13231A);
  static const Color textPrimaryDark = Color(0xFFF1F5F9);
  static const Color textSecondaryDark = Color(0xFF94A3B8);
  static const Color borderDark = Color(0xFF1E382A);

  // ── Séries Graphiques ──
  static const List<Color> chartSeries = [
    primary,
    secondary,
    accentGold,
    warning,
    info,
  ];

  static ColorScheme get lightColorScheme => const ColorScheme(
    brightness: Brightness.light,
    primary: primary,
    onPrimary: Colors.white,
    primaryContainer: Color(0xFFE8F5E9),
    onPrimaryContainer: primary,
    secondary: secondary,
    onSecondary: Colors.white,
    secondaryContainer: Color(0xFFDCFCE7),
    onSecondaryContainer: secondaryDark,
    tertiary: accentGold,
    onTertiary: Colors.white,
    error: error,
    onError: Colors.white,
    surface: surfaceLight,
    onSurface: textPrimaryLight,
    onSurfaceVariant: textSecondaryLight,
    outline: cardBorder,
  );

  static ColorScheme get darkColorScheme => const ColorScheme(
    brightness: Brightness.dark,
    primary: secondary,
    onPrimary: Colors.black,
    primaryContainer: primaryDark,
    onPrimaryContainer: Colors.white,
    secondary: secondaryLight,
    onSecondary: Colors.black,
    secondaryContainer: primary,
    onSecondaryContainer: Colors.white,
    tertiary: accentGold,
    onTertiary: Colors.black,
    error: error,
    onError: Colors.white,
    surface: surfaceDark,
    onSurface: textPrimaryDark,
    onSurfaceVariant: textSecondaryDark,
    outline: borderDark,
  );
}
