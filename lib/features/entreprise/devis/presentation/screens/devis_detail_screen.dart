import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../../../../data/models/devis_model.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/widgets/app_button.dart';

class DevisDetailScreen extends StatelessWidget {
  final DevisModel devis;

  const DevisDetailScreen({super.key, required this.devis});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currencyFormatter = NumberFormat.currency(locale: 'fr_FR', symbol: 'FCFA');
    final dateFormatter = DateFormat('dd MMMM yyyy à HH:mm', 'fr_FR');
    
    final isAccepted = devis.statut == 'accepte';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails du devis'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          // Header Status
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: isAccepted 
                  ? Colors.green.withValues(alpha: 0.1) 
                  : (devis.statut == 'refuse' ? Colors.red.withValues(alpha: 0.1) : Colors.orange.withValues(alpha: 0.1)),
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              border: Border.all(
                color: isAccepted 
                    ? Colors.green 
                    : (devis.statut == 'refuse' ? Colors.red : Colors.orange),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  isAccepted ? Icons.check_circle : (devis.statut == 'refuse' ? Icons.cancel : Icons.hourglass_bottom),
                  color: isAccepted ? Colors.green : (devis.statut == 'refuse' ? Colors.red : Colors.orange),
                  size: 32,
                ),
                AppSpacing.hMd,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isAccepted ? 'Devis Accepté !' : (devis.statut == 'refuse' ? 'Devis Refusé' : 'Devis en attente de réponse'),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: isAccepted ? Colors.green : (devis.statut == 'refuse' ? Colors.red : Colors.orange),
                        ),
                      ),
                      AppSpacing.vXs,
                      Text(
                        'Envoyé le ${dateFormatter.format(devis.dateEnvoi)}',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ).animate().slideY(begin: -0.1).fadeIn(),

          AppSpacing.vXxl,

          // Details Card
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              side: BorderSide(color: theme.colorScheme.outlineVariant),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Récapitulatif', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const Divider(),
                  AppSpacing.vSm,
                  _buildDetailRow('Montant proposé', currencyFormatter.format(devis.montant), theme),
                  AppSpacing.vMd,
                  _buildDetailRow('Délai estimé', devis.delaiEstime, theme),
                  AppSpacing.vMd,
                  const Text('Description détaillée', style: TextStyle(color: Colors.grey, fontSize: 12)),
                  AppSpacing.vXs,
                  Text(devis.description, style: const TextStyle(fontSize: 14, height: 1.5)),
                  
                  if (devis.fichierPdfUrl != null) ...[
                    AppSpacing.vLg,
                    const Divider(),
                    AppSpacing.vMd,
                    Row(
                      children: [
                        const Icon(Icons.picture_as_pdf, color: Colors.red),
                        AppSpacing.hSm,
                        const Expanded(child: Text('Devis_officiel.pdf', style: TextStyle(fontWeight: FontWeight.bold))),
                        IconButton(
                          icon: const Icon(Icons.download),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Téléchargement...')));
                          },
                        )
                      ],
                    )
                  ]
                ],
              ),
            ),
          ).animate().fadeIn(delay: 200.ms),

          AppSpacing.vXxl,

          if (isAccepted)
            AppButton(
              onPressed: () {
                // Here we would create an active project or navigate to it
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Transition vers le chantier actif...')));
              },
              text: 'Transformer en chantier actif',
              icon: Icons.construction,
            ).animate().scale(delay: 400.ms)
          else if (devis.statut == 'en_attente')
            OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
              ),
              child: const Text('Annuler le devis'),
            ).animate().fadeIn(delay: 400.ms)
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ],
    );
  }
}
