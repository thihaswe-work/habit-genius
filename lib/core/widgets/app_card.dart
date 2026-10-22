import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';

/// The app's standard surface: rounded, optionally tappable, optionally
/// filled with a gradient.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.gradient,
    this.color,
    this.borderRadius,
    this.border,
    this.clipContent = false,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final Gradient? gradient;
  final Color? color;
  final BorderRadius? borderRadius;
  final BoxBorder? border;
  final bool clipContent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final radius = borderRadius ?? BorderRadius.circular(AppSpacing.radiusLg);

    final surface = DecoratedBox(
      decoration: BoxDecoration(
        color: gradient == null ? (color ?? theme.colorScheme.surface) : null,
        gradient: gradient,
        borderRadius: radius,
        border: border,
      ),
      child: Padding(padding: padding, child: child),
    );

    if (onTap == null) return surface;

    return Material(
      color: Colors.transparent,
      borderRadius: radius,
      clipBehavior: clipContent ? Clip.antiAlias : Clip.none,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: surface,
      ),
    );
  }
}
