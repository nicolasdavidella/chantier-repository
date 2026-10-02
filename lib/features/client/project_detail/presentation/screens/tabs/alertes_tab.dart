import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../../../core/theme/app_spacing.dart';
import '../../../../../../core/widgets/app_button.dart';
import 'package:chantier_track/core/theme/app_colors.dart';
import 'package:intl/intl.dart';

class AlertesTab extends StatefulWidget {
  final String projectId;

  const AlertesTab({super.key, required this.projectId});

  @override
  State<AlertesTab> createState() => _AlertesTabState();
}

class _AlertesTabState extends State<AlertesTab> {

  void _markAsRead(String alertId) async {
    await FirebaseFirestore.instance.collection('alertes').doc(alertId).update({'isRead': true});
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Alerte marquée comme lue.')),
      );
    }
  }

  void _contactPM() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Ouverture de la messagerie avec le chef de chantier...')),
    );
  }

  // Fonction de test pour générer une fausse alerte en l'absence de Cloud Functions
  Future<void> _genererAlerteTest() async {
    final alert = {
      'projectId': widget.projectId,
      'title': 'Test : Dépassement de Budget Imminent',
      'description': 'Le budget global est engagé à 92%. Attention aux prochaines dépenses.',
      'type': 'budget',
      'severity': 'high',
      'statut': 'alerte_rouge',
      'date': FieldValue.serverTimestamp(),
      'isRead': false,
    };
    await FirebaseFirestore.instance.collection('alertes').add(alert);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        // En mode dev, bouton pour simuler l'alerte
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
          child: OutlinedButton.icon(
            onPressed: _genererAlerteTest,
            icon: const Icon(Icons.warning_amber),
            label: const Text('Simuler une alerte (Test)'),
            style: OutlinedButton.styleFrom(foregroundColor: AppColors.error),
          ),
        ),
        
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('alertes')
                .where('projectId', isEqualTo: widget.projectId)
                .orderBy('date', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final alertsDocs = snapshot.data?.docs ?? [];

              if (alertsDocs.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle_outline, size: 64, color: AppColors.primary.withOpacity(0.5)),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        'Aucune anomalie détectée',
                        style: theme.textTheme.titleMedium?.copyWith(color: AppColors.primary),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      const Text('Le projet se déroule comme prévu.'),
                    ],
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.all(AppSpacing.lg),
                itemCount: alertsDocs.length,
                separatorBuilder: (_, __) => AppSpacing.vMd,
                itemBuilder: (context, index) {
                  final alertDoc = alertsDocs[index];
                  final alert = alertDoc.data() as Map<String, dynamic>;
                  final alertId = alertDoc.id;
                  
                  final isRead = alert['isRead'] as bool? ?? false;
                  final severity = alert['severity'] as String? ?? 'low';
                  final type = alert['type'] as String? ?? 'general';
                  
                  String dateStr = '';
                  if (alert['date'] != null) {
                    final date = (alert['date'] as Timestamp).toDate();
                    dateStr = DateFormat('dd/MM/yyyy HH:mm').format(date);
                  }

                  Color getSeverityColor() {
                    switch (severity) {
                      case 'high':
                        return theme.colorScheme.error;
                      case 'medium':
                        return AppColors.warning;
                      case 'low':
                        return AppColors.primary;
                      default:
                        return AppColors.textSecondaryLight;
                    }
                  }

                  IconData getIcon() {
                    switch (type) {
                      case 'budget':
                      case 'financial':
                        return Icons.money_off;
                      case 'delay':
                        return Icons.schedule_outlined;
                      case 'quality':
                        return Icons.verified_user_outlined;
                      default:
                        return Icons.notifications;
                    }
                  }

                  return Card(
                    elevation: isRead ? 0 : 2,
                    color: isRead ? theme.cardColor : theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                      side: BorderSide(color: isRead ? theme.colorScheme.outlineVariant : getSeverityColor(), width: isRead ? 1 : 1.5),
                    ),
                    child: ExpansionTile(
                      shape: const Border(),
                      leading: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          CircleAvatar(
                            backgroundColor: getSeverityColor().withOpacity(0.1),
                            child: Icon(getIcon(), color: getSeverityColor()),
                          ),
                          if (!isRead)
                            Positioned(
                              top: -2,
                              right: -2,
                              child: Container(
                                width: 12,
                                height: 12,
                                decoration: const BoxDecoration(
                                  color: AppColors.error,
                                  shape: BoxShape.circle,
                                ),
                              ).animate().scale(duration: 300.ms, delay: 200.ms),
                            )
                        ],
                      ),
                      title: Text(
                        alert['title'] ?? 'Alerte',
                        style: TextStyle(fontWeight: isRead ? FontWeight.normal : FontWeight.bold),
                      ),
                      subtitle: Text(dateStr, style: theme.textTheme.bodySmall),
                      childrenPadding: const EdgeInsets.fromLTRB(AppSpacing.xl, 0, AppSpacing.xl, AppSpacing.lg),
                      expandedCrossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppSpacing.vXs,
                        Text(alert['description'] ?? '', style: theme.textTheme.bodyMedium?.copyWith(height: 1.4)),
                        AppSpacing.vLg,
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            if (!isRead)
                              TextButton.icon(
                                onPressed: () => _markAsRead(alertId),
                                icon: const Icon(Icons.check),
                                label: const Text('Marquer lu'),
                              ),
                            AppSpacing.hSm,
                            AppButton(
                              onPressed: _contactPM,
                              text: 'Contacter',
                              icon: Icons.chat_bubble_outline,
                              isOutlined: true,
                            ),
                          ],
                        )
                      ],
                    ),
                  ).animate().slideX(begin: 0.1, curve: Curves.easeOut).fadeIn(delay: (index * 100).ms);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
