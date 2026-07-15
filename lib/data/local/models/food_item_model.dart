class FoodItemModel {
  const FoodItemModel({
    required this.id,
    required this.name,
    required this.normalizedName,
    required this.baseQuantity,
    required this.unit,
    required this.calories,
    required this.category,
    required this.isTreatFood,
    required this.isUserCreated,
    required this.createdAt,
    required this.updatedAt,
    this.isDeleted = false,
  });

  final String id;
  final String name;
  final String normalizedName;
  final double baseQuantity;
  final String unit;
  final double calories;
  final String category;
  final bool isTreatFood;
  final bool isUserCreated;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;

  double caloriesForQuantity(double quantity) {
    if (baseQuantity <= 0) {
      return 0;
    }

    return (quantity / baseQuantity) * calories;
  }

  FoodItemModel copyWith({
    String? id,
    String? name,
    String? normalizedName,
    double? baseQuantity,
    String? unit,
    double? calories,
    String? category,
    bool? isTreatFood,
    bool? isUserCreated,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDeleted,
  }) {
    return FoodItemModel(
      id: id ?? this.id,
      name: name ?? this.name,
      normalizedName: normalizedName ?? this.normalizedName,
      baseQuantity: baseQuantity ?? this.baseQuantity,
      unit: unit ?? this.unit,
      calories: calories ?? this.calories,
      category: category ?? this.category,
      isTreatFood: isTreatFood ?? this.isTreatFood,
      isUserCreated: isUserCreated ?? this.isUserCreated,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'normalizedName': normalizedName,
      'baseQuantity': baseQuantity,
      'unit': unit,
      'calories': calories,
      'category': category,
      'isTreatFood': isTreatFood,
      'isUserCreated': isUserCreated,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isDeleted': isDeleted,
    };
  }

  factory FoodItemModel.fromMap(Map<dynamic, dynamic> map) {
    return FoodItemModel(
      id: map['id'] as String,
      name: map['name'] as String,
      normalizedName: map['normalizedName'] as String,
      baseQuantity: (map['baseQuantity'] as num?)?.toDouble() ?? 1,
      unit: map['unit'] as String? ?? 'g',
      calories: (map['calories'] as num?)?.toDouble() ?? 0,
      category: map['category'] as String? ?? 'General',
      isTreatFood: map['isTreatFood'] as bool? ?? false,
      isUserCreated: map['isUserCreated'] as bool? ?? false,
      createdAt: DateTime.tryParse(map['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      updatedAt: DateTime.tryParse(map['updatedAt']?.toString() ?? '') ??
          DateTime.now(),
      isDeleted: map['isDeleted'] as bool? ?? false,
    );
  }
}