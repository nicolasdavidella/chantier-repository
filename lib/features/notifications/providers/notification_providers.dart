import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/models/notification_model.dart';

class NotificationsNotifier extends StateNotifier<List<NotificationModel>> {
  NotificationsNotifier() : super([]) {
    _loadMockData();
  }

  void _loadMockData() {
    final now = DateTime.now();
    state = [
      NotificationModel(
        id: 'n1',
        userId: 'u_current',
        titre: 'Alerte IA Critique',
        corps: 'Anomalie détectée dans les dépenses du chantier "Villa M".',
        type: 'alerte_ia',
        dateEnvoi: now.subtract(const Duration(minutes: 10)),
        lu: false,
      ),
      NotificationModel(
        id: 'n2',
        userId: 'u_current',
        titre: 'Nouveau Message',
        corps: 'BatiPlus a répondu à votre demande de devis.',
        type: 'message',
        dateEnvoi: now.subtract(const Duration(hours: 2)),
        lu: false,
      ),
      NotificationModel(
        id: 'n3',
        userId: 'u_current',
        titre: 'Devis Accepté',
        corps: 'Votre devis D-1234 a été accepté par le client.',
        type: 'statut_devis',
        dateEnvoi: now.subtract(const Duration(days: 1)),
        lu: true,
      ),
      NotificationModel(
        id: 'n4',
        userId: 'u_current',
        titre: 'Nouveau Rapport',
        corps: 'Paul a ajouté un rapport d\'avancement sur "Fondations".',
        type: 'rapport',
        dateEnvoi: now.subtract(const Duration(days: 3)),
        lu: true,
      ),
    ];
  }

  void markAsRead(String id) {
    state = state.map((n) {
      if (n.id == id) return n.copyWith(lu: true);
      return n;
    }).toList();
  }

  void markAllAsRead() {
    state = state.map((n) => n.copyWith(lu: true)).toList();
  }

  void dismissNotification(String id) {
    state = state.where((n) => n.id != id).toList();
  }
}

final notificationsProvider = StateNotifierProvider<NotificationsNotifier, List<NotificationModel>>((ref) {
  return NotificationsNotifier();
});

final unreadNotificationsCountProvider = Provider<int>((ref) {
  final notifs = ref.watch(notificationsProvider);
  return notifs.where((n) => !n.lu).length;
});
