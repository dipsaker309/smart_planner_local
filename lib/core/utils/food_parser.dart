class ParsedFoodInput {
  const ParsedFoodInput({
    required this.quantity,
    required this.unit,
    required this.foodName,
  });

  final double quantity;
  final String unit;
  final String foodName;
}

class FoodParser {
  const FoodParser._();

  static ParsedFoodInput? parse(String input) {
    final cleaned = input.trim().toLowerCase();

    if (cleaned.isEmpty) {
      return null;
    }

    final regex = RegExp(r'^(\d+(?:\.\d+)?)\s*([a-zA-Z]+)?\s+(.+)$');
    final match = regex.firstMatch(cleaned);

    if (match == null) {
      return ParsedFoodInput(
        quantity: 1,
        unit: 'piece',
        foodName: cleaned,
      );
    }

    final quantity = double.tryParse(match.group(1) ?? '1') ?? 1;
    final unit = match.group(2) ?? 'piece';
    final foodName = match.group(3)?.trim() ?? cleaned;

    return ParsedFoodInput(
      quantity: quantity,
      unit: unit,
      foodName: foodName,
    );
  }
}