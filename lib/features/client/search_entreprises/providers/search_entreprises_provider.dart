import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/models/entreprise_model.dart';

// Mock Data
final mockEntreprises = [
  EntrepriseModel(
    id: 'e1',
    userId: 'u1',
    raisonSociale: 'BatiCam Construction',
    description: 'Expert en construction neuve et rénovation. Qualité et respect des délais garantis.',
    specialites: ['Gros oeuvre', 'Maçonnerie', 'Finitions'],
    anneesExperience: 12,
    noteMoyenne: 4.8,
    nombreAvis: 45,
    realisations: [
      'https://images.unsplash.com/photo-1503387762-592deb58ef4e?q=80&w=600&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1541888081622-152e008fa732?q=80&w=600&auto=format&fit=crop',
    ],
    zoneIntervention: ['Douala', 'Yaoundé'],
    certifie: true,
    prixMoyen: '150 000 FCFA / m²',
    delaiMoyen: '3-6 mois',
  ),
  EntrepriseModel(
    id: 'e2',
    userId: 'u2',
    raisonSociale: 'RenovPlus+',
    description: 'Spécialistes de la rénovation intérieure et extérieure.',
    specialites: ['Peinture', 'Carrelage', 'Plomberie'],
    anneesExperience: 5,
    noteMoyenne: 4.2,
    nombreAvis: 18,
    realisations: [
      'https://images.unsplash.com/photo-1589939705384-5185137a7f0f?q=80&w=600&auto=format&fit=crop',
    ],
    zoneIntervention: ['Yaoundé'],
    certifie: false,
    prixMoyen: '80 000 FCFA / m²',
    delaiMoyen: '1-3 mois',
  ),
  EntrepriseModel(
    id: 'e3',
    userId: 'u3',
    raisonSociale: 'Électricité Express',
    description: 'Installation électrique complète, domotique et dépannage 24/7.',
    specialites: ['Électricité', 'Domotique'],
    anneesExperience: 8,
    noteMoyenne: 5.0,
    nombreAvis: 112,
    realisations: [
      'https://images.unsplash.com/photo-1621905252507-b35492cc74b4?q=80&w=600&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1621905251189-08b45d6a269e?q=80&w=600&auto=format&fit=crop',
    ],
    zoneIntervention: ['Douala', 'Edéa'],
    certifie: true,
    prixMoyen: 'Devis sur mesure',
    delaiMoyen: '1-4 semaines',
  ),
  EntrepriseModel(
    id: 'e4',
    userId: 'u4',
    raisonSociale: 'Bois & Toit',
    description: 'Charpente, toiture et menuiserie.',
    specialites: ['Menuiserie', 'Charpente'],
    anneesExperience: 15,
    noteMoyenne: 4.5,
    nombreAvis: 89,
    realisations: [
      'https://images.unsplash.com/photo-1621905251189-08b45d6a269e?q=80&w=600&auto=format&fit=crop'
    ],
    zoneIntervention: ['Bafoussam', 'Bamenda', 'Douala'],
    certifie: true,
    prixMoyen: '120 000 FCFA / m²',
    delaiMoyen: '2-5 mois',
  ),
];

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
      ville: ville, // Can clear by passing empty string later if needed, but for simplicity we keep it like this
      specialite: specialite,
      minRating: minRating ?? this.minRating,
      certifieOnly: certifieOnly ?? this.certifieOnly,
    );
  }
}

final searchFiltersProvider = StateProvider<SearchFilters>((ref) => SearchFilters());

final filteredEntreprisesProvider = Provider<List<EntrepriseModel>>((ref) {
  final filters = ref.watch(searchFiltersProvider);
  
  return mockEntreprises.where((e) {
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
  }).toList();
});

class ComparisonNotifier extends StateNotifier<List<String>> {
  ComparisonNotifier() : super([]);

  bool toggle(String id) {
    if (state.contains(id)) {
      state = state.where((e) => e != id).toList();
      return true;
    } else {
      if (state.length >= 3) return false; // Max 3
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
  return mockEntreprises.where((e) => selectedIds.contains(e.id)).toList();
});
