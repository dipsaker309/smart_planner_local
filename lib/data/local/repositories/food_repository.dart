import 'package:uuid/uuid.dart';

import '../../../core/utils/date_utils.dart';
import '../hive_service.dart';
import '../models/food_item_model.dart';
import '../models/food_log_model.dart';

class FoodRepository {
  FoodRepository();

  final _uuid = const Uuid();

  String normalize(String value) {
    return value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
  }

  Future<void> seedStarterFoodsIfNeeded() async {
    final existingNormalizedNames = HiveService.foodDictionaryBox.values
        .map((rawFood) => FoodItemModel.fromMap(rawFood))
        .map((food) => food.normalizedName)
        .toSet();

    final now = DateTime.now();

    final starterFoods = <FoodItemModel>[
      _starterFood('Cooked Rice', 100, 'g', 130, 'Rice & Grains', now),
      _starterFood('Plain Rice', 100, 'g', 130, 'Rice & Grains', now),
      _starterFood('Fried Rice', 100, 'g', 170, 'Rice & Grains', now),
      _starterFood('Khichuri', 100, 'g', 150, 'Rice & Grains', now),
      _starterFood('Pulao', 100, 'g', 180, 'Rice & Grains', now),
      _starterFood('Chicken Biryani', 100, 'g', 200, 'Rice & Grains', now),
      _starterFood('Beef Biryani', 100, 'g', 220, 'Rice & Grains', now),

      _starterFood('Roti', 1, 'piece', 120, 'Bread', now),
      _starterFood('Chapati', 1, 'piece', 120, 'Bread', now),
      _starterFood('Paratha', 1, 'piece', 260, 'Bread', now),
      _starterFood('Naan', 1, 'piece', 260, 'Bread', now),
      _starterFood('Bread', 1, 'slice', 80, 'Bread', now),
      _starterFood('Toast', 1, 'slice', 75, 'Bread', now),

      _starterFood('Boiled Egg', 1, 'piece', 78, 'Eggs', now),
      _starterFood('Fried Egg', 1, 'piece', 90, 'Eggs', now),
      _starterFood('Omelette', 1, 'piece', 120, 'Eggs', now),

      _starterFood('Chicken Breast', 100, 'g', 165, 'Meat & Fish', now),
      _starterFood('Chicken Curry', 100, 'g', 190, 'Meat & Fish', now),
      _starterFood('Chicken Roast', 100, 'g', 210, 'Meat & Fish', now),
      _starterFood('Beef Curry', 100, 'g', 250, 'Meat & Fish', now),
      _starterFood('Beef', 100, 'g', 250, 'Meat & Fish', now),
      _starterFood('Mutton Curry', 100, 'g', 280, 'Meat & Fish', now),
      _starterFood('Fish Curry', 100, 'g', 130, 'Meat & Fish', now),
      _starterFood('Fried Fish', 100, 'g', 220, 'Meat & Fish', now),
      _starterFood('Hilsa Fish', 100, 'g', 310, 'Meat & Fish', now),
      _starterFood('Rui Fish', 100, 'g', 120, 'Meat & Fish', now),
      _starterFood('Prawn', 100, 'g', 100, 'Meat & Fish', now),

      _starterFood('Dal', 100, 'g', 110, 'Lentils & Beans', now),
      _starterFood('Masoor Dal', 100, 'g', 115, 'Lentils & Beans', now),
      _starterFood('Chickpeas', 100, 'g', 164, 'Lentils & Beans', now),
      _starterFood('Black Chickpeas', 100, 'g', 160, 'Lentils & Beans', now),
      _starterFood('Soybean', 100, 'g', 173, 'Lentils & Beans', now),

      _starterFood('Potato', 100, 'g', 77, 'Vegetables', now),
      _starterFood('Potato Bhorta', 100, 'g', 120, 'Vegetables', now),
      _starterFood('Mixed Vegetables', 100, 'g', 65, 'Vegetables', now),
      _starterFood('Spinach', 100, 'g', 23, 'Vegetables', now),
      _starterFood('Cucumber', 100, 'g', 15, 'Vegetables', now),
      _starterFood('Tomato', 100, 'g', 18, 'Vegetables', now),
      _starterFood('Carrot', 100, 'g', 41, 'Vegetables', now),
      _starterFood('Cauliflower', 100, 'g', 25, 'Vegetables', now),
      _starterFood('Cabbage', 100, 'g', 25, 'Vegetables', now),

      _starterFood('Milk', 100, 'ml', 42, 'Dairy', now),
      _starterFood('Full Cream Milk', 100, 'ml', 61, 'Dairy', now),
      _starterFood('Yogurt', 100, 'g', 61, 'Dairy', now),
      _starterFood('Sweet Yogurt', 100, 'g', 120, 'Dairy', now),
      _starterFood('Cheese', 100, 'g', 402, 'Dairy', now),
      _starterFood('Butter', 10, 'g', 72, 'Dairy', now),

      _starterFood('Banana', 1, 'piece', 105, 'Fruits', now),
      _starterFood('Apple', 1, 'piece', 95, 'Fruits', now),
      _starterFood('Orange', 1, 'piece', 62, 'Fruits', now),
      _starterFood('Mango', 100, 'g', 60, 'Fruits', now),
      _starterFood('Papaya', 100, 'g', 43, 'Fruits', now),
      _starterFood('Watermelon', 100, 'g', 30, 'Fruits', now),
      _starterFood('Guava', 100, 'g', 68, 'Fruits', now),
      _starterFood('Grapes', 100, 'g', 69, 'Fruits', now),

      _starterFood('Tea With Sugar', 1, 'cup', 70, 'Drinks', now),
      _starterFood('Milk Tea', 1, 'cup', 100, 'Drinks', now),
      _starterFood('Black Tea', 1, 'cup', 2, 'Drinks', now),
      _starterFood('Coffee With Sugar', 1, 'cup', 80, 'Drinks', now),
      _starterFood('Black Coffee', 1, 'cup', 2, 'Drinks', now),
      _starterFood('Soft Drink', 100, 'ml', 42, 'Drinks', now),
      _starterFood('Fruit Juice', 100, 'ml', 45, 'Drinks', now),

      _starterFood('Singara', 1, 'piece', 150, 'Snacks', now),
      _starterFood('Samosa', 1, 'piece', 130, 'Snacks', now),
      _starterFood('Puri', 1, 'piece', 170, 'Snacks', now),
      _starterFood('Piyaju', 1, 'piece', 80, 'Snacks', now),
      _starterFood('Beguni', 1, 'piece', 90, 'Snacks', now),
      _starterFood('French Fries', 100, 'g', 312, 'Snacks', now),
      _starterFood('Chicken Nugget', 1, 'piece', 50, 'Snacks', now),
      _starterFood('Burger', 1, 'piece', 350, 'Fast Food', now),
      _starterFood('Pizza', 1, 'slice', 285, 'Fast Food', now),
      _starterFood('Noodles', 100, 'g', 138, 'Fast Food', now),
      _starterFood('Instant Noodles', 1, 'pack', 380, 'Fast Food', now),

      _starterFood('Sugar', 1, 'tsp', 16, 'Misc', now),
      _starterFood('Honey', 1, 'tsp', 21, 'Misc', now),
      _starterFood('Cooking Oil', 1, 'tbsp', 120, 'Misc', now),
      _starterFood('Mayonnaise', 1, 'tbsp', 94, 'Misc', now),
      _starterFood('Ketchup', 1, 'tbsp', 20, 'Misc', now),
    ];

    for (final food in starterFoods) {
      if (existingNormalizedNames.contains(food.normalizedName)) {
        continue;
      }

      await HiveService.foodDictionaryBox.put(food.id, food.toMap());
    }
  }

