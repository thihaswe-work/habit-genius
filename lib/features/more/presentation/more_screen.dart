import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_modules.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_card.dart';
import '../../../data/backup/backup_providers.dart';
import '../../diary/application/diary_providers.dart';
import '../../expenses/application/expense_providers.dart';
import '../../focus/application/focus_providers.dart';
import '../../habits/application/habit_providers.dart';
import '../../mood/application/mood_providers.dart';

/// "All tools" hub: every module in one list, plus utilities such as backup
/// and restore.
class MoreScreen extends ConsumerStatefulWidget {
  const MoreScreen({super.key});

  @override
  ConsumerState<MoreScreen> createState() => _MoreScreenState();
}

enum _BackupAction { export, import }

enum _ImportMode { merge, replace }

class _MoreScreenState extends ConsumerState<MoreScreen> {
  _BackupAction? _busy;

  Future<void> _export(BuildContext tileContext) async {
    if (_busy != null) return;
    setState(() => _busy = _BackupAction.export);

    try {
      final box = tileContext.findRenderObject() as RenderBox?;
      final origin = box == null
          ? null
          : box.localToGlobal(Offset.zero) & box.size;
      await ref
          .read(backupServiceProvider)
          .shareBackup(sharePositionOrigin: origin);
    } catch (error) {
      _showError('Could not export your data.', error);
    } finally {
      if (mounted) setState(() => _busy = null);
    }
  }

  Future<void> _import() async {
    if (_busy != null) return;

    final PlatformFile? pickedFile;
    try {
      pickedFile = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: const <String>['json'],
      );
    } catch (error) {
      _showError('Could not open the file picker.', error);
      return;
    }

    if (pickedFile == null || !mounted) return;

    final Uint8List bytes;
    try {
      bytes = await pickedFile.readAsBytes();
    } catch (error) {
      _showError('Could not read the selected file.', error);
      return;
    }

    if (!mounted) return;
    final mode = await _askImportMode();
    if (mode == null || !mounted) return;

    setState(() => _busy = _BackupAction.import);

    try {
      final summary = await ref
          .read(backupServiceProvider)
          .importJson(utf8.decode(bytes), replace: mode == _ImportMode.replace);

      ref.invalidate(habitsProvider);
      ref.invalidate(moodEntriesProvider);
      ref.invalidate(expensesProvider);
      ref.invalidate(focusSessionsProvider);
      ref.invalidate(diaryEntriesProvider);

      if (!mounted) return;
      final message = summary.total == 0
          ? 'That backup did not contain any records.'
          : 'Imported ${summary.total} records.';
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } catch (error) {
      _showError('Could not import that backup.', error);
    } finally {
      if (mounted) setState(() => _busy = null);
    }
  }

  Future<_ImportMode?> _askImportMode() {
    return showDialog<_ImportMode>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Import backup'),
          content: const Text(
            'Merge keeps the data already on this phone and adds the backup. '
            'Replace erases everything on this phone first.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, _ImportMode.merge),
              child: const Text('Merge'),
            ),
            FilledButton(
              onPressed: () =>
                  Navigator.pop(dialogContext, _ImportMode.replace),
              child: const Text('Replace'),
            ),
          ],
        );
      },
    );
  }

  void _showError(String message, Object? error) {
    if (!mounted) return;
    final detail = error is FormatException ? error.message : null;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(detail == null ? message : '$message $detail')),
    );
  }

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
                    (constraints.maxWidth - (spacing * (columns - 1))) /
                    columns;

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
            Text('Backup', style: theme.textTheme.titleMedium),
            const SizedBox(height: AppSpacing.md),
            Builder(
              builder: (BuildContext tileContext) {
                return _BackupTile(
                  icon: Icons.ios_share_rounded,
                  title: 'Export data',
                  subtitle:
                      'Share or save a backup file to move to another phone',
                  busy: _busy == _BackupAction.export,
                  onTap: () => _export(tileContext),
                );
              },
            ),
            const SizedBox(height: AppSpacing.sm),
            _BackupTile(
              icon: Icons.download_rounded,
              title: 'Import data',
              subtitle: 'Restore a backup file from another phone',
              busy: _busy == _BackupAction.import,
              onTap: _import,
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
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radiusSm,
                          ),
                        ),
                        child: Icon(
                          tool.icon,
                          size: 19,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Text(
                          tool.label,
                          style: theme.textTheme.bodyLarge,
                        ),
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

class _BackupTile extends StatelessWidget {
  const _BackupTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.busy,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool busy;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppCard(
      onTap: busy ? null : onTap,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: <Widget>[
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
            child: busy
                ? const Padding(
                    padding: EdgeInsets.all(10),
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(
                    icon,
                    size: 19,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(title, style: theme.textTheme.bodyLarge),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ],
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
];
