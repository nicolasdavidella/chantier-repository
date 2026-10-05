import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../../data/models/project_model.dart';
import '../../../../../data/models/entreprise_model.dart';
import '../../../../../data/models/marketplace_applicant_model.dart';
import '../../../../marketplace/providers/marketplace_providers.dart';
import '../../../../auth/providers/auth_provider.dart';
import '../../../../chat/providers/chat_providers.dart';

class ClientMarketplaceTab extends ConsumerStatefulWidget {
  const ClientMarketplaceTab({super.key});

  @override
  ConsumerState<ClientMarketplaceTab> createState() => _ClientMarketplaceTabState();
}

class _ClientMarketplaceTabState extends ConsumerState<ClientMarketplaceTab> {
  final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'fr_FR',
    symbol: 'FCFA',
    decimalDigits: 0,
  );

  @override
  Widget build(BuildContext context) {
    final projectsAsync = ref.watch(clientMarketplaceProjectsProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: const Row(
          children: [
            Icon(Icons.storefront_rounded, color: Color(0xFF143D2B), size: 24),
            SizedBox(width: 8),
            Text(
              "Marketplace Chantiers",
              style: TextStyle(
                color: Color(0xFF143D2B),
                fontSize: 20,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.4,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: "Nouveau Projet",
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFF143D2B),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 18),
            ),
            onPressed: () => _showCreateProjectModal(context),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(clientMarketplaceProjectsProvider);
          },
          color: const Color(0xFF143D2B),
          child: projectsAsync.when(
            data: (projects) {
              if (projects.isEmpty) {
                return _buildEmptyState();
              }
              return _buildProjectsList(projects);
            },
            loading: () => const Center(
              child: CircularProgressIndicator(color: Color(0xFF143D2B)),
            ),
            error: (err, stack) => Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 48),
                    const SizedBox(height: 12),
                    Text(
                      "Erreur lors du chargement : $err",
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF143D2B).withValues(alpha: 0.08),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Icon(
              Icons.storefront_outlined,
              size: 64,
              color: Color(0xFF10B981),
            ),
          ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
          const SizedBox(height: 24),
          const Text(
            "Aucune annonce en ligne",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: Color(0xFF143D2B),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            "Publiez votre projet pour recevoir des propositions d'entreprises de construction vérifiées.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF64748B),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),
          // Bouton Conception Assistée
          InkWell(
            onTap: () => context.push('/client/ia_chat'),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF143D2B), Color(0xFF0F5A3E)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF143D2B).withValues(alpha: 0.25),
                    blurRadius: 15,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Row(
                children: [
                  Icon(Icons.architecture_rounded, color: Colors.white, size: 26),
                  SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Conception Architecturale Assistée",
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16),
                        ),
                        SizedBox(height: 2),
                        Text(
                          "Devis estimatif et plan 3D générés pour votre chantier",
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios_rounded, color: Colors.white70, size: 16),
                ],
              ),
            ),
          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0),
          const SizedBox(height: 14),
          // Bouton Formulaire Manuel
          InkWell(
            onTap: () => context.push('/client/create_project'),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Row(
                children: [
                  Icon(Icons.edit_document, color: Color(0xFF143D2B), size: 24),
                  SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Créer un projet classique",
                          style: TextStyle(color: Color(0xFF143D2B), fontWeight: FontWeight.w800, fontSize: 15),
                        ),
                        SizedBox(height: 2),
                        Text(
                          "Renseignez votre cahier des charges et vos documents",
                          style: TextStyle(color: Color(0xFF64748B), fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios_rounded, color: Color(0xFF94A3B8), size: 16),
                ],
              ),
            ),
          ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2, end: 0),
        ],
      ),
    );
  }

  Widget _buildProjectsList(List<ProjectModel> projects) {
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      itemCount: projects.length,
      itemBuilder: (context, index) {
        final project = projects[index];
        return _ProjectMarketplaceCard(
          project: project,
          currencyFormat: _currencyFormat,
        ).animate().fadeIn(delay: (index * 80).ms).slideY(begin: 0.1, end: 0);
      },
    );
  }

  void _showCreateProjectModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Publier un nouveau projet",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF143D2B),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Choisissez le mode de création qui vous convient :",
                style: TextStyle(color: Color(0xFF64748B), fontSize: 14),
              ),
              const SizedBox(height: 20),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                tileColor: const Color(0xFFF0FDF4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: const BorderSide(color: Color(0xFFBBF7D0)),
                ),
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFF143D2B),
                  child: Icon(Icons.architecture_rounded, color: Colors.white, size: 20),
                ),
                title: const Text(
                  "Conception Architecturale Assistée",
                  style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF143D2B)),
                ),
                subtitle: const Text("Plan 3D, estimation et variantes automatiques"),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                onTap: () {
                  Navigator.pop(ctx);
                  context.push('/client/ia_chat');
                },
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                tileColor: const Color(0xFFF8FAFC),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFE2E8F0),
                  child: Icon(Icons.edit_note_rounded, color: Color(0xFF334155), size: 22),
                ),
                title: const Text(
                  "Formulaire Classique",
                  style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF1E293B)),
                ),
                subtitle: const Text("Saisie manuelle des détails et ajout de documents"),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                onTap: () {
                  Navigator.pop(ctx);
                  context.push('/client/create_project');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProjectMarketplaceCard extends ConsumerStatefulWidget {
  final ProjectModel project;
  final NumberFormat currencyFormat;

  const _ProjectMarketplaceCard({
    required this.project,
    required this.currencyFormat,
  });

  @override
  ConsumerState<_ProjectMarketplaceCard> createState() => _ProjectMarketplaceCardState();
}

class _ProjectMarketplaceCardState extends ConsumerState<_ProjectMarketplaceCard> {
  bool _isExpanded = true;

  @override
  Widget build(BuildContext context) {
    final isAi = widget.project.creationSource == 'ia_assistant';
    final applicantsAsync = ref.watch(projectApplicantsProvider(widget.project.id));
    final ville = widget.project.localisation['ville'] ?? 'Cameroun';
    final quartier = widget.project.localisation['quartier'] ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isAi ? const Color(0xFF10B981).withValues(alpha: 0.3) : const Color(0xFFE2E8F0),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // En-tête du projet
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    // Badge Source
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: isAi ? const Color(0xFFECFDF5) : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isAi ? const Color(0xFFA7F3D0) : const Color(0xFFCBD5E1),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isAi ? Icons.architecture_rounded : Icons.edit_note_rounded,
                            size: 13,
                            color: isAi ? const Color(0xFF059669) : const Color(0xFF475569),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            isAi ? "Conception ChantierTrack" : "Standard",
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: isAi ? const Color(0xFF059669) : const Color(0xFF475569),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Badge En recherche / Actif
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFFDE68A)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.sensors_rounded, size: 12, color: Color(0xFFD97706)),
                          SizedBox(width: 4),
                          Text(
                            "Appel d'offres en direct",
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFFD97706),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  widget.project.titre,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF143D2B),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, size: 15, color: Color(0xFF64748B)),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        quartier.isNotEmpty ? "$quartier, $ville" : ville,
                        style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Icon(Icons.account_balance_wallet_outlined, size: 15, color: Color(0xFF64748B)),
                    const SizedBox(width: 4),
                    Text(
                      widget.currencyFormat.format(widget.project.budgetPrevisionnel),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF143D2B),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: Color(0xFFF1F5F9)),

          // Barre d'accordéon pour les candidats
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              color: const Color(0xFFFAF8F5),
              child: Row(
                children: [
                  Expanded(
                    child: applicantsAsync.when(
                      data: (applicants) => Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: applicants.isNotEmpty ? const Color(0xFF10B981) : const Color(0xFF94A3B8),
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              "${applicants.length}",
                              style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w900),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              applicants.isEmpty
                                  ? "En attente de réponses d'entreprises..."
                                  : "${applicants.length} entreprise(s) capable(s) trouvée(s)",
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: applicants.isNotEmpty ? const Color(0xFF143D2B) : const Color(0xFF64748B),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      loading: () => const Text("Recherche des candidats..."),
                      error: (e, s) => const Text("Erreur candidats"),
                    ),
                  ),
                  Icon(
                    _isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                    color: const Color(0xFF64748B),
                  ),
                ],
              ),
            ),
          ),

          // Liste des entreprises candidates
          if (_isExpanded)
            applicantsAsync.when(
              data: (applicants) {
                if (applicants.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(20),
                    alignment: Alignment.center,
                    child: Column(
                      children: [
                        const Icon(Icons.hourglass_top_rounded, color: Color(0xFF94A3B8), size: 28),
                        const SizedBox(height: 8),
                        const Text(
                          "L'annonce a été transmise aux entreprises de BTP qualifiées.",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Vous recevrez une alerte dès qu'une entreprise valide sa capacité.",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 11, color: const Color(0xFF10B981).withValues(alpha: 0.9), fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(14),
                  itemCount: applicants.length,
                  separatorBuilder: (context, separatorIndex) => const SizedBox(height: 10),
                  itemBuilder: (context, idx) {
                    final applicant = applicants[idx];
                    return _ApplicantCompanyCard(
                      applicant: applicant,
                      project: widget.project,
                      currencyFormat: widget.currencyFormat,
                    );
                  },
                );
              },
              loading: () => const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
              ),
              error: (err, _) => Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text("Erreur: $err", style: const TextStyle(fontSize: 12, color: Colors.red)),
              ),
            ),
        ],
      ),
    );
  }
}

