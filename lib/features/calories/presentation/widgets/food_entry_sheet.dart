import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../data/local/models/food_item_model.dart';
import '../../../../shared/widgets/app_card.dart';

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

  final _newFoodNameController = TextEditingController();
  final _newBaseQuantityController = TextEditingController(text: '100');
  final _newCaloriesController = TextEditingController();
  final _newLogQuantityController = TextEditingController(text: '100');

  FoodItemModel? _selectedFood;
  String _newFoodUnit = 'g';
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    _searchController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _quantityController.dispose();
    _noteController.dispose();
    _newFoodNameController.dispose();
    _newBaseQuantityController.dispose();
    _newCaloriesController.dispose();
    _newLogQuantityController.dispose();
    super.dispose();
  }

  String _normalize(String value) {
    return value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
  }

  String _formatQuantity(double value) {
    if (value % 1 == 0) {
      return value.toStringAsFixed(0);
    }

    return value.toStringAsFixed(1);
  }

  List<FoodItemModel> _filteredFoods() {
    final query = _normalize(_searchController.text);

    if (query.isEmpty) {
      return widget.foodItems.take(8).toList();
    }

    return widget.foodItems.where((food) {
      return food.normalizedName.contains(query) ||
          _normalize(food.name).contains(query);
    }).take(10).toList();
  }

  bool _hasExactMatch() {
    final query = _normalize(_searchController.text);

    if (query.isEmpty) {
      return true;
    }

    return widget.foodItems.any((food) {
      return food.normalizedName == query || _normalize(food.name) == query;
    });
  }

  void _selectFood(FoodItemModel food) {
    setState(() {
      _selectedFood = food;
      _searchController.text = food.name;
      _quantityController.text = _formatQuantity(food.baseQuantity);
    });
  }

  void _clearSelection() {
    setState(() {
      _selectedFood = null;
      _quantityController.clear();
      _noteController.clear();
    });
  }

  Future<void> _saveExistingFood() async {
    final selectedFood = _selectedFood;
    final quantity = double.tryParse(_quantityController.text.trim());

    if (selectedFood == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a food first.')),
      );
      return;
    }

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

  Future<void> _saveMissingFood() async {
    final searchedName = _searchController.text.trim();
    final typedName = _newFoodNameController.text.trim();

    final name = typedName.isNotEmpty ? typedName : searchedName;
    final baseQuantity = double.tryParse(
      _newBaseQuantityController.text.trim(),
    );
    final calories = double.tryParse(
      _newCaloriesController.text.trim(),
    );
    final logQuantity = double.tryParse(
      _newLogQuantityController.text.trim(),
    );

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a food name.')),
      );
      return;
    }

    if (baseQuantity == null || baseQuantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid base quantity.')),
      );
      return;
    }

    if (calories == null || calories < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter valid calories.')),
      );
      return;
    }

    if (logQuantity == null || logQuantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid log quantity.')),
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
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
    final colorScheme = Theme.of(context).colorScheme;
    final filteredFoods = _filteredFoods();
    final query = _searchController.text.trim();
    final showMissingFoodForm = query.isNotEmpty && !_hasExactMatch();

    return Padding(
      padding: EdgeInsets.only(bottom: bottomPadding),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.gap20,
            AppSpacing.gap16,
            AppSpacing.gap20,
            AppSpacing.gap24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: colorScheme.primaryContainer,
                    foregroundColor: colorScheme.onPrimaryContainer,
                    child: const Icon(Icons.restaurant_rounded),
                  ),
                  const SizedBox(width: AppSpacing.gap12),
                  Expanded(
                    child: Text(
                      'Log Food',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.gap16),
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  labelText: 'Search food',
                  hintText: 'Example: rice, egg, banana',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: query.isEmpty
                      ? null
                      : IconButton(
                          onPressed: () {
                            _searchController.clear();
                            _clearSelection();
                          },
                          icon: const Icon(Icons.clear_rounded),
                        ),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: AppSpacing.gap16),
              if (_selectedFood != null)
                _SelectedFoodSection(
                  food: _selectedFood!,
                  quantityController: _quantityController,
                  noteController: _noteController,
                  isSaving: _isSaving,
                  onChangeFood: _clearSelection,
                  onSave: _saveExistingFood,
                )
              else ...[
                _FoodSearchResults(
                  foods: filteredFoods,
                  onSelectFood: _selectFood,
                ),
                if (showMissingFoodForm) ...[
                  const SizedBox(height: AppSpacing.gap16),
                  _MissingFoodForm(
                    searchedName: query,
                    nameController: _newFoodNameController,
                    baseQuantityController: _newBaseQuantityController,
                    caloriesController: _newCaloriesController,
                    logQuantityController: _newLogQuantityController,
                    noteController: _noteController,
                    unit: _newFoodUnit,
                    isSaving: _isSaving,
                    onUnitChanged: (value) {
                      if (value == null) {
                        return;
                      }

                      setState(() {
                        _newFoodUnit = value;
                      });
                    },
                    onSave: _saveMissingFood,
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _FoodSearchResults extends StatelessWidget {
  const _FoodSearchResults({
    required this.foods,
    required this.onSelectFood,
  });

  final List<FoodItemModel> foods;
  final ValueChanged<FoodItemModel> onSelectFood;

  String _formatQuantity(double value) {
    if (value % 1 == 0) {
      return value.toStringAsFixed(0);
    }

    return value.toStringAsFixed(1);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (foods.isEmpty) {
      return AppCard(
        child: Row(
          children: [
            Icon(
              Icons.search_off_rounded,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: AppSpacing.gap8),
            Expanded(
              child: Text(
                'No matching food found. Add it below.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Choose from dictionary',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
        const SizedBox(height: AppSpacing.gap8),
        ...foods.map((food) {
          return AppCard(
            margin: const EdgeInsets.only(bottom: AppSpacing.gap8),
            padding: const EdgeInsets.all(AppSpacing.gap12),
            onTap: () => onSelectFood(food),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: colorScheme.primaryContainer,
                  foregroundColor: colorScheme.onPrimaryContainer,
                  child: const Icon(
                    Icons.restaurant_menu_rounded,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppSpacing.gap12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        food.name,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: AppSpacing.gap4),
                      Text(
                        '${food.calories.round()} kcal / '
                        '${_formatQuantity(food.baseQuantity)} ${food.unit}',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded),
              ],
            ),
          );
        }),
      ],
    );
  }
}

class _SelectedFoodSection extends StatelessWidget {
  const _SelectedFoodSection({
    required this.food,
    required this.quantityController,
    required this.noteController,
    required this.isSaving,
    required this.onChangeFood,
    required this.onSave,
  });

  final FoodItemModel food;
  final TextEditingController quantityController;
  final TextEditingController noteController;
  final bool isSaving;
  final VoidCallback onChangeFood;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        AppCard(
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: colorScheme.primaryContainer,
                foregroundColor: colorScheme.onPrimaryContainer,
                child: const Icon(Icons.check_rounded),
              ),
              const SizedBox(width: AppSpacing.gap12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      food.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: AppSpacing.gap4),
                    Text(
                      '${food.calories.round()} kcal / '
                      '${food.baseQuantity.round()} ${food.unit}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: onChangeFood,
                child: const Text('Change'),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.gap16),
        TextField(
          controller: quantityController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Quantity (${food.unit})',
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: AppSpacing.gap12),
        TextField(
          controller: noteController,
          decoration: const InputDecoration(
            labelText: 'Note optional',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: AppSpacing.gap20),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: isSaving ? null : onSave,
            icon: const Icon(Icons.save_rounded),
            label: Text(isSaving ? 'Saving...' : 'Log Food'),
          ),
        ),
      ],
    );
  }
}

class _MissingFoodForm extends StatelessWidget {
  const _MissingFoodForm({
    required this.searchedName,
    required this.nameController,
    required this.baseQuantityController,
    required this.caloriesController,
    required this.logQuantityController,
    required this.noteController,
    required this.unit,
    required this.isSaving,
    required this.onUnitChanged,
    required this.onSave,
  });

  final String searchedName;
  final TextEditingController nameController;
  final TextEditingController baseQuantityController;
  final TextEditingController caloriesController;
  final TextEditingController logQuantityController;
  final TextEditingController noteController;
  final String unit;
  final bool isSaving;
  final ValueChanged<String?> onUnitChanged;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Add "$searchedName" to dictionary',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: AppSpacing.gap4),
          Text(
            'Save its calories once. Next time it will appear in search.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: AppSpacing.gap16),
          TextField(
            controller: nameController,
            decoration: InputDecoration(
              labelText: 'Food name',
              hintText: searchedName,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: AppSpacing.gap12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: baseQuantityController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Base qty',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.gap8),
              SizedBox(
                width: 110,
                child: DropdownButtonFormField<String>(
                  initialValue: unit,
                  decoration: const InputDecoration(
                    labelText: 'Unit',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'g',
                      child: Text('g'),
                    ),
                    DropdownMenuItem(
                      value: 'ml',
                      child: Text('ml'),
                    ),
                    DropdownMenuItem(
                      value: 'piece',
                      child: Text('piece'),
                    ),
                    DropdownMenuItem(
                      value: 'cup',
                      child: Text('cup'),
                    ),
                    DropdownMenuItem(
                      value: 'plate',
                      child: Text('plate'),
                    ),
                  ],
                  onChanged: onUnitChanged,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.gap12),
          TextField(
            controller: caloriesController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Calories for base quantity',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: AppSpacing.gap12),
          TextField(
            controller: logQuantityController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Quantity eaten ($unit)',
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: AppSpacing.gap12),
          TextField(
            controller: noteController,
            decoration: const InputDecoration(
              labelText: 'Note optional',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: AppSpacing.gap20),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: isSaving ? null : onSave,
              icon: const Icon(Icons.save_rounded),
              label: Text(isSaving ? 'Saving...' : 'Save and Log Food'),
            ),
          ),
        ],
      ),
    );
  }
}