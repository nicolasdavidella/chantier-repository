import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../data/models/project_model.dart';
import '../../../../../data/models/tache_model.dart';
import '../../providers/entreprise_dashboard_providers.dart';

class ChantierDetailScreen extends ConsumerStatefulWidget {
  final ProjectModel project;
  const ChantierDetailScreen({super.key, required this.project});

  @override
  ConsumerState<ChantierDetailScreen> createState() => _ChantierDetailScreenState();
}

class _ChantierDetailScreenState extends ConsumerState<ChantierDetailScreen> {
  final _dateFormat = DateFormat('dd/MM/yyyy');

  Color _statusColor(String s) {
    switch (s) {
      case 'terminee': return AppColors.success;
      case 'en_cours': return AppColors.secondary;
      case 'en_retard': return AppColors.error;
      default: return AppColors.grey400;
    }
  }

  String _statusLabel(String s) {
    switch (s) {
      case 'a_faire': return 'À faire';
      case 'en_cours': return 'En cours';
      case 'terminee': return 'Terminée';
      case 'en_retard': return 'En retard';
      default: return s;
    }
  }

  void _openAddTacheDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddTacheSheet(projectId: widget.project.id),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tachesAsync = ref.watch(tachesProjectStreamProvider(widget.project.id));
    final p = widget.project;
    final ville = p.localisation['ville'] ?? '';
    final quartier = p.localisation['quartier'] ?? '';

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(p.titre, style: const TextStyle(fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddTacheDialog,
        backgroundColor: AppColors.secondary,
        icon: const Icon(Icons.add_task_rounded, color: Colors.white),
        label: const Text('Nouvelle tâche', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.location_on_rounded, color: Colors.white70, size: 16),
                      const SizedBox(width: 4),
                      Text('$quartier, $ville', style: const TextStyle(color: Colors.white70, fontSize: 13)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(p.description,
                      style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.4),
                      maxLines: 3, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _InfoChip(Icons.account_balance_wallet_rounded,
                          '${(p.budgetPrevisionnel / 1000).toStringAsFixed(0)}k FCFA'),
                      _InfoChip(Icons.calendar_today_rounded,
                          'Fin: ${_dateFormat.format(p.dateFinPrevue)}'),
                    ],
                  ),
                ],
              ),
            ).animate().fadeIn().slideY(begin: -0.05),

            const SizedBox(height: 24),

            // Tâches
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Tâches du chantier',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.textPrimaryLight)),
                tachesAsync.when(
                  data: (taches) {
                    final done = taches.where((t) => t.statut == 'terminee').length;
                    return Text('$done/${taches.length}',
                        style: const TextStyle(color: AppColors.secondary, fontWeight: FontWeight.bold, fontSize: 14));
                  },
                  loading: () => const SizedBox(),
                  error: (_, __) => const SizedBox(),
                ),
              ],
            ),
            const SizedBox(height: 12),

            tachesAsync.when(
              loading: () => const Center(child: Padding(
                padding: EdgeInsets.all(32),
                child: CircularProgressIndicator(),
              )),
              error: (e, _) => Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.errorLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text('Erreur: $e', style: const TextStyle(color: AppColors.error)),
              ),
              data: (taches) {
                if (taches.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.task_alt_rounded, size: 48, color: AppColors.primary.withOpacity(0.3)),
                        const SizedBox(height: 12),
                        const Text('Aucune tâche pour ce chantier',
                            style: TextStyle(color: AppColors.textSecondaryLight)),
                        const SizedBox(height: 8),
                        const Text('Utilisez le bouton + pour créer la première tâche',
                            style: TextStyle(color: AppColors.grey500, fontSize: 12),
                            textAlign: TextAlign.center),
                      ],
                    ),
                  );
                }

                // Progress
                final done = taches.where((t) => t.statut == 'terminee').length;
                final progress = taches.isEmpty ? 0.0 : done / taches.length;

                return Column(
                  children: [
                    // Progress bar
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.05), blurRadius: 10)],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Avancement', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimaryLight)),
                              Text('${(progress * 100).toInt()}%',
                                  style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.secondary, fontSize: 16)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: progress,
                              minHeight: 10,
                              backgroundColor: AppColors.grey200,
                              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.secondary),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...taches.asMap().entries.map((entry) {
                      final i = entry.key;
                      final t = entry.value;
                      return _TacheCard(
                        tache: t,
                        statusColor: _statusColor(t.statut),
                        statusLabel: _statusLabel(t.statut),
                        dateFormat: _dateFormat,
                        projectId: widget.project.id,
                      ).animate().fadeIn(delay: Duration(milliseconds: 50 * i)).slideY(begin: 0.1);
                    }),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoChip(this.icon, this.label);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.white70),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _TacheCard extends ConsumerWidget {
  final TacheModel tache;
  final Color statusColor;
  final String statusLabel;
  final DateFormat dateFormat;
  final String projectId;

  const _TacheCard({
    required this.tache,
    required this.statusColor,
    required this.statusLabel,
    required this.dateFormat,
    required this.projectId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          // Status indicator
          GestureDetector(
            onTap: () {
              final nextStatut = tache.statut == 'terminee' ? 'a_faire' : 'terminee';
              ref.read(tacheControllerProvider.notifier).updateStatut(projectId, tache.id, nextStatut);
            },
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.12),
                shape: BoxShape.circle,
                border: Border.all(color: statusColor, width: 2),
              ),
              child: tache.statut == 'terminee'
                  ? Icon(Icons.check_rounded, size: 16, color: statusColor)
                  : const SizedBox(),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tache.titre,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimaryLight,
                      decoration: tache.statut == 'terminee' ? TextDecoration.lineThrough : null,
                    )),
                if (tache.description.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(tache.description,
                      style: const TextStyle(fontSize: 12, color: AppColors.grey500),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.person_outline_rounded, size: 12, color: AppColors.grey400),
                    const SizedBox(width: 2),
                    Text(tache.responsable, style: const TextStyle(fontSize: 11, color: AppColors.grey500)),
                    const SizedBox(width: 8),
                    const Icon(Icons.calendar_today_outlined, size: 12, color: AppColors.grey400),
                    const SizedBox(width: 2),
                    Text(dateFormat.format(tache.dateFinPrevue),
                        style: const TextStyle(fontSize: 11, color: AppColors.grey500)),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(statusLabel,
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: statusColor)),
          ),
        ],
      ),
    );
  }
}

