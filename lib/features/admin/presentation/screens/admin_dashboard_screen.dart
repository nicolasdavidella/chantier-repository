import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_spacing.dart';
import 'package:chantier_track/features/admin/providers/admin_providers.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../auth/providers/auth_provider.dart';
import 'package:chantier_track/core/theme/app_colors.dart';


class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(adminStatsFutureProvider);
    final activityLogsAsync = ref.watch(activityLogsStreamProvider);
    final theme = Theme.of(context);
    final currencyFormatter = NumberFormat.compactCurrency(locale: 'fr_FR', symbol: 'FCFA');

    final isWideScreen = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Tableau de bord', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
        centerTitle: false,
        actions: [
          if (!isWideScreen)
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Consumer(
                builder: (context, ref, child) {
                  final userState = ref.watch(currentUserProfileProvider);
                  final user = userState.value;
                  return InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () {},
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                      backgroundImage: user?.photoUrl != null && user!.photoUrl!.isNotEmpty
                          ? NetworkImage(user.photoUrl!)
                          : null,
                      child: user?.photoUrl == null || user!.photoUrl!.isEmpty
                          ? Text(
                              user?.prenom.isNotEmpty == true ? user!.prenom[0].toUpperCase() : 'A',
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : null,
                    ),
                  );
                },
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section
            Container(
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [theme.colorScheme.primary, theme.colorScheme.primary.withValues(alpha: 0.8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
                boxShadow: [
                  BoxShadow(color: theme.colorScheme.primary.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 10)),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text('Bienvenue, Administrateur 👋', style: theme.textTheme.headlineSmall?.copyWith(color: theme.colorScheme.onPrimary, fontWeight: FontWeight.bold)),
                        ),
                        AppSpacing.vSm,
                        Text('Voici un résumé de l\'activité sur la plateforme Chantier Track aujourd\'hui.', style: TextStyle(color: theme.colorScheme.onPrimary.withValues(alpha: 0.8), fontSize: 16)),
                      ],
                    ),
                  ),
                  if (isWideScreen)
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(color: theme.colorScheme.onPrimary.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(AppSpacing.radiusLg)),
                      child: Icon(Icons.analytics_rounded, color: theme.colorScheme.onPrimary, size: 48),
                    )
                ],
              ),
            ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.2),

            AppSpacing.vXxl,
            Text('Aperçu des performances', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
            AppSpacing.vLg,

            // Stats Grid
            statsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Erreur de chargement des stats', style: TextStyle(color: theme.colorScheme.error))),
              data: (stats) => GridView.count(
                crossAxisCount: isWideScreen ? 3 : 1,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: AppSpacing.lg,
                crossAxisSpacing: AppSpacing.lg,
                childAspectRatio: isWideScreen ? 1.4 : 1.5,
                children: [
                  _buildStatCard(
                    context,
                    title: 'Utilisateurs',
                    value: stats['totalUsers'].toString(),
                    icon: Icons.group_rounded,
                    color: theme.colorScheme.primary,
                    chartData: stats['usersData'] as List<double>,
                    delay: 100,
                  ),
                  _buildStatCard(
                    context,
                    title: 'Chantiers Actifs',
                    value: stats['activeProjects'].toString(),
                    icon: Icons.construction_rounded,
                    color: theme.colorScheme.secondary,
                    chartData: [10, 15, 20, 18, 25, 30, 34],
                    delay: 200,
                  ),
                  _buildStatCard(
                    context,
                    title: 'Volume Financier',
                    value: currencyFormatter.format(stats['financialVolume']),
                    icon: Icons.account_balance_wallet_rounded,
                    color: theme.colorScheme.tertiary,
                    chartData: stats['financialData'] as List<double>,
                    delay: 300,
                  ),
                ],
              ),
            ),

            AppSpacing.vXxl,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Activité Récente', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
                TextButton(
                  onPressed: () {},
                  child: Text('Voir tout', style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
                )
              ],
            ),
            AppSpacing.vMd,

            // Recent Activity from Provider
            activityLogsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Erreur: $err', style: TextStyle(color: theme.colorScheme.error))),
              data: (activityLogs) => Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
                  boxShadow: [
                    BoxShadow(color: theme.colorScheme.shadow.withValues(alpha: 0.05), blurRadius: 15, offset: const Offset(0, 5)),
                  ],
                ),
                child: activityLogs.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.all(AppSpacing.xl),
                      child: Center(child: Text("Aucune activité récente.", style: TextStyle(color: Colors.grey))),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: activityLogs.length,
                      separatorBuilder: (context, index) => Divider(height: 1, color: AppColors.textSecondaryLight),
                      itemBuilder: (context, index) {
                        final log = activityLogs[index];
                        final isRecent = DateTime.now().difference(log.timestamp).inHours < 1;
                        
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
                          leading: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              _getIconForAction(log.action),
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          title: Text(log.action, style: TextStyle(fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface)),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text(
                              'Par ${log.user} • ${_formatTimeAgo(log.timestamp)}',
                              style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 13),
                            ),
                          ),
                          trailing: isRecent
                              ? Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primaryContainer,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text('Nouveau', style: TextStyle(color: theme.colorScheme.onPrimaryContainer, fontSize: 11, fontWeight: FontWeight.bold)),
                                )
                              : null,
                        ).animate().fadeIn(delay: Duration(milliseconds: 400 + (index * 100))).slideX(begin: 0.1);
                      },
                    ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, {required String title, required String value, required IconData icon, required Color color, required List<double> chartData, required int delay}) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        boxShadow: [
          BoxShadow(color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.05), blurRadius: 15, offset: const Offset(0, 5)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.arrow_upward_rounded, color: Theme.of(context).colorScheme.onPrimaryContainer, size: 14),
                    const SizedBox(width: 4),
                    Text('+12%', style: TextStyle(color: Theme.of(context).colorScheme.onPrimaryContainer, fontWeight: FontWeight.bold, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
          const Spacer(),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(value, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
          ),
          AppSpacing.vXs,
          Text(title, style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurfaceVariant, fontWeight: FontWeight.w500)),
          AppSpacing.vMd,
          SizedBox(
            height: 45,
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineTouchData: const LineTouchData(enabled: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: chartData.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList(),
                    isCurved: true,
                    curveSmoothness: 0.35,
                    color: color,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [color.withValues(alpha: 0.3), color.withValues(alpha: 0.0)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: delay)).slideY(begin: 0.1);
  }

  IconData _getIconForAction(String action) {
    if (action.toLowerCase().contains('validation')) return Icons.verified_rounded;
    if (action.toLowerCase().contains('bannissement') || action.toLowerCase().contains('suppression')) return Icons.block_rounded;
    if (action.toLowerCase().contains('paiement')) return Icons.payments_rounded;
    return Icons.history_rounded;
  }

  String _formatTimeAgo(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 60) return 'Il y a ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Il y a ${diff.inHours} heures';
    return 'Il y a ${diff.inDays} jours';
  }
}
