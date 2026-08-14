import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../providers/analytics_provider.dart';
import '../../../../../core/theme/app_spacing.dart';

class ConversionPieChart extends ConsumerWidget {
  const ConversionPieChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final data = ref.watch(entrepriseConversionProvider);

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
          Text('Taux de Conversion des Devis', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 40,
                      sections: [
                        PieChartSectionData(
                          color: Colors.green,
                          value: data['acceptes'],
                          title: '${data['acceptes']}%',
                          radius: 50,
                          titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        PieChartSectionData(
                          color: Colors.redAccent,
                          value: data['refuses'],
                          title: '${data['refuses']}%',
                          radius: 50,
                          titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        PieChartSectionData(
                          color: Colors.orangeAccent,
                          value: data['attente'],
                          title: '${data['attente']}%',
                          radius: 50,
                          titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ],
                    ),
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.easeOutBack,
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLegend(context, 'Acceptés', Colors.green),
                      AppSpacing.vSm,
                      _buildLegend(context, 'Refusés', Colors.redAccent),
                      AppSpacing.vSm,
                      _buildLegend(context, 'En attente', Colors.orangeAccent),
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
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        AppSpacing.hXs,
        Text(text, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
