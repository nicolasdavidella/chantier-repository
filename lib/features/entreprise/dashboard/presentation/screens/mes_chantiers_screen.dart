import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../data/models/project_model.dart';
import '../../providers/entreprise_dashboard_providers.dart';
import 'chantier_detail_screen.dart';

class MesChantierScreen extends ConsumerStatefulWidget {
  const MesChantierScreen({super.key});

  @override
  ConsumerState<MesChantierScreen> createState() => _MesChantierScreenState();
}

class _MesChantierScreenState extends ConsumerState<MesChantierScreen> {
  String _selectedFilter = 'Tous';
  final _filters = ['Tous', 'en_cours', 'en_pause', 'termine', 'brouillon'];

  String _labelFor(String f) {
    switch (f) {
      case 'en_cours': return 'En cours';
      case 'en_pause': return 'En pause';
      case 'termine': return 'Terminé';
      case 'brouillon': return 'Brouillon';
      default: return 'Tous';
    }
  }

  Color _colorFor(String statut) {
    switch (statut) {
      case 'en_cours': return AppColors.secondary;
      case 'en_pause': return AppColors.warning;
      case 'termine': return AppColors.success;
      case 'brouillon': return AppColors.grey500;
      default: return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final projetsAsync = ref.watch(mesChantierProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Mes Chantiers', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filter chips
          Container(
            color: AppColors.primary,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Row(
                children: _filters.map((f) {
                  final selected = _selectedFilter == f;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(_labelFor(f)),
                      selected: selected,
                      onSelected: (_) => setState(() => _selectedFilter = f),
                      backgroundColor: Colors.white,
                      selectedColor: AppColors.secondary,
                      labelStyle: TextStyle(
                        color: selected ? Colors.white : AppColors.primary,
                        fontWeight: selected ? FontWeight.bold : FontWeight.w600,
                      ),
                      checkmarkColor: Colors.white,
                      side: BorderSide.none,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          // List
          Expanded(
            child: projetsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => _buildError(e.toString()),
              data: (projets) {
                final filtered = _selectedFilter == 'Tous'
                    ? projets
                    : projets.where((p) => p.statut == _selectedFilter).toList();
                if (filtered.isEmpty) return _buildEmpty();
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filtered.length,
                  itemBuilder: (ctx, i) =>
                      _ProjectCard(project: filtered[i], colorFor: _colorFor)
                          .animate()
                          .fadeIn(delay: Duration(milliseconds: 60 * i))
                          .slideY(begin: 0.1),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.construction_rounded, size: 72, color: AppColors.primary.withOpacity(0.3)),
            const SizedBox(height: 16),
            const Text('Aucun chantier trouvé',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimaryLight)),
            const SizedBox(height: 8),
            Text('Acceptez des projets depuis les appels d\'offres',
                style: TextStyle(color: AppColors.grey500), textAlign: TextAlign.center),
          ],
        ),
      );

  Widget _buildError(String e) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.error),
            const SizedBox(height: 12),
            Text('Erreur: $e', textAlign: TextAlign.center),
          ],
        ),
      );
}

class _ProjectCard extends StatelessWidget {
  final ProjectModel project;
  final Color Function(String) colorFor;

  const _ProjectCard({required this.project, required this.colorFor});

  @override
  Widget build(BuildContext context) {
    final imageUrl = project.listePlans.isNotEmpty ? project.listePlans.first : '';
    final ville = project.localisation['ville'] ?? '';
    final quartier = project.localisation['quartier'] ?? '';
    final statusColor = colorFor(project.statut);

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ChantierDetailScreen(project: project)),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.06),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              child: imageUrl.isNotEmpty
                  ? Image.network(imageUrl, height: 150, width: double.infinity, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _placeholder())
                  : _placeholder(),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(project.titre,
                            style: const TextStyle(
                                fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.textPrimaryLight)),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          project.statut.replaceAll('_', ' '),
                          style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.location_on_rounded, size: 14, color: AppColors.grey500),
                      const SizedBox(width: 4),
                      Text('$quartier, $ville',
                          style: TextStyle(fontSize: 13, color: AppColors.grey500)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.account_balance_wallet_rounded, size: 14, color: AppColors.primary),
                      const SizedBox(width: 4),
                      Text('${project.budgetPrevisionnel.toStringAsFixed(0)} FCFA',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary)),
                      const Spacer(),
                      const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.grey400),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() => Container(
        height: 150,
        color: AppColors.primary.withOpacity(0.08),
        child: const Center(child: Icon(Icons.construction_rounded, size: 48, color: AppColors.primary)),
      );
}
