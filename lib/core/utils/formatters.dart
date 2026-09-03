import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

class FormatUtils {
  /// Format a currency amount in FCFA based on the current locale
  static String formatCurrency(num amount, BuildContext context) {
    // Get current locale from context (or default to 'fr')
    final locale = Localizations.localeOf(context).languageCode;
    
    // We use French format as base (space as thousand separator) or English if preferred.
    // The user requested standard formatting with FCFA fixed.
    final formatter = NumberFormat.currency(
      locale: locale,
      symbol: 'FCFA',
      customPattern: locale == 'en' ? '#,##0 ¤' : '#,##0 ¤',
      decimalDigits: 0, 
    );
    
    // Quick fix for French separator if NumberFormat defaults differently
    if (locale == 'fr') {
       final tempFormatter = NumberFormat.currency(
        locale: 'fr_FR',
        symbol: 'FCFA',
        customPattern: '#,##0 ¤',
        decimalDigits: 0, 
      );
      return tempFormatter.format(amount).replaceAll(' ', ' ');
    }
    
    return formatter.format(amount);
  }

  /// Format a date based on the current locale
  static String formatDate(DateTime date, BuildContext context, {bool short = false}) {
    final locale = Localizations.localeOf(context).languageCode;
    final formatString = short ? (locale == 'en' ? 'MMM d, yyyy' : 'dd MMM yyyy') : (locale == 'en' ? 'MMMM d, yyyy' : 'dd MMMM yyyy');
    final formatter = DateFormat(formatString, locale);
    return formatter.format(date);
  }
}
