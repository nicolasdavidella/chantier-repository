import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../data/models/rapport_avancement_model.dart';
import '../../providers/entreprise_dashboard_providers.dart';

class RapportsScreen extends ConsumerStatefulWidget {
  const RapportsScreen({super.key});

  @override
  ConsumerState<RapportsScreen> createState() => _RapportsScreenState();
}

class _RapportsScreenState extends ConsumerState<RapportsScreen> {
  String? _selectedProjectId;
  String _periodeFilter = '30j';
  final _dateFormat = DateFormat('dd MMM yyyy');

  @override
  Widget build(BuildContext context) {
    final projetsAsync = ref.watch(mesChantierStreamProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Rapports d\'Avancement', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: projetsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erreur: $e')),
        data: (projets) {
          if (projets.isEmpty) return _buildEmptyProjets();

          final actifs = projets.where((p) => p.statut == 'en_cours').toList();
          if (actifs.isEmpty) {
            return _buildEmptyProjets(message: 'Aucun chantier en cours');
          }

          // Select first by default
          _selectedProjectId ??= actifs.first.id;

          return Column(
            children: [
              // Filters bar
              Container(
                color: AppColors.primary,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  children: [
                    // Project selector
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: _selectedProjectId,
                        dropdownColor: Colors.white,
                        style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600),
                        underline: const SizedBox(),
                        icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.primary),
                        items: actifs.map((p) => DropdownMenuItem(
                          value: p.id,
                          child: Text(p.titre, overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: AppColors.primary)),
                        )).toList(),
                        onChanged: (v) => setState(() => _selectedProjectId = v),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Period filter
                    Row(
                      children: [
                        const Text('Période : ', style: TextStyle(color: Colors.white70, fontSize: 12)),
                        ...['7j', '30j', 'tout'].map((p) {
                          final sel = _periodeFilter == p;
                          return Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: GestureDetector(
                              onTap: () => setState(() => _periodeFilter = p),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: sel ? AppColors.secondary : Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(p,
                                    style: TextStyle(
                                        color: sel ? Colors.white : AppColors.primary,
                                        fontWeight: sel ? FontWeight.bold : FontWeight.w600,
                                        fontSize: 12)),
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ],
                ),
              ),

              // Reports for selected project
              Expanded(
                child: _selectedProjectId == null
                    ? _buildEmptyProjets()
                    : _RapportsList(
                        projectId: _selectedProjectId!,
                        periodeFilter: _periodeFilter,
                        dateFormat: _dateFormat,
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyProjets({String message = 'Aucun chantier trouvé'}) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bar_chart_rounded, size: 72, color: AppColors.primary.withOpacity(0.3)),
            const SizedBox(height: 16),
            Text(message,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimaryLight)),
            const SizedBox(height: 8),
            const Text('Les rapports d\'avancement apparaîtront ici',
                style: TextStyle(color: AppColors.grey500), textAlign: TextAlign.center),
          ],
        ),
      );
}

class _RapportsList extends ConsumerWidget {
  final String projectId;
  final String periodeFilter;
  final DateFormat dateFormat;

  const _RapportsList({
    required this.projectId,
    required this.periodeFilter,
    required this.dateFormat,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rapportsAsync = ref.watch(rapportsProjectStreamProvider(projectId));

    return rapportsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Erreur: $e')),
      data: (rapports) {
        // Filter by period
        final cutoff = periodeFilter == '7j'
            ? DateTime.now().subtract(const Duration(days: 7))
            : periodeFilter == '30j'
                ? DateTime.now().subtract(const Duration(days: 30))
                : DateTime(2000);

        final filtered = rapports.where((r) => r.date.isAfter(cutoff)).toList();

        if (filtered.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.description_outlined, size: 56, color: AppColors.grey300),
                const SizedBox(height: 16),
                const Text('Aucun rapport sur cette période',
                    style: TextStyle(fontSize: 16, color: AppColors.textSecondaryLight, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                const Text('Les rapports sont créés par le chef de chantier',
                    style: TextStyle(color: AppColors.grey500, fontSize: 13), textAlign: TextAlign.center),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: filtered.length,
          itemBuilder: (ctx, i) {
            final r = filtered[i];
            return _RapportCard(rapport: r, dateFormat: dateFormat)
                .animate()
                .fadeIn(delay: Duration(milliseconds: 50 * i))
                .slideY(begin: 0.05);
          },
        );
      },
    );
  }
}

class _RapportCard extends StatelessWidget {
  final RapportAvancementModel rapport;
  final DateFormat dateFormat;

  const _RapportCard({required this.rapport, required this.dateFormat});

  @override
  Widget build(BuildContext context) {
    final avancement = rapport.pourcentageAvancement;
    Color progressColor = avancement >= 80 ? AppColors.success : avancement >= 50 ? AppColors.secondary : AppColors.warning;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.05),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.assignment_rounded, color: Colors.white, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(dateFormat.format(rapport.date),
                          style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.textPrimaryLight)),
                      Text('Chef de chantier: ${rapport.chefChantierId}',
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryLight)),
                    ],
                  ),
                ),
                // Progress badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: progressColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text('${avancement.toInt()}%',
                      style: TextStyle(color: progressColor, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Progress bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: avancement / 100,
                    minHeight: 8,
                    backgroundColor: AppColors.grey200,
                    valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                  ),
                ),
                const SizedBox(height: 12),
                // Description
                Text(rapport.description,
                    style: const TextStyle(color: AppColors.textSecondaryLight, fontSize: 13, height: 1.5)),
                // Photos
                if (rapport.photos.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 70,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: rapport.photos.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 8),
                      itemBuilder: (_, i) => ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          rapport.photos[i],
                          width: 100, height: 70, fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => Container(
                            width: 100, height: 70,
                            color: AppColors.grey200,
                            child: const Icon(Icons.broken_image_rounded, color: AppColors.grey400),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
