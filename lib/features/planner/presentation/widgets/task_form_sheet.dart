import 'package:flutter/material.dart';

class TaskFormSheet extends StatefulWidget {
  const TaskFormSheet({
    super.key,
    required this.onSubmit,
    this.initialTitle = '',
    this.initialDescription = '',
    this.initialPriority = 'medium',
    this.sheetTitle = 'Add Task',
    this.submitLabel = 'Add Task',
  });

  final Future<void> Function({
    required String title,
    required String description,
    required String priority,
  }) onSubmit;

  final String initialTitle;
  final String initialDescription;
  final String initialPriority;
  final String sheetTitle;
  final String submitLabel;

  @override
  State<TaskFormSheet> createState() => _TaskFormSheetState();
}

class _TaskFormSheetState extends State<TaskFormSheet> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;

  late String _priority;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    _titleController = TextEditingController(text: widget.initialTitle);
    _descriptionController = TextEditingController(
      text: widget.initialDescription,
    );
    _priority = widget.initialPriority;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveTask() async {
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a task title.')),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    await widget.onSubmit(
      title: title,
      description: description,
      priority: _priority,
    );

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomPadding),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.sheetTitle,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _titleController,
              autofocus: true,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Task title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Description optional',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _priority,
              decoration: const InputDecoration(
                labelText: 'Priority',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'high',
                  child: Text('High'),
                ),
                DropdownMenuItem(
                  value: 'medium',
                  child: Text('Medium'),
                ),
                DropdownMenuItem(
                  value: 'low',
                  child: Text('Low'),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _priority = value;
                  });
                }
              },
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: _isSaving ? null : _saveTask,
              icon: const Icon(Icons.save_rounded),
              label: Text(_isSaving ? 'Saving...' : widget.submitLabel),
            ),
          ],
        ),
      ),
    );
  }
}