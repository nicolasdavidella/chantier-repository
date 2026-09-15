import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../../data/models/project_model.dart';
import 'tabs/avancement_tab.dart';
import 'tabs/depenses_tab.dart';
import 'tabs/alertes_tab.dart';
import 'tabs/documents_tab.dart';
import '../../../../ia_assistant/presentation/screens/ia_insights_screen.dart';
import '../../../../reviews/presentation/screens/create_review_screen.dart';
import '../../../../../../core/services/pdf_export_service.dart';
import '../../../../../../core/widgets/export_pdf_button.dart';
import '../../../../../../data/models/rapport_avancement_model.dart';
import '../../../../../../data/models/depense_model.dart';

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
    _tabController = TabController(length: 4, vsync: this);

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
            Icon(Icons.check_circle_rounded, color: Color(0xFF0F6E56), size: 22),
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

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 200.0,
              floating: false,
              pinned: true,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.pop(),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.psychology, color: Colors.purpleAccent),
                  tooltip: 'Insights IA',
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
                  icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
                  tooltip: 'Exporter',
                  onPressed: _showExportOptions,
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                title: Text(project.titre, style: const TextStyle(shadows: [Shadow(color: Colors.black54, blurRadius: 4)])),
                background: Hero(
                  tag: 'project_image_${project.id}',
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (project.listePlans.isNotEmpty)
                        Image.network(project.listePlans.first, fit: BoxFit.cover)
                      else
                        Container(color: theme.colorScheme.primaryContainer, child: const Icon(Icons.home_work, size: 64)),
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.transparent, Colors.black87],
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
                TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  labelColor: theme.colorScheme.primary,
                  unselectedLabelColor: Colors.grey,
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicatorWeight: 3,
                  tabs: const [
                    Tab(text: 'Avancement', icon: Icon(Icons.timeline)),
                    Tab(text: 'Dépenses', icon: Icon(Icons.account_balance_wallet)),
                    Tab(text: 'Alertes IA', icon: Icon(Icons.warning_amber_rounded)),
                    Tab(text: 'Documents', icon: Icon(Icons.folder)),
                  ],
                ),
              ),
              pinned: true,
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            AvancementTab(projectId: project.id),
            DepensesTab(projectId: project.id, budgetTotal: project.budgetPrevisionnel),
            AlertesTab(projectId: project.id),
            DocumentsTab(projectId: project.id),
          ],
        ),
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
