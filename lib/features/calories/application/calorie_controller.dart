import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../data/local/models/food_item_model.dart';
import '../../../data/local/models/food_log_model.dart';
import '../../../data/local/repositories/food_repository.dart';

final foodRepositoryProvider = Provider<FoodRepository>((ref) {
  return FoodRepository();
});

final calorieControllerProvider = Provider<CalorieController>((ref) {
  return CalorieController(ref.read(foodRepositoryProvider));
});

class CalorieController {
  CalorieController(this._repository);

  final FoodRepository _repository;
  final Uuid _uuid = const Uuid();

  List<FoodLogModel> getLogs() {
    return _repository.getAllLogs();
  }

  Future<void> addFood({
    required String name,
    required int calories,
    DateTime? date,
  }) {
    final now = DateTime.now();
    final item = FoodItemModel(
      id: _uuid.v4(),
      name: name,
      calories: calories,
    );
    final log = FoodLogModel(
      id: _uuid.v4(),
      date: date ?? now,
      items: [item],
      createdAt: now,
    );

    return _repository.saveLog(log);
  }
}
