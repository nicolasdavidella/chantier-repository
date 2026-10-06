import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../providers/entreprise_dashboard_providers.dart';
import 'package:chantier_track/core/theme/app_colors.dart';
import '../screens/mes_chantiers_screen.dart';
import '../../../devis/presentation/screens/devis_screen.dart';

class DashboardStatCards extends ConsumerWidget {
  const DashboardStatCards({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final devisList = ref.watch(mesDevisStreamProvider).value ?? [];
    final chantiersList = ref.watch(mesChantierStreamProvider).value ?? [];
    final entreprise = ref.watch(currentEntrepriseStreamProvider).value;

    final pendingQuotesCount = devisList.where((d) => d.statut == 'en_attente').length;
    final activeProjectsCount = chantiersList.where((p) => p.statut == 'en_cours').length;
    
    // Calcul du CA actif
    double totalRevenue = 0;
    for (final c in chantiersList) {
      if (c.statut == 'en_cours' || c.statut == 'termine') {
        totalRevenue += c.budgetActuel > 0 ? c.budgetActuel : c.budgetPrevisionnel;
      }
    }

    final currencyFormatter = NumberFormat.currency(locale: 'fr_FR', symbol: 'FCFA', decimalDigits: 0);

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
          value: activeProjectsCount.toString(),
          icon: Icons.construction,
          color: AppColors.primary,
          delay: 0.ms,
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MesChantierScreen(initialFilter: 'en_cours'))),
        ),
        _buildStatCard(
          context,
          title: 'Devis en attente',
          value: pendingQuotesCount.toString(),
          icon: Icons.request_quote,
          color: AppColors.warning,
          delay: 100.ms,
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DevisScreen())),
        ),
        _buildStatCard(
          context,
          title: 'Note moyenne',
          value: entreprise != null && entreprise.noteMoyenne > 0
              ? entreprise.noteMoyenne.toStringAsFixed(1)
              : '5.0',
          icon: Icons.star,
          color: AppColors.warning,
          delay: 200.ms,
        ),
        _buildStatCard(
          context,
          title: 'CA du mois',
          value: totalRevenue > 0 ? currencyFormatter.format(totalRevenue) : '0 FCFA',
          icon: Icons.payments_rounded,
          color: AppColors.success,
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
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusLg)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
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
              style: theme.textTheme.bodySmall?.copyWith(color: AppColors.grey700),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    ),
  ).animate().scale(delay: delay, duration: 400.ms, curve: Curves.easeOutBack).fadeIn();
}
}
