import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_modules.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_card.dart';

/// "All tools" hub: every module in one list, plus a place for future
/// utilities such as insights, settings and data export.
class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.gutter,
            AppSpacing.lg,
            AppSpacing.gutter,
            AppSpacing.xxxl,
          ),
          children: <Widget>[
            Text('All tools', style: theme.textTheme.headlineSmall),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Every module in one place.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                const spacing = AppSpacing.md;
                const columns = 2;
                final tileWidth =
                    (constraints.maxWidth - (spacing * (columns - 1))) / columns;

                return Wrap(
                  spacing: spacing,
                  runSpacing: spacing,
                  children: <Widget>[
                    for (final module in AppModules.all)
                      SizedBox(
                        width: tileWidth,
                        child: _ToolCard(module: module),
                      ),
                  ],
                );
              },
            ),
            const SizedBox(height: AppSpacing.xxl),
            Text('Coming soon', style: theme.textTheme.titleMedium),
            const SizedBox(height: AppSpacing.md),
            for (final tool in _upcomingTools)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: AppCard(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Row(
                    children: <Widget>[
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainer,
                          borderRadius:
                              BorderRadius.circular(AppSpacing.radiusSm),
                        ),
                        child: Icon(
                          tool.icon,
                          size: 19,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Text(tool.label, style: theme.textTheme.bodyLarge),
                      ),
                      Text(
                        'Soon',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ToolCard extends StatelessWidget {
  const _ToolCard({required this.module});

  final AppModule module;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppCard(
      onTap: () => context.go(module.route),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              gradient: module.gradient,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            child: Icon(module.icon, color: Colors.white, size: 24),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            module.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 2),
          Text(
            module.caption,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _UpcomingTool {
  const _UpcomingTool(this.label, this.icon);

  final String label;
  final IconData icon;
}

const List<_UpcomingTool> _upcomingTools = <_UpcomingTool>[
  _UpcomingTool('Insights & trends', Icons.insights_rounded),
  _UpcomingTool('Settings', Icons.settings_rounded),
  _UpcomingTool('Export data', Icons.ios_share_rounded),
];
