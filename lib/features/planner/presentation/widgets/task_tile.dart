import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../data/local/models/task_model.dart';
import '../../../../shared/widgets/app_card.dart';
import 'progress_slider.dart';

class TaskTile extends StatelessWidget {
  const TaskTile({
    super.key,
    required this.task,
    required this.onProgressChanged,
    required this.onEdit,
    required this.onDelete,
  });

  final TaskModel task;
  final ValueChanged<int> onProgressChanged;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  Color _statusColor(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (task.isDone) {
      return colorScheme.primary;
    }

    if (task.isPartiallyDone) {
      return colorScheme.tertiary;
    }

    return colorScheme.outline;
  }

  Color _priorityColor(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    switch (task.priority) {
      case 'high':
        return colorScheme.error;
      case 'low':
        return colorScheme.outline;
      case 'medium':
      default:
        return colorScheme.tertiary;
    }
  }

  String _progressText() {
    if (task.isDone) {
      return 'Completed';
    }

    if (task.isPending) {
      return 'Not started';
    }

    return '${task.progress}% done';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final statusColor = _statusColor(context);
    final priorityColor = _priorityColor(context);

    return AppCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.gap12),
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(
                width: 40,
                child: Icon(
                  task.isDone
                      ? Icons.check_circle_rounded
                      : Icons.radio_button_unchecked_rounded,
                  color: statusColor,
                  size: 28,
                ),
              ),
              const SizedBox(width: AppSpacing.gap8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            decoration:
                                task.isDone ? TextDecoration.lineThrough : null,
                          ),
                    ),
                    const SizedBox(height: AppSpacing.gap4),
                    Row(
                      children: [
                        Text(
                          _progressText(),
                          style:
                              Theme.of(context).textTheme.labelMedium?.copyWith(
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
                          '${task.priorityLabel} priority',
                          style:
                              Theme.of(context).textTheme.labelMedium?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                        ),
                        if (task.rolloverSourceTaskId != null) ...[
                          const SizedBox(width: AppSpacing.gap8),
                          Icon(
                            Icons.history_rounded,
                            size: 16,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_horiz_rounded),
                tooltip: 'Task options',
                onSelected: (value) {
                  if (value == 'edit') {
                    onEdit();
                  }

                  if (value == 'delete') {
                    onDelete();
                  }
                },
                itemBuilder: (context) {
                  return const [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit_outlined),
                          SizedBox(width: 8),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline_rounded),
                          SizedBox(width: 8),
                          Text('Delete'),
                        ],
                      ),
                    ),
                  ];
                },
              ),
            ],
          ),
          if (task.description.trim().isNotEmpty) ...[
            const SizedBox(height: AppSpacing.gap12),
            Padding(
              padding: const EdgeInsets.only(left: 48),
              child: Text(
                task.description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.gap12),
          ProgressSlider(
            progress: task.progress,
            onChanged: onProgressChanged,
          ),
        ],
      ),
    );
  }
}