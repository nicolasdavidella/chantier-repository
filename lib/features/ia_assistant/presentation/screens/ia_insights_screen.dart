import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../providers/ia_providers.dart';
import '../widgets/insight_card.dart';

class IaInsightsScreen extends ConsumerWidget {
  final String projectId;
  
  const IaInsightsScreen({super.key, required this.projectId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final insightsAsync = ref.watch(iaInsightsProvider(projectId));
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.psychology, color: Colors.purple),
            AppSpacing.hSm,
            const Text('Insights IA'),
          ],
        ),
      ),
      body: insightsAsync.when(
        data: (data) => _buildContent(context, data, theme),
        loading: () => _buildLoadingState(theme),
        error: (err, stack) => Center(child: Text('Erreur: $err')),
      ),
    );
  }

  Widget _buildLoadingState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.psychology, size: 64, color: Colors.purple)
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scale(begin: const Offset(0.9, 0.9), end: const Offset(1.1, 1.1), duration: 1.seconds),
          AppSpacing.vMd,
          Text(
            'L\'IA analyse votre chantier...',
            style: theme.textTheme.titleMedium?.copyWith(color: Colors.grey),
          ).animate(onPlay: (c) => c.repeat()).fade(duration: 1.seconds),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, IAInsightData data, ThemeData theme) {
    int delayBase = 300; // ms between sections

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Prediction de retard
          _buildSectionTitle('Prédiction de délai', theme)
              .animate()
              .fadeIn(delay: 0.ms)
              .slideX(begin: -0.1),
          
          _buildDelayPrediction(data, theme)
              .animate()
              .fadeIn(delay: 100.ms)
              .slideY(begin: 0.2),

          AppSpacing.vLg,

          // 2. Anomalies
          _buildSectionTitle('Anomalies Détectées', theme)
              .animate()
              .fadeIn(delay: Duration(milliseconds: delayBase))
              .slideX(begin: -0.1),
          
          ...data.anomalies.asMap().entries.map((entry) {
            return InsightCard(
              titre: entry.value['titre']!,
              description: entry.value['description']!,
              type: 'anomalie',
              severite: entry.value['severite'],
            )
            .animate()
            .fadeIn(delay: Duration(milliseconds: delayBase + 100 + (entry.key * 100)))
            .slideY(begin: 0.2);
          }),

          AppSpacing.vLg,

          // 3. Recommandations
          _buildSectionTitle('Recommandations', theme)
              .animate()
              .fadeIn(delay: Duration(milliseconds: delayBase * 2))
              .slideX(begin: -0.1),

          ...data.recommandations.asMap().entries.map((entry) {
            return InsightCard(
              titre: 'Action Recommandée',
              description: entry.value,
              type: 'recommandation',
            )
            .animate()
            .fadeIn(delay: Duration(milliseconds: (delayBase * 2) + 100 + (entry.key * 100)))
            .slideY(begin: 0.2);
          }),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Text(
        title,
        style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildDelayPrediction(IAInsightData data, ThemeData theme) {
    // 0 = en avance, 0.5 = dans les temps, 1 = très en retard
    Color barColor;
    String statusText;
    
    if (data.predictionRetard < 0.3) {
      barColor = Colors.green;
      statusText = "Le chantier est en avance ou parfaitement dans les temps.";
    } else if (data.predictionRetard < 0.7) {
      barColor = Colors.orange;
      statusText = "Léger retard possible. Une vigilance est requise.";
    } else {
      barColor = Colors.red;
      statusText = "Risque élevé de dépassement des délais prévus !";
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Indice de risque', style: theme.textTheme.titleMedium),
              Text(
                '${(data.predictionRetard * 100).toInt()}%',
                style: theme.textTheme.titleLarge?.copyWith(color: barColor, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          AppSpacing.vSm,
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: data.predictionRetard,
              minHeight: 12,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(barColor),
            ),
          ),
          AppSpacing.vSm,
          Text(statusText, style: TextStyle(color: theme.colorScheme.onSurfaceVariant)),
          AppSpacing.vXs,
          Row(
            children: [
              const Icon(Icons.info_outline, size: 14, color: Colors.grey),
              AppSpacing.hXs,
              Text(
                'Niveau de confiance de l\'IA : ${(data.confiancePrediction * 100).toInt()}%',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          )
        ],
      ),
    );
  }
}
