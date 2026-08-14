import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AnalyticsPeriod { days7, days30, days90, all }

class AnalyticsPeriodNotifier extends StateNotifier<AnalyticsPeriod> {
  AnalyticsPeriodNotifier() : super(AnalyticsPeriod.days30);

  void setPeriod(AnalyticsPeriod period) {
    state = period;
  }
}

final analyticsPeriodProvider = StateNotifierProvider<AnalyticsPeriodNotifier, AnalyticsPeriod>((ref) {
  return AnalyticsPeriodNotifier();
});

// Mock providers pour les graphiques afin de réagir au changement de période
// Dans la réalité, ces providers iraient lire dans Firestore en fonction des dates.

final entrepriseRevenueProvider = Provider<List<double>>((ref) {
  final period = ref.watch(analyticsPeriodProvider);
  switch (period) {
    case AnalyticsPeriod.days7:
      return [120000, 50000, 300000, 0, 80000, 450000, 100000];
    case AnalyticsPeriod.days30:
      // Simulé par semaine
      return [450000, 1200000, 800000, 2100000];
    case AnalyticsPeriod.days90:
      // Simulé par mois
      return [3500000, 4200000, 5100000];
    case AnalyticsPeriod.all:
      return [12000000, 15000000, 18000000, 25000000, 32000000];
  }
});

final entrepriseConversionProvider = Provider<Map<String, double>>((ref) {
  final period = ref.watch(analyticsPeriodProvider);
  // Retourne pourcentage [Acceptés, Refusés, En attente]
  switch (period) {
    case AnalyticsPeriod.days7:
      return {'acceptes': 20, 'refuses': 30, 'attente': 50};
    case AnalyticsPeriod.days30:
      return {'acceptes': 45, 'refuses': 35, 'attente': 20};
    case AnalyticsPeriod.days90:
      return {'acceptes': 60, 'refuses': 30, 'attente': 10};
    case AnalyticsPeriod.all:
      return {'acceptes': 65, 'refuses': 25, 'attente': 10};
  }
});

// Provider pour les délais: List de [Délai Prévu (jours), Délai Réel (jours)]
final entrepriseDelayProvider = Provider<List<List<double>>>((ref) {
  final period = ref.watch(analyticsPeriodProvider);
  switch (period) {
    case AnalyticsPeriod.days7:
      return [[10, 11], [5, 5], [14, 16], [8, 7]];
    case AnalyticsPeriod.days30:
      return [[20, 22], [30, 28], [15, 18], [10, 10], [45, 50]];
    case AnalyticsPeriod.days90:
      return [[60, 65], [45, 40], [30, 35], [90, 85], [120, 130]];
    case AnalyticsPeriod.all:
      return [[60, 65], [45, 40], [30, 35], [90, 85], [120, 130], [200, 210]];
  }
});

// Provider pour les zones (HeatMap): List de {zone: string, intensite: double (0-1)}
final entrepriseZonesProvider = Provider<List<Map<String, dynamic>>>((ref) {
  return [
    {'zone': 'Douala - Akwa', 'intensite': 0.9},
    {'zone': 'Douala - Bonanjo', 'intensite': 0.7},
    {'zone': 'Yaoundé - Bastos', 'intensite': 0.8},
    {'zone': 'Yaoundé - Biyem-Assi', 'intensite': 0.4},
    {'zone': 'Bafoussam', 'intensite': 0.2},
  ];
});

// --- ADMIN MOCKS --- //

// Croissance des utilisateurs: List de [Clients, Entreprises, Chefs de chantier]
final adminUserGrowthProvider = Provider<List<List<double>>>((ref) {
  final period = ref.watch(analyticsPeriodProvider);
  switch (period) {
    case AnalyticsPeriod.days7:
      return [[100, 20, 15], [105, 21, 15], [110, 21, 16], [112, 22, 16]];
    case AnalyticsPeriod.days30:
      return [[80, 15, 10], [100, 20, 15], [150, 25, 20], [210, 35, 25]];
    case AnalyticsPeriod.days90:
      return [[50, 10, 5], [100, 20, 15], [210, 35, 25]];
    case AnalyticsPeriod.all:
      return [[10, 2, 1], [50, 10, 5], [210, 35, 25], [500, 80, 60]];
  }
});

// Volume financier total: List de double
final adminFinancialVolumeProvider = Provider<List<double>>((ref) {
  final period = ref.watch(analyticsPeriodProvider);
  switch (period) {
    case AnalyticsPeriod.days7:
      return [1.2, 1.5, 0.8, 2.1, 1.8, 2.5, 3.0]; // en millions
    case AnalyticsPeriod.days30:
      return [10.5, 12.0, 15.5, 18.2];
    case AnalyticsPeriod.days90:
      return [45.0, 52.0, 61.5];
    case AnalyticsPeriod.all:
      return [150.0, 210.0, 340.5, 520.0];
  }
});

// Taux d'alertes IA: Map<Gravité, Pourcentage>
final adminAiAlertsProvider = Provider<Map<String, double>>((ref) {
  final period = ref.watch(analyticsPeriodProvider);
  switch (period) {
    case AnalyticsPeriod.days7:
      return {'Critique': 5, 'Majeure': 15, 'Mineure': 80};
    case AnalyticsPeriod.days30:
      return {'Critique': 8, 'Majeure': 22, 'Mineure': 70};
    case AnalyticsPeriod.days90:
      return {'Critique': 10, 'Majeure': 30, 'Mineure': 60};
    case AnalyticsPeriod.all:
      return {'Critique': 12, 'Majeure': 28, 'Mineure': 60};
  }
});

// Classement des entreprises (Ne dépend pas forcément de la période pour le mockup)
final adminTopEntreprisesProvider = Provider<List<Map<String, dynamic>>>((ref) {
  return [
    {'nom': 'BatiPlus SARL', 'note': 4.9, 'projets': 124, 'avatar': 'B'},
    {'nom': 'ConstrucTech', 'note': 4.8, 'projets': 98, 'avatar': 'C'},
    {'nom': 'Menuiserie Etoile', 'note': 4.7, 'projets': 210, 'avatar': 'M'},
    {'nom': 'Plomberie Express', 'note': 4.6, 'projets': 45, 'avatar': 'P'},
  ];
});
