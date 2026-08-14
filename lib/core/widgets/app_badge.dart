import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

enum AppBadgeStatus {
  inProgress, // En cours
  delayed,    // En retard
  completed,  // Terminé
  anomaly,    // Anomalie détectée
  neutral     // Information neutre
}

class AppBadge extends StatelessWidget {
  final String label;
  final AppBadgeStatus status;
  final bool hasIcon;

  const AppBadge({
    super.key,
    required this.label,
    this.status = AppBadgeStatus.neutral,
    this.hasIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    Color backgroundColor;
    Color foregroundColor;
    IconData? icon;

    switch (status) {
      case AppBadgeStatus.inProgress:
        backgroundColor = AppColors.info.withOpacity(0.15);
        foregroundColor = isDark ? AppColors.info : const Color(0xFF1976D2);
        icon = Icons.sync;
        break;
      case AppBadgeStatus.delayed:
        backgroundColor = AppColors.warning.withOpacity(0.15);
        foregroundColor = isDark ? AppColors.warning : AppColors.warningDark;
        icon = Icons.schedule;
        break;
      case AppBadgeStatus.completed:
        backgroundColor = AppColors.success.withOpacity(0.15);
        foregroundColor = isDark ? AppColors.success : AppColors.successDark;
        icon = Icons.check_circle_outline;
        break;
      case AppBadgeStatus.anomaly:
        backgroundColor = theme.colorScheme.error.withOpacity(0.15);
        foregroundColor = theme.colorScheme.error;
        icon = Icons.warning_amber_rounded;
        break;
      case AppBadgeStatus.neutral:
      default:
        backgroundColor = theme.colorScheme.outline.withOpacity(0.15);
        foregroundColor = theme.colorScheme.onSurface;
        icon = Icons.info_outline;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(100), // Fully rounded like pill
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (hasIcon && icon != null) ...[
            Icon(icon, size: 14, color: foregroundColor),
            AppSpacing.hXs,
          ],
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: foregroundColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
