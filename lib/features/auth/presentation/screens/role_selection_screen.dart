import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_card.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inscription'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Choisissez votre profil',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.primary,
              ),
            ).animate().fadeIn().slideY(begin: 0.1),
            AppSpacing.vSm,
            Text(
              'Pour personnaliser votre expérience sur ChantierTrack.',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1),
            AppSpacing.vXxl,
            Expanded(
              child: ListView(
                children: [
                  _RoleCard(
                    title: 'Client / Propriétaire',
                    description: 'Je veux suivre l\'avancement de mon chantier et gérer mes dépenses.',
                    icon: Icons.person_outline,
                    delay: 200,
                    onTap: () => context.push('/signup?role=client'),
                  ),
                  AppSpacing.vLg,
                  _RoleCard(
                    title: 'Entreprise de construction',
                    description: 'Je veux gérer mes chantiers, trouver des clients et éditer des devis.',
                    icon: Icons.business_outlined,
                    delay: 300,
                    onTap: () => context.push('/signup?role=entreprise'),
                  ),
                  AppSpacing.vLg,
                  _RoleCard(
                    title: 'Chef de chantier',
                    description: 'Je supervise les travaux sur le terrain et rédige les rapports journaliers.',
                    icon: Icons.engineering_outlined,
                    delay: 400,
                    onTap: () => context.push('/signup?role=chef_chantier'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final int delay;
  final VoidCallback onTap;

  const _RoleCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.delay,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 32,
              color: theme.colorScheme.primary,
            ),
          ),
          AppSpacing.hLg,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                AppSpacing.vXs,
                Text(
                  description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          AppSpacing.hMd,
          Icon(
            Icons.chevron_right,
            color: theme.colorScheme.outline,
          ),
        ],
      ),
    ).animate().fadeIn(delay: delay.ms).slideX(begin: 0.1);
  }
}
