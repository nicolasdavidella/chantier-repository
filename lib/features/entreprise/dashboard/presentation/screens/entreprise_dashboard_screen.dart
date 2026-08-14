import 'package:flutter/material.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../widgets/dashboard_stat_cards.dart';
import '../widgets/project_requests_section.dart';
import '../widgets/active_projects_section.dart';
import '../widgets/public_profile_section.dart';

class EntrepriseDashboardScreen extends StatelessWidget {
  const EntrepriseDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon Tableau de Bord'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {},
          ),
          const Padding(
            padding: EdgeInsets.only(right: AppSpacing.md),
            child: CircleAvatar(
              backgroundImage: NetworkImage('https://images.unsplash.com/photo-1541888081622-1db116fb837a?ixlib=rb-4.0.3&auto=format&fit=crop&w=500&q=60'),
              radius: 18,
            ),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, 0),
              child: Text(
                'Bonjour, Batix Construction 👋',
                style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SliverPadding(
            padding: EdgeInsets.all(AppSpacing.lg),
            sliver: SliverToBoxAdapter(
              child: DashboardStatCards(),
            ),
          ),
          const SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            sliver: SliverToBoxAdapter(
              child: ProjectRequestsSection(),
            ),
          ),
          const SliverPadding(
            padding: EdgeInsets.all(AppSpacing.lg),
            sliver: SliverToBoxAdapter(
              child: ActiveProjectsSection(),
            ),
          ),
          const SliverPadding(
            padding: EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.xxl),
            sliver: SliverToBoxAdapter(
              child: PublicProfileSection(),
            ),
          ),
        ],
      ),
    );
  }
}
