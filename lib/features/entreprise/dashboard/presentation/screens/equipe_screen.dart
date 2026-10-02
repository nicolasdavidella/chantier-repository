import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../data/models/membre_equipe_model.dart';
import '../../providers/entreprise_dashboard_providers.dart';

class EquipeScreen extends ConsumerWidget {
  const EquipeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final membresAsync = ref.watch(membresEquipeProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Mon Équipe', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddMemberSheet(context, ref),
        backgroundColor: AppColors.secondary,
        icon: const Icon(Icons.person_add_rounded, color: Colors.white),
        label: const Text('Ajouter', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: membresAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erreur: $e')),
        data: (membres) {
          if (membres.isEmpty) return _buildEmpty();

          // Group by métier
          final grouped = <String, List<MembreEquipeModel>>{};
          for (final m in membres) {
            grouped.putIfAbsent(m.metier, () => []).add(m);
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            children: grouped.entries.map((entry) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Group header
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8, top: 8),
                    child: Row(
                      children: [
                        Container(
                          width: 4, height: 18,
                          decoration: BoxDecoration(
                            color: AppColors.secondary,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(entry.key,
                            style: const TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimaryLight)),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text('${entry.value.length}',
                              style: const TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary)),
                        ),
                      ],
                    ),
                  ),
                  ...entry.value.asMap().entries.map((e) =>
                      _MembreCard(membre: e.value)
                          .animate()
                          .fadeIn(delay: Duration(milliseconds: 40 * e.key))
                          .slideX(begin: 0.05)),
                  const SizedBox(height: 8),
                ],
              );
            }).toList(),
          );
        },
      ),
    );
  }

  Widget _buildEmpty() => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.group_rounded, size: 72, color: AppColors.primary.withOpacity(0.3)),
            const SizedBox(height: 16),
            const Text('Aucun membre dans l\'équipe',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimaryLight)),
            const SizedBox(height: 8),
            Text('Ajoutez vos premiers collaborateurs',
                style: TextStyle(color: AppColors.grey500), textAlign: TextAlign.center),
          ],
        ),
      );

  void _showAddMemberSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _AddMembreSheet(),
    );
  }
}

