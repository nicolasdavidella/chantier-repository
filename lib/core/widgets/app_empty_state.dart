import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../theme/app_spacing.dart';

class AppEmptyState extends StatelessWidget {
  final String title;
  final String description;
  final String lottieAsset;
  final Widget? action;

  const AppEmptyState({
    super.key,
    required this.title,
    required this.description,
    required this.lottieAsset,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Lottie.asset(
              lottieAsset,
              width: 200,
              height: 200,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Icon(
                  Icons.inbox_outlined,
                  size: 64,
                  color: theme.colorScheme.outline,
                );
              },
            ),
            AppSpacing.vLg,
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            AppSpacing.vSm,
            Text(
              description,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            if (action != null) ...[
              AppSpacing.vLg,
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
