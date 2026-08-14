import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/analytics_provider.dart';
import '../../../../core/theme/app_spacing.dart';
import '../widgets/entreprise/revenue_bar_chart.dart';
import '../widgets/entreprise/conversion_pie_chart.dart';
import '../widgets/entreprise/delay_line_chart.dart';
import '../widgets/entreprise/zones_heat_map.dart';

class EntrepriseAnalyticsScreen extends ConsumerWidget {
  const EntrepriseAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final period = ref.watch(analyticsPeriodProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Statistiques'),
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
                  
                  // Graphique Revenus
                  const RevenueBarChart().animate().fadeIn(delay: 100.ms).slideX(begin: -0.1),
                  AppSpacing.vXxl,
                  
                  // Graphique Conversion
                  const ConversionPieChart().animate().fadeIn(delay: 200.ms).slideX(begin: 0.1),
                  AppSpacing.vXxl,
                  
                  // Graphique Délais
                  const DelayLineChart().animate().fadeIn(delay: 300.ms).slideX(begin: -0.1),
                  AppSpacing.vXxl,

                  // Heatmap Zones
                  const ZonesHeatMap().animate().fadeIn(delay: 400.ms).slideY(begin: 0.1),
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
