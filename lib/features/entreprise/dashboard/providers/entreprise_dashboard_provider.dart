import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../data/models/project_model.dart';

// --- Models for Dashboard Stats ---
class EntrepriseStats {
  final int activeProjects;
  final int pendingQuotes;
  final double averageRating;
  final double monthlyRevenue;

  EntrepriseStats({
    required this.activeProjects,
    required this.pendingQuotes,
    required this.averageRating,
    required this.monthlyRevenue,
  });
}

// --- Providers ---
final entrepriseStatsProvider = Provider<EntrepriseStats>((ref) {
  return EntrepriseStats(
    activeProjects: 3,
    pendingQuotes: 5,
    averageRating: 4.8,
    monthlyRevenue: 12500000.0, // 12.5M FCFA
  );
});

final projectRequestsProvider = Provider<List<ProjectModel>>((ref) {
  return [
    ProjectModel(
      id: 'req1',
      clientId: 'c1',
      titre: 'Construction Villa F4 à Kribi',
      description: 'Projet de construction d\'une villa avec piscine. Cherche entreprise gros oeuvre et finitions.',
      localisation: {'ville': 'Kribi', 'quartier': 'Mpangou'},
      budgetPrevisionnel: 45000000.0,
      budgetActuel: 0,
      dateDebut: DateTime.now().add(const Duration(days: 30)),
      dateFinPrevue: DateTime.now().add(const Duration(days: 180)),
      statut: 'en_recherche_entreprise',
      listePlans: [],
      listeDocuments: [],
    ),
    ProjectModel(
      id: 'req2',
      clientId: 'c2',
      titre: 'Rénovation toiture et peinture',
      description: 'Refonte complète de la toiture d\'un immeuble R+2 et ravalement de façade.',
      localisation: {'ville': 'Douala', 'quartier': 'Bonapriso'},
      budgetPrevisionnel: 8500000.0,
      budgetActuel: 0,
      dateDebut: DateTime.now().add(const Duration(days: 14)),
      dateFinPrevue: DateTime.now().add(const Duration(days: 45)),
      statut: 'en_recherche_entreprise',
      listePlans: [],
      listeDocuments: [],
    ),
  ];
});

final activeProjectsProvider = Provider<List<ProjectModel>>((ref) {
  return [
    ProjectModel(
      id: 'act1',
      clientId: 'c3',
      entrepriseId: 'me',
      titre: 'Immeuble Commercial R+4',
      description: 'Construction d\'un immeuble de bureaux au centre ville.',
      localisation: {'ville': 'Yaoundé', 'quartier': 'Bastos'},
      budgetPrevisionnel: 120000000.0,
      budgetActuel: 45000000.0, // Used for progress
      dateDebut: DateTime.now().subtract(const Duration(days: 60)),
      dateFinPrevue: DateTime.now().add(const Duration(days: 200)),
      statut: 'en_cours',
      listePlans: ['https://picsum.photos/seed/immeuble-r4/500/350'],
      listeDocuments: [],
    ),
    ProjectModel(
      id: 'act2',
      clientId: 'c4',
      entrepriseId: 'me',
      titre: 'Maison Individuelle Moderne',
      description: 'Construction clé en main.',
      localisation: {'ville': 'Douala', 'quartier': 'Makepe'},
      budgetPrevisionnel: 35000000.0,
      budgetActuel: 31000000.0, // Almost done
      dateDebut: DateTime.now().subtract(const Duration(days: 120)),
      dateFinPrevue: DateTime.now().add(const Duration(days: 10)),
      statut: 'en_cours',
      listePlans: ['https://picsum.photos/seed/maison-moderne/500/350'],
      listeDocuments: [],
    ),
  ];
});

// --- Models for Notion-style Dashboard ---
class DashboardTask {
  final String title;
  final String tag;
  final String assignee;
  final String avatarUrl;
  final String status; // 'To Do', 'In Progress', 'Review', 'Done'

  DashboardTask({required this.title, required this.tag, required this.assignee, required this.avatarUrl, required this.status});
}

class DashboardBudget {
  final double totalBudget;
  final double spent;
  final Map<String, double> breakdown;

