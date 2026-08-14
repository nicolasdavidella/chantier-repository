import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../screens/ia_chat_screen.dart';
import '../../devis_simulator/presentation/devis_simulator_screen.dart';

class IaFab extends StatelessWidget {
  const IaFab({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FloatingActionButton(
      onPressed: () {
        HapticFeedback.mediumImpact();
        _showIaOptions(context, theme);
      },
      backgroundColor: theme.colorScheme.primary, // Changed to primary for consistency
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
      child: const FaIcon(FontAwesomeIcons.wandMagicSparkles, color: Colors.white, size: 20),
    )
        .animate(onPlay: (controller) => controller.repeat(reverse: true))
        .scale(begin: const Offset(1, 1), end: const Offset(1.05, 1.05), duration: 2.seconds, curve: Curves.easeInOut);
  }

  void _showIaOptions(BuildContext context, ThemeData theme) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.outline.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text('Assistant ChantierTrack', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: FaIcon(FontAwesomeIcons.calculator, color: theme.colorScheme.primary, size: 20),
              ),
              title: const Text('Simulateur de Devis IA', style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: const Text('Obtenez une estimation rapide pour vos travaux'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const DevisSimulatorScreen()),
                );
              },
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondaryContainer.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: FaIcon(FontAwesomeIcons.solidCommentDots, color: theme.colorScheme.secondary, size: 20),
              ),
              title: const Text('Chatbot Expert', style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: const Text('Posez vos questions sur la construction'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const IaChatScreen()),
                );
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
