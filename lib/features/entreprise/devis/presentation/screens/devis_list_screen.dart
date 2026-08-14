import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../../data/models/devis_model.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../providers/devis_provider.dart';
import 'devis_detail_screen.dart';

class DevisListScreen extends ConsumerStatefulWidget {
  const DevisListScreen({super.key});

  @override
  ConsumerState<DevisListScreen> createState() => _DevisListScreenState();
}

class _DevisListScreenState extends ConsumerState<DevisListScreen> {
  @override
  void initState() {
    super.initState();
    // Setting up a listener for simulated FCM notifications
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.listenManual(devisProvider, (previous, next) {
        if (previous == null) return;
        
        // Find if any quote transitioned to 'accepte'
        for (var n in next) {
          final p = previous.firstWhere((element) => element.id == n.id, orElse: () => n);
          if (p.statut != 'accepte' && n.statut == 'accepte') {
            _showFCMNotification(n);
          }
        }
      });
    });
  }

  void _showFCMNotification(DevisModel devis) {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            AppSpacing.hSm,
            Expanded(child: Text('Félicitations ! Votre devis a été accepté.')),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'VOIR',
          textColor: Colors.white,
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => DevisDetailScreen(devis: devis)));
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final devisList = ref.watch(devisProvider);
    final theme = Theme.of(context);
    final currencyFormatter = NumberFormat.currency(locale: 'fr_FR', symbol: 'FCFA');
    final dateFormatter = DateFormat('dd MMM yyyy', 'fr_FR');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes devis envoyés'),
      ),
      body: devisList.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.assignment_outlined, size: 64, color: Colors.grey[400]),
                  AppSpacing.vMd,
                  Text('Aucun devis envoyé', style: theme.textTheme.titleMedium?.copyWith(color: Colors.grey[600])),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.lg),
              itemCount: devisList.length,
              separatorBuilder: (_, __) => AppSpacing.vMd,
              itemBuilder: (context, index) {
                final devis = devisList[index];
                
                Color getStatusColor() {
                  switch (devis.statut) {
                    case 'accepte': return Colors.green;
                    case 'refuse': return Colors.red;
                    case 'en_attente': return Colors.orange;
                    default: return Colors.grey;
                  }
                }

                String getStatusLabel() {
                  switch (devis.statut) {
                    case 'accepte': return 'Accepté';
                    case 'refuse': return 'Refusé';
                    case 'en_attente': return 'En attente';
                    default: return 'Inconnu';
                  }
                }

                return Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                    side: BorderSide(color: theme.colorScheme.outlineVariant),
                  ),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => DevisDetailScreen(devis: devis)));
                    },
                    borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(dateFormatter.format(devis.dateEnvoi), style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey)),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: getStatusColor().withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: getStatusColor().withValues(alpha: 0.5)),
                                ),
                                child: Text(
                                  getStatusLabel(),
                                  style: TextStyle(color: getStatusColor(), fontWeight: FontWeight.bold, fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                          AppSpacing.vSm,
                          Text(
                            'Projet ID: ${devis.projectId}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          AppSpacing.vXs,
                          Text(
                            'Montant: ${currencyFormatter.format(devis.montant)}',
                            style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold),
                          ),
                          AppSpacing.vXs,
                          Text(
                            'Délai: ${devis.delaiEstime}',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ),
                ).animate().slideX(begin: 0.1, curve: Curves.easeOut).fadeIn(delay: (index * 100).ms);
              },
            ),
    );
  }
}