  DashboardBudget({required this.totalBudget, required this.spent, required this.breakdown});
  
  double get remaining => totalBudget - spent;
  double get spentPercentage => spent / totalBudget;
}

class DashboardData {
  final double overallProgress;
  final int tasksCompleted;
  final int tasksRemaining;
  final String projectDuration;
  final String completionTarget;
  final List<DashboardTask> tasks;
  final DashboardBudget budget;
  final List<Map<String, String>> photos;

  DashboardData({
    required this.overallProgress,
    required this.tasksCompleted,
    required this.tasksRemaining,
    required this.projectDuration,
    required this.completionTarget,
    required this.tasks,
    required this.budget,
    required this.photos,
  });
}

class DashboardDataNotifier extends Notifier<DashboardData> {
  @override
  DashboardData build() {
    return DashboardData(
      overallProgress: 0.72,
      tasksCompleted: 28,
      tasksRemaining: 112,
      projectDuration: '12 Semaines',
      completionTarget: '30 Mai 2025',
      budget: DashboardBudget(
        totalBudget: 75000000,
        spent: 52500000,
        breakdown: {
          'Matériaux': 27000000,
          'Main d\'œuvre': 15000000,
          'Équipement': 5700000,
          'Sous-traitants': 4500000,
          'Divers': 300000,
        },
      ),
      tasks: [
        DashboardTask(title: 'Coulage Dalle', tag: 'Fondations', status: 'To Do', assignee: 'Jean D.', avatarUrl: 'https://ui-avatars.com/api/?name=Jean+D&background=4F6BED&color=fff&size=64'),
        DashboardTask(title: 'Élévation Murs', tag: 'Structure', status: 'In Progress', assignee: 'Marc L.', avatarUrl: 'https://ui-avatars.com/api/?name=Marc+L&background=22C55E&color=fff&size=64'),
        DashboardTask(title: 'Charpente', tag: 'Structure', status: 'In Progress', assignee: 'Paul B.', avatarUrl: 'https://ui-avatars.com/api/?name=Paul+B&background=F59E0B&color=fff&size=64'),
        DashboardTask(title: 'Pose Fenêtres', tag: 'Extérieur', status: 'Review', assignee: 'Sarah W.', avatarUrl: 'https://ui-avatars.com/api/?name=Sarah+W&background=EC4899&color=fff&size=64'),
        DashboardTask(title: 'Terrassement', tag: 'Préparation', status: 'Done', assignee: 'Robert C.', avatarUrl: 'https://ui-avatars.com/api/?name=Robert+C&background=8B5CF6&color=fff&size=64'),
      ],
      photos: [
        {'url': 'https://picsum.photos/seed/fondations/300/200', 'date': '20 Mai 2025', 'caption': 'Fondations'},
        {'url': 'https://picsum.photos/seed/briques/300/200', 'date': '27 Mai 2025', 'caption': 'Murs en briques'},
        {'url': 'https://picsum.photos/seed/structure/300/200', 'date': '3 Juin 2025', 'caption': 'Structure Métallique'},
        {'url': 'https://picsum.photos/seed/charpente/300/200', 'date': '10 Juin 2025', 'caption': 'Charpente Toiture'},
      ],
    );
  }

  void addPhoto(String url) {
    final now = DateTime.now();
    final months = ['Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Juin', 'Juil', 'Août', 'Sep', 'Oct', 'Nov', 'Déc'];
    final dateStr = '${now.day} ${months[now.month - 1]} ${now.year}';
    
    final newPhoto = {
      'url': url,
      'date': dateStr,
      'caption': 'Nouvelle Photo'
    };

    state = DashboardData(
      overallProgress: state.overallProgress,
      tasksCompleted: state.tasksCompleted,
      tasksRemaining: state.tasksRemaining,
      projectDuration: state.projectDuration,
      completionTarget: state.completionTarget,
      tasks: state.tasks,
      budget: state.budget,
      photos: [...state.photos, newPhoto],
    );
  }
}

final entrepriseDashboardDataProvider = NotifierProvider<DashboardDataNotifier, DashboardData>(() {
  return DashboardDataNotifier();
});
