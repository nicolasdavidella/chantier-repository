import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/providers/settings_provider.dart';
import '../../../../core/theme/app_spacing.dart';

class SettingsSection extends ConsumerWidget {
  const SettingsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final themeMode = ref.watch(themeModeProvider);
    final language = ref.watch(languageProvider);
    final notifications = ref.watch(notificationPrefsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Préférences de l\'Application',
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        AppSpacing.vLg,
        
        // Theme Toggle
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: (themeMode == ThemeMode.dark || (themeMode == ThemeMode.system && theme.brightness == Brightness.dark))
              ? const Icon(Icons.dark_mode).animate().rotate(duration: 500.ms, begin: -0.5, end: 0)
              : const Icon(Icons.light_mode, color: Colors.orange).animate().rotate(duration: 500.ms, begin: 0.5, end: 0),
          title: const Text('Thème sombre'),
          trailing: Switch(
            value: themeMode == ThemeMode.dark || (themeMode == ThemeMode.system && theme.brightness == Brightness.dark),
            onChanged: (isDark) {
              ref.read(themeModeProvider.notifier).setThemeMode(isDark ? ThemeMode.dark : ThemeMode.light);
            },
          ),
        ),
        
        const Divider(),
        
        // Language Select
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.language),
          title: const Text('Langue / Language'),
          trailing: DropdownButton<String>(
            value: language,
            underline: const SizedBox(),
            items: const [
              DropdownMenuItem(value: 'fr', child: Text('Français')),
              DropdownMenuItem(value: 'en', child: Text('English')),
            ],
            onChanged: (val) {
              if (val != null) {
                ref.read(languageProvider.notifier).setLanguage(val);
              }
            },
          ),
        ),
        
        const Divider(),

        // Notifications
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.notifications_active_outlined),
          title: const Text('Notifications de messages'),
          trailing: Switch(
            value: notifications['messages'] ?? true,
            onChanged: (val) => ref.read(notificationPrefsProvider.notifier).togglePreference('messages', val),
          ),
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.auto_awesome),
          title: const Text('Alertes IA'),
          trailing: Switch(
            value: notifications['alertes_ia'] ?? true,
            onChanged: (val) => ref.read(notificationPrefsProvider.notifier).togglePreference('alertes_ia', val),
          ),
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.receipt_long),
          title: const Text('Mises à jour des devis'),
          trailing: Switch(
            value: notifications['statut_devis'] ?? true,
            onChanged: (val) => ref.read(notificationPrefsProvider.notifier).togglePreference('statut_devis', val),
          ),
        ),
      ],
    );
  }
}