  FoodItemModel _starterFood(
    String name,
    double baseQuantity,
    String unit,
    double calories,
    String category,
    DateTime now,
  ) {
    return FoodItemModel(
      id: _uuid.v4(),
      name: name,
      normalizedName: normalize(name),
      baseQuantity: baseQuantity,
      unit: unit,
      calories: calories,
      category: category,
      isUserCreated: false,
      createdAt: now,
      updatedAt: now,
    );
  }

  List<FoodItemModel> getFoodItems() {
    final foods = HiveService.foodDictionaryBox.values
        .map((rawFood) => FoodItemModel.fromMap(rawFood))
        .where((food) => !food.isDeleted)
        .toList();

    foods.sort((a, b) => a.name.compareTo(b.name));

    return foods;
  }

  List<FoodItemModel> searchFoodItems(String query) {
    final normalizedQuery = normalize(query);

    if (normalizedQuery.isEmpty) {
      return getFoodItems();
    }

    return getFoodItems().where((food) {
      return food.normalizedName.contains(normalizedQuery);
    }).toList();
  }

  FoodItemModel? getFoodItemById(String id) {
    final rawFood = HiveService.foodDictionaryBox.get(id);

    if (rawFood == null) {
      return null;
    }

    return FoodItemModel.fromMap(rawFood);
  }

