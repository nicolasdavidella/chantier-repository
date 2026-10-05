import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import '../../../../../core/theme/app_spacing.dart';
import 'package:chantier_track/features/entreprise/offres/providers/offres_provider.dart';
import 'package:chantier_track/core/theme/app_colors.dart';


class OffreDetailScreen extends ConsumerWidget {
  final ProjectDiffusion diffusion;

  const OffreDetailScreen({super.key, required this.diffusion});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projet = diffusion.project;
    final theme = Theme.of(context);
    final candidatureState = ref.watch(candidatureControllerProvider);

    // Formatteur de date
    final dateFormat = DateFormat('dd MMM yyyy');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails de l\'Offre'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Badge IA ou Standard
            if (projet.creationSource == 'ia_assistant') ...[
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFECFDF5), Color(0xFFD1FAE5)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFA7F3D0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Projet IA",
                      style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF065F46), fontSize: 13),
                    ),
                    if (projet.planChoisi != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        "Variante retenue : ${projet.planChoisi}",
                        style: const TextStyle(color: Color(0xFF047857), fontSize: 12),
                      ),
                    ],
                  ],
                ),
              ),
            ],

            Text(
              projet.titre,
              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppSpacing.lg),
            
            // Carte Info Principales
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: theme.colorScheme.outline.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  _buildInfoRow(
                    context, 
                    Icons.location_on, 
                    'Localisation', 
                    '${projet.localisation['ville'] ?? ''}, ${projet.localisation['quartier'] ?? ''}',
                  ),
                  const Divider(height: AppSpacing.xl),
                  _buildInfoRow(
                    context, 
                    Icons.account_balance_wallet, 
                    'Budget Prévu', 
                    '${projet.budgetPrevisionnel.toStringAsFixed(0)} FCFA',
                  ),
                  const Divider(height: AppSpacing.xl),
                  _buildInfoRow(
                    context, 
                    Icons.calendar_today, 
                    'Date de début', 
                    dateFormat.format(projet.dateDebut),
                  ),
                  const Divider(height: AppSpacing.xl),
                  _buildInfoRow(
                    context, 
                    Icons.event_available, 
                    'Date de fin estimée', 
                    dateFormat.format(projet.dateFinPrevue),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: AppSpacing.xl),
            Text(
              'Description du Projet',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              projet.description,
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
            ),
            
            if (projet.listeDocuments.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.xl),
              Text(
                'Documents Joints',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppSpacing.md),
              ...projet.listeDocuments.map((docUrl) => 
                ListTile(
                  leading: const FaIcon(FontAwesomeIcons.filePdf, color: AppColors.error),
                  title: Text('Document attaché', style: theme.textTheme.bodyMedium),
                  trailing: const Icon(Icons.download),
                  onTap: () {},
                )
              ),
            ],
            
            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: candidatureState.isLoading ? null : () {
                    context.pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Offre ignorée')),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(color: theme.colorScheme.error),
                    foregroundColor: theme.colorScheme.error,
                  ),
                  child: const Text('Décliner'),
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: candidatureState.isLoading ? null : () => _showAcceptModal(context, ref, projet),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: const Color(0xFF143D2B),
                    foregroundColor: Colors.white,
                    elevation: 3,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: candidatureState.isLoading 
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Je suis capable de réaliser', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAcceptModal(BuildContext context, WidgetRef ref, dynamic projet) {
    final noteController = TextEditingController();
    final quoteController = TextEditingController(text: projet.budgetPrevisionnel > 0 ? projet.budgetPrevisionnel.toStringAsFixed(0) : '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 24),
                SizedBox(width: 8),
                Text(
                  "Valider votre capacité",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF143D2B)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              "Indiquez au client vos disponibilités ou un devis indicatif pour ce chantier :",
              style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
            ),
            const SizedBox(height: 18),
            TextField(
              controller: quoteController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Devis / Budget estimé (FCFA)",
                hintText: "Ex: 45000000",
                prefixIcon: const Icon(Icons.account_balance_wallet_outlined),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: noteController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: "Message technique pour le client (optionnel)",
                hintText: "Ex: Disponibilité immédiate de nos équipes, expérience sur des projets similaires...",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF143D2B),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () async {
                  Navigator.pop(ctx);
                  final parsedQuote = double.tryParse(quoteController.text.trim());
                  final message = noteController.text.trim();

                  try {
                    await ref.read(candidatureControllerProvider.notifier).accepterProjet(
                      diffusion.diffusionId,
                      projet,
                      commentaire: message.isNotEmpty ? message : null,
                      devisEstime: parsedQuote,
                    );
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          backgroundColor: Color(0xFF143D2B),
                          content: Text("Capacité confirmée ! Le client a été notifié instantanément."),
                        ),
                      );
                      context.pop();
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(backgroundColor: Colors.redAccent, content: Text("Erreur: $e")),
                      );
                    }
                  }
                },
                child: const Text("Confirmer & Envoyer au Client", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String title, String value) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(width: AppSpacing.md),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: theme.textTheme.bodySmall?.copyWith(color: AppColors.textSecondaryLight)),
            Text(value, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
          ],
        ),
      ],
    );
  }
}
