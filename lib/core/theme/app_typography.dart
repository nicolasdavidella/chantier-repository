import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTypography {
  static TextTheme getTextTheme({required bool isDark}) {
    final Color textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    
    return TextTheme(
      displayLarge: GoogleFonts.plusJakartaSans(
        fontSize: 57,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.25,
        color: textColor,
      ),
      displayMedium: GoogleFonts.plusJakartaSans(
        fontSize: 45,
        fontWeight: FontWeight.w700,
        color: textColor,
      ),
      displaySmall: GoogleFonts.plusJakartaSans(
        fontSize: 36,
        fontWeight: FontWeight.w700,
        color: textColor,
      ),
      headlineLarge: GoogleFonts.plusJakartaSans(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: textColor,
      ),
      headlineMedium: GoogleFonts.plusJakartaSans(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: textColor,
      ),
      headlineSmall: GoogleFonts.plusJakartaSans(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: textColor,
      ),
      titleLarge: GoogleFonts.plusJakartaSans(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      titleMedium: GoogleFonts.plusJakartaSans(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.15,
        color: textColor,
      ),
      titleSmall: GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        color: textColor,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.5,
        color: textColor,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25,
        color: textColor,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.4,
        color: textColor,
      ),
      labelLarge: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        color: textColor,
      ),
      labelMedium: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        color: textColor,
      ),
      labelSmall: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        color: textColor,
      ),
    );
  }
}
