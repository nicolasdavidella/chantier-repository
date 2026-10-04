import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:chantier_track/core/theme/app_colors.dart';
import 'app_settings_modal.dart';

/// Modal bottom sheet pour les 4 petits carrés (Menu des Services & Accès Rapide)
void showQuickServicesModal({
  required BuildContext context,
  required bool isFrench,
  required void Function(int) onSelectTab,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => QuickServicesModal(
      isFrench: isFrench,
      onSelectTab: onSelectTab,
    ),
  );
}

class QuickServicesModal extends StatelessWidget {
  final bool isFrench;
  final void Function(int) onSelectTab;

  const QuickServicesModal({
    super.key,
    required this.isFrench,
    required this.onSelectTab,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.only(top: 12, bottom: 32, left: 20, right: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 48,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.grid_view_rounded,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isFrench ? 'Services & Raccourcis' : 'Services & Shortcuts',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    Text(
                      isFrench
                          ? 'Tous vos outils de chantier au même endroit'
                          : 'All your construction tools in one place',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => Navigator.pop(context),
                color: Colors.grey.shade600,
              ),
            ],
          ),

          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 16),

          // Services Grid
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 14,
            crossAxisSpacing: 14,
            childAspectRatio: 0.85,
            children: [
              _QuickServiceItem(
                icon: Icons.architecture_rounded,
                label: isFrench ? 'NICO IA' : 'NICO AI',
                color: const Color(0xFF1B4D3E),
                onTap: () {
                  Navigator.pop(context);
                  context.push('/client/ia_chat');
                },
              ),
              _QuickServiceItem(
                icon: Icons.assignment_rounded,
                label: isFrench ? 'Mes Projets' : 'My Projects',
                color: const Color(0xFF10B981),
                onTap: () {
                  Navigator.pop(context);
                  onSelectTab(1);
                },
              ),
              _QuickServiceItem(
                icon: Icons.search_rounded,
                label: isFrench ? 'Trouver un Pro' : 'Find a Pro',
                color: const Color(0xFFF59E0B),
                onTap: () {
                  Navigator.pop(context);
                  onSelectTab(2);
                },
              ),
              _QuickServiceItem(
                icon: Icons.chat_bubble_outline_rounded,
                label: isFrench ? 'Discussions' : 'Chat',
                color: const Color(0xFF3B82F6),
                onTap: () {
                  Navigator.pop(context);
                  onSelectTab(3);
                },
              ),
              _QuickServiceItem(
                icon: Icons.report_problem_rounded,
                label: isFrench ? 'Réclamations' : 'Claims',
                color: const Color(0xFFEF4444),
                onTap: () {
                  Navigator.pop(context);
                  context.push('/client/reclamation');
                },
              ),
              _QuickServiceItem(
                icon: Icons.person_outline_rounded,
                label: isFrench ? 'Mon Profil' : 'My Profile',
                color: const Color(0xFF8B5CF6),
                onTap: () {
                  Navigator.pop(context);
                  onSelectTab(4);
                },
              ),
              _QuickServiceItem(
                icon: Icons.settings_rounded,
                label: isFrench ? 'Paramètres' : 'Settings',
                color: AppColors.primary,
                onTap: () {
                  Navigator.pop(context);
                  showAppSettingsModal(context);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickServiceItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickServiceItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 22),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
