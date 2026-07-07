import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/date_utils.dart';
import '../../../data/local/models/food_item_model.dart';
import '../../../data/local/models/food_log_model.dart';
import '../../../data/local/repositories/food_repository.dart';

final foodRepositoryProvider = Provider<FoodRepository>((ref) {
  return FoodRepository();
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
    required this.isLoading,
    this.message,
  });

  factory CalorieState.initial() {
    return CalorieState(
      selectedDate: AppDateUtils.today(),
      foodItems: const [],
      logs: const [],
      dailyTotalCalories: 0,
      isLoading: false,
    );
  }

  final DateTime selectedDate;
  final List<FoodItemModel> foodItems;
  final List<FoodLogModel> logs;
  final double dailyTotalCalories;
  final bool isLoading;
  final String? message;

  CalorieState copyWith({
    DateTime? selectedDate,
    List<FoodItemModel>? foodItems,
    List<FoodLogModel>? logs,
    double? dailyTotalCalories,
    bool? isLoading,
    String? message,
  }) {
    return CalorieState(
      selectedDate: selectedDate ?? this.selectedDate,
      foodItems: foodItems ?? this.foodItems,
      logs: logs ?? this.logs,
      dailyTotalCalories: dailyTotalCalories ?? this.dailyTotalCalories,
      isLoading: isLoading ?? this.isLoading,
      message: message,
    );
  }
}

class CalorieController extends Notifier<CalorieState> {
  late final FoodRepository _repository;

  @override
  CalorieState build() {
    _repository = ref.read(foodRepositoryProvider);

    final initialState = CalorieState.initial();

    Future.microtask(() async {
      await _repository.seedStarterFoodsIfNeeded();
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

    final foodItems = _repository.getFoodItems();
    final logs = _repository.getFoodLogsByDate(date);
    final total = _repository.getDailyTotalCalories(date);

    state = state.copyWith(
      selectedDate: date,
      foodItems: foodItems,
      logs: logs,
      dailyTotalCalories: total,
      isLoading: false,
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

    final foodItem = _repository.getFoodItemById(foodItemId);

    if (foodItem == null) {
      state = state.copyWith(message: 'Selected food was not found.');
      return;
    }

    await _repository.addFoodLog(
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

    await _repository.addCustomFoodAndLog(
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
    await _repository.deleteFoodLog(id);
    loadForDate(state.selectedDate);
  }

  void clearMessage() {
    state = state.copyWith(message: null);
  }
}