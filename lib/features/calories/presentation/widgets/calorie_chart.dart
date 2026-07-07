import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../data/local/repositories/food_repository.dart';

class CalorieChart extends StatelessWidget {
  const CalorieChart({
    super.key,
    required this.dailyTotals,
  });

  final List<DailyCalorieTotal> dailyTotals;

  @override
  Widget build(BuildContext context) {
    if (dailyTotals.isEmpty) {
      return const Center(
        child: Text('No calorie data available.'),
      );
    }

    final theme = Theme.of(context);
    final maxCalories = dailyTotals.fold<double>(
      0,
      (maxValue, day) => math.max(maxValue, day.calories),
    );

    final maxY = maxCalories <= 0 ? 100.0 : maxCalories * 1.25;

    return AspectRatio(
      aspectRatio: 1.45,
      child: BarChart(
        BarChartData(
          minY: 0,
          maxY: maxY,
          alignment: BarChartAlignment.spaceBetween,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: maxY / 4,
          ),
          borderData: FlBorderData(show: false),
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                if (groupIndex < 0 || groupIndex >= dailyTotals.length) {
                  return null;
                }

                final day = dailyTotals[groupIndex];
                final dateLabel = DateFormat('MMM d').format(day.date);

                return BarTooltipItem(
                  '$dateLabel\n${day.calories.round()} kcal',
                  TextStyle(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            leftTitles: AxisTitles(
              axisNameWidget: const Text('kcal'),
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 44,
                getTitlesWidget: (value, meta) {
                  if (value < 0) {
                    return const SizedBox.shrink();
                  }

                  return Text(
                    value.round().toString(),
                    style: theme.textTheme.labelSmall,
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 42,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();

                  if (index < 0 || index >= dailyTotals.length) {
                    return const SizedBox.shrink();
                  }

                  final shouldShow = index == 0 ||
                      index == dailyTotals.length - 1 ||
                      index % 5 == 0;

                  if (!shouldShow) {
                    return const SizedBox.shrink();
                  }

                  final label = DateFormat('MMM d').format(
                    dailyTotals[index].date,
                  );

                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Transform.rotate(
                      angle: -0.6,
                      child: Text(
                        label,
                        style: theme.textTheme.labelSmall,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          barGroups: List.generate(dailyTotals.length, (index) {
            final day = dailyTotals[index];

            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: day.calories,
                  width: 8,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(6),
                  ),
                  color: theme.colorScheme.primary,
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}