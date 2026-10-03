import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../data/models/entreprise_model.dart';
import '../../../../data/models/avis_model.dart';
import '../../../../data/models/certification_request_model.dart';

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

final adminStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final db = FirebaseFirestore.instance;
  
  // Total users
  final usersCountQuery = await db.collection('users').count().get();
  final totalUsers = usersCountQuery.count ?? 0;
  
  // Active projects
  final projectsCountQuery = await db.collection('projects').where('statut', isEqualTo: 'en_cours').count().get();
  final activeProjects = projectsCountQuery.count ?? 0;
  
  // Financial volume
  final projectsSnap = await db.collection('projects').where('statut', isNotEqualTo: 'brouillon').get();
  double financialVolume = 0.0;
  for (var doc in projectsSnap.docs) {
    final data = doc.data();
    if (data['budget'] != null) {
      financialVolume += (data['budget'] as num).toDouble();
    }
  }

  return {
    'totalUsers': totalUsers,
    'activeProjects': activeProjects,
    'financialVolume': financialVolume,
    'financialData': [100.0, 120.0, 110.0, 150.0, 200.0, 180.0, 220.0],
    'usersData': [30.0, 40.0, 35.0, 50.0, 60.0, 80.0, 95.0],
  };
});

final pendingEnterprisesProvider = StreamProvider<List<EntrepriseModel>>((ref) {
  return FirebaseFirestore.instance
      .collection('entreprises')
      .where('isVerified', isEqualTo: false)
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) => EntrepriseModel.fromJson(doc.data())).toList());
});

final pendingCertificationsProvider = StreamProvider<List<CertificationRequestModel>>((ref) {
  return FirebaseFirestore.instance
      .collection('demandes_certification')
      .where('statut', isEqualTo: 'en_attente')
      .snapshots()
      .map((snapshot) {
        final list = snapshot.docs.map((doc) => CertificationRequestModel.fromJson(doc.data(), doc.id)).toList();
        list.sort((a, b) {
          if (a.dateSoumission == null && b.dateSoumission == null) return 0;
          if (a.dateSoumission == null) return 1;
          if (b.dateSoumission == null) return -1;
          return a.dateSoumission!.compareTo(b.dateSoumission!);
        }); // plus anciennes en premier
        return list;
      });
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
          targetId: 'e1',
          targetType: 'entreprise',
          clientId: 'c1',
          projectId: 'p1',
          note: 1.0,
          criteres: {'qualite': 1, 'delais': 1, 'communication': 1, 'prix': 1},
          commentaire: 'Arnaque totale, n\'y allez pas !!! [Propos injurieux]',
          dateCreation: DateTime.now().subtract(const Duration(days: 2)),
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

final activityLogsProvider = StreamProvider<List<ActivityLogModel>>((ref) {
  return FirebaseFirestore.instance
      .collection('audit_logs')
      .orderBy('timestamp', descending: true)
      .limit(10)
      .snapshots()
      .map((snap) => snap.docs.map((doc) {
            final data = doc.data();
            return ActivityLogModel(
              id: doc.id,
              action: data['action'] ?? 'Action inconnue',
              user: data['userName'] ?? 'Système',
              timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
            );
          }).toList());
});
