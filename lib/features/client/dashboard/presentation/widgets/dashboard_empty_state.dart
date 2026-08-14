import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/widgets/app_button.dart';

class DashboardEmptyState extends StatelessWidget {
  final VoidCallback onAddProject;

  const DashboardEmptyState({super.key, required this.onAddProject});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.network(
            'https://lottie.host/8b725055-6677-44da-b371-bd6b90875c75/Z1hW6r60PZ.json', // Placeholder illustration
            height: 200,
            repeat: false,
            errorBuilder: (context, error, stackTrace) => const Icon(Icons.architecture, size: 80),
          ),
          AppSpacing.vLg,
          Text(
            'Aucun projet pour le moment',
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2),
          AppSpacing.vSm,
          Text(
            'Lancez votre premier chantier et suivez son évolution en temps réel.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2),
          AppSpacing.vXxl,
          AppButton(
            onPressed: onAddProject,
            text: 'Créer un projet',
            icon: Icons.add,
          ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2),
        ],
      ),
    );
  }
}
