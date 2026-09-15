import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../../core/theme/app_spacing.dart';

class EntrepriseMediaTab extends ConsumerStatefulWidget {
  final String projectId;
  const EntrepriseMediaTab({super.key, required this.projectId});

  @override
  ConsumerState<EntrepriseMediaTab> createState() => _EntrepriseMediaTabState();
}

class _EntrepriseMediaTabState extends ConsumerState<EntrepriseMediaTab> {
  final List<String> _mediaUrls = [
    'https://picsum.photos/seed/media-chantier-1/500/500',
    'https://picsum.photos/seed/media-chantier-2/500/500',
  ];

  void _uploadMedia() {
    // Mock upload
    setState(() {
      _mediaUrls.insert(0, 'https://picsum.photos/seed/media-nouveau/500/500');
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Photo publiée avec succès !')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GridView.builder(
        padding: const EdgeInsets.all(AppSpacing.lg),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: AppSpacing.md,
          mainAxisSpacing: AppSpacing.md,
        ),
        itemCount: _mediaUrls.length,
        itemBuilder: (context, index) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            child: Image.network(
              _mediaUrls[index],
              fit: BoxFit.cover,
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _uploadMedia,
        icon: const Icon(Icons.camera_alt),
        label: const Text('Publier'),
      ),
    );
  }
}
