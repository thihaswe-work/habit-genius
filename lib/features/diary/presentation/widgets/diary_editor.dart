import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../application/diary_providers.dart';

class DiaryEditor extends ConsumerStatefulWidget {
  const DiaryEditor({super.key});

  @override
  ConsumerState<DiaryEditor> createState() => _DiaryEditorState();
}

class _DiaryEditorState extends ConsumerState<DiaryEditor> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _contentCtrl;

  @override
  void initState() {
    super.initState();
    final today = ref.read(todayDiaryProvider);
    _titleCtrl = TextEditingController(text: today?.title ?? '');
    _contentCtrl = TextEditingController(text: today?.content ?? '');
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final today = ref.watch(todayDiaryProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          today != null ? 'Today\'s entry' : 'Write for today',
          style: theme.textTheme.titleLarge,
        ),
        const SizedBox(height: AppSpacing.lg),
        TextField(
          controller: _titleCtrl,
          decoration: InputDecoration(
            hintText: 'Title (optional)',
            filled: true,
            fillColor: theme.colorScheme.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              borderSide: BorderSide(color: theme.colorScheme.outlineVariant),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              borderSide: BorderSide(color: theme.colorScheme.outlineVariant),
            ),
          ),
          style: theme.textTheme.titleMedium,
          onChanged: (_) => _save(),
        ),
        const SizedBox(height: AppSpacing.md),
        TextField(
          controller: _contentCtrl,
          decoration: InputDecoration(
            hintText: 'Start writing your thoughts...',
            filled: true,
            fillColor: theme.colorScheme.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              borderSide: BorderSide(color: theme.colorScheme.outlineVariant),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              borderSide: BorderSide(color: theme.colorScheme.outlineVariant),
            ),
          ),
          style: theme.textTheme.bodyLarge,
          maxLines: 12,
          minLines: 8,
          onChanged: (_) => _save(),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Auto-saved',
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  void _save() {
    ref.read(diaryEntriesProvider.notifier).writeToday(
          title: _titleCtrl.text,
          content: _contentCtrl.text,
        );
  }
}
