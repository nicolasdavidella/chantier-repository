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
      final budgetDeclare = double.tryParse(formData['budgetPrevisionnel'].toString()) ?? 0;
      final project = ProjectModel(
        id: projectRef.id,
        clientId: user.uid,
        titre: formData['titre'] ?? 'Projet ${formData['typeConstruction']}',
        description: formData['description'] ?? '',
        localisation: {
          'ville': formData['ville'],
          'quartier': formData['quartier'],
          'lat': formData['lat'],
          'lng': formData['lng'],
        },
        budgetPrevisionnel: budgetDeclare,
        budgetActuel: 0,
        dateDebut: DateTime.now(),
        dateFinPrevue: DateTime.now().add(const Duration(days: 180)),
        statut: 'brouillon_ia',
        listePlans: [],
        listeDocuments: [],
      );
      
      await projectRef.set(project.toJson());

      // 2. Simulate Quote
      Map<String, dynamic> devisResult;
      try {
        final callable = FirebaseFunctions.instance.httpsCallable('simulerDevisIA');
        final result = await callable.call({
          'typeConstruction': formData['typeConstruction'],
          'ville': formData['ville'],
          'superficie': formData['surfaceTerrain'],
          'nombrePieces': formData['nombreChambres'],
          'budgetDeclare': budgetDeclare,
        });
        devisResult = Map<String, dynamic>.from(result.data);
      } catch (e) {
        // Fallback local
        devisResult = {
          "fourchetteTotal": {
            "minimum": budgetDeclare * 0.9,
            "moyenne": budgetDeclare,
            "maximum": budgetDeclare * 1.2
          },
          "repartitionParPoste": [
            { "nom": "Gros œuvre", "pourcentage": 40, "montantEstime": budgetDeclare * 0.4 },
            { "nom": "Toiture", "pourcentage": 15, "montantEstime": budgetDeclare * 0.15 },
            { "nom": "Finitions", "pourcentage": 25, "montantEstime": budgetDeclare * 0.25 },
            { "nom": "Plomberie & Électricité", "pourcentage": 20, "montantEstime": budgetDeclare * 0.2 }
          ],
          "delaiEstimeSemaines": 24,
        };
      }

      final fourchette = devisResult['fourchetteTotal'];
      final repartition = devisResult['repartitionParPoste'] as List<dynamic>;
      
      String simulationText = "Voici la simulation de votre devis pour ${formData['typeConstruction']} à ${formData['ville']} :\n\n"
          "💰 Budget Estimé : ${fourchette['moyenne'].toStringAsFixed(0)} FCFA\n"
          "📉 Fourchette : ${fourchette['minimum'].toStringAsFixed(0)} à ${fourchette['maximum'].toStringAsFixed(0)} FCFA\n"
          "⏱ Délai estimé : ${devisResult['delaiEstimeSemaines']} semaines\n\n"
          "📊 Répartition par poste :\n";
          
      for (var poste in repartition) {
        simulationText += "- ${poste['nom']} (${poste['pourcentage']}%) : ${poste['montantEstime'].toStringAsFixed(0)} FCFA\n";
      }

      state = state.copyWith(
        isTyping: false,
        projectId: projectRef.id,
        messages: [
          ...state.messages,
          IaMessage(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            text: simulationText,
            isUser: false,
          ),
          IaMessage(
            id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
            text: "Cette simulation vous convient-elle ? Si oui, vous pouvez valider le projet pour l'envoyer aux entreprises.",
            isUser: false,
            isPlans: true, // we will use this flag to show a Validation button instead of plans
          ),
        ]
      );
    } catch (e) {
      state = state.copyWith(
        isTyping: false,
        messages: [
          ...state.messages,
          IaMessage(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            text: 'Une erreur est survenue lors de la simulation. Voulez-vous réessayer ?',
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
