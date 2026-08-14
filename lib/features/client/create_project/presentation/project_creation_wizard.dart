import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../providers/create_project_provider.dart';
import 'steps/step_general.dart';
import 'steps/step_location.dart';
import 'steps/step_budget_dates.dart';
import 'steps/step_documents.dart';
import 'steps/step_summary.dart';

class ProjectCreationWizardScreen extends ConsumerStatefulWidget {
  const ProjectCreationWizardScreen({super.key});

  @override
  ConsumerState<ProjectCreationWizardScreen> createState() => _ProjectCreationWizardScreenState();
}

class _ProjectCreationWizardScreenState extends ConsumerState<ProjectCreationWizardScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  final int _totalSteps = 5;
  
  final _step1Key = GlobalKey<FormState>();
  final _step2Key = GlobalKey<FormState>();
  final _step3Key = GlobalKey<FormState>();

  void _nextStep() async {
    bool isValid = true;
    
    // Validate current step
    if (_currentStep == 0) {
      isValid = _step1Key.currentState?.validate() ?? false;
    } else if (_currentStep == 1) {
      isValid = _step2Key.currentState?.validate() ?? false;
    } else if (_currentStep == 2) {
      isValid = _step3Key.currentState?.validate() ?? false;
      final data = ref.read(projectCreationProvider).value;
      if (isValid && (data?.dateDebut == null || data?.dateFin == null)) {
        isValid = false;
      }
    }

    if (!isValid) return;

    if (_currentStep < _totalSteps - 1) {
      setState(() => _currentStep++);
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Final Submit
      try {
        await ref.read(projectCreationProvider.notifier).submitProject();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Projet publié avec succès !')),
          );
          context.pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur: $e')),
          );
        }
      }
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSubmitting = ref.watch(projectCreationProvider).isLoading;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _previousStep,
        ),
        title: const Text('Nouveau projet'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4.0),
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: (_currentStep + 1) / _totalSteps),
            duration: const Duration(milliseconds: 300),
            builder: (context, value, _) {
              return LinearProgressIndicator(
                value: value,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
              );
            },
          ),
        ),
      ),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(), // Disable swipe
        children: [
          StepGeneral(formKey: _step1Key).animate().fadeIn().slideX(),
          StepLocation(formKey: _step2Key).animate().fadeIn().slideX(),
          StepBudgetDates(formKey: _step3Key).animate().fadeIn().slideX(),
          const StepDocuments().animate().fadeIn().slideX(),
          const StepSummary().animate().fadeIn().slideX(),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: AppButton(
            onPressed: isSubmitting ? () {} : _nextStep,
            text: _currentStep == _totalSteps - 1 ? 'Publier le projet' : 'Continuer',
            isLoading: isSubmitting,
            icon: _currentStep == _totalSteps - 1 ? Icons.check : Icons.arrow_forward,
          ),
        ),
      ),
    );
  }
}
