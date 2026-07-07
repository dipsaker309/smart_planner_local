import 'package:flutter/material.dart';

import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/empty_state.dart';

class CalorieScreen extends StatelessWidget {
  const CalorieScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppScaffold(
      title: 'Calories',
      body: EmptyState(
        icon: Icons.local_fire_department_outlined,
        title: 'Calories',
        message: 'Food logging will be added here.',
      ),
    );
  }
}
