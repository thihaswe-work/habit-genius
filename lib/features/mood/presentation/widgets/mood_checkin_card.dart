import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../data/models/mood_entry.dart';
import '../../application/mood_providers.dart';

class MoodCheckinCard extends ConsumerStatefulWidget {
  const MoodCheckinCard({super.key});

  @override
  ConsumerState<MoodCheckinCard> createState() => _MoodCheckinCardState();
}

class _MoodCheckinCardState extends ConsumerState<MoodCheckinCard> {
  final _noteCtrl = TextEditingController();

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final entry = ref.watch(todayMoodProvider);
    final selected = entry?.mood;

    return AppCard(
      gradient: LinearGradient(
        colors: [
          AppColors.mood.withValues(alpha: 0.18),
          AppColors.moodAlt.withValues(alpha: 0.10),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('How are you feeling?', style: theme.textTheme.titleLarge),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      selected == null
                          ? 'Log your mood for today'
                          : 'You\'re feeling ${selected.label.toLowerCase()}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Text(selected?.emoji ?? '😊', style: const TextStyle(fontSize: 32)),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (final mood in Mood.values)
                _MoodTile(
                  mood: mood,
                  selected: mood == selected,
                  onTap: () {
                    ref.read(moodEntriesProvider.notifier).logMood(mood);
                    setState(() {});
                  },
                ),
            ],
          ),
          if (selected != null) ...[
            const SizedBox(height: AppSpacing.lg),
            TextField(
              controller: _noteCtrl,
              decoration: InputDecoration(
                hintText: 'Add a note (optional)',
                filled: true,
                fillColor: theme.colorScheme.surface.withValues(alpha: 0.7),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  borderSide: BorderSide.none,
                ),
              ),
              maxLines: 2,
              onSubmitted: (v) {
                ref.read(moodEntriesProvider.notifier).logMood(selected, note: v);
              },
            ),
          ],
        ],
      ),
    );
  }
}

class _MoodTile extends StatelessWidget {
  const _MoodTile({
    required this.mood,
    required this.selected,
    required this.onTap,
  });

  final Mood mood;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 56,
        height: 56,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? theme.colorScheme.surface : Colors.transparent,
          shape: BoxShape.circle,
          border: Border.all(
            color: selected ? AppColors.mood : theme.colorScheme.outlineVariant,
            width: selected ? 2 : 1,
          ),
        ),
        child: Text(mood.emoji, style: const TextStyle(fontSize: 26)),
      ),
    );
  }
}
