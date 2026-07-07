import 'package:flutter/material.dart';

import '../../../../data/local/models/task_model.dart';
import 'progress_slider.dart';

class TaskTile extends StatelessWidget {
  const TaskTile({
    super.key,
    required this.task,
    required this.onProgressChanged,
    required this.onDelete,
  });

  final TaskModel task;
  final ValueChanged<int> onProgressChanged;
  final VoidCallback onDelete;

  Color _statusColor(BuildContext context) {
    if (task.isDone) {
      return Colors.green;
    }

    if (task.isPartiallyDone) {
      return Colors.orange;
    }

    return Theme.of(context).colorScheme.outline;
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  task.isDone
                      ? Icons.check_circle_rounded
                      : Icons.radio_button_unchecked_rounded,
                  color: statusColor,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    task.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          decoration:
                              task.isDone ? TextDecoration.lineThrough : null,
                        ),
                  ),
                ),
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline_rounded),
                  tooltip: 'Delete task',
                ),
              ],
            ),
            if (task.description.trim().isNotEmpty) ...[
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.only(left: 36),
                child: Text(
                  task.description,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ],
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 28),
              child: Text(
                task.statusLabel,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
            ProgressSlider(
              progress: task.progress,
              onChanged: onProgressChanged,
            ),
          ],
        ),
      ),
    );
  }
}