import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_drawer.dart';
import '../../../data/backup/backup_service.dart';

enum _BackupFormat { json, csv, excel, sql }

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _busy = false;

  Future<void> _chooseBackupAction({required bool export}) async {
    final format = await showModalBottomSheet<_BackupFormat>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.gutter,
                AppSpacing.sm,
                AppSpacing.gutter,
                AppSpacing.md,
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  export ? 'Choose export format' : 'Choose backup format',
                  style: Theme.of(sheetContext).textTheme.titleLarge,
                ),
              ),
            ),
            for (final option in _formatOptions)
              ListTile(
                leading: Icon(option.$2),
                title: Text(option.$3),
                subtitle: Text(option.$4),
                onTap: () => Navigator.pop(sheetContext, option.$1),
              ),
            const SizedBox(height: AppSpacing.md),
          ],
        ),
      ),
    );
    if (format == null || !mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    setState(() => _busy = true);
    try {
      final service = ref.read(backupServiceProvider);
      final message = export
          ? 'Saved: ${await _export(service, format)}'
          : await _import(service, format);
      if (mounted) messenger.showSnackBar(SnackBar(content: Text(message)));
    } catch (error) {
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(
            content: Text('Could not ${export ? 'export' : 'import'}: $error'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<String> _export(BackupService service, _BackupFormat format) {
    return switch (format) {
      _BackupFormat.json => service.exportJson(),
      _BackupFormat.csv => service.exportCsv(),
      _BackupFormat.excel => service.exportExcel(),
      _BackupFormat.sql => service.exportSql(),
    };
  }

  Future<String> _import(BackupService service, _BackupFormat format) async {
    final count = await switch (format) {
      _BackupFormat.json => service.importJson(),
      _BackupFormat.csv => service.importCsv(),
      _BackupFormat.excel => service.importExcel(),
      _BackupFormat.sql => service.importSql(),
    };
    return count == 0 ? 'No data imported' : 'Imported $count items';
  }

  Future<void> _chooseTheme() async {
    final currentMode = ref.read(themeProvider);
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Text(
                'Choose theme',
                style: Theme.of(sheetContext).textTheme.titleLarge,
              ),
            ),
            for (final mode in ThemeMode.values)
              ListTile(
                leading: Icon(_themeIcon(mode)),
                title: Text(_themeLabel(mode)),
                trailing: currentMode == mode ? const Icon(Icons.check) : null,
                onTap: () {
                  ref.read(themeProvider.notifier).setThemeMode(mode);
                  Navigator.pop(sheetContext);
                },
              ),
            const SizedBox(height: AppSpacing.md),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mode = ref.watch(themeProvider);

    return Scaffold(
      key: _scaffoldKey,
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('Settings'),
        leading: AppMenuButton(scaffoldKey: _scaffoldKey),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.gutter),
          children: <Widget>[
            Text('Backup & Restore', style: theme.textTheme.titleLarge),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Choose an action, then select the file format from its menu.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.xl),
            _SettingsActionCard(
              icon: Icons.download_rounded,
              title: 'Export data',
              subtitle: 'JSON, CSV, Excel or SQL',
              onTap: _busy ? null : () => _chooseBackupAction(export: true),
            ),
            const SizedBox(height: AppSpacing.md),
            _SettingsActionCard(
              icon: Icons.upload_file_rounded,
              title: 'Import backup',
              subtitle: 'Choose a Habit Genius backup file',
              onTap: _busy ? null : () => _chooseBackupAction(export: false),
            ),
            if (_busy) ...<Widget>[
              const SizedBox(height: AppSpacing.lg),
              const Center(child: CircularProgressIndicator()),
            ],
            const SizedBox(height: AppSpacing.xxl),
            Text('Appearance', style: theme.textTheme.titleLarge),
            const SizedBox(height: AppSpacing.md),
            _SettingsActionCard(
              icon: _themeIcon(mode),
              title: 'App theme',
              subtitle: _themeLabel(mode),
              onTap: _chooseTheme,
            ),
          ],
        ),
      ),
    );
  }
}

const _formatOptions = <(_BackupFormat, IconData, String, String)>[
  (
    _BackupFormat.json,
    Icons.data_object_rounded,
    'JSON',
    'Full backup for restore',
  ),
  (
    _BackupFormat.csv,
    Icons.table_chart_rounded,
    'CSV',
    'Open in spreadsheet apps',
  ),
  (
    _BackupFormat.excel,
    Icons.grid_on_rounded,
    'Excel (.xlsx)',
    'Multi-sheet workbook',
  ),
  (
    _BackupFormat.sql,
    Icons.storage_rounded,
    'SQL (.sql)',
    'Portable database script',
  ),
];

String _themeLabel(ThemeMode mode) => switch (mode) {
  ThemeMode.light => 'Light',
  ThemeMode.dark => 'Dark',
  ThemeMode.system => 'System',
};

IconData _themeIcon(ThemeMode mode) => switch (mode) {
  ThemeMode.light => Icons.wb_sunny_rounded,
  ThemeMode.dark => Icons.nightlight_round,
  ThemeMode.system => Icons.brightness_auto_rounded,
};

class _SettingsActionCard extends StatelessWidget {
  const _SettingsActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: <Widget>[
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            child: Icon(icon, color: theme.colorScheme.primary),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(title, style: theme.textTheme.titleMedium),
                const SizedBox(height: 2),
                Text(subtitle, style: theme.textTheme.bodySmall),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded),
        ],
      ),
    );
  }
}
