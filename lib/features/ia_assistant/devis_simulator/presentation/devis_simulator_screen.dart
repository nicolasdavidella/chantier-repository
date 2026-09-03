import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_spacing.dart';
import 'package:chantier_track/features/ia_assistant/providers/ia_providers.dart';

class DevisSimulatorScreen extends ConsumerStatefulWidget {
  const DevisSimulatorScreen({super.key});

  @override
  ConsumerState<DevisSimulatorScreen> createState() => _DevisSimulatorScreenState();
}

class _DevisSimulatorScreenState extends ConsumerState<DevisSimulatorScreen> {
  int _currentStep = 0;
  final _typeTravauxController = TextEditingController();
  final _surfaceController = TextEditingController();
  String _selectedGamme = 'Standard';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const FaIcon(FontAwesomeIcons.arrowLeft, size: 20),
          onPressed: () => context.pop(),
        ),
        title: const Text('Simulateur IA'),
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Obtenez une estimation en quelques secondes.',
                style: theme.textTheme.headlineMedium,
              ).animate().fadeIn().slideX(begin: -0.2),
              
              AppSpacing.vXl,
              
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _buildCurrentStep(theme),
                ),
              ),
              
              AppSpacing.vLg,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_currentStep > 0)
                    TextButton(
                      onPressed: () => setState(() => _currentStep--),
                      child: const Text('Retour'),
                    )
                  else
                    const SizedBox.shrink(),
                  
                  ElevatedButton(
                    onPressed: () {
                      if (_currentStep < 2) {
                        setState(() => _currentStep++);
                      } else {
                        // Lancer la simulation IA
                        _simulateDevis(context);
                      }
                    },
                    child: Text(_currentStep < 2 ? 'Suivant' : 'Simuler'),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentStep(ThemeData theme) {
    switch (_currentStep) {
      case 0:
        return _buildStep1(theme);
      case 1:
        return _buildStep2(theme);
      case 2:
        return _buildStep3(theme);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildStep1(ThemeData theme) {
    return Column(
      key: const ValueKey(1),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Quel est le type de travaux ?', style: theme.textTheme.titleLarge),
        AppSpacing.vLg,
        TextField(
          controller: _typeTravauxController,
          decoration: const InputDecoration(
            hintText: 'Ex: Rénovation complète salle de bain, Construction piscine...',
            prefixIcon: Padding(
              padding: EdgeInsets.all(16.0),
              child: FaIcon(FontAwesomeIcons.hammer, size: 20),
            ),
          ),
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildStep2(ThemeData theme) {
    return Column(
      key: const ValueKey(2),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Quelle est la surface concernée ?', style: theme.textTheme.titleLarge),
        AppSpacing.vLg,
        TextField(
          controller: _surfaceController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            hintText: 'Surface en m²',
            suffixText: 'm²',
            prefixIcon: Padding(
              padding: EdgeInsets.all(16.0),
              child: FaIcon(FontAwesomeIcons.rulerCombined, size: 20),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStep3(ThemeData theme) {
    return Column(
      key: const ValueKey(3),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Gamme de matériaux souhaitée ?', style: theme.textTheme.titleLarge),
        AppSpacing.vLg,
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: ['Économique', 'Standard', 'Premium', 'Luxe'].map((gamme) {
            final isSelected = _selectedGamme == gamme;
            return ChoiceChip(
              label: Text(gamme),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) setState(() => _selectedGamme = gamme);
              },
              backgroundColor: theme.colorScheme.surface,
              selectedColor: theme.colorScheme.primary,
              labelStyle: TextStyle(
                color: isSelected ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
            );
          }).toList(),
        ),
      ],
    );
  }

  void _simulateDevis(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildResultSheet(context, Theme.of(context)),
    );
  }

  Widget _buildResultSheet(BuildContext context, ThemeData theme) {
    final geminiService = ref.read(geminiServiceProvider);
    
    return FutureBuilder<String>(
      future: geminiService.simulateDevis(_typeTravauxController.text, _surfaceController.text, _selectedGamme),
      builder: (context, snapshot) {
        return Container(
          padding: const EdgeInsets.all(AppSpacing.xl),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.outline.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              AppSpacing.vXl,
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const FaIcon(FontAwesomeIcons.wandMagicSparkles, color: Colors.orange),
                  const SizedBox(width: 12),
                  Text('Estimation IA', style: theme.textTheme.titleLarge),
                ],
              ),
              AppSpacing.vLg,
              if (snapshot.connectionState == ConnectionState.waiting)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (snapshot.hasError)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Text('Erreur : ${snapshot.error}', style: const TextStyle(color: Colors.red), textAlign: TextAlign.center),
                )
              else
                _buildResultData(snapshot.data!, theme, context),
            ],
          ),
        ).animate().slideY(begin: 1, curve: Curves.easeOutCubic);
      },
    );
  }

  Widget _buildResultData(String jsonStr, ThemeData theme, BuildContext context) {
    String budgetStr = "Erreur";
    String dureeStr = "Non estimée";
    try {
      final data = jsonDecode(jsonStr);
      budgetStr = "${data['budgetMin']} - ${data['budgetMax']} FCFA";
      dureeStr = "Durée estimée : ${data['dureeTexte']}";
    } catch (e) {
      budgetStr = "Erreur d'analyse IA";
    }

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.xl),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            children: [
              Text('Budget estimé', style: theme.textTheme.labelLarge ?? const TextStyle()),
              AppSpacing.vSm,
              Text(
                budgetStr,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
                textAlign: TextAlign.center,
              ),
              const Divider(height: 32),
              Text(dureeStr, style: theme.textTheme.bodyMedium),
            ],
          ),
        ),
        AppSpacing.vXl,
        ElevatedButton(
          onPressed: () {
            context.pop();
          },
          child: const Text('Demander des devis réels'),
        ),
        AppSpacing.vLg,
      ],
    );
  }
}
