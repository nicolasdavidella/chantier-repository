import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../data/models/project_model.dart';
import '../../../../core/services/meshy_service.dart';
import '../../../../core/services/storage_service.dart';
import 'package:firebase_storage/firebase_storage.dart';

final iaProjectProvider =
    StateNotifierProvider<IaProjectNotifier, IaProjectState>((ref) {
      return IaProjectNotifier();
    });

class IaProjectState {
  final List<IaMessage> messages;
  final bool isTyping;
  final bool isGenerating3D;
  final bool hasSubmittedForm;
  final String? projectId;
  final List<dynamic>? generatedPlans;

  IaProjectState({
    required this.messages,
    this.isTyping = false,
    this.isGenerating3D = false,
    this.hasSubmittedForm = false,
    this.projectId,
    this.generatedPlans,
  });

  IaProjectState copyWith({
    List<IaMessage>? messages,
    bool? isTyping,
    bool? isGenerating3D,
    bool? hasSubmittedForm,
    String? projectId,
    List<dynamic>? generatedPlans,
  }) {
    return IaProjectState(
      messages: messages ?? this.messages,
      isTyping: isTyping ?? this.isTyping,
      isGenerating3D: isGenerating3D ?? this.isGenerating3D,
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
  final List<String>? options;
  final String? questionKey;

  IaMessage({
    required this.id,
    required this.text,
    required this.isUser,
    this.isForm = false,
    this.isPlans = false,
    this.options,
    this.questionKey,
  });
}

class IaProjectNotifier extends StateNotifier<IaProjectState> {
  StreamSubscription? _authSub;
  int _stepIndex = 0;
  final Map<String, dynamic> _projectDraft = {
    'typeConstruction': 'villa',
    'ville': 'Yaoundé',
    'quartier': 'Bastos',
    'surfaceTerrain': '200',
    'nombreChambres': '4',
    'budgetPrevisionnel': '25000000',
    'description': '',
  };

  IaProjectNotifier() : super(IaProjectState(messages: [])) {
    _initChat();
    // Écouter les changements d'authentification pour réinitialiser si déconnexion
    _authSub = FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user == null) {
        resetSession();
      }
    });
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }

  void _initChat() {
    _stepIndex = 0;
    _projectDraft.clear();
    state = state.copyWith(
      messages: [
        IaMessage(
          id: 'q1',
          text:
              'Bonjour ! Bienvenue sur le Studio Architecte ChantierTrack. Pour concevoir votre plan 3D sur-mesure et simuler votre devis, quel type de construction souhaitez-vous réaliser ?',
          isUser: false,
          questionKey: 'typeConstruction',
          options: const [
            'Villa contemporaine',
            'Duplex moderne',
            'Maison plain-pied',
            'Immeuble / Résidence',
            'Studio moderne',
            'Rénovation / Extension',
          ],
        ),
      ],
    );
  }

  void resetSession() {
    state = IaProjectState(messages: []);
    _initChat();
  }

  Future<void> answerQuestion(String answer, {String? imagePath}) async {
    final cleanAnswer = answer.trim();
    if (cleanAnswer.isEmpty && imagePath == null) return;

    if (imagePath != null) {
      _projectDraft['imagePath'] = imagePath;
    }

    // 1. Ajouter la réponse de l'utilisateur dans le fil
    state = state.copyWith(
      messages: [
        ...state.messages,
        IaMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          text: cleanAnswer.isNotEmpty ? cleanAnswer : 'Plan / croquis joint 📎',
          isUser: true,
        ),
      ],
    );

    // 2. Traiter selon l'étape actuelle du circuit
    switch (_stepIndex) {
      case 0: // Type de construction
        _projectDraft['typeConstruction'] = cleanAnswer;
        _stepIndex = 1;
        _askNextQuestion(
          'Excellent choix ! Dans quelle ville se situe votre terrain ou futur chantier ?',
          'ville',
          const ['Yaoundé', 'Douala', 'Kribi', 'Bafoussam', 'Garoua', 'Autre ville'],
        );
        break;

      case 1: // Ville
        _projectDraft['ville'] = cleanAnswer;
        _stepIndex = 2;
        _askNextQuestion(
          'Dans quel quartier ou zone de ${_projectDraft['ville']} se trouve votre projet ?',
          'quartier',
          const ['Bastos', 'Bonapriso', 'Odza', 'Ngousso', 'Centre-ville', 'Autre quartier'],
        );
        break;

      case 2: // Quartier
        _projectDraft['quartier'] = cleanAnswer;
        _stepIndex = 3;
        _askNextQuestion(
          'Quelle superficie approximative envisagez-vous pour le bâtiment (en m²) ?',
          'surfaceTerrain',
          const ['100 m²', '150 m²', '200 m²', '300 m²', '500 m²+'],
        );
        break;

      case 3: // Surface
        final match = RegExp(r'\d+').firstMatch(cleanAnswer);
        _projectDraft['surfaceTerrain'] = match != null ? match.group(0)! : '200';
        _stepIndex = 4;
        _askNextQuestion(
          'Combien de chambres prévoyez-vous dans ce plan ?',
          'nombreChambres',
          const ['2 chambres', '3 chambres', '4 chambres', '5+ chambres'],
        );
        break;

      case 4: // Chambres
        final match = RegExp(r'\d+').firstMatch(cleanAnswer);
        _projectDraft['nombreChambres'] = match != null ? match.group(0)! : '4';
        _stepIndex = 5;
        _askNextQuestion(
          'Quel est votre budget pour ces travaux (en FCFA) ?',
          'budgetPrevisionnel',
          const [], // L'utilisateur entre directement son budget
        );
        break;

      case 5: // Budget
        final digits = cleanAnswer.replaceAll(RegExp(r'[^\d]'), '');
        _projectDraft['budgetPrevisionnel'] = digits.isNotEmpty ? digits : '25000000';
        _stepIndex = 6;
        _askNextQuestion(
          'Avez-vous des exigences particulières (piscine, terrasse, toiture plate) ou un croquis à joindre ?',
          'description',
          const [
            'Avec grande terrasse & baies vitrées',
            'Avec piscine et jardin paysager',
            'Design contemporain minimaliste',
            'Lancer la modélisation 3D directement',
          ],
        );
        break;

      case 6: // Détails / Déclenchement de la modélisation
        _projectDraft['description'] = cleanAnswer;
        _projectDraft['titre'] = 'Projet ${_projectDraft['typeConstruction']}';
        _stepIndex = 7;

        state = state.copyWith(
          messages: [
            ...state.messages,
            IaMessage(
              id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
              text:
                  'Parfait ! Vos critères sont tous enregistrés :\n'
                  '• Type : ${_projectDraft['typeConstruction']}\n'
                  '• Localisation : ${_projectDraft['ville']} (${_projectDraft['quartier']})\n'
                  '• Surface : ${_projectDraft['surfaceTerrain']} m² • ${_projectDraft['nombreChambres']} chambres\n'
                  '• Budget : ${_projectDraft['budgetPrevisionnel']} FCFA\n\n'
                  'Je lance immédiatement la génération de votre modèle 3D avec Meshy AI et l\'estimation prévisionnelle de votre devis...',
              isUser: false,
            ),
          ],
        );

        await submitProjectForm(Map<String, dynamic>.from(_projectDraft));
        break;

      default:
        // Si le questionnaire est fini, affiner avec l'IA
        await affinerPlan(cleanAnswer);
        break;
    }
  }

  void _askNextQuestion(String text, String key, List<String> options) {
    state = state.copyWith(
      messages: [
        ...state.messages,
        IaMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          text: text,
          isUser: false,
          questionKey: key,
          options: options,
        ),
      ],
    );
  }

  Future<void> submitProjectForm(Map<String, dynamic> formData) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    state = state.copyWith(
      hasSubmittedForm: true,
      isTyping: true,
    );

    try {
      // 1. Create draft project in Firestore
      final projectRef = FirebaseFirestore.instance
          .collection('projects')
          .doc();
      final budgetDeclare =
          double.tryParse(formData['budgetPrevisionnel'].toString()) ?? 0;
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
        final callable = FirebaseFunctions.instance.httpsCallable(
          'simulerDevisIA',
        );
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
            "maximum": budgetDeclare * 1.2,
          },
          "repartitionParPoste": [
            {
              "nom": "Gros œuvre",
              "pourcentage": 40,
              "montantEstime": budgetDeclare * 0.4,
            },
            {
              "nom": "Toiture",
              "pourcentage": 15,
              "montantEstime": budgetDeclare * 0.15,
            },
            {
              "nom": "Finitions",
              "pourcentage": 25,
              "montantEstime": budgetDeclare * 0.25,
            },
            {
              "nom": "Plomberie & Électricité",
              "pourcentage": 20,
              "montantEstime": budgetDeclare * 0.2,
            },
          ],
          "delaiEstimeSemaines": 24,
        };
      }

      final fourchette = devisResult['fourchetteTotal'];
      final repartition = devisResult['repartitionParPoste'] as List<dynamic>;

      String simulationText =
          "Voici la simulation de votre devis pour ${formData['typeConstruction']} à ${formData['ville']} :\n\n"
          "💰 Budget Estimé : ${fourchette['moyenne'].toStringAsFixed(0)} FCFA\n"
          "📉 Fourchette : ${fourchette['minimum'].toStringAsFixed(0)} à ${fourchette['maximum'].toStringAsFixed(0)} FCFA\n"
          "⏱ Délai estimé : ${devisResult['delaiEstimeSemaines']} semaines\n\n"
          "📊 Répartition par poste :\n";

      for (var poste in repartition) {
        simulationText +=
            "- ${poste['nom']} (${poste['pourcentage']}%) : ${poste['montantEstime'].toStringAsFixed(0)} FCFA\n";
      }

      state = state.copyWith(
        isTyping: false,
        isGenerating3D: true,
        projectId: projectRef.id,
        messages: [
          ...state.messages,
          IaMessage(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            text: simulationText,
            isUser: false,
          ),
        ],
      );

      // 3. Generate 3D plan
      String? glbUrl;
      try {
        final meshyService = MeshyService();
        final imagePath = formData['imagePath'] as String?;
        final description = formData['description'] as String?;

        if (imagePath != null && imagePath.isNotEmpty) {
          // Upload image to storage first
          final file = File(imagePath);
          final extension = imagePath.split('.').last;
          final storagePath =
              'meshy_inputs/${user.uid}_${DateTime.now().millisecondsSinceEpoch}.$extension';
          final storageService = StorageService(FirebaseStorage.instance);
          final imageUrl = await storageService.uploadFile(storagePath, file);

          glbUrl = await meshyService.generate3DModel(imageUrl: imageUrl);
        } else {
          // Combiner toutes les informations du formulaire pour créer un prompt très riche (en anglais pour une meilleure qualité d'IA)
          final type = formData['typeConstruction'] ?? 'house';
          final surface = formData['surfaceTerrain'] ?? '100';
          final chambres = formData['nombreChambres'] ?? '3';
          
          String fullPrompt = "High quality architectural 3D cutaway model, isometric floor plan of a $type, $surface sqm with $chambres bedrooms. Photorealistic, highly detailed interior with furniture, modern design, professional architectural rendering, global illumination, clean lighting.";
          
          if (description != null && description.isNotEmpty) {
            // Ajouter la description de l'utilisateur (traduite ou brute)
            fullPrompt += " Specific details: $description";
          }
          
          // Sécurité : couper à 790 caractères pour respecter la limite stricte de Meshy (800)
          if (fullPrompt.length > 790) {
            fullPrompt = fullPrompt.substring(0, 790);
          }

          glbUrl = await meshyService.generate3DModel(prompt: fullPrompt);
        }

        if (glbUrl.isNotEmpty) {
           // Télécharger le fichier GLB localement pour éviter les problèmes de CORS dans le WebView
           String finalPath = glbUrl;
           try {
             final response = await http.get(Uri.parse(glbUrl));
             if (response.statusCode == 200) {
               final dir = Directory.systemTemp;
               final file = File('${dir.path}/modele_3d_${DateTime.now().millisecondsSinceEpoch}.glb');
               await file.writeAsBytes(response.bodyBytes);
               finalPath = 'file://${file.path}';
               debugPrint('Fichier 3D téléchargé localement : $finalPath');
             }
           } catch (e) {
             debugPrint('Erreur lors du téléchargement du GLB: $e');
           }

          // Update project with the 3D plan
          await projectRef.update({
            'listePlans': [finalPath],
          });

          state = state.copyWith(
            isGenerating3D: false,
            generatedPlans: [finalPath],
            messages: [
              ...state.messages,
              IaMessage(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                text:
                    "Voici votre maquette 3D interactive conçue pour votre projet ! Vous pouvez pivoter et zoomer sur le plan. Souhaitez-vous valider le projet pour l'envoyer aux entreprises ?",
                isUser: false,
                isPlans: true,
              ),
            ],
          );
        }
      } catch (e) {
        state = state.copyWith(
          isGenerating3D: false,
          messages: [
            ...state.messages,
            IaMessage(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              text:
                  "La modélisation 3D a rencontré une anomalie ($e). Vous pouvez toutefois valider votre devis pour démarrer vos démarches.",
              isUser: false,
              isPlans: true,
            ),
          ],
        );
      }
    } catch (e) {
      state = state.copyWith(
        isTyping: false,
        isGenerating3D: false,
        messages: [
          ...state.messages,
          IaMessage(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            text:
                'Une erreur est survenue lors de la simulation. Voulez-vous réessayer ?',
            isUser: false,
          ),
        ],
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
        'statut':
            'en_recherche_entreprise', // Changé de plan_valide à en_recherche_entreprise pour démarrer la diffusion
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
        debugPrint(
          '✅ Plan validé et diffusé à ${entreprisesSnap.docs.length} entreprise(s)',
        );
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
      final httpsCallable = FirebaseFunctions.instance.httpsCallable(
        'affinerPlan',
      );
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
              text:
                  result.data['message'] ??
                  'Le plan a été mis à jour selon vos retours.',
              isUser: false,
            ),
          ],
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
            text:
                'Désolé, je n\'ai pas pu modifier le plan. Veuillez réessayer.',
            isUser: false,
          ),
        ],
      );
    }
  }
}
