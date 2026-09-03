import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../../../core/theme/app_spacing.dart';
import 'package:chantier_track/features/ia_assistant/providers/ia_providers.dart';

class EntrepriseReportsTab extends ConsumerStatefulWidget {
  final String projectId;
  const EntrepriseReportsTab({super.key, required this.projectId});

  @override
  ConsumerState<EntrepriseReportsTab> createState() => _EntrepriseReportsTabState();
}

class _EntrepriseReportsTabState extends ConsumerState<EntrepriseReportsTab> {
  final List<Map<String, String>> _reports = [
    {'date': '12 Août 2026', 'desc': 'Les fondations sont terminées à 100%. Coulage du béton sec.'},
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
                  final geminiService = ref.read(geminiServiceProvider);
                  final reportText = await geminiService.generateReport();
                  textController.text = reportText;
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Rapport généré par l\'IA !', style: TextStyle(color: Colors.amber))));
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e', style: const TextStyle(color: Colors.red))));
                  }
                }
              },
              icon: const Icon(Icons.auto_awesome, color: Colors.amber),
              label: const Text('Générer avec l\'IA', style: TextStyle(color: Colors.amber)),
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
        separatorBuilder: (_, __) => AppSpacing.vMd,
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
