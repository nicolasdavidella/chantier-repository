import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../data/models/devis_model.dart';
import '../../../../../data/models/project_model.dart';
import '../../../dashboard/providers/entreprise_dashboard_providers.dart';
import '../../../../chat/presentation/screens/chat_detail_screen.dart';
import '../../../../auth/providers/auth_provider.dart';
import '../../providers/devis_provider.dart';
import 'devis_detail_screen.dart';

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
            Tab(text: 'Mes devis'),
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
    final devisAsync = ref.watch(mesDevisStreamProvider);
    final localDevisList = ref.watch(devisProvider);
    final dateFormat = DateFormat('dd MMM yyyy');

    final firestoreDevis = devisAsync.value ?? [];

    final allDevis = <DevisModel>[...firestoreDevis];
    for (final ld in localDevisList) {
      if (!allDevis.any((d) => (d.id.isNotEmpty && d.id == ld.id) || (d.projectId == ld.projectId && d.montant == ld.montant))) {
        allDevis.add(ld);
      }
    }
    allDevis.sort((a, b) => b.dateEnvoi.compareTo(a.dateEnvoi));

    if (devisAsync.isLoading && allDevis.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF143D2B)));
    }

    if (allDevis.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.request_quote_rounded, size: 72, color: AppColors.primary.withValues(alpha: 0.3)),
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
      itemCount: allDevis.length,
      itemBuilder: (ctx, i) {
        final d = allDevis[i];
            final statusColor = _statusColor(d.statut);
            return InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => DevisDetailScreen(devis: d)),
                );
              },
              borderRadius: BorderRadius.circular(18),
              child: Container(
                margin: const EdgeInsets.only(bottom: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.05),
                      blurRadius: 10,
                    ),
                  ],
                  border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.08),
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  (d.projectTitle != null && d.projectTitle!.isNotEmpty)
                                      ? d.projectTitle!
                                      : (d.projectId.isNotEmpty
                                          ? 'Chantier #${d.projectId.length > 8 ? d.projectId.substring(0, 8) : d.projectId}'
                                          : 'Proposition de devis'),
                                  style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimaryLight),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (d.clientName != null && d.clientName!.isNotEmpty) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    'Client : ${d.clientName}',
                                    style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Color(0xFF10B981)),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.15),
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
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Montant', style: TextStyle(fontSize: 11, color: AppColors.grey500)),
                                  Text('${d.montant.toStringAsFixed(0)} FCFA',
                                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.primary),
                                      maxLines: 1, overflow: TextOverflow.ellipsis),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Flexible(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  const Text('Délai estimé', style: TextStyle(fontSize: 11, color: AppColors.grey500)),
                                  Text(d.delaiEstime,
                                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimaryLight),
                                      maxLines: 1, overflow: TextOverflow.ellipsis),
                                ],
                              ),
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
            ),
          ).animate().fadeIn(delay: Duration(milliseconds: 50 * i)).slideY(begin: 0.05);
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

  @override
  void dispose() {
    _montantCtrl.dispose();
    _delaiCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  void _onPressSend() {
    if (!_formKey.currentState!.validate()) return;

    // Ouvrir la page de sélection des projets sur lesquels l'entreprise travaille
    _showProjectSelectionSheet();
  }

  void _showProjectSelectionSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _ProjectSelectionSheet(
        onProjectSelected: (project) async {
          Navigator.pop(ctx);
          await _submitDevisForProject(project);
        },
      ),
    );
  }

  Future<void> _submitDevisForProject(ProjectModel project) async {
    final entreprise = ref.read(currentEntrepriseStreamProvider).value;
    final user = ref.read(authStateProvider).value;
    final authUser = FirebaseAuth.instance.currentUser;
    final entId = entreprise?.id ?? authUser?.uid ?? user?.uid ?? '';

    final montantVal = double.parse(_montantCtrl.text.replaceAll(' ', ''));
    final delaiVal = _delaiCtrl.text.trim();
    final descVal = _descCtrl.text.trim();

    final devis = DevisModel(
      id: '',
      projectId: project.id,
      entrepriseId: entId,
      montant: montantVal,
      delaiEstime: delaiVal,
      description: descVal,
      dateEnvoi: DateTime.now(),
      statut: 'en_attente',
      projectTitle: project.titre,
    );

    // Mettre à jour immédiatement l'état local dans devisProvider
    try {
      ref.read(devisProvider.notifier).submitDevis(devis);
    } catch (_) {}

    try {
      final conversationId = await ref.read(devisControllerProvider.notifier).submitDevis(
        devis,
        targetClientId: project.clientId,
        projectTitle: project.titre,
      );

      if (!mounted) return;

      // Nom d'affichage du client
      String clientDisplayName = 'Client';
      if (project.clientId.isNotEmpty) {
        try {
          final userDoc = await FirebaseFirestore.instance.collection('users').doc(project.clientId).get();
          if (userDoc.exists && userDoc.data() != null) {
            final u = userDoc.data()!;
            final fullName = '${u['prenom'] ?? ''} ${u['nom'] ?? ''}'.trim();
            if (fullName.isNotEmpty) clientDisplayName = fullName;
          }
        } catch (_) {}
      }

      final currencyFmt = NumberFormat.currency(locale: 'fr_FR', symbol: 'FCFA', decimalDigits: 0);
      final montantStr = currencyFmt.format(montantVal);

      _montantCtrl.clear();
      _delaiCtrl.clear();
      _descCtrl.clear();

      if (!mounted) return;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogCtx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Color(0xFFE8F5E9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 48),
              ),
              const SizedBox(height: 16),
              const Text(
                'Devis transmis avec succès !',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Color(0xFF143D2B)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Votre proposition de $montantStr a été envoyée pour le chantier "${project.titre}" et déposée directement dans la discussion avec le client ($clientDisplayName).',
                style: const TextStyle(fontSize: 13, color: Color(0xFF475569), height: 1.4),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              if (conversationId != null) ...[
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.chat_bubble_rounded, size: 16, color: Colors.white),
                    label: const Text('Ouvrir la discussion', style: TextStyle(fontWeight: FontWeight.w800, color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF143D2B),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () {
                      Navigator.pop(dialogCtx);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatDetailScreen(
                            conversationId: conversationId,
                            otherUserName: clientDisplayName,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),
              ],
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF143D2B),
                    side: const BorderSide(color: Color(0xFFCBD5E1)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () {
                    Navigator.pop(dialogCtx);
                    widget.onDevisCreated();
                  },
                  child: const Text('Voir mes devis', style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de l\'envoi du devis: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(devisControllerProvider).isLoading;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero info card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFC8E6C9), width: 1.2),
              ),
              child: const Row(
                children: [
                  Icon(Icons.edit_note_rounded, color: Color(0xFF143D2B), size: 28),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Créer et chiffrer un devis',
                          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: Color(0xFF143D2B)),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Renseignez les éléments ci-dessous. En appuyant sur "Envoyer", vous pourrez choisir le chantier auquel l\'adresser et le devis sera partagé dans le chat.',
                          style: TextStyle(fontSize: 12, color: Color(0xFF2E7D32), height: 1.3),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            const Text('Montant du devis (FCFA)',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppColors.textPrimaryLight)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _montantCtrl,
              keyboardType: TextInputType.number,
              decoration: _deco('Ex: 5000000', Icons.payments_rounded),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Montant requis';
                if (double.tryParse(v.replaceAll(' ', '')) == null) return 'Nombre invalide';
                return null;
              },
            ),
            const SizedBox(height: 18),

            const Text('Délai d\'exécution estimé',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppColors.textPrimaryLight)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _delaiCtrl,
              decoration: _deco('Ex: 3 mois, 45 jours…', Icons.schedule_rounded),
              validator: (v) => v == null || v.trim().isEmpty ? 'Délai requis' : null,
            ),
            const SizedBox(height: 18),

            const Text('Description détaillée des prestations',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppColors.textPrimaryLight)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _descCtrl,
              maxLines: 5,
              decoration: _deco('Détaillez les travaux inclus : gros œuvre, matériaux, main d\'œuvre…', Icons.description_rounded),
              validator: (v) => v == null || v.trim().isEmpty ? 'Description requise' : null,
            ),
            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: isLoading ? null : _onPressSend,
                icon: isLoading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.arrow_forward_rounded, color: Colors.white),
                label: const Text('Envoyer le devis',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF143D2B),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 2,
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
        hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
        prefixIcon: Icon(icon, color: const Color(0xFF143D2B), size: 20),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFF143D2B), width: 1.5)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
      );
}

