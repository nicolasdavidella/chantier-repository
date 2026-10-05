import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../data/models/user_model.dart';
import '../../../../data/models/entreprise_model.dart';
import '../../../../data/models/avis_model.dart';
import '../../../../data/models/certification_request_model.dart';

// --- Activity and Moderation Models ---

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

final adminStatsFutureProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
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

final pendingEnterprisesStreamProvider = StreamProvider.autoDispose<List<EntrepriseModel>>((ref) {
  return FirebaseFirestore.instance
      .collection('entreprises')
      .where('isVerified', isEqualTo: false)
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return EntrepriseModel.fromJson(data);
          }).toList());
});

final pendingCertificationsStreamProvider = StreamProvider.autoDispose<List<CertificationRequestModel>>((ref) {
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

final usersStreamProvider = StreamProvider.autoDispose<List<UserModel>>((ref) {
  return FirebaseFirestore.instance
      .collection('users')
      .snapshots()
      .map((snapshot) {
        final list = snapshot.docs.map((doc) {
          final data = doc.data();
          if (!data.containsKey('uid') || (data['uid'] as String?)?.isEmpty == true) {
            data['uid'] = doc.id;
          }
          return UserModel.fromJson(data);
        }).toList();
        list.sort((a, b) => b.dateCreation.compareTo(a.dateCreation));
        return list;
      });
});

class AdminUserController {
  static Future<void> changeRole(String uid, String newRole) async {
    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'role': newRole,
    }, SetOptions(merge: true));
  }

  static Future<void> toggleStatus(String uid, bool currentActive) async {
    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'isActive': !currentActive,
    }, SetOptions(merge: true));
  }
}

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

final activityLogsStreamProvider = StreamProvider.autoDispose<List<ActivityLogModel>>((ref) {
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
