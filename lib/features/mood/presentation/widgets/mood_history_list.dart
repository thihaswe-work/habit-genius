import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../data/models/mood_entry.dart';
import '../../application/mood_providers.dart';

class MoodHistoryList extends ConsumerWidget {
  const MoodHistoryList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final entries = ref.watch(moodEntriesProvider);

    if (entries.isEmpty) {
      return AppCard(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          children: [
            const Text('😌', style: TextStyle(fontSize: 32)),
            const SizedBox(height: AppSpacing.md),
            Text('No mood entries yet', style: theme.textTheme.titleMedium),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Log your first mood above',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final entry in entries.take(30))
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: AppCard(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.mood.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    ),
                    child: Text(
                      entry.mood.emoji,
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              entry.mood.label,
                              style: theme.textTheme.titleSmall,
                            ),
                            const Spacer(),
                            Text(
                              DateFormat('MMM d, yyyy').format(entry.date),
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            PopupMenuButton<String>(
                              tooltip: 'Mood actions',
                              onSelected: (action) async {
                                if (action == 'edit') {
                                  final edited = await showDialog<MoodEntry>(
                                    context: context,
                                    builder: (_) =>
                                        _EditMoodDialog(entry: entry),
                                  );
                                  if (edited != null && context.mounted) {
                                    await ref
                                        .read(moodEntriesProvider.notifier)
                                        .update(edited);
                                  }
                                } else if (action == 'delete') {
                                  final confirmed = await showDialog<bool>(
                                    context: context,
                                    builder: (dialogContext) => AlertDialog(
                                      title: const Text('Delete mood entry?'),
                                      content: const Text(
                                        'This will permanently remove this mood and its note.',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(
                                            dialogContext,
                                            false,
                                          ),
                                          child: const Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () => Navigator.pop(
                                            dialogContext,
                                            true,
                                          ),
                                          child: const Text('Delete'),
                                        ),
                                      ],
                                    ),
                                  );
                                  if (confirmed == true) {
                                    await ref
                                        .read(moodEntriesProvider.notifier)
                                        .delete(entry.id);
                                  }
                                }
                              },
                              itemBuilder: (_) => const [
                                PopupMenuItem(
                                  value: 'edit',
                                  child: Text('Edit'),
                                ),
                                PopupMenuItem(
                                  value: 'delete',
                                  child: Text('Delete'),
                                ),
                              ],
                            ),
                          ],
                        ),
                        if (entry.note != null && entry.note!.isNotEmpty) ...[
                          const SizedBox(height: AppSpacing.xs),
                          Text(entry.note!, style: theme.textTheme.bodyMedium),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _EditMoodDialog extends StatefulWidget {
  const _EditMoodDialog({required this.entry});

  final MoodEntry entry;

  @override
  State<_EditMoodDialog> createState() => _EditMoodDialogState();
}

class _EditMoodDialogState extends State<_EditMoodDialog> {
  late Mood _mood = widget.entry.mood;
  late final TextEditingController _noteController = TextEditingController(
    text: widget.entry.note ?? '',
  );

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Edit mood'),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Wrap(
          spacing: AppSpacing.sm,
          children: [
            for (final mood in Mood.values)
              ChoiceChip(
                label: Text('${mood.emoji} ${mood.label}'),
                selected: mood == _mood,
                onSelected: (_) => setState(() => _mood = mood),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        TextField(
          controller: _noteController,
          autofocus: true,
          minLines: 2,
          maxLines: 4,
          decoration: const InputDecoration(
            labelText: 'Note',
            border: OutlineInputBorder(),
          ),
        ),
      ],
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      FilledButton(
        onPressed: () => Navigator.pop(
          context,
          widget.entry.copyWith(mood: _mood, note: _noteController.text.trim()),
        ),
        child: const Text('Save'),
      ),
    ],
  );
}
