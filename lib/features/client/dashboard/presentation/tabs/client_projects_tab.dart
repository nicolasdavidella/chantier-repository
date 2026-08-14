import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../../core/theme/app_spacing.dart';

class ClientProjectsTab extends ConsumerWidget {
  const ClientProjectsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Projets'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.filter, size: 20),
            onPressed: () {},
          )
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Tabs for project status
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip(theme, 'Tous', true),
                    AppSpacing.hSm,
                    _buildFilterChip(theme, 'En cours', false),
                    AppSpacing.hSm,
                    _buildFilterChip(theme, 'En attente', false),
                    AppSpacing.hSm,
                    _buildFilterChip(theme, 'Terminés', false),
                  ],
                ),
              ),
              AppSpacing.vLg,
              Expanded(
                child: ListView.builder(
                  itemCount: 3,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: Container(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: FaIcon(FontAwesomeIcons.building, color: theme.colorScheme.primary),
                              ),
                            ),
                            AppSpacing.hLg,
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Villa Horizon', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                                  AppSpacing.vXs,
                                  Text('Dakar, Almadies', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                                ],
                              ),
                            ),
                            const FaIcon(FontAwesomeIcons.chevronRight, size: 16),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(ThemeData theme, String label, bool isSelected) {
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) {},
      backgroundColor: theme.colorScheme.surface,
      selectedColor: theme.colorScheme.primary,
      labelStyle: TextStyle(
        color: isSelected ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
    );
  }
}
