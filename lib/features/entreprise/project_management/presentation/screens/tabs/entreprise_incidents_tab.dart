import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../../../core/theme/app_spacing.dart';

class EntrepriseIncidentsTab extends ConsumerStatefulWidget {
  final String projectId;
  const EntrepriseIncidentsTab({super.key, required this.projectId});

  @override
  ConsumerState<EntrepriseIncidentsTab> createState() => _EntrepriseIncidentsTabState();
}

class _EntrepriseIncidentsTabState extends ConsumerState<EntrepriseIncidentsTab> {
  final List<Map<String, dynamic>> _incidents = [];

  void _reportIncident() {
    showDialog(
      context: context,
      builder: (ctx) {
        final textController = TextEditingController();
        return AlertDialog(
          title: const Text('Signaler un incident/retard', style: TextStyle(color: Colors.red)),
          content: TextField(
            controller: textController,
            decoration: const InputDecoration(
              hintText: 'Nature de l\'incident...',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
              onPressed: () {
                if (textController.text.isNotEmpty) {
                  setState(() {
                    _incidents.insert(0, {
                      'date': 'A l\'instant',
                      'desc': textController.text,
                      'resolved': false,
                    });
                  });
                }
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Incident signalé !')));
              },
              child: const Text('Signaler'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: _incidents.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FaIcon(FontAwesomeIcons.checkDouble, size: 48, color: Colors.green.withValues(alpha: 0.5)),
                  AppSpacing.vMd,
                  const Text('Aucun incident signalé', style: TextStyle(color: Colors.grey)),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.lg),
              itemCount: _incidents.length,
              separatorBuilder: (_, __) => AppSpacing.vMd,
              itemBuilder: (context, index) {
                final incident = _incidents[index];
                final isResolved = incident['resolved'] as bool;
                
                return Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    side: BorderSide(color: isResolved ? Colors.green : Colors.red),
                  ),
                  child: ListTile(
                    leading: Icon(
                      isResolved ? Icons.check_circle : Icons.warning_rounded,
                      color: isResolved ? Colors.green : Colors.red,
                    ),
                    title: Text(incident['date']),
                    subtitle: Text(incident['desc']),
                    trailing: isResolved
                        ? const Text('Résolu', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold))
                        : TextButton(
                            onPressed: () {
                              setState(() {
                                incident['resolved'] = true;
                              });
                            },
                            child: const Text('Marquer résolu'),
                          ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _reportIncident,
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.warning),
        label: const Text('Signaler'),
      ),
    );
  }
}
