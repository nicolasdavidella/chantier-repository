import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../theme/app_spacing.dart';
import '../theme/app_colors.dart';

class AppLoadingShimmer extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const AppLoadingShimmer({
    super.key,
    this.width = double.infinity,
    required this.height,
    this.borderRadius = AppSpacing.radiusSm,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final baseColor = isDark ? AppColors.surfaceDark : AppColors.borderLight;
    final highlightColor = isDark ? AppColors.borderDark : AppColors.surfaceLight;
    
    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: baseColor,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

// Pre-built layout for list items
class AppListShimmer extends StatelessWidget {
  final int itemCount;

  const AppListShimmer({super.key, this.itemCount = 3});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      separatorBuilder: (_, __) => AppSpacing.vMd,
      itemBuilder: (_, __) {
        return Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
            ),
            borderRadius: AppSpacing.borderRadiusMd,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppLoadingShimmer(width: 48, height: 48, borderRadius: 24),
              AppSpacing.hMd,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AppLoadingShimmer(height: 16, width: 120),
                    AppSpacing.vSm,
                    const AppLoadingShimmer(height: 12, width: double.infinity),
                    AppSpacing.vXs,
                    const AppLoadingShimmer(height: 12, width: 200),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
