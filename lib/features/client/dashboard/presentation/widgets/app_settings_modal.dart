import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chantier_track/core/providers/settings_provider.dart';
import 'package:chantier_track/core/theme/app_colors.dart';

/// Modal bottom sheet pour les paramètres de l'application
void showAppSettingsModal(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => const AppSettingsModal(),
  );
}

class AppSettingsModal extends ConsumerWidget {
  const AppSettingsModal({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(languageProvider);
    final themeMode = ref.watch(themeModeProvider);
    final notifications = ref.watch(notificationPrefsProvider);
    final isBiometric = ref.watch(biometricProvider);

    final isFrench = language == 'fr';

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 48,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.settings_rounded,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isFrench ? 'Paramètres' : 'Settings',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      Text(
                        isFrench
                            ? 'Personnalisez votre application'
                            : 'Customize your application preferences',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                  color: Colors.grey.shade600,
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── SECTION 1 : LANGUE (LANGUAGE) ──
                  Row(
                    children: [
                      const Icon(Icons.language_rounded, size: 20, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text(
                        isFrench ? 'Langue de l\'application' : 'App Language',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _LanguageOptionCard(
                          title: 'Français',
                          subtitle: 'France / Francophonie',
                          flag: '🇫🇷',
                          isSelected: isFrench,
                          onTap: () {
                            ref.read(languageProvider.notifier).setLanguage('fr');
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _LanguageOptionCard(
                          title: 'English',
                          subtitle: 'United States / UK',
                          flag: '🇬🇧',
                          isSelected: !isFrench,
                          onTap: () {
                            ref.read(languageProvider.notifier).setLanguage('en');
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),

                  // ── SECTION 2 : THÈME (APPEARANCE) ──
                  Row(
                    children: [
                      const Icon(Icons.palette_outlined, size: 20, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text(
                        isFrench ? 'Apparence et Thème' : 'Appearance & Theme',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.all(4),
                    child: Row(
                      children: [
                        Expanded(
                          child: _ThemeTabButton(
                            label: isFrench ? 'Clair' : 'Light',
                            icon: Icons.light_mode_rounded,
                            isSelected: themeMode == ThemeMode.light,
                            onTap: () {
                              ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.light);
                            },
                          ),
                        ),
                        Expanded(
                          child: _ThemeTabButton(
                            label: isFrench ? 'Sombre' : 'Dark',
                            icon: Icons.dark_mode_rounded,
                            isSelected: themeMode == ThemeMode.dark,
                            onTap: () {
                              ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.dark);
                            },
                          ),
                        ),
                        Expanded(
                          child: _ThemeTabButton(
                            label: isFrench ? 'Système' : 'System',
                            icon: Icons.brightness_auto_rounded,
                            isSelected: themeMode == ThemeMode.system,
                            onTap: () {
                              ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.system);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),

                  // ── SECTION 3 : NOTIFICATIONS ──
                  Row(
                    children: [
                      const Icon(Icons.notifications_active_outlined, size: 20, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text(
                        isFrench ? 'Préférences de notifications' : 'Notification Preferences',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _SwitchTile(
                    title: isFrench ? 'Messages & Discussions' : 'Messages & Chat',
                    subtitle: isFrench ? 'Alertes des réponses des artisans' : 'Alerts for artisan replies',
                    value: notifications['messages'] ?? true,
                    onChanged: (val) {
                      ref.read(notificationPrefsProvider.notifier).togglePreference('messages', val);
                    },
                  ),
                  _SwitchTile(
                    title: isFrench ? 'Génération IA & 3D' : 'AI & 3D Generation',
                    subtitle: isFrench ? 'Quand un plan 3D ou devis est prêt' : 'When 3D floor plan is ready',
                    value: notifications['alertes_ia'] ?? true,
                    onChanged: (val) {
                      ref.read(notificationPrefsProvider.notifier).togglePreference('alertes_ia', val);
                    },
                  ),
                  _SwitchTile(
                    title: isFrench ? 'Suivi et étapes de chantier' : 'Project & Site Updates',
                    subtitle: isFrench ? 'Mises à jour des devis et phases' : 'Updates on quotes and milestones',
                    value: notifications['statut_devis'] ?? true,
                    onChanged: (val) {
                      ref.read(notificationPrefsProvider.notifier).togglePreference('statut_devis', val);
                    },
                  ),

                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),

                  // ── SECTION 4 : SÉCURITÉ ──
                  Row(
                    children: [
                      const Icon(Icons.fingerprint_rounded, size: 20, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text(
                        isFrench ? 'Sécurité' : 'Security',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _SwitchTile(
                    title: isFrench ? 'Connexion Biométrique' : 'Biometric Login',
                    subtitle: isFrench ? 'Empreinte digitale / Face ID' : 'Fingerprint / Face ID unlock',
                    value: isBiometric,
                    onChanged: (val) {
                      ref.read(biometricProvider.notifier).setBiometric(val);
                    },
                  ),

                  const SizedBox(height: 20),
                  // App Version Info
                  Center(
                    child: Text(
                      'ChantierTrack v1.0.0 • 2026',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade400,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LanguageOptionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String flag;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageOptionCard({
    required this.title,
    required this.subtitle,
    required this.flag,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.08) : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(flag, style: const TextStyle(fontSize: 26)),
                if (isSelected)
                  const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 20)
                else
                  Icon(Icons.radio_button_unchecked_rounded, color: Colors.grey.shade400, size: 20),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: isSelected ? AppColors.primary : Colors.black87,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ThemeTabButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeTabButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? AppColors.primary : Colors.grey.shade600,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? AppColors.primary : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SwitchTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            activeTrackColor: AppColors.primary,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
