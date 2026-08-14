import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../../../core/theme/app_spacing.dart';

class DepensesTab extends StatefulWidget {
  final String projectId;
  final double budgetTotal;

  const DepensesTab({super.key, required this.projectId, required this.budgetTotal});

  @override
  State<DepensesTab> createState() => _DepensesTabState();
}

class _DepensesTabState extends State<DepensesTab> {
  String _selectedCategory = 'Toutes';
  final List<String> _categories = ['Toutes', 'Matériaux', 'Main d\'œuvre', 'Équipement', 'Autre'];

  // Mock data for expenses
  final _expenses = [
    {'title': 'Achat Ciment Portland (100 sacs)', 'amount': 450000.0, 'category': 'Matériaux', 'date': '10 Août 2026', 'isAnomaly': false},
    {'title': 'Location Bétonnière (semaine)', 'amount': 150000.0, 'category': 'Équipement', 'date': '08 Août 2026', 'isAnomaly': false},
    {'title': 'Facture Plomberie (Acompte)', 'amount': 850000.0, 'category': 'Main d\'œuvre', 'date': '05 Août 2026', 'isAnomaly': true, 'anomalyReason': 'Montant inhabituellement élevé pour cette phase.'},
    {'title': 'Achat Fer à béton (10 tonnes)', 'amount': 3200000.0, 'category': 'Matériaux', 'date': '01 Août 2026', 'isAnomaly': false},
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final totalEngaged = _expenses.fold<double>(0, (sum, item) => sum + (item['amount'] as double));
    final budgetTotal = widget.budgetTotal > 0 ? widget.budgetTotal : 15000000.0; // Fallback to 15M if 0
    final remaining = budgetTotal - totalEngaged;
    final engagedPercentage = (totalEngaged / budgetTotal) * 100;

    final filteredExpenses = _selectedCategory == 'Toutes'
        ? _expenses
        : _expenses.where((e) => e['category'] == _selectedCategory).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Budget Summary (Gauge-like view)
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusLg)),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Row(
                children: [
                  SizedBox(
                    width: 100,
                    height: 100,
                    child: Stack(
                      children: [
                        PieChart(
                          PieChartData(
                            sectionsSpace: 0,
                            centerSpaceRadius: 35,
                            startDegreeOffset: -90,
                            sections: [
                              PieChartSectionData(
                                color: engagedPercentage > 90 ? Colors.red : theme.colorScheme.primary,
                                value: totalEngaged,
                                title: '',
                                radius: 15,
                              ),
                              PieChartSectionData(
                                color: theme.colorScheme.surfaceContainerHighest,
                                value: remaining > 0 ? remaining : 0,
                                title: '',
                                radius: 15,
                              ),
                            ],
                          ),
                        ),
                        Center(
                          child: Text(
                            '${engagedPercentage.toStringAsFixed(0)}%',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                        ),
                      ],
                    ),
                  ).animate().scale(delay: 200.ms, duration: 600.ms, curve: Curves.easeOutBack),
                  AppSpacing.hXxl,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Budget Global', style: theme.textTheme.titleMedium?.copyWith(color: Colors.grey)),
                        Text('${budgetTotal.toStringAsFixed(0)} FCFA', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                        AppSpacing.vSm,
                        Text('Engagé : ${totalEngaged.toStringAsFixed(0)} FCFA', style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
                        Text('Restant : ${remaining > 0 ? remaining.toStringAsFixed(0) : 0} FCFA', style: const TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          AppSpacing.vXxl,

          // 2. Expenses List & Filters
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Dépenses', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              DropdownButton<String>(
                value: _selectedCategory,
                items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedCategory = val);
                },
                underline: const SizedBox(),
                icon: const Icon(Icons.filter_list),
              ),
            ],
          ),
          AppSpacing.vLg,

          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filteredExpenses.length,
            itemBuilder: (context, index) {
              final expense = filteredExpenses[index];
              final isAnomaly = expense['isAnomaly'] as bool;

              return Card(
                margin: const EdgeInsets.only(bottom: AppSpacing.md),
                color: isAnomaly ? theme.colorScheme.errorContainer.withValues(alpha: 0.3) : theme.cardColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  side: isAnomaly ? BorderSide(color: theme.colorScheme.error, width: 1) : BorderSide(color: theme.colorScheme.outlineVariant),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(AppSpacing.md),
                  leading: CircleAvatar(
                    backgroundColor: isAnomaly ? theme.colorScheme.errorContainer : theme.colorScheme.primaryContainer,
                    child: Icon(
                      isAnomaly ? Icons.warning_amber_rounded : Icons.receipt_long,
                      color: isAnomaly ? theme.colorScheme.error : theme.colorScheme.primary,
                    ),
                  ),
                  title: Text(expense['title'] as String, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppSpacing.vXs,
                      Text('${expense['category']} • ${expense['date']}'),
                      if (isAnomaly) ...[
                        AppSpacing.vXs,
                        Row(
                          children: [
                            Icon(Icons.smart_toy, size: 14, color: theme.colorScheme.error),
                            const SizedBox(width: 4),
                            Expanded(child: Text(expense['anomalyReason'] as String, style: TextStyle(color: theme.colorScheme.error, fontSize: 12))),
                          ],
                        )
                      ]
                    ],
                  ),
                  trailing: Text(
                    '${(expense['amount'] as double).toStringAsFixed(0)} FCFA',
                    style: TextStyle(fontWeight: FontWeight.bold, color: isAnomaly ? theme.colorScheme.error : null, fontSize: 16),
                  ),
                ),
              ).animate().fadeIn(delay: (index * 100).ms).slideY(begin: 0.2, curve: Curves.easeOut);
            },
          ),
          
          AppSpacing.vXxl,
        ],
      ),
    );
  }
}
