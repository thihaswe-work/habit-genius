import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' show DateFormat, NumberFormat;

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_drawer.dart';
import '../../../core/widgets/section_header.dart';
import '../../../data/models/expense_entry.dart';
import '../application/expense_providers.dart';
import 'widgets/add_transaction_sheet.dart';
import 'widgets/category_manager_sheet.dart';
import 'widgets/expense_period_selector.dart';
import 'widgets/transaction_list.dart';

class ExpensesScreen extends ConsumerWidget {
  const ExpensesScreen({super.key});

  static final _scaffoldKey = GlobalKey<ScaffoldState>();

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
        key: _scaffoldKey,
        drawer: const AppDrawer(),
        appBar: AppBar(
          title: const Text('Expenses'),
          leading: AppMenuButton(scaffoldKey: _scaffoldKey),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Overview'),
              Tab(text: 'History'),
              Tab(text: 'Graph'),
            ],
          ),
          actions: <Widget>[
            PopupMenuButton<_ExpenseMenuAction>(
              tooltip: 'More expense options',
              onSelected: (action) {
                if (action == _ExpenseMenuAction.manageCategories) {
                  showModalBottomSheet<void>(
                    context: context,
                    isScrollControlled: true,
                    useSafeArea: true,
                    showDragHandle: true,
                    builder: (_) => const CategoryManagerSheet(),
                  );
                }
              },
              itemBuilder: (context) =>
                  const <PopupMenuEntry<_ExpenseMenuAction>>[
                    PopupMenuItem<_ExpenseMenuAction>(
                      value: _ExpenseMenuAction.manageCategories,
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(Icons.category_outlined),
                        title: Text('Manage categories'),
                      ),
                    ),
                  ],
            ),
          ],
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
            // ── Tab 2: History ──
            const _HistoryTab(),
            // ── Tab 3: Graph ──
            const _GraphTab(),
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
          const SectionHeader(title: 'Recent', subtitle: 'Latest transactions'),
          const SizedBox(height: AppSpacing.md),
          const TransactionList(),
        ],
      ),
    );
  }
}

class _HistoryTab extends ConsumerWidget {
  const _HistoryTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selection = ref.watch(expenseHistorySelectionProvider);
    final allEntries = ref.watch(expensesProvider);
    final entries = _entriesForPeriod(allEntries, selection);
    final income = _totalFor(entries, TransactionType.income);
    final expense = _totalFor(entries, TransactionType.expense);
    final currency = NumberFormat.simpleCurrency();

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
        children: <Widget>[
          const ExpensePeriodSelector(),
          const SizedBox(height: AppSpacing.md),
          AppCard(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              children: <Widget>[
                _PeriodTotalRow(
                  label: 'Income',
                  amount: income,
                  color: AppColors.success,
                  icon: Icons.arrow_upward_rounded,
                  currency: currency,
                ),
                const Divider(height: AppSpacing.xl),
                _PeriodTotalRow(
                  label: 'Expenses',
                  amount: expense,
                  color: AppColors.danger,
                  icon: Icons.arrow_downward_rounded,
                  currency: currency,
                ),
                const Divider(height: AppSpacing.xl),
                _PeriodTotalRow(
                  label: 'Net balance',
                  amount: income - expense,
                  color: income >= expense
                      ? AppColors.success
                      : AppColors.danger,
                  icon: Icons.account_balance_wallet_outlined,
                  currency: currency,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          SectionHeader(
            title: 'Transactions',
            subtitle: '${entries.length} in this ${selection.period.name}',
          ),
          const SizedBox(height: AppSpacing.md),
          TransactionList(
            entries: entries,
            limit: null,
            emptyTitle: 'No transactions in this period',
            emptyMessage: 'Try another month or year.',
          ),
        ],
      ),
    );
  }
}

