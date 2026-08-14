import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../providers/entreprise_dashboard_provider.dart';

class DashboardStatCards extends ConsumerWidget {
  const DashboardStatCards({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(entrepriseStatsProvider);
    final currencyFormatter = NumberFormat.currency(locale: 'fr_FR', symbol: 'FCFA');

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: AppSpacing.md,
      mainAxisSpacing: AppSpacing.md,
      childAspectRatio: 1.2,
      children: [
        _buildStatCard(
          context,
          title: 'Chantiers Actifs',
          value: stats.activeProjects.toString(),
          icon: Icons.construction,
          color: Colors.blue,
          delay: 0.ms,
        ),
        _buildStatCard(
          context,
          title: 'Devis en attente',
          value: stats.pendingQuotes.toString(),
          icon: Icons.request_quote,
          color: Colors.orange,
          delay: 100.ms,
        ),
        _buildStatCard(
          context,
          title: 'Note moyenne',
          value: stats.averageRating.toString(),
          icon: Icons.star,
          color: Colors.amber,
          delay: 200.ms,
        ),
        _buildStatCard(
          context,
          title: 'CA du mois',
          value: currencyFormatter.format(stats.monthlyRevenue),
          icon: Icons.euro_symbol,
          color: Colors.green,
          delay: 300.ms,
          valueFontSize: 14,
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required Duration delay,
    double valueFontSize = 24,
  }) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusLg)),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const Spacer(),
            Text(
              value,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: valueFontSize,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            AppSpacing.vXs,
            Text(
              title,
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[700]),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    ).animate().scale(delay: delay, duration: 400.ms, curve: Curves.easeOutBack).fadeIn();
  }
}
