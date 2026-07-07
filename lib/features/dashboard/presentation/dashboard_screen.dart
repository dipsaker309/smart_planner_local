import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/date_utils.dart';
import '../../calories/application/calorie_controller.dart';
import '../../calories/presentation/analytics_screen.dart';
import '../../calories/presentation/widgets/food_entry_sheet.dart';
import '../../planner/application/planner_controller.dart';
import '../../planner/presentation/widgets/task_form_sheet.dart';
import '../application/dashboard_controller.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({
    super.key,
    required this.onOpenPlanner,
    required this.onOpenCalories,
  });

  final VoidCallback onOpenPlanner;
  final VoidCallback onOpenCalories;

  Future<void> _refreshDashboard(WidgetRef ref) async {
    ref.invalidate(dashboardSummaryProvider);
    await ref.read(dashboardSummaryProvider.future);
  }

  Future<void> _openAddTaskSheet(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final today = AppDateUtils.today();
    final plannerController = ref.read(plannerControllerProvider.notifier);

    await plannerController.loadTasksForDate(today);

    if (!context.mounted) {
      return;
    }

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        return TaskFormSheet(
          onSubmit: ({
            required String title,
            required String description,
            required String priority,
          }) {
            return plannerController.addTask(
              title: title,
              description: description,
              priority: priority,
            );
          },
        );
      },
    );

    ref.invalidate(dashboardSummaryProvider);
  }

  Future<void> _openAddFoodSheet(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final today = AppDateUtils.today();

    final foodRepository = ref.read(foodRepositoryProvider);
    await foodRepository.seedStarterFoodsIfNeeded();

    final foodItems = foodRepository.getFoodItems();
    final calorieController = ref.read(calorieControllerProvider.notifier);

    calorieController.loadForDate(today);

    if (!context.mounted) {
      return;
    }

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        return FoodEntrySheet(
          foodItems: foodItems,
          onLogExistingFood: ({
            required String foodItemId,
            required double quantity,
            required String note,
          }) {
            return calorieController.addFoodLog(
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
            return calorieController.addCustomFoodAndLog(
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

    ref.invalidate(dashboardSummaryProvider);
  }

  void _openAnalytics(BuildContext context, WidgetRef ref) {
    ref.read(calorieControllerProvider.notifier).loadForDate(
          AppDateUtils.today(),
        );

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const AnalyticsScreen(),
      ),
    );
  }

  void _openPlannerToday(WidgetRef ref) {
    ref.read(plannerControllerProvider.notifier).loadTasksForDate(
          AppDateUtils.today(),
        );
    onOpenPlanner();
  }

  void _openCaloriesToday(WidgetRef ref) {
    ref.read(calorieControllerProvider.notifier).loadForDate(
          AppDateUtils.today(),
        );
    onOpenCalories();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(dashboardSummaryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            onPressed: () {
              ref.invalidate(dashboardSummaryProvider);
            },
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh dashboard',
          ),
        ],
      ),
      body: summaryAsync.when(
        loading: () {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
        error: (error, stackTrace) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    'Dashboard failed to load.\n$error',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          );
        },
        data: (summary) {
          return RefreshIndicator(
            onRefresh: () => _refreshDashboard(ref),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              children: [
                _DashboardHeader(summary: summary),
                const SizedBox(height: 16),
                _QuickActionsCard(
                  onAddTask: () => _openAddTaskSheet(context, ref),
                  onAddFood: () => _openAddFoodSheet(context, ref),
                  onOpenPlanner: () => _openPlannerToday(ref),
                  onOpenCalories: () => _openCaloriesToday(ref),
                  onOpenAnalytics: () => _openAnalytics(context, ref),
                ),
                const SizedBox(height: 16),
                _PlannerSummaryCard(
                  summary: summary,
                  onOpenPlanner: () => _openPlannerToday(ref),
                ),
                const SizedBox(height: 16),
                _CalorieSummaryCard(
                  summary: summary,
                  onOpenCalories: () => _openCaloriesToday(ref),
                ),
                const SizedBox(height: 16),
                _TaskPreviewCard(summary: summary),
                const SizedBox(height: 16),
                _FoodPreviewCard(summary: summary),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader({
    required this.summary,
  });

  final DashboardSummary summary;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 26,
              child: Icon(Icons.dashboard_rounded),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Today',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppDateUtils.formatFullDate(summary.today),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionsCard extends StatelessWidget {
  const _QuickActionsCard({
    required this.onAddTask,
    required this.onAddFood,
    required this.onOpenPlanner,
    required this.onOpenCalories,
    required this.onOpenAnalytics,
  });

  final VoidCallback onAddTask;
  final VoidCallback onAddFood;
  final VoidCallback onOpenPlanner;
  final VoidCallback onOpenCalories;
  final VoidCallback onOpenAnalytics;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick actions',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                FilledButton.icon(
                  onPressed: onAddTask,
                  icon: const Icon(Icons.add_task_rounded),
                  label: const Text('Add Task'),
                ),
                FilledButton.icon(
                  onPressed: onAddFood,
                  icon: const Icon(Icons.restaurant_rounded),
                  label: const Text('Add Food'),
                ),
                OutlinedButton.icon(
                  onPressed: onOpenPlanner,
                  icon: const Icon(Icons.checklist_rounded),
                  label: const Text('Planner'),
                ),
                OutlinedButton.icon(
                  onPressed: onOpenCalories,
                  icon: const Icon(Icons.local_fire_department_rounded),
                  label: const Text('Calories'),
                ),
                OutlinedButton.icon(
                  onPressed: onOpenAnalytics,
                  icon: const Icon(Icons.bar_chart_rounded),
                  label: const Text('Analytics'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PlannerSummaryCard extends StatelessWidget {
  const _PlannerSummaryCard({
    required this.summary,
    required this.onOpenPlanner,
  });

  final DashboardSummary summary;
  final VoidCallback onOpenPlanner;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onOpenPlanner,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionTitle(
                icon: Icons.checklist_rounded,
                title: 'Planner summary',
                actionLabel: 'Open',
                onAction: onOpenPlanner,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _MiniStat(
                    label: 'Total',
                    value: '${summary.totalTasks}',
                  ),
                  _MiniStat(
                    label: 'Done',
                    value: '${summary.doneTasks}',
                  ),
                  _MiniStat(
                    label: 'Unfinished',
                    value: '${summary.unfinishedTasks}',
                  ),
                ],
              ),
              const SizedBox(height: 16),
              LinearProgressIndicator(
                value: summary.taskCompletionProgress,
                minHeight: 8,
                borderRadius: BorderRadius.circular(999),
              ),
              const SizedBox(height: 10),
              Text(
                summary.totalTasks == 0
                    ? 'No tasks added for today yet.'
                    : '${(summary.taskCompletionProgress * 100).round()}% completed today',
              ),
              if (summary.highPriorityUnfinishedTasks > 0) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.flag_rounded,
                      size: 18,
                      color: Colors.red,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${summary.highPriorityUnfinishedTasks} high-priority task(s) unfinished',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _CalorieSummaryCard extends StatelessWidget {
  const _CalorieSummaryCard({
    required this.summary,
    required this.onOpenCalories,
  });

  final DashboardSummary summary;
  final VoidCallback onOpenCalories;

  @override
  Widget build(BuildContext context) {
    final remaining = summary.caloriesRemaining;

    return Card(
      child: InkWell(
        onTap: onOpenCalories,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionTitle(
                icon: Icons.local_fire_department_rounded,
                title: 'Calorie summary',
                actionLabel: 'Open',
                onAction: onOpenCalories,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _MiniStat(
                    label: 'Consumed',
                    value: '${summary.totalCalories.round()}',
                    suffix: 'kcal',
                  ),
                  _MiniStat(
                    label: 'Target',
                    value: '${summary.calorieTarget.round()}',
                    suffix: 'kcal',
                  ),
                  _MiniStat(
                    label: remaining >= 0 ? 'Left' : 'Over',
                    value: '${remaining.abs().round()}',
                    suffix: 'kcal',
                  ),
                ],
              ),
              const SizedBox(height: 16),
              LinearProgressIndicator(
                value: summary.calorieProgress,
                minHeight: 8,
                borderRadius: BorderRadius.circular(999),
              ),
              const SizedBox(height: 10),
              Text(
                remaining >= 0
                    ? '${remaining.round()} kcal left for today'
                    : '${remaining.abs().round()} kcal over target today',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: remaining >= 0 ? null : Colors.red,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TaskPreviewCard extends StatelessWidget {
  const _TaskPreviewCard({
    required this.summary,
  });

  final DashboardSummary summary;

  Color _priorityColor(String priority) {
    switch (priority) {
      case 'high':
        return Colors.red;
      case 'low':
        return Colors.blueGrey;
      case 'medium':
      default:
        return Colors.amber.shade800;
    }
  }

  @override
  Widget build(BuildContext context) {
    final previewTasks = summary.previewTasks;

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Today’s tasks',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            if (previewTasks.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 14),
                child: Text('No tasks added yet.'),
              )
            else
              ...previewTasks.map((task) {
                final priorityColor = _priorityColor(task.priority);

                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    task.isDone
                        ? Icons.check_circle_rounded
                        : Icons.radio_button_unchecked_rounded,
                  ),
                  title: Text(task.title),
                  subtitle: Text('${task.progress}% done'),
                  trailing: Icon(
                    Icons.flag_rounded,
                    color: priorityColor,
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}

class _FoodPreviewCard extends StatelessWidget {
  const _FoodPreviewCard({
    required this.summary,
  });

  final DashboardSummary summary;

  String _formatQuantity(double value) {
    if (value % 1 == 0) {
      return value.toStringAsFixed(0);
    }

    return value.toStringAsFixed(1);
  }

  @override
  Widget build(BuildContext context) {
    final previewLogs = summary.previewFoodLogs;

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Today’s food logs',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            if (previewLogs.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 14),
                child: Text('No food logged yet.'),
              )
            else
              ...previewLogs.map((log) {
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    child: Text(
                      log.calculatedCalories.round().toString(),
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                  title: Text(log.foodName),
                  subtitle: Text(
                    '${_formatQuantity(log.quantity)} ${log.unit}'
                    ' • ${AppDateUtils.formatTime(log.consumedAt)}',
                  ),
                  trailing: Text(
                    '${log.calculatedCalories.round()} kcal',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.icon,
    required this.title,
    required this.actionLabel,
    required this.onAction,
  });

  final IconData icon;
  final String title;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        TextButton(
          onPressed: onAction,
          child: Text(actionLabel),
        ),
      ],
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.label,
    required this.value,
    this.suffix,
  });

  final String label;
  final String value;
  final String? suffix;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium,
          ),
          const SizedBox(height: 4),
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.end,
            spacing: 4,
            children: [
              Text(
                value,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              if (suffix != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Text(
                    suffix!,
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}