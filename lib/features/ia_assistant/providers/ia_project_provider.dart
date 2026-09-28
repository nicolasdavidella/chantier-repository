import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../data/models/project_model.dart';

final iaProjectProvider = StateNotifierProvider<IaProjectNotifier, IaProjectState>((ref) {
  return IaProjectNotifier();
});

class IaProjectState {
  final List<IaMessage> messages;
  final bool isTyping;
  final bool hasSubmittedForm;
  final String? projectId;
  final List<dynamic>? generatedPlans;

  IaProjectState({
    required this.messages,
    this.isTyping = false,
    this.hasSubmittedForm = false,
    this.projectId,
    this.generatedPlans,
  });

  IaProjectState copyWith({
    List<IaMessage>? messages,
    bool? isTyping,
    bool? hasSubmittedForm,
    String? projectId,
    List<dynamic>? generatedPlans,
  }) {
    return IaProjectState(
      messages: messages ?? this.messages,
      isTyping: isTyping ?? this.isTyping,
      hasSubmittedForm: hasSubmittedForm ?? this.hasSubmittedForm,
      projectId: projectId ?? this.projectId,
      generatedPlans: generatedPlans ?? this.generatedPlans,
    );
  }
}

class IaMessage {
  final String id;
  final String text;
  final bool isUser;
  final bool isForm;
  final bool isPlans;

  IaMessage({
    required this.id,
    required this.text,
    required this.isUser,
    this.isForm = false,
    this.isPlans = false,
  });
}

class IaProjectNotifier extends StateNotifier<IaProjectState> {
  IaProjectNotifier() : super(IaProjectState(messages: [])) {
    _initChat();
  }

  void _initChat() {
    state = state.copyWith(
      messages: [
        IaMessage(
          id: '1',
          text: 'Bonjour ! Je suis votre assistant virtuel ChantierTrack. Parlez-moi de votre projet de construction, et je vous proposerai des plans adaptés à votre budget et vos besoins.',
          isUser: false,
        ),
        IaMessage(
          id: '2',
          text: '',
          isUser: false,
          isForm: true,
        ),
      ]
    );
  }

  Future<void> submitProjectForm(Map<String, dynamic> formData) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    state = state.copyWith(
      hasSubmittedForm: true,
      messages: [
        ...state.messages,
        IaMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          text: 'J\'ai un projet pour une construction de type ${formData['typeConstruction']} à ${formData['ville']} avec un budget de ${formData['budgetPrevisionnel']} FCFA.',
          isUser: true,
        ),
      ],
      isTyping: true,
    );

    try {
      // 1. Create draft project in Firestore
      final projectRef = FirebaseFirestore.instance.collection('projects').doc();
      final project = ProjectModel(
        id: projectRef.id,
        clientId: user.uid,
        titre: formData['titre'] ?? 'Nouveau projet',
        description: formData['description'] ?? '',
        localisation: {
          'ville': formData['ville'],
          'quartier': formData['quartier'],
          'lat': formData['lat'],
          'lng': formData['lng'],
        },
        budgetPrevisionnel: double.tryParse(formData['budgetPrevisionnel'].toString()) ?? 0,
        budgetActuel: 0,
        dateDebut: DateTime.now(),
        dateFinPrevue: DateTime.now().add(const Duration(days: 180)),
        statut: 'brouillon_ia',
        listePlans: [],
        listeDocuments: [],
      );
      
      await projectRef.set(project.toJson());

      // 2. Call Cloud Function
      final httpsCallable = FirebaseFunctions.instance.httpsCallable('genererPropositionsPlans');
      final result = await httpsCallable.call({
        'projet': {
          'typeConstruction': formData['typeConstruction'],
          'ville': formData['ville'],
          'quartier': formData['quartier'],
          'budgetPrevisionnel': project.budgetPrevisionnel,
          'surfaceTerrain': formData['surfaceTerrain'],
          'nombreChambres': formData['nombreChambres'],
          'nombreSallesDeBain': formData['nombreSallesDeBain'],
          'description': project.description,
        }
      });

      if (result.data != null && result.data['success'] == true) {
        final donnees = result.data['donnees'];
        state = state.copyWith(
          isTyping: false,
          projectId: projectRef.id,
          generatedPlans: donnees['variantes'],
          messages: [
            ...state.messages,
            IaMessage(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              text: 'Voici 3 esquisses indicatives (qui ne remplacent pas un plan d\'architecte) générées selon vos critères. Vous pouvez balayer (swipe) pour les voir.',
              isUser: false,
              isPlans: true,
            ),
          ]
        );
      } else {
        throw Exception("Réponse IA invalide");
      }
    } catch (e) {
      state = state.copyWith(
        isTyping: false,
        messages: [
          ...state.messages,
          IaMessage(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            text: 'Une erreur est survenue lors de la génération. Voulez-vous réessayer ?',
            isUser: false,
          ),
        ]
      );
    }
  }

  Future<void> validerPlan(dynamic planJson) async {
    final projectId = state.projectId;
    if (projectId == null) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final db = FirebaseFirestore.instance;
      await db.collection('projects').doc(projectId).update({
        'statut': 'en_recherche_entreprise', // Changé de plan_valide à en_recherche_entreprise pour démarrer la diffusion
        'planChoisi': jsonEncode(planJson),
      });
      
      // Diffusion directe aux entreprises
      try {
        final entreprisesSnap = await db.collection('entreprises').get();
        final batch = db.batch();

        for (final entDoc in entreprisesSnap.docs) {
          final entData = entDoc.data();
          final entrepriseUserId = entData['userId'] as String?;
          if (entrepriseUserId == null || entrepriseUserId.isEmpty) continue;

          final diffusionId = '${projectId}_$entrepriseUserId';
          batch.set(
            db.collection('diffusions_projet').doc(diffusionId),
            {
              'projectId': projectId,
              'clientId': user.uid,
              'entrepriseId': entrepriseUserId,
              'statut': 'envoye',
              'dateEnvoi': FieldValue.serverTimestamp(),
            },
            SetOptions(merge: true),
          );
        }
        await batch.commit();
        debugPrint('✅ Plan validé et diffusé à ${entreprisesSnap.docs.length} entreprise(s)');
      } catch (e) {
        debugPrint('⚠️ Erreur diffusion IA: $e');
      }

    } catch (e) {
      debugPrint("Erreur validation plan: $e");
    }
  }

  Future<void> affinerPlan(String query) async {
    final projectId = state.projectId;
    if (projectId == null) return;

    state = state.copyWith(
      messages: [
        ...state.messages,
        IaMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          text: query,
          isUser: true,
        ),
      ],
      isTyping: true,
    );

    try {
      final httpsCallable = FirebaseFunctions.instance.httpsCallable('affinerPlan');
      final result = await httpsCallable.call({
        'projectId': projectId,
        'query': query,
      });

      if (result.data != null && result.data['success'] == true) {
        state = state.copyWith(
          isTyping: false,
          messages: [
            ...state.messages,
            IaMessage(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              text: result.data['message'] ?? 'Le plan a été mis à jour selon vos retours.',
              isUser: false,
            ),
          ]
        );
      } else {
        throw Exception("Erreur lors de l'affinage");
      }
    } catch (e) {
      state = state.copyWith(
        isTyping: false,
        messages: [
          ...state.messages,
          IaMessage(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            text: 'Désolé, je n\'ai pas pu modifier le plan. Veuillez réessayer.',
            isUser: false,
          ),
        ]
      );
    }
  }
}
