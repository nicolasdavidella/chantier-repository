import 'package:flutter/material.dart';
import '../theme/app_spacing.dart';
import '../theme/app_colors.dart';

class AppCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final bool hasBorder;

  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.hasBorder = true,
  });

  @override
  State<AppCard> createState() => _AppCardState();
}

class _AppCardState extends State<AppCard> {
  bool _isHovered = false;
  bool _isPressed = false;

  void _handleTapDown(TapDownDetails details) {
    if (widget.onTap != null) setState(() => _isPressed = true);
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.onTap != null) {
      setState(() => _isPressed = false);
      widget.onTap!();
    }
  }

  void _handleTapCancel() {
    if (_isPressed) setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // Calculate scale and elevation based on interaction state
    final double scale = _isPressed ? 0.98 : 1.0;
    
    // Soft shadows for a modern look
    final List<BoxShadow> shadows = _isHovered && !_isPressed
        ? [
            BoxShadow(
              color: (isDark ? Colors.black : AppColors.primaryDark).withOpacity(0.08),
              blurRadius: 24,
              offset: const Offset(0, 8),
            )
          ]
        : [
            BoxShadow(
              color: (isDark ? Colors.black : AppColors.primaryDark).withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            )
          ];

    Widget cardContent = AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      padding: widget.padding,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: AppSpacing.borderRadiusMd,
        border: widget.hasBorder
            ? Border.all(
                color: theme.colorScheme.outline.withOpacity(0.3),
                width: 1,
              )
            : null,
        boxShadow: shadows,
      ),
      child: widget.child,
    );

    if (widget.onTap != null) {
      return MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTapDown: _handleTapDown,
          onTapUp: _handleTapUp,
          onTapCancel: _handleTapCancel,
          child: AnimatedScale(
            scale: scale,
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOutCubic,
            child: cardContent,
          ),
        ),
      );
    }

    return cardContent;
  }
}