class _GraphTab extends ConsumerWidget {
  const _GraphTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final selection = ref.watch(expenseHistorySelectionProvider);
    final allEntries = ref.watch(expensesProvider);
    final entries = _entriesForPeriod(allEntries, selection);
    final pointCount = selection.period == ExpenseHistoryPeriod.month
        ? DateTime(selection.date.year, selection.date.month + 1, 0).day
        : 12;
    final income = List<double>.filled(pointCount, 0);
    final expenses = List<double>.filled(pointCount, 0);

    for (final entry in entries) {
      final index = selection.period == ExpenseHistoryPeriod.month
          ? entry.date.day - 1
          : entry.date.month - 1;
      if (entry.type == TransactionType.income) {
        income[index] += entry.amount;
      } else {
        expenses[index] += entry.amount;
      }
    }

    final labels = List<String>.generate(pointCount, (index) {
      if (selection.period == ExpenseHistoryPeriod.month) {
        return '${index + 1}';
      }
      return DateFormat.MMM().format(DateTime(selection.date.year, index + 1));
    });
    final incomeTotal = income.fold<double>(0, (sum, value) => sum + value);
    final expenseTotal = expenses.fold<double>(0, (sum, value) => sum + value);
    final currency = NumberFormat.simpleCurrency();

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
        children: <Widget>[
          const ExpensePeriodSelector(),
          const SizedBox(height: AppSpacing.md),
          AppCard(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Income & expenses', style: theme.textTheme.titleMedium),
                const SizedBox(height: AppSpacing.md),
                const Row(
                  children: <Widget>[
                    _GraphLegend(color: AppColors.success, label: 'Income'),
                    SizedBox(width: AppSpacing.lg),
                    _GraphLegend(color: AppColors.danger, label: 'Expenses'),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                SizedBox(
                  height: 268,
                  child: LayoutBuilder(
                    builder: (context, constraints) => CustomPaint(
                      size: Size(constraints.maxWidth, 268),
                      painter: _ExpenseGraphPainter(
                        income: income,
                        expenses: expenses,
                        labels: labels,
                        labelEvery:
                            selection.period == ExpenseHistoryPeriod.month
                            ? 5
                            : 1,
                        textDirection: Directionality.of(context),
                        gridColor: theme.colorScheme.outlineVariant,
                        textColor: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                _PeriodTotalRow(
                  label: 'Income',
                  amount: incomeTotal,
                  color: AppColors.success,
                  icon: Icons.arrow_upward_rounded,
                  currency: currency,
                ),
                const SizedBox(height: AppSpacing.sm),
                _PeriodTotalRow(
                  label: 'Expenses',
                  amount: expenseTotal,
                  color: AppColors.danger,
                  icon: Icons.arrow_downward_rounded,
                  currency: currency,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

enum _ExpenseMenuAction { manageCategories }

List<ExpenseEntry> _entriesForPeriod(
  List<ExpenseEntry> entries,
  ExpenseHistorySelection selection,
) {
  final start = selection.period == ExpenseHistoryPeriod.month
      ? DateTime(selection.date.year, selection.date.month)
      : DateTime(selection.date.year);
  final end = selection.period == ExpenseHistoryPeriod.month
      ? DateTime(selection.date.year, selection.date.month + 1)
      : DateTime(selection.date.year + 1);
  return entries
      .where((entry) => !entry.date.isBefore(start) && entry.date.isBefore(end))
      .toList();
}

double _totalFor(List<ExpenseEntry> entries, TransactionType type) => entries
    .where((entry) => entry.type == type)
    .fold<double>(0, (sum, entry) => sum + entry.amount);

class _PeriodTotalRow extends StatelessWidget {
  const _PeriodTotalRow({
    required this.label,
    required this.amount,
    required this.color,
    required this.icon,
    required this.currency,
  });

  final String label;
  final double amount;
  final Color color;
  final IconData icon;
  final NumberFormat currency;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: <Widget>[
        Icon(icon, color: color, size: 19),
        const SizedBox(width: AppSpacing.sm),
        Expanded(child: Text(label, style: theme.textTheme.bodyMedium)),
        Text(
          currency.format(amount),
          style: theme.textTheme.titleSmall?.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _GraphLegend extends StatelessWidget {
  const _GraphLegend({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: <Widget>[
      Container(
        width: 9,
        height: 9,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
      const SizedBox(width: AppSpacing.xs),
      Text(label, style: Theme.of(context).textTheme.labelMedium),
    ],
  );
}

class _ExpenseGraphPainter extends CustomPainter {
  const _ExpenseGraphPainter({
    required this.income,
    required this.expenses,
    required this.labels,
    required this.labelEvery,
    required this.textDirection,
    required this.gridColor,
    required this.textColor,
  });

  final List<double> income;
  final List<double> expenses;
  final List<String> labels;
  final int labelEvery;
  final TextDirection textDirection;
  final Color gridColor;
  final Color textColor;

  @override
  void paint(Canvas canvas, Size size) {
    const left = 50.0;
    const right = 8.0;
    const top = 12.0;
    const bottom = 30.0;
    final chart = Rect.fromLTRB(
      left,
      top,
      size.width - right,
      size.height - bottom,
    );
    final maxValue = <double>[
      ...income,
      ...expenses,
    ].fold<double>(0, (max, value) => math.max(max, value));
    final scale = maxValue == 0 ? 1.0 : maxValue;
    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1;
    final incomePaint = Paint()
      ..color = AppColors.success
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final expensePaint = Paint()
      ..color = AppColors.danger
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    for (var line = 0; line <= 4; line++) {
      final y = chart.top + chart.height * line / 4;
      canvas.drawLine(Offset(chart.left, y), Offset(chart.right, y), gridPaint);
      final value = scale * (4 - line) / 4;
      _drawText(canvas, _compactAmount(value), Offset(0, y - 7), textColor, 10);
    }

    _drawSeries(canvas, income, chart, scale, incomePaint);
    _drawSeries(canvas, expenses, chart, scale, expensePaint);

    for (var index = 0; index < labels.length; index++) {
      if (index % labelEvery != 0 && index != labels.length - 1) continue;
      final x = _xAt(index, labels.length, chart);
      _drawText(
        canvas,
        labels[index],
        Offset(x - 11, chart.bottom + 8),
        textColor,
        10,
        width: 22,
      );
    }
  }

  void _drawSeries(
    Canvas canvas,
    List<double> values,
    Rect chart,
    double maxValue,
    Paint paint,
  ) {
    if (values.isEmpty) return;
    final path = Path();
    final points = <Offset>[];
    for (var index = 0; index < values.length; index++) {
      final point = Offset(
        _xAt(index, values.length, chart),
        chart.bottom - chart.height * values[index] / maxValue,
      );
      points.add(point);
      if (index == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    canvas.drawPath(path, paint);
    final pointPaint = Paint()..color = paint.color;
    for (final point in points) {
      canvas.drawCircle(point, values.length > 20 ? 1.7 : 2.8, pointPaint);
    }
  }

  double _xAt(int index, int count, Rect chart) {
    if (count <= 1) return chart.center.dx;
    return chart.left + chart.width * index / (count - 1);
  }

  String _compactAmount(double amount) {
    if (amount >= 1000000) return '${(amount / 1000000).toStringAsFixed(1)}m';
    if (amount >= 1000) return '${(amount / 1000).toStringAsFixed(1)}k';
    return amount.round().toString();
  }

  void _drawText(
    Canvas canvas,
    String value,
    Offset offset,
    Color color,
    double fontSize, {
    double? width,
  }) {
    final painter = TextPainter(
      text: TextSpan(
        text: value,
        style: TextStyle(color: color, fontSize: fontSize),
      ),
      textDirection: textDirection,
      textAlign: TextAlign.center,
      maxLines: 1,
    )..layout(maxWidth: width ?? 48);
    painter.paint(canvas, Offset(offset.dx, offset.dy));
  }

  @override
  bool shouldRepaint(covariant _ExpenseGraphPainter oldDelegate) =>
      oldDelegate.income != income ||
      oldDelegate.expenses != expenses ||
      oldDelegate.labels != labels ||
      oldDelegate.gridColor != gridColor ||
      oldDelegate.textColor != textColor;
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
