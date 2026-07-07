import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class CalorieChart extends StatelessWidget {
  const CalorieChart({
    required this.dailyCalories,
    super.key,
  });

  final List<int> dailyCalories;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final spots = [
      for (var index = 0; index < dailyCalories.length; index++)
        FlSpot(index.toDouble(), dailyCalories[index].toDouble()),
    ];

    return SizedBox(
      height: 180,
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: spots.isEmpty ? const [FlSpot(0, 0)] : spots,
              color: colorScheme.primary,
              barWidth: 3,
              dotData: const FlDotData(show: false),
            ),
          ],
        ),
      ),
    );
  }
}
