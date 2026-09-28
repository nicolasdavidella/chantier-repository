import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../data/models/certification_request_model.dart';
import '../../providers/admin_providers.dart';

class CertificationsScreen extends ConsumerStatefulWidget {
  const CertificationsScreen({super.key});

  @override
  ConsumerState<CertificationsScreen> createState() =>
      _CertificationsScreenState();
}

class _CertificationsScreenState extends ConsumerState<CertificationsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isWideScreen = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Certifications'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: theme.colorScheme.primary,
          unselectedLabelColor: Colors.grey,
          indicatorColor: theme.colorScheme.primary,
          tabs: const [
            Tab(text: 'En attente'),
            Tab(text: 'Certifiées'),
            Tab(text: 'Rejetées'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _PendingCertificationsView(isWideScreen: isWideScreen),
          const Center(child: Text('Historique des certifiées (à venir)')),
          const Center(child: Text('Historique des rejetées (à venir)')),
        ],
      ),
    );
  }
}

class _PendingCertificationsView extends ConsumerWidget {
  final bool isWideScreen;

  const _PendingCertificationsView({required this.isWideScreen});

  String _timeAgo(DateTime? d) {
    if (d == null) return 'Inconnu';
    final diff = DateTime.now().difference(d);
    if (diff.inDays > 0) return 'il y a ${diff.inDays} j';
    if (diff.inHours > 0) return 'il y a ${diff.inHours} h';
    if (diff.inMinutes > 0) return 'il y a ${diff.inMinutes} m';
    return 'à l\'instant';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingAsync = ref.watch(pendingCertificationsProvider);
    final theme = Theme.of(context);

    return pendingAsync.when(
      data: (demandes) {
        if (demandes.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.check_circle_outline,
                  size: 64,
                  color: Colors.green[300],
                ),
                AppSpacing.vMd,
                Text(
                  'Aucune demande en attente',
                  style: theme.textTheme.titleMedium,
                ),
              ],
            ),
          );
        }

        if (isWideScreen) {
          // Table view for desktop
          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('Entreprise')),
                    DataColumn(label: Text('RCCM')),
                    DataColumn(label: Text('Ville(s)')),
                    DataColumn(label: Text('Date de soumission')),
                    DataColumn(label: Text('Documents')),
                    DataColumn(label: Text('Statut')),
                    DataColumn(label: Text('Actions')),
                  ],
                  rows: demandes.map((d) {
                    return DataRow(
                      cells: [
                        DataCell(
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 16,
                                backgroundColor:
                                    theme.colorScheme.primaryContainer,
                                child: const Icon(Icons.business, size: 16),
                              ),
                              AppSpacing.hSm,
                              Text(
                                d.raisonSociale,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        DataCell(Text(d.rccm)),
                        DataCell(Text(d.villesZones.join(', '))),
                        DataCell(Text(_timeAgo(d.dateSoumission))),
                        DataCell(Text('${d.documents.length} doc(s)')),
                        DataCell(
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.amber.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'En attente',
                              style: TextStyle(
                                color: Colors.amber,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                        DataCell(
                          Row(
                            children: [
                              TextButton.icon(
                                onPressed: () =>
                                    _showExamineDialog(context, d, ref),
                                icon: const Icon(Icons.visibility, size: 18),
                                label: const Text('Examiner'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          );
        }

        // List view for mobile
        return ListView.builder(
          padding: const EdgeInsets.all(AppSpacing.md),
          itemCount: demandes.length,
          itemBuilder: (context, index) {
            final d = demandes[index];
            return Card(
              margin: const EdgeInsets.only(bottom: AppSpacing.md),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: theme.colorScheme.primaryContainer,
                  child: const Icon(Icons.business),
                ),
                title: Text(
                  d.raisonSociale,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  'Soumis ${_timeAgo(d.dateSoumission)}\n${d.documents.length} document(s)',
                ),
                isThreeLine: true,
                trailing: FilledButton.tonal(
                  onPressed: () => _showExamineDialog(context, d, ref),
                  child: const Text('Examiner'),
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Erreur: $err')),
    );
  }

  void _showExamineDialog(
    BuildContext context,
    CertificationRequestModel demande,
    WidgetRef ref,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => _ExamineDemandeDialog(demande: demande),
    );
  }
}

class _ExamineDemandeDialog extends StatefulWidget {
  final CertificationRequestModel demande;

  const _ExamineDemandeDialog({required this.demande});

  @override
  State<_ExamineDemandeDialog> createState() => _ExamineDemandeDialogState();
}

class _ExamineDemandeDialogState extends State<_ExamineDemandeDialog> {
  late List<bool> _docsVerified;
  bool _isSaving = false;
  final TextEditingController _motifController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _docsVerified = List.filled(widget.demande.documents.length, false);
  }

  @override
  void dispose() {
    _motifController.dispose();
    super.dispose();
  }

  bool get _allVerified =>
      _docsVerified.isNotEmpty && !_docsVerified.contains(false);

  Future<void> _handleDecision(String status) async {
    setState(() => _isSaving = true);
    try {
      final batch = FirebaseFirestore.instance.batch();

      final demandeRef = FirebaseFirestore.instance
          .collection('demandes_certification')
          .doc(widget.demande.entrepriseId);
      final entrepriseRef = FirebaseFirestore.instance
          .collection('entreprises')
          .doc(widget.demande.entrepriseId);

      if (status == 'certifiee') {
        batch.update(demandeRef, {
          'statut': 'certifiee',
          'dateDecision': FieldValue.serverTimestamp(),
          // 'adminId': currentUserId // ideally
        });
        batch.update(entrepriseRef, {
          'certifie': true,
          'statutVerification': 'approuve',
        });
      } else if (status == 'rejetee') {
        if (_motifController.text.trim().isEmpty) {
          throw Exception("Motif de rejet obligatoire.");
        }
        batch.update(demandeRef, {
          'statut': 'rejetee',
          'dateDecision': FieldValue.serverTimestamp(),
          'motifRejet': _motifController.text.trim(),
        });
        batch.update(entrepriseRef, {'statutVerification': 'rejete'});
      }

      await batch.commit();

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              status == 'certifiee'
                  ? 'Entreprise certifiée avec succès !'
                  : 'Demande rejetée.',
            ),
            backgroundColor: status == 'certifiee' ? Colors.green : Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 600,
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(Icons.business_center),
                AppSpacing.hSm,
                Expanded(
                  child: Text(
                    'Examen: ${widget.demande.raisonSociale}',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(),
            AppSpacing.vSm,
            Text('RCCM: ${widget.demande.rccm} | NIU: ${widget.demande.niu}'),
            Text('Contact: ${widget.demande.contact}'),
            AppSpacing.vLg,
            const Text(
              'Documents fournis (cliquer pour ouvrir):',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            AppSpacing.vSm,

            if (widget.demande.documents.isEmpty)
              const Text(
                'Aucun document fourni.',
                style: TextStyle(color: Colors.red),
              ),

            ...List.generate(widget.demande.documents.length, (index) {
              final doc = widget.demande.documents[index];
              return CheckboxListTile(
                value: _docsVerified[index],
                onChanged: (val) {
                  setState(() {
                    _docsVerified[index] = val ?? false;
                  });
                },
                title: Text(doc.nom),
                subtitle: Text('Type: ${doc.type}'),
                secondary: IconButton(
                  icon: const Icon(Icons.open_in_new),
                  onPressed: () async {
                    final uri = Uri.parse(doc.url);
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri);
                    }
                  },
                ),
                controlAffinity: ListTileControlAffinity.leading,
              );
            }),

            AppSpacing.vLg,
            TextField(
              controller: _motifController,
              decoration: const InputDecoration(
                labelText: 'Motif de rejet (obligatoire si rejeté)',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            AppSpacing.vLg,
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  onPressed: _isSaving
                      ? null
                      : () => _handleDecision('rejetee'),
                  icon: const Icon(Icons.cancel),
                  label: const Text('Rejeter'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                  ),
                ),
                AppSpacing.hMd,
                FilledButton.icon(
                  onPressed: (_isSaving || !_allVerified)
                      ? null
                      : () => _handleDecision('certifiee'),
                  icon: const Icon(Icons.check_circle),
                  label: const Text('Valider la certification'),
                  style: FilledButton.styleFrom(
                    backgroundColor: _allVerified ? Colors.green : Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
