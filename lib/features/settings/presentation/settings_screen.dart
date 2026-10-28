import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_drawer.dart';
import '../../../data/backup/backup_service.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final service = ref.read(backupServiceProvider);

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('Settings'),
        leading: Builder(
          builder: (context) => IconButton(
            tooltip: 'Menu',
            icon: const Icon(Icons.menu_rounded),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.gutter),
          children: [
            Text('Backup & Restore', style: theme.textTheme.titleLarge),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Export your data to transfer between phones, or import a JSON/CSV/Excel/SQL backup.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            AppCard(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Export', style: theme.textTheme.titleMedium),
                  const SizedBox(height: AppSpacing.md),
                  _Tile(
                    icon: Icons.code_rounded,
                    label: 'Export as JSON (recommended for restore)',
                    subtitle: 'Full backup for moving to another phone',
                    onTap: _busy
                        ? null
                        : () async {
                            final messenger = ScaffoldMessenger.of(context);
                            setState(() => _busy = true);
                            try {
                              final name = await service.exportJson();
                              if (mounted) {
                                messenger.showSnackBar(
                                  SnackBar(content: Text('Saved: $name')),
                                );
                              }
                            } finally {
                              if (mounted) setState(() => _busy = false);
                            }
                          },
                  ),
                  const Divider(height: AppSpacing.lg),
                  _Tile(
                    icon: Icons.table_chart_rounded,
                    label: 'Export as CSV',
                    subtitle: 'For viewing in spreadsheets',
                    onTap: _busy
                        ? null
                        : () async {
                            final messenger = ScaffoldMessenger.of(context);
                            setState(() => _busy = true);
                            try {
                              final name = await service.exportCsv();
                              if (mounted) {
                                messenger.showSnackBar(
                                  SnackBar(content: Text('Saved: $name')),
                                );
                              }
                            } finally {
                              if (mounted) setState(() => _busy = false);
                            }
                          },
                  ),
                  const Divider(height: AppSpacing.lg),
                  _Tile(
                    icon: Icons.grid_on_rounded,
                    label: 'Export as Excel (.XLSX)',
                    subtitle: 'Multi-sheet workbook',
                    onTap: _busy
                        ? null
                        : () async {
                            final messenger = ScaffoldMessenger.of(context);
                            setState(() => _busy = true);
                            try {
                              final name = await service.exportExcel();
                              if (mounted) {
                                messenger.showSnackBar(
                                  SnackBar(content: Text('Saved: $name')),
                                );
                              }
                            } finally {
                              if (mounted) setState(() => _busy = false);
                            }
                          },
                  ),
                  const Divider(height: AppSpacing.lg),
                  _Tile(
                    icon: Icons.storage_rounded,
                    label: 'Export as SQL (.sql)',
                    subtitle: 'Portable SQL script for databases',
                    onTap: _busy
                        ? null
                        : () async {
                            final messenger = ScaffoldMessenger.of(context);
                            setState(() => _busy = true);
                            try {
                              final name = await service.exportSql();
                              if (mounted) {
                                messenger.showSnackBar(
                                  SnackBar(content: Text('Saved: $name')),
                                );
                              }
                            } finally {
                              if (mounted) setState(() => _busy = false);
                            }
                          },
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            AppCard(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Restore', style: theme.textTheme.titleMedium),
                  const SizedBox(height: AppSpacing.md),
                  _Tile(
                    icon: Icons.upload_file_rounded,
                    label: 'Import from JSON backup',
                    subtitle: 'Restore all data from another device',
                    onTap: _busy
                        ? null
                        : () async {
                            final messenger = ScaffoldMessenger.of(context);
                            setState(() => _busy = true);
                            try {
                              final count = await service.importJson();
                              if (mounted) {
                                messenger.showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      count == 0
                                          ? 'No data imported'
                                          : 'Imported $count items from backup',
                                    ),
                                  ),
                                );
                              }
                            } finally {
                              if (mounted) setState(() => _busy = false);
                            }
                          },
                  ),
                  const Divider(height: AppSpacing.lg),
                  _Tile(
                    icon: Icons.table_view_rounded,
                    label: 'Import from CSV backup',
                    subtitle: 'Restore data exported as CSV',
                    onTap: _busy
                        ? null
                        : () async {
                            final messenger = ScaffoldMessenger.of(context);
                            setState(() => _busy = true);
                            try {
                              final count = await service.importCsv();
                              if (mounted) {
                                messenger.showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      count == 0
                                          ? 'No data imported'
                                          : 'Imported $count items from backup',
                                    ),
                                  ),
                                );
                              }
                            } finally {
                              if (mounted) setState(() => _busy = false);
                            }
                          },
                  ),
                  const Divider(height: AppSpacing.lg),
                  _Tile(
                    icon: Icons.grid_on_rounded,
                    label: 'Import from Excel (.XLSX)',
                    subtitle: 'Restore multi-sheet workbook',
                    onTap: _busy
                        ? null
                        : () async {
                            final messenger = ScaffoldMessenger.of(context);
                            setState(() => _busy = true);
                            try {
                              final count = await service.importExcel();
                              if (mounted) {
                                messenger.showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      count == 0
                                          ? 'No data imported'
                                          : 'Imported $count items from backup',
                                    ),
                                  ),
                                );
                              }
                            } finally {
                              if (mounted) setState(() => _busy = false);
                            }
                          },
                  ),
                  const Divider(height: AppSpacing.lg),
                  _Tile(
                    icon: Icons.storage_rounded,
                    label: 'Import from SQL (.sql)',
                    subtitle: 'Run a HabitGenius SQL backup',
                    onTap: _busy
                        ? null
                        : () async {
                            final messenger = ScaffoldMessenger.of(context);
                            setState(() => _busy = true);
                            try {
                              final count = await service.importSql();
                              if (mounted) {
                                messenger.showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      count == 0
                                          ? 'No data imported'
                                          : 'Imported $count items from backup',
                                    ),
                                  ),
                                );
                              }
                            } finally {
                              if (mounted) setState(() => _busy = false);
                            }
                          },
                  ),
                ],
              ),
            ),
            if (_busy) ...[
              const SizedBox(height: AppSpacing.lg),
              const Center(child: CircularProgressIndicator()),
            ],
          ],
        ),
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              ),
              child: Icon(icon, color: theme.colorScheme.primary),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: theme.textTheme.titleSmall),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded),
          ],
        ),
      ),
    );
  }
}
