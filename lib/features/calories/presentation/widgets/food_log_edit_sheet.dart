import 'package:flutter/material.dart';

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

    return Padding(
      padding: EdgeInsets.only(bottom: bottomPadding),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Edit Food Log',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.restaurant_menu_rounded),
              title: Text(widget.log.foodName),
              subtitle: Text(
                '${widget.log.calculatedCalories.round()} kcal currently',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _quantityController,
              autofocus: true,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Quantity (${widget.log.unit})',
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
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: _isSaving ? null : _save,
              icon: const Icon(Icons.save_rounded),
              label: Text(_isSaving ? 'Saving...' : 'Update Log'),
            ),
          ],
        ),
      ),
    );
  }
}