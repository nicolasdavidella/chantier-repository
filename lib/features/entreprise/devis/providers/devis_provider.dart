import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/models/devis_model.dart';

class DevisNotifier extends StateNotifier<List<DevisModel>> {
  DevisNotifier() : super([]) {
    _loadInitialMockData();
  }

  void _loadInitialMockData() {
    state = [
      DevisModel(
        id: 'd1',
        projectId: 'req2',
        entrepriseId: 'me',
        montant: 8500000,
        delaiEstime: '45 jours',
        description: 'Nous proposons une toiture en tuiles métalliques de haute qualité et une peinture résistante aux intempéries.',
        dateEnvoi: DateTime.now().subtract(const Duration(days: 2)),
        statut: 'en_attente',
      ),
      DevisModel(
        id: 'd2',
        projectId: 'req3',
        entrepriseId: 'me',
        montant: 1200000,
        delaiEstime: '2 semaines',
        description: 'Installation complète du système de plomberie.',
        dateEnvoi: DateTime.now().subtract(const Duration(days: 5)),
        statut: 'refuse',
      ),
      DevisModel(
        id: 'd3',
        projectId: 'req4',
        entrepriseId: 'me',
        montant: 45000000,
        delaiEstime: '6 mois',
        description: 'Construction d\'une villa type F4 clé en main.',
        dateEnvoi: DateTime.now().subtract(const Duration(days: 10)),
        statut: 'accepte',
      ),
    ];
  }

  void submitDevis(DevisModel devis) {
    state = [devis, ...state];
    _simulateFCMStatusChange(devis.id);
  }

  void _simulateFCMStatusChange(String devisId) {
    // Simulate receiving a notification that the quote is accepted after 5 seconds
    Timer(const Duration(seconds: 5), () {
      state = state.map((d) {
        if (d.id == devisId) {
          return d.copyWith(statut: 'accepte');
        }
        return d;
      }).toList();
      
      // We can expose an event stream or just let the UI react to the state change.
      // For demonstration, a UI layer could listen to this state change.
    });
  }
}

final devisProvider = StateNotifierProvider<DevisNotifier, List<DevisModel>>((ref) {
  return DevisNotifier();
});
