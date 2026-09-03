import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../data/models/avis_model.dart';
import '../widgets/animated_star_rating.dart';

class CreateReviewScreen extends ConsumerStatefulWidget {
  final String projectId;
  final String targetId;
  final String targetType; // 'entreprise' ou 'chef_chantier'
  final String targetName; // Nom pour affichage (ex: 'BatiPlus')

  const CreateReviewScreen({
    super.key,
    required this.projectId,
    required this.targetId,
    required this.targetType,
    required this.targetName,
  });

  @override
  ConsumerState<CreateReviewScreen> createState() => _CreateReviewScreenState();
}

class _CreateReviewScreenState extends ConsumerState<CreateReviewScreen> {
  final Map<String, int> _criteres = {
    'qualite': 0,
    'delais': 0,
    'communication': 0,
    'prix': 0,
  };
  
  final TextEditingController _commentController = TextEditingController();
  bool _isSubmitting = false;

  bool get _isFormValid {
    // Tous les critères doivent avoir au moins 1 étoile
    return !_criteres.values.any((note) => note == 0);
  }

  double get _averageNote {
    if (_criteres.values.isEmpty) return 0;
    int sum = _criteres.values.reduce((a, b) => a + b);
    return sum / _criteres.length;
  }

  Future<void> _submitReview() async {
    if (!_isFormValid) return;

    setState(() => _isSubmitting = true);

    final review = AvisModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(), // Généré par Firestore en prod
      targetId: widget.targetId,
      targetType: widget.targetType,
      clientId: 'current_user_id', // Remplacer par authProvider
      projectId: widget.projectId,
      note: _averageNote,
      criteres: Map.from(_criteres),
      commentaire: _commentController.text,
      dateCreation: DateTime.now(),
    );

    // Simuler l'envoi réseau
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Merci pour votre avis sur ${widget.targetName} !'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop(true);
    }
  }

  Widget _buildCriterionRow(String label, String key) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          AnimatedStarRating(
            initialRating: _criteres[key] ?? 0,
            starSize: 28,
            onRatingChanged: (val) {
              setState(() {
                _criteres[key] = val;
              });
            },
          ),
        ],
      ).animate().fadeIn().slideX(begin: -0.1),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final title = widget.targetType == 'entreprise' ? 'Évaluer l\'entreprise' : 'Évaluer le chef de chantier';

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Comment s\'est passé votre projet avec ${widget.targetName} ?',
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ).animate().fadeIn().scale(),
            
            AppSpacing.vXxl,
            
            // Note globale affichée dynamiquement
            if (_isFormValid)
              Column(
                children: [
                  Text(
                    'Note moyenne : ${_averageNote.toStringAsFixed(1)}/5',
                    style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  AppSpacing.vLg,
                ],
              ).animate().fadeIn().slideY(begin: -0.2),

            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              ),
              child: Column(
                children: [
                  _buildCriterionRow('Qualité du travail', 'qualite'),
                  _buildCriterionRow('Respect des délais', 'delais'),
                  _buildCriterionRow('Communication', 'communication'),
                  _buildCriterionRow('Rapport qualité/prix', 'prix'),
                ],
              ),
            ),
            
            AppSpacing.vXxl,
            
            Text(
              'Un petit commentaire ? (Optionnel)',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            AppSpacing.vSm,
            TextField(
              controller: _commentController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Partagez votre expérience avec les futurs clients...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                filled: true,
                fillColor: theme.colorScheme.surface,
              ),
            ).animate().fadeIn(delay: 200.ms),
            
            AppSpacing.vXxl,
            AppSpacing.vXxl,
            
            AppButton(
              onPressed: _isFormValid && !_isSubmitting ? _submitReview : null,
              text: 'Publier mon avis',
              isLoading: _isSubmitting,
            ).animate().scale(delay: 300.ms),
          ],
        ),
      ),
    );
  }
}
