import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// --- Theme Provider ---
class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.system); // Par défaut: système

  void setThemeMode(ThemeMode mode) {
    state = mode;
  }
}

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});

// --- Language Provider ---
class LanguageNotifier extends StateNotifier<String> {
  LanguageNotifier() : super('fr'); // Par défaut: français

  void setLanguage(String langCode) {
    state = langCode;
  }
}

final languageProvider = StateNotifierProvider<LanguageNotifier, String>((ref) {
  return LanguageNotifier();
});

// --- Biometric Provider ---
class BiometricNotifier extends StateNotifier<bool> {
  BiometricNotifier() : super(false); // Par défaut: désactivé

  void setBiometric(bool isEnabled) {
    state = isEnabled;
  }
}

final biometricProvider = StateNotifierProvider<BiometricNotifier, bool>((ref) {
  return BiometricNotifier();
});

// --- Notifications Preferences Provider ---
class NotificationPrefsNotifier extends StateNotifier<Map<String, bool>> {
  NotificationPrefsNotifier() : super({
    'messages': true,
    'alertes_ia': true,
    'statut_devis': true,
  });

  void togglePreference(String key, bool value) {
    state = {
      ...state,
      key: value,
    };
  }
}

final notificationPrefsProvider = StateNotifierProvider<NotificationPrefsNotifier, Map<String, bool>>((ref) {
  return NotificationPrefsNotifier();
});
