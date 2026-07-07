import 'package:flutter/material.dart';

import '../../../../data/local/models/task_model.dart';

class TaskTile extends StatelessWidget {
  const TaskTile({
    required this.task,
    super.key,
  });

  final TaskModel task;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Checkbox(
        value: task.isCompleted,
        onChanged: null,
      ),
      title: Text(task.title),
      subtitle: task.notes.isEmpty ? null : Text(task.notes),
      trailing: Text('${(task.progress * 100).round()}%'),
    );
  }
}
