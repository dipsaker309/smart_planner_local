import 'package:flutter/material.dart';

import '../../../../data/local/models/food_log_model.dart';
import '../../../../core/utils/date_utils.dart';

class FoodLogTile extends StatelessWidget {
  const FoodLogTile({
    required this.log,
    super.key,
  });

  final FoodLogModel log;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.restaurant_outlined),
      title: Text('${log.totalCalories} calories'),
      subtitle: Text(AppDateUtils.formatShortDate(log.date)),
    );
  }
}
