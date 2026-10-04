import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../data/models/project_model.dart';
import '../../providers/entreprise_dashboard_providers.dart';
import 'chantier_detail_screen.dart';

class MesChantierScreen extends ConsumerStatefulWidget {
  final String initialFilter;
  const MesChantierScreen({super.key, this.initialFilter = 'Tous'});

  @override
  ConsumerState<MesChantierScreen> createState() => _MesChantierScreenState();
}

class _MesChantierScreenState extends ConsumerState<MesChantierScreen> {
  late String _selectedFilter;
  final _filters = ['Tous', 'en_cours', 'en_pause', 'termine', 'brouillon'];

  @override
  void initState() {
    super.initState();
    _selectedFilter = widget.initialFilter;
  }

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
    final projetsAsync = ref.watch(mesChantierStreamProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFFAF8F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF143D2B),
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Mes Chantiers', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white)),
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Background glow
          Positioned(
            top: 20,
            right: -60,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFE8F5E9).withValues(alpha: 0.8),
                    const Color(0xFFE8F5E9).withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Filter chips
              Container(
                color: const Color(0xFF143D2B),
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
                          selectedColor: const Color(0xFF10B981),
                          labelStyle: TextStyle(
                            color: selected ? Colors.white : const Color(0xFF143D2B),
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                          ),
                          checkmarkColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: selected ? const Color(0xFF10B981) : const Color(0xFFC8E6C9),
                              width: 1.2,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              // List
              Expanded(
                child: projetsAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF143D2B))),
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
        ],
      ),
    );
  }

  Widget _buildEmpty() => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFFE8F5E9),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.construction_rounded, size: 54, color: Color(0xFF143D2B)),
            ),
            const SizedBox(height: 16),
            const Text(
              'Aucun chantier trouvé',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF143D2B)),
            ),
            const SizedBox(height: 8),
            const Text(
              'Acceptez des projets depuis les appels d\'offres pour débuter.',
              style: TextStyle(color: AppColors.textSecondaryLight, fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );

  Widget _buildError(String e) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded, size: 48, color: AppColors.error),
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
          border: Border.all(color: const Color(0xFFC8E6C9), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF143D2B).withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
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
                      errorBuilder: (_, _, _) => _placeholder())
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
                        child: Text(
                          project.titre,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF143D2B),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFC8E6C9), width: 1),
                        ),
                        child: Text(
                          project.statut.replaceAll('_', ' ').toUpperCase(),
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.location_on_rounded, size: 14, color: Color(0xFF10B981)),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '$quartier, $ville',
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryLight, fontWeight: FontWeight.w600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.account_balance_wallet_rounded, size: 14, color: Color(0xFF143D2B)),
                      const SizedBox(width: 4),
                      Text(
                        '${project.budgetPrevisionnel.toStringAsFixed(0)} FCFA',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF143D2B)),
                      ),
                      const Spacer(),
                      const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Color(0xFF10B981)),
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
        color: const Color(0xFF143D2B),
        child: const Center(
          child: Icon(Icons.home_work_rounded, size: 48, color: Color(0xFF86EFAC)),
        ),
      );
}
