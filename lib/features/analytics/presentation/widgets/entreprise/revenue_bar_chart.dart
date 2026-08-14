import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../providers/analytics_provider.dart';
import '../../../../../core/theme/app_spacing.dart';

class RevenueBarChart extends ConsumerWidget {
  const RevenueBarChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final data = ref.watch(entrepriseRevenueProvider);
    final period = ref.watch(analyticsPeriodProvider);
    final currencyFormat = NumberFormat.compactCurrency(symbol: 'F', locale: 'fr_FR');

    double maxY = data.isEmpty ? 100 : data.reduce((a, b) => a > b ? a : b) * 1.2;
    if (maxY == 0) maxY = 100;

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
          Text('Évolution du Chiffre d\'Affaires', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          AppSpacing.vLg,
          Expanded(
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxY,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => theme.colorScheme.primaryContainer,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        currencyFormat.format(rod.toY),
                        TextStyle(color: theme.colorScheme.onPrimaryContainer, fontWeight: FontWeight.bold),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            _getBottomLabel(value.toInt(), period),
                            style: const TextStyle(fontSize: 10, color: Colors.grey),
                          ),
                        );
                      },
                      reservedSize: 28,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        if (value == 0 || value == maxY) return const SizedBox.shrink();
                        return Text(
                          NumberFormat.compact().format(value),
                          style: const TextStyle(fontSize: 10, color: Colors.grey),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: maxY / 4,
                  getDrawingHorizontalLine: (value) => FlLine(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3), strokeWidth: 1, dashArray: [5, 5]),
                ),
                borderData: FlBorderData(show: false),
                barGroups: data.asMap().entries.map((e) {
                  return BarChartGroupData(
                    x: e.key,
                    barRods: [
                      BarChartRodData(
                        toY: e.value,
                        color: theme.colorScheme.primary,
                        width: 16,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                        backDrawRodData: BackgroundBarChartRodData(
                          show: true,
                          toY: maxY,
                          color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
              duration: const Duration(milliseconds: 800), // Transition douce des données
              curve: Curves.easeOutCubic,
            ),
          ),
        ],
      ),
    );
  }

  String _getBottomLabel(int index, AnalyticsPeriod period) {
    switch (period) {
      case AnalyticsPeriod.days7:
        // ex: Lun, Mar... (simulé)
        const days = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
        return days[index % 7];
      case AnalyticsPeriod.days30:
        return 'Sem ${index + 1}';
      case AnalyticsPeriod.days90:
        return 'Mois ${index + 1}';
      case AnalyticsPeriod.all:
        return '202${index + 2}';
    }
  }
}
