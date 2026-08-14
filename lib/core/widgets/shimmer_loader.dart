import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ShimmerLoader extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const ShimmerLoader({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8.0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final baseColor = isDark ? Colors.grey[800]! : Colors.grey[300]!;
    final highlightColor = isDark ? Colors.grey[700]! : Colors.grey[100]!;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: baseColor,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    )
        .animate(onPlay: (controller) => controller.repeat())
        .shimmer(
          duration: 1200.ms,
          color: highlightColor,
        );
  }
}

class ProjectCardSkeleton extends StatelessWidget {
  const ProjectCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ShimmerLoader(
            width: double.infinity,
            height: 160,
            borderRadius: 16,
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ShimmerLoader(width: 150, height: 20),
                const SizedBox(height: 8),
                const ShimmerLoader(width: double.infinity, height: 14),
                const SizedBox(height: 4),
                const ShimmerLoader(width: 200, height: 14),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    ShimmerLoader(width: 80, height: 20),
                    ShimmerLoader(width: 80, height: 20),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class EntrepriseCardSkeleton extends StatelessWidget {
  const EntrepriseCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ShimmerLoader(width: 60, height: 60, borderRadius: 30),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ShimmerLoader(width: 150, height: 20),
                const SizedBox(height: 8),
                const ShimmerLoader(width: 100, height: 14),
                const SizedBox(height: 12),
                Row(
                  children: const [
                    ShimmerLoader(width: 60, height: 24, borderRadius: 12),
                    SizedBox(width: 8),
                    ShimmerLoader(width: 60, height: 24, borderRadius: 12),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
