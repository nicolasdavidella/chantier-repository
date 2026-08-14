import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/widgets/app_button.dart';

class PublicProfileSection extends StatelessWidget {
  const PublicProfileSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Mon profil public', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        AppSpacing.vSm,
        Card(
          elevation: 2,
          color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            side: BorderSide(color: theme.colorScheme.primary.withValues(alpha: 0.2)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 50,
                          height: 50,
                          child: CircularProgressIndicator(
                            value: 0.8,
                            backgroundColor: theme.colorScheme.surfaceContainerHighest,
                            color: theme.colorScheme.primary,
                            strokeWidth: 4,
                          ),
                        ),
                        const Text('80%', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      ],
                    ),
                    AppSpacing.hMd,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Profil complété à 80%', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          AppSpacing.vXs,
                          Text(
                            'Ajoutez plus de réalisations pour attirer de nouveaux clients.',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                AppSpacing.vLg,
                const Divider(),
                AppSpacing.vSm,
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    _buildProfileLink(context, 'Réalisations', Icons.photo_library),
                    _buildProfileLink(context, 'Spécialités', Icons.engineering),
                    _buildProfileLink(context, 'Zone d\'intervention', Icons.map),
                  ],
                ),
                AppSpacing.vLg,
                SizedBox(
                  width: double.infinity,
                  child: AppButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ouverture du profil complet...')));
                    },
                    text: 'Mettre à jour mon profil',
                    icon: Icons.edit,
                    isOutlined: true,
                  ),
                )
              ],
            ),
          ),
        ).animate().scale(begin: const Offset(0.95, 0.95), curve: Curves.easeOut).fadeIn(),
      ],
    );
  }

  Widget _buildProfileLink(BuildContext context, String title, IconData icon) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Édition : $title')));
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: theme.colorScheme.outlineVariant),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: theme.colorScheme.primary),
            AppSpacing.hXs,
            Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
