import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../providers/analytics_provider.dart';
import '../../../../../core/theme/app_spacing.dart';

class DelayLineChart extends ConsumerWidget {
  const DelayLineChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final data = ref.watch(entrepriseDelayProvider);
    
    // data = [ [prevu, reel], [prevu, reel], ... ]

    double maxY = 0;
    for (var point in data) {
      if (point[0] > maxY) maxY = point[0];
      if (point[1] > maxY) maxY = point[1];
    }
    maxY = maxY * 1.2;
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
          Text('Délais de Réalisation (Prévus vs Réels)', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          AppSpacing.vLg,
          Expanded(
            child: LineChart(
              LineChartData(
                lineTouchData: LineTouchData(
                  handleBuiltInTouches: true,
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (_) => theme.colorScheme.primaryContainer,
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => FlLine(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3), strokeWidth: 1, dashArray: [5, 5]),
                ),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 22,
                      getTitlesWidget: (value, meta) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text('P${value.toInt() + 1}', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        if (value == 0 || value == maxY) return const SizedBox.shrink();
                        return Text('${value.toInt()}j', style: const TextStyle(fontSize: 10, color: Colors.grey));
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: (data.length - 1).toDouble(),
                minY: 0,
                maxY: maxY,
                lineBarsData: [
                  // Ligne Prévu
                  LineChartBarData(
                    spots: data.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value[0])).toList(),
                    isCurved: true,
                    color: Colors.blueAccent,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: Colors.blueAccent.withValues(alpha: 0.1),
                    ),
                  ),
                  // Ligne Réel
                  LineChartBarData(
                    spots: data.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value[1])).toList(),
                    isCurved: true,
                    color: Colors.orangeAccent,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: true),
                  ),
                ],
              ),
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOutCubic,
            ),
          ),
          AppSpacing.vSm,
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegend(context, 'Prévu', Colors.blueAccent),
              AppSpacing.hLg,
              _buildLegend(context, 'Réel', Colors.orangeAccent),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildLegend(BuildContext context, String text, Color color) {
    return Row(
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
