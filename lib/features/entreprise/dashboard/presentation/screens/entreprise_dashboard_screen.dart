import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/utils/responsive.dart';
import '../../../../../core/providers/settings_provider.dart';
import 'package:chantier_track/l10n/app_localizations.dart';
import '../../../../auth/data/auth_repository.dart';
import '../../providers/entreprise_dashboard_provider.dart';

class EntrepriseDashboardScreen extends ConsumerWidget {
  const EntrepriseDashboardScreen({super.key});

  String _formatCurrency(double amount) {
    // Basic formatting for large numbers: 12500000 -> "12 500 000 FCFA"
    String numStr = amount.toInt().toString();
    String result = '';
    int count = 0;
    for (int i = numStr.length - 1; i >= 0; i--) {
      result = numStr[i] + result;
      count++;
      if (count == 3 && i != 0) {
        result = ' $result';
        count = 0;
      }
    }
    return '$result FCFA';
  }

  Future<void> _pickPhoto(WidgetRef ref) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      // In a real app we'd upload this file. Here we just use its path or a placeholder.
      // In Chrome/Web, the path is often a blob URL.
      ref.read(entrepriseDashboardDataProvider.notifier).addPhoto(pickedFile.path);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const bgColor = Color(0xFF111111);
    const cardColor = Color(0xFF1E1E1E);
    const borderColor = Color(0xFF2A2A2A);
    const accentColor = Color(0xFFF97316);

