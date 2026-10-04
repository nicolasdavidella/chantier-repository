import 'package:flutter/material.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:chantier_track/data/models/project_model.dart';
import 'package:chantier_track/core/theme/app_colors.dart';
import 'package:chantier_track/core/theme/app_spacing.dart';

class DevisIASimulator extends StatefulWidget {
  final ProjectModel project;

  const DevisIASimulator({super.key, required this.project});

  static void show(BuildContext context, ProjectModel project) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: DevisIASimulator(project: project),
      ),
    );
  }

  @override
  State<DevisIASimulator> createState() => _DevisIASimulatorState();
}

class _DevisIASimulatorState extends State<DevisIASimulator> {
  bool _isLoading = false;
  Map<String, dynamic>? _devisResult;
  String? _error;

  Future<void> _simuler() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _devisResult = null;
    });

    try {
      final callable = FirebaseFunctions.instance.httpsCallable('simulerDevisIA');
      final result = await callable.call({
        'typeConstruction': 'Maison/Villa',
        'ville': widget.project.localisation['ville'] ?? 'Inconnue',
        'superficie': 150,
        'nombrePieces': 5,
        'budgetDeclare': widget.project.budgetPrevisionnel,
      });

      setState(() {
        _devisResult = Map<String, dynamic>.from(result.data);
        _isLoading = false;
      });
    } catch (e) {
      // Fallback au cas où l'émulateur n'est pas lancé
      await Future.delayed(const Duration(seconds: 2));
      setState(() {
        _devisResult = {
          "fourchetteTotal": {
            "minimum": widget.project.budgetPrevisionnel * 0.9,
            "moyenne": widget.project.budgetPrevisionnel,
            "maximum": widget.project.budgetPrevisionnel * 1.2
          },
          "repartitionParPoste": [
            { "nom": "Gros œuvre", "pourcentage": 40, "montantEstime": widget.project.budgetPrevisionnel * 0.4 },
            { "nom": "Toiture", "pourcentage": 15, "montantEstime": widget.project.budgetPrevisionnel * 0.15 },
            { "nom": "Finitions (Peinture, Carrelage)", "pourcentage": 25, "montantEstime": widget.project.budgetPrevisionnel * 0.25 },
            { "nom": "Plomberie & Électricité", "pourcentage": 20, "montantEstime": widget.project.budgetPrevisionnel * 0.2 }
          ],
          "delaiEstimeSemaines": 24,
          "hypotheses": [
            "Terrain plat sans besoin de fondations spéciales",
            "Matériaux standards locaux",
            "Accessibilité facile du chantier"
          ],
          "avertissement": "Ceci est une simulation de démonstration (fallback local). La connexion à la Cloud Function a échoué."
        };
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Row(
            children: [
              const Icon(Icons.calculate_rounded, color: AppColors.primary, size: 28),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Simulateur de Devis & Coûts',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    Text(
                      'Calcul automatique détaillé ChantierTrack',
                      style: theme.textTheme.bodySmall?.copyWith(color: AppColors.primary),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              )
            ],
          ),
        ),
        Expanded(
          child: _devisResult == null
              ? _buildEmptyState(theme)
              : _buildResultState(theme),
        ),
      ],
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.calculate_rounded, size: 64, color: AppColors.textSecondaryLight),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Obtenez une estimation détaillée',
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.md),
            const Text(
              'Notre système d\'estimation analyse les caractéristiques de votre projet pour vous donner une fourchette de prix réaliste, poste par poste.',
              textAlign: TextAlign.center,
              style: TextStyle(height: 1.5),
            ),
            const SizedBox(height: AppSpacing.xl * 2),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _simuler,
                icon: _isLoading 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.calculate_rounded),
                label: Text(_isLoading ? 'Calcul en cours...' : 'Lancer la simulation'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultState(ThemeData theme) {
    final fourchette = _devisResult!['fourchetteTotal'];
    final repartition = _devisResult!['repartitionParPoste'] as List<dynamic>;
    final hypotheses = _devisResult!['hypotheses'] as List<dynamic>;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.xl),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primary, Color(0xFF0A4F3E)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Column(
            children: [
              const Text(
                'Budget Total Estimé',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                '${(fourchette['moyenne'] as num).toStringAsFixed(0)} FCFA',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildMiniStat('Min', '${(fourchette['minimum'] as num).toStringAsFixed(0)}'),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
                    child: Text('-', style: TextStyle(color: Colors.white54)),
                  ),
                  _buildMiniStat('Max', '${(fourchette['maximum'] as num).toStringAsFixed(0)}'),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.timer, color: Colors.white70, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    'Délai estimé: ${_devisResult!['delaiEstimeSemaines']} semaines',
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              )
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        Text(
          'Répartition par poste',
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: AppSpacing.md),
        ...repartition.map((poste) => Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      poste['nom'].toString(),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text('${poste['pourcentage']}%', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: (poste['pourcentage'] as num) / 100,
                        backgroundColor: AppColors.grey200,
                        color: AppColors.primary,
                        minHeight: 8,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Text('${(poste['montantEstime'] as num).toStringAsFixed(0)} FCFA', style: theme.textTheme.bodySmall),
                ],
              ),
            ],
          ),
        )),
        const SizedBox(height: AppSpacing.xl),
        Text(
          'Hypothèses de calcul',
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: AppSpacing.sm),
        ...hypotheses.map((h) => Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('• ', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
              Expanded(child: Text(h.toString(), style: theme.textTheme.bodyMedium)),
            ],
          ),
        )),
        const SizedBox(height: AppSpacing.xl),
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.warning.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.warning.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline, color: AppColors.warning),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  _devisResult!['avertissement'],
                  style: theme.textTheme.bodySmall?.copyWith(color: AppColors.warning),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
      ],
    );
  }

  Widget _buildMiniStat(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12)),
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ],
    );
  }
}
