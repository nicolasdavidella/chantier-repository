import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/admin_verification_providers.dart';
import 'admin_verification_detail_screen.dart';
import 'package:intl/intl.dart';

class AdminVerificationDashboardScreen extends ConsumerStatefulWidget {
  const AdminVerificationDashboardScreen({super.key});

  @override
  ConsumerState<AdminVerificationDashboardScreen> createState() => _AdminVerificationDashboardScreenState();
}

class _AdminVerificationDashboardScreenState extends ConsumerState<AdminVerificationDashboardScreen> {
  String _currentFilter = 'ALL';

  @override
  Widget build(BuildContext context) {
    final statsAsync = ref.watch(dashboardStatsProvider);
    final listAsync = ref.watch(adminVerificationListProvider(_currentFilter));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vérification des Entreprises'),
      ),
      body: Column(
        children: [
          // Dashboard Stats
          statsAsync.when(
            data: (stats) => Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatCard('En attente', stats['pending'] ?? 0, Colors.orange),
                  _buildStatCard('Vérifiées', stats['approved'] ?? 0, Colors.green),
                  _buildStatCard('Rejetées', stats['rejected'] ?? 0, Colors.red),
                ],
              ),
            ),
            loading: () => const LinearProgressIndicator(),
            error: (e, _) => Text('Erreur: \$e'),
          ),

          // Filters
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('Tout', 'ALL'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Soumis', 'SUBMITTED'),
                  const SizedBox(width: 8),
                  _buildFilterChip('En cours', 'UNDER_REVIEW'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Approuvés', 'APPROVED'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Rejetés', 'REJECTED'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // List
          Expanded(
            child: listAsync.when(
              data: (requests) {
                if (requests.isEmpty) {
                  return const Center(child: Text('Aucune demande trouvée.'));
                }
                return ListView.builder(
                  itemCount: requests.length,
                  itemBuilder: (context, index) {
                    final request = requests[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        leading: _getStatusIcon(request.status),
                        title: Text('Entreprise ID: \${request.entrepriseId}'),
                        subtitle: Text('Soumis le: \${DateFormat('dd/MM/yyyy HH:mm').format(request.createdAt)}'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AdminVerificationDetailScreen(request: request),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Erreur: \$e')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, int count, Color color) {
    return Card(
      elevation: 4,
      child: Container(
        width: 100,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              count.toString(),
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    return ChoiceChip(
      label: Text(label),
      selected: _currentFilter == value,
      onSelected: (selected) {
        if (selected) {
          setState(() => _currentFilter = value);
        }
      },
    );
  }

  Widget _getStatusIcon(String status) {
    switch (status) {
      case 'SUBMITTED':
      case 'UNDER_REVIEW':
        return const Icon(Icons.hourglass_top, color: Colors.orange);
      case 'APPROVED':
        return const Icon(Icons.check_circle, color: Colors.green);
      case 'REJECTED':
        return const Icon(Icons.cancel, color: Colors.red);
      default:
        return const Icon(Icons.help_outline);
    }
  }
}
