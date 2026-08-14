import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../../../../core/theme/app_spacing.dart';
import '../../providers/create_project_provider.dart';

class StepDocuments extends ConsumerWidget {
  const StepDocuments({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(projectCreationProvider).value;
    final documents = data?.documents ?? [];
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Plans et documents',
            style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          AppSpacing.vSm,
          Text(
            'Ajoutez des plans, esquisses ou photos du terrain pour aider les entreprises à évaluer votre projet.',
            style: theme.textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
          ),
          AppSpacing.vXxl,
          
          // Upload Button
          InkWell(
            onTap: () async {
              final ImagePicker picker = ImagePicker();
              final List<XFile> images = await picker.pickMultiImage();
              if (images.isNotEmpty) {
                ref.read(projectCreationProvider.notifier).addDocuments(images);
              }
            },
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                border: Border.all(color: theme.colorScheme.primary.withOpacity(0.5), width: 2, style: BorderStyle.solid),
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              ),
              child: Column(
                children: [
                  Icon(Icons.cloud_upload_outlined, size: 48, color: theme.colorScheme.primary),
                  AppSpacing.vMd,
                  Text(
                    'Parcourir les fichiers',
                    style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.bold),
                  ),
                  AppSpacing.vXs,
                  Text(
                    'Images (JPG, PNG) acceptées',
                    style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ),
          
          AppSpacing.vXxl,
          
          // Grid Preview
          if (documents.isNotEmpty) ...[
            Text('Fichiers ajoutés (${documents.length})', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            AppSpacing.vMd,
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: AppSpacing.sm,
                mainAxisSpacing: AppSpacing.sm,
              ),
              itemCount: documents.length,
              itemBuilder: (context, index) {
                return Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                        image: DecorationImage(
                          image: kIsWeb 
                              ? NetworkImage(documents[index].path) as ImageProvider
                              : FileImage(File(documents[index].path)),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: InkWell(
                        onTap: () => ref.read(projectCreationProvider.notifier).removeDocument(index),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close, size: 16, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ]
        ],
      ),
    );
  }
}
