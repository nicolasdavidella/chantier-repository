import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../../../core/theme/app_spacing.dart';

class DocumentsTab extends StatelessWidget {
  final String projectId;

  const DocumentsTab({super.key, required this.projectId});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Mock Documents
    final List<Map<String, String>> docs = [
      {'name': 'Plan_Architectural_V2.pdf', 'type': 'pdf', 'category': 'Plans', 'date': '01 Août 2026', 'size': '4.2 MB'},
      {'name': 'Devis_Initial_Signe.pdf', 'type': 'pdf', 'category': 'Contrats', 'date': '15 Juil 2026', 'size': '1.1 MB'},
      {'name': 'Permis_De_Construire.jpeg', 'type': 'image', 'category': 'Administratif', 'date': '10 Juil 2026', 'size': '2.5 MB'},
      {'name': 'Cahier_Des_Charges.docx', 'type': 'word', 'category': 'Plans', 'date': '05 Juil 2026', 'size': '800 KB'},
    ];

    IconData getFileIcon(String type) {
      switch (type) {
        case 'pdf':
          return Icons.picture_as_pdf;
        case 'image':
          return Icons.image;
        case 'word':
          return Icons.description;
        default:
          return Icons.insert_drive_file;
      }
    }

    Color getFileColor(String type) {
      switch (type) {
        case 'pdf':
          return Colors.red;
        case 'image':
          return Colors.blue;
        case 'word':
          return Colors.blueAccent;
        default:
          return Colors.grey;
      }
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.lg),
      itemCount: docs.length,
      itemBuilder: (context, index) {
        final doc = docs[index];
        
        return Card(
          elevation: 1,
          margin: const EdgeInsets.only(bottom: AppSpacing.md),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusMd)),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
            leading: Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: getFileColor(doc['type']!).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(getFileIcon(doc['type']!), color: getFileColor(doc['type']!), size: 32),
            ),
            title: Text(doc['name']!, style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: AppSpacing.xs),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(doc['category']!, style: const TextStyle(fontSize: 10)),
                  ),
                  AppSpacing.hSm,
                  Text('${doc['date']} • ${doc['size']}', style: theme.textTheme.bodySmall),
                ],
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.share_outlined),
                  tooltip: 'Partager',
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Partage en cours...')));
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.download_outlined),
                  tooltip: 'Télécharger',
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Téléchargement en cours...')));
                  },
                ),
              ],
            ),
          ),
        ).animate().slideX(begin: 0.1, curve: Curves.easeOut).fadeIn(delay: (index * 100).ms);
      },
    );
  }
}
