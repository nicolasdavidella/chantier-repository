import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../../core/theme/app_spacing.dart';

import '../../providers/search_entreprises_provider.dart';
import '../widgets/entreprise_card.dart';
import '../widgets/filter_bottom_sheet.dart';
import 'package:chantier_track/core/theme/app_colors.dart';


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
      backgroundColor: const Color(0xFFFAF8F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF143D2B),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Trouver une entreprise',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Colors.white),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(80),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.md),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFC8E6C9), width: 1.2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: _onSearchChanged,
                      decoration: const InputDecoration(
                        hintText: 'Rechercher par nom, mot-clé...',
                        hintStyle: TextStyle(color: AppColors.textSecondaryLight, fontSize: 13),
                        prefixIcon: Icon(Icons.search, color: Color(0xFF143D2B)),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 12),
                      ),
                    ),
                  ),
                ),
                AppSpacing.hSm,
                InkWell(
                  onTap: _showFilters,
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF10B981).withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.tune, color: Colors.white, size: 22),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          // Background ambient glows
          Positioned(
            top: 20,
            right: -60,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFE8F5E9).withValues(alpha: 0.8),
                    const Color(0xFFE8F5E9).withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
          entreprises.when(
            loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF143D2B))),
            error: (err, stack) => Center(
              child: Text('Erreur: $err', style: TextStyle(color: theme.colorScheme.error)),
            ),
            data: (entreprisesList) => entreprisesList.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F5E9),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.search_off_rounded, size: 54, color: Color(0xFF143D2B)),
                        ),
                        AppSpacing.vMd,
                        const Text(
                          'Aucune entreprise trouvée',
                          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Color(0xFF143D2B)),
                        ),
                        AppSpacing.vXs,
                        const Text(
                          'Essayez de modifier vos filtres ou mots-clés.',
                          style: TextStyle(color: AppColors.textSecondaryLight, fontSize: 13),
                        ),
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
                          .slideY(begin: 0.1);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: comparisonList.isNotEmpty
          ? FloatingActionButton.extended(
              heroTag: null,
              onPressed: () => context.push('/client/compare_entreprises'),
              backgroundColor: const Color(0xFF143D2B),
              foregroundColor: Colors.white,
              icon: const Icon(Icons.compare_arrows_rounded, color: Color(0xFF86EFAC)),
              label: Text(
                'Comparer (${comparisonList.length}/3)',
                style: const TextStyle(fontWeight: FontWeight.w800, letterSpacing: 0.3),
              ),
            ).animate().slideY(begin: 1.0, duration: 300.ms, curve: Curves.easeOutBack)
          : null,
    );
  }
}
