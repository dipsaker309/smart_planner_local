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
    final starterFoods = _starterFoods();

    for (final starterFood in starterFoods) {
      await _upsertStarterFood(starterFood);
    }
  }

  Future<void> _upsertStarterFood(FoodItemModel starterFood) async {
    final existingFood = findFoodByName(starterFood.name);

    if (existingFood == null) {
      await HiveService.foodDictionaryBox.put(
        starterFood.id,
        starterFood.toMap(),
      );
      return;
    }

    if (existingFood.isUserCreated) {
      return;
    }

    final updatedFood = existingFood.copyWith(
      name: starterFood.name,
      normalizedName: starterFood.normalizedName,
      baseQuantity: starterFood.baseQuantity,
      unit: starterFood.unit,
      calories: starterFood.calories,
      category: starterFood.category,
      isTreatFood: starterFood.isTreatFood,
      updatedAt: DateTime.now(),
    );

    await HiveService.foodDictionaryBox.put(
      updatedFood.id,
      updatedFood.toMap(),
    );
  }

  List<FoodItemModel> _starterFoods() {
    return [
      // Rice, staples, and common meals
      _starterFood('Plain rice', 100, 'g', 130, 'Rice & Staples'),
      _starterFood('Cooked rice 1 plate', 1, 'plate', 390, 'Rice & Staples'),
      _starterFood('Khichuri', 1, 'plate', 420, 'Rice & Staples'),
      _starterFood('Chicken biryani', 1, 'plate', 650, 'Rice & Staples'),
      _starterFood('Beef biryani', 1, 'plate', 720, 'Rice & Staples'),
      _starterFood('Polao', 1, 'plate', 480, 'Rice & Staples'),
      _starterFood('Panta bhat', 1, 'plate', 300, 'Rice & Staples'),
      _starterFood('Roti', 1, 'piece', 120, 'Rice & Staples'),
      _starterFood('Paratha', 1, 'piece', 260, 'Rice & Staples', isTreatFood: true),
      _starterFood('Luchi', 1, 'piece', 150, 'Rice & Staples', isTreatFood: true),
      _starterFood('Puri', 1, 'piece', 180, 'Rice & Staples', isTreatFood: true),
      _starterFood('Noodles', 1, 'plate', 420, 'Rice & Staples'),
      _starterFood('Muri', 1, 'cup', 55, 'Rice & Staples'),
      _starterFood('Flattened rice chira', 100, 'g', 350, 'Rice & Staples'),

      // Dal, egg, fish, meat
      _starterFood('Dal', 1, 'bowl', 180, 'Protein'),
      _starterFood('Egg boiled', 1, 'piece', 78, 'Protein'),
      _starterFood('Egg omelette', 1, 'piece', 140, 'Protein'),
      _starterFood('Chicken curry', 1, 'serving', 320, 'Protein'),
      _starterFood('Chicken roast', 1, 'piece', 420, 'Protein'),
      _starterFood('Beef curry', 1, 'serving', 380, 'Protein'),
      _starterFood('Mutton curry', 1, 'serving', 430, 'Protein'),
      _starterFood('Rui fish curry', 1, 'piece', 220, 'Protein'),
      _starterFood('Hilsa fish curry', 1, 'piece', 300, 'Protein'),
      _starterFood('Pangas fish curry', 1, 'piece', 240, 'Protein'),
      _starterFood('Tilapia fish curry', 1, 'piece', 210, 'Protein'),
      _starterFood('Small fish curry', 1, 'serving', 190, 'Protein'),
      _starterFood('Dried fish bhorta', 1, 'serving', 180, 'Protein'),

      // Vegetables and bhaji
      _starterFood('Mixed vegetable', 1, 'serving', 160, 'Vegetables'),
      _starterFood('Potato bhaji', 1, 'serving', 180, 'Vegetables'),
      _starterFood('Eggplant bhaji', 1, 'serving', 170, 'Vegetables'),
      _starterFood('Spinach shak', 1, 'serving', 90, 'Vegetables'),
      _starterFood('Bottle gourd lau', 1, 'serving', 80, 'Vegetables'),
      _starterFood('Pumpkin', 1, 'serving', 95, 'Vegetables'),
      _starterFood('Okra bhindi', 1, 'serving', 110, 'Vegetables'),
      _starterFood('Cabbage', 1, 'serving', 80, 'Vegetables'),
      _starterFood('Cauliflower', 1, 'serving', 90, 'Vegetables'),
      _starterFood('Carrot', 100, 'g', 41, 'Vegetables'),
      _starterFood('Cucumber', 100, 'g', 16, 'Vegetables'),
      _starterFood('Tomato', 100, 'g', 18, 'Vegetables'),
      _starterFood('Green salad', 1, 'serving', 60, 'Vegetables'),

      // Fruits common in Bangladesh
      _starterFood('Banana', 1, 'piece', 105, 'Fruits'),
      _starterFood('Mango', 1, 'piece', 200, 'Fruits'),
      _starterFood('Jackfruit', 100, 'g', 95, 'Fruits'),
      _starterFood('Papaya', 100, 'g', 43, 'Fruits'),
      _starterFood('Guava', 1, 'piece', 68, 'Fruits'),
      _starterFood('Apple', 1, 'piece', 95, 'Fruits'),
      _starterFood('Orange', 1, 'piece', 62, 'Fruits'),
      _starterFood('Watermelon', 100, 'g', 30, 'Fruits'),
      _starterFood('Pineapple', 100, 'g', 50, 'Fruits'),
      _starterFood('Litchi', 10, 'piece', 66, 'Fruits'),
      _starterFood('Coconut water', 1, 'glass', 45, 'Drinks'),
      _starterFood('Coconut flesh', 100, 'g', 354, 'Fruits'),

      // Breakfast and dairy
      _starterFood('Bread slice', 1, 'piece', 75, 'Breakfast'),
      _starterFood('Butter', 1, 'tsp', 34, 'Breakfast'),
      _starterFood('Jam', 1, 'tsp', 28, 'Breakfast', isTreatFood: true),
      _starterFood('Milk', 1, 'glass', 150, 'Drinks'),
      _starterFood('Curd yogurt', 1, 'cup', 150, 'Breakfast'),
      _starterFood('Oats', 1, 'bowl', 250, 'Breakfast'),
      _starterFood('Cornflakes with milk', 1, 'bowl', 260, 'Breakfast'),

      // Drinks
      _starterFood('Water', 1, 'glass', 0, 'Drinks'),
      _starterFood('Tea without sugar', 1, 'cup', 5, 'Drinks'),
      _starterFood('Tea with sugar', 1, 'cup', 70, 'Drinks', isTreatFood: true),
      _starterFood('Milk tea', 1, 'cup', 120, 'Drinks', isTreatFood: true),
      _starterFood('Black coffee', 1, 'cup', 5, 'Drinks'),
      _starterFood('Coffee with milk and sugar', 1, 'cup', 120, 'Drinks', isTreatFood: true),
      _starterFood('Soft drink', 1, 'glass', 110, 'Drinks', isTreatFood: true),
      _starterFood('Fruit juice', 1, 'glass', 130, 'Drinks', isTreatFood: true),
      _starterFood('Lassi', 1, 'glass', 220, 'Drinks', isTreatFood: true),

      // Snacks, street food, and treats
      _starterFood('Singara', 1, 'piece', 180, 'Snacks', isTreatFood: true),
      _starterFood('Samosa', 1, 'piece', 190, 'Snacks', isTreatFood: true),
      _starterFood('Piyaju', 1, 'piece', 90, 'Snacks', isTreatFood: true),
      _starterFood('Beguni', 1, 'piece', 120, 'Snacks', isTreatFood: true),
      _starterFood('Fuchka', 1, 'plate', 350, 'Snacks', isTreatFood: true),
      _starterFood('Chotpoti', 1, 'plate', 420, 'Snacks', isTreatFood: true),
      _starterFood('Jhalmuri', 1, 'serving', 250, 'Snacks', isTreatFood: true),
      _starterFood('Chanachur', 50, 'g', 280, 'Snacks', isTreatFood: true),
      _starterFood('Chips', 1, 'packet', 250, 'Snacks', isTreatFood: true),
      _starterFood('Biscuit', 2, 'piece', 110, 'Snacks', isTreatFood: true),
      _starterFood('Cake slice', 1, 'piece', 280, 'Snacks', isTreatFood: true),
      _starterFood('Chocolate', 1, 'piece', 220, 'Snacks', isTreatFood: true),
      _starterFood('Ice cream', 1, 'cup', 210, 'Snacks', isTreatFood: true),
      _starterFood('Sweet doi', 1, 'cup', 220, 'Sweets', isTreatFood: true),
      _starterFood('Rasgulla', 1, 'piece', 150, 'Sweets', isTreatFood: true),
      _starterFood('Gulab jamun', 1, 'piece', 180, 'Sweets', isTreatFood: true),
      _starterFood('Jilapi', 1, 'piece', 170, 'Sweets', isTreatFood: true),
      _starterFood('Mishti', 1, 'piece', 160, 'Sweets', isTreatFood: true),

      // Common fast food
      _starterFood('Burger', 1, 'piece', 450, 'Fast Food', isTreatFood: true),
      _starterFood('Pizza slice', 1, 'piece', 285, 'Fast Food', isTreatFood: true),
      _starterFood('Fried chicken', 1, 'piece', 320, 'Fast Food', isTreatFood: true),
      _starterFood('French fries', 1, 'serving', 365, 'Fast Food', isTreatFood: true),
      _starterFood('Shawarma', 1, 'piece', 420, 'Fast Food', isTreatFood: true),
    ];
  }

  FoodItemModel _starterFood(
    String name,
    double baseQuantity,
    String unit,
    double calories,
    String category, {
    bool isTreatFood = false,
  }) {
    final now = DateTime.now();

    return FoodItemModel(
      id: _uuid.v4(),
      name: name,
      normalizedName: normalize(name),
      baseQuantity: baseQuantity,
      unit: unit,
      calories: calories,
      category: category,
      isTreatFood: isTreatFood,
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

    foods.sort((a, b) {
      final categoryCompare = a.category.compareTo(b.category);

      if (categoryCompare != 0) {
        return categoryCompare;
      }

      return a.name.compareTo(b.name);
    });

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

    final food = FoodItemModel.fromMap(rawFood);

    if (food.isDeleted) {
      return null;
    }

    return food;
  }

  FoodItemModel? findFoodByName(String name) {
    final normalizedName = normalize(name);

    for (final rawFood in HiveService.foodDictionaryBox.values) {
      final food = FoodItemModel.fromMap(rawFood);

      if (food.normalizedName == normalizedName && !food.isDeleted) {
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
    String category = 'User Added',
    bool isTreatFood = false,
  }) async {
    final now = DateTime.now();

    final food = FoodItemModel(
      id: _uuid.v4(),
      name: name.trim(),
      normalizedName: normalize(name),
      baseQuantity: baseQuantity,
      unit: unit,
      calories: calories,
      category: category,
      isTreatFood: isTreatFood,
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

    final log = FoodLogModel(
      id: _uuid.v4(),
      logDate: AppDateUtils.dateKey(date),
      foodItemId: foodItem.id,
      foodName: foodItem.name,
      quantity: quantity,
      unit: foodItem.unit,
      calculatedCalories: foodItem.caloriesForQuantity(quantity),
      isTreatFood: foodItem.isTreatFood,
      consumedAt: now,
      createdAt: now,
      updatedAt: now,
      note: note.trim(),
    );

    await HiveService.foodLogsBox.put(log.id, log.toMap());

    return log;
  }

  Future<void> addCustomFoodAndLog({
    required DateTime date,
    required String name,
    required double baseQuantity,
    required String unit,
    required double calories,
    required double logQuantity,
    String note = '',
  }) async {
    final food = await addFoodItem(
      name: name,
      baseQuantity: baseQuantity,
      unit: unit,
      calories: calories,
    );

    await addFoodLog(
      date: date,
      foodItem: food,
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

  Future<void> updateFoodLog({
    required String id,
    required double quantity,
    required String note,
  }) async {
    final rawLog = HiveService.foodLogsBox.get(id);

    if (rawLog == null) {
      return;
    }

    final log = FoodLogModel.fromMap(rawLog);
    final foodItem = getFoodItemById(log.foodItemId);

    final calculatedCalories = foodItem == null
        ? _calculateCaloriesFromExistingLog(log, quantity)
        : foodItem.caloriesForQuantity(quantity);

    final updatedLog = log.copyWith(
      foodName: foodItem?.name ?? log.foodName,
      quantity: quantity,
      unit: foodItem?.unit ?? log.unit,
      calculatedCalories: calculatedCalories,
      isTreatFood: foodItem?.isTreatFood ?? log.isTreatFood,
      note: note.trim(),
      updatedAt: DateTime.now(),
    );

    await HiveService.foodLogsBox.put(id, updatedLog.toMap());
  }

  double _calculateCaloriesFromExistingLog(
    FoodLogModel log,
    double newQuantity,
  ) {
    if (log.quantity <= 0) {
      return log.calculatedCalories;
    }

    final caloriesPerUnit = log.calculatedCalories / log.quantity;
    return caloriesPerUnit * newQuantity;
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

  double getDailyRegularCalories(DateTime date) {
    final logs = getFoodLogsByDate(date);

    return logs
        .where((log) => !log.isTreatFood)
        .fold<double>(0, (total, log) => total + log.calculatedCalories);
  }

  double getDailyTreatCalories(DateTime date) {
    final logs = getFoodLogsByDate(date);

    return logs
        .where((log) => log.isTreatFood)
        .fold<double>(0, (total, log) => total + log.calculatedCalories);
  }

  DailyFoodBreakdown getDailyFoodBreakdown(DateTime date) {
    final regularCalories = getDailyRegularCalories(date);
    final treatCalories = getDailyTreatCalories(date);

    return DailyFoodBreakdown(
      date: date,
      regularCalories: regularCalories,
      treatCalories: treatCalories,
      totalCalories: regularCalories + treatCalories,
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

class DailyFoodBreakdown {
  const DailyFoodBreakdown({
    required this.date,
    required this.regularCalories,
    required this.treatCalories,
    required this.totalCalories,
  });

  final DateTime date;
  final double regularCalories;
  final double treatCalories;
  final double totalCalories;
}