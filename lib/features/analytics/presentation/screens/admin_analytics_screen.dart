import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/analytics_provider.dart';
import '../../../../core/theme/app_spacing.dart';
import '../widgets/admin/user_growth_chart.dart';
import '../widgets/admin/financial_volume_chart.dart';
import '../widgets/admin/ai_alerts_chart.dart';
import '../widgets/admin/top_entreprises_list.dart';

class AdminAnalyticsScreen extends ConsumerWidget {
  const AdminAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final period = ref.watch(analyticsPeriodProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tableau de Bord Administrateur'),
        centerTitle: true,
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Sélecteur de période animé
                  SegmentedButton<AnalyticsPeriod>(
                    segments: const [
                      ButtonSegment(value: AnalyticsPeriod.days7, label: Text('7j')),
                      ButtonSegment(value: AnalyticsPeriod.days30, label: Text('30j')),
                      ButtonSegment(value: AnalyticsPeriod.days90, label: Text('90j')),
                      ButtonSegment(value: AnalyticsPeriod.all, label: Text('Tout')),
                    ],
                    selected: {period},
                    onSelectionChanged: (Set<AnalyticsPeriod> newSelection) {
                      ref.read(analyticsPeriodProvider.notifier).setPeriod(newSelection.first);
                    },
                    style: SegmentedButton.styleFrom(
                      backgroundColor: theme.colorScheme.surface,
                      selectedForegroundColor: theme.colorScheme.onPrimary,
                      selectedBackgroundColor: theme.colorScheme.primary,
                    ),
                  ).animate().fadeIn().slideY(begin: -0.2),
                  
                  AppSpacing.vXxl,
                  
                  // Graphique Croissance Utilisateurs
                  const UserGrowthChart().animate().fadeIn(delay: 100.ms).slideX(begin: -0.1),
                  AppSpacing.vXxl,
                  
                  // Graphique Volume Financier
                  const FinancialVolumeChart().animate().fadeIn(delay: 200.ms).slideX(begin: 0.1),
                  AppSpacing.vXxl,
                  
                  // Graphique Alertes IA
                  const AiAlertsChart().animate().fadeIn(delay: 300.ms).slideX(begin: -0.1),
                  AppSpacing.vXxl,

                  // Classement Entreprises
                  const TopEntreprisesList().animate().fadeIn(delay: 400.ms).slideY(begin: 0.1),
                  AppSpacing.vXxl,
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
