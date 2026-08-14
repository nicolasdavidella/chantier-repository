import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../../data/models/project_model.dart';
import '../../providers/dashboard_providers.dart';
import 'package:intl/intl.dart';

class ProjectCard extends ConsumerWidget {
  final ProjectModel project;

  const ProjectCard({super.key, required this.project});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final currencyFormatter = NumberFormat.currency(locale: 'fr_FR', symbol: 'FCFA', decimalDigits: 0);

    return GestureDetector(
      onTap: () {
        // TODO: Navigate to project details
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          image: const DecorationImage(
            image: NetworkImage('https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?q=80&w=800&auto=format&fit=crop'), // Modern House Placeholder
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            // Dark gradient at the bottom for text readability
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: 120,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(32),
                    bottomRight: Radius.circular(32),
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.8),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            
            // Top Right Badge (Price or Status)
            Positioned(
              top: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  currencyFormatter.format(project.budgetActuel),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black87),
                ),
              ),
            ),
            
            // Top Left Badge (Rating/Status)
            Positioned(
              top: 16,
              left: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Row(
                  children: [
                    const FaIcon(FontAwesomeIcons.solidStar, size: 10, color: Colors.amber),
                    const SizedBox(width: 4),
                    Text(
                      '4.8',
                      style: theme.textTheme.labelSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Info (Title, Location, Heart)
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          project.titre,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const FaIcon(FontAwesomeIcons.locationDot, size: 12, color: Colors.white70),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                project.localisation['ville'] ?? 'Lieu inconnu',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                    ),
                    child: const FaIcon(FontAwesomeIcons.heart, size: 16, color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

