import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/models/entreprise_model.dart';
import '../../../../data/models/avis_model.dart';

// --- Mock Models ---

class UserModel {
  final String id;
  final String nom;
  final String email;
  final String role; // 'client', 'entreprise', 'chef_chantier', 'admin'
  final bool isActive;

  UserModel({required this.id, required this.nom, required this.email, required this.role, this.isActive = true});

  UserModel copyWith({String? role, bool? isActive}) {
    return UserModel(
      id: id,
      nom: nom,
      email: email,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
    );
  }
}

class ActivityLogModel {
  final String id;
  final String action;
  final String user;
  final DateTime timestamp;

  ActivityLogModel({required this.id, required this.action, required this.user, required this.timestamp});
}

class FlaggedReviewModel {
  final String id;
  final AvisModel review;
  final String reason;
  final DateTime flaggedAt;

  FlaggedReviewModel({required this.id, required this.review, required this.reason, required this.flaggedAt});
}

// --- Providers ---

final adminStatsProvider = Provider((ref) {
  return {
    'totalUsers': 1245,
    'activeProjects': 34,
    'financialVolume': 1500000000.0, // FCFA
    'financialData': [100.0, 120.0, 110.0, 150.0, 200.0, 180.0, 220.0], // For sparkline
    'usersData': [30.0, 40.0, 35.0, 50.0, 60.0, 80.0, 95.0],
  };
});

class PendingEnterprisesNotifier extends StateNotifier<List<EntrepriseModel>> {
  PendingEnterprisesNotifier() : super([]) {
    _loadMockData();
  }

  void _loadMockData() {
    state = [
      EntrepriseModel(
        id: 'e_pending_1',
        nom: 'BatiPlus SARL',
        email: 'contact@batiplus.cm',
        telephone: '699001122',
        specialites: ['Gros oeuvre', 'Fondations'],
        zoneIntervention: ['Yaoundé', 'Douala'],
        bio: 'Entreprise spécialisée dans les gros oeuvres depuis 10 ans.',
        estCertifie: false,
        noteMoyenne: 0.0,
        nombreRealisations: 0,
        logoUrl: 'https://images.unsplash.com/photo-1541888081622-1db116fb837a?auto=format&fit=crop&w=150&q=60',
        realisationsUrls: [],
      ),
      EntrepriseModel(
        id: 'e_pending_2',
        nom: 'Toiture 237',
        email: 'info@toiture237.com',
        telephone: '677889900',
        specialites: ['Charpente', 'Toiture'],
        zoneIntervention: ['Bafoussam'],
        bio: 'Experts en charpentes métalliques.',
        estCertifie: false,
        noteMoyenne: 0.0,
        nombreRealisations: 0,
        logoUrl: null,
        realisationsUrls: [],
      ),
    ];
  }

  void validateEnterprise(String id) {
    state = state.where((e) => e.id != id).toList();
    // Simulate log creation
  }

  void rejectEnterprise(String id) {
    state = state.where((e) => e.id != id).toList();
    // Simulate log creation
  }
}

final pendingEnterprisesProvider = StateNotifierProvider<PendingEnterprisesNotifier, List<EntrepriseModel>>((ref) {
  return PendingEnterprisesNotifier();
});

class UsersManagementNotifier extends StateNotifier<List<UserModel>> {
  UsersManagementNotifier() : super([]) {
    _loadMockData();
  }

  void _loadMockData() {
    state = [
      UserModel(id: 'u1', nom: 'Jean Dupont', email: 'jean@example.com', role: 'client'),
      UserModel(id: 'u2', nom: 'BatiPlus', email: 'contact@batiplus.cm', role: 'entreprise'),
      UserModel(id: 'u3', nom: 'Admin Sup', email: 'admin@chantiertrack.cm', role: 'admin'),
      UserModel(id: 'u4', nom: 'Paul Chantier', email: 'paul@chef.cm', role: 'chef_chantier', isActive: false),
    ];
  }

  void changeRole(String id, String newRole) {
    state = state.map((u) => u.id == id ? u.copyWith(role: newRole) : u).toList();
  }

  void toggleStatus(String id) {
    state = state.map((u) => u.id == id ? u.copyWith(isActive: !u.isActive) : u).toList();
  }
}

final usersManagementProvider = StateNotifierProvider<UsersManagementNotifier, List<UserModel>>((ref) {
  return UsersManagementNotifier();
});

class ModerationNotifier extends StateNotifier<List<FlaggedReviewModel>> {
  ModerationNotifier() : super([]) {
    _loadMockData();
  }

  void _loadMockData() {
    state = [
      FlaggedReviewModel(
        id: 'f1',
        review: AvisModel(
          id: 'a1',
          entrepriseId: 'e1',
          clientId: 'c1',
          clientNom: 'Marc D.',
          note: 1,
          commentaire: 'Arnaque totale, n\'y allez pas !!! [Propos injurieux]',
          date: DateTime.now().subtract(const Duration(days: 2)),
        ),
        reason: 'Langage offensant / Diffamation',
        flaggedAt: DateTime.now().subtract(const Duration(hours: 5)),
      )
    ];
  }

  void deleteReview(String id) {
    state = state.where((f) => f.id != id).toList();
  }

  void ignoreFlag(String id) {
    state = state.where((f) => f.id != id).toList();
  }
}

final moderationProvider = StateNotifierProvider<ModerationNotifier, List<FlaggedReviewModel>>((ref) {
  return ModerationNotifier();
});

final activityLogsProvider = Provider<List<ActivityLogModel>>((ref) {
  return [
    ActivityLogModel(id: 'l1', action: 'Validation de l\'entreprise "Toiture 237"', user: 'Admin Sup', timestamp: DateTime.now().subtract(const Duration(minutes: 10))),
    ActivityLogModel(id: 'l2', action: 'Bannissement de l\'utilisateur "Paul Chantier"', user: 'Admin Sup', timestamp: DateTime.now().subtract(const Duration(hours: 2))),
    ActivityLogModel(id: 'l3', action: 'Suppression de l\'avis de "Marc D."', user: 'Admin Mod', timestamp: DateTime.now().subtract(const Duration(days: 1))),
  ];
});
