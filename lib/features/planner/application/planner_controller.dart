import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../data/local/models/task_model.dart';
import '../../../data/local/repositories/task_repository.dart';

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return TaskRepository();
});

final plannerControllerProvider = Provider<PlannerController>((ref) {
  return PlannerController(ref.read(taskRepositoryProvider));
});

class PlannerController {
  PlannerController(this._repository);

  final TaskRepository _repository;
  final Uuid _uuid = const Uuid();

  List<TaskModel> getTasks() {
    return _repository.getAllTasks();
  }

  Future<void> addTask(String title) {
    final now = DateTime.now();
    final task = TaskModel(
      id: _uuid.v4(),
      title: title,
      createdAt: now,
      updatedAt: now,
    );

    return _repository.saveTask(task);
  }
}
