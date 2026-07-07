import 'package:hive_ce/hive.dart';

import '../hive_service.dart';
import '../models/task_model.dart';

class TaskRepository {
  TaskRepository({Box<Map>? box}) : _box = box ?? HiveService.tasksBox;

  final Box<Map> _box;

  List<TaskModel> getAllTasks() {
    final tasks = _box.values
        .map((value) => TaskModel.fromMap(Map<String, dynamic>.from(value)))
        .toList();

    tasks.sort((first, second) => first.createdAt.compareTo(second.createdAt));
    return tasks;
  }

  Future<void> saveTask(TaskModel task) {
    return _box.put(task.id, task.toMap());
  }

  Future<void> deleteTask(String taskId) {
    return _box.delete(taskId);
  }
}
