import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../data/local/models/food_log_model.dart';

class FoodLogEditSheet extends StatefulWidget {
  const FoodLogEditSheet({
    super.key,
    required this.log,
    required this.onSubmit,
  });

  final FoodLogModel log;

  final Future<void> Function({
    required double quantity,
    required String note,
  }) onSubmit;

  @override
  State<FoodLogEditSheet> createState() => _FoodLogEditSheetState();
}

class _FoodLogEditSheetState extends State<FoodLogEditSheet> {
  late final TextEditingController _quantityController;
  late final TextEditingController _noteController;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    _quantityController = TextEditingController(
      text: _formatQuantity(widget.log.quantity),
    );
    _noteController = TextEditingController(text: widget.log.note);
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  String _formatQuantity(double value) {
    if (value % 1 == 0) {
      return value.toStringAsFixed(0);
    }

    return value.toStringAsFixed(1);
  }

  Future<void> _save() async {
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

    await widget.onSubmit(
      quantity: quantity,
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

    return Padding(
      padding: EdgeInsets.only(bottom: bottomPadding),
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
                  child: const Icon(Icons.edit_rounded),
                ),
                const SizedBox(width: AppSpacing.gap12),
                Expanded(
                  child: Text(
                    'Edit Food Log',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.gap16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.gap16),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: colorScheme.outlineVariant,
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.restaurant_menu_rounded),
                  const SizedBox(width: AppSpacing.gap12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.log.foodName,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                        ),
                        const SizedBox(height: AppSpacing.gap4),
                        Text(
                          '${widget.log.calculatedCalories.round()} kcal currently',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.gap16),
            TextField(
              controller: _quantityController,
              autofocus: true,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Quantity (${widget.log.unit})',
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: AppSpacing.gap12),
            TextField(
              controller: _noteController,
              decoration: const InputDecoration(
                labelText: 'Note optional',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: AppSpacing.gap20),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _isSaving ? null : _save,
                icon: const Icon(Icons.save_rounded),
                label: Text(_isSaving ? 'Saving...' : 'Update Log'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}