// ─── Add Tache Sheet ─────────────────────────────────
class _AddTacheSheet extends ConsumerStatefulWidget {
  final String projectId;
  const _AddTacheSheet({required this.projectId});

  @override
  ConsumerState<_AddTacheSheet> createState() => _AddTacheSheetState();
}

class _AddTacheSheetState extends ConsumerState<_AddTacheSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titreCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _responsableCtrl = TextEditingController();
  DateTime _dateDebut = DateTime.now();
  DateTime _dateFin = DateTime.now().add(const Duration(days: 7));
  String _priorite = 'normale';

  @override
  void dispose() {
    _titreCtrl.dispose();
    _descCtrl.dispose();
    _responsableCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final tache = TacheModel(
      id: '',
      projectId: widget.projectId,
      titre: _titreCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      statut: 'a_faire',
      dateDebutPrevue: _dateDebut,
      dateFinPrevue: _dateFin,
      responsable: _responsableCtrl.text.trim(),
      ordre: DateTime.now().millisecondsSinceEpoch,
    );
    try {
      await ref.read(tacheControllerProvider.notifier).createTache(tache);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(children: [
              Icon(Icons.check_circle_rounded, color: Colors.white),
              SizedBox(width: 8),
              Text('Tâche créée avec succès'),
            ]),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(tacheControllerProvider).isLoading;
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(color: AppColors.grey300, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Nouvelle Tâche',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.textPrimaryLight)),
              const SizedBox(height: 20),

              TextFormField(
                controller: _titreCtrl,
                decoration: _inputDeco('Titre de la tâche', Icons.task_alt_rounded),
                validator: (v) => v == null || v.isEmpty ? 'Requis' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descCtrl,
                decoration: _inputDeco('Description (optionnel)', Icons.description_rounded),
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _responsableCtrl,
                decoration: _inputDeco('Responsable', Icons.person_rounded),
                validator: (v) => v == null || v.isEmpty ? 'Requis' : null,
              ),
              const SizedBox(height: 16),

              // Dates
              Row(
                children: [
                  Expanded(
                    child: _DatePicker(
                      label: 'Début',
                      date: _dateDebut,
                      onPicked: (d) => setState(() => _dateDebut = d),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _DatePicker(
                      label: 'Fin prévue',
                      date: _dateFin,
                      onPicked: (d) => setState(() => _dateFin = d),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Priorité chips
              const Text('Priorité', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimaryLight)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: ['basse', 'normale', 'haute', 'urgente'].map((p) {
                  final selected = _priorite == p;
                  Color c = p == 'urgente' ? AppColors.error :
                             p == 'haute' ? AppColors.warning :
                             p == 'normale' ? AppColors.secondary : AppColors.grey400;
                  return FilterChip(
                    label: Text(p[0].toUpperCase() + p.substring(1)),
                    selected: selected,
                    onSelected: (_) => setState(() => _priorite = p),
                    selectedColor: c.withOpacity(0.15),
                    labelStyle: TextStyle(color: selected ? c : AppColors.grey600, fontWeight: selected ? FontWeight.bold : FontWeight.normal),
                    side: BorderSide(color: selected ? c : AppColors.grey300),
                    checkmarkColor: c,
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: isLoading
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Créer la tâche',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDeco(String hint, IconData icon) => InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
        filled: true,
        fillColor: AppColors.backgroundLight,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.primary)),
      );
}

class _DatePicker extends StatelessWidget {
  final String label;
  final DateTime date;
  final ValueChanged<DateTime> onPicked;

  const _DatePicker({required this.label, required this.date, required this.onPicked});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: date,
          firstDate: DateTime(2020),
          lastDate: DateTime(2030),
        );
        if (picked != null) onPicked(picked);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.backgroundLight,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_rounded, size: 16, color: AppColors.primary),
            const SizedBox(width: 6),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 10, color: AppColors.grey500)),
                Text(DateFormat('dd/MM/yy').format(date),
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimaryLight)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
