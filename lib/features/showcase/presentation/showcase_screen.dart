import 'package:flutter/material.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/app_badge.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/app_loading_shimmer.dart';

class ShowcaseScreen extends StatelessWidget {
  const ShowcaseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Design System Showcase'),
        actions: [
          IconButton(
            icon: const Icon(Icons.brightness_6),
            onPressed: () {
              // Not implemented yet (requires ThemeMode provider to switch), 
              // but you can test dark mode by changing system settings.
            },
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          _buildSectionTitle(context, 'Typography'),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Display Large', style: theme.textTheme.displayLarge),
                AppSpacing.vSm,
                Text('Headline Large', style: theme.textTheme.headlineLarge),
                AppSpacing.vSm,
                Text('Title Large', style: theme.textTheme.titleLarge),
                AppSpacing.vSm,
                Text('Body Large - Inter font for good readability.', style: theme.textTheme.bodyLarge),
                AppSpacing.vSm,
                Text('Label Large', style: theme.textTheme.labelLarge),
              ],
            ),
          ),
          
          AppSpacing.vXxl,
          _buildSectionTitle(context, 'Buttons'),
          AppCard(
            child: Column(
              children: [
                AppButton(
                  text: 'Primary Button',
                  onPressed: () {},
                  icon: Icons.check,
                ),
                AppSpacing.vMd,
                AppButton(
                  text: 'Secondary Button',
                  isSecondary: true,
                  onPressed: () {},
                ),
                AppSpacing.vMd,
                AppButton(
                  text: 'Outlined Button',
                  isOutlined: true,
                  onPressed: () {},
                ),
                AppSpacing.vMd,
                AppButton(
                  text: 'Loading Button',
                  isLoading: true,
                  onPressed: () {},
                ),
                AppSpacing.vMd,
                const AppButton(
                  text: 'Disabled Button',
                  onPressed: null,
                ),
              ],
            ),
          ),

          AppSpacing.vXxl,
          _buildSectionTitle(context, 'Text Fields'),
          AppCard(
            child: Column(
              children: [
                const AppTextField(
                  label: 'Email',
                  hintText: 'Entrez votre email',
                  prefixIcon: Icons.email_outlined,
                ),
                AppSpacing.vMd,
                const AppTextField(
                  label: 'Mot de passe',
                  hintText: '••••••••',
                  prefixIcon: Icons.lock_outline,
                  obscureText: true,
                  suffixIcon: Icon(Icons.visibility_off),
                ),
              ],
            ),
          ),

          AppSpacing.vXxl,
          _buildSectionTitle(context, 'Badges'),
          AppCard(
            child: Wrap(
              spacing: AppSpacing.md,
              runSpacing: AppSpacing.md,
              children: const [
                AppBadge(label: 'En cours', status: AppBadgeStatus.inProgress),
                AppBadge(label: 'En retard', status: AppBadgeStatus.delayed),
                AppBadge(label: 'Terminé', status: AppBadgeStatus.completed),
                AppBadge(label: 'Anomalie', status: AppBadgeStatus.anomaly),
                AppBadge(label: 'Neutre', status: AppBadgeStatus.neutral),
              ],
            ),
          ),
          
          AppSpacing.vXxl,
          _buildSectionTitle(context, 'Loading Shimmer'),
          const AppListShimmer(itemCount: 2),

          AppSpacing.vXxl,
          _buildSectionTitle(context, 'Empty State'),
          AppCard(
            child: AppEmptyState(
              title: 'Aucun chantier',
              description: 'Vous n\'avez pas encore créé de chantier. Commencez dès maintenant.',
              lottieAsset: 'assets/lottie/empty.json', // N'existe pas, affichera l'icône
              action: AppButton(
                text: 'Créer un chantier',
                isFullWidth: false,
                onPressed: () {},
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
