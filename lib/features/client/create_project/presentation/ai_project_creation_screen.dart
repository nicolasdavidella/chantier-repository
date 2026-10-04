import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../features/ia_assistant/providers/ia_providers.dart';
import '../providers/ai_project_creation_provider.dart';
import 'package:chantier_track/core/theme/app_colors.dart';


class AiProjectCreationScreen extends ConsumerStatefulWidget {
  const AiProjectCreationScreen({super.key});

  @override
  ConsumerState<AiProjectCreationScreen> createState() => _AiProjectCreationScreenState();
}

class _AiProjectCreationScreenState extends ConsumerState<AiProjectCreationScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(aiProjectCreationProvider);
    final notifier = ref.read(aiProjectCreationProvider.notifier);
    final theme = Theme.of(context);

    // S'il y a un JSON de proposition final, on affiche les plans
    if (state.proposedPlansJson != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Plans Proposés')),
        body: _buildPlansSelection(state.proposedPlansJson!, notifier, theme),
      );
    }

    // Sinon interface de chat
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assistant Projet', style: TextStyle(fontSize: 18)),
        actions: [
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.robot),
            onPressed: () {},
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: state.messages.length,
              itemBuilder: (context, index) {
                final msg = state.messages[index];
                return _buildMessage(msg, theme);
              },
            ),
          ),
          if (state.isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
          _buildInputArea(theme, notifier),
        ],
      ),
    );
  }

  Widget _buildMessage(ChatMessage message, ThemeData theme) {
    final isUser = message.isUser;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isUser ? theme.colorScheme.primary : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20).copyWith(
            bottomRight: isUser ? const Radius.circular(0) : const Radius.circular(20),
            bottomLeft: !isUser ? const Radius.circular(0) : const Radius.circular(20),
          ),
        ),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        child: Text(
          message.text,
          style: TextStyle(
            color: isUser ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface,
          ),
        ),
      ).animate().fadeIn().slideY(begin: 0.1, end: 0),
    );
  }

  Widget _buildInputArea(ThemeData theme, AiProjectCreationController notifier) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md).copyWith(bottom: MediaQuery.of(context).padding.bottom + AppSpacing.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimaryLight.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Écrivez votre message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHighest,
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              onSubmitted: (_) {
                if (_controller.text.isNotEmpty) {
                  notifier.sendMessage(_controller.text);
                  _controller.clear();
                  _scrollToBottom();
                }
              },
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          CircleAvatar(
            backgroundColor: theme.colorScheme.primary,
            child: IconButton(
              icon: Icon(Icons.send, color: theme.colorScheme.onPrimary),
              onPressed: () {
                if (_controller.text.isNotEmpty) {
                  notifier.sendMessage(_controller.text);
                  _controller.clear();
                  _scrollToBottom();
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlansSelection(Map<String, dynamic> data, AiProjectCreationController notifier, ThemeData theme) {
    final plans = data['plans'] as List;
    final budget = data['budget'];
    
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        Text(
          "L'IA a terminé l'analyse de votre besoin.",
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ).animate().fadeIn(),
        const SizedBox(height: AppSpacing.md),
        Text("Budget estimé/renseigné : $budget FCFA"),
        const SizedBox(height: AppSpacing.lg),
        Text("Voici les plans recommandés pour vous :", style: theme.textTheme.titleMedium),
        const SizedBox(height: AppSpacing.md),
        ...plans.map((plan) {
          return Card(
            margin: const EdgeInsets.only(bottom: AppSpacing.md),
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: InkWell(
              onTap: () async {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (ctx) => const Center(child: CircularProgressIndicator()),
                );
                try {
                  await notifier.createProjectWithPlan(plan['nom']);
                  if (mounted) {
                    Navigator.pop(context); // pop loading
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Projet publié avec succès !')));
                    context.go('/client'); // Retour au dashboard
                  }
                } catch (e) {
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e')));
                  }
                }
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    height: 150,
                    color: theme.colorScheme.surfaceContainerHighest,
                    child: const Icon(Icons.home_work, size: 50, color: AppColors.textSecondaryLight), // Placeholder pour l'image
                  ),
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(plan['nom'], style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(plan['description'], style: theme.textTheme.bodyMedium),
                        const SizedBox(height: AppSpacing.sm),
                        AppButton(
                          onPressed: () async {
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (ctx) => const Center(child: CircularProgressIndicator()),
                            );
                            try {
                              await notifier.createProjectWithPlan(plan['nom']);
                              if (mounted) {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Projet publié avec succès !')));
                                context.go('/client');
                              }
                            } catch (e) {
                              if (mounted) {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e')));
                              }
                            }
                          },
                          text: "Choisir ce plan",
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ).animate().slideY(),
          );
        }),
      ],
    );
  }
}
