import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../providers/create_project_provider.dart';

class StepGeneral extends ConsumerStatefulWidget {
  final GlobalKey<FormState> formKey;
  
  const StepGeneral({super.key, required this.formKey});

  @override
  ConsumerState<StepGeneral> createState() => _StepGeneralState();
}

class _StepGeneralState extends ConsumerState<StepGeneral> {
  late TextEditingController _titleController;
  late TextEditingController _descController;
  String _selectedType = 'Construction neuve';

  final List<String> _types = [
    'Construction neuve',
    'Rénovation totale',
    'Rénovation partielle',
    'Extension',
  ];

  @override
  void initState() {
    super.initState();
    final data = ref.read(projectCreationProvider).value;
    _titleController = TextEditingController(text: data?.titre);
    _descController = TextEditingController(text: data?.description);
    if (data != null && data.typeConstruction.isNotEmpty) {
      _selectedType = data.typeConstruction;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _saveData() {
    ref.read(projectCreationProvider.notifier).updateField(
      titre: _titleController.text,
      description: _descController.text,
      typeConstruction: _selectedType,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Form(
        key: widget.formKey,
        onChanged: _saveData,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Parlez-nous de votre projet',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            AppSpacing.vSm,
            Text(
              'Donnez un nom et une description claire pour attirer les meilleures entreprises.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
            ),
            AppSpacing.vXxl,
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Titre du projet',
                hintText: 'Ex: Construction Villa R+1',
                prefixIcon: Icon(Icons.title),
              ),
              validator: (value) => value == null || value.isEmpty ? 'Le titre est requis' : null,
            ),
            AppSpacing.vLg,
            DropdownButtonFormField<String>(
              value: _selectedType,
              decoration: const InputDecoration(
                labelText: 'Type de travaux',
                prefixIcon: Icon(Icons.category),
              ),
              items: _types.map((type) {
                return DropdownMenuItem(value: type, child: Text(type));
              }).toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() => _selectedType = val);
                  _saveData();
                }
              },
            ),
            AppSpacing.vLg,
            TextFormField(
              controller: _descController,
              decoration: const InputDecoration(
                labelText: 'Description détaillée',
                hintText: 'Décrivez vos attentes, la superficie, le style voulu...',
                alignLabelWithHint: true,
              ),
              maxLines: 5,
              validator: (value) => value == null || value.isEmpty ? 'La description est requise' : null,
            ),
          ],
        ),
      ),
    );
  }
}
