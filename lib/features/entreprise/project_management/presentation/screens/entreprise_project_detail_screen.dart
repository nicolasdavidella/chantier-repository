import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../../data/models/project_model.dart';
import 'tabs/entreprise_tasks_tab.dart';
import 'tabs/entreprise_reports_tab.dart';
import 'tabs/entreprise_media_tab.dart';
import 'tabs/entreprise_incidents_tab.dart';

class EntrepriseProjectDetailScreen extends ConsumerStatefulWidget {
  final ProjectModel project;

  const EntrepriseProjectDetailScreen({super.key, required this.project});

  @override
  ConsumerState<EntrepriseProjectDetailScreen> createState() => _EntrepriseProjectDetailScreenState();
}

class _EntrepriseProjectDetailScreenState extends ConsumerState<EntrepriseProjectDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
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
              expandedHeight: 120.0,
              floating: false,
              pinned: true,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.pop(),
              ),
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  project.titre,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                titlePadding: const EdgeInsets.only(left: 48, bottom: 16),
                background: Container(
                  color: theme.colorScheme.surface,
                ),
              ),
            ),
            SliverPersistentHeader(
              delegate: _SliverAppBarDelegate(
                TabBar(
                  controller: _tabController,
                  labelColor: theme.colorScheme.primary,
                  unselectedLabelColor: Colors.grey,
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicatorWeight: 3,
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  tabs: const [
                    Tab(text: 'Tâches', icon: Icon(Icons.checklist)),
                    Tab(text: 'Rapports', icon: Icon(Icons.description)),
                    Tab(text: 'Médias', icon: Icon(Icons.perm_media)),
                    Tab(text: 'Incidents', icon: Icon(Icons.warning_amber_rounded)),
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
            EntrepriseTasksTab(projectId: project.id),
            EntrepriseReportsTab(projectId: project.id),
            EntrepriseMediaTab(projectId: project.id),
            EntrepriseIncidentsTab(projectId: project.id),
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
