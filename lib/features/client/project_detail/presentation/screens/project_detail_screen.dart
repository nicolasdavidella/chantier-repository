import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../../data/models/project_model.dart';
import 'tabs/avancement_tab.dart';
import 'tabs/depenses_tab.dart';
import 'tabs/alertes_tab.dart';
import 'tabs/entreprises_interessees_tab.dart';
import 'tabs/documents_tab.dart';
import '../../../../ia_assistant/presentation/screens/ia_insights_screen.dart';
import '../../../../reviews/presentation/screens/create_review_screen.dart';
import '../../../../../../core/services/pdf_export_service.dart';
import '../../../../../../core/widgets/export_pdf_button.dart';
import '../../../../../../data/models/rapport_avancement_model.dart';
import '../../../../../../data/models/depense_model.dart';
import 'package:chantier_track/core/theme/app_colors.dart';


class ProjectDetailScreen extends ConsumerStatefulWidget {
  final ProjectModel project;

  const ProjectDetailScreen({super.key, required this.project});

  @override
  ConsumerState<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends ConsumerState<ProjectDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    
    final isSearching = widget.project.statut == 'en_recherche_entreprise' || widget.project.statut == 'publie';
    _tabController = TabController(length: isSearching ? 2 : 4, vsync: this);

    if (widget.project.statut == 'termine' && widget.project.entrepriseId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _promptForReview();
      });
    }
  }

  void _promptForReview() {
    // Dans une vraie app, on vérifierait si un avis a déjà été laissé
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: const [
            Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 22),
            SizedBox(width: 8),
            Text('Félicitations !'),
          ],
        ),
        content: const Text('Votre projet est terminé. Prenez un moment pour évaluer le travail réalisé.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Plus tard')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CreateReviewScreen(
                    projectId: widget.project.id,
                    targetId: widget.project.entrepriseId!,
                    targetType: 'entreprise',
                    targetName: 'L\'entreprise',
                  ),
                ),
              );
            },
            child: const Text('Évaluer'),
          ),
        ],
      ),
    );
  }

  void _showExportOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Exporter en PDF', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
              const SizedBox(height: 24),
              ExportPdfButton(
                label: 'Rapport d\'avancement',
                fileName: 'avancement_${widget.project.id}.pdf',
                onGenerate: () async {
                  return PdfExportService.generateProgressReport(
                    project: widget.project,
                    rapports: [
                      RapportAvancementModel(id: '1', projectId: widget.project.id, chefChantierId: 'c1', date: DateTime.now(), pourcentageAvancement: 40, description: 'Gros oeuvre achevé', tachesConcernees: [], photos: [], videos: []),
                    ],
                  );
                },
              ),
              const SizedBox(height: 16),
              ExportPdfButton(
                label: 'Rapport financier',
                fileName: 'financier_${widget.project.id}.pdf',
                onGenerate: () async {
                  return PdfExportService.generateFinancialReport(
                    project: widget.project,
                    depenses: [
                      DepenseModel(id: '1', projectId: widget.project.id, declarantId: 'c1', montant: 500000, categorie: 'Matériaux', dateDeclaration: DateTime.now(), description: 'Ciment', justificatifUrl: '', statut: 'valide'),
                    ],
                  );
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final project = widget.project;
    final isSearching = project.statut == 'en_recherche_entreprise' || project.statut == 'publie';

    return Scaffold(
      backgroundColor: const Color(0xFFFAF8F5),
      body: Stack(
        children: [
          // Background ambient glows
          Positioned(
            top: 100,
            right: -80,
            child: Container(
              width: 250,
              height: 250,
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
          NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverAppBar(
                  expandedHeight: 220.0,
                  floating: false,
                  pinned: true,
                  backgroundColor: const Color(0xFF143D2B),
                  foregroundColor: Colors.white,
                  leading: IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.3),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                    ),
                    onPressed: () => context.pop(),
                  ),
                  actions: [
                    IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withValues(alpha: 0.3),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.auto_awesome, color: Color(0xFF86EFAC), size: 20),
                      ),
                      tooltip: 'Insights NICO IA',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => IaInsightsScreen(projectId: project.id),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.3),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.picture_as_pdf, color: Colors.white, size: 20),
                      ),
                      tooltip: 'Exporter',
                      onPressed: _showExportOptions,
                    ),
                    const SizedBox(width: 8),
                  ],
                  flexibleSpace: FlexibleSpaceBar(
                    title: Text(
                      project.titre,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 17,
                        color: Colors.white,
                        shadows: [Shadow(color: Colors.black87, blurRadius: 6)],
                      ),
                    ),
                    background: Hero(
                      tag: 'project_image_${project.id}',
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          if (project.listePlans.isNotEmpty)
                            Image.network(project.listePlans.first, fit: BoxFit.cover)
                          else
                            Container(
                              color: const Color(0xFF143D2B),
                              child: const Center(
                                child: Icon(Icons.home_work_rounded, size: 64, color: Color(0xFF86EFAC)),
                              ),
                            ),
                          const DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Colors.black38, Colors.transparent, Colors.black87],
                                stops: [0.0, 0.4, 1.0],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SliverPersistentHeader(
                  delegate: _SliverAppBarDelegate(
                    Container(
                      decoration: const BoxDecoration(
                        color: Color(0xFFFAF8F5),
                        border: Border(
                          bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1),
                        ),
                      ),
                      child: TabBar(
                        controller: _tabController,
                        isScrollable: true,
                        labelColor: const Color(0xFF143D2B),
                        unselectedLabelColor: AppColors.textSecondaryLight,
                        indicatorColor: const Color(0xFF10B981),
                        indicatorWeight: 3,
                        labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                        tabs: isSearching 
                          ? const [
                              Tab(text: 'Entreprises', icon: Icon(Icons.business_center_rounded, size: 20)),
                              Tab(text: 'Documents', icon: Icon(Icons.folder_rounded, size: 20)),
                            ]
                          : const [
                              Tab(text: 'Avancement', icon: Icon(Icons.timeline_rounded, size: 20)),
                              Tab(text: 'Dépenses', icon: Icon(Icons.account_balance_wallet_rounded, size: 20)),
                              Tab(text: 'Alertes NICO IA', icon: Icon(Icons.warning_amber_rounded, size: 20)),
                              Tab(text: 'Documents', icon: Icon(Icons.folder_rounded, size: 20)),
                            ],
                      ),
                    ),
                  ),
                  pinned: true,
                ),
              ];
            },
            body: TabBarView(
              controller: _tabController,
              children: isSearching
                ? [
                    EntreprisesInteresseesTab(project: project),
                    DocumentsTab(projectId: project.id),
                  ]
                : [
                    AvancementTab(projectId: project.id),
                    DepensesTab(projectId: project.id, budgetTotal: project.budgetPrevisionnel),
                    AlertesTab(projectId: project.id),
                    DocumentsTab(projectId: project.id),
                  ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final Widget _tabBar;

  @override
  double get minExtent => 64.0;
  @override
  double get maxExtent => 64.0;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return _tabBar;
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
