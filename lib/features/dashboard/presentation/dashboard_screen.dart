import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/date_utils.dart';
import '../../../shared/widgets/app_card.dart';
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
            padding: const EdgeInsets.all(AppSpacing.screenPadding),
            children: [
              AppCard(
                child: Text(
                  'Dashboard failed to load.\n$error',
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          );
        },
        data: (summary) {
          return RefreshIndicator(
            onRefresh: () => _refreshDashboard(ref),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenPadding,
                AppSpacing.gap16,
                AppSpacing.screenPadding,
                AppSpacing.bottomScrollPadding,
              ),
              children: [
                _GreetingCard(summary: summary),
                const SizedBox(height: AppSpacing.gap16),
                _QuickActionsCard(
                  onAddTask: () => _openAddTaskSheet(context, ref),
                  onAddFood: () => _openAddFoodSheet(context, ref),
                  onOpenPlanner: () => _openPlannerToday(ref),
                  onOpenCalories: () => _openCaloriesToday(ref),
                  onOpenAnalytics: () => _openAnalytics(context, ref),
                ),
                const SizedBox(height: AppSpacing.gap24),
                _CalorieSummaryCard(
                  summary: summary,
                  onOpenCalories: () => _openCaloriesToday(ref),
                ),
                const SizedBox(height: AppSpacing.gap16),
                _PlannerSummaryCard(
                  summary: summary,
                  onOpenPlanner: () => _openPlannerToday(ref),
                ),
                const SizedBox(height: AppSpacing.gap24),
                _TaskPreviewCard(summary: summary),
                const SizedBox(height: AppSpacing.gap16),
                _FoodPreviewCard(summary: summary),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _GreetingCard extends StatelessWidget {
  const _GreetingCard({
    required this.summary,
  });

  final DashboardSummary summary;

  String _greetingTitle() {
    final hour = DateTime.now().hour;

    if (summary.totalTasks > 0 && summary.unfinishedTasks == 0) {
      return 'All caught up';
    }

    if (hour < 12) {
      return 'Good morning';
    }

    if (hour < 18) {
      return 'Keep going';
    }

    return 'Winding down';
  }

  String _summaryLine() {
    final taskText = summary.totalTasks == 0
        ? 'Nothing planned yet'
        : '${summary.unfinishedTasks} task(s) left today';

    if (summary.totalTasks > 0 && summary.unfinishedTasks == 0) {
      return 'Nothing left for today — nice work.';
    }

    final hour = DateTime.now().hour;

    if (hour >= 18 && summary.foodLogs.isEmpty) {
      return '$taskText — log dinner if you have not yet.';
    }

    return '$taskText — ${summary.totalCalories.round()} kcal logged.';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AppCard(
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: colorScheme.primaryContainer,
            foregroundColor: colorScheme.onPrimaryContainer,
            child: const Icon(Icons.insights_rounded),
          ),
          const SizedBox(width: AppSpacing.gap16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _greetingTitle(),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: AppSpacing.gap4),
                Text(
                  _summaryLine(),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: AppSpacing.gap8),
                Text(
                  AppDateUtils.formatFullDate(summary.today),
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: colorScheme.tertiary,
                        fontWeight: FontWeight.w600,
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
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeader(
            icon: Icons.flash_on_rounded,
            title: 'Quick actions',
          ),
          const SizedBox(height: AppSpacing.gap12),
          Wrap(
            spacing: AppSpacing.gap8,
            runSpacing: AppSpacing.gap8,
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
    final colorScheme = Theme.of(context).colorScheme;
    final remaining = summary.caloriesRemaining;
    final isOverTarget = remaining < 0;

    return AppCard(
      onTap: onOpenCalories,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(
            icon: Icons.local_fire_department_rounded,
            title: 'Calories',
            actionLabel: 'Open',
            onAction: onOpenCalories,
          ),
          const SizedBox(height: AppSpacing.gap16),
          Row(
            children: [
              SizedBox(
                width: 116,
                height: 116,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 116,
                      height: 116,
                      child: CircularProgressIndicator(
                        value: summary.calorieProgress,
                        strokeWidth: 8,
                        backgroundColor: colorScheme.surface,
                        color: colorScheme.tertiary,
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          remaining.abs().round().toString(),
                          style:
                              Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: isOverTarget
                                        ? colorScheme.error
                                        : colorScheme.onSurface,
                                  ),
                        ),
                        Text(
                          isOverTarget ? 'kcal over' : 'kcal left',
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.gap20),
              Expanded(
                child: Column(
                  children: [
                    _MetricRow(
                      label: 'Consumed',
                      value: '${summary.totalCalories.round()} kcal',
                    ),
                    const SizedBox(height: AppSpacing.gap8),
                    _MetricRow(
                      label: 'Target',
                      value: '${summary.calorieTarget.round()} kcal',
                    ),
                    const SizedBox(height: AppSpacing.gap8),
                    _MetricRow(
                      label: isOverTarget ? 'Over' : 'Left',
                      value: '${remaining.abs().round()} kcal',
                      valueColor:
                          isOverTarget ? colorScheme.error : colorScheme.tertiary,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
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
    final colorScheme = Theme.of(context).colorScheme;

    return AppCard(
      onTap: onOpenPlanner,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(
            icon: Icons.checklist_rounded,
            title: 'Planner',
            actionLabel: 'Open',
            onAction: onOpenPlanner,
          ),
          const SizedBox(height: AppSpacing.gap16),
          Row(
            children: [
              _StatBox(
                label: 'Total',
                value: '${summary.totalTasks}',
              ),
              const SizedBox(width: AppSpacing.gap8),
              _StatBox(
                label: 'Done',
                value: '${summary.doneTasks}',
              ),
              const SizedBox(width: AppSpacing.gap8),
              _StatBox(
                label: 'Left',
                value: '${summary.unfinishedTasks}',
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.gap16),
          LinearProgressIndicator(
            value: summary.taskCompletionProgress,
            minHeight: 8,
            borderRadius: BorderRadius.circular(999),
          ),
          const SizedBox(height: AppSpacing.gap8),
          Text(
            summary.totalTasks == 0
                ? 'No tasks added for today yet.'
                : '${(summary.taskCompletionProgress * 100).round()}% completed today',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
          ),
          if (summary.highPriorityUnfinishedTasks > 0) ...[
            const SizedBox(height: AppSpacing.gap12),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.gap12,
                vertical: AppSpacing.gap8,
              ),
              decoration: BoxDecoration(
                color: colorScheme.errorContainer.withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.flag_rounded,
                    size: 18,
                    color: colorScheme.error,
                  ),
                  const SizedBox(width: AppSpacing.gap8),
                  Text(
                    '${summary.highPriorityUnfinishedTasks} high-priority left',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: colorScheme.error,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _TaskPreviewCard extends StatelessWidget {
  const _TaskPreviewCard({
    required this.summary,
  });

  final DashboardSummary summary;

  Color _priorityColor(BuildContext context, String priority) {
    final colorScheme = Theme.of(context).colorScheme;

    switch (priority) {
      case 'high':
        return colorScheme.error;
      case 'low':
        return colorScheme.outline;
      case 'medium':
      default:
        return colorScheme.tertiary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final previewTasks = summary.previewTasks;
    final colorScheme = Theme.of(context).colorScheme;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeader(
            icon: Icons.task_alt_rounded,
            title: 'Today’s tasks',
          ),
          const SizedBox(height: AppSpacing.gap12),
          if (previewTasks.isEmpty)
            _CompactEmptyLine(
              icon: Icons.inbox_rounded,
              text: 'Nothing planned yet.',
            )
          else
            ...previewTasks.map((task) {
              final priorityColor = _priorityColor(context, task.priority);

              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.gap8),
                child: Row(
                  children: [
                    SizedBox(
                      width: 40,
                      child: Icon(
                        task.isDone
                            ? Icons.check_circle_rounded
                            : Icons.radio_button_unchecked_rounded,
                        color: task.isDone
                            ? colorScheme.primary
                            : colorScheme.outline,
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            task.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          const SizedBox(height: AppSpacing.gap4),
                          Row(
                            children: [
                              Text(
                                '${task.progress}% done',
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall
                                    ?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                              ),
                              const SizedBox(width: AppSpacing.gap8),
                              Icon(
                                Icons.circle,
                                size: 8,
                                color: priorityColor,
                              ),
                              const SizedBox(width: AppSpacing.gap4),
                              Text(
                                task.priorityLabel,
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall
                                    ?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                              ),
                            ],
                          ),
                        ],
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
    final colorScheme = Theme.of(context).colorScheme;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeader(
            icon: Icons.restaurant_menu_rounded,
            title: 'Today’s food logs',
          ),
          const SizedBox(height: AppSpacing.gap12),
          if (previewLogs.isEmpty)
            _CompactEmptyLine(
              icon: Icons.restaurant_rounded,
              text: 'No food logged yet.',
            )
          else
            ...previewLogs.map((log) {
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.gap8),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: colorScheme.primaryContainer,
                      foregroundColor: colorScheme.onPrimaryContainer,
                      child: const Icon(
                        Icons.restaurant_rounded,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.gap12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            log.foodName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          const SizedBox(height: AppSpacing.gap4),
                          Text(
                            '${_formatQuantity(log.quantity)} ${log.unit}'
                            ' • ${AppDateUtils.formatTime(log.consumedAt)}',
                            style:
                                Theme.of(context).textTheme.labelSmall?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.gap8),
                    Text(
                      '${log.calculatedCalories.round()}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: colorScheme.tertiary,
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
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

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
        if (actionLabel != null && onAction != null)
          TextButton(
            onPressed: onAction,
            child: Text(actionLabel!),
          ),
      ],
    );
  }
}

class _MetricRow extends StatelessWidget {
  const _MetricRow({
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

    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: valueColor,
                fontWeight: FontWeight.w800,
              ),
        ),
      ],
    );
  }
}

class _StatBox extends StatelessWidget {
  const _StatBox({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

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
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ],
        ),
      ),
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