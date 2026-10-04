import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../../../core/theme/app_spacing.dart';
import 'package:chantier_track/features/ia_assistant/providers/ia_providers.dart';
import 'package:chantier_track/core/theme/app_colors.dart';


class EntrepriseReportsTab extends ConsumerStatefulWidget {
  final String projectId;
  const EntrepriseReportsTab({super.key, required this.projectId});

  @override
  ConsumerState<EntrepriseReportsTab> createState() => _EntrepriseReportsTabState();
}

class _EntrepriseReportsTabState extends ConsumerState<EntrepriseReportsTab> {
  final List<Map<String, dynamic>> _reports = [
    {
      'date': '12 Août 2026',
      'desc': 'Les fondations sont terminées à 100%. Coulage du béton sec.',
      'hasMedia': true,
    },
  ];

  void _addReport() {
    showDialog(
      context: context,
      builder: (ctx) {
        final textController = TextEditingController();
        return AlertDialog(
          title: const Text('Nouveau rapport'),
          content: TextField(
            controller: textController,
            decoration: const InputDecoration(
              hintText: 'Décrivez l\'avancement...',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          actions: [
            TextButton.icon(
              onPressed: () async {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Génération en cours...')));
                try {
                  final anthropicService = ref.read(anthropicServiceProvider);
                  final reportText = await anthropicService.generateReport();
                  textController.text = reportText;
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Brouillon généré avec succès !', style: TextStyle(color: AppColors.warning))));
                    }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e', style: const TextStyle(color: AppColors.error))));
                  }
                }
              },
              icon: const Icon(Icons.edit_document, color: AppColors.warning),
              label: const Text('Générer un brouillon', style: TextStyle(color: AppColors.warning)),
            ),
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Photo/Vidéo ajoutée !')));
                  },
                  icon: const Icon(Icons.camera_alt),
                  tooltip: 'Ajouter une photo/vidéo',
                ),
                IconButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Document ajouté !')));
                  },
                  icon: const Icon(Icons.attach_file),
                  tooltip: 'Joindre un fichier',
                ),
              ],
            ),
            const Spacer(),
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                if (textController.text.isNotEmpty) {
                  setState(() {
                    _reports.insert(0, {
                      'date': 'Aujourd\'hui',
                      'desc': textController.text,
                      'hasMedia': false,
                    });
                  });
                }
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Rapport ajouté')));
              },
              child: const Text('Soumettre'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ListView.separated(
        padding: const EdgeInsets.all(AppSpacing.lg),
        itemCount: _reports.length,
        separatorBuilder: (_, _) => AppSpacing.vMd,
        itemBuilder: (context, index) {
          final report = _reports[index];
          return Card(
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              side: BorderSide(color: theme.colorScheme.outlineVariant),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const FaIcon(FontAwesomeIcons.solidFileLines, size: 16, color: Colors.blueGrey),
                      AppSpacing.hSm,
                      Text(
                        report['date']!,
                        style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  AppSpacing.vSm,
                  Text(report['desc']!),
                  if (report['hasMedia'] == true) ...[
                    AppSpacing.vMd,
                    Container(
                      height: 120,
                      decoration: BoxDecoration(
                        color: AppColors.textSecondaryLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: Icon(Icons.image, size: 48, color: AppColors.textSecondaryLight),
                      ),
                    ),
                  ]
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addReport,
        icon: const Icon(Icons.add),
        label: const Text('Nouveau rapport'),
      ),
    );
  }
}