// ─── Sheet de sélection du projet concerné ───────────
class _ProjectSelectionSheet extends ConsumerWidget {
  final Function(ProjectModel) onProjectSelected;
  const _ProjectSelectionSheet({required this.onProjectSelected});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projetsAsync = ref.watch(mesChantierStreamProvider);
    final currencyFmt = NumberFormat.currency(locale: 'fr_FR', symbol: 'FCFA', decimalDigits: 0);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFFFAF8F5),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.apartment_rounded, color: Color(0xFF143D2B), size: 24),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Chantiers en cours',
                        style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17, color: Color(0xFF143D2B)),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Sélectionnez le projet auquel envoyer ce devis',
                        style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B)),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),

          Flexible(
            child: projetsAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.all(40),
                child: Center(child: CircularProgressIndicator(color: Color(0xFF143D2B))),
              ),
              error: (err, _) => Padding(
                padding: const EdgeInsets.all(30),
                child: Center(child: Text('Erreur: $err', style: const TextStyle(color: Colors.red))),
              ),
              data: (projets) {
                if (projets.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: const BoxDecoration(
                            color: Color(0xFFE8F5E9),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.construction_rounded, size: 48, color: Color(0xFF143D2B)),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Aucun chantier actif trouvé',
                          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF143D2B)),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Vous devez avoir au moins un projet en cours ou attribué pour lui adresser un devis formel.',
                          style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  shrinkWrap: true,
                  itemCount: projets.length,
                  separatorBuilder: (_, index) => const SizedBox(height: 12),
                  itemBuilder: (ctx, index) {
                    final p = projets[index];
                    final ville = p.localisation['ville']?.toString() ?? 'Cameroun';
                    final budgetStr = currencyFmt.format(p.budgetPrevisionnel);

                    return InkWell(
                      onTap: () => onProjectSelected(p),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFCBD5E1), width: 1.2),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF143D2B).withValues(alpha: 0.04),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE8F5E9),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(Icons.home_work_rounded, color: Color(0xFF143D2B), size: 20),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        p.titre,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w900,
                                          fontSize: 15,
                                          color: Color(0xFF143D2B),
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 2),
                                      Row(
                                        children: [
                                          const Icon(Icons.location_on_outlined, size: 12, color: Color(0xFF64748B)),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              ville,
                                              style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w600),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFEF3C7),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    p.statut == 'en_cours' ? 'EN COURS' : p.statut.toUpperCase(),
                                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFFB45309)),
                                  ),
                                ),
                              ],
                            ),
                            if (p.description.isNotEmpty) ...[
                              const SizedBox(height: 10),
                              Text(
                                p.description,
                                style: const TextStyle(fontSize: 12.5, color: Color(0xFF475569), height: 1.3),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Budget prévisionnel',
                                        style: TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                                      ),
                                      Text(
                                        budgetStr,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w800,
                                          color: Color(0xFF143D2B),
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF143D2B),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'Choisir',
                                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12),
                                      ),
                                      SizedBox(width: 4),
                                      Icon(Icons.arrow_forward_rounded, size: 14, color: Colors.white),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
