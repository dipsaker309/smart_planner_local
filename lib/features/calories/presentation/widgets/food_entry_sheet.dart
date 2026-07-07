import 'package:flutter/material.dart';

import '../../../../data/local/models/food_item_model.dart';

class FoodEntrySheet extends StatefulWidget {
  const FoodEntrySheet({
    super.key,
    required this.foodItems,
    required this.onLogExistingFood,
    required this.onAddMissingFoodAndLog,
  });

  final List<FoodItemModel> foodItems;

  final Future<void> Function({
    required String foodItemId,
    required double quantity,
    required String note,
  }) onLogExistingFood;

  final Future<void> Function({
    required String name,
    required double baseQuantity,
    required String unit,
    required double calories,
    required double logQuantity,
    required String note,
  }) onAddMissingFoodAndLog;

  @override
  State<FoodEntrySheet> createState() => _FoodEntrySheetState();
}

class _FoodEntrySheetState extends State<FoodEntrySheet> {
  final _searchController = TextEditingController();
  final _quantityController = TextEditingController();
  final _noteController = TextEditingController();

  final _baseQuantityController = TextEditingController();
  final _caloriesController = TextEditingController();

  String _newFoodUnit = 'g';
  FoodItemModel? _selectedFood;
  bool _isSaving = false;

  final List<String> _units = const [
    'g',
    'ml',
    'piece',
    'slice',
    'cup',
    'plate',
    'serving',
    'tbsp',
    'tsp',
    'pack',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    _quantityController.dispose();
    _noteController.dispose();
    _baseQuantityController.dispose();
    _caloriesController.dispose();
    super.dispose();
  }

  List<FoodItemModel> get _filteredFoods {
    final query = _searchController.text.trim().toLowerCase();

    if (query.isEmpty) {
      return widget.foodItems.take(12).toList();
    }

    return widget.foodItems
        .where((food) => food.normalizedName.contains(query))
        .take(12)
        .toList();
  }

  bool get _hasSearchText => _searchController.text.trim().isNotEmpty;

  bool get _exactMatchExists {
    final query = _searchController.text.trim().toLowerCase();

    if (query.isEmpty) {
      return false;
    }

    return widget.foodItems.any((food) => food.normalizedName == query);
  }

  String _formatCalories(FoodItemModel food) {
    final base = food.baseQuantity % 1 == 0
        ? food.baseQuantity.toStringAsFixed(0)
        : food.baseQuantity.toStringAsFixed(1);

    return '${food.calories.round()} kcal / $base ${food.unit}';
  }

  Future<void> _logExistingFood() async {
    final selectedFood = _selectedFood;

    if (selectedFood == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a food first.')),
      );
      return;
    }

    final quantity = double.tryParse(_quantityController.text.trim());

    if (quantity == null || quantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid quantity.')),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    await widget.onLogExistingFood(
      foodItemId: selectedFood.id,
      quantity: quantity,
      note: _noteController.text.trim(),
    );

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _addMissingFoodAndLog() async {
    final name = _searchController.text.trim();
    final baseQuantity =
        double.tryParse(_baseQuantityController.text.trim());
    final calories = double.tryParse(_caloriesController.text.trim());
    final logQuantity = double.tryParse(_quantityController.text.trim());

    if (name.isEmpty ||
        baseQuantity == null ||
        calories == null ||
        logQuantity == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields.')),
      );
      return;
    }

    if (baseQuantity <= 0 || calories < 0 || logQuantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter valid numbers.')),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    await widget.onAddMissingFoodAndLog(
      name: name,
      baseQuantity: baseQuantity,
      unit: _newFoodUnit,
      calories: calories,
      logQuantity: logQuantity,
      note: _noteController.text.trim(),
    );

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredFoods = _filteredFoods;
    final showAddMissingFoodForm =
        _hasSearchText && !_exactMatchExists && _selectedFood == null;
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomPadding),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Log Food',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _searchController,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Search food',
                hintText: 'Example: rice, egg, banana',
                prefixIcon: Icon(Icons.search_rounded),
                border: OutlineInputBorder(),
              ),
              onChanged: (_) {
                setState(() {
                  _selectedFood = null;
                });
              },
            ),
            const SizedBox(height: 12),
            if (_selectedFood != null)
              _SelectedFoodCard(
                food: _selectedFood!,
                onClear: () {
                  setState(() {
                    _selectedFood = null;
                  });
                },
              )
            else
              _FoodSearchResults(
                foods: filteredFoods,
                formatCalories: _formatCalories,
                onSelected: (food) {
                  setState(() {
                    _selectedFood = food;
                    _searchController.text = food.name;
                  });
                },
              ),
            const SizedBox(height: 12),
            TextField(
              controller: _quantityController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: _selectedFood == null
                    ? 'Quantity consumed'
                    : 'Quantity consumed (${_selectedFood!.unit})',
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _noteController,
              decoration: const InputDecoration(
                labelText: 'Note optional',
                border: OutlineInputBorder(),
              ),
            ),
            if (showAddMissingFoodForm) ...[
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Food not found. Add it to dictionary:',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _baseQuantityController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Base quantity',
                        hintText: '100',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _newFoodUnit,
                      decoration: const InputDecoration(
                        labelText: 'Unit',
                        border: OutlineInputBorder(),
                      ),
                      items: _units.map((unit) {
                        return DropdownMenuItem<String>(
                          value: unit,
                          child: Text(unit),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _newFoodUnit = value;
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _caloriesController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Calories for base quantity',
                  hintText: 'Example: 130',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: _isSaving
                  ? null
                  : _selectedFood == null
                      ? _addMissingFoodAndLog
                      : _logExistingFood,
              icon: const Icon(Icons.add_rounded),
              label: Text(
                _isSaving
                    ? 'Saving...'
                    : _selectedFood == null
                        ? 'Save Food & Log'
                        : 'Add Log',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FoodSearchResults extends StatelessWidget {
  const _FoodSearchResults({
    required this.foods,
    required this.formatCalories,
    required this.onSelected,
  });

  final List<FoodItemModel> foods;
  final String Function(FoodItemModel food) formatCalories;
  final ValueChanged<FoodItemModel> onSelected;

  @override
  Widget build(BuildContext context) {
    if (foods.isEmpty) {
      return const Align(
        alignment: Alignment.centerLeft,
        child: Text('No matching food found.'),
      );
    }

    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 220),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: foods.length,
        itemBuilder: (context, index) {
          final food = foods[index];

          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              title: Text(food.name),
              subtitle: Text('${food.category} • ${formatCalories(food)}'),
              trailing: const Icon(Icons.add_circle_outline_rounded),
              onTap: () => onSelected(food),
            ),
          );
        },
      ),
    );
  }
}

class _SelectedFoodCard extends StatelessWidget {
  const _SelectedFoodCard({
    required this.food,
    required this.onClear,
  });

  final FoodItemModel food;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final base = food.baseQuantity % 1 == 0
        ? food.baseQuantity.toStringAsFixed(0)
        : food.baseQuantity.toStringAsFixed(1);

    return Card(
      child: ListTile(
        leading: const Icon(Icons.restaurant_menu_rounded),
        title: Text(food.name),
        subtitle: Text('${food.calories.round()} kcal / $base ${food.unit}'),
        trailing: IconButton(
          onPressed: onClear,
          icon: const Icon(Icons.close_rounded),
        ),
      ),
    );
  }
}