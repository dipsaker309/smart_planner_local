class FoodLogModel {
  const FoodLogModel({
    required this.id,
    required this.logDate,
    required this.foodItemId,
    required this.foodName,
    required this.quantity,
    required this.unit,
    required this.calculatedCalories,
    required this.isTreatFood,
    required this.consumedAt,
    required this.createdAt,
    required this.updatedAt,
    this.note = '',
    this.isDeleted = false,
  });

  final String id;
  final String logDate;
  final String foodItemId;
  final String foodName;
  final double quantity;
  final String unit;
  final double calculatedCalories;
  final bool isTreatFood;
  final DateTime consumedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String note;
  final bool isDeleted;

  FoodLogModel copyWith({
    String? id,
    String? logDate,
    String? foodItemId,
    String? foodName,
    double? quantity,
    String? unit,
    double? calculatedCalories,
    bool? isTreatFood,
    DateTime? consumedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? note,
    bool? isDeleted,
  }) {
    return FoodLogModel(
      id: id ?? this.id,
      logDate: logDate ?? this.logDate,
      foodItemId: foodItemId ?? this.foodItemId,
      foodName: foodName ?? this.foodName,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      calculatedCalories: calculatedCalories ?? this.calculatedCalories,
      isTreatFood: isTreatFood ?? this.isTreatFood,
      consumedAt: consumedAt ?? this.consumedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      note: note ?? this.note,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'logDate': logDate,
      'foodItemId': foodItemId,
      'foodName': foodName,
      'quantity': quantity,
      'unit': unit,
      'calculatedCalories': calculatedCalories,
      'isTreatFood': isTreatFood,
      'consumedAt': consumedAt.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'note': note,
      'isDeleted': isDeleted,
    };
  }

  factory FoodLogModel.fromMap(Map<dynamic, dynamic> map) {
    return FoodLogModel(
      id: map['id'] as String,
      logDate: map['logDate'] as String,
      foodItemId: map['foodItemId'] as String,
      foodName: map['foodName'] as String,
      quantity: (map['quantity'] as num?)?.toDouble() ?? 0,
      unit: map['unit'] as String? ?? 'g',
      calculatedCalories:
          (map['calculatedCalories'] as num?)?.toDouble() ?? 0,
      isTreatFood: map['isTreatFood'] as bool? ?? false,
      consumedAt: DateTime.tryParse(map['consumedAt']?.toString() ?? '') ??
          DateTime.now(),
      createdAt: DateTime.tryParse(map['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      updatedAt: DateTime.tryParse(map['updatedAt']?.toString() ?? '') ??
          DateTime.now(),
      note: map['note'] as String? ?? '',
      isDeleted: map['isDeleted'] as bool? ?? false,
    );
  }
}