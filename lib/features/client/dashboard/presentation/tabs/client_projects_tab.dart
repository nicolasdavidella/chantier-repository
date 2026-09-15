import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../auth/providers/auth_provider.dart';
import '../../../projects/providers/client_projects_provider.dart';
import '../../../../../data/models/project_model.dart';
import 'package:chantier_track/l10n/app_localizations.dart';

class ClientProjectsTab extends ConsumerStatefulWidget {
  const ClientProjectsTab({super.key});

  @override
  ConsumerState<ClientProjectsTab> createState() => _ClientProjectsTabState();
}

class _ClientProjectsTabState extends ConsumerState<ClientProjectsTab> {
  String _selectedFilter = 'Tous';
  final List<String> _filters = ['Tous', 'En cours', 'En attente', 'Terminés'];

  String _mapFilterToStatus(String filter) {
    switch (filter) {
      case 'En cours':
        return 'en_cours';
      case 'En attente':
        return 'en_recherche_entreprise'; // Ou "brouillon" ou autre status d'attente
      case 'Terminés':
        return 'termine';
      default:
        return 'Tous';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final projectsAsync = ref.watch(clientProjectsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)?.projectsTab ?? 'Mes Projets'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.filter, size: 20),
            onPressed: () {},
          )
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Tabs for project status
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _filters.map((filter) {
                    return Padding(
                      padding: const EdgeInsets.only(right: AppSpacing.sm),
                      child: _buildFilterChip(theme, filter, _selectedFilter == filter),
                    );
                  }).toList(),
                ),
              ),
              AppSpacing.vLg,
              Expanded(
                child: projectsAsync.when(
                  data: (projects) {
                    // Filtrage des projets
                    final statusFilter = _mapFilterToStatus(_selectedFilter);
                    final filteredProjects = _selectedFilter == 'Tous' 
                        ? projects 
                        : projects.where((p) => p.statut == statusFilter).toList();

                    if (filteredProjects.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('Aucun projet trouvé dans cette catégorie.'),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: () => _generateMockProjects(context, ref),
                              icon: const Icon(Icons.add_circle_outline),
                              label: const Text('Générer des projets de test'),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: filteredProjects.length,
                      itemBuilder: (context, index) {
                        final project = filteredProjects[index];
                        return _buildProjectCard(theme, project);
                      },
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, stack) => Center(child: Text('Erreur: $err')),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 80.0),
        child: FloatingActionButton.extended(
          onPressed: () {
            context.push('/client/create_project');
          },
          backgroundColor: theme.colorScheme.primary,
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text('Nouveau projet', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildProjectCard(ThemeData theme, ProjectModel project) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: InkWell(
        onTap: () {
          // Navigation vers les détails du projet
          context.push('/client/project_detail', extra: project);
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: FaIcon(FontAwesomeIcons.building, color: theme.colorScheme.primary),
                ),
              ),
              AppSpacing.hLg,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(project.titre, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    AppSpacing.vXs,
                    Text('${project.localisation['ville'] ?? ''}, ${project.localisation['quartier'] ?? ''}', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                    AppSpacing.vXs,
                    Text('Statut: ${project.statut}', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.primary)),
                  ],
                ),
              ),
              const FaIcon(FontAwesomeIcons.chevronRight, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(ThemeData theme, String label, bool isSelected) {
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) {
        setState(() {
          _selectedFilter = label;
        });
      },
      backgroundColor: theme.colorScheme.surface,
      selectedColor: theme.colorScheme.primary,
      labelStyle: TextStyle(
        color: isSelected ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
    );
  }

  Future<void> _generateMockProjects(BuildContext context, WidgetRef ref) async {
    try {
      final user = ref.read(authStateProvider).value;
      if (user == null) return;

      final firestore = FirebaseFirestore.instance;
      
      final mockProjects = [
        ProjectModel(
          id: firestore.collection('projets').doc().id,
          clientId: user.uid,
          titre: 'Villa Horizon',
          description: 'Construction d\'une villa R+1 avec piscine',
          localisation: {'ville': 'Dakar', 'quartier': 'Almadies'},
          budgetPrevisionnel: 150000000,
          budgetActuel: 45000000,
          dateDebut: DateTime.now().subtract(const Duration(days: 30)),
          dateFinPrevue: DateTime.now().add(const Duration(days: 150)),
          statut: 'en_cours',
          listePlans: ['https://picsum.photos/seed/projet-villa/1000/700'],
          listeDocuments: [],
        ),
        ProjectModel(
          id: firestore.collection('projets').doc().id,
          clientId: user.uid,
          titre: 'Rénovation Appartement',
          description: 'Rénovation complète d\'un T4',
          localisation: {'ville': 'Dakar', 'quartier': 'Plateau'},
          budgetPrevisionnel: 25000000,
          budgetActuel: 5000000,
          dateDebut: DateTime.now().subtract(const Duration(days: 10)),
          dateFinPrevue: DateTime.now().add(const Duration(days: 45)),
          statut: 'en_cours',
          listePlans: [],
          listeDocuments: [],
        ),
        ProjectModel(
          id: firestore.collection('projets').doc().id,
          clientId: user.uid,
          titre: 'Immeuble Commercial',
          description: 'Construction R+4 usage mixte',
          localisation: {'ville': 'Dakar', 'quartier': 'Ngor'},
          budgetPrevisionnel: 350000000,
          budgetActuel: 0,
          dateDebut: DateTime.now().add(const Duration(days: 15)),
          dateFinPrevue: DateTime.now().add(const Duration(days: 365)),
          statut: 'en_recherche_entreprise',
          listePlans: [],
          listeDocuments: [],
        ),
      ];

      for (var p in mockProjects) {
        await firestore.collection('projets').doc(p.id).set(p.toJson());
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Projets de test générés avec succès !')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur : $e')));
      }
    }
  }
}
