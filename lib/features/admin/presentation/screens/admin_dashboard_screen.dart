import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_spacing.dart';
import 'package:chantier_track/features/admin/providers/admin_providers.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/data/auth_repository.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(adminStatsProvider);
    final activityLogs = ref.watch(activityLogsProvider);
    final theme = Theme.of(context);
    final currencyFormatter = NumberFormat.compactCurrency(locale: 'fr_FR', symbol: 'FCFA');

    final isWideScreen = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Tableau de bord', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: const Color(0xFF1E293B))),
        centerTitle: false,
        actions: [
          if (!isWideScreen)
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.redAccent),
              tooltip: 'Déconnexion',
              onPressed: () async {
                await ref.read(authRepositoryProvider).signOut();
                if (context.mounted) {
                  context.go('/login');
                }
              },
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
                gradient: const LinearGradient(
                  colors: [Color(0xFF0F6E56), Color(0xFF169E7B)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
                boxShadow: [
                  BoxShadow(color: const Color(0xFF0F6E56).withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 10)),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Bienvenue, Administrateur 👋', style: theme.textTheme.headlineSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                        AppSpacing.vSm,
                        const Text('Voici un résumé de l\'activité sur la plateforme Chantier Track aujourd\'hui.', style: TextStyle(color: Colors.white70, fontSize: 16)),
                      ],
                    ),
                  ),
                  if (isWideScreen)
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(AppSpacing.radiusLg)),
                      child: const Icon(Icons.analytics_rounded, color: Colors.white, size: 48),
                    )
                ],
              ),
            ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.2),

            AppSpacing.vXxl,
            Text('Aperçu des performances', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: const Color(0xFF334155))),
            AppSpacing.vLg,

            // Stats Grid
            GridView.count(
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
                  color: const Color(0xFF3B82F6),
                  chartData: stats['usersData'] as List<double>,
                  delay: 100,
                ),
                _buildStatCard(
                  context,
                  title: 'Chantiers Actifs',
                  value: stats['activeProjects'].toString(),
                  icon: Icons.construction_rounded,
                  color: const Color(0xFFE8601A),
                  chartData: [10, 15, 20, 18, 25, 30, 34],
                  delay: 200,
                ),
                _buildStatCard(
                  context,
                  title: 'Volume Financier',
                  value: currencyFormatter.format(stats['financialVolume']),
                  icon: Icons.account_balance_wallet_rounded,
                  color: const Color(0xFF10B981),
                  chartData: stats['financialData'] as List<double>,
                  delay: 300,
                ),
              ],
            ),

            AppSpacing.vXxl,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Activité Récente', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: const Color(0xFF334155))),
                TextButton(
                  onPressed: () {},
                  child: const Text('Voir tout', style: TextStyle(color: Color(0xFF0F6E56), fontWeight: FontWeight.bold)),
                )
              ],
            ),
            AppSpacing.vMd,

            // Recent Activity from Provider
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 15, offset: const Offset(0, 5)),
                ],
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: activityLogs.length,
                separatorBuilder: (context, index) => Divider(height: 1, color: Colors.grey.shade100),
                itemBuilder: (context, index) {
                  final log = activityLogs[index];
                  final isRecent = DateTime.now().difference(log.timestamp).inHours < 1;
                  
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _getIconForAction(log.action),
                        color: const Color(0xFF475569),
                      ),
                    ),
                    title: Text(log.action, style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF1E293B))),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        'Par ${log.user} • ${_formatTimeAgo(log.timestamp)}',
                        style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                      ),
                    ),
                    trailing: isRecent
                        ? Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text('Nouveau', style: TextStyle(color: Color(0xFF10B981), fontSize: 11, fontWeight: FontWeight.bold)),
                          )
                        : null,
                  ).animate().fadeIn(delay: Duration(milliseconds: 400 + (index * 100))).slideX(begin: 0.1);
                },
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 15, offset: const Offset(0, 5)),
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
                  color: const Color(0xFF10B981).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.arrow_upward_rounded, color: Color(0xFF10B981), size: 14),
                    SizedBox(width: 4),
                    Text('+12%', style: TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
          AppSpacing.vXs,
          Text(title, style: TextStyle(fontSize: 14, color: Colors.grey.shade500, fontWeight: FontWeight.w500)),
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
