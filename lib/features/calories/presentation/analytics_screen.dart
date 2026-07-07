import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../data/local/repositories/food_repository.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/date_selector.dart';
import '../application/calorie_controller.dart';
import 'widgets/calorie_chart.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final calorieState = ref.watch(calorieControllerProvider);
    final calorieController = ref.read(calorieControllerProvider.notifier);
    final foodRepository = ref.watch(foodRepositoryProvider);

    final dailyTotals = foodRepository.getDailyCalorieTotalsForLastDays(
      endDate: calorieState.selectedDate,
      days: 30,
    );

    final double totalCalories = dailyTotals.fold<double>(
      0,
      (total, day) => total + day.calories,
    );

    final double averageCalories = dailyTotals.isEmpty
        ? 0.0
        : totalCalories / dailyTotals.length.toDouble();

    final loggedDays = dailyTotals.where((day) => day.calories > 0).length;

    final highestDay = dailyTotals.reduce(
      (a, b) => a.calories >= b.calories ? a : b,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenPadding,
          AppSpacing.gap12,
          AppSpacing.screenPadding,
          AppSpacing.bottomScrollPadding,
        ),
        children: [
          DateSelector(
            selectedDate: calorieState.selectedDate,
            onDateChanged: calorieController.loadForDate,
          ),
          const SizedBox(height: AppSpacing.gap16),
          _AnalyticsHeader(
            selectedDate: calorieState.selectedDate,
          ),
          const SizedBox(height: AppSpacing.gap16),
          _SummaryGrid(
            averageCalories: averageCalories,
            totalCalories: totalCalories,
            loggedDays: loggedDays,
            highestDay: highestDay,
          ),
          const SizedBox(height: AppSpacing.gap24),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _SectionHeader(
                  icon: Icons.show_chart_rounded,
                  title: 'Daily calorie trend',
                ),
                const SizedBox(height: AppSpacing.gap16),
                CalorieChart(dailyTotals: dailyTotals),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.gap16),
          _DailyTotalsList(dailyTotals: dailyTotals.reversed.toList()),
        ],
      ),
    );
  }
}

class _AnalyticsHeader extends StatelessWidget {
  const _AnalyticsHeader({
    required this.selectedDate,
  });

  final DateTime selectedDate;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AppCard(
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: colorScheme.primaryContainer,
            foregroundColor: colorScheme.onPrimaryContainer,
            child: const Icon(Icons.bar_chart_rounded),
          ),
          const SizedBox(width: AppSpacing.gap12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '30-day overview',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: AppSpacing.gap4),
                Text(
                  'Ending ${DateFormat('MMM d, yyyy').format(selectedDate)}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryGrid extends StatelessWidget {
  const _SummaryGrid({
    required this.averageCalories,
    required this.totalCalories,
    required this.loggedDays,
    required this.highestDay,
  });

  final double averageCalories;
  final double totalCalories;
  final int loggedDays;
  final DailyCalorieTotal highestDay;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.gap12,
      runSpacing: AppSpacing.gap12,
      children: [
        _SummaryCard(
          title: 'Average',
          value: '${averageCalories.round()}',
          suffix: 'kcal/day',
          icon: Icons.speed_rounded,
        ),
        _SummaryCard(
          title: 'Total',
          value: '${totalCalories.round()}',
          suffix: 'kcal',
          icon: Icons.functions_rounded,
        ),
        _SummaryCard(
          title: 'Logged days',
          value: '$loggedDays',
          suffix: '/ 30 days',
          icon: Icons.calendar_month_rounded,
        ),
        _SummaryCard(
          title: 'Highest day',
          value: '${highestDay.calories.round()}',
          suffix: DateFormat('MMM d').format(highestDay.date),
          icon: Icons.trending_up_rounded,
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.title,
    required this.value,
    required this.suffix,
    required this.icon,
  });

  final String title;
  final String value;
  final String suffix;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: 164,
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: colorScheme.tertiary,
            ),
            const SizedBox(height: AppSpacing.gap12),
            Text(
              title,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: AppSpacing.gap4),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            Text(
              suffix,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DailyTotalsList extends StatelessWidget {
  const _DailyTotalsList({
    required this.dailyTotals,
  });

  final List<DailyCalorieTotal> dailyTotals;

  @override
  Widget build(BuildContext context) {
    final daysWithCalories = dailyTotals.where((day) => day.calories > 0).toList();

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeader(
            icon: Icons.list_alt_rounded,
            title: 'Logged days',
          ),
          const SizedBox(height: AppSpacing.gap12),
          if (daysWithCalories.isEmpty)
            _CompactEmptyLine(
              icon: Icons.restaurant_rounded,
              text: 'No calorie logs in this 30-day period yet.',
            )
          else
            ...daysWithCalories.map((day) {
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.gap8),
                child: Row(
                  children: [
                    const SizedBox(
                      width: 40,
                      child: Icon(Icons.local_fire_department_rounded),
                    ),
                    Expanded(
                      child: Text(
                        DateFormat('EEE, MMM d').format(day.date),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    Text(
                      '${day.calories.round()} kcal',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.icon,
    required this.title,
  });

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 22),
        const SizedBox(width: AppSpacing.gap8),
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
      ],
    );
  }
}

class _CompactEmptyLine extends StatelessWidget {
  const _CompactEmptyLine({
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.gap8),
      child: Row(
        children: [
          Icon(
            icon,
            color: colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: AppSpacing.gap8),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}