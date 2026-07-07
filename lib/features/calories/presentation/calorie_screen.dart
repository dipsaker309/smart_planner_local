import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/widgets/date_selector.dart';
import '../../../shared/widgets/empty_state.dart';
import '../application/calorie_controller.dart';
import 'widgets/food_entry_sheet.dart';
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
        title: const Text('Calorie Tracker'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openFoodEntrySheet(context, ref),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Food'),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        child: Column(
          children: [
            DateSelector(
              selectedDate: calorieState.selectedDate,
              onDateChanged: controller.loadForDate,
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    const Icon(Icons.local_fire_department_rounded, size: 36),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        'Daily Intake',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    Text(
                      '${calorieState.dailyTotalCalories.round()} kcal',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Builder(
                builder: (context) {
                  if (calorieState.isLoading) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (calorieState.logs.isEmpty) {
                    return const EmptyState(
                      icon: Icons.restaurant_rounded,
                      message:
                          'No food logged for this date.\nTap + Food to add one.',
                    );
                  }

                  return ListView.builder(
                    itemCount: calorieState.logs.length,
                    itemBuilder: (context, index) {
                      final log = calorieState.logs[index];

                      return FoodLogTile(
                        log: log,
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