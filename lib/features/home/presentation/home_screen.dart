import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../calories/presentation/calorie_screen.dart';
import '../../dashboard/application/dashboard_controller.dart';
import '../../dashboard/presentation/dashboard_screen.dart';
import '../../planner/presentation/planner_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedIndex = 0;

  void _changeTab(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 0) {
      ref.invalidate(dashboardSummaryProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      DashboardScreen(
        onOpenPlanner: () => _changeTab(1),
        onOpenCalories: () => _changeTab(2),
      ),
      const PlannerScreen(),
      const CalorieScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _changeTab,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard_rounded),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.checklist_outlined),
            selectedIcon: Icon(Icons.checklist_rounded),
            label: 'Planner',
          ),
          NavigationDestination(
            icon: Icon(Icons.local_fire_department_outlined),
            selectedIcon: Icon(Icons.local_fire_department_rounded),
            label: 'Calories',
          ),
        ],
      ),
    );
  }
}