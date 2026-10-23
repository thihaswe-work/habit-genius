import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../data/models/custom_category.dart';
import '../../../../data/models/expense_entry.dart';

const _emojiChoices = [
  '🏷️', '🍔', '☕', '🛒', '🚕', '⛽️', '🏠', '💡', '📱', '💊',
  '🎬', '🎁', '✈️', '🐶', '👕', '💼', '💰', '📈', '🎓', '🏋️',
];

Future<CustomCategory?> showCreateCategoryDialog(
  BuildContext context, {
  required TransactionType type,
  required Future<CustomCategory?> Function(String label, String emoji) onCreate,
}) {
  return showDialog<CustomCategory>(
    context: context,
    builder: (_) => _CategoryDialog(type: type, onCreate: onCreate),
  );
}

class _CategoryDialog extends StatefulWidget {
  const _CategoryDialog({required this.type, required this.onCreate});

  final TransactionType type;
  final Future<CustomCategory?> Function(String label, String emoji)
      onCreate;

  @override
  State<_CategoryDialog> createState() => _CategoryDialogState();
}

class _CategoryDialogState extends State<_CategoryDialog> {
  final _labelCtrl = TextEditingController();
  String _emoji = '🏷️';
  bool _saving = false;

  @override
  void dispose() {
    _labelCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final title = widget.type == TransactionType.income
        ? 'New income category'
        : 'New expense category';

    return AlertDialog(
      title: Text(title),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _labelCtrl,
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Name',
                hintText: 'e.g. Freelance, Coffee',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('Emoji', style: theme.textTheme.titleSmall),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: [
                for (final emoji in _emojiChoices)
                  GestureDetector(
                    onTap: () => setState(() => _emoji = emoji),
                    child: Container(
                      width: 38,
                      height: 38,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: _emoji == emoji
                            ? theme.colorScheme.primary.withValues(alpha: 0.16)
                            : theme.colorScheme.surfaceContainer,
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusSm),
                        border: Border.all(
                          color: _emoji == emoji
                              ? theme.colorScheme.primary
                              : Colors.transparent,
                        ),
                      ),
                      child: Text(emoji, style: const TextStyle(fontSize: 18)),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _saving ? null : _save,
          child: const Text('Create'),
        ),
      ],
    );
  }

  Future<void> _save() async {
    final label = _labelCtrl.text.trim();
    if (label.isEmpty) return;
    setState(() => _saving = true);
    final created = await widget.onCreate(label, _emoji);
    if (!mounted) return;
    Navigator.of(context).pop(created);
  }
}
