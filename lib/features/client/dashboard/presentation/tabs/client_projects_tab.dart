import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../auth/providers/auth_provider.dart';
import '../../../projects/providers/client_projects_provider.dart';
import '../../../../../data/models/project_model.dart';
import '../../../../../data/repositories/project_repository.dart';
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
        return 'en_recherche_entreprise';
      case 'Terminés':
        return 'termine';
      default:
        return 'Tous';
    }
  }

  @override
  Widget build(BuildContext context) {
    final projectsAsync = ref.watch(clientProjectsProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Text(
          AppLocalizations.of(context)?.projectsTab ?? 'Mes Projets',
          style: const TextStyle(
            color: Color(0xFF143D2B),
            fontSize: 20,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.3,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Filtres en pilules avec nuances vertes
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: _filters.map((filter) {
                    final isSelected = _selectedFilter == filter;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedFilter = filter),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFF143D2B) : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected ? const Color(0xFF143D2B) : const Color(0xFFC8E6C9),
                              width: 1.2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: isSelected
                                    ? const Color(0xFF143D2B).withValues(alpha: 0.15)
                                    : Colors.black.withValues(alpha: 0.02),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            filter,
                            style: TextStyle(
                              color: isSelected ? Colors.white : const Color(0xFF64748B),
                              fontSize: 13,
                              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 16),

              Expanded(
                child: projectsAsync.when(
                  data: (projects) {
                    final statusFilter = _mapFilterToStatus(_selectedFilter);
                    final filteredProjects = _selectedFilter == 'Tous'
                        ? projects
                        : projects.where((p) => p.statut == statusFilter).toList();

                    if (filteredProjects.isEmpty) {
                      return Center(
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: const Color(0xFFC8E6C9)),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: const BoxDecoration(
                                  color: Color(0xFFE8F5E9),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.architecture_rounded,
                                  color: Color(0xFF143D2B),
                                  size: 40,
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Aucun projet dans cette catégorie',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                'Lancez NICO IA pour concevoir un nouveau plan ou créez un projet test.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 12.5,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                              const SizedBox(height: 18),
                              ElevatedButton.icon(
                                onPressed: () => _generateMockProjects(context, ref),
                                icon: const Icon(Icons.add_circle_outline, color: Colors.white, size: 18),
                                label: const Text(
                                  'Générer des chantiers tests',
                                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF143D2B),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.only(bottom: 90),
                      itemCount: filteredProjects.length,
                      itemBuilder: (context, index) {
                        final project = filteredProjects[index];
                        return _buildProjectCard(project, index);
                      },
                    );
                  },
                  loading: () => const Center(
                    child: CircularProgressIndicator(color: Color(0xFF10B981)),
                  ),
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
          heroTag: null,
          onPressed: () => context.push('/client/create_project'),
          backgroundColor: const Color(0xFF143D2B),
          elevation: 4,
          icon: const Icon(Icons.add_rounded, color: Colors.white, size: 20),
          label: const Text(
            'Nouveau projet',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13.5),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildProjectCard(ProjectModel project, int index) {
    final ville = project.localisation['ville'] ?? 'Cameroun';
    final quartier = project.localisation['quartier'] ?? '';
    final loc = quartier.isNotEmpty ? '$ville, $quartier' : ville;

    Color statusColor;
    String statusLabel;

    switch (project.statut) {
      case 'en_cours':
        statusColor = const Color(0xFF10B981);
        statusLabel = 'En cours';
        break;
      case 'termine':
        statusColor = const Color(0xFF3B82F6);
        statusLabel = 'Terminé';
        break;
      case 'en_recherche_entreprise':
      case 'brouillon_ia':
        statusColor = const Color(0xFFF59E0B);
        statusLabel = 'En recherche';
        break;
      default:
        statusColor = const Color(0xFF64748B);
        statusLabel = project.statut;
        break;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: InkWell(
        onTap: () => context.push('/client/project_detail', extra: project),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFFC8E6C9),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF143D2B).withValues(alpha: 0.05),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF81C784).withValues(alpha: 0.4)),
                ),
                child: const Center(
                  child: Icon(
                    Icons.apartment_rounded,
                    color: Color(0xFF143D2B),
                    size: 26,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            project.titre,
                            style: const TextStyle(
                              fontSize: 15.5,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            statusLabel,
                            style: TextStyle(
                              color: statusColor,
                              fontSize: 10.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 13, color: Color(0xFF64748B)),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            loc,
                            style: const TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${(project.budgetPrevisionnel).toStringAsFixed(0)} FCFA',
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF143D2B),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFEF4444), size: 20),
                onPressed: () => _confirmDeleteProject(context, ref, project),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, color: Color(0xFF81C784), size: 14),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(delay: (index * 60).ms, duration: 350.ms).slideY(begin: 0.05);
  }

  Future<void> _confirmDeleteProject(BuildContext context, WidgetRef ref, ProjectModel project) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text(
            'Supprimer le projet',
            style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
          ),
          content: Text('Voulez-vous vraiment supprimer le projet "${project.titre}" ?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Annuler', style: TextStyle(color: Color(0xFF64748B))),
            ),
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              style: FilledButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
              child: const Text('Supprimer'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      try {
        await ref.read(projectRepositoryProvider).delete(project.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: Color(0xFF143D2B),
              content: Text('Projet supprimé avec succès.'),
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e')));
        }
      }
    }
  }

  Future<void> _generateMockProjects(BuildContext context, WidgetRef ref) async {
    try {
      final user = ref.read(authStateProvider).value;
      if (user == null) return;

      final firestore = FirebaseFirestore.instance;

      final mockProjects = [
        ProjectModel(
          id: firestore.collection('projects').doc().id,
          clientId: user.uid,
          titre: 'Villa Contemporaine Bastos',
          description: 'Construction d\'une villa contemporaine 4 chambres avec piscine',
          localisation: {'ville': 'Yaoundé', 'quartier': 'Bastos'},
          budgetPrevisionnel: 75000000,
          budgetActuel: 25000000,
          dateDebut: DateTime.now().subtract(const Duration(days: 30)),
          dateFinPrevue: DateTime.now().add(const Duration(days: 150)),
          statut: 'en_cours',
          listePlans: [],
          listeDocuments: [],
        ),
        ProjectModel(
          id: firestore.collection('projects').doc().id,
          clientId: user.uid,
          titre: 'Duplex Moderne Bonapriso',
          description: 'Duplex moderne R+1 avec garage et terrasse',
          localisation: {'ville': 'Douala', 'quartier': 'Bonapriso'},
          budgetPrevisionnel: 45000000,
          budgetActuel: 10000000,
          dateDebut: DateTime.now().subtract(const Duration(days: 10)),
          dateFinPrevue: DateTime.now().add(const Duration(days: 90)),
          statut: 'en_cours',
          listePlans: [],
          listeDocuments: [],
        ),
        ProjectModel(
          id: firestore.collection('projects').doc().id,
          clientId: user.uid,
          titre: 'Résidence Kribi Bord de Mer',
          description: 'Résidence de vacances avec jardin paysager',
          localisation: {'ville': 'Kribi', 'quartier': 'Plage'},
          budgetPrevisionnel: 95000000,
          budgetActuel: 0,
          dateDebut: DateTime.now().add(const Duration(days: 15)),
          dateFinPrevue: DateTime.now().add(const Duration(days: 300)),
          statut: 'en_recherche_entreprise',
          listePlans: [],
          listeDocuments: [],
        ),
      ];

      for (var p in mockProjects) {
        await firestore.collection('projects').doc(p.id).set(p.toJson());
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Color(0xFF143D2B),
            content: Text('Projets de test générés avec succès !'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur : $e')));
      }
    }
  }
}
