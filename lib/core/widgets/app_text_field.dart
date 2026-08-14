import 'package:flutter/material.dart';
import '../theme/app_spacing.dart';

class AppTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String label;
  final String? hintText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final int maxLines;

  const AppTextField({
    super.key,
    this.controller,
    required this.label,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        AppSpacing.vXs,
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          validator: validator,
          maxLines: maxLines,
          style: theme.textTheme.bodyLarge,
          decoration: InputDecoration(
            hintText: hintText,
            prefixIcon: prefixIcon != null
                ? Icon(
                    prefixIcon,
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                    size: 20,
                  )
                : null,
            suffixIcon: suffixIcon,
          ),
        ),
      ],
    );
  }
}
