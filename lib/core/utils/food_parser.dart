class ParsedFoodEntry {
  const ParsedFoodEntry({
    required this.name,
    required this.calories,
  });

  final String name;
  final int calories;
}

class FoodParser {
  const FoodParser._();

  static ParsedFoodEntry parse(String input) {
    final trimmedInput = input.trim();
    final calorieMatch = RegExp(
      r'(\d+)\s*(cal|cals|calorie|calories|kcal)?',
      caseSensitive: false,
    ).firstMatch(trimmedInput);

    final calories = int.tryParse(calorieMatch?.group(1) ?? '') ?? 0;
    final name = trimmedInput
        .replaceFirst(RegExp(r'\d+\s*(cal|cals|calorie|calories|kcal)?',
            caseSensitive: false), '')
        .trim();

    return ParsedFoodEntry(
      name: name.isEmpty ? trimmedInput : name,
      calories: calories,
    );
  }
}
