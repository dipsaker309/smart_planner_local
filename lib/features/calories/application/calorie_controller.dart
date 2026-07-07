import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/date_utils.dart';
import '../../../data/local/models/food_item_model.dart';
import '../../../data/local/models/food_log_model.dart';
import '../../../data/local/repositories/food_repository.dart';
import '../../../data/local/repositories/settings_repository.dart';

final foodRepositoryProvider = Provider<FoodRepository>((ref) {
  return FoodRepository();
});

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepository();
});

final calorieControllerProvider =
    NotifierProvider<CalorieController, CalorieState>(
  CalorieController.new,
);

class CalorieState {
  const CalorieState({
    required this.selectedDate,
    required this.foodItems,
    required this.logs,
    required this.dailyTotalCalories,
    required this.dailyCalorieTarget,
    required this.isLoading,
    this.message,
  });

  factory CalorieState.initial() {
    return CalorieState(
      selectedDate: AppDateUtils.today(),
      foodItems: const [],
      logs: const [],
      dailyTotalCalories: 0,
      dailyCalorieTarget: 2000,
      isLoading: false,
    );
  }

  final DateTime selectedDate;
  final List<FoodItemModel> foodItems;
  final List<FoodLogModel> logs;
  final double dailyTotalCalories;
  final double dailyCalorieTarget;
  final bool isLoading;
  final String? message;

  double get remainingCalories => dailyCalorieTarget - dailyTotalCalories;

  double get targetProgress {
    if (dailyCalorieTarget <= 0) {
      return 0;
    }

    return (dailyTotalCalories / dailyCalorieTarget).clamp(0, 1).toDouble();
  }

  CalorieState copyWith({
    DateTime? selectedDate,
    List<FoodItemModel>? foodItems,
    List<FoodLogModel>? logs,
    double? dailyTotalCalories,
    double? dailyCalorieTarget,
    bool? isLoading,
    String? message,
  }) {
    return CalorieState(
      selectedDate: selectedDate ?? this.selectedDate,
      foodItems: foodItems ?? this.foodItems,
      logs: logs ?? this.logs,
      dailyTotalCalories: dailyTotalCalories ?? this.dailyTotalCalories,
      dailyCalorieTarget: dailyCalorieTarget ?? this.dailyCalorieTarget,
      isLoading: isLoading ?? this.isLoading,
      message: message,
    );
  }
}

class CalorieController extends Notifier<CalorieState> {
  late final FoodRepository _foodRepository;
  late final SettingsRepository _settingsRepository;

  @override
  CalorieState build() {
    _foodRepository = ref.read(foodRepositoryProvider);
    _settingsRepository = ref.read(settingsRepositoryProvider);

    final initialState = CalorieState.initial();

    Future.microtask(() async {
      await _foodRepository.seedStarterFoodsIfNeeded();
      loadForDate(initialState.selectedDate);
    });

    return initialState;
  }

  void loadForDate(DateTime date) {
    state = state.copyWith(
      selectedDate: date,
      isLoading: true,
      message: null,
    );

    final foodItems = _foodRepository.getFoodItems();
    final logs = _foodRepository.getFoodLogsByDate(date);
    final total = _foodRepository.getDailyTotalCalories(date);
    final target = _settingsRepository.getDailyCalorieTarget();

    state = state.copyWith(
      selectedDate: date,
      foodItems: foodItems,
      logs: logs,
      dailyTotalCalories: total,
      dailyCalorieTarget: target,
      isLoading: false,
    );
  }

  Future<void> updateDailyCalorieTarget(double target) async {
    if (target <= 0) {
      state = state.copyWith(message: 'Please enter a valid calorie target.');
      return;
    }

    await _settingsRepository.setDailyCalorieTarget(target);

    state = state.copyWith(
      dailyCalorieTarget: target,
      message: 'Daily calorie target updated.',
    );
  }

  Future<void> addFoodLog({
    required String foodItemId,
    required double quantity,
    String note = '',
  }) async {
    if (quantity <= 0) {
      state = state.copyWith(message: 'Please enter a valid quantity.');
      return;
    }

    final foodItem = _foodRepository.getFoodItemById(foodItemId);

    if (foodItem == null) {
      state = state.copyWith(message: 'Selected food was not found.');
      return;
    }

    await _foodRepository.addFoodLog(
      date: state.selectedDate,
      foodItem: foodItem,
      quantity: quantity,
      note: note,
    );

    loadForDate(state.selectedDate);
  }

  Future<void> addCustomFoodAndLog({
    required String name,
    required double baseQuantity,
    required String unit,
    required double calories,
    required double logQuantity,
    String note = '',
  }) async {
    if (name.trim().isEmpty) {
      state = state.copyWith(message: 'Food name cannot be empty.');
      return;
    }

    if (baseQuantity <= 0 || calories < 0 || logQuantity <= 0) {
      state = state.copyWith(message: 'Please enter valid numbers.');
      return;
    }

    await _foodRepository.addCustomFoodAndLog(
      date: state.selectedDate,
      name: name,
      baseQuantity: baseQuantity,
      unit: unit,
      calories: calories,
      logQuantity: logQuantity,
      note: note,
    );

    loadForDate(state.selectedDate);

    state = state.copyWith(message: 'Food saved and logged.');
  }

  Future<void> deleteFoodLog(String id) async {
    await _foodRepository.deleteFoodLog(id);
    loadForDate(state.selectedDate);
  }

  void clearMessage() {
    state = state.copyWith(message: null);
  }
}