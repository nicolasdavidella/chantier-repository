import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../../data/models/project_model.dart';
import '../../../../core/services/storage_service.dart';

class ProjectFormData {
  final String titre;
  final String description;
  final String typeConstruction;
  final String ville;
  final String quartier;
  final double? budget;
  final DateTime? dateDebut;
  final DateTime? dateFin;
  final List<XFile> documents;
  final double? latitude;
  final double? longitude;

  ProjectFormData({
    this.titre = '',
    this.description = '',
    this.typeConstruction = '',
    this.ville = '',
    this.quartier = '',
    this.budget,
    this.dateDebut,
    this.dateFin,
    this.documents = const [],
    this.latitude,
    this.longitude,
  });

  ProjectFormData copyWith({
    String? titre,
    String? description,
    String? typeConstruction,
    String? ville,
    String? quartier,
    double? budget,
    DateTime? dateDebut,
    DateTime? dateFin,
    List<XFile>? documents,
    double? latitude,
    double? longitude,
  }) {
    return ProjectFormData(
      titre: titre ?? this.titre,
      description: description ?? this.description,
      typeConstruction: typeConstruction ?? this.typeConstruction,
      ville: ville ?? this.ville,
      quartier: quartier ?? this.quartier,
      budget: budget ?? this.budget,
      dateDebut: dateDebut ?? this.dateDebut,
      dateFin: dateFin ?? this.dateFin,
      documents: documents ?? this.documents,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }
}

class ProjectCreationController extends StateNotifier<AsyncValue<ProjectFormData>> {
  final Ref ref;

  ProjectCreationController(this.ref) : super(AsyncData(ProjectFormData()));

  void updateField({
    String? titre,
    String? description,
    String? typeConstruction,
    String? ville,
    String? quartier,
    double? budget,
    DateTime? dateDebut,
    DateTime? dateFin,
    double? latitude,
    double? longitude,
  }) {
    if (state is AsyncData) {
      final current = state.value!;
      state = AsyncData(current.copyWith(
        titre: titre,
        description: description,
        typeConstruction: typeConstruction,
        ville: ville,
        quartier: quartier,
        budget: budget,
        dateDebut: dateDebut,
        dateFin: dateFin,
        latitude: latitude,
        longitude: longitude,
      ));
    }
  }

  void addDocuments(List<XFile> newDocs) {
    if (state is AsyncData) {
      final current = state.value!;
      state = AsyncData(current.copyWith(
        documents: [...current.documents, ...newDocs],
      ));
    }
  }

  void removeDocument(int index) {
    if (state is AsyncData) {
      final current = state.value!;
      final updated = List<XFile>.from(current.documents)..removeAt(index);
      state = AsyncData(current.copyWith(documents: updated));
    }
  }

  Future<void> submitProject() async {
    final current = state.value;
    if (current == null) return;

    state = const AsyncLoading();

    try {
      final authUser = ref.read(authStateProvider).value;
      if (authUser == null) throw Exception("Non authentifié");

      final projectId = FirebaseFirestore.instance.collection('projets').doc().id;
      final storageService = ref.read(storageServiceProvider);
      
      List<String> uploadedDocsUrls = [];
      for (var doc in current.documents) {
        // Use readAsBytes and uploadData to support Web properly
        final data = await doc.readAsBytes();
        final fileName = '${DateTime.now().millisecondsSinceEpoch}_${doc.name}';
        final url = await storageService.uploadData('projects/$projectId/documents/$fileName', data, contentType: doc.mimeType);
        uploadedDocsUrls.add(url);
      }

      final newProject = ProjectModel(
        id: projectId,
        clientId: authUser.uid,
        titre: current.titre,
        description: current.description,
        localisation: {
          'ville': current.ville,
          'quartier': current.quartier,
          if (current.latitude != null) 'latitude': current.latitude,
          if (current.longitude != null) 'longitude': current.longitude,
        },
        budgetPrevisionnel: current.budget ?? 0,
        budgetActuel: 0,
        dateDebut: current.dateDebut ?? DateTime.now(),
        dateFinPrevue: current.dateFin ?? DateTime.now().add(const Duration(days: 90)),
        statut: 'en_recherche_entreprise',
        listePlans: [],
        listeDocuments: uploadedDocsUrls,
      );

      await FirebaseFirestore.instance.collection('projets').doc(newProject.id).set(newProject.toJson());

      // Reset state on success
      state = AsyncData(ProjectFormData());
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
      // Revert to data state so user can try again
      state = AsyncData(current);
      rethrow;
    }
  }
}

final projectCreationProvider = StateNotifierProvider.autoDispose<ProjectCreationController, AsyncValue<ProjectFormData>>((ref) {
  return ProjectCreationController(ref);
});
