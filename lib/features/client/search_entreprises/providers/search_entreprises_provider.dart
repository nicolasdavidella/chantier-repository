import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/models/entreprise_model.dart';
import '../../../../data/repositories/entreprise_repository.dart';

// ─────────────────────────────────────────────
// Filtres de recherche
// ─────────────────────────────────────────────
class SearchFilters {
  final String query;
  final String? ville;
  final String? specialite;
  final double minRating;
  final bool certifieOnly;

  SearchFilters({
    this.query = '',
    this.ville,
    this.specialite,
    this.minRating = 0,
    this.certifieOnly = false,
  });

  SearchFilters copyWith({
    String? query,
    String? ville,
    String? specialite,
    double? minRating,
    bool? certifieOnly,
  }) {
    return SearchFilters(
      query: query ?? this.query,
      ville: ville,
      specialite: specialite,
      minRating: minRating ?? this.minRating,
      certifieOnly: certifieOnly ?? this.certifieOnly,
    );
  }
}

final searchFiltersProvider = StateProvider<SearchFilters>((ref) => SearchFilters());

// ─────────────────────────────────────────────
// Stream Firestore de toutes les entreprises
// ─────────────────────────────────────────────
final allEntreprisesStreamProvider = StreamProvider<List<EntrepriseModel>>((ref) {
  final repo = ref.watch(entrepriseRepositoryProvider);
  return repo.watchAll();
});

// ─────────────────────────────────────────────
// Provider filtré (applique les filtres locaux)
// ─────────────────────────────────────────────
final filteredEntreprisesProvider = Provider<AsyncValue<List<EntrepriseModel>>>((ref) {
  final filters = ref.watch(searchFiltersProvider);
  final allAsync = ref.watch(allEntreprisesStreamProvider);

  return allAsync.whenData((list) => list.where((e) {
    if (filters.certifieOnly && !e.certifie) return false;
    if (e.noteMoyenne < filters.minRating) return false;

    if (filters.ville != null && filters.ville!.isNotEmpty && filters.ville != 'Toutes') {
      if (!e.zoneIntervention.contains(filters.ville)) return false;
    }

    if (filters.specialite != null && filters.specialite!.isNotEmpty && filters.specialite != 'Toutes') {
      if (!e.specialites.contains(filters.specialite)) return false;
    }

    if (filters.query.isNotEmpty) {
      final q = filters.query.toLowerCase();
      if (!e.raisonSociale.toLowerCase().contains(q) &&
          !e.description.toLowerCase().contains(q)) {
        return false;
      }
    }

    return true;
  }).toList());
});

// ─────────────────────────────────────────────
// Comparaison
// ─────────────────────────────────────────────
class ComparisonNotifier extends StateNotifier<List<String>> {
  ComparisonNotifier() : super([]);

  bool toggle(String id) {
    if (state.contains(id)) {
      state = state.where((e) => e != id).toList();
      return true;
    } else {
      if (state.length >= 3) return false;
      state = [...state, id];
      return true;
    }
  }

  void clear() => state = [];
}

final comparisonListProvider = StateNotifierProvider<ComparisonNotifier, List<String>>((ref) {
  return ComparisonNotifier();
});

final selectedEntreprisesProvider = Provider<List<EntrepriseModel>>((ref) {
  final selectedIds = ref.watch(comparisonListProvider);
  final allAsync = ref.watch(allEntreprisesStreamProvider);
  final all = allAsync.value ?? [];
  return all.where((e) => selectedIds.contains(e.id)).toList();
});
