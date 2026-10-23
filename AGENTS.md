# AGENTS.md

## Stack
- Flutter 3.47.7 / Dart 3.13.5 (sdk ^3.13.4)
- State: `flutter_riverpod` ^3.4.3
- Nav: `go_router` ^18.1.1
- Local DB: `hive_ce` ^2.22.0 / `hive_ce_flutter` ^2.5.0 (JSON-backed repos; boxes: `habits`, `moods`, `expenses`, `focus_sessions`, `diary`)
- Export/Backup: `csv`, `excel`, `file_saver`, `share_plus`, `file_picker`, `path_provider`

## Commands
- Run app: `flutter run`
- Analyze: `flutter analyze`
- Test: `flutter test`
- Get deps: `flutter pub get`

## Architecture
- `lib/main.dart` — bootstrap (orientation, `registerHiveAdapters()`, `HiveService.init()`, `ProviderScope`)
- `lib/app.dart` — `MaterialApp.router` with `AppTheme` + `appRouterProvider`
- `lib/core/` — theme/spacing/router/constants/utils/widgets
- `lib/data/` — models, `HiveService`, adapters, repository interfaces, `repository_providers` (Hive when ready else safe in-memory fallback), backup service
- `lib/features/` — `shell`, `dashboard`, `habits`, `mood`, `focus`, `expenses`, `diary`, `analytics`, `more`, `settings`

## Patterns (repo-specific)
- Repos: interfaces in `data/repositories/*_repository.dart`, Hive impls in `data/local/repositories/hive_*_repository.dart`, DI in `data/repositories/repository_providers.dart`
- Models: immutable classes + `copyWith`; JSON via `*Json` extensions (e.g. `HabitJson`, `MoodEntryJson`)
- State: `Notifier`/`Provider` in `features/*/application/*_providers.dart`
- Navigation: bottom nav via `StatefulShellRoute` in `core/router/app_router.dart`; `/expenses`, `/analytics`, `/settings` are root routes
- Hive: register adapters in `data/local/hive_adapters.dart`; access via `HiveService.instance.box(name)`

## Habit domain
- `Habit` supports `HabitProgressKind.checkbox|counter|duration`; `durationMinutesTarget` for timed habits; `HabitSchedule` holds time-of-day, weekdays, `reminderMinutes`, `intervalDays`
- JSON stays backwards compatible: legacy payloads without `progressKind`/`schedule` still decode
- `features/habits/application/streak_engine.dart` — current/longest streak (with freeze days), completion rates, Genius Score, `HabitStreakMetrics`
- `features/habits/application/reminder_scheduler.dart` — pure next-reminder/upcoming logic (delivery layer not yet wired)
- `todayHabitsProvider` filters by schedule; dashboard + habit completion use it

## Expenses
- `CustomCategory` (`data/models/custom_category.dart`) stores user-defined income/expense menus; persisted in Hive box `expense_categories` via `HiveCustomCategoryRepository`
- `features/expenses/application/category_providers.dart` exposes `customCategoriesProvider` and `categoriesForTypeProvider`
- Manage from Expenses app bar (`CategoryManagerSheet`) or the "New" chip in `AddTransactionSheet`
- `ExpenseEntry` keeps the legacy enum but supports `customCategory`/`customEmoji` overrides; use `categoryLabel`/`categoryEmoji`
- Arrow convention: expense = red down arrow, income = green up arrow

## Analytics
- `core/utils/heatmap_data.dart` + `features/analytics/presentation/widgets/consistency_heatmap.dart` — GitHub-style 140-day heatmap
- `weekly_trend_bars.dart` — last 7 days completion bars
- `features/analytics/application/insights_engine.dart` — average score, weekday rates, pattern insights, habit breakdown suggestions
- `/analytics` screen reachable from More → Analytics & Heatmap

## Data backup/restore
- Backup service: `lib/data/backup/backup_service.dart` exports all modules to JSON + CSV + XLSX and imports JSON or CSV backups (merges by id, prefers incoming) 
- CSV import reconstructs records from the `extra` JSON column written by `exportCsv`
- Custom categories are included in JSON/CSV/XLSX exports and restored on import
- Settings UI: `lib/features/settings/presentation/settings_screen.dart` with Export JSON/CSV/XLSX and Import JSON/CSV

## Gotchas
- When running in tests/widget tests, Hive may not be initialized — providers fall back to in-memory repos
- Demo data exists under `data/repositories/demo/` but is not used by default
- CSV import requires files produced by HabitGenius (records live in the `extra` column)
- Add new modules: create model + repo interface + Hive impl + providers + screen; register box in `HiveBoxes` and adapters if custom types
