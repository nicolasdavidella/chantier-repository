import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../../../core/theme/app_spacing.dart';
import '../../../../../../core/widgets/app_button.dart';

class AlertesTab extends StatefulWidget {
  final String projectId;

  const AlertesTab({super.key, required this.projectId});

  @override
  State<AlertesTab> createState() => _AlertesTabState();
}

class _AlertesTabState extends State<AlertesTab> {
  final List<Map<String, dynamic>> _alerts = [
    {
      'id': '1',
      'title': 'Anomalie Financière Détectée',
      'description': 'La facture "Plomberie (Acompte)" de 850,000 FCFA est 40% supérieure à l\'estimation initiale de cette phase.',
      'type': 'financial',
      'severity': 'high',
      'date': 'Il y a 2 heures',
      'isRead': false,
    },
    {
      'id': '2',
      'title': 'Risque de Retard',
      'description': 'Le coulage de la dalle a pris du retard suite aux intempéries. Impact estimé : +4 jours sur le planning.',
      'type': 'delay',
      'severity': 'medium',
      'date': 'Il y a 1 jour',
      'isRead': true,
    },
    {
      'id': '3',
      'title': 'Dépassement de Budget Imminent',
      'description': 'Le budget global est engagé à 92%. Attention aux prochaines dépenses.',
      'type': 'budget',
      'severity': 'high',
      'date': 'Il y a 3 jours',
      'isRead': true,
    },
    {
      'id': '4',
      'title': 'Contrôle Qualité Requis',
      'description': 'Les matériaux reçus (Fer à béton) n\'ont pas encore été validés par l\'ingénieur de contrôle.',
      'type': 'quality',
      'severity': 'low',
      'date': 'Il y a 1 semaine',
      'isRead': true,
    },
  ];

  void _markAsRead(int index) {
    setState(() {
      _alerts[index]['isRead'] = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Alerte marquée comme lue.')),
    );
  }

  void _contactPM() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Ouverture de la messagerie avec le chef de chantier...')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.lg),
      itemCount: _alerts.length,
      separatorBuilder: (_, __) => AppSpacing.vMd,
      itemBuilder: (context, index) {
        final alert = _alerts[index];
        final isRead = alert['isRead'] as bool;
        final severity = alert['severity'] as String;
        final type = alert['type'] as String;

        Color getSeverityColor() {
          switch (severity) {
            case 'high':
              return theme.colorScheme.error;
            case 'medium':
              return Colors.orange;
            case 'low':
              return Colors.blue;
            default:
              return Colors.grey;
          }
        }

        IconData getIcon() {
          switch (type) {
            case 'financial':
              return Icons.money_off;
            case 'delay':
              return Icons.schedule_outlined;
            case 'budget':
              return Icons.account_balance_wallet_outlined;
            case 'quality':
              return Icons.verified_user_outlined;
            default:
              return Icons.notifications;
          }
        }

        return Card(
          elevation: isRead ? 0 : 2,
          color: isRead ? theme.cardColor : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
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
                  backgroundColor: getSeverityColor().withValues(alpha: 0.1),
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
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ).animate().scale(duration: 300.ms, delay: 200.ms),
                  )
              ],
            ),
            title: Text(
              alert['title'] as String,
              style: TextStyle(fontWeight: isRead ? FontWeight.normal : FontWeight.bold),
            ),
            subtitle: Text(alert['date'] as String, style: theme.textTheme.bodySmall),
            childrenPadding: const EdgeInsets.fromLTRB(AppSpacing.xl, 0, AppSpacing.xl, AppSpacing.lg),
            expandedCrossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppSpacing.vXs,
              Text(alert['description'] as String, style: theme.textTheme.bodyMedium?.copyWith(height: 1.4)),
              AppSpacing.vLg,
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (!isRead)
                    TextButton.icon(
                      onPressed: () => _markAsRead(index),
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
  }
}