// ─── Membre Card ─────────────────────────────────────
class _MembreCard extends ConsumerWidget {
  final MembreEquipeModel membre;
  const _MembreCard({required this.membre});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isActif = membre.statut == 'actif';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
        border: isActif ? null : Border.all(color: AppColors.grey300),
      ),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 28,
            backgroundColor: isActif ? AppColors.primary : AppColors.grey300,
            backgroundImage: membre.photoUrl != null ? NetworkImage(membre.photoUrl!) : null,
            child: membre.photoUrl == null
                ? Text(
                    '${membre.prenom[0]}${membre.nom[0]}',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                  )
                : null,
          ),
          const SizedBox(width: 14),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text('${membre.prenom} ${membre.nom}',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: isActif ? AppColors.textPrimaryLight : AppColors.grey500,
                          )),
                    ),
                    if (!isActif)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.grey200,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text('Inactif',
                            style: TextStyle(fontSize: 10, color: AppColors.grey600, fontWeight: FontWeight.bold)),
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(membre.metier,
                    style: const TextStyle(fontSize: 12, color: AppColors.secondary, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(Icons.phone_rounded, size: 12, color: AppColors.grey400),
                    const SizedBox(width: 3),
                    Text(membre.telephone, style: const TextStyle(fontSize: 11, color: AppColors.grey500)),
                  ],
                ),
                if (membre.projetsAssignes.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text('${membre.projetsAssignes.length} chantier(s) assigné(s)',
                      style: const TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w600)),
                ],
              ],
            ),
          ),
          // Toggle button
          IconButton(
            onPressed: () => _confirmToggle(context, ref),
            icon: Icon(
              isActif ? Icons.pause_circle_outline_rounded : Icons.play_circle_outline_rounded,
              color: isActif ? AppColors.warning : AppColors.success,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmToggle(BuildContext context, WidgetRef ref) async {
    final isActif = membre.statut == 'actif';
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(isActif ? 'Désactiver le membre ?' : 'Réactiver le membre ?'),
        content: Text(isActif
            ? '${membre.prenom} sera marqué comme inactif mais son historique sera conservé.'
            : '${membre.prenom} sera à nouveau actif dans l\'équipe.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: isActif ? AppColors.warning : AppColors.success),
            child: Text(isActif ? 'Désactiver' : 'Réactiver',
                style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (ok == true) {
      await ref.read(membreControllerProvider.notifier).toggleStatut(membre.id, membre.statut);
    }
  }
}

// ─── Add Membre Sheet ────────────────────────────────
class _AddMembreSheet extends ConsumerStatefulWidget {
  const _AddMembreSheet();

  @override
  ConsumerState<_AddMembreSheet> createState() => _AddMembreSheetState();
}

class _AddMembreSheetState extends ConsumerState<_AddMembreSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nomCtrl = TextEditingController();
  final _prenomCtrl = TextEditingController();
  final _telCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  String _metier = 'Maçon';

  static const _metiers = [
    'Chef de chantier', 'Architecte', 'Électricien',
    'Plombier', 'Peintre', 'Maçon', 'Autre',
  ];

  @override
  void dispose() {
    _nomCtrl.dispose();
    _prenomCtrl.dispose();
    _telCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final entreprise = ref.read(currentEntrepriseProvider).value;
    if (entreprise == null) return;

    final membre = MembreEquipeModel(
      id: '',
      entrepriseId: entreprise.id,
      nom: _nomCtrl.text.trim(),
      prenom: _prenomCtrl.text.trim(),
      metier: _metier,
      telephone: _telCtrl.text.trim(),
      email: _emailCtrl.text.trim().isEmpty ? null : _emailCtrl.text.trim(),
      dateAjout: DateTime.now(),
    );

    try {
      await ref.read(membreControllerProvider.notifier).addMembre(membre);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(children: [
              Icon(Icons.check_circle_rounded, color: Colors.white),
              SizedBox(width: 8),
              Text('Membre ajouté à l\'équipe'),
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
    final isLoading = ref.watch(membreControllerProvider).isLoading;
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
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(color: AppColors.grey300, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Ajouter un membre',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.textPrimaryLight)),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(child: TextFormField(controller: _prenomCtrl,
                      decoration: _deco('Prénom', Icons.person_outline_rounded),
                      validator: (v) => v!.isEmpty ? 'Requis' : null)),
                  const SizedBox(width: 10),
                  Expanded(child: TextFormField(controller: _nomCtrl,
                      decoration: _deco('Nom', Icons.person_rounded),
                      validator: (v) => v!.isEmpty ? 'Requis' : null)),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _telCtrl,
                keyboardType: TextInputType.phone,
                decoration: _deco('Téléphone', Icons.phone_rounded),
                validator: (v) => v!.isEmpty ? 'Requis' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: _deco('Email (optionnel)', Icons.email_outlined),
              ),
              const SizedBox(height: 16),
              const Text('Corps de métier',
                  style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimaryLight)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8, runSpacing: 8,
                children: _metiers.map((m) {
                  final sel = _metier == m;
                  return FilterChip(
                    label: Text(m),
                    selected: sel,
                    onSelected: (_) => setState(() => _metier = m),
                    selectedColor: AppColors.primary.withOpacity(0.12),
                    labelStyle: TextStyle(
                        color: sel ? AppColors.primary : AppColors.grey600,
                        fontWeight: sel ? FontWeight.bold : FontWeight.normal,
                        fontSize: 12),
                    side: BorderSide(color: sel ? AppColors.primary : AppColors.grey300),
                    checkmarkColor: AppColors.primary,
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity, height: 52,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                  child: isLoading
                      ? const SizedBox(width: 24, height: 24,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Ajouter à l\'équipe',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _deco(String hint, IconData icon) => InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
        filled: true,
        fillColor: AppColors.backgroundLight,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.primary)),
      );
}
