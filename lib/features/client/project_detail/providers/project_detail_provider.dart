import 'package:flutter_riverpod/flutter_riverpod.dart';

// --- MODELS ---

class ProjectReportModel {
  final String id;
  final DateTime date;
  final String title;
  final String description;
  final double avancementPercent;
  final List<String> photos;

  ProjectReportModel({
    required this.id,
    required this.date,
    required this.title,
    required this.description,
    required this.avancementPercent,
    required this.photos,
  });
}

class ProjectExpenseModel {
  final String id;
  final DateTime date;
  final String category;
  final String description;
  final double amount;
  final bool isAnomaly;

  ProjectExpenseModel({
    required this.id,
    required this.date,
    required this.category,
    required this.description,
    required this.amount,
    this.isAnomaly = false,
  });
}

class ProjectAlertModel {
  final String id;
  final DateTime date;
  final String title;
  final String description;
  final String severity; // 'info', 'warning', 'critical'
  final String type; // 'finance', 'delai', 'qualite'
  final bool isRead;

  ProjectAlertModel({
    required this.id,
    required this.date,
    required this.title,
    required this.description,
    required this.severity,
    required this.type,
    this.isRead = false,
  });
  
  ProjectAlertModel copyWith({bool? isRead}) {
    return ProjectAlertModel(
      id: id,
      date: date,
      title: title,
      description: description,
      severity: severity,
      type: type,
      isRead: isRead ?? this.isRead,
    );
  }
}

class ProjectDocumentModel {
  final String id;
  final String name;
  final String type; // 'pdf', 'image', 'doc'
  final DateTime dateAjout;
  final String size;

  ProjectDocumentModel({
    required this.id,
    required this.name,
    required this.type,
    required this.dateAjout,
    required this.size,
  });
}

// --- MOCK DATA PROVIDERS ---

final projectReportsProvider = Provider.family<List<ProjectReportModel>, String>((ref, projectId) {
  return [
    ProjectReportModel(
      id: 'r1',
      date: DateTime.now().subtract(const Duration(days: 2)),
      title: 'Coulage de la dalle',
      description: 'La dalle du rez-de-chaussée a été coulée avec succès. Le temps de séchage est respecté.',
      avancementPercent: 35.0,
      photos: [
        'https://picsum.photos/seed/dalle-rdc/600/400',
        'https://picsum.photos/seed/coffrage/600/400',
      ],
    ),
    ProjectReportModel(
      id: 'r2',
      date: DateTime.now().subtract(const Duration(days: 15)),
      title: 'Fondations terminées',
      description: 'Les fondations sont achevées, prêtes pour l\'élévation des murs.',
      avancementPercent: 20.0,
      photos: [
        'https://picsum.photos/seed/fondations-fin/600/400',
      ],
    ),
    ProjectReportModel(
      id: 'r3',
      date: DateTime.now().subtract(const Duration(days: 30)),
      title: 'Préparation du terrain',
      description: 'Défrichage et terrassement terminés.',
      avancementPercent: 5.0,
      photos: [],
    ),
  ];
});

final projectExpensesProvider = Provider.family<List<ProjectExpenseModel>, String>((ref, projectId) {
  return [
    ProjectExpenseModel(id: 'e1', date: DateTime.now().subtract(const Duration(days: 1)), category: 'Matériaux', description: 'Ciment et Fer', amount: 1500000),
    ProjectExpenseModel(id: 'e2', date: DateTime.now().subtract(const Duration(days: 5)), category: 'Main d\'oeuvre', description: 'Paiement ouvriers Semaine 4', amount: 350000),
    ProjectExpenseModel(id: 'e3', date: DateTime.now().subtract(const Duration(days: 12)), category: 'Matériaux', description: 'Achat sable (prix anormalement élevé selon moyenne IA)', amount: 600000, isAnomaly: true),
    ProjectExpenseModel(id: 'e4', date: DateTime.now().subtract(const Duration(days: 20)), category: 'Logistique', description: 'Location pelleteuse', amount: 450000),
  ];
});

class AlertsNotifier extends StateNotifier<List<ProjectAlertModel>> {
  AlertsNotifier() : super([
    ProjectAlertModel(
      id: 'a1',
      date: DateTime.now().subtract(const Duration(hours: 2)),
      title: 'Risque de dépassement budgétaire',
      description: 'Les dépenses en matériaux ont dépassé les prévisions de 15% ce mois-ci.',
      severity: 'warning',
      type: 'finance',
    ),
    ProjectAlertModel(
      id: 'a2',
      date: DateTime.now().subtract(const Duration(days: 2)),
      title: 'Prix matériaux anormal',
      description: 'Le prix du sable acheté le 10 Août est 30% supérieur à la moyenne du marché dans cette zone.',
      severity: 'critical',
      type: 'finance',
    ),
    ProjectAlertModel(
      id: 'a3',
      date: DateTime.now().subtract(const Duration(days: 5)),
      title: 'Météo défavorable',
      description: 'De fortes pluies sont prévues la semaine prochaine, risque de retard sur le gros œuvre.',
      severity: 'info',
      type: 'delai',
    ),
  ]);

  void markAsRead(String id) {
    state = [
      for (final alert in state)
        if (alert.id == id) alert.copyWith(isRead: true) else alert
    ];
  }
}

final projectAlertsProvider = StateNotifierProvider.family<AlertsNotifier, List<ProjectAlertModel>, String>((ref, projectId) {
  return AlertsNotifier();
});

final projectDocumentsProvider = Provider.family<List<ProjectDocumentModel>, String>((ref, projectId) {
  return [
    ProjectDocumentModel(id: 'd1', name: 'Permis_de_construire.pdf', type: 'pdf', dateAjout: DateTime.now().subtract(const Duration(days: 45)), size: '2.4 MB'),
    ProjectDocumentModel(id: 'd2', name: 'Devis_initial_signé.pdf', type: 'pdf', dateAjout: DateTime.now().subtract(const Duration(days: 50)), size: '1.1 MB'),
    ProjectDocumentModel(id: 'd3', name: 'Plan_architectural_V2.png', type: 'image', dateAjout: DateTime.now().subtract(const Duration(days: 30)), size: '5.6 MB'),
    ProjectDocumentModel(id: 'd4', name: 'Contrat_BatiCam.doc', type: 'doc', dateAjout: DateTime.now().subtract(const Duration(days: 48)), size: '840 KB'),
  ];
});
