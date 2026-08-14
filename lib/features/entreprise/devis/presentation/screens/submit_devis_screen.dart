import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../../data/models/devis_model.dart';
import '../../../../../data/models/project_model.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/widgets/app_button.dart';
import '../../providers/devis_provider.dart';

class SubmitDevisScreen extends ConsumerStatefulWidget {
  final ProjectModel project;

  const SubmitDevisScreen({super.key, required this.project});

  @override
  ConsumerState<SubmitDevisScreen> createState() => _SubmitDevisScreenState();
}

class _SubmitDevisScreenState extends ConsumerState<SubmitDevisScreen> {
  final _formKey = GlobalKey<FormState>();
  final _montantController = TextEditingController();
  final _delaiController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  bool _isSubmitting = false;
  bool _pdfAttached = false;

  @override
  void dispose() {
    _montantController.dispose();
    _delaiController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _attachPdf() {
    // Simulate file picker
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sélection du fichier PDF...')));
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _pdfAttached = true;
      });
    });
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSubmitting = true);

      final newDevis = DevisModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        projectId: widget.project.id,
        entrepriseId: 'me', // Simulated current enterprise
        montant: double.tryParse(_montantController.text) ?? 0,
        delaiEstime: _delaiController.text,
        description: _descriptionController.text,
        dateEnvoi: DateTime.now(),
        statut: 'en_attente',
        fichierPdfUrl: _pdfAttached ? 'simulated_url.pdf' : null,
      );

      // Simulate network delay
      Future.delayed(const Duration(seconds: 2), () {
        ref.read(devisProvider.notifier).submitDevis(newDevis);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Devis envoyé avec succès !')));
          context.pop();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Postuler avec un devis')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            // Project summary
            Card(
              elevation: 0,
              color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Demande', style: theme.textTheme.bodySmall),
                    AppSpacing.vXs,
                    Text(widget.project.titre, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
              ),
            ).animate().fadeIn(duration: 400.ms),
            
            AppSpacing.vXxl,

            TextFormField(
              controller: _montantController,
              decoration: const InputDecoration(
                labelText: 'Montant proposé (FCFA)',
                prefixIcon: Icon(Icons.attach_money),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (v) => v == null || v.isEmpty ? 'Champ requis' : null,
            ).animate().slideX(begin: 0.1).fadeIn(delay: 100.ms),

            AppSpacing.vLg,

            TextFormField(
              controller: _delaiController,
              decoration: const InputDecoration(
                labelText: 'Délai d\'exécution estimé',
                hintText: 'Ex: 3 mois',
                prefixIcon: Icon(Icons.timer_outlined),
                border: OutlineInputBorder(),
              ),
              validator: (v) => v == null || v.isEmpty ? 'Champ requis' : null,
            ).animate().slideX(begin: 0.1).fadeIn(delay: 200.ms),
            
            AppSpacing.vLg,

            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description détaillée',
                alignLabelWithHint: true,
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
              validator: (v) => v == null || v.isEmpty ? 'Veuillez décrire votre approche' : null,
            ).animate().slideX(begin: 0.1).fadeIn(delay: 300.ms),

            AppSpacing.vXxl,
            
            OutlinedButton.icon(
              onPressed: _attachPdf,
              icon: Icon(_pdfAttached ? Icons.check_circle : Icons.upload_file, color: _pdfAttached ? Colors.green : null),
              label: Text(_pdfAttached ? 'Devis_officiel.pdf joint' : 'Joindre un fichier PDF (Optionnel)'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.all(AppSpacing.md),
                side: BorderSide(color: _pdfAttached ? Colors.green : theme.colorScheme.outline),
              ),
            ).animate().slideX(begin: 0.1).fadeIn(delay: 400.ms),

            AppSpacing.vXxl,
            
            _isSubmitting
                ? const Center(child: CircularProgressIndicator())
                : AppButton(
                    onPressed: _submit,
                    text: 'Envoyer le devis',
                  ).animate().scale(delay: 500.ms),
          ],
        ),
      ),
    );
  }
}
