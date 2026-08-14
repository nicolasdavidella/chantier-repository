import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../providers/search_entreprises_provider.dart';

class FilterBottomSheet extends ConsumerStatefulWidget {
  const FilterBottomSheet({super.key});

  @override
  ConsumerState<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends ConsumerState<FilterBottomSheet> {
  String _selectedVille = 'Toutes';
  String _selectedSpecialite = 'Toutes';
  double _minRating = 0;
  bool _certifieOnly = false;

  final List<String> _villes = ['Toutes', 'Douala', 'Yaoundé', 'Bafoussam', 'Bamenda', 'Garoua'];
  final List<String> _specialites = ['Toutes', 'Gros oeuvre', 'Maçonnerie', 'Finitions', 'Peinture', 'Carrelage', 'Plomberie', 'Électricité', 'Menuiserie', 'Charpente'];

  @override
  void initState() {
    super.initState();
    final currentFilters = ref.read(searchFiltersProvider);
    _selectedVille = currentFilters.ville ?? 'Toutes';
    _selectedSpecialite = currentFilters.specialite ?? 'Toutes';
    _minRating = currentFilters.minRating;
    _certifieOnly = currentFilters.certifieOnly;
  }

  void _applyFilters() {
    ref.read(searchFiltersProvider.notifier).update((state) => state.copyWith(
      ville: _selectedVille,
      specialite: _selectedSpecialite,
      minRating: _minRating,
      certifieOnly: _certifieOnly,
    ));
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Filtres', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => context.pop(),
              ),
            ],
          ),
          AppSpacing.vLg,
          
          DropdownButtonFormField<String>(
            initialValue: _selectedVille,
            decoration: const InputDecoration(labelText: 'Ville', border: OutlineInputBorder()),
            items: _villes.map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
            onChanged: (val) => setState(() => _selectedVille = val ?? 'Toutes'),
          ),
          AppSpacing.vMd,
          
          DropdownButtonFormField<String>(
            initialValue: _selectedSpecialite,
            decoration: const InputDecoration(labelText: 'Spécialité', border: OutlineInputBorder()),
            items: _specialites.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
            onChanged: (val) => setState(() => _selectedSpecialite = val ?? 'Toutes'),
          ),
          AppSpacing.vLg,
          
          Text('Note minimale: ${_minRating.toStringAsFixed(1)} étoiles'),
          Slider(
            value: _minRating,
            min: 0,
            max: 5,
            divisions: 10,
            label: _minRating.toStringAsFixed(1),
            onChanged: (val) => setState(() => _minRating = val),
          ),
          AppSpacing.vMd,
          
          SwitchListTile(
            title: const Text('Entreprises certifiées uniquement'),
            value: _certifieOnly,
            onChanged: (val) => setState(() => _certifieOnly = val),
            contentPadding: EdgeInsets.zero,
          ),
          
          AppSpacing.vXxl,
          
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _applyFilters,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Appliquer les filtres'),
            ),
          ),
          AppSpacing.vLg,
        ],
      ),
    );
  }
}
