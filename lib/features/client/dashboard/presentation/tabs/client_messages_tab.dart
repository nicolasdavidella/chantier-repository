import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../../core/theme/app_spacing.dart';
import 'package:chantier_track/l10n/app_localizations.dart';

class ClientMessagesTab extends ConsumerWidget {
  const ClientMessagesTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)?.messagesTab ?? 'Messages'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.penToSquare, size: 20),
            onPressed: () {},
          )
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.md),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Rechercher une conversation...',
                  prefixIcon: const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: FaIcon(FontAwesomeIcons.magnifyingGlass, size: 16),
                  ),
                  filled: true,
                  fillColor: theme.colorScheme.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(100),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView.separated(
                itemCount: 4,
                separatorBuilder: (context, index) => Divider(
                  height: 1, 
                  indent: 80, 
                  endIndent: AppSpacing.xl, 
                  color: theme.colorScheme.outline.withValues(alpha: 0.1)
                ),
                itemBuilder: (context, index) {
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.sm),
                    leading: Stack(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: theme.colorScheme.primaryContainer,
                          child: FaIcon(FontAwesomeIcons.userLarge, color: theme.colorScheme.primary),
                        ),
                        if (index == 0) // Indicateur de présence
                          Positioned(
                            bottom: 2,
                            right: 2,
                            child: Container(
                              width: 14,
                              height: 14,
                              decoration: BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                                border: Border.all(color: theme.colorScheme.background, width: 2),
                              ),
                            ),
                          )
                      ],
                    ),
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          index == 0 ? 'Entreprise BTP SARL' : 'Chef de Chantier - Ali',
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: index == 0 ? FontWeight.bold : FontWeight.w600),
                        ),
                        Text(
                          '12:30',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: index == 0 ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant
                          ),
                        ),
                      ],
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        index == 0 ? 'Nous avons reçu les matériaux pour la phase 2.' : 'D\'accord, je vérifie ça tout de suite.',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: index == 0 ? theme.colorScheme.onSurface : theme.colorScheme.onSurfaceVariant,
                          fontWeight: index == 0 ? FontWeight.w500 : FontWeight.normal,
                        ),
                      ),
                    ),
                    trailing: index == 0 ? Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Text('1', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                    ) : null,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
