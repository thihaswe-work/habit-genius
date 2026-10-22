import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repositories/repository_providers.dart';
import 'backup_service.dart';

final backupServiceProvider = Provider<BackupService>((Ref ref) {
  return BackupService(
    habits: ref.watch(habitRepositoryProvider),
    moods: ref.watch(moodRepositoryProvider),
    expenses: ref.watch(expenseRepositoryProvider),
    focusSessions: ref.watch(focusRepositoryProvider),
    diary: ref.watch(diaryRepositoryProvider),
  );
});
