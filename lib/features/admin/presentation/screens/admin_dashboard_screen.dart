import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_spacing.dart';
import 'package:chantier_track/features/admin/providers/admin_providers.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(adminStatsProvider);
    final theme = Theme.of(context);
    final currencyFormatter = NumberFormat.compactCurrency(locale: 'fr_FR', symbol: 'FCFA');

    // Make layout responsive
    final isWideScreen = MediaQuery.of(context).size.width > 800;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vue d\'ensemble'),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Statistiques Globales', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            AppSpacing.vLg,
            
            // Stats Grid
            GridView.count(
              crossAxisCount: isWideScreen ? 3 : 1,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: AppSpacing.lg,
              crossAxisSpacing: AppSpacing.lg,
              childAspectRatio: isWideScreen ? 1.5 : 2.5,
              children: [
                _buildStatCard(
                  context,
                  title: 'Utilisateurs',
                  value: stats['totalUsers'].toString(),
                  icon: Icons.people,
                  color: Colors.blue,
                  chartData: stats['usersData'] as List<double>,
                ),
                _buildStatCard(
                  context,
                  title: 'Chantiers Actifs',
                  value: stats['activeProjects'].toString(),
                  icon: Icons.construction,
                  color: Colors.orange,
                  chartData: [10, 15, 20, 18, 25, 30, 34],
                ),
                _buildStatCard(
                  context,
                  title: 'Volume Financier',
                  value: currencyFormatter.format(stats['financialVolume']),
                  icon: Icons.account_balance_wallet,
                  color: Colors.green,
                  chartData: stats['financialData'] as List<double>,
                ),
              ],
            ),
            
            AppSpacing.vXxl,
            Text('Activité Récente', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            AppSpacing.vLg,
            
            // Recent Activity (Quick summary from logs)
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                side: BorderSide(color: theme.colorScheme.outlineVariant),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 3,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: theme.colorScheme.primaryContainer,
                      child: Icon(Icons.history, color: theme.colorScheme.primary),
                    ),
                    title: const Text('Validation de l\'entreprise "BatiPlus"'),
                    subtitle: const Text('Il y a 10 minutes - par Admin Sup'),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, {required String title, required String value, required IconData icon, required Color color, required List<double> chartData}) {
    final theme = Theme.of(context);
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusLg)),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: theme.textTheme.titleMedium?.copyWith(color: Colors.grey[700])),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
              ],
            ),
            AppSpacing.vSm,
            Text(value, style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
            const Spacer(),
            // Mini Chart (Sparkline)
            SizedBox(
              height: 40,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: const FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: chartData.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList(),
                      isCurved: true,
                      color: color,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: color.withValues(alpha: 0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
