import 'package:flutter/material.dart';

import '../../../../core/utils/date_utils.dart';
import '../../../../data/local/models/food_log_model.dart';

class FoodLogTile extends StatelessWidget {
  const FoodLogTile({
    super.key,
    required this.log,
    required this.onDelete,
  });

  final FoodLogModel log;
  final VoidCallback onDelete;

  String _formatQuantity(double value) {
    if (value % 1 == 0) {
      return value.toStringAsFixed(0);
    }

    return value.toStringAsFixed(1);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          child: Text(
            log.calculatedCalories.round().toString(),
            style: const TextStyle(fontSize: 12),
          ),
        ),
        title: Text(log.foodName),
        subtitle: Text(
          '${_formatQuantity(log.quantity)} ${log.unit}'
          ' • ${AppDateUtils.formatTime(log.consumedAt)}',
        ),
        trailing: IconButton(
          onPressed: onDelete,
          icon: const Icon(Icons.delete_outline_rounded),
          tooltip: 'Delete food log',
        ),
      ),
    );
  }
}