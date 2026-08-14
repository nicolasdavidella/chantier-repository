import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../providers/search_entreprises_provider.dart';

class CompareEntreprisesScreen extends ConsumerWidget {
  const CompareEntreprisesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedEntreprises = ref.watch(selectedEntreprisesProvider);

    if (selectedEntreprises.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Comparateur')),
        body: const Center(child: Text('Aucune entreprise sélectionnée.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Comparateur'),
        actions: [
          TextButton(
            onPressed: () {
              ref.read(comparisonListProvider.notifier).clear();
              Navigator.of(context).pop();
            },
            child: const Text('Effacer'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: DataTable(
              headingRowHeight: 120,
              dataRowMinHeight: 60,
              dataRowMaxHeight: 100,
              columnSpacing: 24,
              columns: [
                const DataColumn(label: Text('Critères', style: TextStyle(fontWeight: FontWeight.bold))),
                ...selectedEntreprises.map((e) => DataColumn(
                      label: SizedBox(
                        width: 140,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundImage: e.realisations.isNotEmpty
                                  ? CachedNetworkImageProvider(e.realisations.first)
                                  : null,
                              child: e.realisations.isEmpty ? const Icon(Icons.business) : null,
                            ),
                            AppSpacing.vXs,
                            Text(
                              e.raisonSociale,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    )),
              ],
              rows: [
                DataRow(
                  cells: [
                    const DataCell(Text('Note moyenne')),
                    ...selectedEntreprises.map((e) => DataCell(
                          Row(
                            children: [
                              const Icon(Icons.star, color: Colors.amber, size: 16),
                              const SizedBox(width: 4),
                              Text('${e.noteMoyenne} (${e.nombreAvis})'),
                            ],
                          ),
                        )),
                  ],
                ),
                DataRow(
                  cells: [
                    const DataCell(Text('Expérience')),
                    ...selectedEntreprises.map((e) => DataCell(Text('${e.anneesExperience} ans'))),
                  ],
                ),
                DataRow(
                  cells: [
                    const DataCell(Text('Certifié')),
                    ...selectedEntreprises.map((e) => DataCell(
                          e.certifie
                              ? const Icon(Icons.check_circle, color: Colors.green)
                              : const Icon(Icons.cancel, color: Colors.red),
                        )),
                  ],
                ),
                DataRow(
                  cells: [
                    const DataCell(Text('Zones d\'intervention')),
                    ...selectedEntreprises.map((e) => DataCell(
                          Text(e.zoneIntervention.join(', '), maxLines: 3, overflow: TextOverflow.ellipsis),
                        )),
                  ],
                ),
                DataRow(
                  cells: [
                    const DataCell(Text('Prix Moyen')),
                    ...selectedEntreprises.map((e) => DataCell(
                          Text(e.prixMoyen ?? 'N/A', maxLines: 2, overflow: TextOverflow.ellipsis),
                        )),
                  ],
                ),
                DataRow(
                  cells: [
                    const DataCell(Text('Délai Moyen')),
                    ...selectedEntreprises.map((e) => DataCell(
                          Text(e.delaiMoyen ?? 'N/A', maxLines: 2, overflow: TextOverflow.ellipsis),
                        )),
                  ],
                ),
                DataRow(
                  cells: [
                    const DataCell(Text('Spécialités')),
                    ...selectedEntreprises.map((e) => DataCell(
                          Wrap(
                            spacing: 4,
                            runSpacing: 4,
                            children: e.specialites.map((s) => Chip(
                                  label: Text(s, style: const TextStyle(fontSize: 10)),
                                  padding: EdgeInsets.zero,
                                )).toList(),
                          ),
                        )),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
