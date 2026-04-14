import 'package:flutter/material.dart';

enum AppButtonVariant { primary, secondary, outline, ghost, destructive }

enum AppButtonSize { sm, md, lg }

class AppButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final bool fullWidth;

  const AppButton({
    super.key,
    required this.child,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.md,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final basePadding = switch (size) {
      AppButtonSize.sm => const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      AppButtonSize.md => const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      AppButtonSize.lg => const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
    };

    final textStyle = switch (size) {
      AppButtonSize.sm => theme.textTheme.labelMedium,
      AppButtonSize.md => theme.textTheme.titleSmall,
      AppButtonSize.lg => theme.textTheme.titleMedium,
    };

    final backgroundColor = switch (variant) {
      AppButtonVariant.primary => colorScheme.primary,
      AppButtonVariant.secondary => colorScheme.secondary,
      AppButtonVariant.outline => colorScheme.surface,
      AppButtonVariant.ghost => Colors.transparent,
      AppButtonVariant.destructive => colorScheme.error,
    };

    final foregroundColor = switch (variant) {
      AppButtonVariant.primary => colorScheme.onPrimary,
      AppButtonVariant.secondary => colorScheme.onSecondary,
      AppButtonVariant.outline => colorScheme.primary,
      AppButtonVariant.ghost => colorScheme.primary,
      AppButtonVariant.destructive => colorScheme.onError,
    };

    final borderSide = switch (variant) {
      AppButtonVariant.outline => BorderSide(color: colorScheme.outlineVariant),
      _ => BorderSide.none,
    };

    return SizedBox(
      width: fullWidth ? double.infinity : null,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          padding: basePadding,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          side: borderSide,
          textStyle: textStyle,
        ),
        child: child,
      ),
    );
  }
}
