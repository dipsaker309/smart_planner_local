import 'package:flutter/material.dart';

import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/empty_state.dart';

class PlannerScreen extends StatelessWidget {
  const PlannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppScaffold(
      title: 'Planner',
      body: EmptyState(
        icon: Icons.checklist_outlined,
        title: 'Planner',
        message: 'Task planning will be added here.',
      ),
    );
  }
}