class _ApplicantCompanyCard extends ConsumerWidget {
  final MarketplaceApplicantModel applicant;
  final ProjectModel project;
  final NumberFormat currencyFormat;

  const _ApplicantCompanyCard({
    required this.applicant,
    required this.project,
    required this.currencyFormat,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ent = applicant.entreprise;
    final diff = applicant.diffusion;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Logo ou Avatar
              CircleAvatar(
                radius: 20,
                backgroundColor: const Color(0xFF143D2B),
                backgroundImage: (ent.logoUrl != null && ent.logoUrl!.isNotEmpty)
                    ? NetworkImage(ent.logoUrl!)
                    : null,
                child: (ent.logoUrl == null || ent.logoUrl!.isEmpty)
                    ? Text(
                        ent.raisonSociale.isNotEmpty ? ent.raisonSociale[0].toUpperCase() : 'E',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            ent.raisonSociale,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (ent.isVerified) ...[
                          const SizedBox(width: 4),
                          const Icon(Icons.verified_rounded, size: 14, color: Color(0xFF10B981)),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const NeverScrollableScrollPhysics(),
                      child: Row(
                        children: [
                          const Icon(Icons.star_rounded, size: 14, color: Color(0xFFF59E0B)),
                          const SizedBox(width: 2),
                          Text(
                            ent.noteMoyenne.toStringAsFixed(1),
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF334155)),
                          ),
                          Text(
                            " (${ent.nombreAvis} avis)",
                            style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            "•  ${ent.anneesExperience} ans",
                            style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              // Badge Capacité validée
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle_rounded, size: 12, color: Color(0xFF15803D)),
                    SizedBox(width: 3),
                    Text(
                      "Capable",
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF15803D)),
                    ),
                  ],
                ),
              ),
            ],
          ),

          if (diff.commentaire != null && diff.commentaire!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Text(
                "« ${diff.commentaire} »",
                style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Color(0xFF475569)),
              ),
            ),
          ],

          if (diff.devisEstime != null && diff.devisEstime! > 0) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Text("Estimation proposée : ", style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                Text(
                  currencyFormat.format(diff.devisEstime),
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Color(0xFF143D2B)),
                ),
              ],
            ),
          ],

          const SizedBox(height: 12),

          // Boutons d'actions
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.chat_bubble_outline_rounded, size: 14),
                  label: const FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text("Contacter", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF143D2B),
                    side: const BorderSide(color: Color(0xFFCBD5E1)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                  ),
                  onPressed: () => _contactCompany(context, ref, ent),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.handshake_rounded, size: 14, color: Colors.white),
                  label: const FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text("Attribuer le chantier", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.white)),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF143D2B),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                  ),
                  onPressed: () => _confirmSelection(context, ref, ent.raisonSociale, ent.userId),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _contactCompany(BuildContext context, WidgetRef ref, EntrepriseModel ent) async {
    final user = ref.read(authStateProvider).value;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez vous connecter pour envoyer un message.')),
      );
      return;
    }

    // Récupérer le nom complet du client
    String clientName = 'Client';
    try {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (userDoc.exists && userDoc.data() != null) {
        final u = userDoc.data()!;
        final fullName = '${u['prenom'] ?? ''} ${u['nom'] ?? ''}'.trim();
        if (fullName.isNotEmpty) clientName = fullName;
      }
    } catch (_) {}

    final ville = project.localisation['ville'] ?? 'Non précisée';
    final budgetStr = currencyFormat.format(project.budgetPrevisionnel);
    final description = project.description.isNotEmpty ? project.description : 'Projet de construction';

    final initialContextMessage = "Bonjour ${ent.raisonSociale},\n\nJe suis $clientName et je souhaite échanger avec vous concernant mon projet :\n\n🏗️ Projet : \"${project.titre}\"\n📍 Localisation : $ville\n💰 Budget prévisionnel : $budgetStr\n📝 Besoins & Spécifications :\n$description";
    try {
      final targetUserId = ent.userId.isNotEmpty ? ent.userId : ent.id;
      final conv = await ref.read(chatRepositoryProvider).getOrCreateConversation(
        currentUserId: user.uid,
        targetUserId: targetUserId,
        currentUserName: clientName,
        targetUserName: ent.raisonSociale,
        projectId: project.id,
        initialContextMessage: initialContextMessage,
      );

      if (context.mounted) {
        context.push('/chat/detail', extra: {
          'conversationId': conv.id,
          'otherUserName': ent.raisonSociale,
        });
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Impossible d\'ouvrir la messagerie: $e')),
        );
      }
    }
  }

  void _confirmSelection(BuildContext context, WidgetRef ref, String companyName, String entrepriseUserId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.handshake_rounded, color: Color(0xFF143D2B)),
            const SizedBox(width: 8),
            const Text("Confirmer l'attribution", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
          ],
        ),
        content: Text(
          "Souhaitez-vous confier la réalisation du chantier '${project.titre}' à l'entreprise $companyName ?\n\nL'annonce sera clôturée sur la marketplace et votre espace projet passera en statut actif.",
          style: const TextStyle(fontSize: 14, color: Color(0xFF475569), height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Annuler", style: TextStyle(color: Color(0xFF64748B))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF143D2B),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await ref.read(marketplaceControllerProvider.notifier).selectCompany(
                  projectId: project.id,
                  entrepriseUserId: entrepriseUserId,
                );
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: const Color(0xFF143D2B),
                      content: Text("Félicitations ! Le chantier a été attribué à $companyName."),
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: Colors.redAccent,
                      content: Text("Erreur: $e"),
                    ),
                  );
                }
              }
            },
            child: const Text("Confirmer & Démarrer", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
