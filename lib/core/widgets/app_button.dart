import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_spacing.dart';

class AppButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final String text;
  final IconData? icon;
  final bool isLoading;
  final bool isSecondary;
  final bool isOutlined;
  final bool isFullWidth;

  const AppButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.icon,
    this.isLoading = false,
    this.isSecondary = false,
    this.isOutlined = false,
    this.isFullWidth = true,
  });

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  bool _isPressed = false;

  void _handleTapDown(TapDownDetails details) {
    if (widget.onPressed != null && !widget.isLoading) {
      HapticFeedback.lightImpact();
      setState(() => _isPressed = true);
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.onPressed != null && !widget.isLoading) {
      setState(() => _isPressed = false);
      widget.onPressed!();
    }
  }

  void _handleTapCancel() {
    if (_isPressed) {
      setState(() => _isPressed = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    // Determine colors based on button type
    Color backgroundColor;
    Color foregroundColor;
    
    if (widget.isSecondary) {
      backgroundColor = colorScheme.secondary;
      foregroundColor = colorScheme.onSecondary;
    } else {
      backgroundColor = colorScheme.primary;
      foregroundColor = colorScheme.onPrimary;
    }

    if (widget.isOutlined) {
      foregroundColor = widget.isSecondary ? colorScheme.secondary : colorScheme.primary;
      backgroundColor = Colors.transparent;
    }

    if (widget.onPressed == null) {
      backgroundColor = theme.disabledColor.withOpacity(0.12);
      foregroundColor = theme.disabledColor;
    }

    Widget content = Row(
      mainAxisSize: widget.isFullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.isLoading) ...[
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(foregroundColor),
            ),
          ),
          AppSpacing.hSm,
        ] else if (widget.icon != null) ...[
          Icon(widget.icon, size: 20, color: foregroundColor),
          AppSpacing.hSm,
        ],
        Text(
          widget.text,
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: foregroundColor,
          ),
        ),
      ],
    );

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: AnimatedScale(
        scale: _isPressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeInOut,
        child: Container(
          width: widget.isFullWidth ? double.infinity : null,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.lg,
          ),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: AppSpacing.borderRadiusMd,
            border: widget.isOutlined
                ? Border.all(color: foregroundColor, width: 1.5)
                : null,
          ),
          child: content,
        ),
      ),
    );
  }
}
