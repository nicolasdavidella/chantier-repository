import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/services/anthropic_service.dart';
import '../../../../features/ia_assistant/providers/ia_providers.dart'; // Pour ChatMessage
import '../../../../data/models/project_model.dart';
import '../../../auth/providers/auth_provider.dart';

class AiProjectCreationState {
  final List<ChatMessage> messages;
  final bool isLoading;
  final Map<String, dynamic>? proposedPlansJson;

  AiProjectCreationState({
    this.messages = const [],
    this.isLoading = false,
    this.proposedPlansJson,
  });

  AiProjectCreationState copyWith({
    List<ChatMessage>? messages,
    bool? isLoading,
    Map<String, dynamic>? proposedPlansJson,
  }) {
    return AiProjectCreationState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      proposedPlansJson: proposedPlansJson ?? this.proposedPlansJson,
    );
  }
}

class AiProjectCreationController extends StateNotifier<AiProjectCreationState> {
  final AnthropicService _anthropicService;
  final Ref ref;

  AiProjectCreationController(this.ref) : _anthropicService = AnthropicService(), super(AiProjectCreationState()) {
    _initChat();
  }

  void _initChat() {
    state = state.copyWith(messages: [
      ChatMessage(
        text: "Bonjour ! Je suis l'architecte IA de ChantierTrack. Parlez-moi de votre projet de construction (style, nombre de pièces...) et n'oubliez pas de m'indiquer votre budget !",
        isUser: false,
        timestamp: DateTime.now(),
      )
    ]);
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final userMsg = ChatMessage(text: text, isUser: true, timestamp: DateTime.now());
    state = state.copyWith(
      messages: [...state.messages, userMsg],
      isLoading: true,
    );

    try {
      final responseText = await _anthropicService.chatForProjectCreation(text, state.messages);
      
      // Essayer de voir si c'est le JSON final
      try {
        final parsed = jsonDecode(responseText);
        if (parsed != null && parsed['isFinal'] == true) {
           state = state.copyWith(
             proposedPlansJson: parsed,
             isLoading: false,
           );
           return;
        }
      } catch (e) {
        // Ce n'est pas un JSON, c'est un texte normal
      }

      final aiMsg = ChatMessage(text: responseText, isUser: false, timestamp: DateTime.now());
      state = state.copyWith(
        messages: [...state.messages, aiMsg],
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        messages: [...state.messages, ChatMessage(text: "Désolé, une erreur est survenue.", isUser: false, timestamp: DateTime.now())],
        isLoading: false,
      );
    }
  }

  Future<void> createProjectWithPlan(String planNom) async {
    if (state.proposedPlansJson == null) return;
    
    try {
      final authUser = ref.read(authStateProvider).value;
      if (authUser == null) throw Exception("Non authentifié");

      final projectId = FirebaseFirestore.instance.collection('projects').doc().id;
      final budget = (state.proposedPlansJson!['budget'] as num).toDouble();
      final description = state.proposedPlansJson!['descriptionComplete'] ?? 'Projet généré par IA';

      final newProject = ProjectModel(
        id: projectId,
        clientId: authUser.uid,
        titre: 'Projet: $planNom',
        description: description,
        localisation: {'ville': 'À définir', 'quartier': 'À définir'}, // TODO: Demander à l'IA ou plus tard
        budgetPrevisionnel: budget,
        budgetActuel: 0,
        dateDebut: DateTime.now(),
        dateFinPrevue: DateTime.now().add(const Duration(days: 90)),
        statut: 'en_recherche_entreprise',
        listePlans: [],
        listeDocuments: [],
        planChoisi: planNom,
      );

      await FirebaseFirestore.instance.collection('projects').doc(newProject.id).set(newProject.toJson());
      
    } catch (e) {
      print("Erreur création projet IA: $e");
      rethrow;
    }
  }
}

final aiProjectCreationProvider = StateNotifierProvider.autoDispose<AiProjectCreationController, AiProjectCreationState>((ref) {
  return AiProjectCreationController(ref);
});
