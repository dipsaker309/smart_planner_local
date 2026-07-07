import 'package:flutter/material.dart';

import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/empty_state.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppScaffold(
      title: 'Analytics',
      body: EmptyState(
        icon: Icons.bar_chart_outlined,
        title: 'Analytics',
        message: 'Calorie analytics will be added here.',
      ),
    );
  }
}