    final data = ref.watch(entrepriseDashboardDataProvider);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Menu
              if (Responsive.isMobile(context))
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.apartment, color: Colors.black),
                            ),
                            const SizedBox(width: 12),
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'SUMMIT',
                                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 1.5),
                                ),
                                Text(
                                  'CONSTRUCTION',
                                  style: TextStyle(color: Colors.grey, fontSize: 10, letterSpacing: 2),
                                ),
                              ],
                            )
                          ],
                        ),
                        Row(
                          children: [
                            InkWell(
                              onTap: () {
                                final currentLang = ref.read(languageProvider);
                                ref.read(languageProvider.notifier).setLanguage(currentLang == 'fr' ? 'en' : 'fr');
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.grey.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  ref.watch(languageProvider).toUpperCase(),
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            IconButton(
                              icon: const Icon(Icons.logout, color: Colors.grey),
                              onPressed: () {
                                ref.read(authRepositoryProvider).signOut();
                              },
                              tooltip: 'Déconnexion',
                            ),
                            const SizedBox(width: 8),
                            InkWell(
                              onTap: () => context.push('/profile'),
                              child: const CircleAvatar(
                                backgroundImage: NetworkImage('https://images.unsplash.com/photo-1541888081622-1db116fb837a?auto=format&fit=crop&w=150&q=80'),
                                radius: 20,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildTopMenuIcon(Icons.work_outline, 'Appels\nd\'Offres', onTap: () => context.pushNamed('offres')),
                          const SizedBox(width: 8),
                          _buildTopMenuIcon(Icons.calendar_month, 'Project\nPlanning', onTap: () => context.pushNamed('project_planning')),
                          const SizedBox(width: 8),
                          _buildTopMenuIcon(Icons.task_alt, 'Task\nManagement', onTap: () => context.pushNamed('task_management')),
                          const SizedBox(width: 8),
                          _buildTopMenuIcon(Icons.attach_money, 'Budget\nTracking', color: accentColor),
                          const SizedBox(width: 8),
                          _buildTopMenuIcon(Icons.camera_alt_outlined, 'Site\nPhotos'),
                          const SizedBox(width: 8),
                          _buildTopMenuIcon(Icons.description_outlined, 'Documents\n& Reports', onTap: () => context.pushNamed('documents_reports')),
                        ],
                      ),
                    ),
                  ],
                )
              else
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.apartment, color: Colors.black),
                        ),
                        const SizedBox(width: 12),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'SUMMIT',
                              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 1.5),
                            ),
                            Text(
                              'CONSTRUCTION',
                              style: TextStyle(color: Colors.grey, fontSize: 10, letterSpacing: 2),
                            ),
                          ],
                        )
                      ],
                    ),
                    Row(
                      children: [
                        _buildTopMenuIcon(Icons.work_outline, 'Appels\nd\'Offres', onTap: () => context.pushNamed('offres')),
                        const SizedBox(width: 8),
                        _buildTopMenuIcon(Icons.calendar_month, 'Project\nPlanning', onTap: () => context.pushNamed('project_planning')),
                        const SizedBox(width: 8),
                        _buildTopMenuIcon(Icons.task_alt, 'Task\nManagement', onTap: () => context.pushNamed('task_management')),
                        const SizedBox(width: 8),
                        _buildTopMenuIcon(Icons.attach_money, 'Budget\nTracking', color: accentColor),
                        const SizedBox(width: 8),
                        _buildTopMenuIcon(Icons.camera_alt_outlined, 'Site\nPhotos'),
                        const SizedBox(width: 8),
                        _buildTopMenuIcon(Icons.description_outlined, 'Documents\n& Reports', onTap: () => context.pushNamed('documents_reports')),
                        const SizedBox(width: 24),
                        InkWell(
                          onTap: () {
                            final currentLang = ref.read(languageProvider);
                            ref.read(languageProvider.notifier).setLanguage(currentLang == 'fr' ? 'en' : 'fr');
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              ref.watch(languageProvider).toUpperCase(),
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.logout, color: Colors.grey),
                          onPressed: () {
                            ref.read(authRepositoryProvider).signOut();
                          },
                          tooltip: 'Déconnexion',
                        ),
                        const SizedBox(width: 8),
                        InkWell(
                          onTap: () => context.push('/profile'),
                          child: const CircleAvatar(
                            backgroundImage: NetworkImage('https://images.unsplash.com/photo-1541888081622-1db116fb837a?auto=format&fit=crop&w=150&q=80'),
                            radius: 20,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              const SizedBox(height: 48),

              // Title Section
              Text(
                AppLocalizations.of(context)?.dashboardTitle ?? 'Construction Project Dashboard',
                style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Track. Manage. Deliver.',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
              const SizedBox(height: 32),

              // Main Grid
              if (Responsive.isMobile(context))
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProjectOverview(data, cardColor, borderColor, accentColor),
                    const SizedBox(height: 24),
                    _buildGanttChart(cardColor, borderColor, accentColor),
                  ],
                )
              else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left Column: Overview
                    Expanded(
                      flex: 1,
                      child: _buildProjectOverview(data, cardColor, borderColor, accentColor),
                    ),
                    const SizedBox(width: 24),
                    // Right Column: Gantt Chart
                    Expanded(
                      flex: 2,
                      child: _buildGanttChart(cardColor, borderColor, accentColor),
                    ),
                  ],
                ),
              const SizedBox(height: 24),

              if (Responsive.isMobile(context))
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTaskBoard(data, cardColor, borderColor),
                    const SizedBox(height: 24),
                    _buildBudgetTracker(data, cardColor, borderColor, accentColor),
                  ],
                )
              else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left Column: Task Board
                    Expanded(
                      flex: 2,
                      child: _buildTaskBoard(data, cardColor, borderColor),
                    ),
                    const SizedBox(width: 24),
                    // Right Column: Budget
                    Expanded(
                      flex: 1,
                      child: _buildBudgetTracker(data, cardColor, borderColor, accentColor),
                    ),
                  ],
                ),
              const SizedBox(height: 24),

              // Bottom Section: Photos
              _buildSitePhotos(data, cardColor, borderColor, ref),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopMenuIcon(IconData icon, String label, {Color color = Colors.grey, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(String title, IconData icon, Color cardColor, Color borderColor, Widget child, {Widget? trailing}) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(icon, color: const Color(0xFFF97316), size: 20),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              if (trailing != null) trailing,
            ],
          ),
          const SizedBox(height: 24),
          child,
        ],
      ),
    );
  }

  Widget _buildProjectOverview(DashboardData data, Color cardColor, Color borderColor, Color accentColor) {
    return _buildCard(
      'Project Overview',
      Icons.assessment_outlined,
      cardColor,
      borderColor,
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Overall Progress', style: TextStyle(color: Colors.grey, fontSize: 14)),
          const SizedBox(height: 8),
          Text('${(data.overallProgress * 100).toInt()}%', style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: data.overallProgress,
            backgroundColor: Colors.grey.shade800,
            valueColor: AlwaysStoppedAnimation<Color>(accentColor),
            minHeight: 6,
            borderRadius: BorderRadius.circular(3),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatDetail('Tasks Completed', '${data.tasksCompleted}'),
              _buildStatDetail('Tasks Remaining', '${data.tasksRemaining}'),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatDetail('Project Duration', data.projectDuration),
              _buildStatDetail('Completion Target', data.completionTarget),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatDetail(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildGanttChart(Color cardColor, Color borderColor, Color accentColor) {
    return _buildCard(
      'Gantt Chart',
      Icons.bar_chart,
      cardColor,
      borderColor,
      Column(
        children: [
          // Timeline header
          const SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: 500, // Fixed width to allow scrolling if needed
              child: Column(
                children: [
                  Row(
                    children: [
                      SizedBox(width: 140),
                      Expanded(child: Text('Week', style: TextStyle(color: Colors.grey, fontSize: 12))),
                      Expanded(child: Text('May', style: TextStyle(color: Colors.grey, fontSize: 12))),
                      Expanded(child: Text('June', style: TextStyle(color: Colors.grey, fontSize: 12))),
                    ],
                  ),
                  SizedBox(height: 16),
                  Divider(color: Color(0xFF2A2A2A)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Bars
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: 500,
              child: Column(
                children: [
                  _buildGanttRow('Site Preparation', 0.0, 0.4, Colors.blue),
                  _buildGanttRow('Foundation', 0.3, 0.6, Colors.orange),
                  _buildGanttRow('Structure', 0.5, 0.7, Colors.green),
                  _buildGanttRow('MEP Rough-in', 0.65, 0.8, Colors.yellow),
                  _buildGanttRow('Interior Finishes', 0.75, 0.95, Colors.purple),
                  _buildGanttRow('Final Walkthrough', 0.9, 1.0, Colors.pink),
                ],
              ),
            ),
          ),
        ],
      ),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(color: const Color(0xFF2A2A2A), borderRadius: BorderRadius.circular(6)),
        child: const Text('Today', style: TextStyle(color: Colors.white, fontSize: 12)),
      ),
    );
  }

  Widget _buildGanttRow(String task, double start, double end, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          SizedBox(
            width: 140,
            child: Text(task, style: const TextStyle(color: Colors.white, fontSize: 13)),
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                return Stack(
                  children: [
                    Container(height: 8, width: width, color: Colors.transparent),
                    Positioned(
                      left: width * start,
                      width: width * (end - start),
                      child: Container(
                        height: 8,
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskBoard(DashboardData data, Color cardColor, Color borderColor) {
    return _buildCard(
      'Contractor Task Board',
      Icons.view_kanban_outlined,
      cardColor,
      borderColor,
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 250,
              child: _buildKanbanColumn('To Do', data.tasks.where((t) => t.status == 'To Do').map((t) => _buildKanbanTask(t.title, t.tag, t.avatarUrl, t.assignee)).toList()),
            ),
            const SizedBox(width: 16),
            SizedBox(
              width: 250,
              child: _buildKanbanColumn('In Progress', data.tasks.where((t) => t.status == 'In Progress').map((t) => _buildKanbanTask(t.title, t.tag, t.avatarUrl, t.assignee)).toList()),
            ),
            const SizedBox(width: 16),
            SizedBox(
              width: 250,
              child: _buildKanbanColumn('Review', data.tasks.where((t) => t.status == 'Review').map((t) => _buildKanbanTask(t.title, t.tag, t.avatarUrl, t.assignee)).toList()),
            ),
            const SizedBox(width: 16),
            SizedBox(
              width: 250,
              child: _buildKanbanColumn('Done', data.tasks.where((t) => t.status == 'Done').map((t) => _buildKanbanTask(t.title, t.tag, t.avatarUrl, t.assignee)).toList()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKanbanColumn(String title, List<Widget> tasks) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        const Divider(color: Color(0xFF2A2A2A)),
        const SizedBox(height: 16),
        ...tasks,
      ],
    );
  }

  Widget _buildKanbanTask(String title, String tag, String avatarUrl, String assignee) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(tag, style: TextStyle(color: Colors.grey.shade600, fontSize: 11)),
          const SizedBox(height: 12),
          Row(
            children: [
              CircleAvatar(backgroundImage: NetworkImage(avatarUrl), radius: 10),
              const SizedBox(width: 8),
              Expanded(
                child: Text(assignee, style: const TextStyle(color: Colors.grey, fontSize: 11), overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetTracker(DashboardData data, Color cardColor, Color borderColor, Color accentColor) {
    return _buildCard(
      'Budget Tracker',
      Icons.pie_chart_outline,
      cardColor,
      borderColor,
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 16,
            runSpacing: 16,
            alignment: WrapAlignment.spaceBetween,
            children: [
              _buildStatDetail('Total Budget', _formatCurrency(data.budget.totalBudget)),
              _buildStatDetail('Spent', _formatCurrency(data.budget.spent)),
              _buildStatDetail('Remaining', _formatCurrency(data.budget.remaining)),
            ],
          ),
          const SizedBox(height: 32),
          LayoutBuilder(
            builder: (context, constraints) {
              if (Responsive.isMobile(context)) {
                return Column(
                  children: [
                    // Circle Progress
                    SizedBox(
                      width: 120,
                      height: 120,
                      child: Stack(
                        children: [
                          Center(
                            child: SizedBox(
                              width: 100,
                              height: 100,
                              child: CircularProgressIndicator(
                                value: data.budget.spentPercentage,
                                backgroundColor: Colors.grey.shade800,
                                valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                                strokeWidth: 8,
                              ),
                            ),
                          ),
                          Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('${(data.budget.spentPercentage * 100).toInt()}%', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                                const Text('Spent', style: TextStyle(color: Colors.grey, fontSize: 10)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Legend
                    Column(
                      children: data.budget.breakdown.entries.map((e) => _buildBudgetRow(e.key, _formatCurrency(e.value))).toList(),
                    ),
                  ],
                );
              }
              return Row(
                children: [
                  // Circle Progress
                  SizedBox(
                    width: 100,
                    height: 100,
                    child: Stack(
                      children: [
                        Center(
                          child: SizedBox(
                            width: 80,
                            height: 80,
                            child: CircularProgressIndicator(
                              value: data.budget.spentPercentage,
                              backgroundColor: Colors.grey.shade800,
                              valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                              strokeWidth: 8,
                            ),
                          ),
                        ),
                        Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('${(data.budget.spentPercentage * 100).toInt()}%', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                              const Text('Spent', style: TextStyle(color: Colors.grey, fontSize: 10)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 24),
                  // Legend
                  Expanded(
                    child: Column(
                      children: data.budget.breakdown.entries.map((e) => _buildBudgetRow(e.key, _formatCurrency(e.value))).toList(),
                    ),
                  )
                ],
              );
            }
          )
        ],
      ),
    );
  }

  Widget _buildBudgetRow(String label, String amount) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          Text(amount, style: const TextStyle(color: Colors.white, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildSitePhotos(DashboardData data, Color cardColor, Color borderColor, WidgetRef ref) {
    return _buildCard(
      'Site Photos',
      Icons.photo_library_outlined,
      cardColor,
      borderColor,
      Wrap(
        spacing: 16,
        runSpacing: 16,
        children: [
          ...data.photos.map((p) => SizedBox(
                width: 150,
                child: _buildPhotoItem(p['url']!, p['date']!, p['caption']!),
              )),
          
          // New Photo Button
          SizedBox(
            width: 150,
            child: InkWell(
              onTap: () => _pickPhoto(ref),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                height: 120,
                decoration: BoxDecoration(
                  color: const Color(0xFF111111),
                  border: Border.all(color: const Color(0xFF2A2A2A), style: BorderStyle.solid),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add, color: Colors.grey),
                    SizedBox(height: 8),
                    Text('New Photo', style: TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoItem(String url, String date, String caption) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 120,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            image: DecorationImage(
              image: NetworkImage(url),
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(date, style: const TextStyle(color: Colors.grey, fontSize: 10)),
        Text(caption, style: const TextStyle(color: Colors.white, fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis),
      ],
    );
  }
}
