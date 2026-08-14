import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/connectivity/sync_queue_provider.dart';
import '../../providers/chef_chantier_providers.dart';

class AddExpenseScreen extends ConsumerStatefulWidget {
  final String projectId;

  const AddExpenseScreen({super.key, required this.projectId});

  @override
  ConsumerState<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends ConsumerState<AddExpenseScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  String? _selectedCategory;
  bool _photoTaken = false;

  final List<String> _categories = ['Matériaux', 'Transport', 'Main d\'œuvre', 'Équipement', 'Autre'];

  void _takePhoto() {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ouverture de l\'appareil photo...')));
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) setState(() => _photoTaken = true);
    });
  }

  void _saveExpense() {
    if (_amountController.text.isEmpty || _selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Veuillez remplir le montant et la catégorie.')));
      return;
    }
    
    if (!_photoTaken) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Veuillez prendre une photo du justificatif !')));
      return;
    }

    final expenseData = {
      'projectId': widget.projectId,
      'amount': double.tryParse(_amountController.text) ?? 0,
      'title': _titleController.text.isEmpty ? 'Dépense de chantier' : _titleController.text,
      'category': _selectedCategory,
      'timestamp': DateTime.now().toIso8601String(),
      'location': 'Lat: 4.0511, Lng: 9.7085', // Simulated GPS
    };

    final item = SyncAction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: 'expense',
      data: expenseData,
    );

    ref.read(syncQueueProvider.notifier).addAction(item);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Dépense enregistrée (hors-ligne). Synchronisation en attente.')),
    );
    context.pop();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Déclarer une Dépense')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          // 1. Amount Input (Large)
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
            decoration: const InputDecoration(
              hintText: '0',
              suffixText: 'FCFA',
              border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
              contentPadding: EdgeInsets.all(AppSpacing.xl),
            ),
          ).animate().slideY(begin: -0.1).fadeIn(duration: 400.ms),

          AppSpacing.vXxl,

          // 2. Title / Description
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Motif (Optionnel)',
              prefixIcon: Icon(Icons.description),
              border: OutlineInputBorder(),
            ),
          ).animate().slideX(begin: 0.1).fadeIn(delay: 100.ms),

          AppSpacing.vXxl,

          // 3. Category Chips
          Text('Catégorie', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          AppSpacing.vSm,
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: _categories.map((c) => ChoiceChip(
              label: Text(c),
              selected: _selectedCategory == c,
              onSelected: (selected) {
                if (selected) setState(() => _selectedCategory = c);
              },
            )).toList(),
          ).animate().slideX(begin: 0.1).fadeIn(delay: 200.ms),

          AppSpacing.vXxl,

          // 4. Receipt Photo
          Text('Justificatif (Requis)', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          AppSpacing.vSm,
          InkWell(
            onTap: _takePhoto,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            child: Container(
              height: 150,
              decoration: BoxDecoration(
                color: _photoTaken ? Colors.green.withValues(alpha: 0.1) : theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                border: Border.all(color: _photoTaken ? Colors.green : theme.colorScheme.outline, width: 2),
              ),
              child: _photoTaken
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.check_circle, color: Colors.green, size: 48),
                        AppSpacing.hMd,
                        Text('Justificatif scanné', style: TextStyle(color: Colors.green[800], fontWeight: FontWeight.bold)),
                      ],
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.receipt_long, size: 48, color: theme.colorScheme.primary),
                        AppSpacing.vSm,
                        const Text('Scanner la facture ou reçu', style: TextStyle(fontWeight: FontWeight.bold)),
                        AppSpacing.vXs,
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.location_on, size: 14, color: Colors.grey),
                            Text(' Position GPS activée', style: TextStyle(color: Colors.grey, fontSize: 12)),
                          ],
                        )
                      ],
                    ),
            ),
          ).animate().fadeIn(delay: 300.ms),

          AppSpacing.vXxl,
          AppSpacing.vXxl,

          // 5. Submit Button
          SizedBox(
            width: double.infinity,
            height: 60,
            child: AppButton(
              onPressed: _saveExpense,
              text: 'ENREGISTRER',
              icon: Icons.save,
            ),
          ).animate().scale(delay: 400.ms),
          
          AppSpacing.vXxl,
        ],
      ),
    );
  }
}
