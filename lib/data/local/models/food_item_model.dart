class FoodItemModel {
  const FoodItemModel({
    required this.id,
    required this.name,
    required this.calories,
    this.quantity = 1,
  });

  final String id;
  final String name;
  final int calories;
  final double quantity;

  int get totalCalories => (calories * quantity).round();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'calories': calories,
      'quantity': quantity,
    };
  }

  factory FoodItemModel.fromMap(Map<String, dynamic> map) {
    return FoodItemModel(
      id: map['id'] as String,
      name: map['name'] as String,
      calories: map['calories'] as int? ?? 0,
      quantity: (map['quantity'] as num?)?.toDouble() ?? 1,
    );
  }
}
