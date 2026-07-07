import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../data/local/models/task_model.dart';
import '../../../../shared/widgets/app_card.dart';

class RolloverTaskSheet extends StatefulWidget {
  const RolloverTaskSheet({
    super.key,
    required this.candidates,
    required this.onSubmit,
  });

  final List<TaskModel> candidates;
  final Future<void> Function(List<String> selectedTaskIds) onSubmit;

  @override
  State<RolloverTaskSheet> createState() => _RolloverTaskSheetState();
}

class _RolloverTaskSheetState extends State<RolloverTaskSheet> {
  late final Set<String> _selectedTaskIds;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();

    _selectedTaskIds = widget.candidates.map((task) => task.id).toSet();
  }

  void _toggleTask(String taskId, bool selected) {
    setState(() {
      if (selected) {
        _selectedTaskIds.add(taskId);
      } else {
        _selectedTaskIds.remove(taskId);
      }
    });
  }

  void _selectAll() {
    setState(() {
      _selectedTaskIds
        ..clear()
        ..addAll(widget.candidates.map((task) => task.id));
    });
  }

  void _clearAll() {
    setState(() {
      _selectedTaskIds.clear();
    });
  }

  Future<void> _submit() async {
    if (_selectedTaskIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one task.')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    await widget.onSubmit(_selectedTaskIds.toList());

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  Color _priorityColor(BuildContext context, TaskModel task) {
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

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomPadding),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.gap20,
            AppSpacing.gap12,
            AppSpacing.gap20,
            AppSpacing.gap20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: colorScheme.primaryContainer,
                    foregroundColor: colorScheme.onPrimaryContainer,
                    child: const Icon(Icons.history_rounded),
                  ),
                  const SizedBox(width: AppSpacing.gap12),
                  Expanded(
                    child: Text(
                      'Rollover Tasks',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.gap8),
              Text(
                'Select unfinished tasks from yesterday to copy into this date.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: AppSpacing.gap16),
              if (widget.candidates.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: AppSpacing.gap24,
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.inbox_rounded,
                        size: 56,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(height: AppSpacing.gap12),
                      Text(
                        'No tasks to roll over',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: AppSpacing.gap4),
                      Text(
                        'Yesterday has no unfinished tasks, or they were already rolled over.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                )
              else ...[
                Row(
                  children: [
                    TextButton.icon(
                      onPressed: _selectAll,
                      icon: const Icon(Icons.done_all_rounded),
                      label: const Text('Select all'),
                    ),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: _clearAll,
                      icon: const Icon(Icons.clear_rounded),
                      label: const Text('Clear'),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.gap8),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 380),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: widget.candidates.length,
                    itemBuilder: (context, index) {
                      final task = widget.candidates[index];
                      final selected = _selectedTaskIds.contains(task.id);
                      final priorityColor = _priorityColor(context, task);

                      return AppCard(
                        margin: const EdgeInsets.only(
                          bottom: AppSpacing.gap8,
                        ),
                        padding: const EdgeInsets.all(AppSpacing.gap12),
                        child: Row(
                          children: [
                            Checkbox(
                              value: selected,
                              onChanged: (value) {
                                _toggleTask(task.id, value ?? false);
                              },
                            ),
                            const SizedBox(width: AppSpacing.gap8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    task.title,
                                    style:
                                        Theme.of(context).textTheme.titleSmall,
                                  ),
                                  if (task.description.trim().isNotEmpty) ...[
                                    const SizedBox(height: AppSpacing.gap4),
                                    Text(
                                      task.description,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color:
                                                colorScheme.onSurfaceVariant,
                                          ),
                                    ),
                                  ],
                                  const SizedBox(height: AppSpacing.gap8),
                                  Row(
                                    children: [
                                      Text(
                                        '${task.progress}% done',
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelSmall
                                            ?.copyWith(
                                              color:
                                                  colorScheme.onSurfaceVariant,
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
                                              color:
                                                  colorScheme.onSurfaceVariant,
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
                    },
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.gap16),
              if (widget.candidates.isNotEmpty)
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _isSubmitting ? null : _submit,
                    icon: const Icon(Icons.redo_rounded),
                    label: Text(
                      _isSubmitting
                          ? 'Rolling over...'
                          : 'Roll Over Selected (${_selectedTaskIds.length})',
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}