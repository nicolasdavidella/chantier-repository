import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../data/models/devis_model.dart';
import '../../../../../data/models/project_model.dart';
import '../../../dashboard/providers/entreprise_dashboard_providers.dart';

class DevisScreen extends ConsumerStatefulWidget {
  const DevisScreen({super.key});

  @override
  ConsumerState<DevisScreen> createState() => _DevisScreenState();
}

class _DevisScreenState extends ConsumerState<DevisScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Devis', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        bottom: TabBar(
          controller: _tabCtrl,
          indicatorColor: AppColors.secondary,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          tabs: const [
            Tab(text: 'Mes devis envoyés'),
            Tab(text: 'Créer un devis'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabCtrl,
        children: [
          const _DevisListTab(),
          _CreateDevisTab(onDevisCreated: () => _tabCtrl.animateTo(0)),
        ],
      ),
    );
  }
}

// ─── Tab 1: Liste des devis ──────────────────────────
class _DevisListTab extends ConsumerWidget {
  const _DevisListTab();

  Color _statusColor(String s) {
    switch (s) {
      case 'accepte': return AppColors.success;
      case 'refuse': return AppColors.error;
      default: return AppColors.warning;
    }
  }

  String _statusLabel(String s) {
    switch (s) {
      case 'accepte': return 'Accepté ✓';
      case 'refuse': return 'Refusé ✗';
      default: return 'En attente…';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final devisAsync = ref.watch(mesDevisProvider);
    final dateFormat = DateFormat('dd MMM yyyy');

    return devisAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Erreur: $e')),
      data: (devisList) {
        if (devisList.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.request_quote_rounded, size: 72, color: AppColors.primary.withOpacity(0.3)),
                const SizedBox(height: 16),
                const Text('Aucun devis envoyé',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimaryLight)),
                const SizedBox(height: 8),
                const Text('Créez votre premier devis depuis l\'onglet "Créer"',
                    style: TextStyle(color: AppColors.grey500), textAlign: TextAlign.center),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: devisList.length,
          itemBuilder: (ctx, i) {
            final d = devisList[i];
            final statusColor = _statusColor(d.statut);
            return Container(
              margin: const EdgeInsets.only(bottom: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.05), blurRadius: 10)],
                border: Border.all(color: statusColor.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.08),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(d.projectId, // Project title would be better here
                              style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimaryLight),
                              overflow: TextOverflow.ellipsis),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(_statusLabel(d.statut),
                              style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Montant', style: TextStyle(fontSize: 11, color: AppColors.grey500)),
                                Text('${d.montant.toStringAsFixed(0)} FCFA',
                                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.primary)),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text('Délai estimé', style: TextStyle(fontSize: 11, color: AppColors.grey500)),
                                Text(d.delaiEstime,
                                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimaryLight)),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(d.description,
                            style: const TextStyle(fontSize: 13, color: AppColors.textSecondaryLight, height: 1.4),
                            maxLines: 2, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 8),
                        Text('Envoyé le ${dateFormat.format(d.dateEnvoi)}',
                            style: const TextStyle(fontSize: 11, color: AppColors.grey500)),
                      ],
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: Duration(milliseconds: 50 * i)).slideY(begin: 0.05);
          },
        );
      },
    );
  }
}

// ─── Tab 2: Créer un devis ───────────────────────────
class _CreateDevisTab extends ConsumerStatefulWidget {
  final VoidCallback onDevisCreated;
  const _CreateDevisTab({required this.onDevisCreated});

  @override
  ConsumerState<_CreateDevisTab> createState() => _CreateDevisTabState();
}

class _CreateDevisTabState extends ConsumerState<_CreateDevisTab> {
  final _formKey = GlobalKey<FormState>();
  final _montantCtrl = TextEditingController();
  final _delaiCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  String? _selectedProjectId;

  @override
  void dispose() {
    _montantCtrl.dispose();
    _delaiCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedProjectId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sélectionnez un projet'), backgroundColor: AppColors.warning),
      );
      return;
    }

    final entreprise = ref.read(currentEntrepriseProvider).value;
    if (entreprise == null) return;

    final devis = DevisModel(
      id: '',
      projectId: _selectedProjectId!,
      entrepriseId: entreprise.id,
      montant: double.parse(_montantCtrl.text.replaceAll(' ', '')),
      delaiEstime: _delaiCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      dateEnvoi: DateTime.now(),
      statut: 'en_attente',
    );

    try {
      await ref.read(devisControllerProvider.notifier).submitDevis(devis);
      if (mounted) {
        _montantCtrl.clear();
        _delaiCtrl.clear();
        _descCtrl.clear();
        setState(() => _selectedProjectId = null);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(children: [
              Icon(Icons.check_circle_rounded, color: Colors.white),
              SizedBox(width: 8),
              Text('Devis envoyé au client !'),
            ]),
            backgroundColor: AppColors.success,
          ),
        );
        widget.onDevisCreated();
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
    final projetsAsync = ref.watch(mesChantierProvider);
    final isLoading = ref.watch(devisControllerProvider).isLoading;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Project selector
            const Text('Projet concerné',
                style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimaryLight)),
            const SizedBox(height: 8),
            projetsAsync.when(
              loading: () => const LinearProgressIndicator(),
              error: (e, _) => Text('Erreur: $e'),
              data: (projets) {
                // Filter projects where no devis sent yet or entreprise is assigned
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: _selectedProjectId,
                    hint: const Text('Sélectionnez un projet'),
                    underline: const SizedBox(),
                    items: projets.map((p) => DropdownMenuItem(
                      value: p.id,
                      child: Text(p.titre, overflow: TextOverflow.ellipsis),
                    )).toList(),
                    onChanged: (v) => setState(() => _selectedProjectId = v),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),

            const Text('Montant (FCFA)',
                style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimaryLight)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _montantCtrl,
              keyboardType: TextInputType.number,
              decoration: _deco('Ex: 5000000', Icons.account_balance_wallet_rounded),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Requis';
                if (double.tryParse(v.replaceAll(' ', '')) == null) return 'Nombre invalide';
                return null;
              },
            ),
            const SizedBox(height: 16),

            const Text('Délai estimé',
                style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimaryLight)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _delaiCtrl,
              decoration: _deco('Ex: 3 mois, 45 jours…', Icons.schedule_rounded),
              validator: (v) => v == null || v.isEmpty ? 'Requis' : null,
            ),
            const SizedBox(height: 16),

            const Text('Description des prestations',
                style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimaryLight)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _descCtrl,
              maxLines: 5,
              decoration: _deco('Détaillez les travaux inclus dans ce devis…', Icons.description_rounded),
              validator: (v) => v == null || v.isEmpty ? 'Requis' : null,
            ),
            const SizedBox(height: 28),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: isLoading ? null : _submit,
                icon: isLoading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.send_rounded, color: Colors.white),
                label: const Text('Envoyer le devis',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _deco(String hint, IconData icon) => InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: AppColors.borderLight)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.primary)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: AppColors.borderLight)),
      );
}
