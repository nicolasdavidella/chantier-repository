import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../../core/theme/app_spacing.dart';

import '../../providers/search_entreprises_provider.dart';
import '../widgets/entreprise_card.dart';
import '../widgets/filter_bottom_sheet.dart';

class SearchEntreprisesScreen extends ConsumerStatefulWidget {
  const SearchEntreprisesScreen({super.key});

  @override
  ConsumerState<SearchEntreprisesScreen> createState() => _SearchEntreprisesScreenState();
}

class _SearchEntreprisesScreenState extends ConsumerState<SearchEntreprisesScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.text = ref.read(searchFiltersProvider).query;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    ref.read(searchFiltersProvider.notifier).update((state) => state.copyWith(query: value));
  }

  void _showFilters() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const FilterBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final entreprises = ref.watch(filteredEntreprisesProvider);
    final comparisonList = ref.watch(comparisonListProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trouver une entreprise'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(70),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.lg),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    decoration: InputDecoration(
                      hintText: 'Rechercher par nom, mot-clé...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: theme.colorScheme.surfaceContainerHighest,
                      contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 0),
                    ),
                  ),
                ),
                AppSpacing.hSm,
                InkWell(
                  onTap: _showFilters,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                    ),
                    child: Icon(Icons.tune, color: theme.colorScheme.onPrimaryContainer),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: entreprises.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Text('Erreur: $err', style: TextStyle(color: theme.colorScheme.error)),
        ),
        data: (entreprisesList) => entreprisesList.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.search_off, size: 64, color: Colors.grey),
                    AppSpacing.vMd,
                    Text('Aucune entreprise trouvée.', style: theme.textTheme.titleMedium),
                    AppSpacing.vXs,
                    Text('Essayez de modifier vos filtres.', style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey)),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(AppSpacing.lg),
                itemCount: entreprisesList.length,
                itemBuilder: (context, index) {
                  return EntrepriseCard(entreprise: entreprisesList[index])
                      .animate()
                      .fadeIn(delay: (50 * index).ms)
                      .slideY(begin: 0.2);
                },
              ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: comparisonList.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: () => context.push('/client/compare_entreprises'),
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              icon: const Icon(Icons.compare_arrows),
              label: Text('Comparer (${comparisonList.length}/3)'),
            ).animate().slideY(begin: 1.0, duration: 300.ms, curve: Curves.easeOutBack)
          : null,
    );
  }
}
