import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/models/devis_model.dart';

class DevisNotifier extends StateNotifier<List<DevisModel>> {
  DevisNotifier() : super([]);

  void submitDevis(DevisModel devis) {
    state = [
      devis,
      ...state.where((d) => d.id != devis.id),
    ];
  }

  void updateDevisStatus(String devisId, String statut) {
    state = state.map((d) {
      if (d.id == devisId) {
        return d.copyWith(statut: statut);
      }
      return d;
    }).toList();
  }
}

final devisProvider = StateNotifierProvider<DevisNotifier, List<DevisModel>>((ref) {
  return DevisNotifier();
});
