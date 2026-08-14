import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../providers/analytics_provider.dart';
import '../../../../../core/theme/app_spacing.dart';

class AiAlertsChart extends ConsumerWidget {
  const AiAlertsChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final data = ref.watch(adminAiAlertsProvider);

    return Container(
      height: 300,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Taux d\'Alertes IA (Gravité)', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 30,
                      sections: [
                        PieChartSectionData(
                          color: Colors.red,
                          value: data['Critique'],
                          title: '${data['Critique']}%',
                          radius: 50,
                          titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        PieChartSectionData(
                          color: Colors.orange,
                          value: data['Majeure'],
                          title: '${data['Majeure']}%',
                          radius: 40,
                          titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        PieChartSectionData(
                          color: Colors.blueGrey,
                          value: data['Mineure'],
                          title: '${data['Mineure']}%',
                          radius: 35,
                          titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ],
                    ),
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.easeOutBack,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLegend(context, 'Critique', Colors.red),
                      AppSpacing.vSm,
                      _buildLegend(context, 'Majeure', Colors.orange),
                      AppSpacing.vSm,
                      _buildLegend(context, 'Mineure', Colors.blueGrey),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend(BuildContext context, String text, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(shape: BoxShape.circle, color: color)),
        AppSpacing.hXs,
        Text(text, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
