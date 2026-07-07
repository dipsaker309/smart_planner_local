import 'package:flutter/material.dart';

class CalorieScreen extends StatelessWidget {
  const CalorieScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calorie Tracker'),
      ),
      body: const Center(
        child: Text(
          'Calorie tracker feature will be built here.',
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}