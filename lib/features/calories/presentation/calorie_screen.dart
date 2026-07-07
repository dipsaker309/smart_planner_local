import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../data/local/models/food_log_model.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/date_selector.dart';
import '../../../shared/widgets/empty_state.dart';
import '../application/calorie_controller.dart';
import 'analytics_screen.dart';
import 'widgets/food_entry_sheet.dart';
import 'widgets/food_log_edit_sheet.dart';
import 'widgets/food_log_tile.dart';

class CalorieScreen extends ConsumerWidget {
  const CalorieScreen({super.key});

  Future<void> _openFoodEntrySheet(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final calorieState = ref.read(calorieControllerProvider);

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        return FoodEntrySheet(
          foodItems: calorieState.foodItems,
          onLogExistingFood: ({
            required String foodItemId,
            required double quantity,
            required String note,
          }) {
            return ref.read(calorieControllerProvider.notifier).addFoodLog(
                  foodItemId: foodItemId,
                  quantity: quantity,
                  note: note,
                );
          },
          onAddMissingFoodAndLog: ({
            required String name,
            required double baseQuantity,
            required String unit,
            required double calories,
            required double logQuantity,
            required String note,
          }) {
            return ref
                .read(calorieControllerProvider.notifier)
                .addCustomFoodAndLog(
                  name: name,
                  baseQuantity: baseQuantity,
                  unit: unit,
                  calories: calories,
                  logQuantity: logQuantity,
                  note: note,
                );
          },
        );
      },
    );
  }

  Future<void> _openEditFoodLogSheet(
    BuildContext context,
    WidgetRef ref,
    FoodLogModel log,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        return FoodLogEditSheet(
          log: log,
          onSubmit: ({
            required double quantity,
            required String note,
          }) {
            return ref.read(calorieControllerProvider.notifier).editFoodLog(
                  logId: log.id,
                  quantity: quantity,
                  note: note,
                );
          },
        );
      },
    );
  }

  void _openAnalytics(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const AnalyticsScreen(),
      ),
    );
  }

  Future<void> _openTargetDialog(
    BuildContext context,
    WidgetRef ref,
    double currentTarget,
  ) async {
    final controller = TextEditingController(
      text: currentTarget.round().toString(),
    );

    final newTarget = await showDialog<double>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Daily calorie target'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Target calories',
              hintText: 'Example: 2000',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final value = double.tryParse(controller.text.trim());
                Navigator.of(context).pop(value);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    controller.dispose();

    if (newTarget == null) {
      return;
    }

    await ref
        .read(calorieControllerProvider.notifier)
        .updateDailyCalorieTarget(newTarget);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final calorieState = ref.watch(calorieControllerProvider);
    final controller = ref.read(calorieControllerProvider.notifier);

    ref.listen(calorieControllerProvider, (previous, next) {
      final message = next.message;

      if (message == null || message.isEmpty) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );

      controller.clearMessage();
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calories'),
        actions: [
          IconButton(
            onPressed: () => _openTargetDialog(
              context,
              ref,
              calorieState.dailyCalorieTarget,
            ),
            icon: const Icon(Icons.flag_rounded),
            tooltip: 'Set calorie target',
          ),
          IconButton(
            onPressed: () => _openAnalytics(context),
            icon: const Icon(Icons.bar_chart_rounded),
            tooltip: '30-day analytics',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openFoodEntrySheet(context, ref),
        icon: const Icon(Icons.restaurant_rounded),
        label: const Text('Food'),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenPadding,
          AppSpacing.gap12,
          AppSpacing.screenPadding,
          0,
        ),
        child: Column(
          children: [
            DateSelector(
              selectedDate: calorieState.selectedDate,
              onDateChanged: controller.loadForDate,
            ),
            const SizedBox(height: AppSpacing.gap16),
            _DailyCalorieCard(
              totalCalories: calorieState.dailyTotalCalories,
              targetCalories: calorieState.dailyCalorieTarget,
              remainingCalories: calorieState.remainingCalories,
              progress: calorieState.targetProgress,
              onEditTarget: () => _openTargetDialog(
                context,
                ref,
                calorieState.dailyCalorieTarget,
              ),
            ),
            const SizedBox(height: AppSpacing.gap16),
            Expanded(
              child: Builder(
                builder: (context) {
                  if (calorieState.isLoading) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (calorieState.logs.isEmpty) {
                    return EmptyState(
                      icon: Icons.restaurant_rounded,
                      title: 'No food logged yet',
                      subtitle: 'Add your first meal or snack for this date.',
                      actionLabel: '+ Add Food',
                      onAction: () => _openFoodEntrySheet(context, ref),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.only(
                      bottom: AppSpacing.bottomScrollPadding,
                    ),
                    itemCount: calorieState.logs.length,
                    itemBuilder: (context, index) {
                      final log = calorieState.logs[index];

                      return FoodLogTile(
                        log: log,
                        onEdit: () {
                          _openEditFoodLogSheet(context, ref, log);
                        },
                        onDelete: () {
                          controller.deleteFoodLog(log.id);
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DailyCalorieCard extends StatelessWidget {
  const _DailyCalorieCard({
    required this.totalCalories,
    required this.targetCalories,
    required this.remainingCalories,
    required this.progress,
    required this.onEditTarget,
  });

  final double totalCalories;
  final double targetCalories;
  final double remainingCalories;
  final double progress;
  final VoidCallback onEditTarget;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isOverTarget = remainingCalories < 0;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: colorScheme.primaryContainer,
                foregroundColor: colorScheme.onPrimaryContainer,
                child: const Icon(Icons.local_fire_department_rounded),
              ),
              const SizedBox(width: AppSpacing.gap12),
              Expanded(
                child: Text(
                  'Daily Intake',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              TextButton.icon(
                onPressed: onEditTarget,
                icon: const Icon(Icons.flag_rounded, size: 18),
                label: const Text('Target'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.gap16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                totalCalories.round().toString(),
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(width: AppSpacing.gap4),
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.gap8),
                child: Text(
                  'kcal logged',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.gap12),
          LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            borderRadius: BorderRadius.circular(999),
            color: isOverTarget ? colorScheme.error : colorScheme.tertiary,
          ),
          const SizedBox(height: AppSpacing.gap12),
          Row(
            children: [
              _SmallMetric(
                label: 'Target',
                value: '${targetCalories.round()} kcal',
              ),
              const SizedBox(width: AppSpacing.gap8),
              _SmallMetric(
                label: isOverTarget ? 'Over' : 'Left',
                value: '${remainingCalories.abs().round()} kcal',
                valueColor: isOverTarget ? colorScheme.error : colorScheme.tertiary,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SmallMetric extends StatelessWidget {
  const _SmallMetric({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.gap12),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: colorScheme.outlineVariant,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: AppSpacing.gap4),
            Text(
              value,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: valueColor,
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}