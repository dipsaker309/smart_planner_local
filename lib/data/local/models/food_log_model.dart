import 'food_item_model.dart';

class FoodLogModel {
  const FoodLogModel({
    required this.id,
    required this.date,
    required this.items,
    required this.createdAt,
    this.note = '',
  });

  final String id;
  final DateTime date;
  final List<FoodItemModel> items;
  final String note;
  final DateTime createdAt;

  int get totalCalories {
    return items.fold(0, (total, item) => total + item.totalCalories);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'items': items.map((item) => item.toMap()).toList(),
      'note': note,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory FoodLogModel.fromMap(Map<String, dynamic> map) {
    final rawItems = map['items'] as List<dynamic>? ?? [];

    return FoodLogModel(
      id: map['id'] as String,
      date: DateTime.tryParse(map['date'] as String? ?? '') ?? DateTime.now(),
      items: rawItems
          .map((item) => FoodItemModel.fromMap(
                Map<String, dynamic>.from(item as Map),
              ))
          .toList(),
      note: map['note'] as String? ?? '',
      createdAt:
          DateTime.tryParse(map['createdAt'] as String? ?? '') ?? DateTime.now(),
    );
  }
}