  FoodItemModel? findFoodByName(String name) {
    final normalizedName = normalize(name);

    for (final food in getFoodItems()) {
      if (food.normalizedName == normalizedName) {
        return food;
      }
    }

    return null;
  }

  Future<FoodItemModel> addFoodItem({
    required String name,
    required double baseQuantity,
    required String unit,
    required double calories,
  }) async {
    final existingFood = findFoodByName(name);

    if (existingFood != null) {
      return existingFood;
    }

    final now = DateTime.now();

    final food = FoodItemModel(
      id: _uuid.v4(),
      name: name.trim(),
      normalizedName: normalize(name),
      baseQuantity: baseQuantity,
      unit: unit.trim().toLowerCase(),
      calories: calories,
      category: 'Custom',
      isUserCreated: true,
      createdAt: now,
      updatedAt: now,
    );

    await HiveService.foodDictionaryBox.put(food.id, food.toMap());

    return food;
  }

  Future<FoodLogModel> addFoodLog({
    required DateTime date,
    required FoodItemModel foodItem,
    required double quantity,
    String note = '',
  }) async {
    final now = DateTime.now();

    final calculatedCalories = foodItem.caloriesForQuantity(quantity);

    final log = FoodLogModel(
      id: _uuid.v4(),
      logDate: AppDateUtils.dateKey(date),
      foodItemId: foodItem.id,
      foodName: foodItem.name,
      quantity: quantity,
      unit: foodItem.unit,
      calculatedCalories: calculatedCalories,
      consumedAt: now,
      createdAt: now,
      updatedAt: now,
      note: note.trim(),
    );

    await HiveService.foodLogsBox.put(log.id, log.toMap());

    return log;
  }

  Future<FoodLogModel> addCustomFoodAndLog({
    required DateTime date,
    required String name,
    required double baseQuantity,
    required String unit,
    required double calories,
    required double logQuantity,
    String note = '',
  }) async {
    final foodItem = await addFoodItem(
      name: name,
      baseQuantity: baseQuantity,
      unit: unit,
      calories: calories,
    );

    return addFoodLog(
      date: date,
      foodItem: foodItem,
      quantity: logQuantity,
      note: note,
    );
  }

  List<FoodLogModel> getFoodLogsByDate(DateTime date) {
    final key = AppDateUtils.dateKey(date);

    final logs = HiveService.foodLogsBox.values
        .map((rawLog) => FoodLogModel.fromMap(rawLog))
        .where((log) => log.logDate == key && !log.isDeleted)
        .toList();

    logs.sort((a, b) => b.consumedAt.compareTo(a.consumedAt));

    return logs;
  }

  Future<void> deleteFoodLog(String id) async {
    final rawLog = HiveService.foodLogsBox.get(id);

    if (rawLog == null) {
      return;
    }

    final log = FoodLogModel.fromMap(rawLog);

    final deletedLog = log.copyWith(
      isDeleted: true,
      updatedAt: DateTime.now(),
    );

    await HiveService.foodLogsBox.put(id, deletedLog.toMap());
  }

  double getDailyTotalCalories(DateTime date) {
    final logs = getFoodLogsByDate(date);

    return logs.fold<double>(
      0,
      (total, log) => total + log.calculatedCalories,
    );
  }

  List<DailyCalorieTotal> getDailyCalorieTotalsForLastDays({
    required DateTime endDate,
    int days = 30,
  }) {
    final normalizedEndDate = DateTime(
      endDate.year,
      endDate.month,
      endDate.day,
    );

    return List.generate(days, (index) {
      final date = normalizedEndDate.subtract(
        Duration(days: days - 1 - index),
      );

      return DailyCalorieTotal(
        date: date,
        dateKey: AppDateUtils.dateKey(date),
        calories: getDailyTotalCalories(date),
      );
    });
  }
}

class DailyCalorieTotal {
  const DailyCalorieTotal({
    required this.date,
    required this.dateKey,
    required this.calories,
  });

  final DateTime date;
  final String dateKey;
  final double calories;
}