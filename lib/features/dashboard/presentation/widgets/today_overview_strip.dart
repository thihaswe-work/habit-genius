import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';

/// A single number shown in the overview strip.
class OverviewStat {
  const OverviewStat({
    required this.label,
    required this.value,
    required this.color,
    this.icon,
    this.emoji,
  }) : assert(icon != null || emoji != null, 'Provide either an icon or emoji');

  final String label;

  /// The headline value, e.g. `3/5`.
  final String value;

  /// Icon rendered in the tinted badge.
  final IconData? icon;

  /// Emoji rendered in the tinted badge instead of an icon.
  final String? emoji;

  final Color color;
}

/// Three-up summary of today's progress across the app.
class TodayOverviewStrip extends StatelessWidget {
  const TodayOverviewStrip({super.key, required this.stats});

  final List<OverviewStat> stats;

  @override
  Widget build(BuildContext context) {
    // IntrinsicHeight gives the row a bounded height inside a scroll view so
    // the three cards can stretch to an equal height.
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          for (var i = 0; i < stats.length; i++) ...<Widget>[
            if (i > 0) const SizedBox(width: AppSpacing.md),
            Expanded(child: _StatCard(stat: stats[i])),
          ],
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.stat});

  final OverviewStat stat;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: stat.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
            child: stat.emoji != null
                ? Text(stat.emoji!, style: const TextStyle(fontSize: 17))
                : Icon(stat.icon, size: 18, color: stat.color),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            stat.value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            stat.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
