import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/project_model.dart';
import '../../../data/models/marketplace_applicant_model.dart';
import '../../../data/repositories/marketplace_repository.dart';
import '../../auth/providers/auth_provider.dart';

/// Stream des projets marketplace du client connecté
final clientMarketplaceProjectsProvider = StreamProvider.autoDispose<List<ProjectModel>>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value([]);
  final repository = ref.watch(marketplaceRepositoryProvider);
  return repository.streamMarketplaceProjectsForClient(user.uid);
});

/// Stream des entreprises candidates / capables pour un projet précis
final projectApplicantsProvider = StreamProvider.autoDispose.family<List<MarketplaceApplicantModel>, String>((ref, projectId) {
  final repository = ref.watch(marketplaceRepositoryProvider);
  return repository.streamApplicantsForProject(projectId);
});

/// Stream du flux d'opportunités marketplace pour l'entreprise connectée
final entrepriseMarketplaceFeedProvider = StreamProvider.autoDispose<List<ProjectDiffusionData>>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value([]);
  final repository = ref.watch(marketplaceRepositoryProvider);
  return repository.streamMarketplaceFeedForEntreprise(user.uid);
});

/// Contrôleur des actions de la marketplace (déclarer capacité, attribuer, décliner)
class MarketplaceController extends StateNotifier<AsyncValue<void>> {
  final MarketplaceRepository _repository;
  final Ref _ref;

  MarketplaceController(this._repository, this._ref) : super(const AsyncData(null));

  /// Déclarer la capacité d'une entreprise pour un projet
  Future<void> declareCapacity({
    required String projectId,
    String? commentaire,
    double? devisEstime,
  }) async {
    state = const AsyncLoading();
    try {
      final user = _ref.read(authStateProvider).value;
      if (user == null) throw Exception("Utilisateur non authentifié.");

      await _repository.declareCompanyCapacity(
        projectId: projectId,
        entrepriseUserId: user.uid,
        commentaire: commentaire,
        devisEstime: devisEstime,
      );
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  /// Décliner un projet
  Future<void> declineProject(String projectId) async {
    state = const AsyncLoading();
    try {
      final user = _ref.read(authStateProvider).value;
      if (user == null) throw Exception("Utilisateur non authentifié.");

      await _repository.declineProject(
        projectId: projectId,
        entrepriseUserId: user.uid,
      );
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  /// Sélectionner une entreprise pour un chantier (Action Client)
  Future<void> selectCompany({
    required String projectId,
    required String entrepriseUserId,
  }) async {
    state = const AsyncLoading();
    try {
      final user = _ref.read(authStateProvider).value;
      if (user == null) throw Exception("Utilisateur non authentifié.");

      await _repository.selectCompanyForProject(
        projectId: projectId,
        clientId: user.uid,
        entrepriseUserId: entrepriseUserId,
      );
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }
}

final marketplaceControllerProvider = StateNotifierProvider.autoDispose<MarketplaceController, AsyncValue<void>>((ref) {
  final repo = ref.watch(marketplaceRepositoryProvider);
  return MarketplaceController(repo, ref);
});
