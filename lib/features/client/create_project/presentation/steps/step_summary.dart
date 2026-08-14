import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../../../../core/theme/app_spacing.dart';
import '../../providers/create_project_provider.dart';

class StepSummary extends ConsumerWidget {
  const StepSummary({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(projectCreationProvider).value;
    final theme = Theme.of(context);
    final currencyFormatter = NumberFormat.currency(locale: 'fr_FR', symbol: 'FCFA', decimalDigits: 0);
    final dateFormatter = DateFormat('dd MMM yyyy');

    if (data == null) return const SizedBox();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Récapitulatif',
            style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          AppSpacing.vSm,
          Text(
            'Vérifiez les informations avant de publier votre projet.',
            style: theme.textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
          ),
          AppSpacing.vXxl,
          
          _SummarySection(
            title: 'Général',
            icon: Icons.info_outline,
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SummaryRow(label: 'Titre', value: data.titre),
                _SummaryRow(label: 'Type', value: data.typeConstruction),
                _SummaryRow(label: 'Description', value: data.description),
              ],
            ),
          ),
          
          AppSpacing.vLg,
          
          _SummarySection(
            title: 'Localisation',
            icon: Icons.location_on_outlined,
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SummaryRow(label: 'Ville', value: data.ville),
                _SummaryRow(label: 'Quartier', value: data.quartier),
              ],
            ),
          ),
          
          AppSpacing.vLg,
          
          _SummarySection(
            title: 'Budget et Dates',
            icon: Icons.account_balance_wallet_outlined,
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SummaryRow(label: 'Budget', value: data.budget != null ? currencyFormatter.format(data.budget) : 'Non défini'),
                _SummaryRow(label: 'Début', value: data.dateDebut != null ? dateFormatter.format(data.dateDebut!) : 'Non défini'),
                _SummaryRow(label: 'Fin estimée', value: data.dateFin != null ? dateFormatter.format(data.dateFin!) : 'Non défini'),
              ],
            ),
          ),
          
          AppSpacing.vLg,
          
          _SummarySection(
            title: 'Documents',
            icon: Icons.attach_file,
            content: data.documents.isEmpty
                ? Text('Aucun document joint', style: theme.textTheme.bodyMedium?.copyWith(fontStyle: FontStyle.italic))
                : SizedBox(
                    height: 80,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: data.documents.length,
                      separatorBuilder: (_, __) => AppSpacing.hSm,
                      itemBuilder: (context, index) {
                        return Container(
                          width: 80,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                            image: DecorationImage(
                              image: kIsWeb 
                                  ? NetworkImage(data.documents[index].path) as ImageProvider
                                  : FileImage(File(data.documents[index].path)),
                              fit: BoxFit.cover,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _SummarySection extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget content;

  const _SummarySection({required this.title, required this.icon, required this.content});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: theme.colorScheme.primary),
              AppSpacing.hSm,
              Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            ],
          ),
          const Divider(height: AppSpacing.xl),
          content,
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(label, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          ),
          Expanded(
            child: Text(value, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}
