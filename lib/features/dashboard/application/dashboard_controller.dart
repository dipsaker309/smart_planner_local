import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/date_utils.dart';
import '../../../data/local/models/food_log_model.dart';
import '../../../data/local/models/task_model.dart';
import '../../../data/local/repositories/food_repository.dart';
import '../../../data/local/repositories/settings_repository.dart';
import '../../../data/local/repositories/task_repository.dart';

final dashboardSummaryProvider = FutureProvider<DashboardSummary>((ref) async {
  final taskRepository = TaskRepository();
  final foodRepository = FoodRepository();
  final settingsRepository = SettingsRepository();

  final today = AppDateUtils.today();

  final tasks = await taskRepository.getTasksByDate(today);
  final foodLogs = foodRepository.getFoodLogsByDate(today);
  final totalCalories = foodRepository.getDailyTotalCalories(today);
  final calorieTarget = settingsRepository.getDailyCalorieTarget();

  return DashboardSummary(
    today: today,
    tasks: tasks,
    foodLogs: foodLogs,
    totalCalories: totalCalories,
    calorieTarget: calorieTarget,
  );
});

class DashboardSummary {
  const DashboardSummary({
    required this.today,
    required this.tasks,
    required this.foodLogs,
    required this.totalCalories,
    required this.calorieTarget,
  });

  final DateTime today;
  final List<TaskModel> tasks;
  final List<FoodLogModel> foodLogs;
  final double totalCalories;
  final double calorieTarget;

  int get totalTasks => tasks.length;

  int get doneTasks {
    return tasks.where((task) => task.progress >= 100).length;
  }

  int get unfinishedTasks {
    return tasks.where((task) => task.progress < 100).length;
  }

  int get highPriorityUnfinishedTasks {
    return tasks
        .where((task) => task.priority == 'high' && task.progress < 100)
        .length;
  }

  double get taskCompletionProgress {
    if (totalTasks == 0) {
      return 0;
    }

    return (doneTasks / totalTasks).clamp(0, 1).toDouble();
  }

  double get caloriesRemaining {
    return calorieTarget - totalCalories;
  }

  double get calorieProgress {
    if (calorieTarget <= 0) {
      return 0;
    }

    return (totalCalories / calorieTarget).clamp(0, 1).toDouble();
  }

  List<TaskModel> get previewTasks {
    return tasks.take(3).toList();
  }

  List<FoodLogModel> get previewFoodLogs {
    return foodLogs.take(3).toList();
  }
}