import 'package:flutter/material.dart';

import '../../../../data/local/models/task_model.dart';

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

  Color _priorityColor(TaskModel task) {
    switch (task.priority) {
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
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomPadding),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Rollover Tasks',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Select unfinished tasks from yesterday to copy into this date.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              if (widget.candidates.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 28),
                  child: Text(
                    'No unfinished tasks found from yesterday, or they were already rolled over.',
                    textAlign: TextAlign.center,
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
                const SizedBox(height: 8),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 360),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: widget.candidates.length,
                    itemBuilder: (context, index) {
                      final task = widget.candidates[index];
                      final selected = _selectedTaskIds.contains(task.id);
                      final priorityColor = _priorityColor(task);

                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: CheckboxListTile(
                          value: selected,
                          onChanged: (value) {
                            _toggleTask(task.id, value ?? false);
                          },
                          title: Text(task.title),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (task.description.trim().isNotEmpty)
                                Text(task.description),
                              const SizedBox(height: 6),
                              Wrap(
                                spacing: 8,
                                children: [
                                  Chip(
                                    visualDensity: VisualDensity.compact,
                                    label: Text('${task.progress}% done'),
                                  ),
                                  Chip(
                                    visualDensity: VisualDensity.compact,
                                    avatar: Icon(
                                      Icons.flag_rounded,
                                      size: 16,
                                      color: priorityColor,
                                    ),
                                    side: BorderSide(color: priorityColor),
                                    label: Text(task.priorityLabel),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          controlAffinity: ListTileControlAffinity.leading,
                        ),
                      );
                    },
                  ),
                ),
              ],
              const SizedBox(height: 16),
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