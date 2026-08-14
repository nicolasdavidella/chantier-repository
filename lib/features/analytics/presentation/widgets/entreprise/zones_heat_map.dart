import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../providers/analytics_provider.dart';
import '../../../../../core/theme/app_spacing.dart';

class ZonesHeatMap extends ConsumerWidget {
  const ZonesHeatMap({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final data = ref.watch(entrepriseZonesProvider);

    return Container(
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
          Text('Carte de Chaleur (Zones de Succès)', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          AppSpacing.vLg,
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: data.map((item) {
              final zone = item['zone'] as String;
              final intensite = item['intensite'] as double; // 0.0 to 1.0

              // Calculate color: light red (low) to deep red/orange (high)
              final color = Color.lerp(
                theme.colorScheme.primaryContainer,
                theme.colorScheme.primary,
                intensite,
              );

              return Tooltip(
                message: 'Intensité: ${(intensite * 100).toInt()}%',
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  ),
                  child: Text(
                    zone,
                    style: TextStyle(
                      color: intensite > 0.5 ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ).animate().scale(delay: (data.indexOf(item) * 100).ms, duration: 400.ms, curve: Curves.easeOutBack),
              );
            }).toList(),
          ),
          AppSpacing.vLg,
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text('Faible', style: theme.textTheme.bodySmall),
              AppSpacing.hSm,
              Container(width: 60, height: 10, decoration: BoxDecoration(
                gradient: LinearGradient(colors: [theme.colorScheme.primaryContainer, theme.colorScheme.primary]),
                borderRadius: BorderRadius.circular(5),
              )),
              AppSpacing.hSm,
              Text('Élevée', style: theme.textTheme.bodySmall),
            ],
          )
        ],
      ),
    );
  }
}
