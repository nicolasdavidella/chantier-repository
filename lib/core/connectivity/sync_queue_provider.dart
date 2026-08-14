import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'connectivity_provider.dart';

class SyncAction {
  final String id;
  final String type; // e.g., 'rapport', 'depense'
  final Map<String, dynamic> data;
  final DateTime timestamp;

  SyncAction({
    required this.id,
    required this.type,
    required this.data,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

class SyncQueueNotifier extends StateNotifier<List<SyncAction>> {
  final Ref ref;

  SyncQueueNotifier(this.ref) : super([]) {
    // Écouter les changements de connectivité pour déclencher la synchro
    ref.listen<AsyncValue<bool>>(connectivityProvider, (previous, next) {
      if (next.value == true && state.isNotEmpty) {
        _processQueue();
      }
    });
  }

  void addAction(SyncAction action) {
    state = [...state, action];
  }

  Future<void> _processQueue() async {
    // Si on a retrouvé internet, on traite la file d'attente.
    // Dans une vraie implémentation Firestore persistante hors ligne, 
    // Firestore gère souvent ça lui-même en arrière-plan.
    // Mais cette file d'attente permet de rassurer l'utilisateur et de gérer
    // des actions spécifiques (comme l'upload d'images vers Storage qui nécessite le réseau).
    
    final currentQueue = List<SyncAction>.from(state);
    
    for (final action in currentQueue) {
      try {
        // Simuler un appel réseau réussi
        await Future.delayed(const Duration(milliseconds: 800));
        
        // Retirer l'action de la file
        state = state.where((a) => a.id != action.id).toList();
      } catch (e) {
        // En cas d'erreur, on garde l'action pour le prochain essai
      }
    }
  }

  void simulateSync() {
    _processQueue();
  }
}

final syncQueueProvider = StateNotifierProvider<SyncQueueNotifier, List<SyncAction>>((ref) {
  return SyncQueueNotifier(ref);
});
