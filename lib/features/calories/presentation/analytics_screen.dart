import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../data/local/repositories/food_repository.dart';
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
        title: const Text('30-Day Analytics'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          DateSelector(
            selectedDate: calorieState.selectedDate,
            onDateChanged: calorieController.loadForDate,
          ),
          const SizedBox(height: 16),
          Text(
            'Last 30 days ending ${DateFormat('MMM d, yyyy').format(calorieState.selectedDate)}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          _SummaryGrid(
            averageCalories: averageCalories,
            totalCalories: totalCalories,
            loggedDays: loggedDays,
            highestDay: highestDay,
          ),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Daily calorie trend',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 20),
                  CalorieChart(dailyTotals: dailyTotals),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _DailyTotalsList(dailyTotals: dailyTotals.reversed.toList()),
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
      spacing: 12,
      runSpacing: 12,
      children: [
        _SummaryCard(
          title: 'Average',
          value: '${averageCalories.round()} kcal',
          icon: Icons.show_chart_rounded,
        ),
        _SummaryCard(
          title: 'Total',
          value: '${totalCalories.round()} kcal',
          icon: Icons.functions_rounded,
        ),
        _SummaryCard(
          title: 'Logged days',
          value: '$loggedDays / 30',
          icon: Icons.calendar_month_rounded,
        ),
        _SummaryCard(
          title: 'Highest day',
          value: '${highestDay.calories.round()} kcal',
          subtitle: DateFormat('MMM d').format(highestDay.date),
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
    required this.icon,
    this.subtitle,
  });

  final String title;
  final String value;
  final IconData icon;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon),
              const SizedBox(height: 10),
              Text(
                title,
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle!,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ],
          ),
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
    final daysWithCalories = dailyTotals
        .where((day) => day.calories > 0)
        .toList();

    if (daysWithCalories.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Text('No calorie logs in this 30-day period yet.'),
        ),
      );
    }

    return Card(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Logged days',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ),
          ...daysWithCalories.map((day) {
            return ListTile(
              leading: const Icon(Icons.local_fire_department_rounded),
              title: Text(DateFormat('EEE, MMM d').format(day.date)),
              trailing: Text(
                '${day.calories.round()} kcal',
                style: Theme.of(context).textTheme.titleSmall,
              ),
            );
          }),
        ],
      ),
    );
  }
}