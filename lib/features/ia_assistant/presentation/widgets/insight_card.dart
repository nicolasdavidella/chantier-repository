import 'package:flutter/material.dart';
import '../../../../core/theme/app_spacing.dart';

class InsightCard extends StatelessWidget {
  final String titre;
  final String description;
  final String type; // 'anomalie' or 'recommandation'
  final String? severite; // 'haute', 'moyenne', 'basse'

  const InsightCard({
    super.key,
    required this.titre,
    required this.description,
    required this.type,
    this.severite,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    IconData icon;
    Color iconColor;
    Color bgColor;

    if (type == 'anomalie') {
      icon = Icons.warning_amber_rounded;
      if (severite == 'haute') {
        iconColor = Colors.red;
        bgColor = Colors.red.withValues(alpha: 0.05);
      } else {
        iconColor = Colors.orange;
        bgColor = Colors.orange.withValues(alpha: 0.05);
      }
    } else {
      icon = Icons.lightbulb_outline;
      iconColor = Colors.blue;
      bgColor = Colors.blue.withValues(alpha: 0.05);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: bgColor, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: bgColor,
            child: Icon(icon, color: iconColor),
          ),
          AppSpacing.hMd,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titre,
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                AppSpacing.vXs,
                Text(
                  description,
                  style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
