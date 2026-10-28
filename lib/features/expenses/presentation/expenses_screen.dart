import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_drawer.dart';
import '../../../core/widgets/section_header.dart';
import '../../../data/models/expense_entry.dart';
import '../application/expense_providers.dart';
import 'widgets/add_transaction_sheet.dart';
import 'widgets/category_manager_sheet.dart';
import 'widgets/transaction_list.dart';

class ExpensesScreen extends ConsumerWidget {
  const ExpensesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final entries = ref.watch(expensesProvider);
    final currency = NumberFormat.simpleCurrency();

    var income = 0.0;
    var expense = 0.0;
    for (final e in entries) {
      if (e.type == TransactionType.income) {
        income += e.amount;
      } else {
        expense += e.amount;
      }
    }
    final balance = income - expense;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        drawer: const AppDrawer(),
        appBar: AppBar(
          title: const Text('Expenses'),
          leading: const AppMenuButton(),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Overview'),
              Tab(text: 'Transactions'),
              Tab(text: 'Categories'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // ── Tab 1: Overview ──
            _OverviewTab(
              theme: theme,
              currency: currency,
              income: income,
              expense: expense,
              balance: balance,
              entries: entries,
            ),
            // ── Tab 2: Transactions ──
            const _TransactionsTab(),
            // ── Tab 3: Categories ──
            const _CategoriesTab(),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              useSafeArea: true,
              builder: (_) => const AddTransactionSheet(),
            );
          },
          backgroundColor: AppColors.expenses,
          icon: const Icon(Icons.add_rounded, color: Colors.white),
          label: const Text('Add', style: TextStyle(color: Colors.white)),
        ),
      ),
    );
  }
}

/// Balance summary card + recent transactions.
class _OverviewTab extends StatelessWidget {
  const _OverviewTab({
    required this.theme,
    required this.currency,
    required this.income,
    required this.expense,
    required this.balance,
    required this.entries,
  });

  final ThemeData theme;
  final NumberFormat currency;
  final double income;
  final double expense;
  final double balance;
  final List entries;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.gutter,
          AppSpacing.lg,
          AppSpacing.gutter,
          100,
        ),
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.expenses, AppColors.expensesAlt],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total balance',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  currency.format(balance),
                  style: theme.textTheme.displaySmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  children: [
                    Expanded(
                      child: _Mini(
                        label: 'Income',
                        value: currency.format(income),
                        icon: Icons.arrow_upward_rounded,
                        iconColor: AppColors.success,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: _Mini(
                        label: 'Expense',
                        value: currency.format(expense),
                        icon: Icons.arrow_downward_rounded,
                        iconColor: AppColors.danger,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          const SectionHeader(
            title: 'Recent',
            subtitle: 'Latest transactions',
          ),
          const SizedBox(height: AppSpacing.md),
          const TransactionList(),
        ],
      ),
    );
  }
}

/// Full scrollable list of all transactions.
class _TransactionsTab extends StatelessWidget {
  const _TransactionsTab();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.gutter,
          AppSpacing.lg,
          AppSpacing.gutter,
          100,
        ),
        children: const [
          TransactionList(),
        ],
      ),
    );
  }
}

/// Category management tab.
class _CategoriesTab extends StatelessWidget {
  const _CategoriesTab();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      bottom: false,
      child: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.gutter,
          AppSpacing.lg,
          AppSpacing.gutter,
          100,
        ),
        children: [
          Text('Manage categories', style: theme.textTheme.headlineSmall),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Create and organise income & expense categories',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          FilledButton.icon(
            onPressed: () => showModalBottomSheet<void>(
              context: context,
              isScrollControlled: true,
              useSafeArea: true,
              builder: (_) => const CategoryManagerSheet(),
            ),
            icon: const Icon(Icons.category_rounded),
            label: const Text('Open Category Manager'),
          ),
        ],
      ),
    );
  }
}

class _Mini extends StatelessWidget {
  const _Mini({
    required this.label,
    required this.value,
    required this.icon,
    this.iconColor = Colors.white,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 18),
          const SizedBox(width: AppSpacing.sm),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
