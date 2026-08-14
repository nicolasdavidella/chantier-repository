import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../providers/create_project_provider.dart';

class StepBudgetDates extends ConsumerStatefulWidget {
  final GlobalKey<FormState> formKey;
  
  const StepBudgetDates({super.key, required this.formKey});

  @override
  ConsumerState<StepBudgetDates> createState() => _StepBudgetDatesState();
}

class _StepBudgetDatesState extends ConsumerState<StepBudgetDates> {
  late TextEditingController _budgetController;
  DateTime? _dateDebut;
  DateTime? _dateFin;

  @override
  void initState() {
    super.initState();
    final data = ref.read(projectCreationProvider).value;
    _budgetController = TextEditingController(text: data?.budget?.toStringAsFixed(0) ?? '');
    _dateDebut = data?.dateDebut;
    _dateFin = data?.dateFin;
  }

  @override
  void dispose() {
    _budgetController.dispose();
    super.dispose();
  }

  void _saveData() {
    ref.read(projectCreationProvider.notifier).updateField(
      budget: double.tryParse(_budgetController.text),
      dateDebut: _dateDebut,
      dateFin: _dateFin,
    );
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final initialDate = isStart ? (_dateDebut ?? DateTime.now()) : (_dateFin ?? (_dateDebut ?? DateTime.now()));
    final firstDate = isStart ? DateTime.now() : (_dateDebut ?? DateTime.now());
    final lastDate = DateTime.now().add(const Duration(days: 3650)); // 10 years

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: Theme.of(context).colorScheme.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _dateDebut = picked;
          if (_dateFin != null && _dateFin!.isBefore(_dateDebut!)) {
            _dateFin = null;
          }
        } else {
          _dateFin = picked;
        }
      });
      _saveData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Form(
        key: widget.formKey,
        onChanged: _saveData,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Budget et Planning',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            AppSpacing.vSm,
            Text(
              'Estimez votre budget et définissez la période de réalisation souhaitée.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
            ),
            AppSpacing.vXxl,
            TextFormField(
              controller: _budgetController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Budget prévisionnel',
                hintText: 'Ex: 15000000',
                suffixText: 'FCFA',
                prefixIcon: Icon(Icons.account_balance_wallet),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) return 'Le budget est requis';
                final parsed = double.tryParse(value);
                if (parsed == null) return 'Entrez un nombre valide';
                if (parsed <= 0) return 'Le budget doit être supérieur à 0';
                return null;
              },
            ),
            AppSpacing.vLg,
            Row(
              children: [
                Expanded(
                  child: _DateTile(
                    label: 'Date de début',
                    date: _dateDebut,
                    onTap: () => _selectDate(context, true),
                  ),
                ),
                AppSpacing.hMd,
                Expanded(
                  child: _DateTile(
                    label: 'Fin estimée',
                    date: _dateFin,
                    onTap: () => _selectDate(context, false),
                  ),
                ),
              ],
            ),
            if (_dateDebut == null || _dateFin == null) ...[
              AppSpacing.vMd,
              Text(
                'Veuillez sélectionner les dates pour continuer.',
                style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 12),
              ),
            ]
          ],
        ),
      ),
    );
  }
}

class _DateTile extends StatelessWidget {
  final String label;
  final DateTime? date;
  final VoidCallback onTap;

  const _DateTile({required this.label, this.date, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final DateFormat formatter = DateFormat('dd MMM yyyy');

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          border: Border.all(color: theme.colorScheme.outline),
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            AppSpacing.vXs,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  date != null ? formatter.format(date!) : 'Sélectionner',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: date != null ? FontWeight.bold : FontWeight.normal,
                    color: date != null ? theme.colorScheme.onSurface : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                Icon(Icons.calendar_today, size: 16, color: theme.colorScheme.primary),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
