import 'package:uuid/uuid.dart';

import '../../../core/utils/date_utils.dart';
import '../hive_service.dart';
import '../models/task_model.dart';

class TaskRepository {
  TaskRepository();

  final _uuid = const Uuid();

  List<TaskModel> _allTasks() {
    return HiveService.tasksBox.values
        .map((rawTask) => TaskModel.fromMap(rawTask))
        .toList();
  }

  Future<List<TaskModel>> getTasksByDate(DateTime date) async {
    final key = AppDateUtils.dateKey(date);

    final tasks = _allTasks()
        .where((task) => task.planDate == key && !task.isDeleted)
        .toList();

    tasks.sort((a, b) => a.createdAt.compareTo(b.createdAt));

    return tasks;
  }

  Future<TaskModel?> getTaskById(String id) async {
    final rawTask = HiveService.tasksBox.get(id);

    if (rawTask == null) {
      return null;
    }

    return TaskModel.fromMap(rawTask);
  }

  Future<TaskModel> addTask({
    required DateTime date,
    required String title,
    String description = '',
    String? rolloverSourceTaskId,
  }) async {
    final now = DateTime.now();

    final task = TaskModel(
      id: _uuid.v4(),
      planDate: AppDateUtils.dateKey(date),
      title: title.trim(),
      description: description.trim(),
      progress: 0,
      rolloverSourceTaskId: rolloverSourceTaskId,
      isDeleted: false,
      createdAt: now,
      updatedAt: now,
    );

    await HiveService.tasksBox.put(task.id, task.toMap());

    return task;
  }

  Future<void> updateTaskProgress({
    required String id,
    required int progress,
  }) async {
    final task = await getTaskById(id);

    if (task == null) {
      return;
    }

    final safeProgress = progress.clamp(0, 100);

    final updatedTask = task.copyWith(
      progress: safeProgress,
      updatedAt: DateTime.now(),
    );

    await HiveService.tasksBox.put(id, updatedTask.toMap());
  }

  Future<void> updateTaskText({
    required String id,
    required String title,
    required String description,
  }) async {
    final task = await getTaskById(id);

    if (task == null) {
      return;
    }

    final updatedTask = task.copyWith(
      title: title.trim(),
      description: description.trim(),
      updatedAt: DateTime.now(),
    );

    await HiveService.tasksBox.put(id, updatedTask.toMap());
  }

  Future<void> deleteTask(String id) async {
    final task = await getTaskById(id);

    if (task == null) {
      return;
    }

    final deletedTask = task.copyWith(
      isDeleted: true,
      updatedAt: DateTime.now(),
    );

    await HiveService.tasksBox.put(id, deletedTask.toMap());
  }

  Future<List<TaskModel>> getUnfinishedTasksByDate(DateTime date) async {
    final tasks = await getTasksByDate(date);

    return tasks.where((task) => task.progress < 100).toList();
  }

  Future<int> rolloverUnfinishedTasksToDate(DateTime targetDate) async {
    final previousDate = AppDateUtils.previousDay(targetDate);
    final unfinishedTasks = await getUnfinishedTasksByDate(previousDate);
    final targetTasks = await getTasksByDate(targetDate);

    final existingRolloverSourceIds = targetTasks
        .map((task) => task.rolloverSourceTaskId)
        .whereType<String>()
        .toSet();

    int createdCount = 0;

    for (final task in unfinishedTasks) {
      if (existingRolloverSourceIds.contains(task.id)) {
        continue;
      }

      await addTask(
        date: targetDate,
        title: task.title,
        description: task.description,
        rolloverSourceTaskId: task.id,
      );

      createdCount++;
    }

    return createdCount;
  }
}