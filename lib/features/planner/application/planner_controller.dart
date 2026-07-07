import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/date_utils.dart';
import '../../../data/local/models/task_model.dart';
import '../../../data/local/repositories/task_repository.dart';

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return TaskRepository();
});

final plannerControllerProvider =
    NotifierProvider<PlannerController, PlannerState>(
  PlannerController.new,
);

class PlannerState {
  const PlannerState({
    required this.selectedDate,
    required this.tasks,
    required this.isLoading,
    this.message,
  });

  factory PlannerState.initial() {
    return PlannerState(
      selectedDate: AppDateUtils.today(),
      tasks: const [],
      isLoading: false,
    );
  }

  final DateTime selectedDate;
  final List<TaskModel> tasks;
  final bool isLoading;
  final String? message;

  PlannerState copyWith({
    DateTime? selectedDate,
    List<TaskModel>? tasks,
    bool? isLoading,
    String? message,
  }) {
    return PlannerState(
      selectedDate: selectedDate ?? this.selectedDate,
      tasks: tasks ?? this.tasks,
      isLoading: isLoading ?? this.isLoading,
      message: message,
    );
  }
}

class PlannerController extends Notifier<PlannerState> {
  late final TaskRepository _repository;

  @override
  PlannerState build() {
    _repository = ref.read(taskRepositoryProvider);

    final initialState = PlannerState.initial();

    Future.microtask(() {
      loadTasksForDate(initialState.selectedDate);
    });

    return initialState;
  }

  Future<void> loadTasksForDate(DateTime date) async {
    state = state.copyWith(
      selectedDate: date,
      isLoading: true,
      message: null,
    );

    final tasks = await _repository.getTasksByDate(date);

    state = state.copyWith(
      selectedDate: date,
      tasks: tasks,
      isLoading: false,
    );
  }

  Future<void> addTask({
    required String title,
    String description = '',
    String priority = 'medium',
  }) async {
    if (title.trim().isEmpty) {
      state = state.copyWith(message: 'Task title cannot be empty.');
      return;
    }

    await _repository.addTask(
      date: state.selectedDate,
      title: title,
      description: description,
      priority: priority,
    );

    await loadTasksForDate(state.selectedDate);
  }

  Future<void> updateProgress({
    required String taskId,
    required int progress,
  }) async {
    await _repository.updateTaskProgress(
      id: taskId,
      progress: progress,
    );

    await loadTasksForDate(state.selectedDate);
  }

  Future<void> deleteTask(String taskId) async {
    await _repository.deleteTask(taskId);
    await loadTasksForDate(state.selectedDate);
  }

  Future<void> rolloverFromPreviousDay() async {
    final createdCount = await _repository.rolloverUnfinishedTasksToDate(
      state.selectedDate,
    );

    await loadTasksForDate(state.selectedDate);

    if (createdCount == 0) {
      state = state.copyWith(
        message: 'No unfinished tasks found from yesterday.',
      );
    } else {
      state = state.copyWith(
        message: '$createdCount task(s) rolled over from yesterday.',
      );
    }
  }

  void clearMessage() {
    state = state.copyWith(message: null);
  }
}